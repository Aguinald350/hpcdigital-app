import 'package:flutter/material.dart';
import '../screens/EventosScreen.dart';
import '../screens/Hinario_Screen.dart';
import '../screens/MoreScreen.dart';
import '../screens/Prefacio_Screen.dart';
import '../screens/churchScreen.dart';
import '../screens/infoScreen.dart';
import '/screens/HomeScreen.dart';

class Navegation_Screen extends StatefulWidget {
  const Navegation_Screen({super.key});

  @override
  State<Navegation_Screen> createState() => _Navegation_ScreenState();
}

int _currentIndex = 0;
class _Navegation_ScreenState extends State<Navegation_Screen> {
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      _currentIndex = page;
    });
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.deepOrange,
       //backgroundColor: const Color(0xFF071013),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black54,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            navigationTapped(index);
          });
        },
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Prefacio'),
          const BottomNavigationBarItem(icon: Icon(Icons.music_note), label: 'Hinário'),
          const BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Eventos'),
          const BottomNavigationBarItem(icon: Icon(Icons.church), label: 'Minha Igreja'),
          const BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'Mais'),


        ],
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: onPageChanged,
        children: [
          Homescreen(),
          Prefacio_Screen(),
          Hinario_Screen(),
          EventosScreen(),
          churchScreen(),
          MoreScreen(),
        ],
      ),
    );
  }
}
