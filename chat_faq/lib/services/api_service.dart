import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ApiService {
  static Future<String> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse("${Constants.backendUrl}/chat"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": message}),
      );

      if (response.statusCode == 200) {
        // Garante que está lidando com texto válido
        final body = response.body;

        // Tenta decodificar apenas se for JSON válido
        try {
          final data = jsonDecode(body);

          if (data is Map<String, dynamic> && data.containsKey("answer")) {
            return data["answer"] ?? "Resposta vazia do servidor.";
          } else if (data is String) {
            // Se a API retornar apenas uma String
            return data;
          } else {
            return "Resposta inesperada do servidor.";
          }
        } catch (e) {
          // Se não for JSON, retorna o texto cru
          return body;
        }
      } else {
        return "Erro ao conectar com o servidor (${response.statusCode})";
      }
    } catch (e) {
      return "Erro: não foi possível se conectar ao backend. Detalhe: $e";
    }
  }
}
