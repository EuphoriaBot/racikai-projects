import 'package:flutter/material.dart';

import 'screens/main_screen.dart';

void main() {
  runApp(const RacikAIApp());
}

class RacikAIApp extends StatelessWidget {
  const RacikAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RacikAI',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFFBF7),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE8752E),
          brightness: Brightness.light,
        ),
      ),
      home: const MainScreen(),
    );
  }
}
