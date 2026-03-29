import 'package:flutter/material.dart';
import 'package:quranfiqh/core/theme/app_theme.dart';

class AskScreen extends StatelessWidget {
  const AskScreen({super.key});

  @override
  State<AskScreen> createState() => _AskScreenState();
}

class _AskScreenState extends State<AskScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = List.from(_initialMessages);
  bool _isTyping = false;
  List<dynamic> _masaalaData = [];
  final AiService _aiService = AiService();


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

  AppLanguage _detectLanguage(String text) {
    if (RegExp(r'[\u0D00-\u0D7F]').hasMatch(text)) return AppLanguage.ml;
    if (RegExp(r'[\u0600-\u06FF]').hasMatch(text)) return AppLanguage.ar;
    return AppLanguage.en;
  }

  Map<String, dynamic>? _findBestMatch(String query) {
    if (_masaalaData.isEmpty) return null;

    final normalizedQuery = query.toLowerCase().trim();
    final queryWords = normalizedQuery
        .split(RegExp(r'\s+'))
        .where((s) => s.length > 2)
        .toList();

    Map<String, dynamic>? bestMatch;
    int maxScore = 0;

    for (var item in _masaalaData) {
      int score = 0;

      // 1. Keyword matching (High weight)
      final keywords =
          (item['keywords'] as List?)
              ?.map((k) => k.toString().toLowerCase())
              .toList() ??
          [];
      for (var kw in keywords) {
        if (normalizedQuery.contains(kw)) {
          score += 10;
        }
      }

      // 2. Question matching (Highest weight)
      final question = item['question']?.toString().toLowerCase() ?? '';
      if (question.contains(normalizedQuery)) {
        score += 15;
      }

      // 3. Incremental word-based score
      for (var word in queryWords) {
        if (keywords.any((kw) => kw.contains(word))) score += 5;
        if (question.contains(word)) score += 3;
      }

      if (score > maxScore) {
        maxScore = score;
        bestMatch = item;
      }
    }

    return maxScore >= 8 ? bestMatch : null;
  }

  void _handleQuestion(String text) {
    _controller.text = text;
    _sendMessage();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final usedLang = _detectLanguage(text);

    setState(() {
      _messages.add(ChatMessage(sender: MessageSender.user, text: text));
      _isTyping = true;
    });
    _controller.clear();
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 600), () async {
      if (!mounted) return;

      final match = _findBestMatch(text);
      
      // Use AI to get a rephrased or polite response
      final rephrasedText = await _aiService.rephraseResponse(
        userQuery: text,
        lang: usedLang,
        matchData: match,
      );

      ChatMessage responseMessage;

      if (match != null) {
        responseMessage = ChatMessage.fromJson(match);
        // Overwrite the default short text with the conversational AI response
        responseMessage = ChatMessage(
          sender: MessageSender.bot,
          text: rephrasedText,
          translations: responseMessage.translations,
          currentLang: usedLang,
          quranArabic: responseMessage.quranArabic,
          quranReference: responseMessage.quranReference,
          hadithArabic: responseMessage.hadithArabic,
          hadithReference: responseMessage.hadithReference,
        );
      } else {
        responseMessage = ChatMessage(
          sender: MessageSender.bot,
          text: rephrasedText,
          currentLang: usedLang,
        );
      }

      setState(() {
        _isTyping = false;
        _messages.add(responseMessage);
      });
      _scrollToBottom();
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

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Header ──────────────────────────────────────────
        AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          centerTitle: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ask a Question'),
              Text(
                'Fiqh & Tajweed Assistant',
                style: AppTextStyles.englishCaption(
                  fontSize: 11,
                  color: AppColors.textOnPrimary.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert_rounded),
              onPressed: () {},
            ),
          ],
        ),

        // ── Chat area ───────────────────────────────────────
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: _messages.length + (_isTyping ? 1 : 0) + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20, top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Categories',
                        style: AppTextStyles.englishDisplay(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _CategoryItem(
                              emoji: '💧',
                              assetPath:
                                  'assets/icons/book-open-02-stroke-rounded.svg',
                              label: 'Wudu',
                              color: const Color(0xFF2196F3),
                              onTap: () => _handleQuestion('What breaks wudu?'),
                            ),
                            const SizedBox(width: 12),
                            _CategoryItem(
                              emoji: '🕌',
                              assetPath:
                                  'assets/icons/chat-01-stroke-rounded.svg',
                              label: 'Salah',
                              color: AppColors.primary,
                              onTap: () =>
                                  _handleQuestion('How to perform Qasr?'),
                            ),
                            const SizedBox(width: 12),
                            _CategoryItem(
                              emoji: '🌙',
                              label: 'Fasting',
                              color: const Color(0xFF9C27B0),
                              onTap: () =>
                                  _handleQuestion('When to start fast?'),
                            ),
                            const SizedBox(width: 12),
                            _CategoryItem(
                              emoji: '🤲',
                              label: 'Zakah',
                              color: AppColors.gold,
                              onTap: () => _handleQuestion('What is Nisab?'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
              final messageIndex = index - 1;
              if (messageIndex == _messages.length) return _TypingIndicator();
              return _ChatBubble(message: _messages[messageIndex]);
            },
          ),
        ),

        // ── Input bar ───────────────────────────────────────
        _InputBar(controller: _controller, onSend: _sendMessage),
      ],
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
    return Scaffold(
      appBar: AppBar(title: const Text('Ask')),
      body: Center(
        child: Text(
          message.text,
          style: AppTextStyles.englishBody(
            color: isBot ? AppColors.textPrimary : AppColors.textOnPrimary,
            fontSize: 14,
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
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.divider, width: 0.8)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.divider, width: 0.8),
              ),
              child: TextField(
                controller: controller,
                onSubmitted: (_) => onSend(),
                decoration: const InputDecoration(
                  hintText: 'Type your question...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: AppColors.textLight,
                  ),
                ),
                style: const TextStyle(fontSize: 14),
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
              icon: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: onSend,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Category Item
// ─────────────────────────────────────────────────────────────

class _CategoryItem extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final String? assetPath;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.emoji,
    required this.label,
    required this.color,
    this.assetPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 0.8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: assetPath != null
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: SvgPicture.asset(
                        assetPath!,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    )
                  : Text(emoji, style: const TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: AppTextStyles.englishDisplay(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
