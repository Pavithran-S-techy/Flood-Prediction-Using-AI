import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const FloodAiApp());
}

class FloodAiApp extends StatelessWidget {
  const FloodAiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FloodAi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}