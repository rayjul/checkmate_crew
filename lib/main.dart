import 'package:flutter/material.dart';
import 'screens/main_menu_screen.dart';

void main() => runApp(const CheckmateCrewApp());

class CheckmateCrewApp extends StatelessWidget {
  const CheckmateCrewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Checkmate Crew',
      home: MainMenuScreen(),
    );
  }
}