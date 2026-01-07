
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PendienteModel {
  final String id;
  String title;
  bool isCompleted;
  DateTime createdAt;

  PendienteModel({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'isCompleted': isCompleted,
    'createdAt': createdAt.toIso8601String(),
  };

  factory PendienteModel.fromJson(Map<String, dynamic> json) => PendienteModel(
    id: json['id'],
    title: json['title'],
    isCompleted: json['isCompleted'] ?? false,
    createdAt: DateTime.parse(json['createdAt']),
  );
}

class PendienteService extends ChangeNotifier {
  static final PendienteService _instance = PendienteService._internal();
  factory PendienteService() => _instance;
  PendienteService._internal();

  List<PendienteModel> _items = [];
  bool _isInitialized = false;

  List<PendienteModel> get items => _items;
  int get pendingCount => _items.where((i) => !i.isCompleted).length;

  Future<void> init() async {
    if (_isInitialized) return;
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('pendientes_list');
    if (data != null) {
      _items = data.map((e) => PendienteModel.fromJson(jsonDecode(e))).toList();
    } else {
      // Default items if empty
      _items = [
        PendienteModel(id: '1', title: 'Configurar perfil de negocio', createdAt: DateTime.now()),
        PendienteModel(id: '2', title: 'Revisar planilla del mes', createdAt: DateTime.now()),
      ];
      await _save();
    }
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> add(String title) async {
    final item = PendienteModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      createdAt: DateTime.now(),
    );
    _items.insert(0, item);
    await _save();
    notifyListeners();
  }

  Future<void> toggle(String id) async {
    final index = _items.indexWhere((i) => i.id == id);
    if (index != -1) {
      _items[index].isCompleted = !_items[index].isCompleted;
      await _save();
      notifyListeners();
    }
  }

  Future<void> remove(String id) async {
    _items.removeWhere((i) => i.id == id);
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _items.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('pendientes_list', data);
  }
}
