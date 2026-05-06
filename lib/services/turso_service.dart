import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/recado.dart';

class TursoService {
  static Future<Map<String, String>> _headers() async {
    final token = await AppConfig.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<String> _baseUrl() async {
    var url = (await AppConfig.getUrl()).trim().replaceAll(RegExp(r'/+$'), '');
    if (url.startsWith('libsql://')) {
      url = 'https://${url.substring(9)}';
    }
    return '$url/v2/pipeline';
  }

  /// Executa uma ou mais queries em pipeline
  static Future<List<Map<String, dynamic>>> _pipeline(
    List<Map<String, dynamic>> statements,
  ) async {
    final url = await _baseUrl();
    final headers = await _headers();

    final requests = [
      ...statements.map((s) => {'type': 'execute', 'stmt': s}),
      {'type': 'close'},
    ];

    final response = await http
        .post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode({'requests': requests}),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Turso error ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = (data['results'] as List).cast<Map<String, dynamic>>();
    return results;
  }

  /// Converte resultado Turso em lista de linhas como List<dynamic>
  static List<List<dynamic>> _parseRows(Map<String, dynamic> result) {
    if (result['type'] != 'ok') {
      final err = result['error'];
      throw Exception('SQL error: $err');
    }
    final response = result['response'] as Map<String, dynamic>;
    final resultSet = response['result'] as Map<String, dynamic>;
    final rows = (resultSet['rows'] as List).cast<List<dynamic>>();
    return rows.map((row) {
      return row.map((cell) {
        if (cell == null) return null;
        final m = cell as Map<String, dynamic>;
        return m['value'];
      }).toList();
    }).toList();
  }

  static Future<List<Recado>> fetchRecados() async {
    final results = await _pipeline([
      {
        'sql':
            'SELECT id, autor, texto, tag, cor, criado_em, imagem FROM mural_recados ORDER BY criado_em DESC',
        'args': [],
      }
    ]);

    final rows = _parseRows(results[0]);
    return rows.map(Recado.fromRow).toList();
  }

  static Future<void> createRecado({
    required String autor,
    required String texto,
    required String tag,
    required int cor,
    String? imagemBase64,
  }) async {
    await _pipeline([
      {
        'sql':
            "INSERT INTO mural_recados (autor, texto, tag, cor, imagem) VALUES (?, ?, ?, ?, ?)",
        'args': [
          {'type': 'text', 'value': autor},
          {'type': 'text', 'value': texto},
          {'type': 'text', 'value': tag},
          {'type': 'integer', 'value': cor.toString()},
          imagemBase64 != null
              ? {'type': 'text', 'value': imagemBase64}
              : {'type': 'null'},
        ],
      }
    ]);
  }

  static Future<void> deleteRecado(int id) async {
    await _pipeline([
      {
        'sql': 'DELETE FROM mural_recados WHERE id = ?',
        'args': [
          {'type': 'integer', 'value': id.toString()}
        ],
      }
    ]);
  }

  /// Verifica se as credenciais são válidas. Retorna null em caso de sucesso ou a mensagem de erro.
  static Future<String?> testConnection() async {
    try {
      await _pipeline([
        {'sql': 'SELECT 1'}
      ]);
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
