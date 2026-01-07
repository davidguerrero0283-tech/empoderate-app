import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_empoderate/src/calculators/schedule_models.dart';
import 'package:proyecto_empoderate/src/features/schedule_management/logic/schedule_controller.dart';

class ShiftManagementDialog extends StatefulWidget {
  final ScheduleController controller;
  final ShiftSlot? existingShift; // null for new shift

  const ShiftManagementDialog({
    Key? key,
    required this.controller,
    this.existingShift,
  }) : super(key: key);

  @override
  State<ShiftManagementDialog> createState() => _ShiftManagementDialogState();
}

class _ShiftManagementDialogState extends State<ShiftManagementDialog> {
  late TextEditingController _nameController;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late bool _isRush;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingShift;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _startTime = existing != null 
        ? TimeOfDay(hour: existing.startTime.hour, minute: existing.startTime.minute)
        : const TimeOfDay(hour: 8, minute: 0);
    _endTime = existing != null 
        ? TimeOfDay(hour: existing.endTime.hour, minute: existing.endTime.minute)
        : const TimeOfDay(hour: 16, minute: 0);
    _isRush = existing?.isRush ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingShift != null;
    
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E2C),
      title: Text(
        isEditing ? 'Editar Turno' : 'Nuevo Turno',
        style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Nombre del Turno',
                labelStyle: TextStyle(color: Colors.grey.shade400),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade600),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.cyanAccent),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTimePicker('Inicio', _startTime, (t) => setState(() => _startTime = t))),
                const SizedBox(width: 16),
                Expanded(child: _buildTimePicker('Fin', _endTime, (t) => setState(() => _endTime = t))),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Turno Pico (Rush)', style: TextStyle(color: Colors.white)),
              subtitle: Text('Se mostrará resaltado', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
              value: _isRush,
              onChanged: (v) => setState(() => _isRush = v),
              activeColor: Colors.amber,
            ),
          ],
        ),
      ),
      actions: [
        if (isEditing)
          TextButton(
            onPressed: () async {
              await widget.controller.deleteShift(widget.existingShift!.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
          onPressed: _saveShift,
          child: Text(isEditing ? 'Actualizar' : 'Crear', style: const TextStyle(color: Colors.black)),
        ),
      ],
    );
  }

  Widget _buildTimePicker(String label, TimeOfDay time, ValueChanged<TimeOfDay> onChanged) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(context: context, initialTime: time);
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade600),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
            const SizedBox(height: 4),
            Text(time.format(context), style: const TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  void _saveShift() async {
    if (_nameController.text.trim().isEmpty) return;

    final shift = ShiftSlot(
      id: widget.existingShift?.id,
      name: _nameController.text.trim(),
      startTime: DateTime(2024, 1, 1, _startTime.hour, _startTime.minute),
      endTime: DateTime(2024, 1, 1, _endTime.hour, _endTime.minute),
      isRush: _isRush,
    );

    if (widget.existingShift != null) {
      await widget.controller.updateShift(shift);
    } else {
      await widget.controller.addShift(shift);
    }

    if (mounted) Navigator.pop(context);
  }
}

/// Shows the dialog to manage shifts (list + add/edit)
class ShiftListDialog extends StatelessWidget {
  final ScheduleController controller;

  const ShiftListDialog({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E2C),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Gestionar Turnos', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.cyanAccent),
            onPressed: () => _showAddEditDialog(context, null),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: controller.shifts.isEmpty
            ? const Center(child: Text('No hay turnos definidos', style: TextStyle(color: Colors.grey)))
            : ListView.builder(
                shrinkWrap: true,
                itemCount: controller.shifts.length,
                itemBuilder: (context, index) {
                  final shift = controller.shifts[index];
                  return ListTile(
                    leading: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: shift.isRush ? Colors.amber : Colors.blueAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Text(shift.name, style: const TextStyle(color: Colors.white)),
                    subtitle: Text(
                      '${_formatTime(shift.startTime)} - ${_formatTime(shift.endTime)}',
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                    trailing: const Icon(Icons.edit, color: Colors.grey, size: 18),
                    onTap: () => _showAddEditDialog(context, shift),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar', style: TextStyle(color: Colors.cyanAccent)),
        ),
      ],
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  void _showAddEditDialog(BuildContext context, ShiftSlot? shift) {
    showDialog(
      context: context,
      builder: (_) => ShiftManagementDialog(controller: controller, existingShift: shift),
    ).then((_) {
      // Trigger rebuild of parent dialog after edit
      (context as Element).markNeedsBuild();
    });
  }
}
