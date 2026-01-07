import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vault_models.dart';

class VaultService extends ChangeNotifier {
  static final VaultService _instance = VaultService._internal();
  factory VaultService() => _instance;
  VaultService._internal();

  List<VaultFolder> _folders = [];
  List<VaultFile> _files = [];
  bool _isLoading = true;

  List<VaultFolder> get folders => _folders;
  List<VaultFile> get files => _files;
  bool get isLoading => _isLoading;

  // SYSTEM FOLDER IDS
  static const String FOLDER_HR = 'folder_hr';
  static const String FOLDER_LEGAL = 'folder_legal';
  static const String FOLDER_FINANCE = 'folder_finance';
  static const String FOLDER_GENERAL = 'folder_general';

  Future<void> init() async {
    _isLoading = true;
    final prefs = await SharedPreferences.getInstance();
    
    // Load Folders
    final fStr = prefs.getStringList('vault_folders');
    if (fStr != null && fStr.isNotEmpty) {
      final List<VaultFolder> loaded = [];
      for (var s in fStr) {
        try {
          final Map<String, dynamic> map = jsonDecode(s);
          loaded.add(VaultFolder.fromJson(map));
        } catch (e) {
          print('Error loading folder: $e');
        }
      }
      _folders = loaded;
    } else {
      _initDefaultFolders();
    }

    // Load Files
    final filesStr = prefs.getStringList('vault_files');
    if (filesStr != null && filesStr.isNotEmpty) {
      final List<VaultFile> loadedFiles = [];
      for (var s in filesStr) {
        try {
          final Map<String, dynamic> map = jsonDecode(s);
          loadedFiles.add(VaultFile.fromJson(map));
        } catch (e) {
          print('Error loading file: $e');
        }
      }
      _files = loadedFiles;
    } else {
      _initDefaultFiles();
    }

    _isLoading = false;
    notifyListeners();
  }

  void _initDefaultFolders() {
    _folders = [
      VaultFolder(id: FOLDER_HR, name: 'Recursos Humanos', colorValue: Colors.pinkAccent.value, iconPoint: Icons.people.codePoint, isSystem: true),
      VaultFolder(id: FOLDER_LEGAL, name: 'Legal & Contratos', colorValue: Colors.blueAccent.value, iconPoint: Icons.gavel.codePoint, isSystem: true),
      VaultFolder(id: FOLDER_FINANCE, name: 'Finanzas & Facturas', colorValue: Colors.greenAccent.value, iconPoint: Icons.attach_money.codePoint, isSystem: true),
      VaultFolder(id: FOLDER_GENERAL, name: 'General', colorValue: Colors.orangeAccent.value, iconPoint: Icons.folder.codePoint, isSystem: true),
    ];
    _persistFolders();
  }

  void _initDefaultFiles() {
    // Some mock files for demo
    _files = [
       VaultFile(id: '1', name: 'Contrato_Juan_Perez.pdf', path: '', date: DateTime.now().subtract(const Duration(days: 1)), size: '1.2 MB', type: 'PDF', folderId: FOLDER_HR),
       VaultFile(id: '2', name: 'Factura_Luz_Enero.pdf', path: '', date: DateTime.now().subtract(const Duration(days: 5)), size: '500 KB', type: 'PDF', folderId: FOLDER_FINANCE),
       VaultFile(id: '3', name: 'Aviso_Operacion_2024.jpg', path: '', date: DateTime.now().subtract(const Duration(days: 20)), size: '3.5 MB', type: 'JPG', folderId: FOLDER_LEGAL),
    ];
    _persistFiles();
  }

  // --- CRUD FOLDERS ---
  Future<void> createFolder(String name, Color color, IconData icon) async {
    final newFolder = VaultFolder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      colorValue: color.value,
      iconPoint: icon.codePoint,
    );
    _folders.add(newFolder);
    await _persistFolders();
  }

  Future<void> updateFolder(String id, String name, Color color, IconData icon) async {
    final idx = _folders.indexWhere((VaultFolder f) => f.id == id);
    if (idx != -1) {
      _folders[idx] = VaultFolder(
        id: id,
        name: name,
        colorValue: color.value,
        iconPoint: icon.codePoint,
        isSystem: _folders[idx].isSystem,
      );
      await _persistFolders();
    }
  }

  Future<void> deleteFolder(String id) async {
    // Move files to General or delete? Let's move to General for safety
    final filesInFolder = _files.where((VaultFile f) => f.folderId == id).toList();
    for (var f in filesInFolder) {
      updateFileFolder(f.id, FOLDER_GENERAL);
    }
    _folders.removeWhere((VaultFolder f) => f.id == id);
    await _persistFolders();
  }

  // --- CRUD FILES ---
  Future<void> addFile({
    required String name,
    required String path,
    required String size,
    required String type,
    String? forcedFolderId,
  }) async {
    // AI LOGIC: If no folder forced, detect by name
    String folderId = forcedFolderId ?? FOLDER_GENERAL;
    
    if (forcedFolderId == null) {
      folderId = _aiCategorize(name); 
    }

    final newFile = VaultFile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      path: path,
      date: DateTime.now(),
      size: size,
      type: type,
      folderId: folderId,
    );
    
    _files.insert(0, newFile); // Top of list
    await _persistFiles();
  }

  Future<void> updateFile(String id, String newName) async {
    final idx = _files.indexWhere((VaultFile f) => f.id == id);
    if (idx != -1) {
       final old = _files[idx];
       // Re-run categorization if desired? Maybe only if asked. For now just rename.
       _files[idx] = VaultFile(
         id: old.id,
         name: newName,
         path: old.path,
         date: old.date,
         size: old.size,
         type: old.type,
         folderId: old.folderId,
       );
       await _persistFiles();
    }
  }

  Future<void> updateFileFolder(String fileId, String newFolderId) async {
    final idx = _files.indexWhere((VaultFile f) => f.id == fileId);
    if (idx != -1) {
      final old = _files[idx];
      _files[idx] = VaultFile(
         id: old.id,
         name: old.name,
         path: old.path,
         date: old.date,
         size: old.size,
         type: old.type,
         folderId: newFolderId,
      );
      await _persistFiles();
    }
  }

  Future<void> deleteFile(String id) async {
    _files.removeWhere((VaultFile f) => f.id == id);
    await _persistFiles();
  }

  // --- AI ENGINE ---
  String _aiCategorize(String name) {
    final lower = name.toLowerCase();
    
    if (lower.contains('factura') || lower.contains('recibo') || lower.contains('pago') || lower.contains('banco') || lower.contains('impuesto')) {
      return FOLDER_FINANCE;
    }
    if (lower.contains('contrato') || lower.contains('aviso') || lower.contains('permiso') || lower.contains('legal') || lower.contains('ruc')) {
      return FOLDER_LEGAL;
    }
    if (lower.contains('cv') || lower.contains('hoja de vida') || lower.contains('renuncia') || lower.contains('carta') || lower.contains('empleado') || lower.contains('planilla')) {
      return FOLDER_HR;
    }
    
    // Check custom folders too? Simple keyword matching
    for (var f in _folders) {
      if (!f.isSystem && lower.contains(f.name.toLowerCase())) {
        return f.id;
      }
    }
    
    return FOLDER_GENERAL;
  }
  
  // --- PERSISTENCE ---
  Future<void> _persistFolders() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = [];
    for (final VaultFolder f in _folders) {
      list.add(jsonEncode(f.toJson()));
    }
    await prefs.setStringList('vault_folders', list);
    notifyListeners();
  }

  Future<void> _persistFiles() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = [];
    for (final VaultFile f in _files) {
      list.add(jsonEncode(f.toJson()));
    }
    await prefs.setStringList('vault_files', list);
    notifyListeners();
  }
}
