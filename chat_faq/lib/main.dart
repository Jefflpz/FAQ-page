import 'package:bible_chatbot/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:bible_chatbot/services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.init();
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