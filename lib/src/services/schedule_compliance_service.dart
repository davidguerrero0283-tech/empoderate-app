import '../calculators/schedule_models.dart';
import '../calculators/salario_models.dart';
import '../services/worker_service.dart';

class ComplianceIssue {
  final String title;
  final String article;
  final String description;
  final String workerName;
  final ComplianceSeverity severity;
  
  ComplianceIssue({
    required this.title,
    required this.article,
    required this.description,
    required this.workerName,
    required this.severity,
  });
}

enum ComplianceSeverity {
  violation, // Red
  warning,   // Orange
  info,      // Blue
}

class LaborComplianceChecker {
  /// Validate a full schedule against Panama Labor Code
  List<ComplianceIssue> checkCompliance(
    Map<String, Map<int, String?>> assignments, // workerId -> dayIndex -> slotId
    List<WorkerProfile> workers,
    List<ShiftSlot> shifts, // List of defined shifts
  ) {
    final issues = <ComplianceIssue>[];
    
    // Map shifts by ID for faster lookup
    final shiftMap = {for (var s in shifts) s.id: s};
    
    for (var worker in workers) {
      if (!assignments.containsKey(worker.id)) continue;
      
      final workerAssignments = assignments[worker.id]!;
      int totalMinutes = 0;
      int daysWorked = 0;
      
      // Calculate daily stats
      for (int day = 0; day < 7; day++) {
        final slotId = workerAssignments[day];
        if (slotId != null && shiftMap.containsKey(slotId)) {
          final shift = shiftMap[slotId]!;
           
           // Calculate duration
           final start = shift.startTime.hour * 60 + shift.startTime.minute;
           int end = shift.endTime.hour * 60 + shift.endTime.minute;
           if (end <= start) end += 24 * 60; // Crosses midnight
           
           final durationMinutes = end - start;
           totalMinutes += durationMinutes;
           daysWorked++;
           
           // Art 32: Max 8 hours (diurna)
           if (durationMinutes > 8 * 60) {
              issues.add(ComplianceIssue(
                title: 'Jornada Diaria Excedida',
                article: 'Art. 32 (C.T.)',
                description: 'Turno de ${(durationMinutes/60).toStringAsFixed(1)}h excede límite de 8h',
                workerName: worker.name,
                severity: ComplianceSeverity.warning,
              ));
           }
        }
      }
      
      // Art 31: Max 48 hours weekly
      if (totalMinutes > 48 * 60) {
        issues.add(ComplianceIssue(
          title: 'Exceso Jornada Semanal',
          article: 'Art. 31 (C.T.)',
          description: 'Acumulado ${(totalMinutes/60).toStringAsFixed(1)}h (Máx 48h)',
          workerName: worker.name,
          severity: ComplianceSeverity.violation,
        ));
      }
      
      // Art 49: Descanso semanal
      if (daysWorked > 6) {
         issues.add(ComplianceIssue(
          title: 'Sin Día de Descanso',
          article: 'Art. 49 (C.T.)',
          description: 'Trabaja los 7 días de la semana sin descanso',
          workerName: worker.name,
          severity: ComplianceSeverity.violation,
        ));
      }
    }
    
    return issues;
  }
}
