import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_empoderate/ui/components/header/premium_header.dart';
import '../components/gradient_background.dart';
import 'business_profile_components.dart';
import 'business_profile_models.dart';

class ReminderDetailScreen extends StatefulWidget {
  const ReminderDetailScreen({Key? key}) : super(key: key);

  @override
  State<ReminderDetailScreen> createState() => _ReminderDetailScreenState();
}

class _ReminderDetailScreenState extends State<ReminderDetailScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isCompleted = false;
  bool _isNewReminder = true;
  BusinessReminder? _existingReminder;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is BusinessReminder) {
      _existingReminder = args;
      _isNewReminder = false;
      _titleController.text = args.titulo;
      _descriptionController.text = args.descripcion;
      _selectedDate = args.fecha;
      _isCompleted = args.completado;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFD4AF37),
              onPrimary: Color(0xFF001B3A),
              surface: Color(0xFF001B3A),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveReminder() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El título es obligatorio')),
      );
      return;
    }

    // TODO: Save reminder using a reminder service
    // For now, just show success and go back
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isNewReminder ? 'Recordatorio creado' : 'Recordatorio actualizado'),
        backgroundColor: const Color(0xFFD4AF37),
      ),
    );
    Navigator.pop(context);
  }

  void _deleteReminder() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF001B3A),
        title: Text(
          'Eliminar recordatorio',
          style: GoogleFonts.outfit(color: Colors.white),
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar este recordatorio?',
          style: GoogleFonts.roboto(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancelar',
              style: GoogleFonts.outfit(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Delete reminder using a reminder service
              Navigator.pop(ctx);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Recordatorio eliminado'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            child: Text(
              'Eliminar',
              style: GoogleFonts.outfit(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: PremiumHeader(showBackButton: true),
      ),
      body: GradientBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isNewReminder ? 'Crear Recordatorio' : 'Editar Recordatorio',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              
              // Title field
              BusinessInputField(
                label: 'Título del Recordatorio',
                controller: _titleController,
                placeholder: 'Ej: Pago de planilla mensual',
              ),
              
              // Description field
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Descripción',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFD4AF37),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(0, 0, 0, 0.35),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: TextField(
                        controller: _descriptionController,
                        maxLines: 4,
                        style: GoogleFonts.outfit(color: Colors.white),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(16),
                          border: InputBorder.none,
                          hintText: 'Ej: Recordar realizar el pago de la planilla antes del día 15 de cada mes',
                          hintStyle: const TextStyle(color: Colors.white30),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Date picker
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fecha límite',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFD4AF37),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(0, 0, 0, 0.35),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, color: Color(0xFFD4AF37), size: 20),
                            const SizedBox(width: 12),
                            Text(
                              '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.edit, color: Colors.white54, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Completed toggle (only for existing reminders)
              if (!_isNewReminder)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(0, 0, 0, 0.35),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Marcar como completado',
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
                    ),
                    activeColor: const Color(0xFFD4AF37),
                    value: _isCompleted,
                    onChanged: (val) {
                      setState(() {
                        _isCompleted = val;
                      });
                    },
                  ),
                ),
              
              const SizedBox(height: 32),
              
              // Save button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _saveReminder,
                  icon: Icon(_isNewReminder ? Icons.add : Icons.save, size: 20),
                  label: Text(
                    _isNewReminder ? 'Crear Recordatorio' : 'Guardar Cambios',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF001B3A),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              
              // Delete button (only for existing reminders)
              if (!_isNewReminder) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: _deleteReminder,
                    icon: const Icon(Icons.delete_outline, size: 20),
                    label: Text(
                      'Eliminar Recordatorio',
                      style: GoogleFonts.outfit(
                        color: Colors.redAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
