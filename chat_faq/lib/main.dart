import 'package:flutter/material.dart';
import '../screens/chat_screen.dart';

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
      home: const ChatScreen(),
    );
  }
}
