import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> messages = [];
  bool _isLoading = false;

  // Envia a mensagem do usuário e recebe a resposta do bot
  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final userMessage = _controller.text.trim();

    setState(() {
      messages.add(userMessage); // adiciona a mensagem do usuário
      _isLoading = true;        // inicia o loading
    });

    _controller.clear();

    // Chama a API
    final botResponse = await ApiService.sendMessage(userMessage);

    setState(() {
      messages.add(botResponse); // adiciona a resposta do bot
      _isLoading = false;        // termina o loading
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Mensagens ou tela inicial
            if (messages.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Bem-Vindo ao HEAVEN",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[300],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Tire todas suas dúvidas bíblicas aqui!",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[400],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Loading do bot
                    if (_isLoading && index == messages.length) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          ),
                        ),
                      );
                    }

                    final message = messages[index];
                    final isUserMessage = index % 2 == 0;
                    
                    return Align(
                      alignment: isUserMessage
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        padding: EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: isUserMessage
                              ? Colors.grey[850]
                              : Colors.grey[700],
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: !isUserMessage
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 6,
                                    offset: Offset(2, 2),
                                  ),
                                ]
                              : [],
                        ),
                        child: Text(
                          message,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ),
                    );

                  },
                ),
              ),

            // Campo de input com botão flutuante
            Padding(
              padding: EdgeInsets.all(12),
              child: Stack(
                children: [
                  TextField(
                    controller: _controller,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    minLines: 1,
                    maxLines: 5, // cresce se o usuário escrever muito
                    decoration: InputDecoration(
                      hintText: "Digite sua pergunta...",
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[900],
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 20, // altura maior
                        horizontal: 20,
                      ).copyWith(right: 60), // espaço extra p/ botão
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                  Positioned(
                    right: 6,
                    top: 6,
                    bottom: 6,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        shape: BoxShape.circle,
                      ), 
                      child: IconButton(
                        icon: Icon(Icons.send, color: Colors.white),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
