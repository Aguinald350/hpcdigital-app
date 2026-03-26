// // lib/screens/conf/conf_screen.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
//
// import '../../services/session_manager.dart';
// import '../../theme/app_theme.dart';
// import '../../theme/app_theme_controller.dart';
// import '../LoginScreen.dart';
// import 'perfil_detalhado_screen.dart';
// import 'widgets/profile_card.dart';
// import 'widgets/tipos_conta.dart';
// import 'widgets/helpers.dart';
//
// class Conf_Screen extends StatefulWidget {
//   const Conf_Screen({
//     super.key,
//     this.onThemeChanged,
//     this.themeSetter,
//   });
//
//   final void Function(AppTheme t)? onThemeChanged;
//   final void Function(AppTheme t)? themeSetter;
//
//   @override
//   State<Conf_Screen> createState() => _Conf_ScreenState();
// }
//
// class _Conf_ScreenState extends State<Conf_Screen> {
//   final _auth = FirebaseAuth.instance;
//   bool _loggingOut = false; // <- evita toques repetidos
//
//   @override
//   Widget build(BuildContext context) {
//     final user = _auth.currentUser;
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('Configurações')),
//       body: user == null
//           ? const CenteredMsg('Nenhum usuário logado.')
//           : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
//         stream: FirebaseFirestore.instance
//             .collection('usuarios')
//             .doc(user.uid)
//             .snapshots(),
//         builder: (context, snap) {
//           if (snap.hasError) {
//             return ErrorStateWidget(
//               message:
//               'Não foi possível carregar as configurações.\n${snap.error}',
//               onRetry: () => setState(() {}),
//             );
//           }
//
//           if (snap.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (!snap.hasData) {
//             return const CenteredMsg('Sem dados do usuário.');
//           }
//
//           final doc = snap.data!;
//           if (!doc.exists) {
//             _ensureUserDoc();
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           final data = doc.data() ?? {};
//           final nome =
//           (data['nome'] ?? user.displayName ?? 'Usuário').toString();
//           final email = (data['email'] ?? user.email ?? '').toString();
//           final telefone = (data['telefone'] ?? '').toString();
//
//           final themeStr = (data['appTheme'] ?? 'deepOrange') as String;
//           final appTheme = appThemeFromString(themeStr);
//           final notif = (data['notificacoesHabilitadas'] ?? true) as bool;
//
//           final trialEndsAt = toDate(data['trialEndsAt']);
//           final activeFrom = toDate(data['activeFrom']);
//           final activeUntil = toDate(data['activeUntil']);
//           final tipo = accountType(trialEndsAt, activeFrom, activeUntil);
//
//           return ListView(
//             padding: const EdgeInsets.all(16),
//             children: [
//               sectionHeader(context, 'Perfil'),
//               const SizedBox(height: 8),
//               ProfileCard(
//                 nome: nome,
//                 email: email,
//                 telefone: telefone,
//                 statusText: tipo.label,
//                 statusColor: tipo.color,
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => PerfilDetalhadoScreen(
//                         uid: user.uid,
//                         nome: nome,
//                         email: email,
//                       ),
//                     ),
//                   );
//                 },
//               ),
//               const SizedBox(height: 20),
//
//               sectionHeader(context, 'Aparência'),
//               const SizedBox(height: 8),
//               Card(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: ListTile(
//                   leading: CircleAvatar(
//                     backgroundColor:
//                     Theme.of(context).colorScheme.secondaryContainer,
//                     child: Icon(
//                       Icons.color_lens,
//                       color: Theme.of(context).colorScheme.primary,
//                     ),
//                   ),
//                   title: const Text('Tema de cor'),
//                   subtitle: Text(appThemeLabel(appTheme)),
//                   trailing: const Icon(Icons.chevron_right),
//                   onTap: () => _selecaoTema(appTheme),
//                 ),
//               ),
//               const SizedBox(height: 20),
//
//               sectionHeader(context, 'Notificações'),
//               const SizedBox(height: 8),
//               Card(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: SwitchListTile(
//                   title: const Text('Ativar notificações'),
//                   secondary: CircleAvatar(
//                     backgroundColor:
//                     Theme.of(context).colorScheme.secondaryContainer,
//                     child: Icon(
//                       Icons.notifications_active_outlined,
//                       color: Theme.of(context).colorScheme.primary,
//                     ),
//                   ),
//                   value: notif,
//                   onChanged: (v) async {
//                     await _updateUser({'notificacoesHabilitadas': v});
//                   },
//                 ),
//               ),
//               const SizedBox(height: 30),
//
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton.icon(
//                   onPressed: _loggingOut ? null : _logout,
//                   icon: _loggingOut
//                       ? const SizedBox(
//                     width: 18,
//                     height: 18,
//                     child: CircularProgressIndicator(strokeWidth: 2),
//                   )
//                       : const Icon(Icons.logout),
//                   label: Text(_loggingOut ? 'Saindo...' : 'Sair da conta'),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   Future<void> _ensureUserDoc() async {
//     final user = _auth.currentUser;
//     if (user == null) return;
//     final ref =
//     FirebaseFirestore.instance.collection('usuarios').doc(user.uid);
//     await ref.set({
//       'nome': user.displayName ?? '',
//       'email': user.email ?? '',
//       'telefone': '',
//       'appTheme': 'deepOrange',
//       'notificacoesHabilitadas': true,
//       'updatedAt': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//   }
//
//   Future<void> _updateUser(Map<String, dynamic> data) async {
//     final uid = _auth.currentUser!.uid;
//     await FirebaseFirestore.instance
//         .collection('usuarios')
//         .doc(uid)
//         .set(data, SetOptions(merge: true));
//   }
//
//   Future<void> _selecaoTema(AppTheme atual) async {
//     final selecionado = await showModalBottomSheet<AppTheme>(
//       context: context,
//       showDragHandle: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (ctx) {
//         AppTheme? chosen = atual;
//         return StatefulBuilder(
//           builder: (ctx, setLocal) => Padding(
//             padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text('Selecionar tema',
//                     style: TextStyle(fontWeight: FontWeight.w800)),
//                 const SizedBox(height: 8),
//                 for (final theme in AppTheme.values)
//                   RadioListTile<AppTheme>(
//                     value: theme,
//                     groupValue: chosen,
//                     onChanged: (v) => setLocal(() => chosen = v),
//                     title: Text(appThemeLabel(theme)),
//                   ),
//                 const SizedBox(height: 12),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () => Navigator.pop(ctx, chosen),
//                     child: const Text('Aplicar'),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//
//     if (selecionado != null) {
//       await _updateUser({'appTheme': appThemeToString(selecionado)});
//       (widget.themeSetter ?? appThemeController.setTheme)(selecionado);
//       widget.onThemeChanged?.call(selecionado);
//     }
//   }
//
//   // --- NOVO: checagem rápida de conectividade
//   Future<bool> _isOnline() async {
//     final result = await Connectivity().checkConnectivity();
//     return result.contains(ConnectivityResult.mobile) ||
//         result.contains(ConnectivityResult.wifi) ||
//         result.contains(ConnectivityResult.ethernet) ||
//         result.contains(ConnectivityResult.vpn);
//   }
//
//   // --- NOVO: sheet com cartão quando offline
//   Future<void> _showOfflineSheet() async {
//     final cs = Theme.of(context).colorScheme;
//     await showModalBottomSheet(
//       context: context,
//       isScrollControlled: false,
//       showDragHandle: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (_) => Padding(
//         padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(Icons.wifi_off, size: 48, color: cs.error),
//             const SizedBox(height: 12),
//             Text(
//               'Impossível fazer logout',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w800,
//                 color: cs.onSurface,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Você está sem internet. Reconecte-se e toque novamente no botão para sair.',
//               textAlign: TextAlign.center,
//               style: TextStyle(color: cs.onSurfaceVariant),
//             ),
//             const SizedBox(height: 16),
//             SizedBox(
//               width: double.infinity,
//               child: OutlinedButton.icon(
//                 icon: const Icon(Icons.check),
//                 label: const Text('Entendi'),
//                 onPressed: () => Navigator.pop(context),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // dentro do Conf_Screen
//
//   Future<void> _logout() async {
//     // 1) Checa internet
//     final online = await _isOnline();
//     if (!online) {
//       await _showOfflineSheet();
//       return;
//     }
//
//     if (_loggingOut) return;
//     setState(() => _loggingOut = true);
//
//     final user = FirebaseAuth.instance.currentUser;
//
//     try {
//       if (user != null) {
//         // encerra sessão remota e local
//         await SessionManager.endSession(user.uid, clearRemote: true);
//         // signOut firebase
//         await FirebaseAuth.instance.signOut();
//       }
//
//       // 🔒 wipe de todo o estado local (prefs/hive/caches)
//       await SessionManager.wipeLocalData();
//
//       if (!mounted) return;
//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(builder: (_) => const Loginscreen()),
//             (_) => false,
//       );
//     } catch (e) {
//       debugPrint('Erro ao sair: $e');
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Erro ao sair: $e')),
//       );
//     } finally {
//       if (mounted) setState(() => _loggingOut = false);
//     }
//   }
//
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../services/session_manager.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_theme_controller.dart';
import '../LoginScreen.dart';
import 'app_preferences_controller.dart';
import 'perfil_detalhado_screen.dart';
import 'widgets/profile_card.dart';
import 'widgets/tipos_conta.dart';
import 'widgets/helpers.dart';

class Conf_Screen extends StatefulWidget {
  const Conf_Screen({
    super.key,
    this.onThemeChanged,
    this.themeSetter,
  });

  final void Function(AppTheme t)? onThemeChanged;
  final void Function(AppTheme t)? themeSetter;

  @override
  State<Conf_Screen> createState() => _Conf_ScreenState();
}

class _Conf_ScreenState extends State<Conf_Screen> {
  final _auth = FirebaseAuth.instance;
  bool _loggingOut = false;

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: user == null
          ? const CenteredMsg('Nenhum usuário logado.')
          : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return ErrorStateWidget(
              message:
              'Não foi possível carregar as configurações.\n${snap.error}',
              onRetry: () => setState(() {}),
            );
          }

          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snap.hasData) {
            return const CenteredMsg('Sem dados do usuário.');
          }

          final doc = snap.data!;
          if (!doc.exists) {
            _ensureUserDoc();
            return const Center(child: CircularProgressIndicator());
          }

          final data = doc.data() ?? {};
          final nome =
          (data['nome'] ?? user.displayName ?? 'Usuário').toString();
          final email =
          (data['email'] ?? user.email ?? '').toString();
          final telefone = (data['telefone'] ?? '').toString();

          final themeStr =
          (data['appTheme'] ?? 'deepOrange') as String;
          final appTheme = appThemeFromString(themeStr);
          final notif =
          (data['notificacoesHabilitadas'] ?? true) as bool;

          final trialEndsAt = toDate(data['trialEndsAt']);
          final activeFrom = toDate(data['activeFrom']);
          final activeUntil = toDate(data['activeUntil']);
          final tipo =
          accountType(trialEndsAt, activeFrom, activeUntil);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [

              /// PERFIL
              sectionHeader(context, 'Perfil'),
              const SizedBox(height: 8),
              ProfileCard(
                nome: nome,
                email: email,
                telefone: telefone,
                statusText: tipo.label,
                statusColor: tipo.color,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PerfilDetalhadoScreen(
                        uid: user.uid,
                        nome: nome,
                        email: email,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              /// APARÊNCIA
              sectionHeader(context, 'Aparência'),
              const SizedBox(height: 8),

              // 🎨 Tema de cor
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .secondaryContainer,
                    child: Icon(
                      Icons.color_lens,
                      color:
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: const Text('Tema de cor'),
                  subtitle: Text(appThemeLabel(appTheme)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _selecaoTema(appTheme),
                ),
              ),

              const SizedBox(height: 12),

              // 🌙 Dark Mode
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.dark_mode),
                  title: const Text('Modo de exibição'),
                  subtitle: Text(_themeModeLabel()),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _selecionarModoExibicao,
                ),
              ),

              const SizedBox(height: 20),

              /// NOTIFICAÇÕES
              sectionHeader(context, 'Notificações'),
              const SizedBox(height: 8),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SwitchListTile(
                  title: const Text('Ativar notificações'),
                  secondary: CircleAvatar(
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .secondaryContainer,
                    child: Icon(
                      Icons.notifications_active_outlined,
                      color: Theme.of(context)
                          .colorScheme
                          .primary,
                    ),
                  ),
                  value: notif,
                  onChanged: (v) async {
                    await _updateUser(
                        {'notificacoesHabilitadas': v});
                  },
                ),
              ),

              const SizedBox(height: 30),

              /// LOGOUT
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed:
                  _loggingOut ? null : _logout,
                  icon: _loggingOut
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2),
                  )
                      : const Icon(Icons.logout),
                  label: Text(
                      _loggingOut ? 'Saindo...' : 'Sair da conta'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// ======================
  /// DARK MODE
  /// ======================

  String _themeModeLabel() {
    switch (preferencesController.themeMode) {
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.dark:
        return 'Escuro';
      case ThemeMode.system:
        return 'Automático';
    }
  }

  Future<void> _selecionarModoExibicao() async {
    final selecionado =
    await showModalBottomSheet<ThemeMode>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Claro'),
              onTap: () =>
                  Navigator.pop(ctx, ThemeMode.light),
            ),
            ListTile(
              title: const Text('Escuro'),
              onTap: () =>
                  Navigator.pop(ctx, ThemeMode.dark),
            ),
            ListTile(
              title: const Text('Automático'),
              onTap: () =>
                  Navigator.pop(ctx, ThemeMode.system),
            ),
            const SizedBox(height: 12),
          ],
        );
      },
    );

    if (selecionado != null) {
      await preferencesController
          .setThemeMode(selecionado);
      if (mounted) setState(() {});
    }
  }

  /// ======================
  /// FIRESTORE HELPERS
  /// ======================

  Future<void> _ensureUserDoc() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final ref = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid);
    await ref.set({
      'nome': user.displayName ?? '',
      'email': user.email ?? '',
      'telefone': '',
      'appTheme': 'deepOrange',
      'notificacoesHabilitadas': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _updateUser(
      Map<String, dynamic> data) async {
    final uid = _auth.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .set(data, SetOptions(merge: true));
  }

  Future<void> _selecaoTema(AppTheme atual) async {
    final selecionado =
    await showModalBottomSheet<AppTheme>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        AppTheme? chosen = atual;
        return StatefulBuilder(
          builder: (ctx, setLocal) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final theme in AppTheme.values)
                RadioListTile<AppTheme>(
                  value: theme,
                  groupValue: chosen,
                  onChanged: (v) =>
                      setLocal(() => chosen = v),
                  title: Text(appThemeLabel(theme)),
                ),
              ElevatedButton(
                onPressed: () =>
                    Navigator.pop(ctx, chosen),
                child: const Text('Aplicar'),
              ),
            ],
          ),
        );
      },
    );

    if (selecionado != null) {
      await _updateUser({
        'appTheme':
        appThemeToString(selecionado)
      });
      (widget.themeSetter ??
          appThemeController.setTheme)(
          selecionado);
    }
  }

  /// ======================
  /// LOGOUT
  /// ======================

  Future<bool> _isOnline() async {
    final result =
    await Connectivity().checkConnectivity();
    return result.contains(
        ConnectivityResult.mobile) ||
        result.contains(
            ConnectivityResult.wifi);
  }

  Future<void> _logout() async {
    final online = await _isOnline();
    if (!online) return;

    if (_loggingOut) return;
    setState(() => _loggingOut = true);

    try {
      final user =
          FirebaseAuth.instance.currentUser;
      if (user != null) {
        await SessionManager.endSession(
            user.uid,
            clearRemote: true);
        await FirebaseAuth.instance.signOut();
      }

      await SessionManager.wipeLocalData();

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (_) =>
            const Loginscreen()),
            (_) => false,
      );
    } finally {
      if (mounted)
        setState(() => _loggingOut = false);
    }
  }
}

