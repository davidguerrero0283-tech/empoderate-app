import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_empoderate/src/features/schedule_management/logic/schedule_controller.dart';
import 'package:proyecto_empoderate/src/calculators/schedule_models.dart';
import 'package:proyecto_empoderate/src/calculators/salario_models.dart';

import 'dart:ui' as do_import_ui;

class ScheduleGrid extends StatefulWidget {
  const ScheduleGrid({Key? key}) : super(key: key);

  @override
  State<ScheduleGrid> createState() => _ScheduleGridState();
}

class _ScheduleGridState extends State<ScheduleGrid> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ScheduleController>(context);
    final workers = controller.workers;

    return Center(
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            do_import_ui.PointerDeviceKind.touch,
            do_import_ui.PointerDeviceKind.mouse,
          },
        ),
        child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          trackVisibility: true,
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- HEADER ---
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _headerCell('EMPLEADO', 200),
                          for (var dayLabel in controller.dayLabels)
                            _headerCell(dayLabel, 120),
                          _headerCell('HRS', 80),
                        ],
                      ),
                    ),

                    // --- WORKER ROWS ---
                    if (workers.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text('No hay empleados.', style: TextStyle(color: Colors.grey.shade600)),
                      )
                    else
                      ...List.generate(workers.length, (index) {
                        final worker = workers[index];
                        return Container(
                           height: 50,
                           decoration: BoxDecoration(
                             color: index % 2 == 0 ? Colors.white : Colors.grey.shade50,
                             border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                           ),
                           child: Row(
                             children: [
                               // Name Column
                               SizedBox(
                                 width: 200,
                                 child: Padding(
                                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                   child: Column(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     mainAxisAlignment: MainAxisAlignment.center,
                                     children: [
                                       Text(worker.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87), overflow: TextOverflow.ellipsis),
                                       Text(worker.position, style: TextStyle(fontSize: 10, color: Colors.grey.shade600), overflow: TextOverflow.ellipsis),
                                     ],
                                   ),
                                 ),
                               ),
                               
                               // Days Columns (EDITING FIX)
                               for (int i = 0; i < controller.totalDays; i++)
                                 SizedBox(
                                   width: 120,
                                   child: _ShiftCell(
                                     workerId: worker.id,
                                     dayIndex: i,
                                     shiftId: controller.assignments[worker.id]?[i],
                                   ),
                                 ),
                               
                               // Hours Column
                               SizedBox(
                                 width: 80,
                                 child: Center(
                                   child: Text(
                                     '${controller.getWorkerWeeklyHours(worker.id).toStringAsFixed(1)}h',
                                     style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                                   ),
                                 ),
                               ),
                             ],
                           ),
                        );
                      }),
                      
                     // --- FOOTER/TOTALS ---
                     Container(
                       height: 36,
                       decoration: BoxDecoration(
                         color: Colors.grey.shade100,
                         borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                       ),
                       child: Row(
                          children: [
                            _headerCell('TOTAL', 200),
                            for (int i = 0; i < controller.totalDays; i++)
                              _headerCell('${controller.getDailyAssignedCount(i)}', 120),
                            _headerCell('${controller.totalWeeklyHours.toStringAsFixed(0)}h', 80),
                          ],
                       ),
                     ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerCell(String text, double width) {
    return SizedBox(
      width: width,
      child: Center(
        child: Text(text, style: GoogleFonts.outfit(color: Colors.blueGrey.shade800, fontSize: 11, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _ShiftCell extends StatelessWidget {
  final String workerId;
  final int dayIndex;
  final String? shiftId;

  const _ShiftCell({
    Key? key,
    required this.workerId,
    required this.dayIndex,
    this.shiftId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ScheduleController>(context, listen: false);
    final shift = controller.getShiftById(shiftId);
    final cellStatus = controller.getCellStatus(workerId, dayIndex);

    // Determine colors and content based on status
    Color bgColor;
    Color borderColor;
    Widget content;

    if (cellStatus != null && cellStatus.type != CellStatusType.normal) {
      // Special status (permission, sick leave, etc.)
      bgColor = cellStatus.color.withOpacity(0.25);
      borderColor = cellStatus.color;
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(cellStatus.icon, size: 14, color: cellStatus.color),
          const SizedBox(height: 2),
          Text(
            cellStatus.label,
            style: TextStyle(color: cellStatus.color, fontSize: 9, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else if (shift != null) {
      // Normal shift - show time range
      bgColor = shift.color.withOpacity(0.2);
      borderColor = shift.color.withOpacity(0.6);
      content = Text(
        controller.getShiftTimeRange(shift),
        style: const TextStyle(color: Colors.black87, fontSize: 9, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      );
    } else {
      // Empty cell
      bgColor = Colors.transparent;
      borderColor = Colors.grey.shade300;
      content = const Icon(Icons.add, size: 14, color: Colors.grey);
    }

    // Get lunch tooltip text
    final lunchInfo = controller.getLunchInfoString(workerId, dayIndex);

    Widget cellWidget = InkWell(
      onTap: () => _showCellDialog(context, controller, cellStatus, shift),
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: borderColor, width: cellStatus != null ? 2 : 1),
        ),
        child: Center(child: content),
      ),
    );

    // Wrap with tooltip if there's lunch info
    if (lunchInfo.isNotEmpty) {
      return Tooltip(
        message: lunchInfo,
        textStyle: const TextStyle(color: Colors.white, fontSize: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(8),
        ),
        child: cellWidget,
      );
    }

    return cellWidget;
  }

  void _showCellDialog(BuildContext context, ScheduleController controller, CellStatus? status, ShiftSlot? shift) {
    if (status != null && status.type != CellStatusType.normal) {
      // Show status details popup
      _showStatusDetailsDialog(context, controller, status);
    } else {
      // Show shift selection
      _showShiftSelectionDialog(context, controller, workerId, dayIndex);
    }
  }

  void _showStatusDetailsDialog(BuildContext context, ScheduleController controller, CellStatus status) {
    final worker = controller.workers.firstWhere(
      (w) => w.id == workerId,
      orElse: () => WorkerProfile(id: '', name: 'Desconocido', position: '', department: '', paymentMode: PayrollFrequency.quincenal, basePayment: 0),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        title: Row(
          children: [
            Icon(status.icon, color: status.color),
            const SizedBox(width: 8),
            Text(status.label, style: const TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('Empleado', worker.name),
            _infoRow('Día', controller.dayLabels[dayIndex]),
            if (status.reason != null) _infoRow('Motivo', status.reason!),
            if (status.targetName != null) _infoRow('Colega', status.targetName!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.removeCellStatus(workerId, dayIndex);
              Navigator.pop(ctx);
            },
            child: const Text('Quitar Estado', style: TextStyle(color: Colors.redAccent)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar', style: TextStyle(color: Colors.cyanAccent)),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  void _showShiftSelectionDialog(BuildContext context, ScheduleController controller, String wId, int dIdx) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        title: const Text('Asignar Turno', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Show current lunch if shift assigned
              if (controller.assignments[wId]?[dIdx] != null) ...[
                ListTile(
                  title: Text('Editar Hora de Almuerzo', style: const TextStyle(color: Colors.amber)),
                  subtitle: Text(controller.getLunchInfoString(wId, dIdx), style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                  leading: const Icon(Icons.restaurant, color: Colors.amber),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final currentLunch = controller.getLunchTime(wId, dIdx);
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: currentLunch ?? TimeOfDay(hour: 12, minute: 0),
                    );
                    if (picked != null) {
                      controller.setLunchTime(wId, dIdx, picked);
                    }
                  },
                ),
                if (controller.lunchBreakOverrides.containsKey('${wId}_$dIdx'))
                  ListTile(
                    title: const Text('Restablecer Almuerzo (Auto)', style: TextStyle(color: Colors.grey)),
                    leading: const Icon(Icons.refresh, color: Colors.grey),
                    onTap: () {
                      controller.clearLunchOverride(wId, dIdx);
                      Navigator.pop(ctx);
                    },
                  ),
                const Divider(color: Colors.grey),
              ],
              ListTile(
                title: const Text('Libre (Día Off)', style: TextStyle(color: Colors.white)),
                leading: const Icon(Icons.weekend, color: Colors.grey),
                onTap: () {
                  controller.clearAssignment(wId, dIdx);
                  controller.setCellStatus(wId, dIdx, CellStatus(type: CellStatusType.dayOff));
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                title: const Text('Sin Turno (Borrar)', style: TextStyle(color: Colors.redAccent)),
                leading: const Icon(Icons.close, color: Colors.red),
                onTap: () {
                  controller.clearAssignment(wId, dIdx);
                  controller.clearCellStatus(wId, dIdx);
                  Navigator.pop(ctx);
                },
              ),
              const Divider(color: Colors.grey),
              ...controller.shifts.map((ShiftSlot s) => ListTile(
                title: Text(s.name, style: const TextStyle(color: Colors.white)),
                subtitle: Text(controller.getShiftTimeRange(s), style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                leading: Icon(Icons.circle, color: s.color),
                onTap: () {
                  controller.assignShift(wId, dIdx, s.id);
                  controller.clearCellStatus(wId, dIdx);
                  Navigator.pop(ctx);
                },
              )),
            ],
          ),
        ),
      ),
    );
  }
}

