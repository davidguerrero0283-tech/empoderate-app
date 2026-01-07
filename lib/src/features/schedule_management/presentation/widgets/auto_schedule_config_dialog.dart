import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_empoderate/src/calculators/schedule_models.dart';
import '../../logic/schedule_controller.dart';
import 'package:proyecto_empoderate/src/features/rrhh/scheduling_intelligence/models/auto_schedule_config.dart';

class AutoScheduleConfigDialog extends StatefulWidget {
  final ScheduleController controller;

  const AutoScheduleConfigDialog({Key? key, required this.controller}) : super(key: key);

  @override
  State<AutoScheduleConfigDialog> createState() => _AutoScheduleConfigDialogState();
}

class _AutoScheduleConfigDialogState extends State<AutoScheduleConfigDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, Map<String, int>> _roleRequirements = {};
  Set<String> _availableRoles = {};

  Map<String, List<DateTime>> _unavailableDates = {};
  RotationMode _rotationMode = RotationMode.rotating;
  double _fairnessWeight = 0.5;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); 
    _initializeData();
  }

  void _initializeData() {
    debugPrint('AutoScheduleConfigDialog: Initializing with ${widget.controller.workers.length} workers');
    
    // Extract unique roles from workers
    _availableRoles = widget.controller.workers
        .map((w) => w.position.trim()) // Trim whitespace
        .where((p) => p.isNotEmpty)
        .toSet();

    // FALLBACK: If no roles found (e.g. all empty strings) but workers exist, use "Empleado General"
    if (_availableRoles.isEmpty && widget.controller.workers.isNotEmpty) {
      _availableRoles.add('Empleado General');
    }
    
    debugPrint('AutoScheduleConfigDialog: Found roles: $_availableRoles');

    // Initialize requirements with 0 or default
    for (var shift in widget.controller.shifts) {
      _roleRequirements[shift.id] = {
        for (var role in _availableRoles) role: 0 
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E1E2C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 900, // Slightly wider for calendar view
        height: 700,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            Row(
              children: const [
                Icon(Icons.tune, color: Colors.cyanAccent),
                SizedBox(width: 12),
                Text('Configuración Avanzada de Horario', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Personaliza los requisitos y restricciones antes de generar.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            // TABS
            TabBar(
              controller: _tabController,
              indicatorColor: Colors.cyanAccent,
              labelColor: Colors.cyanAccent,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: 'Requisitos por Cargo'),
                Tab(text: 'Disponibilidad'),
                Tab(text: 'Patrones'),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildRoleRequirementsTab(),
                  _buildAvailabilityTab(),
                  _buildPatternsTab(),
                ],
              ),
            ),
            
            // Footer buttons
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Generar Horario'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: _generate,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleRequirementsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Explanatory header
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
          ),
          child: Row(
            children: const [
              Icon(Icons.info_outline, color: Colors.blueAccent, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Define cuántas personas de cada cargo necesitas por turno',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: widget.controller.shifts.length,
            itemBuilder: (context, index) {
              final shift = widget.controller.shifts[index];
              return Card(
                color: Colors.white.withOpacity(0.05),
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(width: 4, height: 24, color: shift.color),
                          const SizedBox(width: 12),
                          Text(
                            '${shift.name} (${DateFormat('HH:mm').format(shift.startTime)} - ${DateFormat('HH:mm').format(shift.endTime)})',
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          // Helper text for total count
                          Row(
                            children: [
                              const Icon(Icons.people, color: Colors.cyanAccent, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                'Total: ${_roleRequirements[shift.id]?.values.fold(0, (sum, val) => sum! + val) ?? 0} personas',
                                style: const TextStyle(color: Colors.cyanAccent, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white12),
                      Wrap(
                        spacing: 24,
                        runSpacing: 12,
                        children: _availableRoles.map((role) {
                          final currentCount = _roleRequirements[shift.id]?[role] ?? 0;
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 120,
                                child: Text(role.length > 15 ? '${role.substring(0, 15)}...' : role, 
                                  style: const TextStyle(color: Colors.white70)
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.grey, size: 20),
                                onPressed: () => _updateCount(shift.id, role, -1),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: currentCount > 0 ? Colors.cyanAccent.withOpacity(0.1) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: currentCount > 0 ? Colors.cyanAccent : Colors.white24,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.person, 
                                      color: currentCount > 0 ? Colors.cyanAccent : Colors.white38, 
                                      size: 14
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$currentCount', 
                                      style: TextStyle(
                                        color: currentCount > 0 ? Colors.white : Colors.white54, 
                                        fontWeight: FontWeight.bold, 
                                        fontSize: 16
                                      )
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, color: Colors.cyanAccent, size: 20),
                                onPressed: () => _updateCount(shift.id, role, 1),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _updateCount(String shiftId, String role, int delta) {
    setState(() {
      final current = _roleRequirements[shiftId]?[role] ?? 0;
      final newCount = (current + delta).clamp(0, 50); // Reasonable max
      _roleRequirements[shiftId]![role] = newCount;
    });
  }

  Widget _buildAvailabilityTab() {
    final weekStart = widget.controller.weekStart;
    final dayLabels = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

    return ListView( // Use ListView to make everything scrollable
      children: [
        // 1. The "Chocolate" Card (Restricciones Preventivas)
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orangeAccent.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.event_busy, color: Colors.orangeAccent, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Restricciones Preventivas (ANTES de generar)',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '• Usa esta sección para restricciones CONOCIDAS de antemano\n'
                '• Ejemplos: Vacaciones planificadas, clases permanentes, días fijos de estudio\n'
                '• El generador automático NO asignará turnos en estos días marcados\n'
                '• Es PREVENTIVO: evita problemas antes de crear el horario',
                style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
              ),
              const SizedBox(height: 12),
              const Divider(color: Colors.white24),
              const SizedBox(height: 8),
              Row(
                children: const [
                  Icon(Icons.swap_horiz, color: Colors.blueAccent, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Para cambios de último minuto',
                    style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Usa "Solicitar Cambio" en el Asistente IA (emergencias, incapacidades, permisos imprevistos). Es REACTIVO: modifica un horario ya existente y requiere aprobación.',
                style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.3, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),

        // 2. The Worker List
        ...widget.controller.workers.map((worker) {
          final workerUnavailable = _unavailableDates[worker.id] ?? [];
          
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 200,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(worker.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          Text(worker.position, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(7, (dayIndex) {
                          final date = weekStart.add(Duration(days: dayIndex));
                          // Simple date compare logic
                          final isUnavailable = workerUnavailable.any((d) => 
                            d.year == date.year && d.month == date.month && d.day == date.day
                          );

                          return InkWell(
                            onTap: () => _toggleUnavailable(worker.id, date),
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isUnavailable ? Colors.red.withOpacity(0.2) : Colors.transparent,
                                border: Border.all(
                                  color: isUnavailable ? Colors.redAccent : Colors.white24,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(dayLabels[dayIndex], style: TextStyle(
                                    color: isUnavailable ? Colors.redAccent : Colors.white70,
                                    fontSize: 10,
                                  )),
                                  if (isUnavailable)
                                    const Icon(Icons.block, color: Colors.redAccent, size: 14),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white12),
            ],
          );
        }).toList(),
      ],
    );
  }

  void _toggleUnavailable(String workerId, DateTime date) {
    setState(() {
      final list = _unavailableDates[workerId] ?? [];
      final existsIndex = list.indexWhere((d) => 
        d.year == date.year && d.month == date.month && d.day == date.day
      );

      if (existsIndex >= 0) {
        list.removeAt(existsIndex);
      } else {
        list.add(date);
      }
      _unavailableDates[workerId] = list;
    });
  }

  Widget _buildPatternsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Elige cómo deben rotar los turnos durante la semana.',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 32),
          
          RadioListTile<RotationMode>(
            title: const Text('Rotativo (Dinámico)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: const Text(
              'Optimiza la cobertura diaria. Los empleados pueden tener turnos diferentes cada día según la necesidad.',
              style: TextStyle(color: Colors.white54),
            ),
            value: RotationMode.rotating,
            groupValue: _rotationMode,
            activeColor: Colors.cyanAccent,
            onChanged: (val) => setState(() => _rotationMode = val!),
          ),
          
          const Divider(color: Colors.white12),

          RadioListTile<RotationMode>(
            title: const Text('Turnos Fijos (Estático)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: const Text(
              'Intenta mantener el mismo horario toda la semana para cada empleado (ej. siempre Mañana).',
              style: TextStyle(color: Colors.white54),
            ),
            value: RotationMode.fixed,
            groupValue: _rotationMode,
            activeColor: Colors.purpleAccent,
            onChanged: (val) => setState(() => _rotationMode = val!),
          ),
          
          const SizedBox(height: 32),
          const Divider(color: Colors.white24, thickness: 2),
          const SizedBox(height: 24),
          
          // Fairness Slider (moved here)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Estrategia de Asignación', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(
                      _fairnessWeight == 0.5 ? 'Balanceado' : (_fairnessWeight < 0.5 ? 'Priorizar Costos (Eficiencia)' : 'Priorizar Equidad (Horas)'),
                      style: TextStyle(color: _fairnessWeight == 0.5 ? Colors.white70 : (_fairnessWeight < 0.5 ? Colors.greenAccent : Colors.orangeAccent)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.attach_money, color: Colors.greenAccent, size: 20),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.white54,
                          inactiveTrackColor: Colors.white24,
                          thumbColor: _fairnessWeight < 0.5 ? Colors.greenAccent : (_fairnessWeight > 0.5 ? Colors.orangeAccent : Colors.white),
                          overlayColor: Colors.white.withOpacity(0.2),
                        ),
                        child: Slider(
                          value: _fairnessWeight,
                          onChanged: (val) => setState(() => _fairnessWeight = val),
                          min: 0.0,
                          max: 1.0,
                          divisions: 4,
                          label: _fairnessWeight.toStringAsFixed(2),
                        ),
                      ),
                    ),
                    const Icon(Icons.group, color: Colors.orangeAccent, size: 20),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Más Barato', style: TextStyle(color: Colors.white38, fontSize: 10)),
                    Text('Más Justo', style: TextStyle(color: Colors.white38, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _generate() {
    final config = AutoScheduleConfig(
      roleRequirements: _roleRequirements,
      unavailableDates: _unavailableDates,
      rotationMode: _rotationMode,
      fairnessWeight: _fairnessWeight,
    );
    Navigator.pop(context, config); 
  }
}
