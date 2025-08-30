import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ApiService {
  static Future<Map<String, String>> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse("${Constants.backendUrl}/pergunta"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"pergunta": message}),
      );

      if (response.statusCode == 200) {
        final body = response.body;

        try {
          final data = jsonDecode(body);

          if (data is Map<String, dynamic> && data.containsKey("answer")) {
            final String answer = data["answer"] ?? "";

            if (answer.contains(':')) {
              final parts = answer.split(':');
              final pergunta = parts[0];
              final resposta = parts.sublist(1).join(':');

              return {
                'pergunta': pergunta,
                'resposta': resposta,
                'status': 'success'
              };
            } else {
              return {
                'pergunta': message,
                'resposta': answer,
                'status': 'success'
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
                'status': 'success'
              };
            } else {
              return {
                'pergunta': message,
                'resposta': data,
                'status': 'success'
              };
            }
          } else {
            return {
              'pergunta': message,
              'resposta': 'Resposta inesperada do servidor.',
              'status': 'error'
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
              'status': 'success'
            };
          } else {
            return {
              'pergunta': message,
              'resposta': body,
              'status': 'success'
            };
          }
        }
      } else {
        return {
          'pergunta': message,
          'resposta': 'Erro ao conectar com o servidor (${response.statusCode})',
          'status': 'error'
        };
      }
    } catch (e) {
      return {
        'pergunta': message,
        'resposta': 'Erro: não foi possível se conectar ao backend. Detalhe: $e',
        'status': 'error'
      };
    }
  }
}