import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:quranfiqh/services/firestore_service.dart';
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quranfiqh/core/theme/app_theme.dart';
import 'package:quranfiqh/models/chat_message.dart';
import 'package:quranfiqh/widgets/answer_card.dart';
import 'package:quranfiqh/services/gemini_service.dart';
import 'package:quranfiqh/services/chat_history_service.dart';
import 'package:quranfiqh/widgets/history_drawer.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// ─────────────────────────────────────────────────────────────
//  Ask Screen
// ─────────────────────────────────────────────────────────────

final List<ChatMessage> _initialMessages = [
  ChatMessage(
    sender: MessageSender.bot,
    text:
        'Assalamu Alaikum! 👋\nI\'m your Fiqh & Tajweed Assistant. Ask me any Islamic ruling or recitation question.',
    translations: {
      AppLanguage.en: const LocalizedContent(
        text:
            'Assalamu Alaikum! 👋\nI\'m your Fiqh & Tajweed Assistant. Ask me any Islamic ruling.',
      ),
      AppLanguage.ml: const LocalizedContent(
        text:
            'അസ്സലാമു അലൈക്കും! 👋\nഞാൻ നിങ്ങളുടെ ഫിഖ്ഹ് സാമ്രാജ്യമാണ്. നിങ്ങൾക്ക് എന്ത് സംശയവും ചോദിക്കാം.',
      ),
      AppLanguage.ar: const LocalizedContent(
        text: 'السلام عليكم! 👋\nأنا مساعدك في الفقه والتجويد. اسألني أي سؤال.',
      ),
    },
  ),
];

class AskScreen extends StatefulWidget {
  const AskScreen({super.key});

  @override
  State<AskScreen> createState() => _AskScreenState();
}

class _AskScreenState extends State<AskScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = List.from(_initialMessages);

  String? _currentSessionId;
  bool _isTyping = false;
  bool _isAILoading = false;
  List<dynamic> _masaalaData = [];

  // 🎬 Streaming animation state
  String? _pendingStreamText;
  ChatMessage? _pendingBotMessage;

  @override
  void initState() {
    super.initState();
    _loadMasaalaData();
  }

  Future<void> _selectSession(String sessionId) async {
    setState(() {
      _currentSessionId = sessionId;
    });

    final messages = await ChatHistoryService().getSessionMessages(sessionId);

    if (mounted) {
      setState(() {
        _messages.clear();
        if (messages.isEmpty) {
          _messages.addAll(_initialMessages);
        } else {
          _messages.addAll(messages);
        }
      });
      _scrollToBottom();
    }
  }

  Future<void> _loadMasaalaData() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/data/masaala.json',
      );
      final data = await json.decode(response);
      setState(() {
        _masaalaData = data;
      });
    } catch (e) {
      debugPrint("Error loading masaala JSON: $e");
    }
  }

  Map<String, dynamic>? _findBestMatch(String query) {
    if (_masaalaData.isEmpty) return null;

    final normalizedQuery = query.toLowerCase().trim();
    final queryWords = normalizedQuery
        .split(RegExp(r'[\s\?\!\.]+'))
        .where((s) => s.length > 1)
        .toSet();

    if (queryWords.isEmpty) return null;

    Map<String, dynamic>? bestMatch;
    double maxScore = 0.0;

    for (var item in _masaalaData) {
      double score = 0.0;

      // 1. Exact Question Match (Huge Bonus)
      final questions = item['question'] as Map<String, dynamic>? ?? {};
      for (var q in questions.values) {
        if (q.toString().toLowerCase().trim() == normalizedQuery) {
          score += 100.0;
          break;
        }
      }

      // 2. Keyword Match (Strict)
      final keywords =
          (item['keywords'] as List?)
              ?.map((k) => k.toString().toLowerCase())
              .toList() ??
          [];
      for (var kw in keywords) {
        if (kw.isEmpty) continue;
        if (queryWords.contains(kw) || normalizedQuery == kw) {
          score += 20.0;
        } else if (normalizedQuery.contains(kw) && kw.length > 3) {
          score += 5.0;
        }
      }

      // 3. Word Coverage
      int wordHits = 0;
      for (var word in queryWords) {
        if (keywords.contains(word)) {
          wordHits++;
        }
      }

      // Calculate coverage ratio to favor items that match more of the query
      double coverage = wordHits / queryWords.length;
      score += coverage * 30.0;

      // Ensure we don't match on "hi" or short greetings unless they are explicitly in keywords
      if (score > maxScore) {
        maxScore = score;
        bestMatch = item;
      }
    }

    // Threshold: a good match should have at least some keyword hits or high coverage
    return maxScore >= 15.0 ? bestMatch : null;
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isAILoading) return;

    final usedLang = AppLanguage.en;

    _controller.clear();

    final isNewSession = _currentSessionId == null;
    if (isNewSession) {
      _currentSessionId = const Uuid().v4();
    }

    setState(() {
      final userMsg = ChatMessage(sender: MessageSender.user, text: text);
      _messages.add(userMsg);

      final title = isNewSession
          ? (text.length > 30 ? '${text.substring(0, 27)}...' : text)
          : null;

      ChatHistoryService().saveToSession(
        _currentSessionId!,
        userMsg,
        isNewSession
            ? title!
            : _messages.firstWhere((m) => m.sender == MessageSender.user).text,
      );

      _isTyping = true;
      _isAILoading = true;
    });
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 600), () async {
      if (!mounted) return;

      try {
        final match = _findBestMatch(text);
        String responseText;
        Map<String, dynamic>? aiData;

        if (match != null) {
          final langKey = usedLang == AppLanguage.ml
              ? 'ml'
              : (usedLang == AppLanguage.ar ? 'ar' : 'en');
          final answer = match['answer'][langKey] ?? match['answer']['en'];
          final fiqh = match['fiqh'][langKey] ?? match['fiqh']['en'];

          responseText = "Ruling: $answer\n\nExplanation: $fiqh";

          final quran = match['quran'];
          if (quran != null && quran['reference'] != null) {
            responseText += "\n\nQuran Reference: ${quran['reference']}";
          }
        } else {
          final normalizedText = text.toLowerCase();
          final greetings = [
            'hi',
            'hello',
            'salam',
            'assalamu',
            'hey',
            'ഹായ്',
            'സലാം',
          ];
          final isGreeting =
              greetings.any((g) => normalizedText.contains(g)) &&
              normalizedText.length < 15;

          if (isGreeting) {
            responseText =
                "Assalamu Alaikum! How can I help you today with Shafi'i Fiqh or Tajweed questions?";
          } else {
            try {
              aiData = await GeminiService.getAnswer(text);
              if (!mounted) return;
              responseText = aiData['ruling'] ?? "...";
            } catch (e) {
              responseText = "Something went wrong.";
            }
          }
        }

        ChatMessage responseMessage;

        if (aiData != null) {
          final content = LocalizedContent(
            text: responseText,
            ruling: aiData['ruling'],
            fiqhExplanation: aiData['explanation'],
            quranTranslation: aiData['quran_translation'],
            hadithTranslation: aiData['hadith_translation'],
          );

          responseMessage = ChatMessage(
            sender: MessageSender.bot,
            text: responseText,
            translations: {usedLang: content},
            currentLang: usedLang,
            quranArabic:
                (aiData['quran_arabic'] != null && aiData['quran_arabic'] != "")
                    ? aiData['quran_arabic']
                    : null,
            quranReference: (aiData['quran_reference'] != null &&
                    aiData['quran_reference'] != "")
                ? aiData['quran_reference']
                : null,
            hadithArabic: (aiData['hadith_arabic'] != null &&
                    aiData['hadith_arabic'] != "")
                ? aiData['hadith_arabic']
                : null,
            hadithReference: (aiData['hadith_reference'] != null &&
                    aiData['hadith_reference'] != "")
                ? aiData['hadith_reference']
                : null,
          );
        } else {
          responseMessage = ChatMessage(
            sender: MessageSender.bot,
            text: responseText,
            translations: {
              usedLang: LocalizedContent(text: responseText),
            },
            currentLang: usedLang,
          );
        }

        setState(() {
          _isTyping = false;
          _isAILoading = false;
          _pendingStreamText = responseText;
          _pendingBotMessage = responseMessage;
        });
        _scrollToBottom();
      } catch (e) {
        setState(() {
          _isTyping = false;
          _isAILoading = false;
        });
        debugPrint("Error sending message: $e");
        try {
          FirebaseCrashlytics.instance.recordError(
            e,
            StackTrace.current,
            reason: 'Gemini API Failure',
          );
        } catch (_) {}
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 200,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _resetChat() {
    setState(() {
      _messages.clear();
      _messages.addAll(_initialMessages);
      _pendingStreamText = null;
      _pendingBotMessage = null;
      _isTyping = false;
      _isAILoading = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      key: _scaffoldKey,
      drawer: HistoryDrawer(
        currentSessionId: _currentSessionId,
        onSessionSelected: _selectSession,
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Header Actions ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    icon: SvgPicture.asset(
                      'assets/icons/chat-01-stroke-rounded.svg',
                      width: 22,
                      height: 22,
                      colorFilter: ColorFilter.mode(
                        colorScheme.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.primary.withValues(
                        alpha: 0.1,
                      ),
                      padding: const EdgeInsets.all(10),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _resetChat,
                    icon: SvgPicture.asset(
                      'assets/icons/bubble-chat-add-stroke-rounded.svg',
                      width: 16,
                      height: 16,
                      colorFilter: ColorFilter.mode(
                        colorScheme.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                    label: Text(
                      'New Chat',
                      style: AppTextStyles.englishCaption(
                        fontSize: 12,
                        color: colorScheme.primary,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      backgroundColor: colorScheme.primary.withValues(
                        alpha: 0.1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Chat area ───────────────────────────────────────
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                itemCount:
                    _messages.length +
                    (_pendingStreamText != null || _isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  // Special logic for the very first message/greeting
                  if (index == 0 &&
                      _messages.isNotEmpty &&
                      _messages[0].sender == MessageSender.bot &&
                      _currentSessionId == null) {
                    return Column(
                      children: [
                        // Welcome Logo/Icon
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 40, bottom: 20),
                            child: Column(
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/chat-01-stroke-rounded.svg',
                                  width: 60,
                                  height: 60,
                                  colorFilter: ColorFilter.mode(
                                    colorScheme.primary.withValues(alpha: 0.2),
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Ask a Question',
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: colorScheme.onSurface,
                                        letterSpacing: -0.5,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Explore Shafi'i Fiqh & Tajweed rulings\nin a simple conversation.",
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.englishBody(
                                    fontSize: 15,
                                    color: colorScheme.onSurfaceVariant,
                                  ).copyWith(height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  if (index < _messages.length) {
                    final prevMessage = index > 0 ? _messages[index - 1] : null;
                    return _ChatBubble(
                      message: _messages[index],
                      onBookmark:
                          _messages[index].sender == MessageSender.bot &&
                              prevMessage != null &&
                              prevMessage.sender == MessageSender.user
                          ? () async {
                              final firebaseUser =
                                  FirebaseAuth.instance.currentUser;
                              if (firebaseUser == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please login to save answers',
                                    ),
                                  ),
                                );
                                return;
                              }
                              final r = _messages[index]
                                  .translations![_messages[index].currentLang]!;
                              final messenger = ScaffoldMessenger.of(context);
                              await FirestoreService.saveBookmark(
                                firebaseUser.uid,
                                prevMessage.text,
                                r.ruling ?? r.text,
                              );
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Saved to bookmarks'),
                                ),
                              );
                            }
                          : null,
                    );
                  }

                  // 🎬 Typewriter streaming bubble
                  if (_pendingStreamText != null && index == _messages.length) {
                    return _StreamingBubble(
                      key: const ValueKey('streaming'),
                      fullText: _pendingStreamText!,
                      onComplete: () {
                        if (!mounted) return;
                        setState(() {
                          if (_pendingBotMessage != null) {
                            _messages.add(_pendingBotMessage!);
                            if (_currentSessionId != null) {
                              ChatHistoryService().saveToSession(
                                _currentSessionId!,
                                _pendingBotMessage!,
                                "",
                              );
                            }
                          }
                          _pendingStreamText = null;
                          _pendingBotMessage = null;
                        });
                        _scrollToBottom();
                      },
                    );
                  }

                  // Bouncing dots (API loading)
                  return _TypingIndicator();
                },
              ),
            ),

            // ── Input bar ───────────────────────────────────────
            _InputBar(controller: _controller, onSend: _sendMessage),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Chat Bubble
// ─────────────────────────────────────────────────────────────

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onBookmark;

  const _ChatBubble({required this.message, this.onBookmark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBot = message.sender == MessageSender.bot;
    final hasAnswer =
        message.translations != null &&
        message.translations![message.currentLang] != null;

    if (isBot && hasAnswer) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            AnswerCard(
              data: message.translations![message.currentLang]!,
              quranArabic: message.quranArabic,
              quranReference: message.quranReference,
              hadithArabic: message.hadithArabic,
              hadithReference: message.hadithReference,
            ),
            if (onBookmark != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextButton.icon(
                  onPressed: onBookmark,
                  icon: Icon(
                    Icons.bookmark_border,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  label: Text(
                    'Save Answer',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary.withValues(
                      alpha: 0.1,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isBot
              ? theme.colorScheme.surfaceContainerHighest
              : theme.colorScheme.primary,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isBot ? 4 : 16),
            bottomRight: Radius.circular(isBot ? 16 : 4),
          ),
          boxShadow: [
            if (isBot)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.text,
              style: AppTextStyles.englishBody(
                color: isBot
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onPrimary,
                fontSize: 14,
              ),
            ),
            if (onBookmark != null && isBot)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: InkWell(
                  onTap: onBookmark,
                  child: Icon(
                    Icons.bookmark_border,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Streaming Typewriter Bubble
// ─────────────────────────────────────────────────────────────

class _StreamingBubble extends StatefulWidget {
  final String fullText;
  final VoidCallback onComplete;

  const _StreamingBubble({
    super.key,
    required this.fullText,
    required this.onComplete,
  });

  @override
  State<_StreamingBubble> createState() => _StreamingBubbleState();
}

class _StreamingBubbleState extends State<_StreamingBubble> {
  String _displayed = '';
  int _charIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() {
    _timer = Timer.periodic(const Duration(milliseconds: 18), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_charIndex < widget.fullText.length) {
        setState(() {
          _charIndex++;
          _displayed = widget.fullText.substring(0, _charIndex);
        });
      } else {
        timer.cancel();
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                _displayed,
                style: AppTextStyles.englishBody(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14,
                ),
              ),
            ),
            const _BlinkingCursor(),
          ],
        ),
      ),
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor();

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 530),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) => Opacity(
        opacity: _ctrl.value,
        child: Container(
          width: 2,
          height: 15,
          margin: const EdgeInsets.only(left: 3, bottom: 1),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Typing Indicator
// ─────────────────────────────────────────────────────────────

class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
          border: Border.all(
            color: theme.colorScheme.outlineVariant,
            width: 0.8,
          ),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                final offset = ((_controller.value * 3) - i).clamp(0.0, 1.0);
                final bounce = (offset < 0.5) ? offset * 2 : (1.0 - offset) * 2;
                return Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(
                      alpha: 0.3 + (bounce * 0.7),
                    ),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Input Bar
// ─────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _InputBar({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(color: theme.scaffoldBackgroundColor),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: (_) => onSend(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Type your question...',
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                filled: true,
                fillColor: theme.cardTheme.color,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: colorScheme.outlineVariant,
                    width: 0.8,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 1.2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: SvgPicture.asset(
                'assets/icons/sent-stroke-rounded.svg',
                width: 18,
                height: 18,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
              onPressed: onSend,
            ),
          ),
        ],
      ),
    );
  }
}
