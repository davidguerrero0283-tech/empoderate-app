import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_empoderate/src/features/schedule_management/logic/schedule_controller.dart';
import 'package:proyecto_empoderate/src/services/vacation_eligibility_service.dart';
import 'package:proyecto_empoderate/src/calculators/salario_models.dart';
import 'package:proyecto_empoderate/src/calculators/schedule_models.dart';
import 'shift_change_request_dialog.dart';

class VacationAlert extends StatefulWidget {
  final ScheduleController controller;

  const VacationAlert({Key? key, required this.controller}) : super(key: key);

  @override
  State<VacationAlert> createState() => _VacationAlertState();
}

class _VacationAlertState extends State<VacationAlert> {
  final VacationEligibilityService _eligibilityService = VacationEligibilityService();

  @override
  Widget build(BuildContext context) {
    final workersNeedingVacation = _getWorkersNeedingVacation();
    
    if (workersNeedingVacation.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C), // Matching theme
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orangeAccent.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.orangeAccent.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notification_important, color: Colors.orangeAccent, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '⚠️ Alertas del Personal',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              // CHOOSE COLLABORATOR BUTTON
              TextButton.icon(
                onPressed: () => _showWorkerSelectionDialog(context),
                icon: const Icon(Icons.person_search, size: 16, color: Colors.cyanAccent),
                label: const Text('Elegir colaborador', style: TextStyle(fontSize: 12, color: Colors.cyanAccent)),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Los siguientes empleados necesitan programar sus vacaciones:',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 8),
          _buildVacationTchips(workersNeedingVacation),
          
          if (widget.controller.pendingRequests.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.white10),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.pending_actions, color: Colors.amberAccent, size: 20),
                const SizedBox(width: 12),
                Text(
                  'Hay ${widget.controller.pendingRequests.length} solicitudes pendientes de permisos/cambios',
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _showPendingRequests(context),
                  child: const Text('Revisar Todas', style: TextStyle(color: Colors.amberAccent, fontSize: 12)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVacationTchips(List<Map<String, dynamic>> workers) {
    if (workers.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: workers.take(5).map((worker) { // Show top 5 in card
        final days = worker['days'] as int;
        final color = _getPriorityColor(days);
        return InkWell(
          onTap: () => _openLeaveRequest(context, worker['worker']),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person, color: color, size: 14),
                const SizedBox(width: 6),
                Text(
                  worker['name'],
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$days d',
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  List<Map<String, dynamic>> _getWorkersNeedingVacation() {
    final List<Map<String, dynamic>> needsVacation = [];
    
    for (var worker in widget.controller.workers) {
      final daysAvailable = _eligibilityService.getTotalPendingDays(worker);
      
      if (daysAvailable > 0) {
        needsVacation.add({
          'id': worker.id,
          'name': worker.name,
          'days': daysAvailable,
          'worker': worker,
        });
      }
    }
    
    // SORT BY DAYS OWED (Highest First) - User Request #1
    needsVacation.sort((a, b) => (b['days'] as int).compareTo(a['days'] as int));
    
    return needsVacation;
  }

  Color _getPriorityColor(int days) {
    if (days >= 30) return Colors.redAccent;
    if (days >= 15) return Colors.orangeAccent;
    return Colors.cyanAccent;
  }



  void _showWorkerSelectionDialog(BuildContext context) {
    final workers = _getWorkersNeedingVacation();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        title: Row(
          children: [
            const Icon(Icons.person_search, color: Colors.cyanAccent),
            const SizedBox(width: 12),
            Text('Prioridad de Vacaciones', style: GoogleFonts.outfit(color: Colors.white)),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Colaboradores ordenados por días adeudados (Mayor a menor).',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: workers.length,
                  itemBuilder: (context, index) {
                    final item = workers[index];
                    final days = item['days'] as int;
                    final color = _getPriorityColor(days);
                    final WorkerProfile worker = item['worker'];

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: color.withOpacity(0.2),
                        child: Text('${index + 1}', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                      ),
                      title: Text(worker.name, style: const TextStyle(color: Colors.white)),
                      subtitle: Text(worker.position, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: color.withOpacity(0.5)),
                        ),
                        child: Text(
                          '$days días',
                          style: TextStyle(color: color, fontWeight: FontWeight.bold),
                        ),
                      ),
                      onTap: () {
                      final selectedWorker = worker; // Capture worker
                      Navigator.pop(ctx);
                      //  delay to ensure dialog closes
                      Future.delayed(const Duration(milliseconds: 200), () {
                        if (mounted) {
                          _openLeaveRequest(this.context, selectedWorker);
                        }
                      });
                    },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
        ],
      ),
    );
  }

  void _openLeaveRequest(BuildContext context, WorkerProfile worker) {
    showDialog(
      context: context,
      builder: (ctx) => ShiftChangeRequestDialog(
        controller: widget.controller,
        initialWorker: worker,
      ),
    );
  }

  void _showPendingRequests(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => PendingRequestsPanel(controller: widget.controller),
    );
  }
}
