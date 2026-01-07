import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_empoderate/src/calculators/schedule_models.dart';
import 'package:proyecto_empoderate/src/calculators/salario_models.dart';
import 'package:proyecto_empoderate/src/features/schedule_management/logic/schedule_controller.dart';
import 'package:proyecto_empoderate/src/features/rrhh/scheduling_intelligence/widgets/simulation_preview_modal.dart';
import 'package:proyecto_empoderate/src/utils/carta_generator.dart';
import 'package:proyecto_empoderate/src/services/pdf_service.dart';
import 'package:proyecto_empoderate/src/services/worker_service.dart';
import 'package:go_router/go_router.dart';

/// Dialog for submitting a new shift change request
/// Enhanced with date ranges, shift selection, and Panama labor code leave types
class ShiftChangeRequestDialog extends StatefulWidget {
  final ScheduleController controller;
  final WorkerProfile? initialWorker;

  const ShiftChangeRequestDialog({
    Key? key, 
    required this.controller,
    this.initialWorker,
  }) : super(key: key);

  @override
  State<ShiftChangeRequestDialog> createState() => _ShiftChangeRequestDialogState();
}

class _ShiftChangeRequestDialogState extends State<ShiftChangeRequestDialog> {
  ChangeType _selectedType = ChangeType.permission;
  WorkerProfile? _selectedRequester;
  WorkerProfile? _selectedTarget;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  String? _selectedShiftId;
  final _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialWorker != null) {
      _selectedRequester = widget.initialWorker;
       _selectedType = ChangeType.vacation; // Default to vacation if coming from alert
    }
  }

  // Quick duration presets
  int? _selectedDurationPreset;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  String _getTypeLabel(ChangeType type) {
    switch (type) {
      case ChangeType.swapShift: return 'Intercambio';
      case ChangeType.coverShift: return 'Cobertura';
      case ChangeType.permission: return 'Permiso';
      case ChangeType.daySwap: return 'Cambio Día';
      case ChangeType.sickLeave: return 'Incapacidad';
      case ChangeType.maternityLeave: return 'Maternidad';
      case ChangeType.paternityLeave: return 'Paternidad';
      case ChangeType.lactancia: return 'Lactancia';
      case ChangeType.bereavement: return 'Duelo';
      case ChangeType.vacation: return 'Vacaciones';
      case ChangeType.medicalFollow: return 'Cita Médica';
    }
  }

  IconData _getTypeIcon(ChangeType type) {
    switch (type) {
      case ChangeType.swapShift: return Icons.swap_horiz;
      case ChangeType.coverShift: return Icons.person_add;
      case ChangeType.permission: return Icons.event_busy;
      case ChangeType.daySwap: return Icons.calendar_today;
      case ChangeType.sickLeave: return Icons.local_hospital;
      case ChangeType.maternityLeave: return Icons.pregnant_woman;
      case ChangeType.paternityLeave: return Icons.child_care;
      case ChangeType.lactancia: return Icons.baby_changing_station;
      case ChangeType.bereavement: return Icons.favorite_border;
      case ChangeType.vacation: return Icons.beach_access;
      case ChangeType.medicalFollow: return Icons.medical_services;
    }
  }

  Color _getTypeColor(ChangeType type) {
    switch (type) {
      case ChangeType.swapShift: return Colors.blueAccent;
      case ChangeType.coverShift: return Colors.greenAccent;
      case ChangeType.permission: return Colors.amber;
      case ChangeType.daySwap: return Colors.orangeAccent;
      case ChangeType.sickLeave: return Colors.redAccent;
      case ChangeType.maternityLeave: return Colors.pinkAccent;
      case ChangeType.paternityLeave: return Colors.teal;
      case ChangeType.lactancia: return Colors.pink;
      case ChangeType.bereavement: return Colors.purple;
      case ChangeType.vacation: return Colors.cyan;
      case ChangeType.medicalFollow: return Colors.green;
    }
  }

  /// Check if type needs date range (multi-day)
  bool _needsDateRange(ChangeType type) {
    return [ChangeType.sickLeave, ChangeType.maternityLeave, ChangeType.paternityLeave, 
            ChangeType.bereavement, ChangeType.vacation].contains(type);
  }

  /// Check if type needs target person (swap/cover)
  bool _needsTarget(ChangeType type) {
    return type == ChangeType.swapShift || type == ChangeType.coverShift;
  }

  /// Check if type needs shift selection
  bool _needsShiftSelection(ChangeType type) {
    return type == ChangeType.swapShift || type == ChangeType.coverShift || type == ChangeType.daySwap;
  }

  Widget _buildSwapPreview() {
    // Get Requestor Shift
    final requesterShift = widget.controller.shifts.firstWhere(
      (s) => s.id == _selectedShiftId, 
      orElse: () => ShiftSlot(id: 'none', name: 'Libre', startTime: DateTime(2000), endTime: DateTime(2000))
    );
    
    // Get Target Shift
    final targetShiftId = _getShiftForWorkerDate(_selectedTarget!.id, _startDate);
    final targetShift = widget.controller.shifts.firstWhere(
      (s) => s.id == targetShiftId, 
      orElse: () => ShiftSlot(id: 'none', name: 'Libre', startTime: DateTime(2000), endTime: DateTime(2000))
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.compare_arrows, size: 16, color: Colors.blueAccent),
              SizedBox(width: 8),
              Text('Visualización del Cambio', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          // Row 1: Requester
          _buildSwapRow(_selectedRequester!.name, requesterShift, targetShift),
          const Divider(color: Colors.white12, height: 16),
          // Row 2: Target
          _buildSwapRow(_selectedTarget!.name, targetShift, requesterShift),
        ],
      ),
    );
  }

  Widget _buildSwapRow(String name, ShiftSlot current, ShiftSlot future) {
    return Row(
      children: [
         SizedBox(
           width: 80, 
           child: Text(name.split(' ')[0], style: const TextStyle(color: Colors.white70, fontSize: 11, overflow: TextOverflow.ellipsis))
         ),
         Expanded(child: _buildShiftBadge(current, isOld: true)),
         const Padding(
           padding: EdgeInsets.symmetric(horizontal: 8.0),
           child: Icon(Icons.arrow_forward, size: 12, color: Colors.grey),
         ),
         Expanded(child: _buildShiftBadge(future, isNew: true)),
      ],
    );
  }

  Widget _buildShiftBadge(ShiftSlot shift, {bool isOld = false, bool isNew = false}) {
     final bool isOff = shift.id == 'none';
     // Use extension color if available, or fallback
     final Color shiftColor = isOff ? Colors.grey : shift.color; 
     
     return Container(
       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
       decoration: BoxDecoration(
         color: isOff ? Colors.transparent : shiftColor.withOpacity(0.2),
         border: Border.all(color: isOff ? Colors.grey : shiftColor),
         borderRadius: BorderRadius.circular(4),
       ),
       child: Column(
         children: [
           Text(
             shift.name, 
             textAlign: TextAlign.center,
             style: TextStyle(
               color: isOff ? Colors.grey : shiftColor, 
               fontSize: 10, 
               fontWeight: FontWeight.bold,
               decoration: isOld ? TextDecoration.lineThrough : null,
             )
           ),
           if (!isOff)
             Text(
               _formatTime(shift.startTime),
               style: TextStyle(color: Colors.white54, fontSize: 9),
             ),
         ],
       ),
     );
  }

  String? _getShiftForWorkerDate(String workerId, DateTime date) {
    // Helper to find shift ID in controller current schedule
    // widget.controller.weekStart is the start of the week (Monday)
    // We assume the date is within the current week for this check
    final startOfWeek = widget.controller.weekStart;
    final dayIndex = date.difference(startOfWeek).inDays;
    
    if (dayIndex < 0 || dayIndex >= 7) return null;
    return widget.controller.assignments[workerId]?[dayIndex];
  }

  String _formatTime(DateTime time) {
    // Convert DateTime to TimeOfDay logic manually or use DateFormat
    final hour = time.hour == 0 || time.hour == 12 ? 12 : time.hour % 12;
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '${hour}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  /// Get duration presets for quick selection
  List<Map<String, dynamic>> _getDurationPresets(ChangeType type) {
    switch (type) {
      case ChangeType.sickLeave:
        return [
          {'label': '1 día', 'days': 1},
          {'label': '3 días', 'days': 3},
          {'label': '1 semana', 'days': 7},
          {'label': '2 semanas', 'days': 14},
          {'label': '1 mes', 'days': 30},
          {'label': 'Personalizado', 'days': null},
        ];
      case ChangeType.maternityLeave:
        return [
          {'label': '14 semanas (Art. 107)', 'days': 98},
          {'label': '6 semanas prenatal', 'days': 42},
          {'label': '8 semanas postnatal', 'days': 56},
        ];
      case ChangeType.paternityLeave:
        return [
          {'label': '3 días', 'days': 3},
        ];
      case ChangeType.bereavement:
        return [
          {'label': '1 día', 'days': 1},
          {'label': '3 días', 'days': 3},
        ];
      case ChangeType.vacation:
        return [
          {'label': '1 semana', 'days': 7},
          {'label': '2 semanas', 'days': 14},
          {'label': '30 días', 'days': 30},
          {'label': 'Personalizado', 'days': null},
        ];
      default:
        return [];
    }
  }

  void _setDurationPreset(int? days) {
    setState(() {
      _selectedDurationPreset = days;
      if (days != null) {
        _endDate = _startDate.add(Duration(days: days - 1));
      } else {
        _endDate = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final workers = widget.controller.workers;
    final shifts = widget.controller.shifts;
    final needsTarget = _needsTarget(_selectedType);
    final needsDateRange = _needsDateRange(_selectedType);
    final needsShift = _needsShiftSelection(_selectedType);
    final presets = _getDurationPresets(_selectedType);

    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E2C),
      title: Row(
        children: [
          Icon(_getTypeIcon(_selectedType), color: _getTypeColor(_selectedType)),
          const SizedBox(width: 8),
          Text('Nueva Solicitud', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type Selection (compact)
              Text('Tipo de Solicitud', style: TextStyle(color: Colors.cyanAccent, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: ChangeType.values.map((type) => ChoiceChip(
                  label: Text(_getTypeLabel(type), style: TextStyle(fontSize: 10)),
                  avatar: Icon(_getTypeIcon(type), size: 14, color: _selectedType == type ? Colors.white : _getTypeColor(type)),
                  selected: _selectedType == type,
                  onSelected: (v) => setState(() {
                    _selectedType = type;
                    _selectedDurationPreset = null;
                    _endDate = null;
                  }),
                  selectedColor: _getTypeColor(type),
                  backgroundColor: Colors.grey.shade800,
                  labelStyle: TextStyle(color: _selectedType == type ? Colors.white : Colors.grey),
                )).toList(),
              ),
              const SizedBox(height: 16),

              // Requester
              Text('Empleado', style: TextStyle(color: Colors.cyanAccent, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              DropdownButton<WorkerProfile>(
                value: _selectedRequester,
                isExpanded: true,
                dropdownColor: const Color(0xFF2A2A3C),
                hint: const Text('Seleccionar empleado', style: TextStyle(color: Colors.grey)),
                items: workers.map((w) => DropdownMenuItem(
                  value: w,
                  child: Text(w.name, style: const TextStyle(color: Colors.white)),
                )).toList(),
                onChanged: (v) => setState(() => _selectedRequester = v),
              ),

              // Target (if swap/cover)
              if (needsTarget) ...[
                const SizedBox(height: 12),
                Text('Colega (intercambio/cobertura)', style: TextStyle(color: Colors.cyanAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                DropdownButton<WorkerProfile>(
                  value: _selectedTarget,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF2A2A3C),
                  hint: const Text('Seleccionar colega', style: TextStyle(color: Colors.grey)),
                  items: workers.where((w) => w.id != _selectedRequester?.id).map((w) => DropdownMenuItem(
                    value: w,
                    child: Text(w.name, style: const TextStyle(color: Colors.white)),
                  )).toList(),
                  onChanged: (v) => setState(() => _selectedTarget = v),
                ),
              ],

              // Shift selection (for swaps)
              if (needsShift) ...[
                const SizedBox(height: 12),
                const SizedBox(height: 12),
                Text('Turno a Cambiar', style: TextStyle(color: Colors.cyanAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                DropdownButton<String>(
                  value: _selectedShiftId,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF2A2A3C),
                  hint: const Text('Seleccionar turno', style: TextStyle(color: Colors.grey)),
                  items: shifts.map((s) => DropdownMenuItem(
                    value: s.id,
                    child: Row(
                      children: [
                        Container(width: 12, height: 12, decoration: BoxDecoration(color: s.color, borderRadius: BorderRadius.circular(3))),
                        const SizedBox(width: 8),
                        Text('${s.name} (${_formatTime(s.startTime)} - ${_formatTime(s.endTime)})', style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  )).toList(),
                  onChanged: (v) => setState(() => _selectedShiftId = v),
                ),

                // SWAP PREVIEW (New Comparison UI)
                if (_selectedType == ChangeType.swapShift && _selectedRequester != null && _selectedTarget != null)
                   Padding(
                     padding: const EdgeInsets.only(top: 16.0),
                     child: _buildSwapPreview(),
                   ),
              ],

              // Date selection
              const SizedBox(height: 12),
              Text(needsDateRange ? 'Fecha Inicio' : 'Fecha', style: TextStyle(color: Colors.cyanAccent, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              _buildDatePicker('Seleccionar fecha', _startDate, (d) => setState(() {
                _startDate = d;
                if (_selectedDurationPreset != null) {
                  _endDate = _startDate.add(Duration(days: _selectedDurationPreset! - 1));
                }
              })),

              // Duration presets (for date range types)
              if (needsDateRange && presets.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text('Duración', style: TextStyle(color: Colors.cyanAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: presets.map((p) => ChoiceChip(
                    label: Text(p['label'], style: const TextStyle(fontSize: 10)),
                    selected: _selectedDurationPreset == p['days'],
                    onSelected: (_) => _setDurationPreset(p['days']),
                    selectedColor: _getTypeColor(_selectedType),
                    backgroundColor: Colors.grey.shade800,
                    labelStyle: TextStyle(color: _selectedDurationPreset == p['days'] ? Colors.white : Colors.grey),
                  )).toList(),
                ),
              ],

              // End date (for custom/personalizado)
              if (needsDateRange && _selectedDurationPreset == null) ...[
                const SizedBox(height: 12),
                Text('Fecha Fin', style: TextStyle(color: Colors.cyanAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                _buildDatePicker('Seleccionar fecha fin', _endDate ?? _startDate, (d) => setState(() => _endDate = d)),
              ],

              // Show calculated days
              if (needsDateRange && _endDate != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getTypeColor(_selectedType).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: _getTypeColor(_selectedType), size: 16),
                      const SizedBox(width: 8),
                      Text(
                        '${_endDate!.difference(_startDate).inDays + 1} días (${DateFormat('d MMM').format(_startDate)} - ${DateFormat('d MMM').format(_endDate!)})',
                        style: TextStyle(color: _getTypeColor(_selectedType), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],

              // Reason
              const SizedBox(height: 12),
              Text('Motivo', style: TextStyle(color: Colors.cyanAccent, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              TextField(
                controller: _reasonController,
                style: const TextStyle(color: Colors.white),
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: _getReasonHint(_selectedType),
                  hintStyle: TextStyle(color: Colors.grey.shade600),
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

              // Legal info for maternity
              if (_selectedType == ChangeType.maternityLeave) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.pink.withOpacity(0.1),
                    border: Border.all(color: Colors.pink),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('📜 Art. 107 Código de Trabajo', style: TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('• 14 semanas totales (6 pre + 8 post)', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      Text('• Fuero maternal: 12 meses post-reincorporación', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      Text('• Pago: CSS o empleador si no afiliada', style: TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ),
              ],

              // Legal info for lactancia
              if (_selectedType == ChangeType.lactancia) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.pink.withOpacity(0.1),
                    border: Border.all(color: Colors.pink),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('📜 Art. 114 Código de Trabajo', style: TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('• 15 min cada 2-3 horas, o', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      Text('• 2 periodos de 30 min durante jornada', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      Text('• Sin afectar salario', style: TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: _getTypeColor(_selectedType)),
          onPressed: _submit,
          child: const Text('Enviar Solicitud', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildDatePicker(String hint, DateTime date, Function(DateTime) onPicked) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime.now().subtract(const Duration(days: 7)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) onPicked(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade600),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.cyanAccent, size: 18),
            const SizedBox(width: 12),
            Text(DateFormat('EEEE, d MMM yyyy', 'es').format(date), style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  String _getReasonHint(ChangeType type) {
    switch (type) {
      case ChangeType.sickLeave: return 'Ej: Diagnóstico médico...';
      case ChangeType.maternityLeave: return 'Fecha probable de parto...';
      case ChangeType.permission: return 'Ej: Cita médica, trámite personal...';
      case ChangeType.swapShift: return 'Ej: Necesito cubrir un compromiso...';
      case ChangeType.bereavement: return 'Ej: Fallecimiento de familiar...';
      case ChangeType.vacation: return 'Ej: Vacaciones programadas...';
      default: return 'Motivo de la solicitud...';
    }
  }

  void _submit() async {
    if (_selectedRequester == null || _reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor complete todos los campos requeridos'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final request = ShiftChangeLog(
        type: _selectedType,
        requesterId: _selectedRequester!.id,
        requesterName: _selectedRequester!.name,
        targetId: _selectedTarget?.id,
        targetName: _selectedTarget?.name,
        date: _startDate,
        endDate: _endDate,
        originalSlotId: _selectedShiftId,
        reason: _reasonController.text.trim(),
      );

      // Submit request
      await widget.controller.submitChangeRequest(request);
      
      if (!mounted) return;
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Solicitud de ${_getTypeLabel(_selectedType)} enviada correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Close dialog
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al enviar solicitud: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

/// Panel showing pending requests (for admin view)
class PendingRequestsPanel extends StatelessWidget {
  final ScheduleController controller;

  const PendingRequestsPanel({Key? key, required this.controller}) : super(key: key);

  String _getTypeLabel(ChangeType type) {
    switch (type) {
      case ChangeType.swapShift: return 'Intercambio';
      case ChangeType.coverShift: return 'Cobertura';
      case ChangeType.permission: return 'Permiso';
      case ChangeType.daySwap: return 'Cambio Día';
      case ChangeType.sickLeave: return 'Incapacidad';
      case ChangeType.maternityLeave: return 'Maternidad';
      case ChangeType.paternityLeave: return 'Paternidad';
      case ChangeType.lactancia: return 'Lactancia';
      case ChangeType.bereavement: return 'Duelo';
      case ChangeType.vacation: return 'Vacaciones';
      case ChangeType.medicalFollow: return 'Cita Médica';
    }
  }

  Color _getTypeColor(ChangeType type) {
    switch (type) {
      case ChangeType.swapShift: return Colors.blueAccent;
      case ChangeType.coverShift: return Colors.greenAccent;
      case ChangeType.permission: return Colors.amber;
      case ChangeType.daySwap: return Colors.orangeAccent;
      case ChangeType.sickLeave: return Colors.redAccent;
      case ChangeType.maternityLeave: return Colors.pinkAccent;
      case ChangeType.paternityLeave: return Colors.teal;
      case ChangeType.lactancia: return Colors.pink;
      case ChangeType.bereavement: return Colors.purple;
      case ChangeType.vacation: return Colors.cyan;
      case ChangeType.medicalFollow: return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final requests = controller.pendingRequests;

    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E2C),
      title: Row(
        children: [
          const Icon(Icons.pending_actions, color: Colors.amber),
          const SizedBox(width: 8),
          Text('Solicitudes (${requests.length})', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: requests.isEmpty
            ? const Center(child: Text('No hay solicitudes pendientes', style: TextStyle(color: Colors.grey)))
            : ListView.separated(
                shrinkWrap: true,
                itemCount: requests.length,
                separatorBuilder: (_, __) => const Divider(color: Colors.grey),
                itemBuilder: (context, index) {
                  final r = requests[index];
                  final daysText = r.endDate != null 
                    ? '${r.durationDays} días (${DateFormat('d/M').format(r.date)} - ${DateFormat('d/M').format(r.endDate!)})'
                    : DateFormat('d MMM yyyy').format(r.date);
                  
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getTypeColor(r.type).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.pending, color: _getTypeColor(r.type)),
                    ),
                    title: Text('${r.requesterName} - ${_getTypeLabel(r.type)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(daysText, style: const TextStyle(color: Colors.cyanAccent)),
                        Text(r.reason, style: const TextStyle(color: Colors.white70, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                        if (r.targetName != null) Text('Con: ${r.targetName}', style: const TextStyle(color: Colors.amber, fontSize: 11)),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.download, color: Colors.cyanAccent),
                          onPressed: () => _exportRequest(context, r),
                          tooltip: 'Descargar Documento',
                        ),
                        if (r.type == ChangeType.vacation)
                          IconButton(
                            icon: const Icon(Icons.calculate, color: Colors.orangeAccent),
                            onPressed: () {
                                final startIso = r.date.toIso8601String();
                                final endIso = r.endDate?.toIso8601String() ?? r.date.toIso8601String();
                                context.push(
                                  '/vacation_calculator?workerId=${r.requesterId}&startDate=$startIso&endDate=$endIso'
                                );
                            },
                            tooltip: 'Calcular Pago',
                          ),
                        IconButton(
                          icon: const Icon(Icons.check_circle, color: Colors.green),
                          onPressed: () async {
                              // SIMULATION (Smart Scheduling V1)
                              final simulation = await controller.simulateRequest(r.id);
                              
                              if (simulation != null && context.mounted) {
                                  // Show preview dialog
                                  showDialog(
                                    context: context,
                                    builder: (_) => SimulationPreviewModal(
                                        result: simulation,
                                        onConfirm: () {
                                            Navigator.pop(context); // Close modal
                                            controller.approveRequest(r.id);
                                        },
                                        onCancel: () => Navigator.pop(context),
                                    ),
                                  );
                              } else {
                                  // Fallback if flag disabled or simulation unavailable
                                  controller.approveRequest(r.id);
                              }
                          },
                          tooltip: 'Aprobar',
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () => controller.rejectRequest(r.id),
                          tooltip: 'Rechazar',
                        ),
                      ],
                    ),
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

  Future<void> _exportRequest(BuildContext context, ShiftChangeLog r) async {
    try {
      final worker = await WorkerService().getWorkerById(r.requesterId);
      if (worker == null) return;

      String title = '';
      String content = '';

      if (r.type == ChangeType.vacation) {
        title = 'Solicitud de Vacaciones';
        content = CartaGenerator.generateVacationRequest(
          worker, 
          r.date, 
          r.endDate ?? r.date, 
          days: r.durationDays
        );
      } else {
        title = 'Solicitud de Permiso / Licencia';
        content = CartaGenerator.generatePermissionRequest(
          worker, 
          r.date, 
          _getTypeLabel(r.type), 
          r.reason
        );
      }

      await PdfService.generateGenericDocument(
        title: title,
        content: content,
        companyName: worker.department, // Using department as company name placeholder
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al exportar: $e')));
      }
    }
  }
}
