import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../ui/theme/empoderate_theme.dart';
import '../../../components/safe_async_screen.dart';
import '../../../components/neon_widgets.dart';
import '../models/doc_model.dart';
import '../services/boveda_service.dart';

class BovedaScreen extends StatefulWidget {
  const BovedaScreen({Key? key}) : super(key: key);

  @override
  State<BovedaScreen> createState() => _BovedaScreenState();
}

class _BovedaScreenState extends State<BovedaScreen> {
  final BovedaService _service = BovedaService();
  DocCategory? _selectedCategory;

  Future<List<DocModel>> _loadData() async {
    await _service.init();
    return _service.documents;
  }

  List<DocModel> _filterDocs(List<DocModel> docs) {
    if (_selectedCategory == null) return docs;
    return docs.where((doc) => doc.category == _selectedCategory).toList();
  }

  Future<void> _mockUpload() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _UploadModal(onUpload: (title, category) async {
        try {
          await _service.addDocument(
            title: title,
            category: category,
            path: 'assets/docs/mock_doc.pdf',
            size: 1024 * 500 + (DateTime.now().millisecond * 100),
          );
          if (mounted) {
            setState(() {}); // Trigger rebuild
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Documento guardado correctamente')),
            );
          }
        } catch (e) {
          print('Error adding document: $e');
        }
      }),
    );
  }

  Future<void> _deleteDoc(String id) async {
    await _service.deleteDocument(id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeAsyncScreen<List<DocModel>>(
      title: 'BÓVEDA DIGITAL',
      futureBuilder: _loadData,
      emptyCheck: (docs) => docs.isEmpty,
      emptyMessage: 'La bóveda está vacía',
      emptyIcon: 'folder',
      emptyActionLabel: 'Subir Primer Archivo',
      onEmptyAction: _mockUpload,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mockUpload,
        backgroundColor: EmpoderateTheme.goldStrong,
        icon: const Icon(Icons.upload_file, color: Colors.black),
        label: Text(
          'Subir Archivo',
          style: GoogleFonts.outfit(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      builder: (context, allDocs) {
        final docs = _filterDocs(allDocs);
        final totalSize = allDocs.fold<int>(0, (sum, doc) => sum + doc.sizeBytes);
        final sizeLabel = (totalSize / (1024 * 1024)).toStringAsFixed(1);

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Storage Status
              NeonCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Almacenamiento',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '$sizeLabel MB / 100 MB',
                          style: GoogleFonts.outfit(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: totalSize / (1024 * 1024 * 100),
                        backgroundColor: Colors.white10,
                        valueColor: const AlwaysStoppedAnimation(
                          EmpoderateTheme.cyanAccent,
                        ),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _InfoBadge(
                          icon: Icons.security,
                          label: 'Encriptado',
                          color: EmpoderateTheme.goldStrong,
                        ),
                        _InfoBadge(
                          icon: Icons.cloud_off,
                          label: 'Solo Local',
                          color: Colors.blueAccent,
                        ),
                        _InfoBadge(
                          icon: Icons.backup,
                          label: 'Backup',
                          color: Colors.greenAccent,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Category Filters
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'Todos',
                      isSelected: _selectedCategory == null,
                      onTap: () => setState(() => _selectedCategory = null),
                    ),
                    ...DocCategory.values.map(
                      (cat) => _FilterChip(
                        label: cat.label,
                        isSelected: _selectedCategory == cat,
                        onTap: () => setState(() => _selectedCategory = cat),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Document List
              Expanded(
                child: docs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.filter_list_off,
                              size: 60,
                              color: Colors.white24,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay documentos en esta categoría',
                              style: GoogleFonts.outfit(
                                color: Colors.white30,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: docs.length,
                        padding: const EdgeInsets.only(bottom: 80),
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          return _buildDocTile(doc);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDocTile(DocModel doc) {
    IconData icon;
    Color color;

    switch (doc.category) {
      case DocCategory.legal:
        icon = Icons.gavel;
        color = Colors.blue;
        break;
      case DocCategory.fiscal:
        icon = Icons.account_balance;
        color = EmpoderateTheme.goldStrong;
        break;
      case DocCategory.rrhh:
        icon = Icons.people;
        color = Colors.purple;
        break;
      case DocCategory.otros:
        icon = Icons.description;
        color = Colors.grey;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF161B28),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          doc.title,
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 15),
        ),
        subtitle: Text(
          '${DateFormat('dd/MM/yyyy').format(doc.dateAdded)} • ${doc.sizeLabel}',
          style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12),
        ),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert, color: Colors.white54),
          color: const Color(0xFF1A1A2E),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'open',
              child: Text('Abrir', style: TextStyle(color: Colors.white)),
            ),
            const PopupMenuItem(
              value: 'share',
              child: Text('Compartir', style: TextStyle(color: Colors.white)),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
          onSelected: (value) {
            if (value == 'delete') _deleteDoc(doc.id);
            if (value == 'open') _viewDoc(doc);
          },
        ),
      ),
    );
  }

  void _viewDoc(DocModel doc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161B28),
        title: Text(doc.title, style: GoogleFonts.outfit(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Categoría: ${doc.category.label}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
            Text('Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(doc.dateAdded)}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
            const Divider(color: Colors.white12, height: 24),
            const Text('CONTENIDO (SIMULADO):', style: TextStyle(color: kNeonGold, fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(4)),
              child: Text(
                'Este es un documento almacenado de forma segura en su bóveda local.\n\nEn la versión final, aquí podrá visualizar el PDF original.',
                style: GoogleFonts.sourceCodePro(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CERRAR', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preparando para compartir...')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: EmpoderateTheme.cyanAccent),
            child: const Text('COMPARTIR', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? EmpoderateTheme.goldStrong
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? EmpoderateTheme.goldStrong
                : Colors.white12,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: isSelected ? Colors.black : Colors.white70,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.outfit(color: Colors.white60, fontSize: 10),
        ),
      ],
    );
  }
}

class _UploadModal extends StatefulWidget {
  final Function(String, DocCategory) onUpload;

  const _UploadModal({required this.onUpload});

  @override
  State<_UploadModal> createState() => _UploadModalState();
}

class _UploadModalState extends State<_UploadModal> {
  final _titleController = TextEditingController();
  DocCategory _category = DocCategory.otros;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF161B28),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subir Documento',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Nombre del archivo',
              filled: true,
              fillColor: Colors.white10,
              labelStyle: TextStyle(color: Colors.white54),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Text('Categoría:', style: GoogleFonts.outfit(color: Colors.white70)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: DocCategory.values.map((cat) {
              return ChoiceChip(
                label: Text(cat.label),
                selected: _category == cat,
                selectedColor: EmpoderateTheme.goldStrong,
                onSelected: (selected) {
                  if (selected) setState(() => _category = cat);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: EmpoderateTheme.cyanAccent,
              ),
              onPressed: () {
                if (_titleController.text.isNotEmpty) {
                  widget.onUpload(_titleController.text, _category);
                  Navigator.pop(context);
                }
              },
              child: const Text(
                'GUARDAR',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
          ),
        ],
      ),
    );
  }
}
