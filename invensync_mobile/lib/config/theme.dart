import 'package:flutter/material.dart';

class AppTheme {
  // ============================================
  // BRAND COLORS
  // ============================================
  static const Color primaryColor = Color(0xFFEA580C);
  static const Color primaryLight = Color(0xFFFB923C);
  static const Color primaryDark = Color(0xFFC2410C);
  static const Color primaryContainer = Color(0xFFFFF7ED);
  static const Color primarySoft = Color(0xFFFFEDD5);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // ============================================
  // SEMANTIC COLORS
  // ============================================
  static const Color successColor = Color(0xFF059669);
  static const Color successBg = Color(0xFFD1FAE5);
  static const Color successText = Color(0xFF065F46);
  static const Color successSoft = Color(0xFFECFDF5);

  static const Color warningColor = Color(0xFFD97706);
  static const Color warningBg = Color(0xFFFEF3C7);
  static const Color warningText = Color(0xFF92400E);
  static const Color warningSoft = Color(0xFFFFFBEB);

  static const Color errorColor = Color(0xFFDC2626);
  static const Color errorBg = Color(0xFFFEE2E2);
  static const Color errorText = Color(0xFF991B1B);
  static const Color errorSoft = Color(0xFFFEF2F2);

  static const Color infoColor = Color(0xFF2563EB);
  static const Color infoBg = Color(0xFFDBEAFE);
  static const Color infoText = Color(0xFF1E40AF);
  static const Color infoSoft = Color(0xFFEFF6FF);

  // ============================================
  // NEUTRAL COLORS - LIGHT
  // ============================================
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardElevatedLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderSubtleLight = Color(0xFFF1F5F9);
  static const Color mutedText = Color(0xFF64748B);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color dividerLight = Color(0xFFF1F5F9);
  static const Color overlayLight = Color(0x0A0F172A);

  // ============================================
  // NEUTRAL COLORS - DARK
  // ============================================
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color cardElevatedDark = Color(0xFF1E293B);
  static const Color borderDark = Color(0xFF334155);
  static const Color borderSubtleDark = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFFCBD5E1);
  static const Color textTertiaryDark = Color(0xFF64748B);
  static const Color dividerDark = Color(0xFF1E293B);

  // ============================================
  // GRADIENTS
  // ============================================
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFEA580C), Color(0xFFF97316), Color(0xFFFB923C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryVerticalGradient = LinearGradient(
    colors: [Color(0xFFEA580C), Color(0xFFF97316)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient darkOverlayGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient subtleGradient = LinearGradient(
    colors: [Color(0xFFFFF7ED), Color(0xFFFFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============================================
  // SPACING & SIZING
  // ============================================
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;

  static const double contentPaddingMobile = 16.0;
  static const double contentPaddingTablet = 24.0;
  static const double sectionSpacing = 24.0;
  static const double cardRadius = 14.0;
  static const double cardRadiusSm = 10.0;
  static const double cardRadiusLg = 20.0;
  static const double inputRadius = 10.0;
  static const double badgeRadius = 20.0;
  static const double buttonRadius = 10.0;
  static const double iconSizeSm = 16.0;
  static const double iconSizeMd = 20.0;
  static const double iconSizeLg = 24.0;
  static const double iconSizeXl = 32.0;

  // ============================================
  // SHADOWS
  // ============================================
  static List<BoxShadow> shadowSm = [
    BoxShadow(color: Color(0x0A0F172A), blurRadius: 4, offset: Offset(0, 1)),
  ];

  static List<BoxShadow> shadowMd = [
    BoxShadow(color: Color(0x0A0F172A), blurRadius: 8, offset: Offset(0, 2)),
    BoxShadow(color: Color(0x050F172A), blurRadius: 2, offset: Offset(0, 1)),
  ];

  static List<BoxShadow> shadowLg = [
    BoxShadow(color: Color(0x0F0F172A), blurRadius: 16, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x050F172A), blurRadius: 4, offset: Offset(0, 2)),
  ];

  static List<BoxShadow> shadowXl = [
    BoxShadow(color: Color(0x140F172A), blurRadius: 24, offset: Offset(0, 8)),
    BoxShadow(color: Color(0x0A0F172A), blurRadius: 8, offset: Offset(0, 4)),
  ];

  static List<BoxShadow> shadowPrimary = [
    BoxShadow(color: Color(0x25EA580C), blurRadius: 12, offset: Offset(0, 4)),
  ];

  static List<BoxShadow> shadowCard = [
    BoxShadow(color: Color(0x080F172A), blurRadius: 6, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x030F172A), blurRadius: 2, offset: Offset(0, 0.5)),
  ];

  // ============================================
  // TYPOGRAPHY SCALE
  // ============================================
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.8, height: 1.2,
  );
  static const TextStyle displayMedium = TextStyle(
    fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.7, height: 1.2,
  );
  static const TextStyle heading1 = TextStyle(
    fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.5, height: 1.25,
  );
  static const TextStyle heading2 = TextStyle(
    fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.3, height: 1.3,
  );
  static const TextStyle heading3 = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.2, height: 1.4,
  );
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w500, letterSpacing: -0.1, height: 1.5,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0, height: 1.5,
  );
  static const TextStyle bodySmall = TextStyle(
    fontSize: 13, fontWeight: FontWeight.w400, letterSpacing: 0.1, height: 1.45,
  );
  static const TextStyle caption = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.2, height: 1.4,
  );
  static const TextStyle overline = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5, height: 1.35,
  );

  // ============================================
  // HELPERS
  // ============================================
  static EdgeInsets contentPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return EdgeInsets.symmetric(
      horizontal: width >= 600 ? contentPaddingTablet : contentPaddingMobile,
    );
  }

  static EdgeInsets pagePadding(BuildContext context) {
    return EdgeInsets.fromLTRB(
      MediaQuery.of(context).size.width >= 600 ? 24 : 16,
      16,
      MediaQuery.of(context).size.width >= 600 ? 24 : 16,
      16,
    );
  }

  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color textColor(BuildContext context) {
    return isDark(context) ? textPrimaryDark : textPrimary;
  }

  static Color mutedColor(BuildContext context) {
    return isDark(context) ? textTertiaryDark : mutedText;
  }

  static Color secondaryTextColor(BuildContext context) {
    return isDark(context) ? textSecondaryDark : textSecondary;
  }

  static Color cardColor(BuildContext context) {
    return isDark(context) ? cardDark : cardLight;
  }

  static Color borderColor(BuildContext context) {
    return isDark(context) ? borderDark : borderLight;
  }

  static Color scaffoldBg(BuildContext context) {
    return isDark(context) ? backgroundDark : backgroundLight;
  }

  // ============================================
  // LIGHT THEME
  // ============================================
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: primaryColor,
    brightness: Brightness.light,
    scaffoldBackgroundColor: backgroundLight,
    fontFamily: 'Inter',
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      backgroundColor: cardLight,
      foregroundColor: textPrimary,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      iconTheme: IconThemeData(color: textSecondary),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: cardLight,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
        side: const BorderSide(color: borderLight),
      ),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputRadius),
        borderSide: const BorderSide(color: borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputRadius),
        borderSide: const BorderSide(color: borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputRadius),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputRadius),
        borderSide: const BorderSide(color: errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputRadius),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      hintStyle: const TextStyle(color: textTertiary, fontSize: 14, fontWeight: FontWeight.w400),
      labelStyle: const TextStyle(color: textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      isDense: false,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: onPrimary,
        disabledBackgroundColor: primaryColor.withValues(alpha: 0.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
        ),
        elevation: 0,
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
        ),
        side: const BorderSide(color: borderLight),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: onPrimary,
      elevation: 4,
      highlightElevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: primaryColor,
      unselectedItemColor: textTertiary,
      showUnselectedLabels: true,
      backgroundColor: cardLight,
      selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      elevation: 0,
    ),
    dividerTheme: const DividerThemeData(
      color: dividerLight,
      thickness: 1,
      space: 0,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    chipTheme: const ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(badgeRadius)),
      ),
    ),
    iconTheme: const IconThemeData(size: iconSizeMd),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
      },
    ),
  );

  // ============================================
  // DARK THEME
  // ============================================
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: primaryColor,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundDark,
    fontFamily: 'Inter',
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      backgroundColor: surfaceDark,
      foregroundColor: textPrimaryDark,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: textPrimaryDark,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      iconTheme: IconThemeData(color: textSecondaryDark),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: surfaceDark,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputRadius),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputRadius),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputRadius),
        borderSide: const BorderSide(color: primaryLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputRadius),
        borderSide: const BorderSide(color: errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputRadius),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      hintStyle: TextStyle(color: textTertiaryDark.withValues(alpha: 0.8), fontSize: 14),
      labelStyle: TextStyle(color: textSecondaryDark, fontSize: 13, fontWeight: FontWeight.w500),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      isDense: false,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
        ),
        elevation: 0,
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textSecondaryDark,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
        ),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryLight,
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: onPrimary,
      elevation: 4,
      highlightElevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: primaryLight,
      unselectedItemColor: textTertiaryDark,
      showUnselectedLabels: true,
      backgroundColor: surfaceDark,
      selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      elevation: 0,
    ),
    dividerTheme: DividerThemeData(
      color: Colors.white.withValues(alpha: 0.06),
      thickness: 1,
      space: 0,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(badgeRadius)),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
      ),
    ),
    iconTheme: const IconThemeData(size: iconSizeMd),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}