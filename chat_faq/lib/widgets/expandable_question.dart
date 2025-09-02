// widgets/expandable_question.dart
import 'package:flutter/material.dart';
import '../widgets/stay_disconnected_popup.dart';
import '../services/api_service.dart'; // Import ApiService para checar autenticação

class ExpandableQuestion extends StatefulWidget {
  final String question;
  final String answer;
  final VoidCallback? onAnyInteraction;

  const ExpandableQuestion({
    super.key,
    required this.question,
    required this.answer,
    this.onAnyInteraction,
  });

  @override
  State<ExpandableQuestion> createState() => _ExpandableQuestionState();
}

class _ExpandableQuestionState extends State<ExpandableQuestion> {
  bool _isExpanded = false;

  void _handleTap(BuildContext context) {
    // Dispara callback externa (se existir)
    widget.onAnyInteraction?.call();

    if (!ApiService.isAuthenticated) {
      // Se não estiver logado -> abre popup
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const StayDisconnectedPopup();
        },
      );
      return;
    }

    // Se estiver logado -> comportamento normal de expandir/colapsar
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleTap(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.question,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.white,
                ),
              ],
            ),
            if (_isExpanded) ...[
              const SizedBox(height: 12),
              Text(
                widget.answer,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
