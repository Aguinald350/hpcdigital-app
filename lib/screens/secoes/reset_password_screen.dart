import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResetPasswordScreen extends StatefulWidget {
  /// Caso você venha por deep link com o código, pode passar aqui.
  final String? initialCode;
  const ResetPasswordScreen({super.key, this.initialCode});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formPassKey = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();

  bool _loading = false;

  // Estados do fluxo
  bool _codeEmailSent = false;     // já enviou e-mail com código
  bool _codeValidated = false;     // código validado com sucesso
  String? _emailFromCode;          // e-mail retornado ao validar código

  @override
  void initState() {
    super.initState();
    if (widget.initialCode != null && widget.initialCode!.isNotEmpty) {
      _codeCtrl.text = widget.initialCode!;
      // pula direto para etapa de validação do código
      _codeEmailSent = true;
      _verificarCodigo();
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    _passCtrl.dispose();
    _pass2Ctrl.dispose();
    super.dispose();
  }

  // PASSO A) Enviar e-mail com link/código (oobCode)
  Future<void> _enviarCodigo() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      _toast('Informe o e-mail.');
      return;
    }
    setState(() => _loading = true);
    try {
      final auth = FirebaseAuth.instance;
      await auth.setLanguageCode('pt'); // PT/Portugal no template
      await auth.sendPasswordResetEmail(email: email);

      setState(() {
        _codeEmailSent = true;
      });
      _toast(
        'Se existir uma conta com este e-mail, você receberá um código/link para repor a palavra-passe.',
      );
    } on FirebaseAuthException catch (_) {
      // Mensagem neutra (não revelar se o e-mail existe)
      _toast(
        'Se existir uma conta com este e-mail, você receberá um código/link para repor a palavra-passe.',
      );
    } catch (_) {
      _toast('Não foi possível enviar agora. Tente mais tarde.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // PASSO B) Validar código (oobCode)
  Future<void> _verificarCodigo() async {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) {
      _toast('Digite o código recebido por e-mail.');
      return;
    }
    setState(() {
      _loading = true;
      _codeValidated = false;
      _emailFromCode = null;
    });
    try {
      final email = await FirebaseAuth.instance.verifyPasswordResetCode(code);
      setState(() {
        _emailFromCode = email;
        _codeValidated = true;
      });
      _toast('Código válido para: $email');
    } on FirebaseAuthException catch (e) {
      setState(() {
        _codeValidated = false;
        _emailFromCode = null;
      });
      _toast(_erroVerificar(e));
    } catch (_) {
      _toast('Não foi possível validar o código agora.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // PASSO C) Confirmar nova password
  Future<void> _confirmarNovaSenha() async {
    if (!_codeValidated) {
      _toast('Valide o código antes de atualizar a palavra-passe.');
      return;
    }
    if (!_formPassKey.currentState!.validate()) return;

    final code = _codeCtrl.text.trim();
    final pass = _passCtrl.text;
    setState(() => _loading = true);

    try {
      await FirebaseAuth.instance.confirmPasswordReset(
        code: code,
        newPassword: pass,
      );
      _toast('Palavra-passe atualizada! Faça login com a nova palavra-passe.');
      if (!mounted) return;
      Navigator.of(context).pop(); // volta para o login
    } on FirebaseAuthException catch (e) {
      _toast(_erroConfirmar(e));
    } catch (_) {
      _toast('Não foi possível repor a palavra-passe agora.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Helpers de erro
  String _erroVerificar(FirebaseAuthException e) {
    switch (e.code) {
      case 'expired-action-code':
        return 'O código expirou. Solicite um novo e-mail.';
      case 'invalid-action-code':
        return 'Código inválido. Verifique o e-mail e copie o código corretamente.';
      default:
        return 'Não foi possível validar o código agora.';
    }
  }

  String _erroConfirmar(FirebaseAuthException e) {
    switch (e.code) {
      case 'expired-action-code':
        return 'O código expirou. Solicite um novo e-mail.';
      case 'invalid-action-code':
        return 'Código inválido. Valide novamente o código.';
      case 'weak-password':
        return 'A palavra-passe é fraca. Use pelo menos 6 caracteres.';
      default:
        return 'Não foi possível repor a palavra-passe agora.';
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final disabled = _loading ? null : () {};

    return Scaffold(
      appBar: AppBar(title: const Text('Repor palavra-passe')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // PASSO A — E-mail
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('1) Confirmar e-mail',
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-mail da conta',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _loading ? null : _enviarCodigo,
                        icon: const Icon(Icons.email_outlined),
                        label: Text(_codeEmailSent
                            ? 'Reenviar código por e-mail'
                            : 'Enviar código por e-mail'),
                      ),
                    ),
                    if (_codeEmailSent)
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Text(
                          'Se existir uma conta com este e-mail, você receberá um link/código (oobCode).',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // PASSO B — Código
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('2) Validar código',
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _codeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Código recebido (oobCode)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _loading ? null : _verificarCodigo,
                        icon: const Icon(Icons.verified),
                        label: const Text('Validar código'),
                      ),
                    ),
                    if (_emailFromCode != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          'Código válido para: $_emailFromCode',
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // PASSO C — Nova password (só aparece após validar código)
            if (_codeValidated)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formPassKey,
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text('3) Definir nova palavra-passe',
                              style: Theme.of(context).textTheme.titleMedium),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Nova palavra-passe',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => (v == null || v.length < 6)
                              ? 'Mínimo 6 caracteres.'
                              : null,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _pass2Ctrl,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Confirmar nova palavra-passe',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                          (v != _passCtrl.text) ? 'As palavras-passe não coincidem.' : null,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _loading ? null : _confirmarNovaSenha,
                            icon: const Icon(Icons.lock_reset),
                            label: _loading
                                ? const Text('A atualizar...')
                                : const Text('Atualizar palavra-passe'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
