import 'package:flutter/material.dart';

class MenuStateService {
  static final MenuStateService _instance = MenuStateService._internal();
  factory MenuStateService() => _instance;
  MenuStateService._internal();

  // The persistent state of the menu (open or closed)
  bool _isMenuOpen = false;
  
  // Notifier to allow UI components to react to changes
  final ValueNotifier<bool> menuNotifier = ValueNotifier<bool>(false);

  bool get isMenuOpen => _isMenuOpen;

  void toggleMenu() {
    _isMenuOpen = !_isMenuOpen;
    menuNotifier.value = _isMenuOpen;
  }

  void setMenuOpen(bool isOpen) {
    if (_isMenuOpen != isOpen) {
      _isMenuOpen = isOpen;
      menuNotifier.value = isOpen;
    }
  }
}
