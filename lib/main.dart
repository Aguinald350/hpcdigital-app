// // lib/main.dart
// import 'dart:ui' as ui;
//
// import 'package:flutter/material.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:intl/date_symbol_data_local.dart';
//
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// import 'firebase_options.dart';
//
// // telas / widgets do app
// import 'screens/splash_screen.dart';
// import 'screens/LoginScreen.dart';
// import 'widgets/connectivity_gate.dart';
//
// // tema / controllers
// import 'theme/app_theme.dart';
// import 'theme/app_theme_controller.dart';
//
// // serviços locais
// import 'services/hymn_local_service.dart';
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // 🌍 Locale + Intl
//   final systemTag = ui.PlatformDispatcher.instance.locale.toLanguageTag();
//   try {
//     await initializeDateFormatting(systemTag);
//   } catch (_) {}
//   await initializeDateFormatting('pt_BR');
//
//   // 🔥 Firebase
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//
//   // 💾 Hive (serviço local de hinos)
//   final hymnLocal = HymnLocalService();
//   await hymnLocal.init();
//
//   runApp(const MyApp());
// }
//
// class MyApp extends StatefulWidget {
//   const MyApp({super.key});
//   @override
//   State<MyApp> createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   late final Stream<User?> _authStream;
//
//   static const List<String> _adminsVitalicios = [
//     'admin@hpc.com',
//     'aguinaldo@igreja.org',
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _authStream = FirebaseAuth.instance.authStateChanges();
//     _authStream.listen((user) async {
//       if (user == null) return;
//       try {
//         final doc = await FirebaseFirestore.instance
//             .collection('usuarios')
//             .doc(user.uid)
//             .get();
//
//         final themeStr = (doc.data()?['appTheme'] ?? 'deepOrange') as String;
//         appThemeController.setTheme(appThemeFromString(themeStr));
//
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           _checkAccountStatus(context, user);
//         });
//       } catch (e) {
//         debugPrint('Erro ao inicializar usuário: $e');
//       }
//     });
//   }
//
//   Future<void> _checkAccountStatus(BuildContext context, User user) async {
//     try {
//       final email = (user.email ?? '').trim().toLowerCase();
//       if (_adminsVitalicios.contains(email)) return;
//
//       final doc = await FirebaseFirestore.instance
//           .collection('usuarios')
//           .doc(user.uid)
//           .get();
//
//       final data = doc.data();
//       final role = (data?['role'] ?? '').toString().toLowerCase();
//       if (role == 'admin') return;
//
//       DateTime? trialEndsAt = (data?['trialEndsAt'] as Timestamp?)?.toDate();
//       DateTime? activeFrom = (data?['activeFrom'] as Timestamp?)?.toDate();
//       DateTime? activeUntil = (data?['activeUntil'] as Timestamp?)?.toDate();
//
//       final now = DateTime.now();
//       final today = DateTime(now.year, now.month, now.day);
//
//       final bool isTrialActive =
//           trialEndsAt != null && today.isBefore(trialEndsAt.add(const Duration(days: 1)));
//       final bool isPaidActive = activeFrom != null &&
//           activeUntil != null &&
//           !today.isBefore(activeFrom) &&
//           !today.isAfter(activeUntil);
//
//       if (!isTrialActive && !isPaidActive) {
//         if (!context.mounted) return;
//         Navigator.pushReplacementNamed(context, '/conta_desativada');
//       }
//     } catch (e) {
//       debugPrint('Erro ao verificar status da conta: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: appThemeController,
//       builder: (context, _) {
//         final appTheme = appThemeController.current;
//         return MaterialApp(
//           title: 'Hinário Digital Hosana',
//           debugShowCheckedModeBanner: false,
//           theme: themeDataFor(appTheme),
//
//           // ✅ Localizations — resolve AppBar/NavigationRail no mobile também
//           localizationsDelegates: const [
//             GlobalMaterialLocalizations.delegate,
//             GlobalWidgetsLocalizations.delegate,
//             GlobalCupertinoLocalizations.delegate,
//           ],
//           supportedLocales: const [
//             Locale('pt', 'BR'),
//             Locale('pt', 'PT'),
//             Locale('en', 'US'),
//           ],
//           locale: const Locale('pt', 'BR'),
//
//           // 🔒 Envolvemos o fluxo inicial com o ConnectivityGate:
//           // O gate garante que o app só execute auto-login/listeners
//           // quando houver internet real; caso contrário mostra tela pedindo reconexão.
//           home: ConnectivityGate(
//             child: splash_screen(
//               themeSetter: (t) => appThemeController.setTheme(t),
//             ),
//           ),
//
//           routes: {
//             '/conta_desativada': (_) => const ContaDesativadaScreen(),
//             '/login': (_) => const Loginscreen(),
//           },
//         );
//       },
//     );
//   }
// }
//
// // ====== (restante do arquivo permanece exatamente igual) ======
// class ContaDesativadaScreen extends StatefulWidget {
//   const ContaDesativadaScreen({super.key});
//   @override
//   State<ContaDesativadaScreen> createState() => _ContaDesativadaScreenState();
// }
//
// class _ContaDesativadaScreenState extends State<ContaDesativadaScreen> {
//   final String suporteWhatsapp =
//       'https://wa.me/244900000000?text=Ol%C3%A1!%20Preciso%20de%20ajuda%20com%20minha%20conta%20no%20Hin%C3%A1rio%20Digital%20Hosana.';
//   static const List<String> _adminsVitalicios = [
//     'admin@hpc.com',
//     'aguinaldo@igreja.org',
//   ];
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) return;
//       final email = (user.email ?? '').trim().toLowerCase();
//       if (_adminsVitalicios.contains(email)) {
//         if (!mounted) return;
//         Navigator.of(context).pop();
//         return;
//       }
//       try {
//         final doc = await FirebaseFirestore.instance
//             .collection('usuarios')
//             .doc(user.uid)
//             .get();
//         final role = (doc.data()?['role'] ?? '').toString().toLowerCase();
//         if (role == 'admin' && mounted) {
//           Navigator.of(context).pop();
//         }
//       } catch (_) {}
//     });
//   }
//
//   Future<void> _abrirWhatsapp() async {
//     final uri = Uri.parse(suporteWhatsapp);
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri, mode: LaunchMode.externalApplication);
//     } else {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Não foi possível abrir o WhatsApp.')),
//       );
//     }
//   }
//
//   Future<void> _requisitarAtivacao() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) return;
//     try {
//       await FirebaseFirestore.instance
//           .collection('usuarios')
//           .doc(user.uid)
//           .set({'requisitouAtivacao': true}, SetOptions(merge: true));
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Requisição de ativação enviada.')),
//       );
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Erro ao requisitar: $e')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Icon(Icons.lock_outline, size: 80, color: Colors.redAccent),
//               const SizedBox(height: 16),
//               const Text(
//                 'Sua conta foi desativada.',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.redAccent,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               const Text(
//                 'Entre em contato com o suporte ou solicite uma nova ativação.',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(color: Colors.black54),
//               ),
//               const SizedBox(height: 24),
//               ElevatedButton.icon(
//                 onPressed: _abrirWhatsapp,
//                 icon: const Icon(Icons.chat),
//                 label: const Text('Falar com o Suporte'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green,
//                   minimumSize: const Size(double.infinity, 48),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               ElevatedButton.icon(
//                 onPressed: _requisitarAtivacao,
//                 icon: const Icon(Icons.flash_on_outlined),
//                 label: const Text('Requisitar Ativação'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.deepOrange,
//                   minimumSize: const Size(double.infinity, 48),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton.icon(
//                 onPressed: () async {
//                   await FirebaseAuth.instance.signOut();
//                   if (!mounted) return;
//                   Navigator.pushNamedAndRemoveUntil(
//                     context,
//                     '/login',
//                         (_) => false,
//                   );
//                 },
//                 icon: const Icon(Icons.logout),
//                 label: const Text('Sair da Conta'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.redAccent,
//                   minimumSize: const Size(double.infinity, 48),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

/////////test //////////

// lib/main.dart
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'firebase_options.dart';

// telas / widgets do app
import 'screens/splash_screen.dart';
import 'screens/LoginScreen.dart';
import 'widgets/connectivity_gate.dart';

// tema / controllers
import 'theme/app_theme.dart';
import 'theme/app_theme_controller.dart';

// serviços locais
import 'services/hymn_local_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🌍 Locale + Intl
  final systemTag = ui.PlatformDispatcher.instance.locale.toLanguageTag();
  try {
    await initializeDateFormatting(systemTag);
  } catch (_) {}
  await initializeDateFormatting('pt_BR');

  // 🔥 Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 🔁 ATIVAR PERSISTÊNCIA OFFLINE DO FIRESTORE
  // Deve ser feito **após** Firebase.initializeApp e antes de qualquer uso intensivo do Firestore.
  try {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    debugPrint('Firestore persistence ativada (cache ilimitado).');
  } catch (e) {
    debugPrint('Falha ao ativar Firestore persistence: $e');
  }

  // 💾 Hive (serviço local de hinos)
  // Inicializa Hive/boxes antes do runApp para evitar delays na UI inicial.
  await Hive.initFlutter();
  final hymnLocal = HymnLocalService();
  await hymnLocal.init();

  runApp(const MyApp());
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
    _authStream = FirebaseAuth.instance.authStateChanges();
    _authStream.listen((user) async {
      if (user == null) return;
      try {
        final doc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .get();

        final themeStr = (doc.data()?['appTheme'] ?? 'deepOrange') as String;
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

      DateTime? trialEndsAt = (data?['trialEndsAt'] as Timestamp?)?.toDate();
      DateTime? activeFrom = (data?['activeFrom'] as Timestamp?)?.toDate();
      DateTime? activeUntil = (data?['activeUntil'] as Timestamp?)?.toDate();

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final bool isTrialActive =
          trialEndsAt != null && today.isBefore(trialEndsAt.add(const Duration(days: 1)));
      final bool isPaidActive = activeFrom != null &&
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
      animation: appThemeController,
      builder: (context, _) {
        final appTheme = appThemeController.current;
        return MaterialApp(
          title: 'Hinário Digital Hosana',
          debugShowCheckedModeBanner: false,
          theme: themeDataFor(appTheme),

          // ✅ Localizations — resolve AppBar/NavigationRail no mobile também
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

          // 🔒 Envolvemos o fluxo inicial com o ConnectivityGate:
          // O gate garante que o app só execute auto-login/listeners
          // quando houver internet real; caso contrário mostra tela pedindo reconexão.
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

// ====== (restante do arquivo permanece exatamente igual) ======
class ContaDesativadaScreen extends StatefulWidget {
  const ContaDesativadaScreen({super.key});
  @override
  State<ContaDesativadaScreen> createState() => _ContaDesativadaScreenState();
}

class _ContaDesativadaScreenState extends State<ContaDesativadaScreen> {
  final String suporteWhatsapp =
      'https://wa.me/244900000000?text=Ol%C3%A1!%20Preciso%20de%20ajuda%20com%20minha%20conta%20no%20Hin%C3%A1rio%20Digital%20Hosana.';
  static const List<String> _adminsVitalicios = [
    'admin@hpc.com',
    'aguinaldo@igreja.org',
  ];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final email = (user.email ?? '').trim().toLowerCase();
      if (_adminsVitalicios.contains(email)) {
        if (!mounted) return;
        Navigator.of(context).pop();
        return;
      }
      try {
        final doc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .get();
        final role = (doc.data()?['role'] ?? '').toString().toLowerCase();
        if (role == 'admin' && mounted) {
          Navigator.of(context).pop();
        }
      } catch (_) {}
    });
  }

  Future<void> _abrirWhatsapp() async {
    final uri = Uri.parse(suporteWhatsapp);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o WhatsApp.')),
      );
    }
  }

  Future<void> _requisitarAtivacao() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .set({'requisitouAtivacao': true}, SetOptions(merge: true));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Requisição de ativação enviada.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao requisitar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 80, color: Colors.redAccent),
              const SizedBox(height: 16),
              const Text(
                'Sua conta foi desativada.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Entre em contato com o suporte ou solicite uma nova ativação.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _abrirWhatsapp,
                icon: const Icon(Icons.chat),
                label: const Text('Falar com o Suporte'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _requisitarAtivacao,
                icon: const Icon(Icons.flash_on_outlined),
                label: const Text('Requisitar Ativação'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (!mounted) return;
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                        (_) => false,
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('Sair da Conta'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
