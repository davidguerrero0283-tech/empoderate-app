import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../calculators/schedule_models.dart';
import '../calculators/salario_models.dart';
import 'worker_service.dart';
import '../features/rrhh/scheduling_intelligence/models/auto_schedule_config.dart'; // Import RotationMode


class ScheduleService {
  static const String _templatesKey = 'schedule_templates';
  static const String _schedulesKey = 'weekly_schedules';

  // --- TEMPLATES ---

  Future<List<ScheduleTemplate>> getTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_templatesKey);
    if (data == null) return [];
    final List<dynamic> decoded = jsonDecode(data);
    return decoded.map((e) => ScheduleTemplate.fromJson(e)).toList();
  }

  Future<void> saveTemplate(ScheduleTemplate template) async {
    final templates = await getTemplates();
    final index = templates.indexWhere((t) => t.id == template.id);
    if (index >= 0) {
      templates[index] = template;
    } else {
      templates.add(template);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_templatesKey, jsonEncode(templates.map((e) => e.toJson()).toList()));
  }

  Future<void> deleteTemplate(String id) async {
    final templates = await getTemplates();
    templates.removeWhere((t) => t.id == id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_templatesKey, jsonEncode(templates.map((e) => e.toJson()).toList()));
  }

  // --- WEEKLY SCHEDULES ---

  Future<List<WeeklySchedule>> getSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_schedulesKey);
    if (data == null) return [];
    final List<dynamic> decoded = jsonDecode(data);
    return decoded.map((e) => WeeklySchedule.fromJson(e)).toList();
  }

  Future<void> saveSchedule(WeeklySchedule schedule) async {
    final schedules = await getSchedules();
    final index = schedules.indexWhere((s) => s.id == schedule.id);
    if (index >= 0) {
      schedules[index] = schedule;
    } else {
      schedules.add(schedule);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_schedulesKey, jsonEncode(schedules.map((e) => e.toJson()).toList()));
  }

  Future<void> deleteSchedule(String id) async {
    final schedules = await getSchedules();
    schedules.removeWhere((s) => s.id == id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_schedulesKey, jsonEncode(schedules.map((e) => e.toJson()).toList()));
  }

  // --- LOGIC: AUTOMATIC GENERATION / SHUFFLE ---

  Future<WeeklySchedule> generateWeeklySchedule({
    required DateTime startDate,
    required ScheduleTemplate template,
    required List<WorkerProfile> workers,
    Map<String, List<DateTime>>? unavailableDates,
    RotationMode rotationMode = RotationMode.rotating,
    double fairnessWeight = 0.5, // 0.0 = Cheap, 1.0 = Fair
  }) async {
    final List<WorkerAssignment> assignments = [];
    final DateTime endDate = startDate.add(const Duration(days: 6));
    
    // Track worker shifts count for fairness
    final Map<String, int> workerShiftCount = {for (var w in workers) w.id : 0};
    
    // For Fixed Rotation: Track which slot (if any) a worker is assigned to
    final Map<String, String?> workerFixedSlot = {for (var w in workers) w.id : null};

    // Pre-calculate max hourly rate for normalization (avoid div/0)
    double maxRate = 1.0;
    if (workers.isNotEmpty) {
      maxRate = workers.map((w) => w.hourlyRate ?? 0.0).reduce((a, b) => a > b ? a : b);
      if (maxRate == 0) maxRate = 1.0;
    }
    
    // For each day of the week
    for (int i = 0; i < 7; i++) {
        // ... (day loop setup same as before)
      final DateTime currentDate = startDate.add(Duration(days: i));
      final int dayOfWeek = currentDate.weekday;
      
      final demand = template.weeklyDemand.firstWhere(
        (d) => d.dayOfWeek == dayOfWeek,
        orElse: () => DailyDemand(dayOfWeek: dayOfWeek, requirements: []),
      );

      // Randomize worker list for fairness each day
      final shuffledWorkers = List<WorkerProfile>.from(workers)..shuffle();

      // 1. Filter workers who are NOT on vacation AND NOT unavailable
      final availableToday = shuffledWorkers.where((w) {
        // Vacation Check
        final isOnVacation = w.vacationHistory.any((v) => 
          (currentDate.isAfter(v.startDate) || currentDate.isAtSameMomentAs(v.startDate)) &&
          (currentDate.isBefore(v.endDate) || currentDate.isAtSameMomentAs(v.endDate))
        );
        if (isOnVacation) return false;

        // Custom Availability Check (Config)
        if (unavailableDates != null && unavailableDates.containsKey(w.id)) {
           final dates = unavailableDates[w.id]!;
           final isUnavailable = dates.any((d) => 
             d.year == currentDate.year && d.month == currentDate.month && d.day == currentDate.day
           );
           if (isUnavailable) return false;
        }

        return true;
      }).toList();

      // 2. Assign to slots based on demand
      final List<WorkerProfile> assignedToday = [];
      
      for (var req in demand.requirements) {
        int filled = 0;
        
        // SORTING STRATEGY
        if (rotationMode == RotationMode.fixed) {
           // ... (Fixed Logic Same as Before)
           // Prioritize: 
           // 1. Workers ALREADY assigned to THIS slot ID (Sticky)
           // 2. Workers NOT assigned to ANY slot ID yet (Fresh)
           // 3. (Avoid moving workers from other slots if possible)
           availableToday.sort((a, b) {
             final aHasThisSlot = workerFixedSlot[a.id] == req.slotId;
             final bHasThisSlot = workerFixedSlot[b.id] == req.slotId;
             if (aHasThisSlot && !bHasThisSlot) return -1; // a comes first
             if (!aHasThisSlot && bHasThisSlot) return 1;
             
             final aFree = workerFixedSlot[a.id] == null;
             final bFree = workerFixedSlot[b.id] == null;
             if (aFree && !bFree) return -1;
             if (!aFree && bFree) return 1;

             return (workerShiftCount[a.id] ?? 0).compareTo(workerShiftCount[b.id] ?? 0);
           });
        } else {
           // Rotating: Sort by Weighted Score
           // Efficiency (Cost): Lower Rate is better
           // Fairness (Count): Lower Count is better (to distribute/catch up)
           
           availableToday.sort((a, b) {
             final countA = workerShiftCount[a.id] ?? 0;
             final countB = workerShiftCount[b.id] ?? 0;
             
             // Normalize Count (local to this week so far) - approx max 7
             final normCountA = countA / 7.0; 
             final normCountB = countB / 7.0;
             
             // Normalize Rate (with null safety)
             final normRateA = (a.hourlyRate ?? 0.0) / maxRate;
             final normRateB = (b.hourlyRate ?? 0.0) / maxRate;
             
             // Score (Lower is better)
             // If weight = 0 (Efficiency), strictly Rate.
             // If weight = 1 (Fairness), strictly Count.
             final scoreA = (normRateA * (1 - fairnessWeight)) + (normCountA * fairnessWeight);
             final scoreB = (normRateB * (1 - fairnessWeight)) + (normCountB * fairnessWeight);
             
             return scoreA.compareTo(scoreB);
           });
        }

        for (var w in availableToday) {
          if (filled >= req.employeeCount) break;
          // If Fixed Mode: Don't assign if they belong to another slot (unless they are free)
          if (rotationMode == RotationMode.fixed) {
            final fixedSlot = workerFixedSlot[w.id];
            if (fixedSlot != null && fixedSlot != req.slotId) continue; 
          }

          if (assignedToday.contains(w)) continue;

          assignments.add(WorkerAssignment(
            workerId: w.id,
            workerName: w.name,
            date: currentDate,
            slotId: req.slotId,
          ));
          
          assignedToday.add(w);
          workerShiftCount[w.id] = (workerShiftCount[w.id] ?? 0) + 1;
          
          // Lock them to this slot if fixed mode
          if (rotationMode == RotationMode.fixed && workerFixedSlot[w.id] == null) {
            workerFixedSlot[w.id] = req.slotId;
          }
          
          filled++;
        }
      }

      // 3. Mark the rest...
      for (var w in workers) {
        if (!assignedToday.map((a) => a.id).contains(w.id)) {
           // ... (same vacation check logic)
          final isOnVacation = w.vacationHistory.any((v) => 
            (currentDate.isAfter(v.startDate) || currentDate.isAtSameMomentAs(v.startDate)) &&
            (currentDate.isBefore(v.endDate) || currentDate.isAtSameMomentAs(v.endDate))
          );
          
          assignments.add(WorkerAssignment(
            workerId: w.id,
            workerName: w.name,
            date: currentDate,
            slotId: null,
            isVacation: isOnVacation,
          ));
        }
      }
    }

    return WeeklySchedule(
      startDate: startDate,
      endDate: endDate,
      templateId: template.id,
      assignments: assignments,
    );
  }

  /// Refines a schedule by rotating assignments.
  Future<WeeklySchedule> shuffleSchedules({
    required WeeklySchedule current, 
    required List<WorkerProfile> workers, 
    required ScheduleTemplate template
  }) async {
    // Shuffling is essentially a re-generation with the same parameters
    // since the generation logic now includes randomization and fairness.
    return generateWeeklySchedule(
      startDate: current.startDate,
      template: template,
      workers: workers,
    );
  }
}
