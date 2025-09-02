import 'package:bible_chatbot/screens/history_chat_screen.dart';
import 'package:bible_chatbot/services/api_service.dart';
import 'package:bible_chatbot/widgets/stay_disconnected_popup.dart';
import 'package:flutter/material.dart';

class QuestionTile extends StatelessWidget {
  final String question;
  final String answer;

  const QuestionTile({
    super.key,
    required this.question,
    required this.answer,
  });

  void _handleTap(BuildContext context) {
    if (ApiService.isAuthenticated) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HistoryChatScreen(
            question: question,
            answer: answer,
          ),
        ),
      );
    } else {
      _showPopupIfNotAuthenticated(context);
    }
  }

  void _showPopupIfNotAuthenticated(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const StayDisconnectedPopup(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleTap(context),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          title: Text(
            question.length > 25 ? '${question.substring(0, 25)}...' : question,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
