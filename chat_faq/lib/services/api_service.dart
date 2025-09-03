import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ApiService {
  static String? _token;
  static Map<String, dynamic>? _currentUser;

  // Inicializa dados salvos (chamar no main.dart antes do runApp)
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    final userString = prefs.getString('current_user');
    if (userString != null) {
      _currentUser = jsonDecode(userString);
    }
  }

  static String? get token => _token;
  static Map<String, dynamic>? get currentUser => _currentUser;
  static bool get isAuthenticated => _token != null && _currentUser != null;

  static Future<void> _saveAuthData(String token, Map<String, dynamic> user) async {
    _token = token;
    _currentUser = user;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('current_user', jsonEncode(user));
  }

  static Future<void> _clearAuthData() async {
    _token = null;
    _currentUser = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('current_user');
  }

  static Map<String, String> get _headers {
    final headers = {"Content-Type": "application/json"};
    if (_token != null) {
      headers["Authorization"] = "Bearer $_token";
    }
    return headers;
  }

  // CADASTRO DE USUÁRIO
  static Future<Map<String, dynamic>> cadastrarUsuario({
    required String email,
    required String senha,
    required String nome,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("${Constants.backendUrl}/cadastro"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "senha": senha,
          "nome": nome,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'user': data['user'],
          'message': 'Usuário cadastrado com sucesso',
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Erro no cadastro',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão: $e',
      };
    }
  }

  // LOGIN
  static Future<Map<String, dynamic>> login({
    required String email,
    required String senha,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("${Constants.backendUrl}/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "senha": senha,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final String token = data['token'] ?? data['access_token'] ?? '';
        final user = data['user'] ?? {};

        if (token.isEmpty) {
          return {
            'success': false,
            'message': 'Token não retornado pelo servidor',
          };
        }

        await _saveAuthData(token, Map<String, dynamic>.from(user));

        return {
          'success': true,
          'token': token,
          'user': user,
          'message': 'Login realizado com sucesso',
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Erro no login',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão: $e',
      };
    }
  }

  // LOGOUT
  static Future<Map<String, dynamic>> logout() async {
    try {
      final response = await http.post(
        Uri.parse("${Constants.backendUrl}/logout"),
        headers: _headers,
      );

      await _clearAuthData();

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Logout realizado com sucesso'};
      } else {
        return {'success': false, 'message': 'Erro no logout'};
      }
    } catch (e) {
      await _clearAuthData();
      return {'success': false, 'message': 'Erro de conexão: $e'};
    }
  }

  // SOLICITAR REDEFINIÇÃO DE SENHA
  static Future<Map<String, dynamic>> solicitarRedefinicaoSenha(String email) async {
    try {
      final response = await http.post(
        Uri.parse("${Constants.backendUrl}/solicitar-redefinicao-senha"),
        headers: {"Content-Type": "application/json"}, // 🔹 sem Authorization
        body: jsonEncode({"email": email}),
      );

      final data = jsonDecode(response.body);
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? 'Erro ao solicitar redefinição',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão: $e',
      };
    }
  }

  // REDEFINIR SENHA
  static Future<Map<String, dynamic>> redefinirSenha({
    required String token,
    required String novaSenha,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("${Constants.backendUrl}/redefinir-senha"),
        headers: {"Content-Type": "application/json"}, // 🔹 sem Authorization
        body: jsonEncode({
          "token": token,
          "novaSenha": novaSenha,
        }),
      );

      final data = jsonDecode(response.body);
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? 'Erro ao redefinir senha',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão: $e',
      };
    }
  }

  // ENVIAR MENSAGEM/PERGUNTA
  static Future<Map<String, dynamic>> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse("${Constants.backendUrl}/pergunta"),
        headers: _headers,
        body: jsonEncode({"pergunta": message}),
      );

      if (response.statusCode == 200) {
        final body = response.body;

        try {
          final data = jsonDecode(body);

          // Formato novo
          if (data is Map<String, dynamic>) {
            if (data.containsKey('success') && data.containsKey('answer')) {
              final bool success = data['success'] ?? false;
              final String answer = data['answer'] ?? '';

              if (answer.contains(':')) {
                final parts = answer.split(':');
                final pergunta = parts[0];
                final resposta = parts.sublist(1).join(':');

                return {
                  'pergunta': pergunta,
                  'resposta': resposta,
                  'status': success ? 'success' : 'error',
                  'success': success,
                  'message': data['message'] ?? '',
                };
              } else {
                return {
                  'pergunta': message,
                  'resposta': answer,
                  'status': success ? 'success' : 'error',
                  'success': success,
                  'message': data['message'] ?? '',
                };
              }
            }
          }

          // Formato antigo
          if (data is Map<String, dynamic> && data.containsKey("answer")) {
            final String answer = data["answer"] ?? "";

            if (answer.contains(':')) {
              final parts = answer.split(':');
              final pergunta = parts[0];
              final resposta = parts.sublist(1).join(':');

              return {
                'pergunta': pergunta,
                'resposta': resposta,
                'status': 'success',
                'success': true,
              };
            } else {
              return {
                'pergunta': message,
                'resposta': answer,
                'status': 'success',
                'success': true,
              };
            }
          } else if (data is String) {
            if (data.contains(':')) {
              final parts = data.split(':');
              final pergunta = parts[0];
              final resposta = parts.sublist(1).join(':');

              return {
                'pergunta': pergunta,
                'resposta': resposta,
                'status': 'success',
                'success': true,
              };
            } else {
              return {
                'pergunta': message,
                'resposta': data,
                'status': 'success',
                'success': true,
              };
            }
          } else {
            return {
              'pergunta': message,
              'resposta': 'Resposta inesperada do servidor.',
              'status': 'error',
              'success': false,
            };
          }
        } catch (e) {
          if (body.contains(':')) {
            final parts = body.split(':');
            final pergunta = parts[0];
            final resposta = parts.sublist(1).join(':');

            return {
              'pergunta': pergunta,
              'resposta': resposta,
              'status': 'success',
              'success': true,
            };
          } else {
            return {
              'pergunta': message,
              'resposta': body,
              'status': 'success',
              'success': true,
            };
          }
        }
      } else {
        return {
          'pergunta': message,
          'resposta': 'Erro ao conectar com o servidor (${response.statusCode})',
          'status': 'error',
          'success': false,
        };
      }
    } catch (e) {
      return {
        'pergunta': message,
        'resposta': 'Erro: não foi possível se conectar ao backend. Detalhe: $e',
        'status': 'error',
        'success': false,
      };
    }
  }

  // VERIFICAR TOKEN
  static Future<bool> verificarToken() async {
    if (_token == null) return false;
    try {
      final response = await http.get(
        Uri.parse("${Constants.backendUrl}/usuario"),
        headers: _headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // OBTER DADOS DO USUÁRIO
  static Future<Map<String, dynamic>> getUsuario() async {
    try {
      final response = await http.get(
        Uri.parse("${Constants.backendUrl}/usuario"),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'message': 'Erro ao buscar dados do usuário',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão: $e',
      };
    }
  }

  // OBTER PERGUNTAS RECENTES
  static Future<Map<String, dynamic>> getPerguntasRecentes() async {
    try {
      final response = await http.get(
        Uri.parse("${Constants.backendUrl}/perguntas-recentes"),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'perguntas': List<Map<String, String>>.from(
            data['perguntas']?.map((p) => {
              'question': p['pergunta'] ?? '',
              'answer': p['resposta'] ?? ''
            }) ?? [],
          ),
        };
      } else {
        return {
          'success': false,
          'message': 'Erro ao buscar perguntas',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão: $e',
      };
    }
  }

  // OBTER TODAS AS PERGUNTAS
  static Future<Map<String, dynamic>> getTodasPerguntas() async {
    try {
      final response = await http.get(
        Uri.parse("${Constants.backendUrl}/todas-perguntas"),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'perguntas': List<Map<String, dynamic>>.from(
            data['perguntas']?.map((p) => {
              'question': p['pergunta'] ?? '',
              'answer': p['resposta'] ?? '',
              'data': p['data_pergunta'] ?? '',
            }) ?? [],
          ),
        };
      } else {
        return {
          'success': false,
          'message': 'Erro ao buscar histórico',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão: $e',
      };
    }
  }

  // SALVAR PERGUNTA
  static Future<Map<String, dynamic>> salvarPergunta(Map<String, String> pergunta) async {
    try {
      final response = await http.post(
        Uri.parse("${Constants.backendUrl}/salvar-pergunta"),
        headers: _headers,
        body: jsonEncode(pergunta),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Pergunta salva com sucesso'};
      } else {
        return {'success': false, 'message': 'Erro ao salvar pergunta'};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão: $e',
      };
    }
  }
}
