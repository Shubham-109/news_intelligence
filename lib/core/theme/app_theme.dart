import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const serif = 'Gelasio';
  static const sans = 'Geist';
  static final ThemeData light = _build(_lightColors);
  static final ThemeData dark = _build(_darkColors);

  static const _lightColors = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF0E5E4A),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFD9ECE4),
    onPrimaryContainer: Color(0xFF06382B),
    secondary: Color(0xFF4B5158),
    onSecondary: Color(0xFFFFFFFF),
    error: Color(0xFFB3261E),
    onError: Color(0xFFFFFFFF),
    surface: Color(0xFFF7F5F0),
    onSurface: Color(0xFF17191C),
    onSurfaceVariant: Color(0xFF5F646B),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF2EFE9),
    surfaceContainer: Color(0xFFEDE9E2),
    surfaceContainerHigh: Color(0xFFE7E3DB),
    surfaceContainerHighest: Color(0xFFE0DBD2),
    outline: Color(0xFF8C9198),
    outlineVariant: Color(0xFFE2DDD4),
    inverseSurface: Color(0xFF17191C),
    onInverseSurface: Color(0xFFF2F0EB),
    inversePrimary: Color(0xFF7FD3B4),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    surfaceTint: Colors.transparent,
  );

  static const _darkColors = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF74CFAE),
    onPrimary: Color(0xFF00382A),
    primaryContainer: Color(0xFF15433A),
    onPrimaryContainer: Color(0xFFC2EEDC),
    secondary: Color(0xFFB9BEC4),
    onSecondary: Color(0xFF22262A),
    error: Color(0xFFF2B8B5),
    onError: Color(0xFF601410),
    surface: Color(0xFF121416),
    onSurface: Color(0xFFECEAE5),
    onSurfaceVariant: Color(0xFFA4A9AF),
    surfaceContainerLowest: Color(0xFF0C0E10),
    surfaceContainerLow: Color(0xFF181A1D),
    surfaceContainer: Color(0xFF1C1F22),
    surfaceContainerHigh: Color(0xFF23272B),
    surfaceContainerHighest: Color(0xFF2B2F34),
    outline: Color(0xFF6F757C),
    outlineVariant: Color(0xFF2B2F34),
    inverseSurface: Color(0xFFECEAE5),
    onInverseSurface: Color(0xFF17191C),
    inversePrimary: Color(0xFF0E5E4A),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    surfaceTint: Colors.transparent,
  );

  static ThemeData _build(ColorScheme colors) {
    final text = _textTheme(colors);
    final rounded = BorderRadius.circular(12);
    final fieldFill = colors.brightness == Brightness.light
        ? colors.surfaceContainerLowest
        : colors.surfaceContainer;

    OutlineInputBorder fieldBorder(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: rounded,
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      fontFamily: sans,
      textTheme: text,
      scaffoldBackgroundColor: colors.surface,
      appBarTheme: AppBarThemeData(
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
      ),
      dividerTheme: DividerThemeData(
        color: colors.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: fieldFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        hintStyle: text.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
        prefixIconColor: colors.onSurfaceVariant,
        suffixIconColor: colors.onSurfaceVariant,
        border: fieldBorder(colors.outlineVariant),
        enabledBorder: fieldBorder(colors.outlineVariant),
        focusedBorder: fieldBorder(colors.primary, 1.5),
        errorBorder: fieldBorder(colors.error),
        focusedErrorBorder: fieldBorder(colors.error, 1.5),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: rounded),
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 46),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          foregroundColor: colors.onSurface,
          side: BorderSide(color: colors.outlineVariant),
          shape: RoundedRectangleBorder(borderRadius: rounded),
          textStyle: text.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
          textStyle: text.labelLarge,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: colors.onSurface,
        unselectedLabelColor: colors.onSurfaceVariant,
        labelStyle: text.titleSmall,
        unselectedLabelStyle: text.titleSmall?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: colors.onSurface, width: 2),
        ),
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: colors.outlineVariant,
        tabAlignment: TabAlignment.start,
        labelPadding: const EdgeInsets.symmetric(horizontal: 12),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        splashFactory: NoSplash.splashFactory,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        elevation: 0,
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return text.labelMedium?.copyWith(
            color: selected ? colors.onSurface : colors.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? colors.onSurface : colors.onSurfaceVariant,
          );
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surface,
        selectedColor: colors.inverseSurface,
        side: WidgetStateBorderSide.resolveWith(
          (states) => BorderSide(
            color: states.contains(WidgetState.selected)
                ? colors.inverseSurface
                : colors.outlineVariant,
          ),
        ),
        shape: const StadiumBorder(),
        labelStyle: text.labelMedium?.copyWith(
          color: WidgetStateColor.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? colors.onInverseSurface
                : colors.onSurface,
          ),
        ),
        showCheckmark: false,
        elevation: 0,
        pressElevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.inverseSurface,
        contentTextStyle: text.bodyMedium?.copyWith(
          color: colors.onInverseSurface,
        ),
        actionTextColor: colors.inversePrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: colors.outline,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: colors.primary),
    );
  }

  static TextTheme _textTheme(ColorScheme colors) {
    TextStyle serifStyle(double size, double height) {
      return TextStyle(
        fontFamily: serif,
        fontSize: size,
        height: height,
        fontWeight: FontWeight.w600,
        color: colors.onSurface,
      );
    }

    TextStyle sansStyle(
      double size,
      double height,
      FontWeight weight, {
      Color? color,
      double letterSpacing = 0,
    }) {
      return TextStyle(
        fontFamily: sans,
        fontSize: size,
        height: height,
        fontWeight: weight,
        letterSpacing: letterSpacing,
        color: color ?? colors.onSurface,
      );
    }

    return TextTheme(
      displaySmall: serifStyle(34, 1.15),
      headlineMedium: serifStyle(28, 1.2),
      headlineSmall: serifStyle(23, 1.25),
      titleLarge: serifStyle(20, 1.3),
      titleMedium: serifStyle(17, 1.32),
      titleSmall: sansStyle(14.5, 1.4, FontWeight.w600),
      bodyLarge: sansStyle(16, 1.5, FontWeight.w400),
      bodyMedium: sansStyle(14, 1.45, FontWeight.w400),
      bodySmall: sansStyle(
        12.5,
        1.4,
        FontWeight.w400,
        color: colors.onSurfaceVariant,
      ),
      labelLarge: sansStyle(15, 1.2, FontWeight.w600),
      labelMedium: sansStyle(13, 1.2, FontWeight.w500),
      labelSmall: sansStyle(11, 1.2, FontWeight.w600, letterSpacing: 1.1),
    );
  }
}

extension AppTextStyles on TextTheme {
  TextStyle get standfirst => titleMedium!.copyWith(
    fontSize: 16.5,
    height: 1.45,
    fontWeight: FontWeight.w400,
  );

  TextStyle get articleBody => titleMedium!.copyWith(
    fontSize: 18,
    height: 1.65,
    fontWeight: FontWeight.w400,
  );
}
