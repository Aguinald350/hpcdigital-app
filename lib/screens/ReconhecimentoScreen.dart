import 'package:flutter/material.dart';

class ReconhecimentoScreen extends StatefulWidget {
  const ReconhecimentoScreen({super.key});

  @override
  State<ReconhecimentoScreen> createState() => _ReconhecimentoScreenState();
}

class _ReconhecimentoScreenState extends State<ReconhecimentoScreen> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        elevation: 0,
        title: const Text("Reconhecimento", style: TextStyle(color: Colors.white),),
      ),
    );
  }
}
