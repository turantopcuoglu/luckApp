import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_dimens.dart';

/// Uygulamanın tek (dark) temasını üreten sınıf.
///
/// Tema `MaterialApp.theme`'e [AppTheme.dark] ile bağlanır; renkler
/// [AppColors], ölçüler [AppSpacing]/[AppRadius] sabitlerinden gelir.
abstract final class AppTheme {
  /// Koyu tema: derin lacivert zemin, altın vurgu, soft mor ikincil.
  static ThemeData get dark {
    final ColorScheme scheme = ColorScheme.dark(
      surface: AppColors.background,
      surfaceContainer: AppColors.surface,
      primary: AppColors.gold,
      onPrimary: AppColors.background,
      secondary: AppColors.purple,
      onSecondary: AppColors.textPrimary,
      error: AppColors.error,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: _textTheme,
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.background,
          minimumSize: const Size.fromHeight(AppSpacing.xxl),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }

  /// Metin stilleri: başlıklar Playfair Display (mistik/şık),
  /// gövde metinleri Inter (okunaklı).
  static TextTheme get _textTheme {
    final TextTheme base = ThemeData.dark().textTheme;
    return GoogleFonts.interTextTheme(base)
        .copyWith(
          displayLarge: GoogleFonts.playfairDisplay(
            textStyle: base.displayLarge,
            fontWeight: FontWeight.w600,
          ),
          displayMedium: GoogleFonts.playfairDisplay(
            textStyle: base.displayMedium,
            fontWeight: FontWeight.w600,
          ),
          headlineMedium: GoogleFonts.playfairDisplay(
            textStyle: base.headlineMedium,
            fontWeight: FontWeight.w600,
          ),
        )
        .apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        );
  }
}
