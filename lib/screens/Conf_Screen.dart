import 'package:flutter/material.dart';

class Conf_Screen extends StatefulWidget {
  const Conf_Screen({super.key});

  @override
  State<Conf_Screen> createState() => _Conf_ScreenState();
}

class _Conf_ScreenState extends State<Conf_Screen> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        elevation: 0,
        title: const Text("Configuracoes", style: TextStyle(color: Colors.white),),
      ),
    );
  }
}
