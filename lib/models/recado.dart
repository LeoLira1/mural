import 'package:flutter/material.dart';

enum TagRecado { aviso, urgente, lembrete, info }

extension TagLabel on TagRecado {
  String get label {
    switch (this) {
      case TagRecado.aviso:
        return 'AVISO';
      case TagRecado.urgente:
        return 'URGENTE';
      case TagRecado.lembrete:
        return 'LEMBRETE';
      case TagRecado.info:
        return 'INFO';
    }
  }

  Color get color {
    switch (this) {
      case TagRecado.aviso:
        return const Color(0xFF64B5F6); // azul
      case TagRecado.urgente:
        return const Color(0xFFEF5350); // vermelho
      case TagRecado.lembrete:
        return const Color(0xFF81C784); // verde
      case TagRecado.info:
        return const Color(0xFFB0BEC5); // cinza
    }
  }

  static TagRecado fromString(String s) {
    switch (s.toLowerCase()) {
      case 'urgente':
        return TagRecado.urgente;
      case 'lembrete':
        return TagRecado.lembrete;
      case 'info':
        return TagRecado.info;
      default:
        return TagRecado.aviso;
    }
  }
}

/// Índice de cor → cor do post-it (mesmas cores do Streamlit)
const List<Color> coresPostIt = [
  Color(0xFFFFE066), // 0 amarelo
  Color(0xFFFFB347), // 1 laranja
  Color(0xFFA8E6CF), // 2 verde
  Color(0xFF87CEEB), // 3 azul
  Color(0xFFFFB6C1), // 4 rosa
  Color(0xFFF5F5F5), // 5 branco
];

class Recado {
  final int id;
  final String autor;
  final String texto;
  final TagRecado tag;
  final int cor;
  final String criadoEm;
  final String? imagem; // base64

  Recado({
    required this.id,
    required this.autor,
    required this.texto,
    required this.tag,
    required this.cor,
    required this.criadoEm,
    this.imagem,
  });

  Color get cardColor => coresPostIt[cor.clamp(0, coresPostIt.length - 1)];

  factory Recado.fromRow(List<dynamic> values) {
    // ORDER das colunas: id, autor, texto, tag, cor, criado_em, imagem
    return Recado(
      id: (values[0] as num).toInt(),
      autor: values[1]?.toString() ?? 'Anônimo',
      texto: values[2]?.toString() ?? '',
      tag: TagLabel.fromString(values[3]?.toString() ?? 'aviso'),
      cor: (values[4] as num?)?.toInt() ?? 0,
      criadoEm: values[5]?.toString() ?? '',
      imagem: values[6]?.toString(),
    );
  }
}
