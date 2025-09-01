import 'package:bible_chatbot/screens/splash_screen.dart';
import 'package:flutter/material.dart';
void main() {
  runApp(const ChatFAQ());
}

class ChatFAQ extends StatelessWidget {
  const ChatFAQ({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const SplashScreen(),
    );
  }
}
