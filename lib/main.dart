import 'package:flutter/material.dart';
import 'package:hpcdigital/screens/splash_screen.dart';
import 'package:hpcdigital/widgets/Navegation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HPCDIGITAL',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Roboto',
      ),
      home: splash_screen(),
    );
  }
}


