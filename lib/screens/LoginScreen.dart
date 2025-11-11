// lib/screens/LoginScreen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hpcdigital/screens/secoes/reset_password_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

import '../admin/AdminPanelScreen.dart';
import '../widgets/Navegation.dart';
import 'RegisterScreen.dart';

// ✅ Sessão única (claimOrStart + SessionInUseException + heartbeat + listener)
import '../services/session_manager.dart';

// ✅ Firestore Retry utilitário (criar arquivo lib/services/firestore_retry.dart)
import '../services/firestore_retry.dart';

// ✅ verificação de e-mail
import 'verify_email_screen.dart';

/// 🔒 Tela de conta desativada / expirada
class ContaDesativadaScreen extends StatefulWidget {
  const ContaDesativadaScreen({super.key});

  @override
  State<ContaDesativadaScreen> createState() => _ContaDesativadaScreenState();
}

class _ContaDesativadaScreenState extends State<ContaDesativadaScreen> {
  String? _nomeUsuario;
  String? _dataExpiracaoTexto;
  String? _telefone; // se tiver salvo no doc do usuário

  // número do suporte (sem "+")
  static const String _whatsSuporte = '244925780193';

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
  }

  Future<void> _carregarDadosUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();
      final data = doc.data();
      final nome = (data?['nome'] ?? '').toString().trim();
      final trialEndsAt = (data?['trialEndsAt'] as Timestamp?)?.toDate();
      final activeUntil = (data?['activeUntil'] as Timestamp?)?.toDate();
      _telefone = (data?['telefone'] ?? '').toString().trim();

      String? dataFim;
      final exp = activeUntil ?? trialEndsAt;
      if (exp != null) {
        dataFim =
        "${exp.day.toString().padLeft(2, '0')}/${exp.month.toString().padLeft(2, '0')}/${exp.year}";
      }

      if (!mounted) return;
      setState(() {
        _nomeUsuario = nome.isNotEmpty ? nome : user.email;
        _dataExpiracaoTexto =
        dataFim != null ? 'Período encerrado em $dataFim' : null;
      });
    } catch (e) {
      debugPrint('Erro ao carregar dados: $e');
    }
  }

  Future<void> _abrirWhatsappSuporte() async {
    final user = FirebaseAuth.instance.currentUser;
    final nome = _nomeUsuario ?? user?.email ?? 'usuário';
    final email = user?.email ?? '-';
    final uid = user?.uid ?? '-';
    final exp = _dataExpiracaoTexto ?? '-';
    final tel = (_telefone?.isNotEmpty == true) ? _telefone! : '-';

    final msg = [
      'Saudações 👋',
      'Minha conta está desativada/expirada e preciso de ajuda.',
      '— Nome: $nome',
      '— Email: $email',
      '— UID: $uid',
      '— Telefone: $tel',
      '— Status: $exp',
    ].join('\n');

    // 1) tentar abrir app do WhatsApp
    final uriApp = Uri.parse(
        'whatsapp://send?phone=$_whatsSuporte&text=${Uri.encodeComponent(msg)}');
    try {
      final ok = await launchUrl(uriApp, mode: LaunchMode.externalApplication);
      if (ok) return;
    } catch (_) {}

    // 2) fallback via wa.me
    final uriWaMe =
    Uri.parse('https://wa.me/$_whatsSuporte?text=${Uri.encodeComponent(msg)}');
    try {
      final ok = await launchUrl(uriWaMe, mode: LaunchMode.externalApplication);
      if (ok) return;
    } catch (_) {}

    // 3) último recurso: folha com opções
    if (!mounted) return;
    _showWhatsappHelpSheet(_whatsSuporte, msg);
  }

  void _showWhatsappHelpSheet(String telefone, String msg) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.support_agent, size: 32),
              const SizedBox(height: 8),
              const Text('Abrir WhatsApp',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 8),
              Text(
                'Não consegui abrir o WhatsApp automaticamente. Toque em uma das opções abaixo:',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black.withOpacity(.7)),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () async {
                  final uri = Uri.parse(
                      'https://wa.me/$telefone?text=${Uri.encodeComponent(msg)}');
                  Navigator.of(context).pop();
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text('Abrir via wa.me'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: telefone));
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content:
                      Text('Telefone copiado. Abra o WhatsApp e cole na busca.'),
                    ),
                  );
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copiar telefone do suporte'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final nome = _nomeUsuario ?? 'usuário';
    final dataInfo = _dataExpiracaoTexto != null ? '\n$_dataExpiracaoTexto' : '';

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
                'Conta Desativada',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Sua conta foi desativada, $nome.\n\n'
                    'Entre em contato com o suporte para reativação.$dataInfo',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54, fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _abrirWhatsappSuporte,
                icon: const Icon(Icons.chat),
                label: const Text('Falar com o Suporte'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (!mounted) return;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const Loginscreen()),
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

/// 🔸 Tela de Login principal
class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _loading = false;
  bool _checkingSession = true;
  bool _obscurePassword = true;

  /// Lista de administradores vitalícios
  static const List<String> _adminsVitalicios = [
    'admin@hpc.com',
    'aguinaldo@igreja.org',
  ];

  @override
  void initState() {
    super.initState();

    // Configurações do Firestore: ativa persistência e cache ilimitado
    try {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        host: 'firestore.googleapis.com',
        sslEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      debugPrint('Firestore settings applied: persistenceEnabled + unlimited cache');
    } catch (e) {
      debugPrint('Erro ao aplicar Firestore settings: $e');
    }

    _tryAutoLogin();
  }

  /// Auto-login com ordem correta:
  /// 1) claimOrStart
  /// 2) startHeartbeat
  /// 3) startListeningToUserDoc
  /// 4) _checkUserAccess → navega
  Future<void> _tryAutoLogin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _checkingSession = false);
      return;
    }

    // refresh do user
    try {
      await user.reload();
    } catch (e) {
      debugPrint('Warning: user.reload() failed: $e');
    }

    final refreshed = FirebaseAuth.instance.currentUser;

    final emailLower = refreshed?.email?.toLowerCase().trim() ?? '';
    final isAdminEmail = _adminsVitalicios.contains(emailLower);

    if (!isAdminEmail && !(refreshed?.emailVerified ?? false)) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const VerifiqueEmailScreen()),
      );
      return;
    }

    try {
      // Sessão única: claimOrStart, heartbeat e listener
      await SessionManager.claimOrStart(user.uid);
      SessionManager.startHeartbeat(user.uid);

      SessionManager.startListeningToUserDoc(
        uid: user.uid,
        onSessionMismatch: (remoteId) async {
          if (!mounted) return;
          final escolha = await showDialog<_SessionChoice>(
            context: context,
            barrierDismissible: false,
            builder: (_) => _SessionConflictDialog(),
          );

          if (escolha == _SessionChoice.signOut) {
            await FirebaseAuth.instance.signOut();
            await SessionManager.endSession(user.uid, clearRemote: false);
            SessionManager.stopListening();
            if (!mounted) return;
            setState(() => _checkingSession = false);
          } else if (escolha == _SessionChoice.reclaim) {
            await SessionManager.reclaimSession(user.uid);
          }
        },
      );

      // Depois de tudo, verifica acesso com retry
      await _checkUserAccess(user);
    } on SessionInUseException {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text('Conta em uso'),
          content: Text(
            'Este usuário já está conectado em outro dispositivo. '
                'Finalize a sessão lá ou tente novamente mais tarde.',
          ),
        ),
      );
      setState(() => _checkingSession = false);
    } catch (e) {
      debugPrint('Auto-login falhou: $e');
      setState(() => _checkingSession = false);
    }
  }

  /// 🔹 Verifica status de acesso e navega (usa retry para o documento do usuário)
  Future<void> _checkUserAccess(User user) async {
    final email = user.email?.toLowerCase().trim() ?? '';

    // admins vitalícios
    if (_adminsVitalicios.contains(email)) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminPanelScreen()),
      );
      return;
    }

    final userRef = FirebaseFirestore.instance.collection('usuarios').doc(user.uid);

    // tenta com retry
    final snap = await FirestoreRetry.getDocWithRetry(ref: userRef, maxAttempts: 4);

    if (snap == null || !snap.exists) {
      // pergunta ao usuário se quer tentar outra vez
      if (!mounted) return;
      final retry = await FirestoreRetry.showRetryDialog(context,
          message:
          'Erro ao inicializar usuário: não foi possível contactar o Firestore.\nVerifique sua conexão e tente novamente.');
      if (retry) {
        return _checkUserAccess(user); // tentar novamente
      } else {
        // fallback: desloga e mostra mensagem
        try {
          await FirebaseAuth.instance.signOut();
        } catch (_) {}
        if (!mounted) return;
        setState(() => _checkingSession = false);
        _showMessage('Operação cancelada. Verifique sua internet e tente novamente.');
        return;
      }
    }

    final data = snap.data() ?? {};
    final role = (data['role'] ?? 'user').toString().toLowerCase();

    // Data / trial checks
    final trialEndsAt = (data['trialEndsAt'] as Timestamp?)?.toDate();
    final activeFrom = (data['activeFrom'] as Timestamp?)?.toDate();
    final activeUntil = (data['activeUntil'] as Timestamp?)?.toDate();

    final now = DateTime.now();

    final bool isTrialActive =
        trialEndsAt != null && now.isBefore(trialEndsAt.add(const Duration(days: 1)));
    final bool isPaidActive = activeFrom != null &&
        activeUntil != null &&
        now.isAfter(activeFrom) &&
        now.isBefore(activeUntil);

    if (!isTrialActive && !isPaidActive) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ContaDesativadaScreen()),
      );
      return;
    }

    if (role == 'admin') {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminPanelScreen()),
      );
    } else {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Navegation_Screen()),
      );
    }
  }

  /// 🔹 Login manual com ordem correta e retry na leitura do doc do usuário
  Future<void> _login() async {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Por favor, preencha todos os campos');
      return;
    }

    setState(() => _loading = true);

    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      final user = credential.user;

      if (user != null) {
        await user.reload();
        final refreshed = FirebaseAuth.instance.currentUser;

        final emailLower = refreshed?.email?.toLowerCase().trim() ?? '';
        final isAdminEmail = _adminsVitalicios.contains(emailLower);

        if (!isAdminEmail && !(refreshed?.emailVerified ?? false)) {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const VerifiqueEmailScreen()),
          );
          return;
        }

        // ✅ Ordem exata da sessão
        try {
          await SessionManager.claimOrStart(user.uid);
          SessionManager.startHeartbeat(user.uid);
        } on SessionInUseException {
          await FirebaseAuth.instance.signOut();
          if (context.mounted) {
            await showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Conta em uso'),
                content: const Text(
                  'Este usuário já está conectado em outro dispositivo. '
                      'Finalize a sessão lá ou tente novamente mais tarde.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  )
                ],
              ),
            );
          }
          if (mounted) setState(() => _loading = false);
          return;
        }

        // Listener que detecta mismatch de sessão
        SessionManager.startListeningToUserDoc(
          uid: user.uid,
          onSessionMismatch: (firestoreSessionId) async {
            if (!mounted) return;
            final escolha = await showDialog<_SessionChoice>(
              context: context,
              barrierDismissible: false,
              builder: (_) => _SessionConflictDialog(),
            );

            if (escolha == _SessionChoice.signOut) {
              await FirebaseAuth.instance.signOut();
              await SessionManager.endSession(user.uid, clearRemote: false);
              SessionManager.stopListening();
            } else if (escolha == _SessionChoice.reclaim) {
              await SessionManager.reclaimSession(user.uid);
            }
          },
        );

        // verifica e navega (com retry integrado no _checkUserAccess)
        await _checkUserAccess(user);
      }
    } on FirebaseAuthException catch (e) {
      String message = switch (e.code) {
        'user-not-found' => 'Usuário não encontrado.',
        'wrong-password' => 'Senha incorreta.',
        'invalid-email' => 'Email inválido.',
        _ => 'Erro ao fazer login.',
      };
      _showMessage(message);
    } catch (e) {
      debugPrint('Erro inesperado no login: $e');
      _showMessage('Erro inesperado. Tente novamente mais tarde.');
    }

    if (mounted) setState(() => _loading = false);
  }

  // ✅ Recuperação de senha com confirmação por e-mail (abre a tela dedicada)
  void _openResetPasswordScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingSession) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: Colors.deepOrange)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Image.asset('images/icon.png', width: 290, height: 290),
                const SizedBox(height: 10),
                const Text(
                  'HOSANA PROJECTO CRISTÃO',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 30),

                // Email
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _buildInputDecoration('Email'),
                ),
                const SizedBox(height: 16),

                // Senha
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: _buildInputDecoration('Senha').copyWith(
                    suffixIcon: IconButton(
                      tooltip: _obscurePassword ? 'Mostrar senha' : 'Ocultar senha',
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.deepOrange,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                ),

                // 🔗 Esqueceu a senha?
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _openResetPasswordScreen,
                    child: const Text('Esqueceu a senha? Repor palavra-passe'),
                  ),
                ),

                const SizedBox(height: 8),
                _loading
                    ? const CircularProgressIndicator(color: Colors.deepOrange)
                    : ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.deepOrange,
                  ),
                  child: const Text(
                    'Entrar',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  child: const Text(
                    'Não tem conta? Cadastrar-se',
                    style: TextStyle(color: Colors.deepOrange),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.deepOrange),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.deepOrange, width: 2.5),
      ),
    );
  }
}

/// 🔘 opções do diálogo de conflito de sessão
enum _SessionChoice { signOut, reclaim }

/// 🧩 Diálogo exibido quando detectamos login em outro dispositivo
class _SessionConflictDialog extends StatelessWidget {
  const _SessionConflictDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sessão em outro dispositivo'),
      content: const Text(
        'Detectamos um login em outro dispositivo. '
            'Você deseja sair deste dispositivo ou manter a sessão aqui?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(_SessionChoice.reclaim),
          child: const Text('Manter aqui (reclamar)'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
          onPressed: () => Navigator.of(context).pop(_SessionChoice.signOut),
          child: const Text('Sair deste dispositivo'),
        ),
      ],
    );
  }
}
