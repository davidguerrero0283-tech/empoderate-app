import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:proyecto_empoderate/src/calculators/schedule_models.dart';

class ScheduleTemplateService {
  static const String _templatesKey = 'saved_schedule_templates';

  /// Save a schedule as a reusable template
  Future<void> saveTemplate(ScheduleTemplate template) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get existing templates
    final templates = await getTemplates();
    
    // Add or update template
    final index = templates.indexWhere((t) => t.id == template.id);
    if (index >= 0) {
      templates[index] = template;
    } else {
      templates.add(template);
    }
    
    // Save to storage
    final jsonList = templates.map((t) => _templateToJson(t)).toList();
    await prefs.setString(_templatesKey, jsonEncode(jsonList));
  }

  /// Get all saved templates
  Future<List<ScheduleTemplate>> getTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_templatesKey);
    
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => _templateFromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Delete a template
  Future<void> deleteTemplate(String templateId) async {
    final templates = await getTemplates();
    templates.removeWhere((t) => t.id == templateId);
    
    final prefs = await SharedPreferences.getInstance();
    final jsonList = templates.map((t) => _templateToJson(t)).toList();
    await prefs.setString(_templatesKey, jsonEncode(jsonList));
  }

  Map<String, dynamic> _templateToJson(ScheduleTemplate template) {
    return {
      'id': template.id,
      'name': template.name,
      'availableSlots': template.availableSlots.map((slot) => {
        'id': slot.id,
        'name': slot.name,
        'startTime': '${slot.startTime.hour}:${slot.startTime.minute}',
        'endTime': '${slot.endTime.hour}:${slot.endTime.minute}',
        'isRush': slot.isRush,
      }).toList(),
      'minDaysOffPerWeek': template.minDaysOffPerWeek,
    };
  }

  ScheduleTemplate _templateFromJson(Map<String, dynamic> json) {
    return ScheduleTemplate(
      id: json['id'],
      name: json['name'],
      availableSlots: (json['availableSlots'] as List).map<ShiftSlot>((slot) {
        final startParts = (slot['startTime'] as String).split(':');
        final endParts = (slot['endTime'] as String).split(':');
        return ShiftSlot(
          id: slot['id'],
          name: slot['name'],
          startTime: DateTime(2000, 1, 1, int.parse(startParts[0]), int.parse(startParts[1])),
          endTime: DateTime(2000, 1, 1, int.parse(endParts[0]), int.parse(endParts[1])),
          isRush: slot['isRush'] ?? false,
        );
      }).toList(),
      minDaysOffPerWeek: json['minDaysOffPerWeek'],
      weeklyDemand: [], // Will be calculated when loaded
    );
  }
}
