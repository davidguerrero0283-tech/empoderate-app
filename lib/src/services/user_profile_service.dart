import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

/// Service to manage user profile data stored locally
class UserProfileService extends ChangeNotifier {
  static final UserProfileService _instance = UserProfileService._internal();
  factory UserProfileService() => _instance;
  UserProfileService._internal();

  static const String _keyBusinessName = 'user_business_name';
  static const String _keyUserName = 'user_display_name';
  static const String _keyProfileImage = 'user_profile_image';

  String _businessName = '';
  String _userName = '';
  String? _profileImageBase64;
  Uint8List? _profileImageBytes;

  String get businessName => _businessName;
  String get userName => _userName;
  Uint8List? get profileImageBytes => _profileImageBytes;
  bool get hasProfileImage => _profileImageBytes != null && _profileImageBytes!.isNotEmpty;
  
  /// Returns display name (business name if set, otherwise user name, otherwise 'EMPODÉRATE')
  String get displayName {
    if (_businessName.isNotEmpty) return _businessName;
    if (_userName.isNotEmpty) return _userName;
    return 'EMPODÉRATE';
  }

  /// Returns initials for avatar (max 2 chars)
  String get initials {
    final name = _businessName.isNotEmpty ? _businessName : _userName;
    if (name.isEmpty) return 'E';
    
    final words = name.trim().split(' ').where((w) => w.isNotEmpty).toList();
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.isNotEmpty && words[0].length >= 2) {
      return words[0].substring(0, 2).toUpperCase();
    } else if (words.isNotEmpty) {
      return words[0][0].toUpperCase();
    }
    return 'E';
  }

  /// Load profile from SharedPreferences
  Future<void> loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _businessName = prefs.getString(_keyBusinessName) ?? '';
      _userName = prefs.getString(_keyUserName) ?? '';
      _profileImageBase64 = prefs.getString(_keyProfileImage);
      
      // Decode base64 to bytes
      if (_profileImageBase64 != null && _profileImageBase64!.isNotEmpty) {
        try {
          _profileImageBytes = base64Decode(_profileImageBase64!);
        } catch (e) {
          debugPrint('UserProfileService: Error decoding image: $e');
          _profileImageBytes = null;
        }
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('UserProfileService: Error loading profile: $e');
    }
  }

  /// Save business name
  Future<void> setBusinessName(String name) async {
    _businessName = name.trim();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyBusinessName, _businessName);
      notifyListeners();
    } catch (e) {
      debugPrint('UserProfileService: Error saving business name: $e');
    }
  }

  /// Save user name
  Future<void> setUserName(String name) async {
    _userName = name.trim();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserName, _userName);
      notifyListeners();
    } catch (e) {
      debugPrint('UserProfileService: Error saving user name: $e');
    }
  }

  /// Pick and save profile image
  Future<bool> pickProfileImage() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 256,
        maxHeight: 256,
        imageQuality: 80,
      );
      
      if (image != null) {
        final bytes = await image.readAsBytes();
        _profileImageBytes = bytes;
        _profileImageBase64 = base64Encode(bytes);
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_keyProfileImage, _profileImageBase64!);
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('UserProfileService: Error picking image: $e');
      return false;
    }
  }

  /// Remove profile image
  Future<void> removeProfileImage() async {
    _profileImageBytes = null;
    _profileImageBase64 = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyProfileImage);
      notifyListeners();
    } catch (e) {
      debugPrint('UserProfileService: Error removing image: $e');
    }
  }

  /// Clear all profile data
  Future<void> clearProfile() async {
    _businessName = '';
    _userName = '';
    _profileImageBytes = null;
    _profileImageBase64 = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyBusinessName);
      await prefs.remove(_keyUserName);
      await prefs.remove(_keyProfileImage);
      notifyListeners();
    } catch (e) {
      debugPrint('UserProfileService: Error clearing profile: $e');
    }
  }
}
