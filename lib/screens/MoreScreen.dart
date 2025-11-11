import 'package:flutter/material.dart';

import 'conf/Conf_Screen.dart';
import 'PrivacyScreen.dart';
import 'ReconhecimentoScreen.dart';
import 'infoScreen.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() => _currentIndex = page);
  }

  void _navigationTapped(int page) => _pageController.jumpToPage(page);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: cs.primary,                 // era: Colors.deepOrange
        selectedItemColor: cs.onPrimary,             // texto/ícone selecionado
        unselectedItemColor: cs.onPrimary.withOpacity(0.7),
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          _navigationTapped(index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Informação',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Reconhecimento',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configurações',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.privacy_tip),
            label: 'Privacidade',
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: const [
          // use const quando possível
          infoScreen(),
          ReconhecimentoScreen(),
          Conf_Screen(),
          PrivacyPolicyScreen(),
        ],
      ),
    );
  }
}
