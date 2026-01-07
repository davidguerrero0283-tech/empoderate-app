import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'business_profile_models.dart';

class ReminderServicePlaceholder {
  static const String _storageKey = 'business_reminders';
  
  // Singleton pattern to ensure we access the same storage list in memory if needed
  static final ReminderServicePlaceholder _instance = ReminderServicePlaceholder._internal();
  factory ReminderServicePlaceholder() => _instance;
  ReminderServicePlaceholder._internal();

  /// Loads reminders from storage, or generates defaults if empty.
  Future<List<BusinessReminder>> getReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? encoded = prefs.getStringList(_storageKey);

    if (encoded != null && encoded.isNotEmpty) {
      return encoded.map((s) => BusinessReminder.fromJson(jsonDecode(s))).toList();
    }

    // Return defaults if nothing saved, but don't save them yet unless user confirms? 
    // Or maybe we treat generating default reminders separately.
    // For now, let's return defaults but NOT persistent ones if empty, to simplify.
    // Actually, let's just return empty list + defaults in UI, or seed them here.
    return _generateDefaults();
  }

  /// Adds a new reminder to persistence
  Future<void> addReminder(BusinessReminder reminder) async {
    final prefs = await SharedPreferences.getInstance();
    List<BusinessReminder> current = await getReminders();
    
    // Add new one
    current.add(reminder);
    
    // Sort by date? Optional.
    current.sort((a, b) => a.fecha.compareTo(b.fecha));

    final List<String> encoded = current.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList(_storageKey, encoded);
  }

  List<BusinessReminder> _generateDefaults() {
    return [
      BusinessReminder(
        id: "1",
        titulo: "Declaración mensual (ITBMS)",
        descripcion: "Recuerda presentar tu declaración del mes Formulario 430.",
        fecha: DateTime.now().add(const Duration(days: 30)),
      ),
      BusinessReminder(
        id: "2",
        titulo: "Décimo Tercer Mes",
        descripcion: "Revisa el cálculo del décimo tercer mes con la calculadora.",
        fecha: DateTime(DateTime.now().year, 12, 15),
      ),
      BusinessReminder(
        id: "3",
        titulo: "Declaración de Renta Jurídica",
        descripcion: "Fecha límite para presentar la declaración anual.",
        fecha: DateTime(DateTime.now().year + 1, 3, 31),
      ),
    ];
  }

  // Deprecated method signature kept for compatibility if needed, but we should migrate calling code
  List<BusinessReminder> generarRecordatorios(BusinessProfile perfil) {
    return _generateDefaults();
  }
}
