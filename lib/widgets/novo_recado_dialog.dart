import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/recado.dart';

class NovoRecadoDialog extends StatefulWidget {
  final Future<void> Function({
    required String autor,
    required String texto,
    required String tag,
    required int cor,
    String? imagemBase64,
  }) onPublicar;

  const NovoRecadoDialog({super.key, required this.onPublicar});

  @override
  State<NovoRecadoDialog> createState() => _NovoRecadoDialogState();
}

class _NovoRecadoDialogState extends State<NovoRecadoDialog> {
  final _autorCtrl = TextEditingController();
  final _textoCtrl = TextEditingController();
  TagRecado _tag = TagRecado.aviso;
  int _cor = 0;
  String? _imagemBase64;
  bool _loading = false;
  final _picker = ImagePicker();

  static const _tagLabels = ['Aviso', 'Urgente', 'Lembrete', 'Info'];
  static const _tagValues = [
    TagRecado.aviso,
    TagRecado.urgente,
    TagRecado.lembrete,
    TagRecado.info,
  ];

  @override
  void dispose() {
    _autorCtrl.dispose();
    _textoCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? img =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 60);
    if (img == null) return;
    final bytes = await File(img.path).readAsBytes();
    final ext = img.path.split('.').last.toLowerCase();
    final mime = ext == 'png' ? 'image/png' : 'image/jpeg';
    setState(() {
      _imagemBase64 = 'data:$mime;base64,${base64Encode(bytes)}';
    });
  }

  Future<void> _publicar() async {
    if (_textoCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      await widget.onPublicar(
        autor: _autorCtrl.text.trim().isEmpty
            ? 'Anônimo'
            : _autorCtrl.text.trim(),
        texto: _textoCtrl.text.trim(),
        tag: _tag.label.toLowerCase(),
        cor: _cor,
        imagemBase64: _imagemBase64,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E2130),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Novo recado',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildField(_autorCtrl, 'Seu nome', maxLines: 1),
              const SizedBox(height: 12),
              _buildField(_textoCtrl, 'Escreva sua mensagem...', maxLines: 4),
              const SizedBox(height: 16),
              const Text(
                'CATEGORIA',
                style: TextStyle(
                  color: Color(0xFF9E9E9E),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              _buildTagDropdown(),
              const SizedBox(height: 16),
              const Text(
                'COR DO POST-IT',
                style: TextStyle(
                  color: Color(0xFF9E9E9E),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 10),
              _buildColorPicker(),
              const SizedBox(height: 16),
              _buildImagePicker(),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white54,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed:
                          _loading ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _loading ? null : _publicar,
                      child: _loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.push_pin, size: 16),
                                SizedBox(width: 6),
                                Text('Publicar',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String hint, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: const Color(0xFF2A2D3E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _buildTagDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2D3E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<TagRecado>(
        value: _tag,
        isExpanded: true,
        dropdownColor: const Color(0xFF2A2D3E),
        underline: const SizedBox(),
        style: const TextStyle(color: Colors.white, fontSize: 14),
        onChanged: (v) => setState(() => _tag = v!),
        items: List.generate(
          _tagValues.length,
          (i) => DropdownMenuItem(
            value: _tagValues[i],
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _tagValues[i].color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(_tagLabels[i]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorPicker() {
    return Row(
      children: List.generate(
        coresPostIt.length,
        (i) => GestureDetector(
          onTap: () => setState(() => _cor = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(right: 10),
            width: _cor == i ? 36 : 30,
            height: _cor == i ? 36 : 30,
            decoration: BoxDecoration(
              color: coresPostIt[i],
              shape: BoxShape.circle,
              border: Border.all(
                color: _cor == i ? Colors.white : Colors.transparent,
                width: 2.5,
              ),
              boxShadow: _cor == i
                  ? [
                      BoxShadow(
                        color: coresPostIt[i].withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 1,
                      )
                    ]
                  : [],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2D3E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _imagemBase64 != null
                ? const Color(0xFF6C63FF)
                : Colors.white12,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _imagemBase64 != null ? Icons.check_circle : Icons.attach_file,
              size: 18,
              color:
                  _imagemBase64 != null ? const Color(0xFF6C63FF) : Colors.white38,
            ),
            const SizedBox(width: 8),
            Text(
              _imagemBase64 != null
                  ? 'Foto anexada  (toque para trocar)'
                  : 'Anexar foto (opcional)',
              style: TextStyle(
                color:
                    _imagemBase64 != null ? Colors.white70 : Colors.white38,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
