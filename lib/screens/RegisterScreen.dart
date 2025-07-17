import 'package:flutter/material.dart';
import 'LoginScreen.dart';

class RegisterScreen extends StatefulWidget {
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


  void _register() {
    if (_formKey.currentState!.validate()) {
      // Simula sucesso de cadastro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cadastro realizado com sucesso!')),
      );

      // Redireciona para a tela de login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Loginscreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Cadastrar-se',
          style: TextStyle(color: Colors.deepOrange),
        ),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nome completo',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.deepOrange),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.deepOrange, width: 4),
                  )
                ),
                validator: (value) =>
                value!.isEmpty ? 'Informe seu nome completo' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.deepOrange),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.deepOrange, width: 4),
                    )
                ),
                validator: (value) =>
                value!.isEmpty ? 'Informe seu email' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.deepOrange),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.deepOrange, width: 4),
                    )
                ),
                obscureText: true,
                validator: (value) => value!.length < 6
                    ? 'A senha deve ter pelo menos 6 caracteres'
                    : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirmar senha',
                  labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.deepOrange),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.deepOrange, width: 4),
                    )
                ),
                obscureText: true,
                validator: (value) =>
                value != _passwordController.text ? 'As senhas não coincidem' : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedIgreja,
                items: _igrejas
                    .map((igreja) =>
                    DropdownMenuItem(value: igreja, child: Text(igreja)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedIgreja = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Distrito',
                  labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.deepOrange),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.deepOrange, width: 4),
                    )
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedOrganismo,
                items: _organismos
                    .map((org) => DropdownMenuItem(
                  value: org,
                  child: Text(org),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedOrganismo = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Ministério ou Organismos',
                  labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.deepOrange),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.deepOrange, width: 4),
                    )
                ),
                validator: (value) =>
                value == null ? 'Selecione uma associação ou organismo' : null,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _register,
                child: Text(
                  'Cadastrar',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
              SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => Loginscreen()),
                  );
                },
                child: Text('Já tem uma conta? Fazer login',
                style: TextStyle(color: Colors.deepOrange),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
