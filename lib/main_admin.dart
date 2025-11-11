// lib/main_admin.dart
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Localizations (ADICIONE no pubspec: flutter_localizations: sdk: flutter)
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'theme/app_theme_controller.dart';

// telas do admin
import 'admin/AdminPanelScreen.dart';
import 'screens/LoginScreen.dart' show Loginscreen;

/// Allowlist: admins com acesso vitalício
const _adminsVitalicios = ['admin@hpc.com', 'aguinaldo@igreja.org'];

/// FORÇAR caminho do log dentro da pasta do usuário:
/// Exemplo Windows: C:\Users\DELL\hpclogs\hpc_admin_crash_log.txt
/// Exemplo Unix: /home/username/hpclogs/hpc_admin_crash_log.txt
final String _forcedLogPath = () {
  try {
    if (Platform.isWindows) {
      final userProfile = Platform.environment['USERPROFILE'] ?? Directory.current.path;
      return '${userProfile}${Platform.pathSeparator}hpclogs${Platform.pathSeparator}hpc_admin_crash_log.txt';
    } else {
      final home = Platform.environment['HOME'] ?? Directory.current.path;
      return '${home}${Platform.pathSeparator}hpclogs${Platform.pathSeparator}hpc_admin_crash_log.txt';
    }
  } catch (_) {
    // fallback simples
    return '${Directory.current.path}${Platform.pathSeparator}hpclogs${Platform.pathSeparator}hpc_admin_crash_log.txt';
  }
}();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('main(): Flutter bindings initialized.');

  // captura erros do Flutter (framework)
  FlutterError.onError = (FlutterErrorDetails details) async {
    // em debug use o handler padrão
    if (kDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    }
    debugPrint('FlutterError.onError: ${details.exception}');
    await _writeCrash(details.exceptionAsString(), details.stack?.toString(),
        note: 'FlutterError.onError');
  };

  // captura erros não tratados (zona)
  await runZonedGuarded<Future<void>>(() async {
    debugPrint('runZonedGuarded: init start');

    // Inicializações críticas (intl + firebase)
    final systemTag = ui.PlatformDispatcher.instance.locale.toLanguageTag();
    debugPrint('Locale tag: $systemTag');

    try {
      debugPrint('Initializing date formatting for systemTag...');
      try {
        await initializeDateFormatting(systemTag);
        debugPrint('initializeDateFormatting(systemTag) OK');
      } catch (e) {
        debugPrint('initializeDateFormatting(systemTag) failed: $e');
      }

      debugPrint('Initializing date formatting for pt_BR...');
      await initializeDateFormatting('pt_BR');
      debugPrint('initializeDateFormatting(pt_BR) OK');
    } catch (e, st) {
      debugPrint('Intl init error: $e');
      await _writeCrash('Intl init error: $e', st.toString(), note: 'Intl init');
    }

    try {
      debugPrint('Calling Firebase.initializeApp()...');
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      debugPrint('Firebase.initializeApp() completed successfully.');
    } catch (e, st) {
      debugPrint('Firebase.initializeApp() error: $e');
      await _writeCrash('Firebase initializeApp error: $e', st.toString(), note: 'Firebase init');
      // não rethrow — permitimos que o app continue (poderás ajustar)
    }

    debugPrint('About to runApp(_AdminApp)...');
    runApp(const _AdminApp());
    debugPrint('runApp returned (should not normally reach here).');
  }, (error, stack) async {
    debugPrint('runZonedGuarded caught error: $error');
    await _writeCrash(error.toString(), stack.toString(), note: 'runZonedGuarded');
  });
}

/// grava crashes em arquivo (força caminho se possível), e no stdout.
Future<void> _writeCrash(String error, String? stack, {String? note}) async {
  try {
    final now = DateTime.now().toIso8601String();
    final content = [
      '----- HPC Admin Crash -----',
      'Timestamp: $now',
      'Note: ${note ?? "none"}',
      'Platform: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
      'ForcedLogPath: $_forcedLogPath',
      'Error: $error',
      'Stack: ${stack ?? "sem stack"}',
      '',
    ].join('\n');

    // 1) Tenta o caminho forçado (definido globalmente) — cria diretório se necessário
    try {
      final forcedFile = File(_forcedLogPath);
      final parent = forcedFile.parent;
      if (!await parent.exists()) {
        await parent.create(recursive: true);
        debugPrint('Created log directory: ${parent.path}');
      }
      await forcedFile.create(recursive: true);
      await forcedFile.writeAsString(content, mode: FileMode.append);
      debugPrint('Crash log written to forced path: $_forcedLogPath');
      // também escreve no stdout
      try {
        stdout.writeln(content);
      } catch (_) {}
      return;
    } catch (e) {
      debugPrint('Failed writing to forced log path ($_forcedLogPath): $e');
      // segue para fallback
    }

    // 2) fallback: tenta múltiplos locais
    final pathsToTry = <String>[
      Directory.systemTemp.path,
      Directory.current.path,
      if (Platform.isWindows) (Platform.environment['USERPROFILE'] ?? r'C:\Users\Default'),
    ];

    var wrote = false;
    for (final p in pathsToTry) {
      try {
        final dir = Directory(p);
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        final f = File('${p}${Platform.pathSeparator}hpclogs${Platform.pathSeparator}hpc_crash_log.txt');
        final parent = f.parent;
        if (!await parent.exists()) {
          await parent.create(recursive: true);
        }
        await f.create(recursive: true);
        await f.writeAsString(content, mode: FileMode.append);
        debugPrint('Crash log written to: ${f.path}');
        wrote = true;
        break;
      } catch (e) {
        debugPrint('Failed writing crash log to $p: $e');
      }
    }

    // último recurso: stdout
    if (!wrote) {
      try {
        stdout.writeln(content);
        debugPrint('Crash log written to stdout as last resort.');
      } catch (e) {
        debugPrint('Failed writing crash log to stdout: $e');
      }
    }
  } catch (e) {
    // nada a fazer se falhar completamente
    try {
      debugPrint('_writeCrash top-level failure: $e');
    } catch (_) {}
  }
}

class _AdminApp extends StatefulWidget {
  const _AdminApp({super.key});
  @override
  State<_AdminApp> createState() => _AdminAppState();
}

class _AdminAppState extends State<_AdminApp> {
  @override
  Widget build(BuildContext context) {
    debugPrint('_AdminApp.build() - building MaterialApp');
    return AnimatedBuilder(
      animation: appThemeController,
      builder: (_, __) {
        final theme = appThemeController.current;
        return MaterialApp(
          title: 'HPC Digital — Admin',
          debugShowCheckedModeBanner: false,
          theme: themeDataFor(theme),

          // ✅ Localizations — resolve o erro do AppBar/NavigationRail
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
          // defina o app em pt_BR
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
    debugPrint('_AdminGate.initState() - subscribing to authStateChanges');
    // ouvir authStateChanges com cancelamento seguro
    _authSub = FirebaseAuth.instance.authStateChanges().listen((u) async {
      debugPrint('authStateChanges: user -> ${u?.uid ?? "null"} / ${u?.email}');
      _user = u;
      if (u == null) {
        if (mounted) setState(() => _checking = false);
        return;
      }
      try {
        debugPrint('Fetching usuario doc for uid=${u.uid}');
        final snap = await FirebaseFirestore.instance.collection('usuarios').doc(u.uid).get();
        final data = snap.data() ?? {};
        final email = (u.email ?? '').trim().toLowerCase();
        final role = (data['role'] ?? '').toString().toLowerCase();
        debugPrint('Usuario doc loaded. role=$role');

        // aplica tema salvo (se tiver)
        final themeStr = (data['appTheme'] ?? 'deepOrange') as String;
        debugPrint('Applying theme: $themeStr');
        appThemeController.setTheme(appThemeFromString(themeStr));

        final isAdmin = _adminsVitalicios.contains(email) || role == 'admin';
        debugPrint('isAdmin? $isAdmin (email:$email)');

        if (!mounted) return;
        if (isAdmin) {
          debugPrint('Navigating to AdminPanelScreen...');
          try {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const AdminPanelScreen()),
            );
            debugPrint('Navigation to AdminPanelScreen requested.');
          } catch (e, st) {
            debugPrint('Navigation error: $e');
            await _writeCrash('Navigation to AdminPanelScreen error: $e', st.toString(), note: 'Navigation');
            // ensure sign out and fallback to login
            try {
              await FirebaseAuth.instance.signOut();
            } catch (_) {}
            if (mounted) setState(() => _checking = false);
          }
        } else {
          debugPrint('Not admin -> signing out and showing login.');
          await FirebaseAuth.instance.signOut();
          if (mounted) setState(() => _checking = false);
        }
      } catch (e, st) {
        debugPrint('AdminGate auth handler error: $e');
        await _writeCrash('AdminGate auth handler error: $e', st.toString(), note: 'AdminGate');
        if (!mounted) return;
        setState(() => _checking = false);
      }
    }, onError: (e, st) async {
      debugPrint('authStateChanges listen error: $e');
      await _writeCrash('authStateChanges listen error: $e', st.toString(), note: 'auth listen');
      if (mounted) setState(() => _checking = false);
    });
  }

  @override
  void dispose() {
    debugPrint('_AdminGate.dispose() - cancelling auth subscription');
    _authSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('_AdminGate.build() - _checking=$_checking');
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
    debugPrint('_AdminLoginScreen._login() - attempting signInWithEmailAndPassword for ${_email.text}');
    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim().toLowerCase(),
        password: _pass.text,
      );

      final user = cred.user;
      debugPrint('signInWithEmailAndPassword result user=${user?.uid}');
      if (user == null) throw Exception('Sem usuário.');

      final email = (user.email ?? '').trim().toLowerCase();
      debugPrint('Loading usuario doc for ${user.uid}');
      final snap = await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get();
      final data = snap.data() ?? {};
      final role = (data['role'] ?? '').toString().toLowerCase();

      final isAdmin = _adminsVitalicios.contains(email) || role == 'admin';
      debugPrint('isAdmin after login? $isAdmin');
      if (!isAdmin) {
        await FirebaseAuth.instance.signOut();
        setState(() => _error = 'Acesso restrito. Esta aplicação é apenas para administradores.');
        return;
      }

      if (!mounted) return;
      debugPrint('Navigating to AdminPanelScreen after manual login...');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminPanelScreen()),
      );
      debugPrint('Navigation requested.');
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException in _login: ${e.code} / ${e.message}');
      setState(() => _error = e.message ?? 'Erro no login');
    } catch (e, st) {
      debugPrint('Unexpected error in _login: $e');
      await _writeCrash('Admin login error: $e', st.toString(), note: 'Login');
      setState(() => _error = 'Erro inesperado: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('_AdminLoginScreen.build() - building login UI');
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('HPC Digital — Admin', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
                    child: Text(_error!, style: const TextStyle(color: Colors.red)),
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
