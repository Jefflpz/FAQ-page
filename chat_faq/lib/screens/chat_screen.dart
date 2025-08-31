import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/chat_message.dart';
import '../widgets/input_field.dart';
import '../widgets/expandable_question.dart';
import '../services/api_service.dart';
import 'history_chat_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Map<String, String>> mockQuestions = [
    {"question": "Qual o maior animal do mundo?", "answer": "O maior animal do mundo é a baleia azul."},
    {"question": "Como funciona a fotossíntese?", "answer": "A fotossíntese converte luz em energia química nas plantas."},
    {"question": "Quem inventou a lâmpada?", "answer": "Thomas Edison é conhecido por inventar a lâmpada incandescente."},
    {"question": "Por que o céu é azul?", "answer": "O céu é azul devido à dispersão da luz solar na atmosfera."},
  ];

  List<Map<String, String>> chatMessages = [];
  bool _isLoading = false;

  void updateTopCard(String novaPergunta, String novaResposta) {
    setState(() {
      if (mockQuestions.length == 4) {
        mockQuestions.removeAt(0);
        mockQuestions.add({"question": novaPergunta, "answer": novaResposta});
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    setState(() {
      _isLoading = true;
      chatMessages.add({"user": text, "bot": "Processando..."});
    });

    try {
      final resultado = await ApiService.sendMessage(text);
      setState(() {
        chatMessages.removeLast();
        if (resultado['status'] == 'success') {
          chatMessages.add({"user": text, "bot": resultado['resposta']!});
          updateTopCard(resultado['pergunta']!, resultado['resposta']!);
        } else {
          chatMessages.add({"user": text, "bot": "Erro: ${resultado['resposta']}"});
        }
      });
    } catch (e) {
      setState(() {
        chatMessages.removeLast();
        chatMessages.add({"user": text, "bot": "Erro de conexão: $e"});
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      drawer: _buildBlurDrawer(context),
      body: Stack(
        children: [
          // 🔹 Fundo
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
                // 🔹 Topo custom (menu, logo, sol)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // menu
                      Builder(
                        builder: (context) => IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                      ),
                      // logo centralizada
                      Image.asset(
                        "assets/iconKairos.png",
                        height: 36,
                      ),
                      // sol
                      IconButton(
                        icon: const Icon(Icons.wb_sunny_outlined, color: Colors.white),
                        onPressed: () {
                          // futuramente toggle tema
                        },
                      ),
                    ],
                  ),
                ),

                // 🔹 Cards + chat
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      children: [
                        for (var item in mockQuestions)
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => HistoryChatScreen(
                                    question: item["question"]!,
                                    answer: item["answer"]!,
                                  ),
                                ),
                              );
                            },
                            child: ExpandableQuestion(
                              question: item["question"]!,
                              answer: item["answer"]!,
                            ),
                          ),
                        const SizedBox(height: 12),
                        ...chatMessages.map((msg) => Column(
                              children: [
                                ChatMessage(text: msg["user"]!, isUser: true),
                                const SizedBox(height: 8),
                                ChatMessage(
                                  text: msg["bot"]!,
                                  isUser: false,
                                  isLoading: msg["bot"] == "Processando...",
                                ),
                              ],
                            )),
                      ],
                    ),
                  ),
                ),

                // 🔹 Campo de input
                InputField(
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty && !_isLoading) _sendMessage(value.trim());
                  },
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Drawer com blur
  Widget _buildBlurDrawer(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(topRight: Radius.circular(16), bottomRight: Radius.circular(16)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Drawer(
          backgroundColor: Colors.grey.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.deepPurple,
                      child: Icon(Icons.person, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Jefferson Lopes",
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("jeffcustodio@gmail.com", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 20),
                // Glow do botão
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.purple, blurRadius: 18, spreadRadius: 2)],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple[300]!,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      setState(() {
                        chatMessages.clear();
                      });
                      Navigator.pop(context);
                    },
                    child: const Center(child: Text("Nova conversa", style: TextStyle(color: Colors.white))),
                  ),
                ),
                const SizedBox(height: 20),
                const Text("Histórico de conversas", style: TextStyle(color: Colors.white, fontSize: 14)),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: mockQuestions.length,
                    itemBuilder: (context, index) {
                      final item = mockQuestions[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HistoryChatScreen(
                                question: item["question"]!,
                                answer: item["answer"]!,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            title: Text(
                              item["question"]!.length > 25
                                  ? '${item["question"]!.substring(0, 25)}...'
                                  : item["question"]!,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Botão sair
                Align(
                  alignment: Alignment.bottomLeft,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.logout, color: Colors.black),
                    label: const Text("Sair", style: TextStyle(color: Colors.black)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
