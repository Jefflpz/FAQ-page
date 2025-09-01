import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'chat_screen.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _nameError = false;
  bool _emailError = false;
  bool _passwordError = false;
  bool _confirmPasswordError = false;
  bool _isLoading = false;

  String _errorMessage = '';

  void _validateAndRegister() async {
    setState(() {
      _nameError = _nameController.text.isEmpty;
      _emailError = _emailController.text.isEmpty;
      _passwordError = _passwordController.text.isEmpty;
      _confirmPasswordError =
          _confirmPasswordController.text != _passwordController.text;
      _errorMessage = '';
    });

    if (!_nameError && !_emailError && !_passwordError && !_confirmPasswordError) {
      setState(() {
        _isLoading = true;
      });

      final registerResult = await ApiService.cadastrarUsuario(
        email: _emailController.text,
        senha: _passwordController.text,
        nome: _nameController.text,
      );

      if (registerResult['success'] == true) {
        final loginResult = await ApiService.login(
          email: _emailController.text,
          senha: _passwordController.text,
        );

        setState(() {
          _isLoading = false;
        });

        if (loginResult['success'] == true) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ChatScreen()),
          );
        } else {
          setState(() {
            _errorMessage = 'Cadastro realizado! Faça login para continuar.';
          });
          
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = registerResult['message'] ?? 'Erro ao realizar cadastro';
        });
      }
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
                const SizedBox(height: 20),

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
                  "Criar conta",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Preencha os dados abaixo para registrar-se",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                
                const SizedBox(height: 24),

                if (_nameError)
                  const Text("Digite seu nome",
                      style: TextStyle(color: Colors.red, fontSize: 12)),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: "Digite seu nome completo",
                    hintStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.black54,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: _nameError ? Colors.red : Colors.white70),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: _nameError ? Colors.red : Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),

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
                ),
                const SizedBox(height: 16),

                if (_confirmPasswordError)
                  const Text("As senhas não coincidem",
                      style: TextStyle(color: Colors.red, fontSize: 12)),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Confirme sua senha",
                    hintStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.black54,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: _confirmPasswordError ? Colors.red : Colors.white70),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: _confirmPasswordError ? Colors.red : Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: _isLoading ? null : _validateAndRegister,
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
                      : const Text("Registrar",
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Já tem conta?",
                        style: TextStyle(color: Colors.white)),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                        );
                      },
                      child: const Text("Entrar",
                          style: TextStyle(
                              color: Color(0xFFB57BFF),
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}