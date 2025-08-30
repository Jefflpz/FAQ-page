import 'package:flutter/material.dart';
import '../widgets/chat_message.dart';
import '../widgets/input_field.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Map<String, String>> mockQuestions = [
    {
      "question": "Qual o maior animal do mundo?",
      "answer": "O maior animal do mundo é a baleia azul."
    },
    {
      "question": "Como funciona a fotossíntese?",
      "answer": "A fotossíntese converte luz em energia química nas plantas."
    },
    {
      "question": "Quem inventou a lâmpada?",
      "answer": "Thomas Edison é conhecido por inventar a lâmpada incandescente."
    },
    {
      "question": "Por que o céu é azul?",
      "answer": "O céu é azul devido à dispersão da luz solar na atmosfera."
    },
  ];

  List<Map<String, String>> chatMessages = [];

  void updateTopCard(String novaPergunta, String novaResposta) {
    setState(() {
      if (mockQuestions.length == 4) {
        mockQuestions.removeAt(0); // Remove o card mais antigo
        mockQuestions.add({
          "question": novaPergunta,
          "answer": novaResposta,
        }); // Adiciona novo no final
      }
    });
  }

  void _sendMessage(String text) {
    setState(() {
      String botReply = "API em desenvolvimento";

      chatMessages.add({
        "user": text,
        "bot": botReply,
      });

      updateTopCard(text, botReply);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      children: [
                        for (var item in mockQuestions)
                          ExpandableQuestion(
                            question: item["question"]!,
                            answer: item["answer"]!,
                          ),
                        const SizedBox(height: 12),
                        ...chatMessages.map((msg) => Column(
                              children: [
                                ChatMessage(text: msg["user"]!, isUser: true),
                                const SizedBox(height: 8),
                                ChatMessage(text: msg["bot"]!, isUser: false),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 17, bottom: 6),
                                    child: Text(
                                      "Perguntas frequentes atualizadas",
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                      ],
                    ),
                  ),
                ),
                InputField(
                  onSubmitted: (value) {
                    _sendMessage(value);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ExpandableQuestion extends StatefulWidget {
  final String question;
  final String answer;

  const ExpandableQuestion({
    super.key,
    required this.question,
    required this.answer,
  });

  @override
  State<ExpandableQuestion> createState() => _ExpandableQuestionState();
}

class _ExpandableQuestionState extends State<ExpandableQuestion>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  late final AnimationController _controller;
  late final Animation<Color?> _questionColor;
  late final Animation<double> _arrowRotation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _questionColor = ColorTween(begin: Colors.white, end: Colors.grey[500])
        .animate(_controller);
    _arrowRotation = Tween<double>(begin: 0, end: 0.5).animate(_controller);
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.purple[900]!.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: _isExpanded ? 8 : 0, horizontal: _isExpanded ? 12 : 20),
                        child: Text(
                          widget.question,
                          style: TextStyle(
                            fontSize: _isExpanded ? 16 : 16,
                            color: _questionColor.value,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Transform.rotate(
                      angle: _arrowRotation.value * 3.1415926 * 2,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Colors.white),
                        onPressed: _toggleExpand,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                );
              },
            ),
            if (_isExpanded)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 12, right: 12, bottom: 12),
                child: Text(
                  widget.answer,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
