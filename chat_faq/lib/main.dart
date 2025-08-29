import 'package:flutter/material.dart';
import 'screens/chat_screen.dart'; 

void main() {
  runApp(const ChatFAQ());
}

class ChatFAQ extends StatelessWidget {
  const ChatFAQ({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HEAVEN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFBFA34F), 
        scaffoldBackgroundColor: const Color(0xFF1C1C1C), 
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF111111),
          titleTextStyle: TextStyle(
            color: Color(0xFFBFA34F),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFBFA34F),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2C2C2C),
          hintStyle: const TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const ChatScreen(),
    );
  }
}
