// lib/screens/RegisterScreen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'LoginScreen.dart';
import '../services/email_verification.dart'; // << ADICIONE
import 'verify_email_screen.dart';            // << ADICIONE

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _customOrganismoController = TextEditingController();
  final _customIgrejaController = TextEditingController();

  bool _loading = false;
  bool _loadingIgrejas = true;

  // 🔹 Listas dinâmicas
  List<String> _igrejas = [];
  String? _selectedIgreja;

  final List<String> _organismos = const [
    'Criança',
    'Jovem',
    'Jovem Adulto',
    'Organização dos Papas',
    'Organização das Mamas',
    'Outro',
  ];
  String? _selectedOrganismo;

  @override
  void initState() {
    super.initState();
    _carregarIgrejas();
  }

  /// 🔹 Carrega lista de igrejas do Firestore
  Future<void> _carregarIgrejas() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('igrejas').get();

      final nomes = snapshot.docs
          .map((doc) => (doc['nome'] ?? '').toString())
          .where((nome) => nome.isNotEmpty)
          .toList()
        ..sort((a, b) => a.compareTo(b));

      if (!nomes.contains('Outro')) nomes.add('Outro');

      setState(() {
        _igrejas = nomes;
        _loadingIgrejas = false;
      });
    } catch (e) {
      setState(() {
        _igrejas = const ['Outro'];
        _loadingIgrejas = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar igrejas: $e')),
      );
    }
  }

  /// 🔹 Registro + Firestore + envio de verificação + tela "verifique seu e-mail"
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    setState(() => _loading = true);

    try {
      // 1) Cria usuário e envia e-mail de verificação
      final cred = await registrarEnviarVerificacao(email: email, senha: password);
      final user = cred.user!;
      final uid = user.uid;

      // 2) Regras para admin (como você já tinha)
      final isAdmin = email == 'admin@hpc.com' || email == 'aguinaldo@igreja.org';

      // 3) Campos dependentes do formulário
      final organismoFinal = _selectedOrganismo == 'Outro'
          ? _customOrganismoController.text.trim()
          : _selectedOrganismo;

      final igrejaFinal = _selectedIgreja == 'Outro'
          ? _customIgrejaController.text.trim()
          : _selectedIgreja;

      // 4) Trial de 15 dias
      final trialEndsAt = Timestamp.fromDate(DateTime.now().add(const Duration(days: 15)));

      // 5) Atualiza displayName (opcional, mas útil)
      await user.updateDisplayName(name);

      // 6) Grava documento do usuário
      await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
        'uid': uid,
        'nome': name,
        'email': email,
        'telefone': '',
        'igreja': igrejaFinal,
        'organismo': organismoFinal,
        'role': isAdmin ? 'admin' : 'user',
        'createdAt': FieldValue.serverTimestamp(),
        'trialEndsAt': trialEndsAt,
        'activeFrom': null,
        'activeUntil': null,
        'requisitouAtivacao': false,
      });

      // 7) Feedback e ir para tela de verificação
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastro realizado! Verifique seu e-mail.')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const VerifiqueEmailScreen()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Erro ao cadastrar usuário')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro inesperado: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Cadastrar-se', style: TextStyle(color: Colors.deepOrange)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.deepOrange),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Nome
              TextFormField(
                controller: _nameController,
                decoration: _buildInputDecoration('Nome completo'),
                validator: (value) => value == null || value.isEmpty ? 'Informe seu nome completo' : null,
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: _buildInputDecoration('Email'),
                validator: (value) => value == null || value.isEmpty ? 'Informe seu email' : null,
              ),
              const SizedBox(height: 16),

              // Senha
              TextFormField(
                controller: _passwordController,
                decoration: _buildInputDecoration('Senha'),
                obscureText: true,
                validator: (value) => (value == null || value.length < 6)
                    ? 'A senha deve ter pelo menos 6 caracteres'
                    : null,
              ),
              const SizedBox(height: 16),

              // Confirmar senha
              TextFormField(
                controller: _confirmPasswordController,
                decoration: _buildInputDecoration('Confirmar senha'),
                obscureText: true,
                validator: (value) =>
                value != _passwordController.text ? 'As senhas não coincidem' : null,
              ),
              const SizedBox(height: 16),

              // 🔹 Igreja
              _loadingIgrejas
                  ? const Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(color: Colors.deepOrange),
              )
                  : DropdownButtonFormField<String>(
                value: _selectedIgreja,
                items: _igrejas
                    .map((igreja) => DropdownMenuItem(value: igreja, child: Text(igreja)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedIgreja = value),
                decoration: _buildInputDecoration('Distrito / Igreja'),
                validator: (value) {
                  if (value == null) return 'Selecione uma igreja';
                  if (value == 'Outro' && (_customIgrejaController.text.trim().isEmpty)) {
                    return 'Informe o nome do distrito/igreja';
                  }
                  return null;
                },
              ),

              if (_selectedIgreja == 'Outro') ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _customIgrejaController,
                  decoration: _buildInputDecoration('Digite o nome do distrito/igreja'),
                  validator: (value) {
                    if (_selectedIgreja == 'Outro' && (value == null || value.trim().isEmpty)) {
                      return 'Informe o nome do distrito/igreja';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 16),

              // 🔹 Organismo
              DropdownButtonFormField<String>(
                value: _selectedOrganismo,
                items: _organismos
                    .map((org) => DropdownMenuItem(value: org, child: Text(org)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedOrganismo = value),
                decoration: _buildInputDecoration('Ministério / Organismo'),
                validator: (value) {
                  if (value == null) return 'Selecione um ministério';
                  if (value == 'Outro' && (_customOrganismoController.text.trim().isEmpty)) {
                    return 'Informe o nome do organismo';
                  }
                  return null;
                },
              ),

              if (_selectedOrganismo == 'Outro') ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _customOrganismoController,
                  decoration: _buildInputDecoration('Digite o nome do organismo'),
                  validator: (value) {
                    if (_selectedOrganismo == 'Outro' && (value == null || value.trim().isEmpty)) {
                      return 'Informe o nome do organismo';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 24),

              _loading
                  ? const CircularProgressIndicator(color: Colors.deepOrange)
                  : ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Cadastrar',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),

              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const Loginscreen()),
                  );
                },
                child: const Text(
                  'Já tem uma conta? Fazer login',
                  style: TextStyle(color: Colors.deepOrange),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return const InputDecoration(
      labelText: '',
      labelStyle: TextStyle(color: Colors.grey),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.deepOrange),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.deepOrange, width: 2.5),
      ),
    ).copyWith(labelText: label);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _customOrganismoController.dispose();
    _customIgrejaController.dispose();
    super.dispose();
  }
}
