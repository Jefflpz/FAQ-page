import 'package:flutter/material.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _emailError = false;
  bool _passwordError = false;
  bool _confirmPasswordError = false;

  void _validateAndRegister() {
    setState(() {
      _emailError = _emailController.text.isEmpty;
      _passwordError = _passwordController.text.isEmpty;
      _confirmPasswordError =
          _confirmPasswordController.text != _passwordController.text;
    });

    if (!_emailError && !_passwordError && !_confirmPasswordError) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: const BoxConstraints.expand(), // fundo ocupa tela inteira
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

                // LOGO
                Padding(
                  padding: const EdgeInsets.only(left: 4), // <-- controla a distância da borda
                  child: Image.asset(
                    "assets/iconEntrada.png",
                    width: 60,
                    height: 60,
                  ),
                ),

                const SizedBox(height: 4),

                // TÍTULO
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
                const SizedBox(height: 40),

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
                  onPressed: _validateAndRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB57BFF),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text("Registrar",
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
