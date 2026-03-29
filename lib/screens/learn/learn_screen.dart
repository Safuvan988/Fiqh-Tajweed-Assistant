import 'package:flutter/material.dart';
import 'package:quranfiqh/core/theme/app_theme.dart';
import 'package:quranfiqh/screens/learn/masala_detail_screen.dart';
import 'package:quranfiqh/widgets/masaala_tile.dart';

// ─────────────────────────────────────────────────────────────
//  Data Models
// ─────────────────────────────────────────────────────────────

class MasalaCategory {
  final String emoji;
  final String title;
  final String subtitle;
  final Color accentColor;
  final String? assetPath;
  final List<MasalaItem> items;

  const MasalaCategory({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    this.assetPath,
    required this.items,
  });
}

class MasalaItem {
  final String title;
  final String shortRuling;
  final String quranRef;
  final String hadithRef;
  final String details;

  const MasalaItem({
    required this.title,
    required this.shortRuling,
    required this.quranRef,
    required this.hadithRef,
    required this.details,
  });
}

// ─────────────────────────────────────────────────────────────
//  Sample Data
// ─────────────────────────────────────────────────────────────

const List<MasalaCategory> _categories = [
  MasalaCategory(
    emoji: '💧',
    assetPath: 'assets/icons/book-open-02-stroke-rounded.svg',
    title: 'Wudu',
    subtitle: '12 rulings',
    accentColor: Color(0xFF2196F3),
    items: [
      MasalaItem(
        title: 'Obligatory acts of Wudu',
        shortRuling:
            'Washing the face, arms up to elbows, wiping the head, and washing feet up to ankles are fard.',
        quranRef: 'Al-Ma\'idah 5:6',
        hadithRef: 'Bukhari 135',
        details:
            'The four faraidh of wudu are derived from Surah Al-Ma\'idah verse 6. Missing any one of them invalidates the wudu. The sunnah acts include niyyah, basmalah, washing hands, miswak, and rinsing the mouth and nose.',
      ),
      MasalaItem(
        title: 'Things that break Wudu',
        shortRuling:
            'Passing wind, using the toilet, deep sleep, loss of consciousness, or touching private parts directly break wudu.',
        quranRef: 'Al-Ma\'idah 5:6',
        hadithRef: 'Muslim 362',
        details:
            'The nawaqid (nullifiers) of wudu are agreed upon by the four schools with minor differences. Passing wind breaks wudu by consensus. Touching the private part breaks wudu according to Shafi\'i and Hanbali but not Hanafi.',
      ),
      MasalaItem(
        title: 'Wiping over khuffayn (leather socks)',
        shortRuling:
            'A traveller may wipe over leather socks for 3 days; a resident for 1 day, instead of washing feet in wudu.',
        quranRef: 'N/A',
        hadithRef: 'Muslim 276',
        details:
            'Wiping over khuffayn is a concession (rukhsah) that is mutawatir in hadith. The condition is that the socks must have been worn in a state of taharah (after full wudu).',
      ),
    ],
  ),
  MasalaCategory(
    emoji: '🕌',
    assetPath: 'assets/icons/chat-01-stroke-rounded.svg',
    title: 'Salah',
    subtitle: '18 rulings',
    accentColor: AppColors.primary,
    items: [
      MasalaItem(
        title: 'Combining prayers (Jam\')',
        shortRuling:
            'Travellers may combine Dhuhr+Asr and Maghrib+Isha. Hanafi restricts this to Arafah and Muzdalifah.',
        quranRef: 'An-Nisa 4:101',
        hadithRef: 'Muslim 705',
        details:
            'The Maliki, Shafi\'i, and Hanbali schools permit combination during travel without restriction. The distance threshold is approximately 80 km (48 miles). Combination can be taqdim (advance) or ta\'khir (delay).',
      ),
      MasalaItem(
        title: 'Shortening prayers (Qasr)',
        shortRuling:
            'A traveller may shorten 4-rakat prayers to 2 rakats for the duration of travel.',
        quranRef: 'An-Nisa 4:101',
        hadithRef: 'Bukhari 1102',
        details:
            'Qasr is Sunnah mu\'akkadah according to most scholars during travel. The Hanafi school considers it wajib. The traveller performs 2 rakats for Dhuhr, Asr, and Isha — Fajr and Maghrib remain unchanged.',
      ),
      MasalaItem(
        title: 'Missed prayers (Qada)',
        shortRuling:
            'Prayers missed intentionally or unintentionally must be made up (qada) as soon as possible.',
        quranRef: 'Ta-Ha 20:14',
        hadithRef: 'Bukhari 597',
        details:
            'The Prophet ﷺ said: "Whoever forgets a prayer should perform it when he remembers it." Intentionally missing prayers carries a greater sin, and one must repent and make up all missed prayers.',
      ),
    ],
  ),
  MasalaCategory(
    emoji: '🌙',
    title: 'Fasting',
    subtitle: '10 rulings',
    accentColor: Color(0xFF9C27B0),
    items: [
      MasalaItem(
        title: 'Conditions for validity of fast',
        shortRuling:
            'Niyyah (intention) before Fajr, Islam, sanity, and being free from haidh/nifas are required for a valid fast.',
        quranRef: 'Al-Baqarah 2:183',
        hadithRef: 'Bukhari 1904',
        details:
            'The intention must be made each night before Fajr for Ramadan fasts according to Maliki, Shafi\'i, and Hanbali schools. Hanafis accept a single intention for all of Ramadan if made at the beginning.',
      ),
      MasalaItem(
        title: 'Things that break the fast (Muftirat)',
        shortRuling:
            'Eating, drinking, sexual intercourse, and deliberate vomiting break the fast.',
        quranRef: 'Al-Baqarah 2:187',
        hadithRef: 'Bukhari 1933',
        details:
            'If done forgetfully, the fast is not broken (Hadith in Bukhari). Blood tests and injections are a contemporary issue — most scholars say non-nutritive injections do not break the fast.',
      ),
      MasalaItem(
        title: 'Who is exempt from fasting?',
        shortRuling:
            'Travellers, the ill, pregnant/nursing women, and the elderly may skip fasts and make them up or pay fidyah.',
        quranRef: 'Al-Baqarah 2:184-185',
        hadithRef: 'Abu Dawud 2408',
        details:
            'Travellers and the ill must make up missed fasts later. Those with chronic illness who cannot fast permanently pay fidyah (feeding one poor person per missed day). Pregnant women follow the ruling of the ill.',
      ),
    ],
  ),
  MasalaCategory(
    emoji: '🤲',
    title: 'Zakah',
    subtitle: '8 rulings',
    accentColor: AppColors.gold,
    items: [
      MasalaItem(
        title: 'Nisab threshold for Zakah',
        shortRuling:
            'Zakah is due on gold (85g+), silver (595g+), cash equivalents, and trade goods when held for one lunar year.',
        quranRef: 'At-Tawbah 9:103',
        hadithRef: 'Abu Dawud 1558',
        details:
            'The nisab for gold is 85 grams and for silver is 595 grams. Most scholars today use the gold nisab as the reference. Zakah rate is 2.5% of the total eligible wealth.',
      ),
    ],
  ),
  MasalaCategory(
    emoji: '✈️',
    title: 'Travel Fiqh',
    subtitle: '6 rulings',
    accentColor: AppColors.goldAccent,
    items: [
      MasalaItem(
        title: 'When does travel rukhsah apply?',
        shortRuling:
            'Concessions apply when travelling a minimum of ~80km (48 miles) for a legitimate purpose.',
        quranRef: 'An-Nisa 4:101',
        hadithRef: 'Bukhari 1102',
        details:
            'The majority position is 80 km based on the Maliki view. Once one intends permanent residence (4 days for Shafi\'i/Hanbali, 15 days for Hanafi), concessions no longer apply.',
      ),
    ],
  ),
  MasalaCategory(
    emoji: '👶',
    title: 'Family Fiqh',
    subtitle: '9 rulings',
    accentColor: Color(0xFFE91E63),
    items: [
      MasalaItem(
        title: 'Conditions for valid Nikah',
        shortRuling:
            'Valid nikah requires offer & acceptance, two male witnesses, mahr, and a wali (guardian) for the bride.',
        quranRef: 'An-Nisa 4:4',
        hadithRef: 'Tirmidhi 1101',
        details:
            'All four schools agree on these conditions. The Hanafi school has a minority position allowing a woman to contract her own nikah without a wali, but the majority require it. Mahr is obligatory and becomes the wife\'s right.',
      ),
    ],
  ),
];

// ─────────────────────────────────────────────────────────────
//  Learn Screen
// ─────────────────────────────────────────────────────────────

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  String _search = '';

  List<MasalaCategory> get _filtered => _categories
      .where((c) => c.title.toLowerCase().contains(_search.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Masa\'la Library')),
      body: Column(
        children: [
          // ── Search bar ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              style: AppTextStyles.englishBody(
                  fontSize: 14, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search categories…',
                hintStyle: AppTextStyles.englishBody(
                    fontSize: 14, color: AppColors.textLight),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColors.textLight, size: 20),
                filled: true,
                fillColor: AppColors.cardBackground,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: AppColors.border, width: 0.8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),

          // ── Category list ───────────────────────────────────
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
              itemCount: _filtered.length,
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final category = _filtered[i];
                return MasaalaTile(
                  title: category.title,
                  subtitle: category.subtitle,
                  emoji: category.emoji,
                  assetPath: category.assetPath,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MasalaDetailScreen(category: category),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// (Removed _CategoryCard as we are now using MasaalaTile)


