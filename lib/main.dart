// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:hpcdigital/screens/splash_screen.dart';
// import 'package:intl/date_symbol_data_file.dart';
// import 'firebase_options.dart';
// import 'dart:ui' as ui;
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   await initializeDateFormatting(ui.PlatformDispatcher.instance.locale.toLanguageTag());
//
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'HPCDIGITAL',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.deepOrange,
//         fontFamily: 'Roboto',
//       ),
//       home: const splash_screen(),
//     );
//   }
// }
//
//

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart'; // <-- import CORRETO
import 'firebase_options.dart';
import 'package:hpcdigital/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa dados de formatação para o locale atual do dispositivo (ex.: pt-BR)
  final String localeTag = ui.PlatformDispatcher.instance.locale.toLanguageTag();
  await initializeDateFormatting(localeTag);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HPCDIGITAL',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        fontFamily: 'Roboto',
      ),

      // Delegates e locales (opcional, mas recomendado)
      // localizationsDelegates: const [
      //   GlobalMaterialLocalizations.delegate,
      //   GlobalWidgetsLocalizations.delegate,
      //   GlobalCupertinoLocalizations.delegate,
      // ],
      // supportedLocales: const [
      //   Locale('pt', 'BR'),
      //   Locale('en', 'US'),
      // ],
      home: const splash_screen(), // use CamelCase na classe
    );
  }
}
