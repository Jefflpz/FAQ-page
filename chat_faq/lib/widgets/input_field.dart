import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final ValueChanged<String> onSubmitted;
  final bool isLoading;

  const InputField({
    super.key, 
    required this.onSubmitted,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: controller,
        enabled: !isLoading, // Desabilita durante o loading
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: isLoading ? "Processando..." : "Faça uma pergunta",
          hintStyle: const TextStyle(color: Colors.white),
          filled: true,
          fillColor: Colors.grey.withOpacity(0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 22),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: Transform.scale(
              scale: 1.1,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isLoading ? Colors.grey : const Color(0xFF6B21A8),
                ),
                child: isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.send, color: Colors.white, size: 22),
                        onPressed: () {
                          if (controller.text.isNotEmpty && !isLoading) {
                            onSubmitted(controller.text);
                            controller.clear();
                          }
                        },
                      ),
              ),
            ),
          ),
        ),
        onSubmitted: (value) {
          if (value.isNotEmpty && !isLoading) {
            onSubmitted(value);
            controller.clear();
          }
        },
      ),
    );
  }
}