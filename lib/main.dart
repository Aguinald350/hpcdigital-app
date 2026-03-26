import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'firebase_options.dart';

// telas / widgets do app
import 'screens/splash_screen.dart';
import 'screens/LoginScreen.dart';
import 'widgets/connectivity_gate.dart';

// tema / controllers
import 'theme/app_theme.dart';
import 'theme/app_theme_controller.dart';

// controller de preferências
import 'screens/conf/app_preferences_controller.dart';

// serviços locais
import 'services/hymn_local_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final systemTag = ui.PlatformDispatcher.instance.locale.toLanguageTag();

    try {
      await initializeDateFormatting(systemTag);
    } catch (_) {}

    await initializeDateFormatting('pt_BR');

    // 🔥 Inicialização segura do Firebase
    try {
      debugPrint('🔥 Tentando inicializar Firebase...');
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('✅ Firebase inicializado com sucesso.');
    } on FirebaseException catch (e) {
      if (e.code == 'duplicate-app') {
        debugPrint('⚠️ Firebase já estava inicializado nativamente. Continuando...');
      } else {
        rethrow;
      }
    }

    // 🔥 Firestore config segura
    try {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      debugPrint('✅ Firestore configurado com cache local.');
    } catch (e) {
      debugPrint('⚠️ Firestore settings já aplicadas ou erro ignorável: $e');
    }

    await Hive.initFlutter();
    final hymnLocal = HymnLocalService();
    await hymnLocal.init();

    debugPrint('🚀 App iniciando...');
    runApp(const MyApp());
  } catch (e, stack) {
    debugPrint('❌ Erro fatal no main(): $e');
    debugPrintStack(stackTrace: stack);

    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'Erro ao iniciar o app:\n\n$e',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final Stream<User?> _authStream;

  static const List<String> _adminsVitalicios = [
    'admin@hpc.com',
    'aguinaldo@igreja.org',
  ];

  @override
  void initState() {
    super.initState();

    preferencesController.load();

    _authStream = FirebaseAuth.instance.authStateChanges();

    _authStream.listen((user) async {
      if (user == null) return;

      try {
        final doc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .get();

        final themeStr =
        (doc.data()?['appTheme'] ?? 'deepOrange') as String;

        appThemeController.setTheme(appThemeFromString(themeStr));

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _checkAccountStatus(context, user);
        });
      } catch (e) {
        debugPrint('Erro ao inicializar usuário: $e');
      }
    });
  }

  Future<void> _checkAccountStatus(BuildContext context, User user) async {
    try {
      final email = (user.email ?? '').trim().toLowerCase();
      if (_adminsVitalicios.contains(email)) return;

      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      final data = doc.data();
      final role = (data?['role'] ?? '').toString().toLowerCase();
      if (role == 'admin') return;

      DateTime? trialEndsAt =
      (data?['trialEndsAt'] as Timestamp?)?.toDate();
      DateTime? activeFrom =
      (data?['activeFrom'] as Timestamp?)?.toDate();
      DateTime? activeUntil =
      (data?['activeUntil'] as Timestamp?)?.toDate();

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final bool isTrialActive =
          trialEndsAt != null &&
              today.isBefore(trialEndsAt.add(const Duration(days: 1)));

      final bool isPaidActive =
          activeFrom != null &&
              activeUntil != null &&
              !today.isBefore(activeFrom) &&
              !today.isAfter(activeUntil);

      if (!isTrialActive && !isPaidActive) {
        if (!context.mounted) return;
        Navigator.pushReplacementNamed(context, '/conta_desativada');
      }
    } catch (e) {
      debugPrint('Erro ao verificar status da conta: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        appThemeController,
        preferencesController,
      ]),
      builder: (context, _) {
        final appTheme = appThemeController.current;

        return MaterialApp(
          title: 'Hinário Digital Hosana',
          debugShowCheckedModeBanner: false,

          theme: themeDataFor(appTheme, Brightness.light),
          darkTheme: themeDataFor(appTheme, Brightness.dark),
          themeMode: preferencesController.themeMode,

          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('pt', 'BR'),
            Locale('pt', 'PT'),
            Locale('en', 'US'),
          ],
          locale: const Locale('pt', 'BR'),

          home: ConnectivityGate(
            child: splash_screen(
              themeSetter: (t) => appThemeController.setTheme(t),
            ),
          ),

          routes: {
            '/conta_desativada': (_) => const ContaDesativadaScreen(),
            '/login': (_) => const Loginscreen(),
          },
        );
      },
    );
  }
}