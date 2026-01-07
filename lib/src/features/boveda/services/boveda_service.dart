import 'dart:convert';
// import 'dart:io'; 
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:path_provider/path_provider.dart'; // Using generic implementation for now to avoid direct IO issues in web if not handled
import '../models/doc_model.dart';
import 'package:uuid/uuid.dart';

class BovedaService {
  static const String _key = 'boveda_docs_v1';
  // Use a singleton 
  static final BovedaService _instance = BovedaService._internal();
  factory BovedaService() => _instance;
  BovedaService._internal();

  List<DocModel> _cache = [];

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_key);
    if (data != null) {
      try {
        final List<dynamic> decoded = jsonDecode(data);
        _cache = decoded.map((e) => DocModel.fromJson(e)).toList();
      } catch (e) {
        print('Error loading boveda data: $e');
        _cache = [];
      }
    }
    
    // Auto-populate if empty (Fix for "Boveda vacia")
    if (_cache.isEmpty) {
      await addDocument(
        title: 'Bienvenido a tu Bóveda',
        category: DocCategory.otros,
        path: 'assets/docs/welcome.pdf',
        size: 1024 * 25, 
      );
    }
  }

  List<DocModel> get documents => List.unmodifiable(_cache);

  // MOCK IMPLEMENTATION FOR WEB/DEMO if file_picker not fully set up
  // In a real app we would copy the file to AppDocumentsDir
  Future<void> addDocument({
    required String title,
    required DocCategory category,
    required String path, // For web/demo this might just be a name or fake path
    required int size,
  }) async {
    final newDoc = DocModel(
      id: const Uuid().v4(),
      title: title,
      category: category,
      filePath: path, 
      dateAdded: DateTime.now(),
      sizeBytes: size,
    );

    _cache.add(newDoc);
    await _saveToPrefs();
  }

  Future<void> saveDocument({
    required String title,
    required DocCategory category,
    required String? content,
    String? extension = '.txt',
  }) async {
    final newDoc = DocModel(
      id: const Uuid().v4(),
      title: title,
      category: category,
      filePath: 'simulated_path/$title$extension', 
      dateAdded: DateTime.now(),
      sizeBytes: content?.length ?? 0,
    );

    _cache.add(newDoc);
    await _saveToPrefs();
  }

  Future<void> deleteDocument(String id) async {
    // In real app, delete file from FS here using _cache.firstWhere((e) => e.id == id).filePath
    _cache.removeWhere((doc) => doc.id == id);
    await _saveToPrefs();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_cache.map((e) => e.toJson()).toList());
    await prefs.setString(_key, encoded);
  }
}
