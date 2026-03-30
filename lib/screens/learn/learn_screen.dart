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
    title: 'Purification (Taharah)',
    subtitle: '15 extensive rulings',
    accentColor: Color(0xFF2196F3),
    assetPath: 'assets/icons/book-open-02-stroke-rounded.svg',
    items: [
      MasalaItem(
        title: 'Obligatory acts (Arkan) of Wudu',
        shortRuling: 'Wait! Niyyah, washing face, washing arms to elbows, wiping part of head, washing feet to ankles, and tartib (sequence) are Fard.',
        quranRef: 'Al-Ma\'idah 5:6',
        hadithRef: 'Bukhari 135',
        details: 'According to the Shafi\'i school, Wudu has six integrals (arkan): 1. Intention at the moment of washing the face. 2. Washing the entire face. 3. Washing both arms up to and including the elbows. 4. Wiping a portion of the head. 5. Washing both feet up to the ankles. 6. Sequence (tartib) strictly as mentioned.',
      ),
      MasalaItem(
        title: 'Things that invalidate Wudu (Nawaqid)',
        shortRuling: 'Passing anything from the two passages, deep sleep without a firmly seated posture, loss of intellect, and direct touch of private parts.',
        quranRef: 'An-Nisa 4:43',
        hadithRef: 'Muslim 362, Abu Dawud 201',
        details: 'The nullifiers include: 1. Discharge from front or back passages. 2. Sleep where one\'s buttocks are not firmly seated (Shafi\'i view). 3. Loss of consciousness via fainting or intoxication. 4. Skin-to-skin contact with marriageable opposite gender without a barrier (major Shafi\'i view). 5. Touching human private parts with the palm or inner fingers.',
      ),
      MasalaItem(
        title: 'Ghusl (Major Ablution) Requirements',
        shortRuling: 'Intention and flowing water over the entire body (including roots of hair) are the only strictly obligatory acts.',
        quranRef: 'Al-Ma\'idah 5:6',
        hadithRef: 'Bukhari 248',
        details: 'Ghusl is required after sexual intercourse, ejaculation, ending of menstruation (Haidh) or postpartum bleeding (Nifas). The strict faraidh (obligatory parts) in the Shafi\'i school are merely two: Niyyah (intention) to lift the state of major impurity, and ensuring water reaches every part of the external skin and hair.',
      ),
      MasalaItem(
        title: 'Wiping over Leather Socks (Khuffayn)',
        shortRuling: 'Permitted for 1 day/night for residents, and 3 days/nights for travellers, if worn after a complete wudu.',
        quranRef: 'Mutawatir Sunnah',
        hadithRef: 'Muslim 276',
        details: 'Wiping over footgear (khuff) is a concession. Conditions: 1. Put on immediately after complete Wudu/Ghusl. 2. Must cover the area of the foot that is obligatory to wash (up to ankles). 3. Must be waterproof and durable enough for continuous walking. The period starts from the first nullification of wudu after putting them on.',
      ),
      MasalaItem(
        title: 'Tayammum (Dry Ablution)',
        shortRuling: 'Striking clean earth twice: once to wipe the face, and once to wipe both arms to the elbows. Allowed if water is absent or harmful.',
        quranRef: 'Al-Ma\'idah 5:6',
        hadithRef: 'Bukhari 347',
        details: 'Tayammum replaces Wudu and Ghusl. It requires unmixed, dusty earth. Integrals: Intention to permit prayer, transferring dust, wiping the entire face, wiping hands and arms up to elbows, and sequence. A new tayammum must be made for every obligatory prayer.',
      )
    ],
  ),
  MasalaCategory(
    emoji: '🕌',
    title: 'Prayer (Salah)',
    subtitle: '24 extensive rulings',
    accentColor: AppColors.primary,
    assetPath: 'assets/icons/chat-01-stroke-rounded.svg',
    items: [
      MasalaItem(
        title: 'Conditions for Validity (Shurut)',
        shortRuling: 'Purity of body/clothes/place, covering awrah, facing Qibla, knowing prayer time entered, and knowing its obligations.',
        quranRef: 'Al-Muddaththir 74:4',
        hadithRef: 'Bukhari 395',
        details: 'Without these, the prayer never commences. The awrah for men is exactly from navel to knee. For women, it is the entire body except the face and hands up to the wrists. Any strictly visible uncoverings invalidate the prayer immediately unless covered instantly.',
      ),
      MasalaItem(
        title: 'Integrals of Prayer (Arkan)',
        shortRuling: '13 Integrals: Intention, standing, Takbiratul Ihram, Fatihah, Ruku\', I\'tidal, Sujud, sitting between Sujud, final Tashahhud, Salawat, Salam, and Tartib.',
        quranRef: 'Al-Baqarah 2:238',
        hadithRef: 'Bukhari 757',
        details: 'Missing an integral (rukn) unconditionally invalidates a rak\'ah. Missing a main Sunnah (like the first Tashahhud or Qunut in Fajr) does not invalidate, but requires the Prostration of Forgetfulness (Sujud Sahw).',
      ),
      MasalaItem(
        title: 'Shortening (Qasr) & Combining (Jam\')',
        shortRuling: 'A traveller journeying beyond 81km for a permissible purpose may shorten 4-rak\'ah prayers to 2, and combine Dhuhr/Asr and Maghrib/Isha.',
        quranRef: 'An-Nisa 4:101',
        hadithRef: 'Bukhari 1093',
        details: 'In the Shafi\'i school, shortening is permitted (rukhsah) but full prayer is preferred unless the journey crosses 120km. The intention to shorten MUST be made simultaneously with the opening Takbir. Combining can be early (taqdim) or delayed (ta\'khir).',
      ),
      MasalaItem(
        title: 'Prostration of Forgetfulness (Sujud al-Sahw)',
        shortRuling: 'Two prostrations performed right before the final Salam to compensate for missed main Sunnahs (Ab\'ad) or extra accidental actions.',
        quranRef: 'Sunnah',
        hadithRef: 'Muslim 572',
        details: 'Required if one forgets the first Tashahhud, the Qunut of Fajr, or accidentally adds a standing/sitting. Unlike other schools, the Shafi\'is perform both prostrations BEFORE the final Salam, regardless of whether it was an addition or omission.',
      ),
    ],
  ),
  MasalaCategory(
    emoji: '🌙',
    title: 'Fasting (Sawm)',
    subtitle: '12 extensive rulings',
    accentColor: Color(0xFF9C27B0),
    items: [
      MasalaItem(
        title: 'Nightly Intention (Niyyah)',
        shortRuling: 'For obligatory fasts (Ramadan, Qada, Kaffarah), the intention must be made every single night before Fajr.',
        quranRef: 'Al-Bayyinah 98:5',
        hadithRef: 'Abu Dawud 2454',
        details: 'Unlike the Maliki school, the Shafi\'i school mandates a renewed intention for each individual day of Ramadan. "Whoever does not resolve to fast before Fajr, there is no fast for him." For voluntary fasts, intention is valid until Dhuhr if one hasn\'t eaten.',
      ),
      MasalaItem(
        title: 'Nullifiers of the Fast',
        shortRuling: 'Intentional eating/drinking, sexual intercourse, deliberate vomiting, masturbation, and menstruation/nifas.',
        quranRef: 'Al-Baqarah 2:187',
        hadithRef: 'Bukhari 1928',
        details: 'Eating forgetfully does NOT break the fast, regardless of quantity. Deliberate vomiting invalidates it, but unintentional vomiting does not. Injections into muscle or vein do not break the fast as they do not enter an open bodily cavity through normal channels.',
      ),
      MasalaItem(
        title: 'Fidyah (Expiation for incapacity)',
        shortRuling: 'Those permanently incapable of fasting (due to terminal illness, extreme old age) must feed one poor person per missed day.',
        quranRef: 'Al-Baqarah 2:184',
        hadithRef: 'Bukhari 4505',
        details: '1 Mudd (approx. 600-750 grams) of the staple food of the region (e.g., wheat, rice). Pregnant/nursing women who fear ONLY for their child must make up the days AND pay the Fidyah (according to Shafi\'i/Hanbali). If they fear for themselves, they only make it up.',
      ),
    ],
  ),
  MasalaCategory(
    emoji: '🤲',
    title: 'Zakat & Wealth',
    subtitle: '10 extensive rulings',
    accentColor: AppColors.gold,
    items: [
      MasalaItem(
        title: 'Conditions for Zakat Obligation',
        shortRuling: 'Islam, freedom, absolute ownership, reaching the Nisab (threshold), and the passing of one lunar year (Hawl).',
        quranRef: 'At-Tawbah 9:103',
        hadithRef: 'Ibn Majah 1792',
        details: 'Zakat is due on Gold/Silver, cash, trade merchandise, livestock, and certain agricultural produce. Personal use items (house, car, clothes) hold no Zakat, regardless of value.',
      ),
      MasalaItem(
        title: 'Nisab of Gold, Silver, and Cash',
        shortRuling: 'Gold nisab is 85 grams; Silver is 595 grams. Fiat currency taking the ruling of the lowest threshold (usually silver). Rate is 2.5%.',
        quranRef: 'Sunnah',
        hadithRef: 'Abu Dawud 1573',
        details: 'If cash/savings dip below the nisab during the year, the lunar year count resets (Shafi\'i view). Debt does NOT deduct from Zakat in the Shafi\'i school; you pay on what you currently physically hold.',
      ),
      MasalaItem(
        title: 'Eligible Recipients',
        shortRuling: 'Only 8 categories: The poor, the needy, Zakat administrators, hearts to be reconciled, slaves, debtors, in the path of Allah, and travellers.',
        quranRef: 'At-Tawbah 9:60',
        hadithRef: '—',
        details: 'Zakat cannot be given to parents, grandparents, children, or a spouse. It must be transferred into the full ownership of the eligible recipient (Tamlīk), thus cannot be used directly for building mosques or hospitals.',
      ),
    ],
  ),
  MasalaCategory(
    emoji: '👶',
    title: 'Family & Marriage',
    subtitle: '15 extensive rulings',
    accentColor: Color(0xFFE91E63),
    items: [
      MasalaItem(
        title: 'Conditions of the Marriage Contract',
        shortRuling: 'Consent of bride, the Wali (guardian), two male Muslim witnesses, and the Offer (Ijab) & Acceptance (Qabul).',
        quranRef: 'An-Nisa 4:3',
        hadithRef: 'Tirmidhi 1101',
        details: 'The Prophet ﷺ said: "There is no marriage without a wali." The guardian is strictly male (father, grandfather, brother, etc). The Mahr (dowry) is obligatory, but not a strict condition for the initial contract to be valid—if unspecified, she receives standard cultural amount (Mahr al-Mithl).',
      ),
      MasalaItem(
        title: 'Khulu\' (Wife-Initiated Separation)',
        shortRuling: 'If a wife detests the marriage (with no direct fault of the husband), she may return the dowry in exchange for an annulment/divorce.',
        quranRef: 'Al-Baqarah 2:229',
        hadithRef: 'Bukhari 5273',
        details: 'The husband must accept the compensation for it to take effect. If accepted, it counts as an irrevocable minor divorce. Her waiting period (Iddah) is generally one menstrual cycle (or three according to other views).',
      )
    ],
  )
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Masa\'la Library')),
      body: Column(
        children: [
          // ── Search bar ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'Search categories…',
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                  size: 20,
                ),
                filled: true,
                fillColor: theme.cardTheme.color,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: colorScheme.outlineVariant,
                    width: 0.8,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 1.5,
                  ),
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


