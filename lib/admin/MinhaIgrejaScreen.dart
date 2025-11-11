// lib/admin/MinhaIgrejaScreen.dart
import 'package:flutter/material.dart';

import 'CadastrarDistritoScreen.dart';
import 'CadastrarIgrejaScreen.dart';
import 'CadastrarIntendenciaScreen.dart';
import 'widgets/admin_shell.dart'; // 👈 usa o shell compartilhado

class MinhaIgrejaScreen extends StatelessWidget {
  const MinhaIgrejaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: 'Minha Igreja',
      currentIndex: 4, // índice do menu: Painel(0), Hinos(1), Cadastrar Evento(2), Ver Eventos(3), Minha Igreja(4)
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildButton(
                  context: context,
                  title: "Cadastrar Distrito",
                  icon: Icons.church,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CadastrarDistritoScreen()),
                    );
                  },
                ),
                const SizedBox(height: 20),
                _buildButton(
                  context: context,
                  title: "Cadastrar Intendência",
                  icon: Icons.location_city,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CadastrarIntendenciaScreen()),
                    );
                  },
                ),
                const SizedBox(height: 20),
                _buildButton(
                  context: context,
                  title: "Cadastrar Igreja",
                  icon: Icons.account_balance,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CadastrarIgrejaScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
        ),
        icon: Icon(icon, size: 28),
        label: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        onPressed: onTap,
      ),
    );
  }
}
