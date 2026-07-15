import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_decorations.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => _build(Brightness.light);

  static ThemeData get darkTheme => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: AppColors.primaryGreen,
        onPrimary: AppColors.white,
        secondary: AppColors.pink,
        onSecondary: AppColors.white,
        tertiary: AppColors.cyan,
        error: AppColors.error,
        onError: AppColors.white,
        surface: isDark ? AppColors.navyCard : AppColors.offWhite,
        onSurface: isDark ? AppColors.textPrimary : const Color(0xFF0E1428),
      ),
      scaffoldBackgroundColor: isDark ? AppColors.navy : AppColors.offWhite,
      dividerColor: AppColors.divider,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: isDark ? AppColors.navy : AppColors.offWhite,
        foregroundColor: isDark ? AppColors.textPrimary : const Color(0xFF0E1428),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.textPrimary : const Color(0xFF0E1428),
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(
          color: isDark ? AppColors.textPrimary : const Color(0xFF0E1428),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark
            ? AppColors.navyCard.withValues(alpha: 0.85)
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDecorations.radiusXl),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDecorations.radiusLg),
          ),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDecorations.radiusLg),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.pink,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? AppColors.navyLight.withValues(alpha: 0.85)
            : Colors.white,
        hintStyle: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14),
        labelStyle: GoogleFonts.inter(color: AppColors.textSecondary),
        prefixIconColor: AppColors.cyan,
        suffixIconColor: AppColors.textSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDecorations.radiusLg),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDecorations.radiusLg),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDecorations.radiusLg),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDecorations.radiusLg),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.navyCard,
        contentTextStyle: GoogleFonts.inter(color: AppColors.textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDecorations.radiusLg),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.navyCard,
        selectedItemColor: AppColors.pink,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.pink,
        foregroundColor: AppColors.white,
        elevation: 8,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.navyLight,
        selectedColor: AppColors.primaryGreen.withValues(alpha: 0.35),
        labelStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDecorations.radiusFull),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.navyCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDecorations.radiusXl),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.navyCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1),
      listTileTheme: ListTileThemeData(
        iconColor: AppColors.cyan,
        textColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDecorations.radiusLg),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryGreen,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primaryGreen;
          return AppColors.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryGreen.withValues(alpha: 0.35);
          }
          return AppColors.border;
        }),
      ),
    );

    return base.copyWith(
      textTheme: _buildTextTheme(base.textTheme, isDark: isDark),
    );
  }

  static TextTheme _buildTextTheme(TextTheme base, {required bool isDark}) {
    final primary = isDark ? AppColors.textPrimary : const Color(0xFF0E1428);
    final secondary = AppColors.textSecondary;
    return TextTheme(
      displayLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: primary,
        letterSpacing: -0.8,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: primary,
        letterSpacing: -0.6,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: primary,
        letterSpacing: -0.4,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      bodyLarge: GoogleFonts.inter(fontSize: 16, color: primary, height: 1.45),
      bodyMedium: GoogleFonts.inter(fontSize: 14, color: secondary, height: 1.45),
      bodySmall: GoogleFonts.inter(fontSize: 12, color: secondary),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
    );
  }
}
