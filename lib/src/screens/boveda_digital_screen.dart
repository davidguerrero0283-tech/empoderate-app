import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
// import 'package:file_picker/file_picker.dart'; 
import '../../ui/theme/empoderate_theme.dart';
import '../components/premium_scaffold.dart';
import '../components/neon_widgets.dart';
import '../features/vault/services/vault_service.dart';
import '../features/vault/models/vault_models.dart';

class BovedaDigitalScreen extends StatefulWidget {
  const BovedaDigitalScreen({Key? key}) : super(key: key);

  @override
  State<BovedaDigitalScreen> createState() => _BovedaDigitalScreenState();
}

class _BovedaDigitalScreenState extends State<BovedaDigitalScreen> {
  final VaultService _service = VaultService();
  VaultViewMode _viewMode = VaultViewMode.list;
  
  // New settings
  String _cardSize = 'medium'; // small, medium, large
  String _detailLevel = 'normal'; // minimal, normal, detailed
  String _sortBy = 'date'; // date, name, size, type
  bool _sortAscending = false;
  bool _selectionMode = false;
  Set<String> _selectedFiles = {};

  @override
  void initState() {
    super.initState();
    _service.addListener(_onServiceUpdate);
    _service.init();
  }

  @override
  void dispose() {
    _service.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  // --- ACTIONS ---

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF151C2B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ajustes de Bóveda', style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              
              // View Mode Section
              Text('Modo de Vista', style: GoogleFonts.outfit(color: EmpoderateTheme.goldStrong, fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildViewOption(VaultViewMode.list, 'Lista Detallada', Icons.view_list),
              _buildViewOption(VaultViewMode.grid, 'Cuadrícula', Icons.grid_view),
              _buildViewOption(VaultViewMode.largeIcons, 'Iconos Grandes', Icons.apps),
              _buildViewOption(VaultViewMode.smallIcons, 'Iconos Pequeños', Icons.grid_on),
              
              const Divider(color: Colors.white10, height: 32),
              
              // Card Size Section
              Text('Tamaño de Tarjeta', style: GoogleFonts.outfit(color: EmpoderateTheme.goldStrong, fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildSizeOption('small', 'Pequeño', Icons.photo_size_select_small),
              _buildSizeOption('medium', 'Mediano', Icons.photo_size_select_large),
              _buildSizeOption('large', 'Grande', Icons.photo_size_select_actual),
              
              const Divider(color: Colors.white10, height: 32),
              
              // Detail Level Section
              Text('Nivel de Detalle', style: GoogleFonts.outfit(color: EmpoderateTheme.goldStrong, fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildDetailOption('minimal', 'Mínimo', Icons.remove),
              _buildDetailOption('normal', 'Normal', Icons.list),
              _buildDetailOption('detailed', 'Detallado', Icons.view_headline),
              
              const Divider(color: Colors.white10, height: 32),
              
              // Sort Options
              Text('Ordenar Por', style: GoogleFonts.outfit(color: EmpoderateTheme.goldStrong, fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildSortOption('date', 'Fecha', Icons.calendar_today),
              _buildSortOption('name', 'Nombre', Icons.sort_by_alpha),
              _buildSortOption('size', 'Tamaño', Icons.data_usage),
              _buildSortOption('type', 'Tipo', Icons.category),
              
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text('Orden Ascendente', style: GoogleFonts.outfit(color: Colors.white)),
                value: _sortAscending,
                activeColor: EmpoderateTheme.goldStrong,
                onChanged: (v) {
                  setState(() => _sortAscending = v);
                  Navigator.pop(ctx);
                },
              ),
              
              const SizedBox(height: 24),
              
              // Bulk Actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() => _selectionMode = !_selectionMode);
                        Navigator.pop(ctx);
                      },
                      icon: Icon(_selectionMode ? Icons.close : Icons.check_box),
                      label: Text(_selectionMode ? 'Cancelar Selección' : 'Seleccionar Múltiples'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: EmpoderateTheme.cyanAccent,
                        foregroundColor: Colors.black,
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

  Widget _buildViewOption(VaultViewMode mode, String label, IconData icon) {
    final isSelected = _viewMode == mode;
    return ListTile(
      leading: Icon(icon, color: isSelected ? EmpoderateTheme.cyanAccent : Colors.white54),
      title: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.white70)),
      trailing: isSelected ? Icon(Icons.check, color: EmpoderateTheme.cyanAccent) : null,
      onTap: () {
        setState(() => _viewMode = mode);
        Navigator.pop(context);
      },
    );
  }
  
  Widget _buildSizeOption(String size, String label, IconData icon) {
    final isSelected = _cardSize == size;
    return ListTile(
      leading: Icon(icon, color: isSelected ? EmpoderateTheme.goldStrong : Colors.white54),
      title: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.white70)),
      trailing: isSelected ? Icon(Icons.check, color: EmpoderateTheme.goldStrong) : null,
      onTap: () {
        setState(() => _cardSize = size);
        Navigator.pop(context);
      },
    );
  }
  
  Widget _buildDetailOption(String level, String label, IconData icon) {
    final isSelected = _detailLevel == level;
    return ListTile(
      leading: Icon(icon, color: isSelected ? EmpoderateTheme.goldStrong : Colors.white54),
      title: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.white70)),
      trailing: isSelected ? Icon(Icons.check, color: EmpoderateTheme.goldStrong) : null,
      onTap: () {
        setState(() => _detailLevel = level);
        Navigator.pop(context);
      },
    );
  }
  
  Widget _buildSortOption(String sort, String label, IconData icon) {
    final isSelected = _sortBy == sort;
    return ListTile(
      leading: Icon(icon, color: isSelected ? EmpoderateTheme.goldStrong : Colors.white54),
      title: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.white70)),
      trailing: isSelected ? Icon(Icons.check, color: EmpoderateTheme.goldStrong) : null,
      onTap: () {
        setState(() => _sortBy = sort);
        Navigator.pop(context);
      },
    );
  }

  Future<void> _createFolderDialog({VaultFolder? existing}) async {
    final ctrl = TextEditingController(text: existing?.name ?? '');
    Color selectedColor = existing?.color ?? Colors.blueAccent;
    // Simple palette
    final colors = [Colors.blueAccent, Colors.pinkAccent, Colors.greenAccent, Colors.orangeAccent, Colors.purpleAccent, Colors.tealAccent, Colors.redAccent];

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E2532),
            title: Text(existing == null ? 'Nueva Carpeta' : 'Editar Carpeta', style: const TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: ctrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Nombre', labelStyle: TextStyle(color: Colors.white54)),
                ),
                const SizedBox(height: 16),
                const Text('Color de Carpeta', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  children: colors.map((c) => GestureDetector(
                    onTap: () => setDialogState(() => selectedColor = c),
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(color: c, shape: BoxShape.circle, border: selectedColor == c ? Border.all(color: Colors.white, width: 2) : null),
                    ),
                  )).toList(),
                )
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
              ElevatedButton(
                onPressed: () {
                  if (ctrl.text.isEmpty) return;
                  // Auto-Icon based on name?
                  IconData icon = Icons.folder;
                  final low = ctrl.text.toLowerCase();
                  if (low.contains('legal')) icon = Icons.gavel;
                  if (low.contains('finanza') || low.contains('pago')) icon = Icons.attach_money;
                  if (low.contains('foto') || low.contains('img')) icon = Icons.image;
                  
                  if (existing == null) {
                    _service.createFolder(ctrl.text, selectedColor, icon);
                  } else {
                    _service.updateFolder(existing.id, ctrl.text, selectedColor, icon);
                  }
                  Navigator.pop(ctx);
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        }
      ),
    );
  }

  Future<void> _uploadFileMock(String type) async {
    // Determine source
    String name = 'Documento_${DateTime.now().minute}.pdf';
    IconData icon = Icons.picture_as_pdf;
    if (type == 'camera') {
      name = 'Foto_${DateTime.now().minute}.jpg';
      icon = Icons.camera_alt;
    } else if (type == 'gallery') {
      name = 'Imagen_${DateTime.now().minute}.png';
      icon = Icons.image; // Should be image icon
    }

    // Simulate "AI Auto-Sort" notification
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Analizando documento con IA... 🤖'), duration: Duration(milliseconds: 800)));
    await Future.delayed(const Duration(milliseconds: 1000));
    
    await _service.addFile(name: name, path: '', size: '1.5 MB', type: type == 'pdf' ? 'PDF' : 'IMG');
    
    // Find where it went
    final newFile = _service.files.first;
    final folderName = _service.folders.firstWhere((f) => f.id == newFile.folderId, orElse: () => _service.folders.last).name;
    
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('¡Guardado en "$folderName"! (Autodetectado)'),
      backgroundColor: Colors.green,
    ));
  }

  void _showFileOptions(VaultFile file) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0xFF151C2B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
               leading: const Icon(Icons.share, color: Colors.blueAccent),
               title: const Text('Compartir (PDF/Word)', style: TextStyle(color: Colors.white)),
               onTap: () { Navigator.pop(ctx); _mockShare(file); },
            ),
            ListTile(
               leading: const Icon(Icons.edit, color: Colors.orangeAccent),
               title: const Text('Renombrar', style: TextStyle(color: Colors.white)),
               onTap: () { Navigator.pop(ctx); _renameFile(file); },
            ),
            ListTile(
               leading: const Icon(Icons.folder_open, color: Colors.tealAccent),
               title: const Text('Mover de Carpeta', style: TextStyle(color: Colors.white)),
               onTap: () { Navigator.pop(ctx); _moveFile(file); },
            ),
            ListTile(
               leading: const Icon(Icons.delete, color: Colors.redAccent),
               title: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
               onTap: () { Navigator.pop(ctx); _service.deleteFile(file.id); },
            ),
          ],
        ),
      ),
    );
  }

  void _mockShare(VaultFile file) {
    // Show mock share sheet
    showModalBottomSheet(
       context: context,
       builder: (ctx) => Container(
         height: 200,
         color: Colors.white,
         child: Column(
           children: [
             const Padding(padding: EdgeInsets.all(16), child: Text("Compartir via...", style: TextStyle(fontWeight: FontWeight.bold))),
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
               children: [
                 _shareIcon(Icons.picture_as_pdf, "PDF", Colors.red),
                 _shareIcon(Icons.description, "Word", Colors.blue),
                 _shareIcon(Icons.email, "Email", Colors.grey),
                 _shareIcon(Icons.chat, "WhatsApp", Colors.green),
               ],
             )
           ],
         ),
       )
    );
  }

  Widget _shareIcon(IconData icon, String label, Color color) {
    return Column(children: [CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)), const SizedBox(height: 4), Text(label)]);
  }

  void _renameFile(VaultFile file) {
    final ctrl = TextEditingController(text: file.name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E2532),
        title: const Text('Renombrar', style: TextStyle(color: Colors.white)),
        content: TextField(controller: ctrl, style: const TextStyle(color: Colors.white)),
        actions: [
          ElevatedButton(onPressed: (){ _service.updateFile(file.id, ctrl.text); Navigator.pop(context); }, child: const Text('OK'))
        ],
      )
    );
  }

  void _moveFile(VaultFile file) {
    // Show list of folders to move to
     showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: 400,
        decoration: const BoxDecoration(color: Color(0xFF151C2B), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          children: [
             const Padding(padding: EdgeInsets.all(16), child: Text("Selecciona Carpeta", style: TextStyle(color: Colors.white, fontSize: 18))),
             Expanded(
               child: ListView(
                 children: _service.folders.map((f) => ListTile(
                   leading: Icon(f.icon, color: f.color),
                   title: Text(f.name, style: const TextStyle(color: Colors.white)),
                   onTap: () { _service.updateFileFolder(file.id, f.id); Navigator.pop(ctx); },
                 )).toList(),
               ),
             )
          ],
        ),
      ));
  }


  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'BÓVEDA INTELIGENTE',
      showBackButton: true,
      actions: [
         if (_selectionMode && _selectedFiles.isNotEmpty)
           IconButton(
             onPressed: () {
               showDialog(
                 context: context,
                 builder: (ctx) => AlertDialog(
                   backgroundColor: const Color(0xFF1E2532),
                   title: Text('Eliminar ${_selectedFiles.length} archivos', style: const TextStyle(color: Colors.white)),
                   content: const Text('¿Estás seguro?', style: TextStyle(color: Colors.white70)),
                   actions: [
                     TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                     ElevatedButton(
                       onPressed: () {
                         for (var id in _selectedFiles) {
                           _service.deleteFile(id);
                         }
                         setState(() {
                           _selectedFiles.clear();
                           _selectionMode = false;
                         });
                         Navigator.pop(ctx);
                       },
                       style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                       child: const Text('Eliminar'),
                     ),
                   ],
                 ),
               );
             },
             icon: const Icon(Icons.delete, color: Colors.red),
           ),
         if (_selectionMode)
           IconButton(
             onPressed: () {
               setState(() {
                 _selectionMode = false;
                 _selectedFiles.clear();
               });
             },
             icon: const Icon(Icons.close, color: Colors.white),
           ),
         IconButton(onPressed: _showSettings, icon: const Icon(Icons.tune, color: Colors.white)),
      ],
      body: _service.isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Column( // Use Column instead of SingleScrollView as root to allow Expanded body
            children: [
               // SEARCH BAR
               Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                 child: _buildSearchBar(),
               ),
               
               // FOLDERS ROW (Horizontal Scroll always)
               SizedBox(
                 height: 120,
                 child: ListView.builder(
                   scrollDirection: Axis.horizontal,
                   padding: const EdgeInsets.symmetric(horizontal: 16),
                   itemCount: _service.folders.length + 1, // +1 for "Add"
                   itemBuilder: (ctx, i) {
                     if (i == _service.folders.length) return _buildAddFolderBtn();
                     return _buildFolderItem(_service.folders[i]);
                   },
                 ),
               ),
               
               const Divider(color: Colors.white10),
               
               // FILES AREA (Depends on ViewMode)
               Expanded(
                 child: _buildFilesArea(),
               ),
            ],
          ),
      floatingActionButton: _buildSpeedDial(),
    );
  }
  
  Widget _buildFilesArea() {
    if (_service.files.isEmpty) return const Center(child: Text("Bóveda vacía. ¡Sube tu primer archivo!", style: TextStyle(color: Colors.white54)));

    if (_viewMode == VaultViewMode.list) {
       return ListView.builder(
         itemCount: _service.files.length,
         padding: const EdgeInsets.only(bottom: 80),
         itemBuilder: (ctx, i) => _buildFileListItem(_service.files[i]),
       );
    } else {
       // Grid Logic
       int crossAxisCount = _viewMode == VaultViewMode.smallIcons ? 4 : 2;
       if (_viewMode == VaultViewMode.largeIcons) crossAxisCount = 2; // Or 3
       
       return GridView.builder(
         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
           crossAxisCount: crossAxisCount,
           childAspectRatio: 0.8,
           crossAxisSpacing: 8, mainAxisSpacing: 8,
         ),
         padding: const EdgeInsets.all(16),
         itemCount: _service.files.length,
         itemBuilder: (ctx, i) => _buildFileGridItem(_service.files[i]),
       );
    }
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
      child: const TextField(
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: Colors.white54),
          hintText: 'Buscar factura, contrato...',
          hintStyle: TextStyle(color: Colors.white38),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildFolderItem(VaultFolder f) {
    return GestureDetector(
      onLongPress: () {
         if (f.isSystem) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Carpeta de sistema no editable.')));
           return;
         }
         // Edit dialog
         _createFolderDialog(existing: f);
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: f.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: f.color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(f.icon, color: f.color, size: 32),
            const SizedBox(height: 8),
            Text(f.name, style: GoogleFonts.outfit(color: Colors.white, fontSize: 12), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildAddFolderBtn() {
    return GestureDetector(
      onTap: () => _createFolderDialog(),
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24, style: BorderStyle.solid),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.create_new_folder, color: Colors.white54, size: 32),
            SizedBox(height: 8),
            Text("Crear", style: TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildFileListItem(VaultFile f) {
    // Determine color from folder?
    final folder = _service.folders.firstWhere((fold) => fold.id == f.folderId, orElse: () => _service.folders.first); // Default generic
    final isSelected = _selectedFiles.contains(f.id);
    
    // Adjust height based on card size
    double height = _cardSize == 'small' ? 60 : (_cardSize == 'large' ? 90 : 72);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? EmpoderateTheme.goldStrong.withOpacity(0.1) : Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(8),
        border: isSelected ? Border.all(color: EmpoderateTheme.goldStrong, width: 2) : null,
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: _cardSize == 'large' ? 8 : 4),
        leading: _selectionMode
            ? Checkbox(
                value: isSelected,
                activeColor: EmpoderateTheme.goldStrong,
                onChanged: (v) {
                  setState(() {
                    if (v == true) {
                      _selectedFiles.add(f.id);
                    } else {
                      _selectedFiles.remove(f.id);
                    }
                  });
                },
              )
            : Icon(
                f.type == 'PDF' ? Icons.picture_as_pdf : Icons.image,
                color: folder.color,
                size: _cardSize == 'large' ? 40 : (_cardSize == 'small' ? 24 : 32),
              ),
        title: Text(
          f.name,
          style: TextStyle(
            color: Colors.white,
            fontSize: _cardSize == 'large' ? 16 : (_cardSize == 'small' ? 13 : 14),
          ),
        ),
        subtitle: _detailLevel != 'minimal'
            ? Text(
                _detailLevel == 'detailed'
                    ? "${f.size} • ${DateFormat('dd MMM yyyy, HH:mm').format(f.date)} • ${folder.name}"
                    : "${f.size} • ${DateFormat('dd MMM').format(f.date)}",
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              )
            : null,
        trailing: _selectionMode
            ? null
            : IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white30),
                onPressed: () => _showFileOptions(f),
              ),
        onTap: _selectionMode
            ? () {
                setState(() {
                  if (isSelected) {
                    _selectedFiles.remove(f.id);
                  } else {
                    _selectedFiles.add(f.id);
                  }
                });
              }
            : null,
      ),
    );
  }

  Widget _buildFileGridItem(VaultFile f) {
    final folder = _service.folders.firstWhere((fold) => fold.id == f.folderId, orElse: () => _service.folders.first);
    
    return GestureDetector(
      onTap: () {}, // Preview
      onLongPress: () => _showFileOptions(f),
      child: Container(
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Icon(f.type == 'PDF' ? Icons.picture_as_pdf : Icons.image, color: folder.color, size: 40),
             const SizedBox(height: 12),
             Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text(f.name, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 12), maxLines: 2)),
             const SizedBox(height: 4),
             Text(folder.name, style: TextStyle(color: folder.color.withOpacity(0.7), fontSize: 10)),
          ],
        ),
      ),
    );
  }

  // Speed Dial replacement: FloatingActionButton that opens a bottom sheet with upload options
  Widget _buildSpeedDial() {
    return FloatingActionButton(
      backgroundColor: EmpoderateTheme.cyanAccent,
      child: const Icon(Icons.add, color: Colors.black, size: 28),
      onPressed: _showUploadOptions,
    );
  }

  void _showUploadOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(color: Color(0xFF151C2B), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.white70),
              title: const Text('Tomar Foto', style: TextStyle(color: Colors.white)),
              onTap: () { Navigator.pop(ctx); _uploadFileMock('camera'); },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.white70),
              title: const Text('Galería', style: TextStyle(color: Colors.white)),
              onTap: () { Navigator.pop(ctx); _uploadFileMock('gallery'); },
            ),
            ListTile(
              leading: const Icon(Icons.upload_file, color: Colors.white70),
              title: const Text('Subir Archivo', style: TextStyle(color: Colors.white)),
              onTap: () { Navigator.pop(ctx); _uploadFileMock('pdf'); },
            ),
          ],
        ),
      ),
    );
  }
}
