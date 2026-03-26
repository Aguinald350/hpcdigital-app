// // lib/theme/app_theme.dart
// import 'package:flutter/material.dart';
//
// enum AppTheme { deepOrange, red, indigo, teal }
//
// String appThemeToString(AppTheme t) => switch (t) {
//   AppTheme.deepOrange => 'deepOrange',
//   AppTheme.red        => 'red',
//   AppTheme.indigo     => 'indigo',
//   AppTheme.teal       => 'teal',
//
// };
//
// AppTheme appThemeFromString(String s) => switch (s) {
//   'red'        => AppTheme.red,
//   'indigo'     => AppTheme.indigo,
//   'teal'       => AppTheme.teal,
//   _            => AppTheme.deepOrange,
// };
//
// String appThemeLabel(AppTheme t) => switch (t) {
//   AppTheme.deepOrange => 'Laranja (Deep Orange)',
//   AppTheme.red        => 'Vermelho',
//   AppTheme.indigo     => 'Índigo',
//   AppTheme.teal       => 'Verde-Água',
// };
//
// ThemeData themeDataFor(AppTheme t) {
//   // Escolhe um swatch Material “puro” e usa como cor primária real
//   final MaterialColor swatch = switch (t) {
//     AppTheme.deepOrange => Colors.deepOrange,
//     AppTheme.red        => Colors.red,
//     AppTheme.indigo     => Colors.indigo,
//     AppTheme.teal       => Colors.teal,
//   };
//
//   // Gera o esquema baseado no seed…
//   final base = ColorScheme.fromSeed(
//     seedColor: swatch,
//     brightness: Brightness.light,
//   );
//
//   // …mas força o primary a ser exatamente o swatch escolhido
//   // e escolhe containers coerentes (claros) para manter legibilidade.
//   final ColorScheme scheme = base.copyWith(
//     primary: swatch,
//     onPrimary: Colors.white,
//     primaryContainer: swatch.shade100,
//     onPrimaryContainer: Colors.black,
//     secondary: base.secondary, // mantém o restante do esquema do M3
//     tertiary: base.tertiary,
//   );
//
//   return ThemeData(
//     useMaterial3: true,
//     colorScheme: scheme,
//     scaffoldBackgroundColor: Colors.white,
//
//     appBarTheme: AppBarTheme(
//       backgroundColor: scheme.primary,
//       foregroundColor: scheme.onPrimary,
//       elevation: 0,
//       scrolledUnderElevation: 0,
//       surfaceTintColor: Colors
//           .transparent, // evita tonal overlay que “suja” a cor no M3
//     ),
//
//     elevatedButtonTheme: ElevatedButtonThemeData(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: scheme.primary,
//         foregroundColor: scheme.onPrimary,
//         minimumSize: const Size.fromHeight(48),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//     ),
//
//     chipTheme: ChipThemeData(
//       selectedColor: scheme.primaryContainer,
//       labelStyle: TextStyle(color: scheme.onPrimaryContainer),
//     ),
//
//     inputDecorationTheme: InputDecorationTheme(
//       border: const OutlineInputBorder(),
//       focusedBorder: OutlineInputBorder(
//         borderSide: BorderSide(color: scheme.primary, width: 2),
//       ),
//     ),
//
//     progressIndicatorTheme: ProgressIndicatorThemeData(
//       color: scheme.primary,
//     ),
//   );
// }


// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

enum AppTheme { deepOrange, red, indigo, teal }

String appThemeToString(AppTheme t) => switch (t) {
  AppTheme.deepOrange => 'deepOrange',
  AppTheme.red        => 'red',
  AppTheme.indigo     => 'indigo',
  AppTheme.teal       => 'teal',
};

AppTheme appThemeFromString(String s) => switch (s) {
  'red'        => AppTheme.red,
  'indigo'     => AppTheme.indigo,
  'teal'       => AppTheme.teal,
  _            => AppTheme.deepOrange,
};

String appThemeLabel(AppTheme t) => switch (t) {
  AppTheme.deepOrange => 'Laranja (Deep Orange)',
  AppTheme.red        => 'Vermelho',
  AppTheme.indigo     => 'Índigo',
  AppTheme.teal       => 'Verde-Água',
};

ThemeData themeDataFor(AppTheme t, Brightness brightness) {
  // Define o swatch principal
  final MaterialColor swatch = switch (t) {
    AppTheme.deepOrange => Colors.deepOrange,
    AppTheme.red        => Colors.red,
    AppTheme.indigo     => Colors.indigo,
    AppTheme.teal       => Colors.teal,
  };

  // Gera ColorScheme baseado no brilho
  final baseScheme = ColorScheme.fromSeed(
    seedColor: swatch,
    brightness: brightness,
  );

  // Ajustes finos no esquema
  final scheme = baseScheme.copyWith(
    primary: swatch,
    onPrimary: Colors.white,
  );

  final bool isDark = brightness == Brightness.dark;

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,

    scaffoldBackgroundColor:
    isDark ? const Color(0xFF121212) : Colors.white,

    appBarTheme: AppBarTheme(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    chipTheme: ChipThemeData(
      selectedColor: scheme.primaryContainer,
      labelStyle: TextStyle(color: scheme.onPrimaryContainer),
    ),

    inputDecorationTheme: InputDecorationTheme(
      border: const OutlineInputBorder(),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
    ),

    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: scheme.primary,
    ),

    cardTheme: CardThemeData(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}
