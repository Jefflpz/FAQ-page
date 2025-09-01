import 'package:flutter/material.dart';
import '../screens/chat_screen.dart';

class SuccessPopup extends StatelessWidget {
  /// Callback opcional para o botão "Vamos lá".
  /// Se for nulo, o popup navega para ChatScreen por padrão.
  final VoidCallback? onPressed;

  const SuccessPopup({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900]!.withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Sucesso",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Conta registrada com sucesso.\nAproveite para fazer sua primeira pergunta",
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onPressed ??
                () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const ChatScreen()),
                  );
                },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB57BFF),
              minimumSize: const Size(double.infinity, 40),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text("Vamos lá", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
