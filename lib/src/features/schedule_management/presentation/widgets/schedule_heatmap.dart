import 'package:flutter/material.dart';
import 'package:proyecto_empoderate/src/features/schedule_management/logic/schedule_controller.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as do_import_ui;

class ScheduleHeatmap extends StatefulWidget {
  final ScheduleController controller;

  const ScheduleHeatmap({Key? key, required this.controller}) : super(key: key);

  @override
  State<ScheduleHeatmap> createState() => _ScheduleHeatmapState();
}

class _ScheduleHeatmapState extends State<ScheduleHeatmap> {
  String? _hoveredCell;
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workers = widget.controller.workers;
    if (workers.isEmpty) {
      return const Center(
        child: Text('No hay empleados cargados', style: TextStyle(color: Colors.white54)),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purpleAccent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purpleAccent.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: const [
                Icon(Icons.analytics, color: Colors.purpleAccent),
                SizedBox(width: 12),
                Text(
                  'Mapa de Calor - Distribución de Horas',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Icon(Icons.info_outline, color: Colors.white54, size: 20),
              ],
            ),
          ),
          
          // Legend
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text('Intensidad: ', style: TextStyle(color: Colors.white70, fontSize: 12)),
                _buildLegendItem(Colors.green.withOpacity(0.3), 'Baja (0-4h)'),
                const SizedBox(width: 12),
                _buildLegendItem(Colors.yellow.withOpacity(0.3), 'Media (5-8h)'),
                const SizedBox(width: 12),
                _buildLegendItem(Colors.orange.withOpacity(0.3), 'Alta (9-10h)'),
                const SizedBox(width: 12),
                _buildLegendItem(Colors.red.withOpacity(0.3), 'Crítica (>10h)'),
              ],
            ),
          ),

          // Heatmap Table
          Expanded(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  do_import_ui.PointerDeviceKind.touch,
                  do_import_ui.PointerDeviceKind.mouse,
                },
              ),
              child: Scrollbar( // Vertical scrollbar
                controller: _verticalController,
                thumbVisibility: true,
                trackVisibility: true,
                child: SingleChildScrollView(
                  controller: _verticalController,
                  scrollDirection: Axis.vertical,
                  physics: const ClampingScrollPhysics(),
                  child: Scrollbar( // Horizontal scrollbar
                    controller: _horizontalController,
                    thumbVisibility: true,
                    trackVisibility: true,
                    notificationPredicate: (notif) => notif.depth == 1, // Only listen to immediate child
                    child: SingleChildScrollView(
                      controller: _horizontalController,
                      scrollDirection: Axis.horizontal,
                      physics: const ClampingScrollPhysics(),
                      child: _buildHeatmapTable(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.white30),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
      ],
    );
  }

  Widget _buildHeatmapTable() {
    final workers = widget.controller.workers;
    final days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    
    return DataTable(
      headingRowColor: MaterialStateProperty.all(Colors.white.withOpacity(0.05)),
      dataRowColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.hovered)) {
          return Colors.white.withOpacity(0.03);
        }
        return Colors.transparent;
      }),
      columns: [
        DataColumn(
          label: const Text('Empleado', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        ...days.map((day) => DataColumn(
          label: Text(day, style: const TextStyle(color: Colors.cyanAccent, fontSize: 12)),
        )),
        DataColumn(
          label: const Text('Total Semanal', style: TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ],
      rows: [
        ...workers.map((worker) => _buildWorkerRow(worker)),
        _buildTotalRow(days.length),
      ],
    );
  }

  DataRow _buildWorkerRow(worker) {
    final weeklyHours = <double>[];
    double totalHours = 0;

    for (int dayIndex = 0; dayIndex < 7; dayIndex++) {
      final hours = widget.controller.getWorkerWeeklyHours(worker.id);
      final dailyHours = _getDailyHours(worker.id, dayIndex);
      weeklyHours.add(dailyHours);
      totalHours += dailyHours;
    }

    return DataRow(
      cells: [
        DataCell(
          SizedBox(
            width: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  worker.name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  worker.position,
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        ...List.generate(7, (dayIndex) {
          final hours = weeklyHours[dayIndex];
          final cellKey = '${worker.id}_$dayIndex';
          return DataCell(
            MouseRegion(
              onEnter: (_) => setState(() => _hoveredCell = cellKey),
              onExit: (_) => setState(() => _hoveredCell = null),
              child: Container(
                width: 80,
                height: 50,
                decoration: BoxDecoration(
                  color: _getHeatColor(hours),
                  border: Border.all(
                    color: _hoveredCell == cellKey ? Colors.white : Colors.white12,
                    width: _hoveredCell == cellKey ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${hours.toStringAsFixed(1)}h',
                      style: TextStyle(
                        color: hours > 8 ? Colors.white : Colors.white70,
                        fontWeight: hours > 8 ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                    if (_hoveredCell == cellKey && hours > 0)
                      Text(
                        _getShiftName(worker.id, dayIndex),
                        style: const TextStyle(color: Colors.white54, fontSize: 9),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getTotalColor(totalHours),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.purpleAccent.withOpacity(0.5)),
            ),
            child: Text(
              '${totalHours.toStringAsFixed(1)}h',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  DataRow _buildTotalRow(int dayCount) {
    final dailyTotals = <double>[];
    double grandTotal = 0;

    for (int dayIndex = 0; dayIndex < dayCount; dayIndex++) {
      double dayTotal = 0;
      for (var worker in widget.controller.workers) {
        dayTotal += _getDailyHours(worker.id, dayIndex);
      }
      dailyTotals.add(dayTotal);
      grandTotal += dayTotal;
    }

    return DataRow(
      color: MaterialStateProperty.all(Colors.purpleAccent.withOpacity(0.1)),
      cells: [
        const DataCell(
          Text(
            'Total Diario →',
            style: TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold),
          ),
        ),
        ...dailyTotals.map((total) => DataCell(
          Container(
            padding: const EdgeInsets.all(8),
            child: Text(
              '${total.toStringAsFixed(1)}h',
              style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        )),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.purpleAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.purpleAccent),
            ),
            child: Text(
              '${grandTotal.toStringAsFixed(1)}h',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  double _getDailyHours(String workerId, int dayIndex) {
    final workerAssignments = widget.controller.assignments[workerId];
    if (workerAssignments == null) return 0.0;
    
    final shiftId = workerAssignments[dayIndex];
    if (shiftId == null) return 0.0;

    final shift = widget.controller.getShiftById(shiftId);
    if (shift == null) return 0.0;

    final duration = shift.endTime.difference(shift.startTime);
    return duration.inMinutes / 60.0;
  }

  String _getShiftName(String workerId, int dayIndex) {
    final workerAssignments = widget.controller.assignments[workerId];
    if (workerAssignments == null) return '';
    
    final shiftId = workerAssignments[dayIndex];
    if (shiftId == null) return '';

    final shift = widget.controller.getShiftById(shiftId);
    return shift?.name ?? '';
  }

  Color _getHeatColor(double hours) {
    if (hours == 0) return Colors.transparent;
    if (hours <= 4) return Colors.green.withOpacity(0.3);
    if (hours <= 8) return Colors.yellow.withOpacity(0.4);
    if (hours <= 10) return Colors.orange.withOpacity(0.5);
    return Colors.red.withOpacity(0.6);
  }

  Color _getTotalColor(double totalHours) {
    if (totalHours <= 20) return Colors.green.withOpacity(0.2);
    if (totalHours <= 40) return Colors.yellow.withOpacity(0.2);
    if (totalHours <= 48) return Colors.orange.withOpacity(0.2);
    return Colors.red.withOpacity(0.3);
  }
}
