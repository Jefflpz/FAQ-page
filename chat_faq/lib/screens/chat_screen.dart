import 'dart:ui';
import 'package:bible_chatbot/widgets/question_tile.dart';
import 'package:flutter/material.dart';
import '../widgets/chat_message.dart';
import '../widgets/input_field.dart';
import '../widgets/expandable_question.dart';
import '../services/api_service.dart';
import '../widgets/theme_feature_popup.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Map<String, String>> recentQuestions = [];
  List<Map<String, String>> chatMessages = [];
  Map<String, dynamic>? userData;
  bool _isLoading = false;
  bool _loadingUser = true;
  bool _loadingQuestions = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadRecentQuestions();
  }

  Future<void> _loadUserData() async {
    if (ApiService.isAuthenticated) {
      final resultado = await ApiService.getUsuario();
      if (resultado['success']) {
        setState(() {
          userData = resultado['user'];
          _loadingUser = false;
        });
      } else {
        setState(() => _loadingUser = false);
      }
    } else {
      setState(() => _loadingUser = false);
    }
  }

  Future<void> _loadRecentQuestions() async {
    if (ApiService.isAuthenticated) {
      final resultado = await ApiService.getPerguntasRecentes();
      if (resultado['success']) {
        setState(() {
          recentQuestions = List<Map<String, String>>.from(resultado['perguntas'] ?? []);
          _loadingQuestions = false;
        });
      } else {
        _loadDefaultQuestions();
      }
    } else {
      _loadDefaultQuestions();
    }
  }


  void _loadDefaultQuestions() {
    setState(() {
      recentQuestions = [
        {"question": "Qual o maior animal do mundo?", "answer": "O maior animal do mundo é a baleia azul."},
        {"question": "Como funciona a fotossíntese?", "answer": "A fotossíntese converte luz em energia química nas plantas."},
        {"question": "Quem inventou a lâmpada?", "answer": "Thomas Edison é conhecido por inventar a lâmpada incandescente."},
        {"question": "Por que o céu é azul?", "answer": "O céu é azul devido à dispersão da luz solar na atmosfera."},
      ];
      _loadingQuestions = false;
    });
  }

  void updateTopCard(String novaPergunta, String novaResposta) async {
    if (ApiService.isAuthenticated) {
      await ApiService.salvarPergunta({
        "question": novaPergunta,
        "answer": novaResposta,
      });

      await _loadRecentQuestions();
    } else {
      setState(() {
        if (recentQuestions.length == 4) {
          recentQuestions.removeAt(0); 
        }
        recentQuestions.add({
          "question": novaPergunta,
          "answer": novaResposta,
        });
      });
    }
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

  // Função para realizar logout
  Future<void> _performLogout() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ApiService.logout();
      
      if (result['success'] == true) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const ChatScreen()),
          (route) => false,
        );
      } else {
        await ApiService.logout(); // Acessando o método interno para limpeza
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const ChatScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      await ApiService.logout();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const ChatScreen()),
        (route) => false,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 54),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Builder(
                        builder: (context) => IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                      ),
                      Image.asset("assets/iconKairos.png", height: 36),
                      IconButton(
                        icon: const Icon(Icons.wb_sunny_outlined, color: Colors.white),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => const ThemeFeaturePopup(),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      children: [
                        if (_loadingQuestions)
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(color: Colors.white),
                          )
                        else
                          for (var item in recentQuestions)
                            ExpandableQuestion(
                              question: item["question"]!,
                              answer: item["answer"]!,
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

  Widget _buildBlurDrawer(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(16),
        bottomRight: Radius.circular(16),
      ),
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

                // 👤 Cabeçalho com usuário
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
                      children: [
                        Text(
                          _loadingUser
                              ? "Carregando..."
                              : userData?['nome'] ?? "Usuário",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _loadingUser
                              ? "carregando..."
                              : userData?['email'] ?? "E-mail não disponível",
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    )
                  ],
                ),

                const SizedBox(height: 20),

                // ➕ Nova conversa
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple[900]!.withOpacity(0.55),
                        blurRadius: 18,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple[300]!,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      setState(() {
                        chatMessages.clear();
                      });
                      Navigator.pop(context);
                    },
                    child: const Center(
                      child: Text("Nova conversa", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Center(
                  child: Text(
                    "Histórico de conversas",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),

                // 📜 Lista de perguntas (usa recentQuestions direto)
                Expanded(
                  child: _loadingQuestions
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : ListView.builder(
                          itemCount: recentQuestions.length,
                          itemBuilder: (context, index) {
                            final item = recentQuestions[index];
                            return QuestionTile(
                              question: item["question"]!,
                              answer: item["answer"]!,
                            );
                          },
                        ),
                ),

                // 🚪 Logout (só aparece se o usuário estiver logado)
                if (ApiService.isAuthenticated)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isLoading ? null : _performLogout,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : const Icon(Icons.logout, color: Colors.black),
                      label: _isLoading
                          ? const Text("Saindo...", style: TextStyle(color: Colors.black))
                          : const Text("Sair", style: TextStyle(color: Colors.black)),
                    ),
                  ),
               ],
            ),
          ),
        ),
      ),
    );
  }
}