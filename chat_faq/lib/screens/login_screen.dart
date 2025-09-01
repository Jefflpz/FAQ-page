import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../widgets/reset_password_popup.dart';
import 'register_screen.dart';
import 'chat_screen.dart';
import '../services/api_service.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _emailError = false;
  bool _passwordError = false;
  bool _isLoading = false;
  String _errorMessage = '';

  void _validateAndLogin() async {
    setState(() {
      _emailError = _emailController.text.isEmpty;
      _passwordError = _passwordController.text.isEmpty;
      _errorMessage = '';
    });

    if (_emailError || _passwordError) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ApiService.login(
        email: _emailController.text.trim(),
        senha: _passwordController.text,
      );

      if (result['success'] == true) {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ChatScreen()),
        );
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Erro ao fazer login';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro de conexão: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Image.asset(
                    "assets/iconEntrada.png",
                    width: 60,
                    height: 60,
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  "Seja bem vindo ao Kairo's",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Faça login ou registre-se para acompanhar as perguntas frequentes",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 40),

                if (_errorMessage.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (_errorMessage.isNotEmpty) const SizedBox(height: 16),

                if (_emailError)
                  const Text("Digite seu email",
                      style: TextStyle(color: Colors.red, fontSize: 12)),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: "Digite seu email",
                    hintStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.black54,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: _emailError ? Colors.red : Colors.white70),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: _emailError ? Colors.red : Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                if (_passwordError)
                  const Text("Digite sua senha",
                      style: TextStyle(color: Colors.red, fontSize: 12)),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Digite sua senha",
                    hintStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.black54,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: _passwordError ? Colors.red : Colors.white70),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: _passwordError ? Colors.red : Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onSubmitted: (_) => _validateAndLogin(),
                ),
                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.centerRight,
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 14),
                      children: [
                        const TextSpan(
                          text: "Esqueceu a senha? ",
                          style: TextStyle(color: Colors.white),
                        ),
                        TextSpan(
                          text: "Clique aqui",
                          style: const TextStyle(color: Color(0xFFB57BFF)),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              showDialog(
                                context: context,
                                builder: (context) => ResetPasswordPopup(),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: _isLoading ? null : _validateAndLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB57BFF),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text("Entrar",
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Não tem conta?",
                        style: TextStyle(color: Colors.white)),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: _isLoading
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const RegisterScreen()),
                              );
                            },
                      child: const Text("Criar conta",
                          style: TextStyle(
                              color: Color(0xFFB57BFF),
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // BOTÃO GOOGLE
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () {
                            // ação login Google
                          },
                    icon: Image.asset("assets/google_logo.png",
                        height: 24, width: 24),
                    label: const Text("Google",
                        style: TextStyle(color: Colors.black, fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      minimumSize: const Size(120, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 6,
                    ),
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