// lib/main_admin.dart
import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'theme/app_theme_controller.dart';

// controller de preferências (Dark Mode)
import 'screens/conf/app_preferences_controller.dart';

// telas do admin
import 'admin/AdminPanelScreen.dart';
import 'screens/LoginScreen.dart' show Loginscreen;

const _adminsVitalicios = ['admin@hpc.com', 'aguinaldo@igreja.org'];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('❌ Flutter Error: ${details.exception}');
    debugPrintStack(stackTrace: details.stack);
  };

  await runZonedGuarded<Future<void>>(() async {
    try {
      final systemTag = ui.PlatformDispatcher.instance.locale.toLanguageTag();

      try {
        await initializeDateFormatting(systemTag);
      } catch (_) {}

      await initializeDateFormatting('pt_BR');

      // 🔥 FIREBASE SAFE INIT (CORRIGIDO)
      try {
        debugPrint('🔥 [ADMIN] Tentando inicializar Firebase...');
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        debugPrint('✅ [ADMIN] Firebase inicializado');
      } on FirebaseException catch (e) {
        if (e.code == 'duplicate-app') {
          debugPrint(
              '⚠️ [ADMIN] Firebase já estava inicializado nativamente.');
        } else {
          rethrow;
        }
      }

      // 🔥 FIRESTORE CONFIG SAFE
      try {
        FirebaseFirestore.instance.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );
        debugPrint('✅ [ADMIN] Firestore configurado');
      } catch (e) {
        debugPrint('⚠️ [ADMIN] Firestore já configurado ou erro: $e');
      }

      debugPrint('🚀 [ADMIN] App iniciando...');
      runApp(const _AdminApp());
    } catch (e, stack) {
      debugPrint('❌ ERRO FATAL ADMIN: $e');
      debugPrintStack(stackTrace: stack);

      runApp(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Erro ao iniciar ADMIN:\n\n$e',
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      );
    }
  }, (error, stack) {
    debugPrint('❌ ZONED ERROR ADMIN: $error');
    debugPrintStack(stackTrace: stack);
  });
}

class _AdminApp extends StatefulWidget {
  const _AdminApp({super.key});

  @override
  State<_AdminApp> createState() => _AdminAppState();
}

class _AdminAppState extends State<_AdminApp> {
  @override
  void initState() {
    super.initState();

    // 🔥 Carrega modo Light/Dark/System
    preferencesController.load();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        appThemeController,
        preferencesController,
      ]),
      builder: (_, __) {
        final theme = appThemeController.current;

        return MaterialApp(
          title: 'HPC Digital — Admin',
          debugShowCheckedModeBanner: false,

          theme: themeDataFor(theme, Brightness.light),
          darkTheme: themeDataFor(theme, Brightness.dark),
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

          home: const _AdminGate(),
        );
      },
    );
  }
}

class _AdminGate extends StatefulWidget {
  const _AdminGate({super.key});

  @override
  State<_AdminGate> createState() => _AdminGateState();
}

class _AdminGateState extends State<_AdminGate> {
  User? _user;
  bool _checking = true;
  StreamSubscription<User?>? _authSub;

  @override
  void initState() {
    super.initState();

    _authSub =
        FirebaseAuth.instance.authStateChanges().listen((u) async {
          _user = u;

          if (u == null) {
            if (mounted) setState(() => _checking = false);
            return;
          }

          try {
            final snap = await FirebaseFirestore.instance
                .collection('usuarios')
                .doc(u.uid)
                .get();

            final data = snap.data() ?? {};
            final email = (u.email ?? '').trim().toLowerCase();
            final role = (data['role'] ?? '').toString().toLowerCase();

            final themeStr = (data['appTheme'] ?? 'deepOrange') as String;

            appThemeController.setTheme(
              appThemeFromString(themeStr),
            );

            final isAdmin =
                _adminsVitalicios.contains(email) || role == 'admin';

            if (!mounted) return;

            if (isAdmin) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const AdminPanelScreen(),
                ),
              );
            } else {
              await FirebaseAuth.instance.signOut();
              setState(() => _checking = false);
            }
          } catch (e) {
            debugPrint('Erro ao validar admin: $e');
            if (!mounted) return;
            setState(() => _checking = false);
          }
        });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return const _AdminLoginScreen();
  }
}

class _AdminLoginScreen extends StatefulWidget {
  const _AdminLoginScreen({super.key});

  @override
  State<_AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<_AdminLoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim().toLowerCase(),
        password: _pass.text,
      );

      final user = cred.user;
      if (user == null) throw Exception('Sem usuário.');

      final email = (user.email ?? '').trim().toLowerCase();

      final snap = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      final data = snap.data() ?? {};
      final role = (data['role'] ?? '').toString().toLowerCase();

      final isAdmin =
          _adminsVitalicios.contains(email) || role == 'admin';

      if (!isAdmin) {
        await FirebaseAuth.instance.signOut();
        setState(() => _error =
        'Acesso restrito. Apenas administradores.');
        return;
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const AdminPanelScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? 'Erro no login');
    } catch (e) {
      setState(() => _error = 'Erro inesperado.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'HPC Digital — Admin',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _email,
                  decoration: const InputDecoration(
                    labelText: 'Email do administrador',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _pass,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _login(),
                ),
                const SizedBox(height: 16),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                _loading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _login,
                    child: const Text('Entrar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}