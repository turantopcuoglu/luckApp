import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimens.dart';
import 'app_motion.dart';
import 'app_typography.dart';

/// Modern Tesadüf açık/koyu temaları; bileşenler renkleri ColorScheme'den alır.
/// Eski feature ekranları taşınana kadar kök uygulama koyu temada kalır.
abstract final class AppTheme {
  /// Sıcak krem zemin ve lime ana eylem.
  static ThemeData get light => _build(Brightness.light);

  /// Derin ink zemin ve lime ana eylem.
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final bool dark = brightness == Brightness.dark;
    final Color canvas = dark ? AppColors.ink : AppColors.warmCream;
    final Color surface = dark ? AppColors.inkSurface : AppColors.creamSurface;
    final Color text = dark ? AppColors.textOnInk : AppColors.textOnCream;
    final Color muted = dark ? AppColors.mutedOnInk : AppColors.mutedOnCream;
    final Color outline = dark
        ? AppColors.outlineOnInk
        : AppColors.outlineOnCream;
    final Color divider = dark
        ? AppColors.dividerOnInk
        : AppColors.dividerOnCream;
    final ColorScheme scheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.electricLime,
      onPrimary: AppColors.ink,
      primaryContainer: AppColors.electricLime,
      onPrimaryContainer: AppColors.ink,
      secondary: AppColors.iris,
      onSecondary: AppColors.ink,
      secondaryContainer: AppColors.iris,
      onSecondaryContainer: AppColors.ink,
      tertiary: AppColors.warmCoral,
      onTertiary: AppColors.ink,
      tertiaryContainer: AppColors.iceBlue,
      onTertiaryContainer: AppColors.ink,
      error: dark ? AppColors.errorOnInk : AppColors.errorOnCream,
      onError: dark ? AppColors.ink : AppColors.creamSurface,
      surface: surface,
      onSurface: text,
      surfaceContainerLowest: canvas,
      surfaceContainerLow: surface,
      surfaceContainer: surface,
      surfaceContainerHigh: canvas,
      surfaceContainerHighest: canvas,
      onSurfaceVariant: muted,
      outline: outline,
      outlineVariant: divider,
      inverseSurface: dark ? AppColors.creamSurface : AppColors.inkSurface,
      onInverseSurface: dark ? AppColors.textOnCream : AppColors.textOnInk,
      inversePrimary: dark ? AppColors.ink : AppColors.electricLime,
      shadow: AppColors.ink,
      scrim: AppColors.ink,
      surfaceTint: Colors.transparent,
    );
    final RoundedRectangleBorder shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
    );
    final ButtonStyle control = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll<Size>(
        Size(AppLayout.minTouchTarget, AppLayout.buttonMinHeight),
      ),
      padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
        EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
      ),
      shape: WidgetStatePropertyAll<OutlinedBorder>(shape),
      tapTargetSize: MaterialTapTargetSize.padded,
      animationDuration: AppMotion.press,
      textStyle: WidgetStatePropertyAll<TextStyle>(
        AppTypography.textTheme(brightness).labelLarge!,
      ),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: canvas,
      fontFamily: AppTypography.bodyFamily,
      textTheme: AppTypography.textTheme(
        brightness,
      ).apply(bodyColor: text, displayColor: text),
      disabledColor: muted,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: text,
        selectionColor: outline.withValues(alpha: 0.25),
        selectionHandleColor: text,
      ),
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: AppElevation.flat,
        margin: EdgeInsets.zero,
        shape: shape.copyWith(
          side: BorderSide(color: divider, width: AppStroke.thin),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: control.copyWith(
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) => states.contains(WidgetState.disabled)
                ? divider
                : scheme.primary,
          ),
          foregroundColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) => states.contains(WidgetState.disabled)
                ? muted
                : scheme.onPrimary,
          ),
          side: WidgetStateProperty.resolveWith<BorderSide>(
            (Set<WidgetState> states) => BorderSide(
              color: states.contains(WidgetState.focused)
                  ? outline
                  : scheme.onPrimary,
              width: states.contains(WidgetState.focused)
                  ? AppStroke.focus
                  : AppStroke.thin,
            ),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: control.copyWith(
          foregroundColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) =>
                states.contains(WidgetState.disabled) ? muted : text,
          ),
          side: WidgetStateProperty.resolveWith<BorderSide>(
            (Set<WidgetState> states) => BorderSide(
              color: states.contains(WidgetState.disabled) ? divider : outline,
              width: states.contains(WidgetState.focused)
                  ? AppStroke.focus
                  : AppStroke.control,
            ),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: control.copyWith(
          foregroundColor: WidgetStatePropertyAll<Color>(text),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: text,
          minimumSize: const Size.square(AppLayout.minTouchTarget),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: canvas,
        foregroundColor: text,
        surfaceTintColor: Colors.transparent,
        elevation: AppElevation.flat,
        scrolledUnderElevation: AppElevation.flat,
        centerTitle: false,
      ),
      dividerTheme: DividerThemeData(color: divider, thickness: AppStroke.thin),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: AppElevation.overlay,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.lg),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: TextStyle(color: muted),
        labelStyle: TextStyle(color: muted),
        floatingLabelStyle: TextStyle(color: text),
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: outline, width: AppStroke.focus),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: text),
    );
  }
}
