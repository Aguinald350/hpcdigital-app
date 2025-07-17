import 'package:flutter/material.dart';

class churchScreen extends StatefulWidget {
  const churchScreen({super.key});

  @override
  State<churchScreen> createState() => _churchScreenState();
}

class _churchScreenState extends State<churchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        elevation: 0,
        title: const Text("Minha Igreja", style: TextStyle(color: Colors.white),),
      ),
    );
  }
}
