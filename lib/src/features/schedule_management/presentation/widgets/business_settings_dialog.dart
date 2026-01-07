import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_empoderate/src/features/schedule_management/logic/schedule_controller.dart';

/// Dialog for configuring business hours and schedule settings
class BusinessSettingsDialog extends StatefulWidget {
  final ScheduleController controller;

  const BusinessSettingsDialog({Key? key, required this.controller}) : super(key: key);

  @override
  State<BusinessSettingsDialog> createState() => _BusinessSettingsDialogState();
}

class _BusinessSettingsDialogState extends State<BusinessSettingsDialog> {
  late List<bool> _operatingDays;
  late TimeOfDay _openTime;
  late TimeOfDay _closeTime;
  late int _daysOffPerWeek;
  late bool _isPaidLunch;
  late int _lunchDuration;
  late bool _paysNightAsDay;

  final _dayNames = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

  @override
  void initState() {
    super.initState();
    _operatingDays = List.from(widget.controller.operatingDays);
    _openTime = widget.controller.businessOpenTime;
    _closeTime = widget.controller.businessCloseTime;
    _daysOffPerWeek = widget.controller.requiredDaysOffPerWeek;
    _isPaidLunch = widget.controller.isPaidLunch;
    _lunchDuration = widget.controller.lunchDuration;
    _paysNightAsDay = widget.controller.paysNightAsDay;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E2C),
      title: Row(
        children: [
          const Icon(Icons.settings, color: Colors.cyanAccent),
          const SizedBox(width: 8),
          Text('Configuración del Negocio', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // OPERATING DAYS
            Text('Días Operativos', style: GoogleFonts.outfit(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              children: List.generate(7, (i) => FilterChip(
                label: Text(_dayNames[i], style: TextStyle(color: _operatingDays[i] ? Colors.white : Colors.grey)),
                selected: _operatingDays[i],
                selectedColor: Colors.green,
                backgroundColor: Colors.grey.shade800,
                onSelected: (v) => setState(() => _operatingDays[i] = v),
              )),
            ),
            const SizedBox(height: 16),

            // BUSINESS HOURS
            Text('Horario del Local', style: GoogleFonts.outfit(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildTimePicker('Apertura', _openTime, (t) => setState(() => _openTime = t))),
                const SizedBox(width: 16),
                Expanded(child: _buildTimePicker('Cierre', _closeTime, (t) => setState(() => _closeTime = t))),
              ],
            ),
            const SizedBox(height: 16),

            // DAYS OFF PER WEEK
            Text('Días Libres por Semana', style: GoogleFonts.outfit(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
                  onPressed: _daysOffPerWeek > 1 ? () => setState(() => _daysOffPerWeek--) : null,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('$_daysOffPerWeek', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  onPressed: _daysOffPerWeek < 3 ? () => setState(() => _daysOffPerWeek++) : null,
                ),
                const SizedBox(width: 8),
                Text('(Art. 49 C.T.: mín 1)', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 16),

            // PAID LUNCH
            Text('Hora de Almuerzo', style: GoogleFonts.outfit(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SwitchListTile(
              value: _isPaidLunch,
              onChanged: (v) => setState(() => _isPaidLunch = v),
              title: Text(_isPaidLunch ? 'Pagada por la Empresa' : 'No Pagada (se descuenta)', 
                style: TextStyle(color: _isPaidLunch ? Colors.green : Colors.orange)),
              subtitle: Text(
                _isPaidLunch 
                  ? '${_lunchDuration} min incluidos en horas trabajadas (Ley 59 Art. 6)' 
                  : '${_lunchDuration} min se deducen del total de horas',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
              ),
              activeColor: Colors.green,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),

            // LUNCH DURATION SLIDER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Duración del Almuerzo', style: TextStyle(color: Colors.white70, fontSize: 13)),
                Text(
                  '${_lunchDuration} min (${(_lunchDuration / 60).toStringAsFixed(1)} hr)', 
                  style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)
                ),
              ],
            ),
            Slider(
              value: _lunchDuration.toDouble(),
              min: 30,
              max: 120,
              divisions: 6, // 30, 45, 60, 75, 90, 105, 120
              label: '${_lunchDuration} min',
              activeColor: Colors.cyanAccent,
              inactiveColor: Colors.grey.shade800,
              onChanged: (v) => setState(() => _lunchDuration = v.round()),
            ),
            const SizedBox(height: 16),


            // NIGHT/MIXED SHIFT EQUIVALENCE
            Text('Jornadas Nocturna/Mixta', style: GoogleFonts.outfit(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SwitchListTile(
              value: _paysNightAsDay,
              onChanged: (v) => setState(() => _paysNightAsDay = v),
              title: Text(_paysNightAsDay ? '7h Noche = 8h Pago' : 'Se pagan horas exactas', 
                style: TextStyle(color: _paysNightAsDay ? Colors.green : Colors.orange)),
              subtitle: Text(
                'Art. 31 C.T.: 7h nocturnas o 7.5h mixtas se pagan como 8h diurnas',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
              ),
              activeColor: Colors.green,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
          onPressed: _save,
          child: const Text('Guardar', style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }

  Widget _buildTimePicker(String label, TimeOfDay time, Function(TimeOfDay) onChanged) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(context: context, initialTime: time);
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade600),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: Colors.cyanAccent, size: 18),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
                Text(_formatTime(time), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:${t.minute.toString().padLeft(2, '0')} $period';
  }

  void _save() {
    widget.controller.operatingDays = _operatingDays;
    widget.controller.businessOpenTime = _openTime;
    widget.controller.businessCloseTime = _closeTime;
    widget.controller.requiredDaysOffPerWeek = _daysOffPerWeek;
    widget.controller.isPaidLunch = _isPaidLunch;
    widget.controller.lunchDuration = _lunchDuration;
    widget.controller.paysNightAsDay = _paysNightAsDay;
    // Trigger rebuild by calling a public method that notifies
    widget.controller.notifyConfigChanged();
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuración guardada')),
    );
  }
}
