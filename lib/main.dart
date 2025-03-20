import 'package:flutter/material.dart';
import 'package:offline_speech_app/UI/splash_screen.dart';

void main() {
  runApp(const SpeakEasyApp());
}

// ---------------------- APP ENTRY ----------------------

class SpeakEasyApp extends StatelessWidget {
  const SpeakEasyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SpeakEasy',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        brightness: Brightness.light,
      ),
      home: const SplashScreen(),
    );
  }
}
