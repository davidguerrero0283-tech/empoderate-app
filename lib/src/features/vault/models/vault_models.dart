import 'package:flutter/material.dart';

enum VaultViewMode { list, grid, largeIcons, smallIcons }

class VaultFolder {
  final String id;
  final String name;
  final int colorValue; // Store int for easy JSON serialization
  final int iconPoint; // Store codepoint
  final bool isSystem; // Prevent deletion of system folders

  const VaultFolder({
    required this.id, 
    required this.name, 
    required this.colorValue, 
    required this.iconPoint,
    this.isSystem = false,
  });

  Color get color => Color(colorValue);
  IconData get icon => IconData(iconPoint, fontFamily: 'MaterialIcons');

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'colorValue': colorValue, 'iconPoint': iconPoint, 'isSystem': isSystem
  };

  factory VaultFolder.fromJson(Map<String, dynamic> json) => VaultFolder(
    id: json['id'],
    name: json['name'],
    colorValue: json['colorValue'],
    iconPoint: json['iconPoint'],
    isSystem: json['isSystem'] ?? false,
  );
}

class VaultFile {
  final String id;
  final String name;
  final String path; // Local path or URL
  final DateTime date;
  final String size; // Human readable string for now
  final String type; // PDF, JPG, etc
  final String folderId;

  VaultFile({
    required this.id,
    required this.name,
    required this.path,
    required this.date,
    required this.size,
    required this.type,
    required this.folderId,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'path': path, 'date': date.toIso8601String(), 
    'size': size, 'type': type, 'folderId': folderId
  };

  factory VaultFile.fromJson(Map<String, dynamic> json) => VaultFile(
    id: json['id'],
    name: json['name'],
    path: json['path'],
    date: DateTime.parse(json['date']),
    size: json['size'],
    type: json['type'],
    folderId: json['folderId'],
  );
}
