import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemePalette {
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color accent;
  final Color accentWarm;
  final Color success;
  final Color accentViolet;

  const ThemePalette({
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.accent,
    required this.accentWarm,
    required this.success,
    required this.accentViolet,
  });
}

class GritTheme {
  // --- Tech-Kawaii / Wii-U Color Palette ---
  static const Color background = Color(0xFFF0EEFF);      // Soft lavender-white
  static const Color surface = Color(0xFFFFFFFF);          // Pure white cards
  static const Color surfaceLight = Color(0xFFEDE9FE);     // Pale lavender
  static const Color surfaceMid = Color(0xFFD8D4F0);       // Medium lavender for borders

  static const Color primary = Color(0xFFFF6B9D);          // Neon pink / hot coral
  static const Color primaryLight = Color(0xFFFFB3CC);     // Pastel pink
  static const Color primaryDark = Color(0xFFE0457A);      // Deeper pink

  static const Color accent = Color(0xFF4ECAFF);           // Electric blue (Wii-U)
  static const Color accentWarm = Color(0xFFFFD166);       // Warm yellow highlight
  static const Color success = Color(0xFF4ECDC4);          // Mint green

  static const Color textPrimary = Color(0xFF2D2640);      // Deep purple-dark
  static const Color textSecondary = Color(0xFF8B7FA8);    // Muted lavender-grey
  static const Color divider = Color(0xFFE4DFFF);          // Pale lavender divider

  // --- Semantic aliases ---
  static const Color danger = Color(0xFFEF4444);
  static const Color onPrimary = Colors.white;
  static const Color accentViolet = Color(0xFF7B61FF);
  static const Color primaryOrange = Color(0xFFFF8E53);

  static const List<Color> chartPalette = [
    Color(0xFFEF4444),
    Color(0xFF42A5F5),
    Color(0xFF66BB6A),
    Color(0xFFFDD835),
    Color(0xFFFFA726),
    Color(0xFFAB47BC),
    Color(0xFF26A69A),
    Color(0xFFEC407A),
    Color(0xFF5C6BC0),
    Color(0xFF26C6DA),
  ];

  // --- Milestone Bar Zone Colors ---
  static const Color milestoneZone1 = Color(0xFFEF4444); // Starter - red
  static const Color milestoneZone2 = Color(0xFFFFD166); // Novice - warm yellow
  static const Color milestoneZone3 = Color(0xFF4ECAFF); // Intermediate - electric blue
  static const Color milestoneZone4 = Color(0xFF4ECDC4); // Advanced - mint green
  static const Color milestoneZone5 = Color(0xFF7B61FF); // Elite - violet

  // --- Dark Mode Color Palette ---
  static const Color darkBackground = Color(0xFF0F0A1A);
  static const Color darkSurface = Color(0xFF1A1228);
  static const Color darkSurfaceLight = Color(0xFF251D38);
  static const Color darkSurfaceMid = Color(0xFF332A4D);
  static const Color darkTextPrimary = Color(0xFFF0ECFF);
  static const Color darkTextSecondary = Color(0xFF9B8FBF);
  static const Color darkDivider = Color(0xFF2D2444);

  static ThemeData get lightTheme {
    final baseTheme = ThemeData.light(useMaterial3: true);
    return baseTheme.copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.light(
        surface: surface,
        primary: primary,
        secondary: accent,
        onPrimary: onPrimary,
        onSurface: textPrimary,
        onSecondary: onPrimary,
      ),
      dividerColor: divider,
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shadowColor: primary.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: divider, width: 1.5),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.rubik(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      textTheme: GoogleFonts.rubikTextTheme(baseTheme.textTheme).copyWith(
        bodyLarge: GoogleFonts.rubik(color: textPrimary, fontSize: 16),
        bodyMedium: GoogleFonts.rubik(color: textSecondary, fontSize: 14),
        titleLarge: GoogleFonts.rubik(color: textPrimary, fontSize: 22, fontWeight: FontWeight.w800),
        titleMedium: GoogleFonts.rubik(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
        labelLarge: GoogleFonts.rubik(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceLight,
        selectedColor: primary.withValues(alpha: 0.15),
        checkmarkColor: primary,
        labelStyle: GoogleFonts.rubik(
          color: textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        side: const BorderSide(color: divider, width: 1.5),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: divider, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: divider, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        hintStyle: GoogleFonts.rubik(color: textSecondary),
        labelStyle: GoogleFonts.rubik(color: textSecondary, fontWeight: FontWeight.w600),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          shadowColor: primary.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.rubik(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.rubik(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: GoogleFonts.rubik(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: GoogleFonts.rubik(fontSize: 11, fontWeight: FontWeight.w700),
        unselectedLabelStyle: GoogleFonts.rubik(fontSize: 11, fontWeight: FontWeight.w600),
        elevation: 0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titleTextStyle: GoogleFonts.rubik(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
        contentTextStyle: GoogleFonts.rubik(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimary,
        contentTextStyle: GoogleFonts.rubik(color: onPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: surfaceLight,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(onPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        side: const BorderSide(color: divider, width: 2),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return onPrimary;
          return textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return divider;
        }),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        shadowColor: primary.withValues(alpha: 0.1),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseTheme = ThemeData.dark(useMaterial3: true);
    return baseTheme.copyWith(
      scaffoldBackgroundColor: darkBackground,
      colorScheme: ColorScheme.dark(
        surface: darkSurface,
        primary: primary,
        secondary: accent,
        onPrimary: onPrimary,
        onSurface: darkTextPrimary,
        onSecondary: onPrimary,
      ),
      dividerColor: darkDivider,
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shadowColor: primary.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: darkDivider, width: 1.5),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.rubik(
          color: darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
        iconTheme: const IconThemeData(color: darkTextPrimary),
      ),
      textTheme: GoogleFonts.rubikTextTheme(baseTheme.textTheme).copyWith(
        bodyLarge: GoogleFonts.rubik(color: darkTextPrimary, fontSize: 16),
        bodyMedium: GoogleFonts.rubik(color: darkTextSecondary, fontSize: 14),
        titleLarge: GoogleFonts.rubik(color: darkTextPrimary, fontSize: 22, fontWeight: FontWeight.w800),
        titleMedium: GoogleFonts.rubik(color: darkTextPrimary, fontSize: 18, fontWeight: FontWeight.w700),
        labelLarge: GoogleFonts.rubik(color: darkTextPrimary, fontSize: 14, fontWeight: FontWeight.w700),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: darkSurfaceLight,
        selectedColor: primary.withValues(alpha: 0.2),
        checkmarkColor: primary,
        labelStyle: GoogleFonts.rubik(
          color: darkTextPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        side: const BorderSide(color: darkDivider, width: 1.5),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkDivider, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkDivider, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        hintStyle: GoogleFonts.rubik(color: darkTextSecondary),
        labelStyle: GoogleFonts.rubik(color: darkTextSecondary, fontWeight: FontWeight.w600),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: primary.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.rubik(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.rubik(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryLight,
          textStyle: GoogleFonts.rubik(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: primary,
        unselectedItemColor: darkTextSecondary,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: GoogleFonts.rubik(fontSize: 11, fontWeight: FontWeight.w700),
        unselectedLabelStyle: GoogleFonts.rubik(fontSize: 11, fontWeight: FontWeight.w600),
        elevation: 0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titleTextStyle: GoogleFonts.rubik(
          color: darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
        contentTextStyle: GoogleFonts.rubik(
          color: darkTextSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkSurfaceMid,
        contentTextStyle: GoogleFonts.rubik(color: darkTextPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: darkSurfaceLight,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        side: const BorderSide(color: darkDivider, width: 2),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return darkTextSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return darkDivider;
        }),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        shadowColor: primary.withValues(alpha: 0.1),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }

  static ThemeData buildLightTheme(ThemePalette palette) {
    final baseTheme = ThemeData.light(useMaterial3: true);
    return baseTheme.copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.light(
        surface: surface,
        primary: palette.primary,
        secondary: palette.accent,
        onPrimary: onPrimary,
        onSurface: textPrimary,
        onSecondary: onPrimary,
      ),
      dividerColor: divider,
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shadowColor: palette.primary.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: divider, width: 1.5),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.rubik(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      textTheme: GoogleFonts.rubikTextTheme(baseTheme.textTheme).copyWith(
        bodyLarge: GoogleFonts.rubik(color: textPrimary, fontSize: 16),
        bodyMedium: GoogleFonts.rubik(color: textSecondary, fontSize: 14),
        titleLarge: GoogleFonts.rubik(color: textPrimary, fontSize: 22, fontWeight: FontWeight.w800),
        titleMedium: GoogleFonts.rubik(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
        labelLarge: GoogleFonts.rubik(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceLight,
        selectedColor: palette.primary.withValues(alpha: 0.15),
        checkmarkColor: palette.primary,
        labelStyle: GoogleFonts.rubik(
          color: textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        side: const BorderSide(color: divider, width: 1.5),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: divider, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: divider, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.primary, width: 2),
        ),
        hintStyle: GoogleFonts.rubik(color: textSecondary),
        labelStyle: GoogleFonts.rubik(color: textSecondary, fontWeight: FontWeight.w600),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: onPrimary,
          elevation: 0,
          shadowColor: palette.primary.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.rubik(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.primary,
          side: BorderSide(color: palette.primary, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.rubik(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.primary,
          textStyle: GoogleFonts.rubik(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: palette.primary,
        unselectedItemColor: textSecondary,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: GoogleFonts.rubik(fontSize: 11, fontWeight: FontWeight.w700),
        unselectedLabelStyle: GoogleFonts.rubik(fontSize: 11, fontWeight: FontWeight.w600),
        elevation: 0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titleTextStyle: GoogleFonts.rubik(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
        contentTextStyle: GoogleFonts.rubik(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimary,
        contentTextStyle: GoogleFonts.rubik(color: onPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: palette.primary,
        linearTrackColor: surfaceLight,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return palette.primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(onPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        side: const BorderSide(color: divider, width: 2),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return onPrimary;
          return textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return palette.primary;
          return divider;
        }),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        shadowColor: palette.primary.withValues(alpha: 0.1),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }

  static ThemeData buildDarkTheme(ThemePalette palette) {
    final baseTheme = ThemeData.dark(useMaterial3: true);
    return baseTheme.copyWith(
      scaffoldBackgroundColor: darkBackground,
      colorScheme: ColorScheme.dark(
        surface: darkSurface,
        primary: palette.primary,
        secondary: palette.accent,
        onPrimary: onPrimary,
        onSurface: darkTextPrimary,
        onSecondary: onPrimary,
      ),
      dividerColor: darkDivider,
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shadowColor: palette.primary.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: darkDivider, width: 1.5),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.rubik(
          color: darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
        iconTheme: const IconThemeData(color: darkTextPrimary),
      ),
      textTheme: GoogleFonts.rubikTextTheme(baseTheme.textTheme).copyWith(
        bodyLarge: GoogleFonts.rubik(color: darkTextPrimary, fontSize: 16),
        bodyMedium: GoogleFonts.rubik(color: darkTextSecondary, fontSize: 14),
        titleLarge: GoogleFonts.rubik(color: darkTextPrimary, fontSize: 22, fontWeight: FontWeight.w800),
        titleMedium: GoogleFonts.rubik(color: darkTextPrimary, fontSize: 18, fontWeight: FontWeight.w700),
        labelLarge: GoogleFonts.rubik(color: darkTextPrimary, fontSize: 14, fontWeight: FontWeight.w700),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: darkSurfaceLight,
        selectedColor: palette.primary.withValues(alpha: 0.2),
        checkmarkColor: palette.primary,
        labelStyle: GoogleFonts.rubik(
          color: darkTextPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        side: const BorderSide(color: darkDivider, width: 1.5),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkDivider, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkDivider, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.primary, width: 2),
        ),
        hintStyle: GoogleFonts.rubik(color: darkTextSecondary),
        labelStyle: GoogleFonts.rubik(color: darkTextSecondary, fontWeight: FontWeight.w600),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: palette.primary.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.rubik(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.primary,
          side: BorderSide(color: palette.primary, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.rubik(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.primaryLight,
          textStyle: GoogleFonts.rubik(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: palette.primary,
        unselectedItemColor: darkTextSecondary,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: GoogleFonts.rubik(fontSize: 11, fontWeight: FontWeight.w700),
        unselectedLabelStyle: GoogleFonts.rubik(fontSize: 11, fontWeight: FontWeight.w600),
        elevation: 0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titleTextStyle: GoogleFonts.rubik(
          color: darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
        contentTextStyle: GoogleFonts.rubik(
          color: darkTextSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkSurfaceMid,
        contentTextStyle: GoogleFonts.rubik(color: darkTextPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: palette.primary,
        linearTrackColor: darkSurfaceLight,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return palette.primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        side: const BorderSide(color: darkDivider, width: 2),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return darkTextSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return palette.primary;
          return darkDivider;
        }),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        shadowColor: palette.primary.withValues(alpha: 0.1),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }
}
