import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_sizes.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.textOnPrimary,
        primaryContainer: AppColors.primaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.textOnSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        errorContainer: AppColors.errorContainer,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: GoogleFonts.poppins().fontFamily,
    );

    return base.copyWith(
      textTheme: _buildTextTheme(base.textTheme),
      appBarTheme: _appBarTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textButtonTheme: _textButtonTheme,
      inputDecorationTheme: _inputDecorationTheme,
      cardTheme: _cardTheme,
      chipTheme: _chipTheme,
      bottomNavigationBarTheme: _bottomNavTheme,
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: _snackBarTheme,
      dialogTheme: _dialogTheme,
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXs),
        ),
      ),
    );
  }

  static ThemeData get dark {
    const darkBackground = Color(0xFF0F1018);
    const darkSurface = Color(0xFF171927);
    const darkSurfaceAlt = Color(0xFF222437);

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.primaryLight,
        onPrimary: AppColors.white,
        secondary: AppColors.secondaryLight,
        onSecondary: Color(0xFF2B1A24),
        error: AppColors.error,
        onError: AppColors.white,
        surface: darkSurface,
        onSurface: Color(0xFFF3F2F7),
        surfaceContainerHighest: darkSurfaceAlt,
        onSurfaceVariant: Color(0xFFC5C2D3),
        outline: Color(0xFF67637A),
        outlineVariant: Color(0xFF343248),
        shadow: Colors.black,
      ),
      scaffoldBackgroundColor: darkBackground,
      fontFamily: GoogleFonts.poppins().fontFamily,
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primaryLight;
          return const Color(0xFF9A97AB);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary.withValues(alpha: 0.5);
          return const Color(0xFF3B394B);
        }),
      ),
    );

    return base.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).apply(
        bodyColor: base.colorScheme.onSurface,
        displayColor: base.colorScheme.onSurface,
      ),
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: darkBackground,
        foregroundColor: base.colorScheme.onSurface,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      inputDecorationTheme: _inputDecorationTheme.copyWith(
        fillColor: darkSurfaceAlt,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: const BorderSide(color: Color(0xFF343248)),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: const BorderSide(color: Color(0xFF343248)),
        ),
      ),
      cardTheme: base.cardTheme.copyWith(
        color: darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          side: const BorderSide(color: Color(0xFF343248)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF343248),
        thickness: 1,
        space: 1,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: Color(0xFF9A97AB),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dialogTheme: _dialogTheme.copyWith(
        backgroundColor: darkSurface,
      ),
    );
  }

  static TextTheme _buildTextTheme(TextTheme base) {
    return GoogleFonts.poppinsTextTheme(base).copyWith(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.2,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.2,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.3,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.3,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.4,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.4,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.5,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        height: 1.5,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.6,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.6,
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.4,
        letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        height: 1.4,
        letterSpacing: 0.2,
      ),
      labelSmall: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textHint,
        height: 1.4,
        letterSpacing: 0.5,
      ),
    );
  }

  static const AppBarTheme _appBarTheme = AppBarTheme(
    backgroundColor: AppColors.background,
    foregroundColor: AppColors.textPrimary,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
    titleSpacing: AppSizes.md,
  );

  static final ElevatedButtonThemeData _elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      elevation: 0,
      textStyle: GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    ),
  );

  static final OutlinedButtonThemeData _outlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      side: const BorderSide(color: AppColors.primary, width: 1.5),
      textStyle: GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    ),
  );

  static final TextButtonThemeData _textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      textStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  static final InputDecorationTheme _inputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceVariant,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSizes.md,
      vertical: AppSizes.md,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      borderSide: const BorderSide(color: AppColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
    ),
    hintStyle: GoogleFonts.poppins(
      fontSize: 14,
      color: AppColors.textHint,
    ),
    labelStyle: GoogleFonts.poppins(
      fontSize: 14,
      color: AppColors.textSecondary,
    ),
    floatingLabelStyle: GoogleFonts.poppins(
      fontSize: 12,
      color: AppColors.primary,
      fontWeight: FontWeight.w500,
    ),
    errorStyle: GoogleFonts.poppins(
      fontSize: 12,
      color: AppColors.error,
    ),
  );

  static final CardThemeData _cardTheme = CardThemeData(
    color: AppColors.surface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      side: const BorderSide(color: AppColors.border),
    ),
    margin: EdgeInsets.zero,
  );

  static final ChipThemeData _chipTheme = ChipThemeData(
    backgroundColor: AppColors.surfaceVariant,
    selectedColor: AppColors.primaryContainer,
    labelStyle: GoogleFonts.poppins(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: AppSizes.sm,
      vertical: AppSizes.xs,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      side: const BorderSide(color: AppColors.border),
    ),
  );

  static const BottomNavigationBarThemeData _bottomNavTheme = BottomNavigationBarThemeData(
    backgroundColor: AppColors.surface,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.textHint,
    showSelectedLabels: true,
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  );

  static final SnackBarThemeData _snackBarTheme = SnackBarThemeData(
    backgroundColor: AppColors.textPrimary,
    contentTextStyle: GoogleFonts.poppins(
      color: AppColors.white,
      fontSize: 14,
    ),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
    ),
  );

  static final DialogThemeData _dialogTheme = DialogThemeData(
    backgroundColor: AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusXl),
    ),
    titleTextStyle: GoogleFonts.poppins(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    contentTextStyle: GoogleFonts.poppins(
      fontSize: 14,
      color: AppColors.textSecondary,
      height: 1.6,
    ),
  );
}

