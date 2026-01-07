import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:html' as html;
import 'package:printing/printing.dart';
import 'package:proyecto_empoderate/src/services/worker_service.dart';
import 'package:proyecto_empoderate/src/services/schedule_service.dart';
import 'package:proyecto_empoderate/src/calculators/schedule_models.dart';
import 'package:proyecto_empoderate/src/calculators/salario_models.dart';
import 'package:proyecto_empoderate/src/services/schedule_export_service.dart';
import 'package:proyecto_empoderate/src/services/schedule_compliance_service.dart';
import 'package:proyecto_empoderate/src/services/smart_schedule_service.dart';
import 'package:proyecto_empoderate/src/services/schedule_analytics_service.dart';

import 'package:proyecto_empoderate/src/services/panama_holidays_service.dart';
import 'package:proyecto_empoderate/src/features/rrhh/scheduling_intelligence/models/schedule_context.dart';
import 'package:proyecto_empoderate/src/features/rrhh/scheduling_intelligence/models/business_rules_config.dart';
import 'package:proyecto_empoderate/src/features/rrhh/scheduling_intelligence/services/scheduling_intelligence_service.dart';
import 'package:proyecto_empoderate/src/features/rrhh/scheduling_intelligence/services/schedule_simulation_service.dart';
import 'package:proyecto_empoderate/src/features/rrhh/scheduling_intelligence/services/schedule_audit_service.dart';
import 'package:proyecto_empoderate/src/features/rrhh/scheduling_intelligence/models/suggestion.dart';
import 'package:proyecto_empoderate/src/features/rrhh/scheduling_intelligence/rules/rule_engine.dart';
import 'package:proyecto_empoderate/src/features/rrhh/scheduling_intelligence/models/tuning_feedback.dart';
import 'package:proyecto_empoderate/src/features/rrhh/scheduling_intelligence/services/auto_tuning_service.dart';
import 'package:proyecto_empoderate/src/features/rrhh/scheduling_intelligence/models/auto_schedule_config.dart';

/// Status for a cell in the schedule grid
enum CellStatusType {
  normal,       // Regular assigned shift
  dayOff,       // Scheduled day off
  permission,   // Approved permission
  sickLeave,    // Sick leave
  swap,         // Shift swap
  vacation,     // On vacation
  maternity,    // Maternity leave
  paternity,    // Paternity leave
  lactancia,    // Lactation break
  bereavement,  // Bereavement leave
  medical,      // Medical appointment/follow-up
}

/// Metadata for a schedule cell
class CellStatus {
  final CellStatusType type;
  final String? requestId; // Reference to the original request
  final String? reason;
  final String? targetName; // For swaps/covers

  CellStatus({
    required this.type,
    this.requestId,
    this.reason,
    this.targetName,
  });

  Color get color {
    switch (type) {
      case CellStatusType.normal: return Colors.blueAccent;
      case CellStatusType.dayOff: return Colors.grey;
      case CellStatusType.permission: return Colors.orange;
      case CellStatusType.sickLeave: return Colors.redAccent;
      case CellStatusType.swap: return Colors.purpleAccent;
      case CellStatusType.vacation: return Colors.teal;
      case CellStatusType.maternity: return Colors.pinkAccent;
      case CellStatusType.paternity: return Colors.blue;
      case CellStatusType.lactancia: return Colors.pink;
      case CellStatusType.bereavement: return Colors.purple;
      case CellStatusType.medical: return Colors.green;
    }
  }

  String get label {
    switch (type) {
      case CellStatusType.normal: return 'Normal';
      case CellStatusType.dayOff: return 'Día Libre';
      case CellStatusType.permission: return 'Permiso';
      case CellStatusType.sickLeave: return 'Incapacidad';
      case CellStatusType.swap: return 'Intercambio';
      case CellStatusType.vacation: return 'Vacaciones';
      case CellStatusType.maternity: return 'Lic. Maternidad';
      case CellStatusType.paternity: return 'Lic. Paternidad';
      case CellStatusType.lactancia: return 'Lactancia';
      case CellStatusType.bereavement: return 'Duelo';
      case CellStatusType.medical: return 'Cita Médica';
    }
  }

  IconData get icon {
    switch (type) {
      case CellStatusType.normal: return Icons.work;
      case CellStatusType.dayOff: return Icons.weekend;
      case CellStatusType.permission: return Icons.event_busy;
      case CellStatusType.sickLeave: return Icons.local_hospital;
      case CellStatusType.swap: return Icons.swap_horiz;
      case CellStatusType.vacation: return Icons.beach_access;
      case CellStatusType.maternity: return Icons.child_friendly;
      case CellStatusType.paternity: return Icons.child_care;
      case CellStatusType.lactancia: return Icons.baby_changing_station;
      case CellStatusType.bereavement: return Icons.heart_broken;
      case CellStatusType.medical: return Icons.medical_services;
    }
  }
}

/// Shift type classification based on start hour
enum ShiftType {
  matutino,   // 5:00 AM - 11:59 AM start (Morning)
  vespertino, // 12:00 PM - 5:59 PM start (Afternoon)
  nocturno,   // 6:00 PM - 4:59 AM start (Night)
}

class ScheduleController extends ChangeNotifier {
  final WorkerService _workerService = WorkerService();
  final ScheduleService _scheduleService = ScheduleService();
  static const String _shiftsKey = 'schedule_shifts';


  
  // State
  List<WorkerProfile> workers = [];
  List<ShiftSlot> shifts = [];
  bool isLoading = true;
  
  // Business Configuration
  static const String _businessConfigKey = 'schedule_business_config';
  
  // Operating Days: true = open, false = closed (index 0=Mon, 6=Sun)
  List<bool> operatingDays = [true, true, true, true, true, true, true]; // Default: all days open
  
  // Business hours (start and end for reference)
  TimeOfDay businessOpenTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay businessCloseTime = const TimeOfDay(hour: 18, minute: 0);
  
  // Days off per worker per week (Panama Labor Code Art 49: minimum 1 day rest per week)
  int requiredDaysOffPerWeek = 1;
  
  // ═══════════════════════════════════════════════════════════════════════════
  // CÓDIGO DE TRABAJO DE PANAMÁ - CONFIGURACIÓN DE JORNADAS (Art 30-32)
  // ═══════════════════════════════════════════════════════════════════════════
  
  // Jornada Diurna (6AM - 6PM): máx 8 horas/día, 48 horas/semana
  static const int maxDiurnaDaily = 8;
  static const int maxDiurnaWeekly = 48;
  
  // Jornada Nocturna (6PM - 6AM): máx 7 horas/día, 42 horas/semana
  static const int maxNocturnaDaily = 7;
  static const int maxNocturnaWeekly = 42;
  
  // Jornada Mixta (combina ambas, <3h nocturnas): máx 7.5 horas/día, 45 horas/semana
  static const double maxMixtaDaily = 7.5;
  static const int maxMixtaWeekly = 45;
  
  // Art 31: 7h nocturnas o 7.5h mixtas SE PAGAN COMO 8h diurnas
  // Esto aplica para empresas con turnos rotativos o para cálculo de salario mínimo
  bool paysNightAsDay = true; // Si true, 7h nocturnas = 8h de pago
  
  // Recargos por Horas Extraordinarias (Art 33-36)
  static const double overtimeDayRate = 0.25;      // 25% diurno
  static const double overtimeNightRate = 0.50;    // 50% nocturno
  static const double overtimeNightExtRate = 0.75; // 75% prolongación nocturna
  
  // Recargos por Días Especiales
  static const double sundayRate = 0.50;           // 50% domingos (Art 49)
  static const double holidayRate = 1.50;          // 150% feriados (día duelo nacional)
  
  // ═══════════════════════════════════════════════════════════════════════════
  // ALMUERZO
  // ═══════════════════════════════════════════════════════════════════════════
  
  // Si la empresa PAGA los 30 min de almuerzo, se cuentan como horas trabajadas
  bool isPaidLunch = true; // Default: empresa asume el almuerzo (Ley 59 Art 6)
  
  // Storage for multi-week data: WeekStart -> (WorkerId -> (DayIndex -> ShiftId))
  final Map<DateTime, Map<String, Map<int, String?>>> _weeklyData = {};
  
  // Current Week Assignments
  Map<String, Map<int, String?>> assignments = {};
  
  // Cell Metadata: tracks special statuses (permission, sick leave, swap, day off)
  // Key: "workerId_dayIndex" -> CellStatus
  Map<String, CellStatus> cellMetadata = {};
  
  // Lunch Break Overrides: manual lunch times
  // Key: "workerId_dayIndex" -> TimeOfDay (null = auto-calculate)
  Map<String, TimeOfDay?> lunchBreakOverrides = {};
  
  // Lunch Break Configuration
  int lunchDuration = 30; // minutes (configurable)
  static const int lunchIntervalBetweenWorkers = 30; // minutes between workers
  static final TimeOfDay defaultFirstLunch = TimeOfDay(hour: 11, minute: 30);
  static final TimeOfDay defaultLastLunch = TimeOfDay(hour: 14, minute: 0);
  
  // Panama Holidays
  final PanamaHolidaysService _holidaysService = PanamaHolidaysService();
  // Intelligence Services
  // Intelligence Services
  final _intelligenceService = SchedulingIntelligenceService(config: BusinessRulesConfig.panamaDefault());
  // ignore: unused_field
  final _simulationService = ScheduleSimulationService(); // Used in simulation
  final _auditService = ScheduleAuditService();
  final _autoTuningService = AutoTuningService();
  
  // Feature Flags
  bool enableSmartSchedulingV1 = true; // Enable intelligent scheduling engine
  bool enableSmartSchedulingAutoTuning = true; // Enable auto-learning of preference weights


  List<PublicHoliday> holidays = [];
  
  // Configuration
  DateTime weekStart = DateTime.now();
  int totalDays = 7; 
  List<String> get dayLabels => List.generate(totalDays, (i) {
    final date = weekStart.add(Duration(days: i));
    final holiday = getHolidayForDay(i);
    if (holiday != null) {
      return '🎉 ${DateFormat('EEE d', 'es').format(date)}';
    }
    return DateFormat('EEE d', 'es').format(date);
  });

  // Current Schedule Metadata
  WeeklySchedule? currentSchedule;
  String scheduleName = 'Nuevo Horario';

  // --- INITIALIZATION ---

  void initialize() {
    weekStart = DateTime.now();
    while (weekStart.weekday != DateTime.monday) {
      weekStart = weekStart.add(const Duration(days: 1));
    }
    weekStart = DateTime(weekStart.year, weekStart.month, weekStart.day);
  }

  Future<void> loadData() async {
    isLoading = true;
    notifyListeners();

    // Safety timeout to prevent infinite loading
    final timeout = Future.delayed(const Duration(seconds: 8), () {
      if (isLoading) {
        isLoading = false;
        notifyListeners();
        debugPrint('⚠️ Schedule loadData timed out');
      }
    });

    try {
      workers = await _workerService.getWorkers();
      await _loadShifts();
      await _loadHolidays();
      _initOrLoadAssignments();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading schedule data: $e');
      isLoading = false;
      notifyListeners();
    } finally {
      // Allow timeout to complete silently if already loaded
    }
  }

  /// Load all employees to the current schedule
  /// This populates the workers list and initializes empty assignments for the week
  Future<bool> loadAllEmployeesToSchedule() async {
    try {
      // Load all workers from service
      workers = await _workerService.getWorkers();
      
      // Reinitialize assignments for all workers
      _initOrLoadAssignments();
      
      debugPrint('✅ Loaded ${workers.length} employees to schedule');
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ Error loading employees: $e');
      return false;
    }
  }

  /// Load Panama public holidays for current week's year
  Future<void> _loadHolidays() async {
    try {
      holidays = await _holidaysService.getHolidaysInRange(
        weekStart,
        weekStart.add(Duration(days: totalDays - 1)),
      );
    } catch (e) {
      // Use fallback if API fails
      holidays = PanamaHolidaysService.getFallbackHolidays(weekStart.year)
          .where((h) => !h.date.isBefore(weekStart) && !h.date.isAfter(weekStart.add(Duration(days: totalDays - 1))))
          .toList();
    }
  }

  /// Get holiday for a specific day index (null if not a holiday)
  PublicHoliday? getHolidayForDay(int dayIndex) {
    final date = weekStart.add(Duration(days: dayIndex));
    try {
      return holidays.firstWhere(
        (h) => h.date.year == date.year && h.date.month == date.month && h.date.day == date.day,
      );
    } catch (e) {
      return null;
    }
  }

  // --- SHIFT MANAGEMENT ---

  Future<void> _loadShifts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_shiftsKey);
    if (data != null) {
      final List<dynamic> decoded = jsonDecode(data);
      shifts = decoded.map((e) => ShiftSlot.fromJson(e)).toList();
    } else {
      // Create defaults if none exist
      shifts = [
        ShiftSlot(id: 's1', name: 'Mañana', startTime: DateTime(2024,1,1,8), endTime: DateTime(2024,1,1,16), isRush: false),
        ShiftSlot(id: 's2', name: 'Tarde', startTime: DateTime(2024,1,1,14), endTime: DateTime(2024,1,1,22), isRush: true),
        ShiftSlot(id: 's3', name: 'Cierre', startTime: DateTime(2024,1,1,16), endTime: DateTime(2024,1,1,23), isRush: false),
      ];
      await _saveShifts();
    }
  }

  Future<void> _saveShifts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_shiftsKey, jsonEncode(shifts.map((s) => s.toJson()).toList()));
  }

  Future<void> addShift(ShiftSlot shift) async {
    shifts.add(shift);
    await _saveShifts();
    notifyListeners();
  }

  Future<void> updateShift(ShiftSlot updated) async {
    final index = shifts.indexWhere((s) => s.id == updated.id);
    if (index >= 0) {
      shifts[index] = updated;
      await _saveShifts();
      notifyListeners();
    }
  }

  Future<void> deleteShift(String shiftId) async {
    shifts.removeWhere((s) => s.id == shiftId);
    await _saveShifts();
    notifyListeners();
  }

  void _initOrLoadAssignments() {
    // Clear metadata for the new week view (prevents stale statuses from other weeks)
    cellMetadata.clear();

     if (_weeklyData.containsKey(weekStart)) {
       // Deep copy to avoid reference issues
       assignments = {};
       _weeklyData[weekStart]!.forEach((wId, dayMap) {
         assignments[wId] = Map.from(dayMap);
       });
       
       // Ensure new workers are covered
       for (var w in workers) {
         if (!assignments.containsKey(w.id)) {
           assignments[w.id] = {for (var i=0; i<totalDays; i++) i: null};
         }
       }
     } else {
       // New week
       assignments = {};
       for (var w in workers) {
         assignments[w.id] = {for (var i=0; i<totalDays; i++) i: null};
       }
     }

     // Apply automated statuses (Vacations, etc.) derived from persistent history
     _applyVacationsToSchedule();
  }

  /// Check for approved vacations overlapping this week and mark cells
  void _applyVacationsToSchedule() {
    final weekEnd = weekStart.add(Duration(days: totalDays - 1));

    for (var worker in workers) {
      if (worker.vacationHistory.isEmpty) continue;

      for (var vacation in worker.vacationHistory) {
        // Skip if records are just payments without time off (if applicable)
        // or ensure we only block strict time-off records. 
        // Assuming all history records imply time off unless flagged otherwise.
        if (vacation.isPaid) continue; 

        // Check Overlap: Start < WeekEnd AND End > WeekStart
        // Using strict day comparison to avoid time issues
        if (_isDateAfter(vacation.startDate, weekEnd) || _isDateBefore(vacation.endDate, weekStart)) {
          continue; // No overlap
        }

        // iterate days of the week to mark overlap
        for (int i = 0; i < totalDays; i++) {
          final dayDate = weekStart.add(Duration(days: i));
          
          // Check if dayDate is inside [startDate, endDate]
          if ((_isDateAfter(dayDate, vacation.startDate) || _isSameDate(dayDate, vacation.startDate)) &&
              (_isDateBefore(dayDate, vacation.endDate) || _isSameDate(dayDate, vacation.endDate))) {
            
            // Apply Status
            cellMetadata['${worker.id}_$i'] = CellStatus(
              type: CellStatusType.vacation,
              requestId: vacation.id,
              reason: 'Vacaciones Programadas',
            );
            
            // Clear any shift assignment for this day
            if (assignments.containsKey(worker.id)) {
              assignments[worker.id]![i] = null;
            }
          }
        }
      }
    }
  }

  bool _isSameDate(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  bool _isDateBefore(DateTime d1, DateTime d2) {
    if (d1.year != d2.year) return d1.year < d2.year;
    if (d1.month != d2.month) return d1.month < d2.month;
    return d1.day < d2.day;
  }

  bool _isDateAfter(DateTime d1, DateTime d2) {
    if (d1.year != d2.year) return d1.year > d2.year;
    if (d1.month != d2.month) return d1.month > d2.month;
    return d1.day > d2.day;
  }
  
  void _saveCurrentWeekState() {
    // Deep copy current assignments to storage
    final weekSnapshot = <String, Map<int, String?>>{};
    assignments.forEach((wId, dayMap) {
      weekSnapshot[wId] = Map.from(dayMap);
    });
    _weeklyData[weekStart] = weekSnapshot;
  }

  // --- LOGIC: DATE NAVIGATION ---

  void nextWeek() {
    _saveCurrentWeekState();
    weekStart = weekStart.add(const Duration(days: 7));
    _initOrLoadAssignments();
    notifyListeners();
  }

  void previousWeek() {
    _saveCurrentWeekState();
    weekStart = weekStart.subtract(const Duration(days: 7));
    _initOrLoadAssignments();
    notifyListeners();
  }

  String get currentWeekLabel {
    final end = weekStart.add(Duration(days: totalDays - 1));
    return '${DateFormat('d MMM', 'es').format(weekStart)} - ${DateFormat('d MMM', 'es').format(end)}';
  }

  /// Load shifts from a saved template
  void loadShiftsFromTemplate(ScheduleTemplate template) {
    shifts = List.from(template.availableSlots);
    requiredDaysOffPerWeek = template.minDaysOffPerWeek;
    _saveShifts(); // Persist to local storage
    notifyListeners();
  }

  // --- LOGIC: ASSIGNMENTS ---

  void assignShift(String workerId, int dayIndex, String? shiftId) {
    if (!assignments.containsKey(workerId)) assignments[workerId] = {};
    assignments[workerId]![dayIndex] = shiftId;
    notifyListeners();
  }

  void clearAssignment(String workerId, int dayIndex) {
    if (assignments.containsKey(workerId)) {
      assignments[workerId]![dayIndex] = null;
      notifyListeners();
    }
  }

  // --- LOGIC: KPIS ---

  double get totalWeeklyHours {
    double total = 0;
    assignments.forEach((wId, days) {
      days.forEach((d, sId) {
        if (sId != null) {
          final shift = getShiftById(sId);
          if (shift != null) {
            // Check for midnight crossing logic if needed, but simple diff works for same-day or handled dates
            // Assuming shifts in ShiftSlot have generic dates, we just use time difference
            int end = shift.endTime.hour * 60 + shift.endTime.minute;
            int start = shift.startTime.hour * 60 + shift.startTime.minute;
            if (end <= start) end += 24 * 60;
            
            total += (end - start) / 60.0;
          }
        }
      });
    });
    return total;
  }

  double get projectedCost {
    double total = 0;
    assignments.forEach((wId, days) {
      final worker = workers.firstWhere((w) => w.id == wId, orElse: () => WorkerProfile(
        id: 'u', name: 'U', position: 'U', department: 'G', 
        paymentMode: PayrollFrequency.quincenal, basePayment: 0
      ));
      days.forEach((d, sId) {
        if (sId != null) {
          final shift = getShiftById(sId);
          if (shift != null) {
             int end = shift.endTime.hour * 60 + shift.endTime.minute;
            int start = shift.startTime.hour * 60 + shift.startTime.minute;
            if (end <= start) end += 24 * 60;
            
            final hours = (end - start) / 60.0;
            total += hours * (worker.hourlyRate ?? 0);
          }
        }
      });
    });
    return total;
  }
  
  // --- COMPLIANCE ---

  List<ComplianceIssue> get complianceIssues {
    return LaborComplianceChecker().checkCompliance(assignments, workers, shifts);
  }

  int get conflictCount => complianceIssues.length;

  // --- LOGIC: EXPORT ---

  Future<void> exportPdf() async {
    try {
      final scheduleExport = WeeklySchedule(
        id: currentSchedule?.id ?? 'temp',
        name: scheduleName,
        startDate: weekStart,
        endDate: weekStart.add(Duration(days: totalDays - 1)),
        assignments: _buildAssignmentsList(),
      );
      
      final template = ScheduleTemplate(
        id: 'temp_tpl', 
        name: 'Current', 
        availableSlots: shifts, 
        minDaysOffPerWeek: 1,
        weeklyDemand: [], 
      );

      final pdfBytes = await ScheduleExportService().generateSchedulePdf(scheduleExport, workers, template);
      
      // For web, use printing package to download
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: 'Horario_${DateFormat('yyyyMMdd').format(weekStart)}.pdf',
      );
      
      debugPrint('✅ PDF exported successfully');
    } catch (e) {
      debugPrint('❌ Export PDF Error: $e');
      rethrow;
    }
  }

  Future<void> exportExcel() async {
    try {
      final scheduleExport = WeeklySchedule(
        id: currentSchedule?.id ?? 'temp',
        name: scheduleName,
        startDate: weekStart,
        endDate: weekStart.add(Duration(days: totalDays - 1)),
        assignments: _buildAssignmentsList(),
      );
      
      final template = ScheduleTemplate(
        id: 'temp_tpl', 
        name: 'Current', 
        availableSlots: shifts, 
        minDaysOffPerWeek: 1,
        weeklyDemand: [], 
      );

      final csvString = await ScheduleExportService().generateScheduleCsv(scheduleExport, workers, template);
      
      // For web, trigger download using dart:html
      final bytes = utf8.encode(csvString);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'Horario_${DateFormat('yyyyMMdd').format(weekStart)}.csv')
        ..click();
      html.Url.revokeObjectUrl(url);
      
      debugPrint('✅ Excel/CSV exported successfully');
    } catch (e) {
      debugPrint('❌ Export CSV Error: $e');
      rethrow;
    }
  }

  List<WorkerAssignment> _buildAssignmentsList() {
      List<WorkerAssignment> assignmentsList = [];
      assignments.forEach((workerId, daysMap) {
        final workerName = workers.firstWhere((w) => w.id == workerId, orElse: () => WorkerProfile(
          id: 'unknown', name: 'Unknown', position: 'Unknown', department: 'General', 
          paymentMode: PayrollFrequency.quincenal, basePayment: 0
        )).name;
        
        daysMap.forEach((dayIndex, shiftId) {
          if (shiftId != null) {
            assignmentsList.add(WorkerAssignment(
              workerId: workerId,
              workerName: workerName,
              date: weekStart.add(Duration(days: dayIndex)),
              slotId: shiftId,
            ));
          }
        });
      });
      return assignmentsList;
  }

  // --- LOGIC: SAVING ---

  Future<bool> saveSchedule() async {
    try {
      final assignmentsList = _buildAssignmentsList();

      final scheduleToSave = WeeklySchedule(
        id: currentSchedule?.id ?? const Uuid().v4(),
        name: scheduleName,
        startDate: weekStart,
        endDate: weekStart.add(Duration(days: totalDays - 1)),
        assignments: assignmentsList,
      );

      await _scheduleService.saveSchedule(scheduleToSave);
      
      currentSchedule = scheduleToSave;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error saving schedule: $e');
      return false;
    }
  }
  
  ShiftSlot? getShiftById(String? id) {
    if (id == null) return null;
    try {
      return shifts.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  // --- ANALYTICS ---

  ScheduleAnalyticsMetrics getAnalytics() {
    return ScheduleAnalyticsService().calculateMetrics(
      workers: workers,
      assignments: assignments,
      shifts: shifts,
      operatingDays: operatingDays,
    );
  }

  // --- AI SUGGESTIONS ---

  List<OptimizationSuggestion> getOptimizationSuggestions() {
    if (enableSmartSchedulingV1) {
       final smartSuggestions = generateSmartSuggestions();
       return smartSuggestions.map((s) => OptimizationSuggestion(
         title: s.title,
         message: s.description,
         type: SuggestionType.optimization, // Generalize for now
         isHighPriority: s.explanation.scoreChange > 0 || s.actionType == 'fix_violation',
         actionLabel: s.actionType == 'fix_violation' ? 'Corregir' : 'Optimizar',
         explanation: s.explanation, // Pass the full explanation object
       )).toList();
    }

    return SmartScheduleService().analyzeSchedule(
      workers: workers,
      assignments: assignments,
      shifts: shifts,
      operatingDays: operatingDays,
    );
  }

  // --- AUTO TUNING FEEDBACK ---

  Future<void> handleSuggestionAction({
    required OptimizationSuggestion suggestion, 
    required bool isAccepted,
    RejectionReason? rejectionReason,
  }) async {
    if (!enableSmartSchedulingAutoTuning) return;

    var currentConfig = await _autoTuningService.loadTunedConfig(BusinessRulesConfig.panamaDefault());
    
    // Apply Feedback
    final newConfig = await _autoTuningService.applyFeedback(
      currentConfig: currentConfig,
      suggestionId: suggestion.title, 
      suggestionType: suggestion.type.toString(),
      action: isAccepted ? TuningAction.accept : TuningAction.reject,
      reason: rejectionReason,
    );
    
    notifyListeners();
  }


  // --- AUTO GENERATE ---

  Future<void> autoGenerateSchedule({AutoScheduleConfig? config}) async {
    if (shifts.isEmpty || workers.isEmpty) return;
    
    // Create a basic template with current shifts
    final template = ScheduleTemplate(
      id: 'auto_template', 
      name: 'Auto Generated', 
      availableSlots: shifts, 
      weeklyDemand: List.generate(7, (dayIndex) => DailyDemand(
        dayOfWeek: dayIndex + 1, 
        requirements: shifts.map((s) {
          // If config exists, calculate total count for this shift from all roles
          // Otherwise revert to default distribution logic
          int count;
          if (config != null && config.roleRequirements.containsKey(s.id)) {
            // Sum all role counts for this shift
            count = config.roleRequirements[s.id]!.values.fold(0, (sum, val) => sum + val);
            debugPrint('AutoSchedule: Shift ${s.name} (${s.id}) - Configured Count: $count');
          } else {
            count = (workers.length / shifts.length).ceil().clamp(1, workers.length);
            debugPrint('AutoSchedule: Shift ${s.name} - Auto Count: $count');
          }
          
          return SlotRequirement(
            slotId: s.id, 
            employeeCount: count
          );
        }).toList(),
          )),
      minDaysOffPerWeek: 1,
    );
    
    final generated = await _scheduleService.generateWeeklySchedule(
      startDate: weekStart,
      template: template,
      workers: workers,
      unavailableDates: config?.unavailableDates, // Pass restrictions
      rotationMode: config?.rotationMode ?? RotationMode.rotating, // Pass rotation mode
      fairnessWeight: config?.fairnessWeight ?? 0.5, // Pass fairness weight
    );
    
    // Convert WeeklySchedule assignments to our map format
    assignments = {};
    cellMetadata = {}; // Clear metadata on regenerate
    
    for (var w in workers) {
      assignments[w.id] = {for (var i = 0; i < totalDays; i++) i: null};
    }
    for (var a in generated.assignments) {
      if (a.slotId != null) {
        final dayIndex = a.date.difference(weekStart).inDays;
        if (dayIndex >= 0 && dayIndex < totalDays) {
          assignments[a.workerId]?[dayIndex] = a.slotId;
        }
      }
    }
    
    // SMART DAY-OFF DISTRIBUTION (Intelligence V1)
    if (enableSmartSchedulingV1) {
       final context = _buildContext();
       final optimized = _intelligenceService.optimizeSchedule(context);
       
       // Apply optimization results back
       assignments = optimized.assignments;
       cellMetadata = optimized.cellMetadata;
    } else {
       _distributeRestDaysEquitably();
    }

    notifyListeners();
  }

  /// Smart equitable day-off distribution
  /// - Respects business closed days (operatingDays)
  /// - Distributes days off rotating among workers
  /// - Ensures each worker gets requiredDaysOffPerWeek days off
  void _distributeRestDaysEquitably() {
    // First, mark business closed days as off for everyone
    for (int day = 0; day < totalDays; day++) {
      if (!operatingDays[day]) {
        // Business is closed this day - mark everyone off
        for (var worker in workers) {
          assignments[worker.id]?[day] = null;
          _setCellStatus(worker.id, day, CellStatus(type: CellStatusType.dayOff, reason: 'Cerrado'));
        }
      }
    }
    
    // Get list of days business is open (for distributing personal days off)
    final openDays = <int>[];
    for (int i = 0; i < totalDays; i++) {
      if (operatingDays[i]) openDays.add(i);
    }
    
    if (openDays.isEmpty) return; // All days closed, nothing more to do
    
    // For each worker, check if they need additional days off
    for (int workerIdx = 0; workerIdx < workers.length; workerIdx++) {
      final worker = workers[workerIdx];
      final workerAssignments = assignments[worker.id]!;
      
      // Count current days off (including closed days)
      int currentDaysOff = 0;
      for (int d = 0; d < totalDays; d++) {
        if (workerAssignments[d] == null) currentDaysOff++;
      }
      
      // Need more days off?
      int daysOffNeeded = requiredDaysOffPerWeek - currentDaysOff;
      
      if (daysOffNeeded > 0) {
        // Rotate through open days based on worker index for equitable distribution
        // Worker 0 gets day 0, Worker 1 gets day 1, etc.
        for (int attempt = 0; attempt < openDays.length && daysOffNeeded > 0; attempt++) {
          // Select day based on worker index (rotating)
          final dayChoice = openDays[(workerIdx + attempt) % openDays.length];
          
          // Only assign if this day has a shift (so we're actually giving a day off)
          if (workerAssignments[dayChoice] != null) {
            workerAssignments[dayChoice] = null;
            _setCellStatus(worker.id, dayChoice, CellStatus(type: CellStatusType.dayOff));
            daysOffNeeded--;
          }
        }
      }
    }
  }

  // --- WORKER HOURS CALCULATION ---

  double getWorkerWeeklyHours(String workerId) {
    double total = 0;
    final workerAssignments = assignments[workerId];
    if (workerAssignments == null) return 0;
    
    workerAssignments.forEach((d, sId) {
      if (sId != null) {
        final shift = getShiftById(sId);
        if (shift != null) {
          int end = shift.endTime.hour * 60 + shift.endTime.minute;
          int start = shift.startTime.hour * 60 + shift.startTime.minute;
          if (end <= start) end += 24 * 60;
          total += (end - start) / 60.0;
        }
      }
    });
    return total;
  }

  // --- DAILY TOTALS ---

  int getDailyAssignedCount(int dayIndex) {
    int count = 0;
    assignments.forEach((wId, days) {
      if (days[dayIndex] != null) count++;
    });
    return count;
  }

  // ===========================================
  // --- SHIFT CHANGE REQUESTS ---
  // ===========================================
  
  static const String _requestsKey = 'schedule_change_requests';
  List<ShiftChangeLog> changeRequests = [];
  
  Future<void> loadChangeRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_requestsKey);
    if (data != null) {
      final List<dynamic> decoded = jsonDecode(data);
      changeRequests = decoded.map((e) => ShiftChangeLog.fromJson(e)).toList();
    }
    notifyListeners();
  }
  
  Future<void> _saveChangeRequests() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_requestsKey, jsonEncode(changeRequests.map((r) => r.toJson()).toList()));
  }
  
  Future<void> submitChangeRequest(ShiftChangeLog request) async {
    changeRequests.add(request);
    await _saveChangeRequests();
    notifyListeners();
  }
  
  Future<void> approveRequest(String requestId) async {
    final index = changeRequests.indexWhere((r) => r.id == requestId);
    if (index >= 0) {
      final request = changeRequests[index];
      
      // Determine date range
      final startDate = request.date;
      final endDate = request.endDate ?? request.date;
      final daysDifference = endDate.difference(startDate).inDays;
      
      int daysApplied = 0;
      
      // Loop through each day in the range
      for (int i = 0; i <= daysDifference; i++) {
        final currentDate = startDate.add(Duration(days: i));
        final dayIndex = currentDate.difference(weekStart).inDays;
        
        // Only apply if day is within current view
        if (dayIndex >= 0 && dayIndex < totalDays) {
          _applyChangeForDay(request, dayIndex);
          daysApplied++;
        }
      }
      
      // Remove from pending list
      changeRequests.removeAt(index);
      await _saveChangeRequests();
      
      notifyListeners();
      
      // Log for debugging
      print('✅ Solicitud aprobada: ${request.type.name} para ${request.requesterName}');
      print('   Días aplicados en vista actual: $daysApplied/${daysDifference + 1}');
      if (daysApplied < daysDifference + 1) {
        print('   ⚠️ Algunos días están fuera de la semana actual ($weekStart)');
      }
    }
  }

  void _applyChangeForDay(ShiftChangeLog request, int dayIndex) {
      // Apply the change based on type
      switch (request.type) {
        case ChangeType.swapShift:
          // Swap shifts between requester and target
          if (request.targetId != null) {
              final requesterShift = assignments[request.requesterId]?[dayIndex];
              final targetShift = assignments[request.targetId]?[dayIndex];
              
              assignments[request.requesterId]?[dayIndex] = targetShift;
              assignments[request.targetId]?[dayIndex] = requesterShift;
              
              // Mark as swap
              _setCellStatus(request.requesterId, dayIndex, CellStatus(
                type: CellStatusType.swap,
                requestId: request.id,
                targetName: request.targetName,
                reason: request.reason,
              ));
              _setCellStatus(request.targetId!, dayIndex, CellStatus(
                type: CellStatusType.swap,
                requestId: request.id,
                targetName: request.requesterName,
                reason: request.reason,
              ));
          }
          break;
          
        case ChangeType.coverShift:
          // Target covers requester's shift
          if (request.targetId != null) {
              final requesterShift = assignments[request.requesterId]?[dayIndex];
              assignments[request.targetId]?[dayIndex] = requesterShift;
              assignments[request.requesterId]?[dayIndex] = null;
              
              // Mark requester's cell as covered/permission
              _setCellStatus(request.requesterId, dayIndex, CellStatus(
                type: CellStatusType.permission,
                requestId: request.id,
                reason: 'Cubierto por ${request.targetName}: ${request.reason}',
                targetName: request.targetName,
              ));
          }
          break;

        case ChangeType.lactancia:
             // Lactancia does NOT remove shift, just adds marker
             _setCellStatus(request.requesterId, dayIndex, CellStatus(
                type: CellStatusType.lactancia,
                requestId: request.id,
                reason: request.reason,
              ));
             break;
          
        default:
          // All other types (leaves, permissions, etc.) -> Remove assignment & set status
          assignments[request.requesterId]?[dayIndex] = null;
          
          CellStatusType statusType;
          switch (request.type) {
            case ChangeType.sickLeave: statusType = CellStatusType.sickLeave; break;
            case ChangeType.maternityLeave: statusType = CellStatusType.maternity; break;
            case ChangeType.paternityLeave: statusType = CellStatusType.paternity; break;
            case ChangeType.bereavement: statusType = CellStatusType.bereavement; break;
            case ChangeType.vacation: statusType = CellStatusType.vacation; break;
            case ChangeType.medicalFollow: statusType = CellStatusType.medical; break;
            case ChangeType.daySwap: statusType = CellStatusType.swap; break;
            default: statusType = CellStatusType.permission;
          }
          
          _setCellStatus(request.requesterId, dayIndex, CellStatus(
            type: statusType,
            requestId: request.id,
            reason: request.reason,
          ));
          break;
      }
  }
  
  Future<void> rejectRequest(String requestId) async {
    changeRequests.removeWhere((r) => r.id == requestId);
    await _saveChangeRequests();
    notifyListeners();
  }
  
  List<ShiftChangeLog> get pendingRequests => changeRequests;

  // --- CELL STATUS HELPERS ---

  String _cellKey(String workerId, int dayIndex) => '${workerId}_$dayIndex';

  void _setCellStatus(String workerId, int dayIndex, CellStatus status) {
    cellMetadata[_cellKey(workerId, dayIndex)] = status;
  }

  // Public setter that also notifies listeners
  void setCellStatus(String workerId, int dayIndex, CellStatus status) {
    _setCellStatus(workerId, dayIndex, status);
    notifyListeners();
  }

  CellStatus? getCellStatus(String workerId, int dayIndex) {
    return cellMetadata[_cellKey(workerId, dayIndex)];
  }

  void clearCellStatus(String workerId, int dayIndex) {
    cellMetadata.remove(_cellKey(workerId, dayIndex));
  }

  // Public remover that also notifies listeners
  void removeCellStatus(String workerId, int dayIndex) {
    clearCellStatus(workerId, dayIndex);
    notifyListeners();
  }

  // Format time for display (e.g., "8:00 AM")
  String formatShiftTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }

  // Get time range string for a shift
  String getShiftTimeRange(ShiftSlot shift) {
    return '${formatShiftTime(shift.startTime)} - ${formatShiftTime(shift.endTime)}';
  }

  // --- LUNCH BREAK LOGIC ---

  /// Get lunch time for a worker on a specific day
  /// SMART LOGIC: Calculates lunch based on shift type and start time
  TimeOfDay? getLunchTime(String workerId, int dayIndex) {
    final key = _cellKey(workerId, dayIndex);
    
    // Check for manual override first
    if (lunchBreakOverrides.containsKey(key)) {
      return lunchBreakOverrides[key];
    }
    
    // Get assigned shift
    final shiftId = assignments[workerId]?[dayIndex];
    if (shiftId == null) return null; // No shift assigned
    
    final shift = getShiftById(shiftId);
    if (shift == null) return null;

    // Determine shift type based on start hour
    final shiftStartHour = shift.startTime.hour;
    final shiftType = _getShiftType(shiftStartHour);
    
    // Calculate shift duration in minutes
    int startMin = shift.startTime.hour * 60 + shift.startTime.minute;
    int endMin = shift.endTime.hour * 60 + shift.endTime.minute;
    if (endMin <= startMin) endMin += 24 * 60; // Crosses midnight
    final durationMin = endMin - startMin;
    
    // SMART LUNCH CALCULATION based on shift type
    int lunchMinutes;
    
    if (shiftType == ShiftType.matutino) {
      // Morning shift (5AM - 12PM start): Lunch at 11:30 AM - 2:00 PM range
      // Calculate: 4 hours after shift start, or 11:30 AM minimum
      lunchMinutes = startMin + (4 * 60); // 4 hours after start
      lunchMinutes = lunchMinutes.clamp(11 * 60 + 30, 14 * 60); // 11:30 AM - 2:00 PM
    } else if (shiftType == ShiftType.vespertino) {
      // Afternoon shift (12PM - 6PM start): Lunch at midpoint of shift
      // Calculate: Midpoint between start and end
      lunchMinutes = startMin + (durationMin ~/ 2);
      lunchMinutes = lunchMinutes.clamp(startMin + 60, endMin - 60); // At least 1h after start, 1h before end
    } else {
      // Night shift (6PM+ start): Lunch/break at midpoint
      lunchMinutes = startMin + (durationMin ~/ 2);
      if (lunchMinutes >= 24 * 60) lunchMinutes -= 24 * 60; // Handle midnight wrap
    }
    
    // Apply worker position offset (staggered lunch breaks)
    final sameShiftWorkers = <String>[];
    for (var w in workers) {
      if (assignments[w.id]?[dayIndex] == shiftId) {
        sameShiftWorkers.add(w.id);
      }
    }
    sameShiftWorkers.sort((a, b) {
      final workerA = workers.firstWhere((w) => w.id == a);
      final workerB = workers.firstWhere((w) => w.id == b);
      return workerA.name.compareTo(workerB.name);
    });
    
    final position = sameShiftWorkers.indexOf(workerId);
    if (position > 0) {
      // Stagger by 30 min for each worker
      lunchMinutes += position * lunchIntervalBetweenWorkers;
    }
    
    // Ensure lunch doesn't exceed shift end
    lunchMinutes = lunchMinutes.clamp(startMin + 60, endMin - 60);
    
    // Handle wrap for display
    final hour = (lunchMinutes ~/ 60) % 24;
    final minute = lunchMinutes % 60;
    
    return TimeOfDay(hour: hour, minute: minute);
  }

  /// Determine shift type based on start hour
  ShiftType _getShiftType(int startHour) {
    if (startHour >= 5 && startHour < 12) {
      return ShiftType.matutino;
    } else if (startHour >= 12 && startHour < 18) {
      return ShiftType.vespertino;
    } else {
      return ShiftType.nocturno;
    }
  }

  /// Get shift type name for display
  String getShiftTypeName(String shiftId) {
    final shift = getShiftById(shiftId);
    if (shift == null) return 'Desconocido';
    final type = _getShiftType(shift.startTime.hour);
    switch (type) {
      case ShiftType.matutino: return 'Matutino';
      case ShiftType.vespertino: return 'Vespertino';
      case ShiftType.nocturno: return 'Nocturno';
    }
  }

  /// Format TimeOfDay for display
  String formatLunchTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  /// Get lunch info string for tooltip
  String getLunchInfoString(String workerId, int dayIndex) {
    final lunchTime = getLunchTime(workerId, dayIndex);
    if (lunchTime == null) return '';
    
    final isManual = lunchBreakOverrides.containsKey(_cellKey(workerId, dayIndex));
    return '🍴 ${formatLunchTime(lunchTime)} (${lunchDuration}min)${isManual ? ' ✏️' : ''}';
  }

  /// Set manual lunch time override
  void setLunchTime(String workerId, int dayIndex, TimeOfDay time) {
    lunchBreakOverrides[_cellKey(workerId, dayIndex)] = time;
    notifyListeners();
  }

  /// Clear manual override (return to auto-calculate)
  void clearLunchOverride(String workerId, int dayIndex) {
    lunchBreakOverrides.remove(_cellKey(workerId, dayIndex));
    notifyListeners();
  }

  /// Public method to notify listeners when config changes (called from dialogs)
  void notifyConfigChanged() {
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // SCHEDULING INTELLIGENCE (Smart V1)
  // ---------------------------------------------------------------------------

  ScheduleContext _buildContext() {
    // Map operating days list to map
    final opDaysMap = <int, bool>{};
    for (int i = 0; i < totalDays; i++) {
        opDaysMap[i] = i < operatingDays.length ? operatingDays[i] : false;
    }

    return ScheduleContext(
      workers: List.from(workers),
      assignments: {
        for (var entry in assignments.entries)
          entry.key: Map.from(entry.value)
      },
      cellMetadata: Map.from(cellMetadata),
      shifts: List.from(shifts),
      weekStart: weekStart,
      totalDays: totalDays,
      holidays: List.from(holidays),
      operatingDays: opDaysMap,
      rulesConfig: BusinessRulesConfig.panamaDefault(),
    );
  }

  /// Generate intelligent suggestions for the current schedule
  List<Suggestion> generateSmartSuggestions() {
    if (!enableSmartSchedulingV1) return [];
    final context = _buildContext();
    return _intelligenceService.generateSuggestions(context);
  }

  /// Simulate the approval of a request to check for violations
  /// Returns a SimulationResult with score impact and violations
  Future<SimulationResult?> simulateRequest(String requestId) async {
    if (!enableSmartSchedulingV1) return null;

    final index = changeRequests.indexWhere((r) => r.id == requestId);
    if (index < 0) return null;
    final request = changeRequests[index];

    final context = _buildContext();
    final modifiedContext = context.copyWith();

    // -- APPLY CHANGES TO MODIFIED CONTEXT (Simulation) --
    // Determine date range
    final startDate = request.date;
    final endDate = request.endDate ?? request.date;
    final daysDifference = endDate.difference(startDate).inDays;

    for (int i = 0; i <= daysDifference; i++) {
      final currentDate = startDate.add(Duration(days: i));
      final dayIndex = currentDate.difference(weekStart).inDays;

      if (dayIndex >= 0 && dayIndex < totalDays) {
        // Apply logic similar to approveRequest but on modifiedContext
        switch (request.type) {
          case ChangeType.swapShift:
             if (request.targetId != null) {
                final rShift = modifiedContext.assignments[request.requesterId]?[dayIndex];
                final tShift = modifiedContext.assignments[request.targetId]?[dayIndex];
                modifiedContext.assignments[request.requesterId]?[dayIndex] = tShift;
                modifiedContext.assignments[request.targetId]?[dayIndex] = rShift;
             }
             break;
          case ChangeType.coverShift:
             if (request.targetId != null) {
                final rShift = modifiedContext.assignments[request.requesterId]?[dayIndex];
                modifiedContext.assignments[request.targetId]?[dayIndex] = rShift;
                modifiedContext.assignments[request.requesterId]?[dayIndex] = null;
             }
             break;
          case ChangeType.lactancia:
             // Non-blocking, no assignment change
             break;
          default:
             // Leaves/Permissions
             modifiedContext.assignments[request.requesterId]?[dayIndex] = null;
             // We should also set metadata in context to check for blockOnMaternity etc.
             // But for now, just checking the "null" assignment helps overlap etc.
             // To check "Conflict with Maternity", we need to simulate the CellStatus update too.
             CellStatusType type = CellStatusType.permission;
             if (request.type == ChangeType.maternityLeave) type = CellStatusType.maternity;
             if (request.type == ChangeType.sickLeave) type = CellStatusType.sickLeave;
             if (request.type == ChangeType.vacation) type = CellStatusType.vacation;
             
             // We manually update metadata copy
             modifiedContext.cellMetadata['${request.requesterId}_$dayIndex'] = CellStatus(type: type);
             break;
        }
      }
    }

    // -- EVALUATE --
    final originalEval = RuleEngine.evaluate(context);
    final newEval = RuleEngine.evaluate(modifiedContext);

    return SimulationResult(
      isViable: newEval.isValid,
      score: newEval.score,
      violations: newEval.violations,
      scoreDelta: newEval.score - originalEval.score,
    );
  }
}

extension ShiftSlotColor on ShiftSlot {
    Color get color => isRush ? Colors.amber : Colors.blueAccent;
}
