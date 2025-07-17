import 'package:flutter/material.dart';

class Prefacio_Screen extends StatefulWidget {
  const Prefacio_Screen({super.key});

  @override
  State<Prefacio_Screen> createState() => _Prefacio_ScreenState();
}

class _Prefacio_ScreenState extends State<Prefacio_Screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        elevation: 0,
        title: const Text("Prefacio", style: TextStyle(color: Colors.white),),
      ),
    );
  }
}
