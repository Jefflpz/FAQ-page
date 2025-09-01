import 'package:flutter/foundation.dart';
import '../utils/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;

  User? get user => _user;

  AuthProvider() {
    _authService.userStream.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<bool> cadastrar(String email, String senha) async {
    try {
      User? user = await _authService.cadastrarComEmailSenha(email, senha);
      return user != null;
    } catch (e) {
      return false;
    }
  }

  Future<bool> login(String email, String senha) async {
    try {
      User? user = await _authService.loginComEmailSenha(email, senha);
      return user != null;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
  }
}