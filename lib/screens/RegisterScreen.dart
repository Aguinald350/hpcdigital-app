import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'LoginScreen.dart';

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

  String? _selectedIgreja;
  final List<String> _igrejas = [
    'Igreja Central de Luanda',
    'Igreja do Cazenga',
    'Igreja de Calemba',
    'Igreja da Luz'
  ];

  String? _selectedOrganismo;
  final List<String> _organismos = [
    'Criança',
    'Jovem',
    'Jovem Adulto',
    'Organização dos Papas',
    'Organização das Mamas',
  ];

  bool _loading = false;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final name = _nameController.text.trim();

      setState(() => _loading = true);

      try {
        // Cria o usuário no Firebase Auth
        final credential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        final uid = credential.user!.uid;

        // Verifica se o email é de um admin
        final isAdmin = email == 'admin@hpc.com' || email == 'aguinaldo@igreja.org';

        // Salva dados no Firestore
        await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
          'uid': uid,
          'nome': name,
          'email': email,
          'igreja': _selectedIgreja,
          'organismo': _selectedOrganismo,
          'role': isAdmin ? 'admin' : 'user',
          'createdAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cadastro realizado com sucesso!')),
        );

        await Future.delayed(const Duration(seconds: 2));

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Loginscreen()),
        );
      } on FirebaseAuthException catch (e) {
        String msg = e.message ?? 'Erro ao cadastrar';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro inesperado: $e')),
        );
      }

      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              TextFormField(
                controller: _nameController,
                decoration: _buildInputDecoration('Nome completo'),
                validator: (value) =>
                value!.isEmpty ? 'Informe seu nome completo' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: _buildInputDecoration('Email'),
                validator: (value) =>
                value!.isEmpty ? 'Informe seu email' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: _buildInputDecoration('Senha'),
                obscureText: true,
                validator: (value) => value!.length < 6
                    ? 'A senha deve ter pelo menos 6 caracteres'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: _buildInputDecoration('Confirmar senha'),
                obscureText: true,
                validator: (value) => value != _passwordController.text
                    ? 'As senhas não coincidem'
                    : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedIgreja,
                items: _igrejas
                    .map((igreja) =>
                    DropdownMenuItem(value: igreja, child: Text(igreja)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedIgreja = value),
                decoration: _buildInputDecoration('Distrito'),
                validator: (value) =>
                value == null ? 'Selecione uma igreja/distrito' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedOrganismo,
                items: _organismos
                    .map((org) =>
                    DropdownMenuItem(value: org, child: Text(org)))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedOrganismo = value),
                decoration: _buildInputDecoration('Ministério ou Organismos'),
                validator: (value) => value == null
                    ? 'Selecione uma associação ou organismo'
                    : null,
              ),
              const SizedBox(height: 24),
              _loading
                  ? const CircularProgressIndicator()
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
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.deepOrange),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.deepOrange, width: 3),
      ),
    );
  }
}
