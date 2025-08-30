import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final ValueChanged<String> onSubmitted;

  const InputField({super.key, required this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Faça uma pergunta",
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
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF6B21A8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white, size: 22,),
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
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
          if (value.isNotEmpty) {
            onSubmitted(value);
            controller.clear();
          }
        },
      ),
    );
  }
}
