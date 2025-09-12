// import 'package:flutter/material.dart';
// import 'AdminVerHinosScreen.dart';
// import 'CadastrarEventoScreen.dart';
// import 'SelecionarLinguaScreen.dart'; // NOVO
//
// class AdminPanelScreen extends StatelessWidget {
//   const AdminPanelScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Painel do Administrador'),
//         backgroundColor: Colors.deepOrange,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(24),
//         child: GridView.count(
//           crossAxisCount: 2,
//           crossAxisSpacing: 16,
//           mainAxisSpacing: 16,
//           children: [
//             _buildMenuItem(
//               icon: Icons.library_music,
//               title: 'Cadastrar Hino',
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const SelecionarLinguaScreen()),
//                 );
//               },
//             ),
//             _buildMenuItem(
//               icon: Icons.music_note,
//               title: 'Ver Hinos',
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const AdminVerHinosScreen()),
//                 );
//               },
//             ),
//             _buildMenuItem(
//               icon: Icons.group,
//               title: 'Gerenciar Usuários',
//               onTap: () {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Em breve...')),
//                 );
//               },
//             ),
//             _buildMenuItem(
//               icon: Icons.settings,
//               title: 'Configurações',
//               onTap: () {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Em breve...')),
//                 );
//               },
//             ),
//             _buildMenuItem(
//               icon: Icons.event,
//               title: 'Eventos',
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const CadastrarEventoScreen()),
//                 );
//               },
//             ),
//
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildMenuItem({
//     required IconData icon,
//     required String title,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Card(
//         elevation: 4,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         child: Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(16),
//             color: Colors.orange.shade50,
//           ),
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(icon, size: 48, color: Colors.deepOrange),
//               const SizedBox(height: 12),
//               Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.deepOrange,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'AdminVerHinosScreen.dart';
import 'CadastrarEventoScreen.dart';
import 'EventosScreenAdmin.dart';
import 'MinhaIgrejaScreen.dart';
import 'SelecionarLinguaScreen.dart';


class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel do Administrador'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildMenuItem(
              icon: Icons.library_music,
              title: 'Cadastrar Hino',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SelecionarLinguaScreen()),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.music_note,
              title: 'Ver Hinos',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminVerHinosScreen()),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.group,
              title: 'Gerenciar Usuários',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Em breve...')),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.settings,
              title: 'Configurações',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Em breve...')),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.event,
              title: 'Cadastrar Evento',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CadastrarEventoScreen()),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.visibility,
              title: 'Ver Eventos', // ✅ Novo botão
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EventosScreenAdmin()),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.church,
              title: 'Minha Igreja',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MinhaIgrejaScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.orange.shade50,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.deepOrange),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
