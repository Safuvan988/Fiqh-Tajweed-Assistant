import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ─────────────────────────────────────────────
///  QuranFiqh App Colour Palette
/// ─────────────────────────────────────────────
class AppColors {
  AppColors._();

  // Primary (Premium Charcoal)
  static const Color primary = Color(0xFF111111); // Deep Charcoal
  static const Color primaryLight = Color(0xFF222222);
  static const Color primaryDark = Color(0xFF000000);

  // Accent (Premium Gold)
  static const Color gold = Color(0xFFCB9B2E); // Gold accent
  static const Color goldAccent = Color(0xFFE6C76E); // Soft Gold

  // Background / Surface
  static const Color background = Color(0xFFF8F3EC); // Off-white / soft beige
  static const Color surface = Color(0xFFFDF8F2); // Slightly lighter surface
  static const Color cardBackground = Color(0xFFFAF5EE);

  // Text
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF4A4A4A);
  static const Color textLight = Color(0xFF8A8A8A);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnAccent = Color(0xFF0F3D2E);

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF0F0F0F); // Deep Charcoal
  static const Color darkSurface = Color(0xFF1A1A1A); // Slightly lighter
  static const Color darkCard = Color(0xFF222222);
  static const Color darkTextPrimary = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkDivider = Color(0xFF333333);
  static const Color darkBorder = Color(0xFF444444);

  // Chat UI
  static const Color userMsgBg = Color(0xFFD4AF37);
  static const Color userMsgText = Color(0xFF0B0F14);
  static const Color botMsgBg = Color(0xFFFDF8F2); // Premium light surface
  static const Color botMsgText = Color(0xFF1A1A1A); // textPrimary

  // Scripture
  static const Color scriptureGold = Color(0xFFE6C76E);

  // Divider / Border
  static const Color divider = Color(0xFFE0D8CF);
  static const Color border = Color(0xFFD4C9BB);
}

/// ─────────────────────────────────────────────
///  Font Families
/// ─────────────────────────────────────────────
class AppFonts {
  AppFonts._();

  // English: Clean sans-serif (Inter)
  static const String english = 'Inter';

  // Arabic: Traditional Arabic font (Amiri)
  static const String arabic = 'Amiri';

  // Malayalam: Rounded readable (Noto Sans Malayalam)
  static const String malayalam = 'NotoSansMalayalam';
}

/// ─────────────────────────────────────────────
///  Text Styles per Language
/// ─────────────────────────────────────────────
class AppTextStyles {
  AppTextStyles._();

  // ── English ──────────────────────────────────
  static TextStyle englishDisplay({
    double fontSize = 28,
    FontWeight fontWeight = FontWeight.bold,
    Color color = AppColors.textPrimary,
  }) => GoogleFonts.inter(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: -0.5,
  );

  static TextStyle englishBody({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.normal,
    Color color = AppColors.textSecondary,
  }) => GoogleFonts.inter(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    height: 1.5,
  );

  static TextStyle englishCaption({
    double fontSize = 13,
    Color color = AppColors.textLight,
  }) => GoogleFonts.inter(fontSize: fontSize, color: color, letterSpacing: 0.2);

  // ── Arabic ────────────────────────────────────
  static TextStyle arabicDisplay({
    double fontSize = 30,
    FontWeight fontWeight = FontWeight.bold,
    Color color = AppColors.textPrimary,
  }) => GoogleFonts.amiri(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    height: 1.8,
  );

  static TextStyle arabicBody({
    double fontSize = 18,
    FontWeight fontWeight = FontWeight.normal,
    Color color = AppColors.textSecondary,
  }) => GoogleFonts.amiri(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    height: 2.0,
  );

  static TextStyle arabicVerse({
    double fontSize = 24,
    Color color = AppColors.primary,
  }) => GoogleFonts.amiri(
    fontSize: fontSize,
    fontWeight: FontWeight.w600,
    color: color,
    height: 2.2,
  );

  // ── Malayalam ─────────────────────────────────
  static TextStyle malayalamDisplay({
    double fontSize = 26,
    FontWeight fontWeight = FontWeight.bold,
    Color color = AppColors.textPrimary,
  }) => GoogleFonts.notoSansMalayalam(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    height: 1.6,
  );

  static TextStyle malayalamBody({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.normal,
    Color color = AppColors.textSecondary,
  }) => GoogleFonts.notoSansMalayalam(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    height: 1.7,
  );
}

/// ─────────────────────────────────────────────
///  App Theme
/// ─────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // ── Colour Scheme ─────────────────────────
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.textOnPrimary,
        primaryContainer: AppColors.primaryLight,
        onPrimaryContainer: AppColors.textOnPrimary,
        secondary: AppColors.gold,
        onSecondary: AppColors.textOnAccent,
        secondaryContainer: Color(0xFFF5E5C0),
        onSecondaryContainer: AppColors.primary,
        tertiary: AppColors.goldAccent,
        onTertiary: AppColors.textOnPrimary,
        tertiaryContainer: Color(0xFFD4F0E2),
        onTertiaryContainer: AppColors.primaryDark,
        error: Color(0xFFB00020),
        onError: Colors.white,
        errorContainer: Color(0xFFFCDAD7),
        onErrorContainer: Color(0xFF410002),
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.cardBackground,
        onSurfaceVariant: AppColors.textSecondary,
        outline: AppColors.border,
        outlineVariant: AppColors.divider,
        shadow: Colors.black26,
        scrim: Colors.black54,
        inverseSurface: AppColors.primary,
        onInverseSurface: AppColors.textOnPrimary,
        inversePrimary: AppColors.goldAccent,
      ),

      // ── Scaffold / Background ──────────────────
      scaffoldBackgroundColor: AppColors.background,

      // ── AppBar ────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textOnPrimary,
          letterSpacing: 0.3,
        ),
        iconTheme: const IconThemeData(color: AppColors.textOnPrimary),
      ),

      // ── Card ──────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 1,
        shadowColor: AppColors.primary.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.divider, width: 0.8),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // ── Elevated Button ───────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 2,
          shadowColor: AppColors.primary.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),

      // ── Text Button ───────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Outlined Button ───────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Input / Text Field ────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: GoogleFonts.inter(color: AppColors.textLight, fontSize: 15),
        labelStyle: GoogleFonts.inter(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),

      // ── Bottom Navigation ─────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textLight,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),

      // ── Divider ───────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 0.8,
        space: 1,
      ),

      // ── Icon ──────────────────────────────────
      iconTheme: const IconThemeData(color: AppColors.primary, size: 24),

      // ── Chip ──────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary,
        labelStyle: GoogleFonts.inter(fontSize: 13),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      // ── FloatingActionButton ──────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.primary,
        elevation: 4,
      ),

      // ── Base TextTheme (English / Inter) ──────
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: AppColors.textSecondary,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: 0.3,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          color: AppColors.textLight,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.goldAccent, // Gold is primary in dark mode for pop
        onPrimary: AppColors.primary,
        secondary: AppColors.gold,
        onSecondary: AppColors.primary,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        surfaceContainerHighest: AppColors.darkCard,
        outline: AppColors.darkBorder,
        outlineVariant: AppColors.darkDivider,
        background: AppColors.darkBackground,
        onBackground: AppColors.darkTextPrimary,
        error: Color(0xFFCF6679),
        onError: Colors.black,
      ),

      scaffoldBackgroundColor: AppColors.darkBackground,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.goldAccent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.goldAccent,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkBorder, width: 0.8),
        ),
      ),

      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(color: AppColors.darkTextPrimary),
        displayMedium: GoogleFonts.inter(color: AppColors.darkTextPrimary),
        headlineLarge: GoogleFonts.inter(color: AppColors.darkTextPrimary),
        bodyLarge: GoogleFonts.inter(color: AppColors.darkTextSecondary),
        bodyMedium: GoogleFonts.inter(color: AppColors.darkTextSecondary),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkBackground,
        selectedItemColor: AppColors.goldAccent,
        unselectedItemColor: AppColors.darkTextSecondary,
      ),

      dividerTheme: const DividerThemeData(color: AppColors.darkDivider),
      iconTheme: const IconThemeData(color: AppColors.goldAccent),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.goldAccent,
        foregroundColor: AppColors.primary,
      ),
    );
  }
}
