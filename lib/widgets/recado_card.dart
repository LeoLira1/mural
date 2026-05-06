import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/recado.dart';

class RecadoCard extends StatelessWidget {
  final Recado recado;
  final VoidCallback? onDelete;

  const RecadoCard({super.key, required this.recado, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final bgColor = recado.cardColor;
    final isDark = bgColor.computeLuminance() < 0.5;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subtleColor = textColor.withOpacity(0.55);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: tag + delete
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _TagChip(tag: recado.tag),
                if (onDelete != null)
                  GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: textColor.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, size: 13, color: subtleColor),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            // Texto principal
            Text(
              recado.texto,
              style: TextStyle(
                color: textColor,
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            // Imagem opcional
            if (recado.imagem != null && recado.imagem!.isNotEmpty) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.memory(
                  base64Decode(_stripBase64Prefix(recado.imagem!)),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ],
            const SizedBox(height: 12),
            // Footer: autor + data
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: textColor.withOpacity(0.2),
                  child: Text(
                    recado.autor.isNotEmpty
                        ? recado.autor[0].toUpperCase()
                        : 'A',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    recado.autor,
                    style: TextStyle(
                      color: subtleColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  _formatDate(recado.criadoEm),
                  style: TextStyle(color: subtleColor, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _stripBase64Prefix(String s) {
    final idx = s.indexOf(',');
    return idx >= 0 ? s.substring(idx + 1) : s;
  }

  String _formatDate(String raw) {
    if (raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw);
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inDays == 0) {
        if (diff.inHours == 0) return 'agora';
        return 'há ${diff.inHours}h';
      }
      if (diff.inDays == 1) return 'ontem';
      if (diff.inDays < 7) return 'há ${diff.inDays}d';
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw.length > 10 ? raw.substring(5, 10) : raw;
    }
  }
}

class _TagChip extends StatelessWidget {
  final TagRecado tag;
  const _TagChip({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: tag.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            tag.label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
    );
  }
}
