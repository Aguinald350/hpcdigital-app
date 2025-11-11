import 'package:flutter/material.dart';
import '../screens/EventosScreen.dart';
import '../screens/Hinario_Screen.dart';
import '../screens/MoreScreen.dart';
import '../screens/Prefacio_Screen.dart';
import '../screens/churchScreen.dart';
import '/screens/HomeScreen.dart';

class Navegation_Screen extends StatefulWidget {
  const Navegation_Screen({super.key});

  @override
  State<Navegation_Screen> createState() => _Navegation_ScreenState();
}

class _Navegation_ScreenState extends State<Navegation_Screen> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() => _currentIndex = page);
  }

  void _navigationTapped(int page) {
    _pageController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // cores para estados
    final selectedColor = cs.onPrimary;
    final unselectedColor = cs.onPrimary.withOpacity(0.60);

    return Scaffold(
      // (opcional) se quiser destacar a barra superiormente com uma borda fina:
      // bottomNavigationBar: DecoratedBox(
      //   decoration: BoxDecoration(
      //     border: Border(top: BorderSide(color: cs.secondary.withOpacity(0.25))),
      //   ),
      //   child: _buildBottomBar(cs, selectedColor, unselectedColor),
      // ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: cs.primary,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,

        // Ícones e rótulos controlados por ColorScheme
        selectedItemColor: selectedColor,
        unselectedItemColor: unselectedColor,

        // (opcional) estilos de rótulo coerentes com o tema
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),

        // (opcional) tamanhos de ícone
        selectedIconTheme: const IconThemeData(size: 26),
        unselectedIconTheme: const IconThemeData(size: 24),

        onTap: (index) {
          setState(() => _currentIndex = index);
          _navigationTapped(index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Prefácio'),
          BottomNavigationBarItem(icon: Icon(Icons.music_note), label: 'Hinário'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Eventos'),
          BottomNavigationBarItem(icon: Icon(Icons.church), label: 'Minha Igreja'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'Mais'),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: const [
          Homescreen(),
          Prefacio_Screen(),
          Hinario_Screen(),
          EventosScreen(),
          ChurchScreen(),
          MoreScreen(),
        ],
      ),
    );
  }
}
