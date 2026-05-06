import 'package:flutter/material.dart';
import 'screens/mural_screen.dart';

void main() {
  runApp(const MuralApp());
}

class MuralApp extends StatelessWidget {
  const MuralApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mural CAMDA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const MuralScreen(),
    );
  }
}
