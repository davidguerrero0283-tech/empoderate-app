import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static final UserService instance = UserService._();
  UserService._();

  static const String _storageKey = 'admin_users_v1';
  List<Map<String, dynamic>> _users = [];
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await _loadUsers();
    _initialized = true;
  }

  Future<void> _loadUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString(_storageKey);
      if (data != null) {
        final List<dynamic> decoded = json.decode(data);
        _users = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        // Initial Mock Data
        _users = [
          {'id': 1, 'name': 'Juan Pérez', 'email': 'juan@empoderate.com', 'role': 'Admin', 'status': 'Active'},
          {'id': 2, 'name': 'Maria Lopez', 'email': 'maria@gmail.com', 'role': 'User', 'status': 'Active'},
          {'id': 3, 'name': 'Carlos Ruiz', 'email': 'carlos@tech.com', 'role': 'Pro', 'status': 'Inactive'},
        ];
        await _saveUsers();
      }
    } catch (e) {
      print('Error loading users: $e');
    }
  }

  Future<void> _saveUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, json.encode(_users));
    } catch (e) {
      print('Error saving users: $e');
    }
  }

  List<Map<String, dynamic>> getAllUsers() {
    return List.from(_users);
  }

  Future<void> addUser(Map<String, dynamic> userData) async {
    final newId = (_users.isEmpty ? 0 : _users.map((e) => e['id'] as int).reduce((a, b) => a > b ? a : b)) + 1;
    final newUser = {
      'id': newId,
      ...userData,
      'status': 'Active', // Default status
    };
    _users.add(newUser);
    await _saveUsers();
  }

  Future<void> updateUser(Map<String, dynamic> userData) async {
    final index = _users.indexWhere((u) => u['id'] == userData['id']);
    if (index != -1) {
      _users[index] = {..._users[index], ...userData};
      await _saveUsers();
    }
  }

  Future<void> deleteUser(int id) async {
    _users.removeWhere((u) => u['id'] == id);
    await _saveUsers();
  }
}
