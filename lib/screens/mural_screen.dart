import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/recado.dart';
import '../services/turso_service.dart';
import '../widgets/recado_card.dart';
import '../widgets/novo_recado_dialog.dart';
import 'settings_screen.dart';

class MuralScreen extends StatefulWidget {
  const MuralScreen({super.key});

  @override
  State<MuralScreen> createState() => _MuralScreenState();
}

class _MuralScreenState extends State<MuralScreen> {
  List<Recado> _recados = [];
  bool _loading = true;
  String? _error;
  TagRecado? _filtroTag; // null = todos

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final lista = await TursoService.fetchRecados();
      setState(() => _recados = lista);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  List<Recado> get _filtered {
    if (_filtroTag == null) return _recados;
    return _recados.where((r) => r.tag == _filtroTag).toList();
  }

  Future<void> _confirmDelete(Recado r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E2130),
        title: const Text('Excluir recado?',
            style: TextStyle(color: Colors.white)),
        content: Text(
          '"${r.texto.length > 60 ? '${r.texto.substring(0, 60)}…' : r.texto}"',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir',
                style: TextStyle(color: Color(0xFFEF5350))),
          ),
        ],
      ),
    );
    if (ok == true) {
      try {
        await TursoService.deleteRecado(r.id);
        await _load();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _showNovoRecado() {
    showDialog(
      context: context,
      builder: (_) => NovoRecadoDialog(
        onPublicar: ({
          required autor,
          required texto,
          required tag,
          required cor,
          imagemBase64,
        }) async {
          await TursoService.createRecado(
            autor: autor,
            texto: texto,
            tag: tag,
            cor: cor,
            imagemBase64: imagemBase64,
          );
          await _load();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E2130),
        elevation: 0,
        title: Row(
          children: [
            const Text(
              'Mural',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2D3E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_recados.length} recados',
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: _loading ? null : _load,
            tooltip: 'Atualizar',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white70),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
            tooltip: 'Configurações',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          _buildFilterBar(),
          // Content
          Expanded(child: _buildContent(filtered)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNovoRecado,
        backgroundColor: const Color(0xFF6C63FF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterBar() {
    final chips = [
      (null, 'Todos'),
      (TagRecado.aviso, 'Aviso'),
      (TagRecado.urgente, 'Urgente'),
      (TagRecado.lembrete, 'Lembrete'),
      (TagRecado.info, 'Info'),
    ];

    return Container(
      color: const Color(0xFF1E2130),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: chips.map((chip) {
            final (tag, label) = chip;
            final selected = _filtroTag == tag;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(label),
                selected: selected,
                onSelected: (_) => setState(() => _filtroTag = tag),
                selectedColor: const Color(0xFF6C63FF),
                backgroundColor: const Color(0xFF2A2D3E),
                labelStyle: TextStyle(
                  color: selected ? Colors.white : Colors.white60,
                  fontSize: 13,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.normal,
                ),
                checkmarkColor: Colors.white,
                side: BorderSide.none,
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildContent(List<Recado> recados) {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF6C63FF)),
            SizedBox(height: 16),
            Text('Carregando recados…',
                style: TextStyle(color: Colors.white54)),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, color: Colors.white30, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Não foi possível carregar o mural',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style:
                    const TextStyle(color: Colors.white38, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF)),
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const SettingsScreen()),
                ),
                child: const Text('Configurar banco de dados',
                    style: TextStyle(color: Colors.white54)),
              ),
            ],
          ),
        ),
      );
    }

    if (recados.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.push_pin_outlined,
                color: Colors.white24, size: 48),
            const SizedBox(height: 16),
            Text(
              _filtroTag == null
                  ? 'Nenhum recado ainda.\nSeja o primeiro!'
                  : 'Nenhum recado com este filtro.',
              style:
                  const TextStyle(color: Colors.white38, fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: const Color(0xFF6C63FF),
      backgroundColor: const Color(0xFF1E2130),
      child: MasonryGridView.count(
        padding: const EdgeInsets.all(12),
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        itemCount: recados.length,
        itemBuilder: (ctx, i) => RecadoCard(
          recado: recados[i],
          onDelete: () => _confirmDelete(recados[i]),
        ),
      ),
    );
  }
}
