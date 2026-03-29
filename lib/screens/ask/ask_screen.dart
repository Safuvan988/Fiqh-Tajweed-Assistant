import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quranfiqh/core/theme/app_theme.dart';
import 'package:quranfiqh/models/chat_message.dart';
import 'package:quranfiqh/widgets/answer_card.dart';
import 'package:quranfiqh/services/gemini_service.dart';

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
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = List.from(_initialMessages);
  bool _isTyping = false;
  bool _isAILoading = false; // 🔥 API Lock
  List<dynamic> _masaalaData = [];

  // 🎬 Streaming animation state
  String? _pendingStreamText;
  ChatMessage? _pendingBotMessage;

  @override
  void initState() {
    super.initState();
    _loadMasaalaData();
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
    if (text.isEmpty || _isAILoading) return; // 🔥 Prevents duplicate calls

    final usedLang = AppLanguage.en; // GeminiService auto-detects language

    _controller.clear();
    setState(() {
      _messages.add(ChatMessage(sender: MessageSender.user, text: text));
      _isTyping = true;
      _isAILoading = true; // 🔥 Lock ON
    });
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 600), () async {
      if (!mounted) return;

      try {
        final match = _findBestMatch(text);
        String responseText;
        Map<String, dynamic>? aiData;

        if (match != null) {
          // Build response text directly from local data (Fallback practice)
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
          // 1. Check for common greetings to reduce API usage
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
            // 2. Use GeminiService directly
            aiData = await GeminiService.getAnswer(text);
            responseText = aiData['ruling'] ?? "Something went wrong.";
          }
        }

        ChatMessage responseMessage;

        if (match != null) {
          responseMessage = ChatMessage.fromJson(match);
          // Force the text to match what we constructed
          responseMessage = ChatMessage(
            sender: MessageSender.bot,
            text: responseText,
            translations: responseMessage.translations,
            currentLang: usedLang,
            quranArabic: responseMessage.quranArabic,
            quranReference: responseMessage.quranReference,
            hadithArabic: responseMessage.hadithArabic,
            hadithReference: responseMessage.hadithReference,
          );
        } else if (aiData != null) {
          // Map the AI JSON to structured ChatMessage for rich UI display
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
            quranReference:
                (aiData['quran_reference'] != null &&
                    aiData['quran_reference'] != "")
                ? aiData['quran_reference']
                : null,
            hadithArabic:
                (aiData['hadith_arabic'] != null && aiData['hadith_arabic'] != "")
                ? aiData['hadith_arabic']
                : null,
            hadithReference:
                (aiData['hadith_reference'] != null && aiData['hadith_reference'] != "")
                ? aiData['hadith_reference']
                : null,
          );
        } else {
          responseMessage = ChatMessage(
            sender: MessageSender.bot,
            text: responseText,
            currentLang: usedLang,
          );
        }

        setState(() {
          _isTyping = false;
          _isAILoading = false; // 🔥 Lock OFF
          // 🎬 Begin typewriter animation
          _pendingStreamText = responseText;
          _pendingBotMessage = responseMessage;
        });
        _scrollToBottom();
      } catch (e) {
        setState(() {
          _isTyping = false;
          _isAILoading = false; // 🔥 Lock OFF
        });
        debugPrint("Error sending message: $e");
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

  void _onStreamingComplete() {
    if (!mounted) return;
    setState(() {
      if (_pendingBotMessage != null) {
        _messages.add(_pendingBotMessage!);
      }
      _pendingStreamText = null;
      _pendingBotMessage = null;
    });
    _scrollToBottom();
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
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // ── Header Actions ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: _resetChat,
                  icon: SvgPicture.asset(
                    'assets/icons/bubble-chat-add-stroke-rounded.svg',
                    width: 16,
                    height: 16,
                    colorFilter: const ColorFilter.mode(
                      AppColors.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: Text(
                    'New Chat',
                    style: AppTextStyles.englishCaption(
                      fontSize: 12,
                      color: AppColors.primary,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.05),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount:
                  _messages.length +
                  (_isTyping ? 1 : 0) +
                  (_pendingStreamText != null ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Welcome Message + Centered Prompt if no messages yet
                  final onlyInitial =
                      _messages.length == 1 &&
                      _messages[0].text == _initialMessages[0].text;

                  return Column(
                    children: [
                      _ChatBubble(message: _messages[0]),
                      if (onlyInitial)
                        Padding(
                          padding: const EdgeInsets.only(top: 80),
                          child: Center(
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.05,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: SvgPicture.asset(
                                    'assets/icons/bubble-chat-add-stroke-rounded.svg',
                                    width: 40,
                                    height: 40,
                                    colorFilter: const ColorFilter.mode(
                                      AppColors.primary,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Ask a Question',
                                  style: AppTextStyles.englishDisplay(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Type any question about Shafi\'i Fiqh\nor Tajweed below.',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.englishBody(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                }

                // Regular messages
                if (index < _messages.length) {
                  return _ChatBubble(message: _messages[index]);
                }

                // 🎬 Typewriter streaming bubble
                if (_pendingStreamText != null && index == _messages.length) {
                  return _StreamingBubble(
                    key: const ValueKey('streaming'),
                    fullText: _pendingStreamText!,
                    onComplete: _onStreamingComplete,
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
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Chat Bubble
// ─────────────────────────────────────────────────────────────

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isBot = message.sender == MessageSender.bot;
    final hasAnswer =
        message.translations != null &&
        message.translations![message.currentLang] != null;

    if (isBot && hasAnswer) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: AnswerCard(
          data: message.translations![message.currentLang]!,
          quranArabic: message.quranArabic,
          quranReference: message.quranReference,
          hadithArabic: message.hadithArabic,
          hadithReference: message.hadithReference,
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
          color: isBot ? AppColors.botMsgBg : AppColors.userMsgBg,
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
        child: Text(
          message.text,
          style: AppTextStyles.englishBody(
            color: isBot ? AppColors.botMsgText : AppColors.userMsgText,
            fontSize: 14,
          ),
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
          color: AppColors.botMsgBg,
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
                  color: AppColors.botMsgText,
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
      builder: (_, __) => Opacity(
        opacity: _ctrl.value,
        child: Container(
          width: 2,
          height: 15,
          margin: const EdgeInsets.only(left: 3, bottom: 1),
          decoration: BoxDecoration(
            color: AppColors.botMsgText,
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
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
          border: Border.all(color: AppColors.divider, width: 0.8),
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
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: const BoxDecoration(color: AppColors.background),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: (_) => onSend(),
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Type your question...',
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textLight,
                ),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(
                    color: AppColors.divider,
                    width: 0.8,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(
                    color: AppColors.divider,
                    width: 0.8,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: AppColors.primary,
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
