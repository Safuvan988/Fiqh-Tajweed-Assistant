import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quranfiqh/core/theme/app_theme.dart';
import 'package:quranfiqh/widgets/audio_player_widget.dart';
import 'package:quranfiqh/services/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';

// ─────────────────────────────────────────────────────────────
//  Data Models
// ─────────────────────────────────────────────────────────────

class TajweedRule {
  final String name;
  final String arabicName;
  final String description;
  final String exampleRef;
  final String exampleArabic;
  final String audioUrl;

  const TajweedRule({
    required this.name,
    required this.arabicName,
    required this.description,
    required this.exampleRef,
    required this.exampleArabic,
    required this.audioUrl,
  });
}

const List<TajweedRule> _rules = [
  TajweedRule(
    name: 'Ikhfa — Concealment',
    arabicName: 'إخفاء',
    description:
        'When a Noon Sakinah or Tanween is followed by any of the 15 Ikhfa letters. The sound is pronounced between Izhar and Idgham with Ghunnah.',
    exampleRef: 'Surah Al-Falaq (113:2)',
    exampleArabic: 'مِن شَرِّ',
    audioUrl: 'https://www.everyayah.com/data/Al_Husary_128kbps/113002.mp3',
  ),
  TajweedRule(
    name: 'Idgham — Merging',
    arabicName: 'إدغام',
    description:
        'When Noon Sakinah or Tanween is followed by (ي، ر، م، ل، و، ن). It merges the first letter into the second.',
    exampleRef: 'Surah Al-Masad (111:1)',
    exampleArabic: 'أَبِي لَهَبٍ وَتَبَّ',
    audioUrl: 'https://www.everyayah.com/data/Al_Husary_128kbps/111001.mp3',
  ),
  TajweedRule(
    name: 'Iqlab — Changing',
    arabicName: 'إقلاب',
    description:
        'When Noon Sakinah or Tanween is followed by a Ba (ب). The Noon changes into a hidden Meem (م) with Ghunnah.',
    exampleRef: 'Surah Al-Baqarah (2:246)',
    exampleArabic: 'مِن بَعْدِ',
    audioUrl: 'https://www.everyayah.com/data/Al_Husary_128kbps/002246.mp3',
  ),
  TajweedRule(
    name: 'Qalqalah — Echo',
    arabicName: 'قلقلة',
    description:
        'A bouncing or echoing sound when pronouncing the letters (ق، ط، ب، ج، د) when they carry a Sukoon.',
    exampleRef: 'Surah Al-Ikhlas (112:1)',
    exampleArabic: 'قُلْ هُوَ اللَّهُ أَحَدٌ',
    audioUrl: 'https://www.everyayah.com/data/Al_Husary_128kbps/112001.mp3',
  ),
];

// ─────────────────────────────────────────────────────────────
//  Tajweed Screen
// ─────────────────────────────────────────────────────────────

class TajweedScreen extends StatelessWidget {
  const TajweedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tajweed Lab'),
        actions: [
          IconButton(
            icon: SizedBox(
              width: 22,
              height: 22,
              child: SvgPicture.asset(
                'assets/icons/information-diamond-stroke-rounded.svg',
                semanticsLabel: 'Information',
                colorFilter: ColorFilter.mode(
                  AppColors.textPrimary.withValues(alpha: 0.8),
                  BlendMode.srcIn,
                ),
              ),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemCount: _rules.length,
        separatorBuilder: (_, _) => const SizedBox(height: 16),
        itemBuilder: (context, i) => _TajweedCard(rule: _rules[i]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Tajweed Card (Player)
// ─────────────────────────────────────────────────────────────

class _TajweedCard extends StatefulWidget {
  final TajweedRule rule;
  const _TajweedCard({required this.rule});

  @override
  State<_TajweedCard> createState() => _TajweedCardState();
}

class _TajweedCardState extends State<_TajweedCard> {
  final AudioService _audioService = AudioService();
  bool _isPlaying = false;
  final double _progress = 0.0;
  StreamSubscription? _playerStateSubscription;

  @override
  void initState() {
    super.initState();
    _playerStateSubscription = _audioService.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        _isPlaying = state == PlayerState.playing && 
                    _audioService.currentlyPlayingUrl == widget.rule.audioUrl;
      });
    });

    // Listen for global audio errors
    AudioService.errorNotifier.addListener(_onErrorChanged);
  }

  void _onErrorChanged() {
    final error = AudioService.errorNotifier.value;
    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    AudioService.errorNotifier.removeListener(_onErrorChanged);
    super.dispose();
  }

  void _handlePlay() {
    if (_isPlaying) {
      _audioService.pause();
    } else {
      _audioService.play(widget.rule.audioUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Row ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.rule.name,
                    style: AppTextStyles.englishDisplay(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.rule.arabicName,
                    style: AppTextStyles.arabicVerse(
                      fontSize: 16,
                      color: AppColors.gold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Description ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              widget.rule.description,
              style: AppTextStyles.englishBody(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Example & Highlighted Arabic ──────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppColors.surface,
            child: Column(
              children: [
                Text(
                  widget.rule.exampleArabic,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: AppTextStyles.arabicVerse(
                    fontSize: 28,
                    color: _isPlaying ? AppColors.gold : AppColors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Example from: ${widget.rule.exampleRef}',
                  style: AppTextStyles.englishCaption(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),

          // ── Audio Player Controls ─────────────────────────
          AudioPlayerWidget(
            isPlaying: _isPlaying,
            progress: _progress,
            audioUrl: widget.rule.audioUrl,
            onTap: _handlePlay,
            onProgressChanged: (val) {
              // Manual seek logic would go here
            },
          ),
        ],
      ),
    );
  }
}
