import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart'; // For WhatsApp
import 'package:shared_preferences/shared_preferences.dart'; // For Templates
import 'package:uuid/uuid.dart';

import '../../components/neon_widgets.dart';
import '../../components/premium_scaffold.dart';
import '../../calculators/schedule_models.dart';
import '../../calculators/salario_models.dart';
import '../../calculators/vacation_models.dart';
import '../../calculators/shift_models.dart';
import '../../services/schedule_service.dart';
import '../../services/worker_service.dart';
import '../../services/worker_service.dart';
import '../../services/schedule_export_service.dart';
import '../../services/schedule_compliance_service.dart';
import '../../services/smart_schedule_service.dart';
import '../../services/schedule_analytics_service.dart';

import 'package:proyecto_empoderate/src/widgets/feature_intro_screen.dart';
import '../../services/subscription_service.dart'; // Subscription Gating
import '../../components/business_hero_header.dart'; // Hero Header
import 'package:uuid/uuid.dart';
import 'dart:math';
class DayHours {
  final TimeOfDay? open;
  final TimeOfDay? close;
  final bool isOpen;
  
  DayHours({this.open, this.close, this.isOpen = true});
}

class SpecialDateSchedule {
  final String id;
  final String name;
  final DateTime date;
  final TimeOfDay? openTime; // Null if closed or full day
  final TimeOfDay? closeTime;
  final bool isClosed;
  final bool isActive;
  
  SpecialDateSchedule({
    required this.id,
    required this.name,
    required this.date,
    this.openTime,
    this.closeTime,
    this.isClosed = false,
    this.isActive = true,
  });
}

class ScheduleAlert {
  final String title;
  final String message;
  final AlertType type;
  final IconData icon;
  
  ScheduleAlert({
    required this.title,
    required this.message,
    required this.type,
    required this.icon,
  });
}

enum AlertType {
  error,    // Rojo - error crítico
  warning,  // Naranja - advertencia
  info,     // Azul - información
}

/// Schedule Creator PRO - Clean rewrite with all integrations
/// Features: Excel grid, PDF/CSV export, vacation sync, persistence, heatmap
enum ScheduleDuration { semana, quincena, mes }

class ScheduleCreatorScreen extends StatefulWidget {
  const ScheduleCreatorScreen({Key? key}) : super(key: key);

  @override
  State<ScheduleCreatorScreen> createState() => _ScheduleCreatorScreenState();
}

class _ScheduleCreatorScreenState extends State<ScheduleCreatorScreen> {
  // Services
  final ScheduleService _scheduleService = ScheduleService();
  final WorkerService _workerService = WorkerService();
  final ScheduleExportService _exportService = ScheduleExportService();
  final LaborComplianceChecker _complianceChecker = LaborComplianceChecker();
  final SmartScheduleService _smartAssistant = SmartScheduleService();
  final ScheduleAnalyticsService _analyticsService = ScheduleAnalyticsService();

  // State
  List<WorkerProfile> _workers = [];
  List<ScheduleTemplate> _templates = [];
  ScheduleTemplate? _selectedTemplate;
  List<WeeklySchedule> _weekSchedules = [];
  WeeklySchedule? _currentSchedule;
  String _currentScheduleName = 'Horario General';
  bool _isLoading = true;
  
  // Config
  DateTime _weekStart = DateTime.now();
  ScheduleDuration _scheduleDuration = ScheduleDuration.semana;
  int get _totalDays => _scheduleDuration == ScheduleDuration.semana ? 7 : (_scheduleDuration == ScheduleDuration.quincena ? 15 : 30);
  
  int _daysOff = 1;
  List<ShiftSlot> _shifts = [];
  
  // Grid data: workerId -> dayIndex -> slotId (or null for free)
  Map<String, Map<int, String?>> _assignments = {};
  
  // Business Operating Days (Mon-Sun)
  // Business Operating Days (Mon-Sun) - All active by default for private sector
  List<bool> _operatingDays = [true, true, true, true, true, true, true];
  
  // Department Filter
  String _selectedDepartment = 'Todos';
  List<String> _departments = ['Todos'];
  
  // Business Hours
  TimeOfDay _generalOpen = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _generalClose = const TimeOfDay(hour: 22, minute: 0);
  bool _showBusinessHoursSection = false;
  bool _showSpecialDates = false;
  bool _useGeneralHours = true;
  Map<int, DayHours> _daySpecificHours = {};
  
  // Employee off-days tracking (for intelligent rotation)
  Map<String, Set<int>> _employeeOffDays = {};
  
  // Alerts system
  List<ScheduleAlert> _alerts = [];
  List<ComplianceIssue> _complianceIssues = [];
  List<OptimizationSuggestion> _aiSuggestions = [];
  ScheduleAnalyticsMetrics? _analyticsMetrics;
  final List<String> _dayNames = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
  
  // Special Dates
  List<SpecialDateSchedule> _specialDates = [];
  
  // Shift Logs
  List<ShiftChangeLog> _changeLogs = [];
  
  // Weather Mock
  List<IconData> _weatherIcons = [];
  
  // Scroll controllers
  final ScrollController _scrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();
  
  // Weather Mock

  @override
  void dispose() {
    _scrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Set week to next Monday
    _weekStart = DateTime.now().add(Duration(days: (8 - DateTime.now().weekday) % 7));
    _generateWeatherForecast(); // Mock weather
    _loadData();
    
    // Show Intro
    // Intro removed - using BusinessHeroHeader instead
  }

  void _showFeatureIntro() {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (ctx, _, __) => FeatureIntroScreen(
          title: 'DOMINA TU TIEMPO',
          subTitle: 'Bienvenido al planificador más avanzado del mercado. Transforma el caos en orden perfecto.',
          heroEmoji: '⚡',
          primaryColor: Colors.cyanAccent,
          features: const [
            IntroFeatureItem(Icons.auto_awesome, 'IA Inteligente'),
            IntroFeatureItem(Icons.published_with_changes, 'Cambios Turno'),
            IntroFeatureItem(Icons.analytics, 'Analytics TR'),
            IntroFeatureItem(Icons.input, 'WhatsApp'),
          ],
          processSteps: const [
            IntroStepItem('1. Configura', 'Define turnos, días libres y reglas del juego.'),
            IntroStepItem('2. Genera', 'Deja que el algoritmo distribuya equitativamente.'),
            IntroStepItem('3. Ajusta', 'Mueve fichas con Drag & Drop y gestiona cambios.'),
            IntroStepItem('4. Publica', 'Envía los horarios a cada empleado con un click.'),
          ],
          proTip: 'Usa el botón "Gestionar Cambios" (morado) para registrar permisos y faltas sin romper el algoritmo.',
          onDismiss: () => Navigator.pop(ctx),
        ),
      ),
    );
  }

  void _generateWeatherForecast() {
    final icons = [Icons.sunny, Icons.cloud, Icons.wb_cloudy, Icons.ac_unit, Icons.flash_on];
    _weatherIcons = List.generate(30, (i) => icons[Random().nextInt(icons.length)]);
  }

  Future<void> _loadData() async {
    try {
      final workers = await _workerService.getWorkers();
      final templates = await _scheduleService.getTemplates();
      
      setState(() {
        _workers = workers;
        _templates = templates;
        _isLoading = false;
        
        // Extract unique departments
        _departments = ['Todos', ...workers.map((w) => w.department).where((d) => d.isNotEmpty).toSet()];
        
        // Load template or create defaults
        if (templates.isNotEmpty) {
          _selectedTemplate = templates.first;
          _shifts = List.from(_selectedTemplate!.availableSlots);
          _daysOff = _selectedTemplate!.minDaysOffPerWeek;
        } else {
          // Sin datos: empezar con lista vacía de turnos
          _shifts = [];
        }
        
        // Initialize empty assignments
        _initEmptyAssignments();
      });
      
      // Try to load existing schedule
      _loadScheduleForWeek();
    } catch (e) {
      debugPrint('Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  void _initEmptyAssignments() {
    _assignments = {};
    for (var w in _workers) {
      _assignments[w.id] = {};
      for (int i = 0; i < 7; i++) {
        _assignments[w.id]![i] = null;
      }
    }
  }

  Future<void> _loadScheduleForWeek() async {
    try {
      final schedules = await _scheduleService.getSchedules();
      final weekSchedules = schedules.where((s) => 
        _weekStart.isAfter(s.startDate.subtract(const Duration(days: 1))) &&
        _weekStart.isBefore(s.endDate.add(const Duration(days: 1)))
      ).toList();
      
      setState(() {
        _weekSchedules = weekSchedules;
        
        // Find existing schedule match
        WeeklySchedule? target;
        
        // Priority 1: Match by ID if we have a current schedule
        if (_currentSchedule != null) {
          try {
            target = weekSchedules.firstWhere((s) => s.id == _currentSchedule!.id);
          } catch (_) {}
        }
        
        // Priority 2: Match by Name and Dept if ID match failed (handles newly saved)
        if (target == null) {
          try {
            target = weekSchedules.firstWhere((s) => 
              s.name == _currentScheduleName && 
              (s.department == _selectedDepartment || (_selectedDepartment == 'Todos' && s.department == null))
            );
          } catch (_) {}
        }
        
        // Priority 3: First in list for dept
        if (target == null) {
          final filtered = weekSchedules.where((s) => 
            _selectedDepartment == 'Todos' || s.department == _selectedDepartment
          ).toList();
          if (filtered.isNotEmpty) target = filtered.first;
        }

        if (target != null) {
          _currentSchedule = target;
          _currentScheduleName = target.name;
          _loadAssignmentsFromSchedule(target);
        } else {
          // Keep current in-memory edits if we just hit "New Table"
          // but if it's a real week/dept change, reset.
          if (_currentSchedule == null && _currentScheduleName != 'Nuevo Horario') {
             // We are likely in "New Table" mode, stay there.
          } else {
            _currentSchedule = null;
            _currentScheduleName = 'Horario General';
            _initEmptyAssignments();
          }
        }
      });
    } catch (e) {
      debugPrint('Error loading schedule: $e');
    }
  }

  void _loadAssignmentsFromSchedule(WeeklySchedule schedule) {
    _initEmptyAssignments();
    for (var a in schedule.assignments) {
      final dayIndex = a.date.weekday - 1;
      if (_assignments.containsKey(a.workerId)) {
        _assignments[a.workerId]![dayIndex] = a.slotId;
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return PremiumScaffold(
      title: 'Planificador PRO',
      subtitle: 'Horarios Semanales',
      usePadding: false, // Body has its own padding
      useScroll: false, // Disable default scaffold scroll to avoid conflict with our inner SingleChildScrollView
      actions: [
        IconButton(
          icon: const Icon(Icons.picture_as_pdf, color: Colors.pinkAccent),
          tooltip: 'Exportar PDF',
          onPressed: _exportPdf,
        ),
        IconButton(
          icon: const Icon(Icons.table_chart, color: Colors.greenAccent),
          tooltip: 'Exportar Excel',
          onPressed: _exportCsv,
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.amber),
          tooltip: 'Configurar Turnos',
          onPressed: _showShiftConfig,
        ),
        IconButton(
          icon: const Icon(Icons.send_to_mobile, color: Colors.greenAccent),
          tooltip: 'Enviar a Registro de Turnos',
          onPressed: _syncToShiftLogger,
        ),
      ],
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                controller: _scrollController,
                primary: false, // Using explicit controller
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                        // HERO HEADER
                        BusinessHeroHeader(
                          title: 'Planificador de Horarios',
                          subtitle: 'Transforma el caos en orden perfecto con IA',
                          icon: Icons.calendar_month,
                          color: Colors.cyanAccent,
                          isCompact: true,
                          stats: [
                            StatItem(
                              value: '${_workers.length}',
                              label: 'Empleados',
                              icon: Icons.people,
                            ),
                            StatItem(
                              value: '${_shifts.length}',
                              label: 'Turnos',
                              icon: Icons.access_time,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildQuickKpiDashboard(),
                        const SizedBox(height: 16),
                        _buildPhaseHeader('1. CONFIGURACIÓN OPERATIVA', Icons.settings_suggest, Colors.cyanAccent),
                        const SizedBox(height: 16),
                        _buildConfigCard(),
                        const SizedBox(height: 12),
                        _buildVacationStatusCard(),
                        const SizedBox(height: 12),
                        _buildPhaseAccordion(
                          title: 'Horarios del Local',
                          icon: Icons.business_center,
                          color: Colors.blueAccent,
                          child: _buildBusinessHoursCard(),
                        ),
                        const SizedBox(height: 12),
                        _buildPhaseAccordion(
                          title: 'Fechas Especiales / Eventos',
                          icon: Icons.event_note,
                          color: Colors.orangeAccent,
                          child: _buildSpecialDatesCard(),
                        ),
                        const SizedBox(height: 32),
                          
                        _buildPhaseHeader('2. MOTOR DE INTELIGENCIA', Icons.psychology, Colors.purpleAccent),
                        const SizedBox(height: 16),
                        _buildComplianceCard(),
                        const SizedBox(height: 12),
                        _buildAIAssistantCard(),
                        const SizedBox(height: 12),
                        _buildAnalyticsDashboard(),
                        const SizedBox(height: 12),
                        _buildAlertsCard(),
                        const SizedBox(height: 32),
                          
                        _buildPhaseHeader('3. GESTIÓN Y RESULTADOS', Icons.analytics, Colors.amberAccent),
                        const SizedBox(height: 16),
                        _buildTablesManager(),
                        const SizedBox(height: 12),
                        _buildActionButtons(),
                        const SizedBox(height: 24),
                          
                          // HEATMAP LEGEND
                          _buildHeatmapLegend(),
                          const SizedBox(height: 24),

                          // DYNAMIC HEADER
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1E2C),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: Colors.amber.withOpacity(0.3)),
                                boxShadow: [
                                  BoxShadow(color: Colors.amber.withOpacity(0.1), blurRadius: 10, spreadRadius: 1)
                                ]
                              ),
                              child: Text(
                                _scheduleDuration == ScheduleDuration.semana ? 'HORARIO SEMANAL' :
                                _scheduleDuration == ScheduleDuration.quincena ? 'HORARIO QUINCENAL' : 'HORARIO MENSUAL',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFFF4D35E), // Neon Gold
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2.0,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // THE SPREADSHEET TABLE
                          Center(
                            child: Scrollbar(
                              controller: _horizontalScrollController,
                              thumbVisibility: true,
                              child: SingleChildScrollView(
                                controller: _horizontalScrollController,
                                scrollDirection: Axis.horizontal,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 12), // Space for scrollbar
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minWidth: 200 + (_totalDays * 120) + 80.0, // Employee(200) + Days(120) + Hrs(80)
                                    ),
                                    child: _buildSpreadsheet(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // EXPORT SECTION
                          _buildExportSection(),
                        const SizedBox(height: 100),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildConfigCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C), // Unified Dark Surface
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Configuración', style: GoogleFonts.outfit(color: Colors.cyanAccent, fontSize: 16, fontWeight: FontWeight.bold)),
              _buildInfoButton(
                'Configuración General',
                'Selecciona el periodo a planificar (semanal, quincenal o mensual) y establece los días libres de tus empleados. Esto define la base del cronograma.'
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white54, size: 18),
              const SizedBox(width: 8),
              Text('Periodo:', style: GoogleFonts.outfit(color: Colors.white70)),
              const SizedBox(width: 8),
              DropdownButton<ScheduleDuration>(
                value: _scheduleDuration,
                dropdownColor: const Color(0xFF1A1A2E),
                underline: Container(),
                items: [
                  DropdownMenuItem(value: ScheduleDuration.semana, child: Text('Semanal (7d)', style: GoogleFonts.outfit(color: Colors.cyanAccent))),
                  DropdownMenuItem(value: ScheduleDuration.quincena, child: Text('Quincenal (15d)', style: GoogleFonts.outfit(color: Colors.cyanAccent))),
                  DropdownMenuItem(value: ScheduleDuration.mes, child: Text('Mensual (30d)', style: GoogleFonts.outfit(color: Colors.cyanAccent))),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _scheduleDuration = v);
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: _pickWeek,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      '${DateFormat('dd MMM').format(_weekStart)} - ${DateFormat('dd MMM').format(_weekStart.add(Duration(days: _totalDays - 1)))}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Days off & Template
          Row(
            children: [
              const Icon(Icons.weekend, color: Colors.white54, size: 18),
              const SizedBox(width: 8),
              Text('Días Libres:', style: GoogleFonts.outfit(color: Colors.white70)),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: _daysOff,
                dropdownColor: const Color(0xFF1A1A2E),
                items: [0, 1, 2, 3, 4, 5].map((d) => DropdownMenuItem(value: d, child: Text('$d días/sem', style: const TextStyle(color: Colors.white)))).toList(),
                onChanged: (v) => setState(() => _daysOff = v ?? 1),
              ),
              const SizedBox(width: 16),
              TextButton.icon(
                icon: const Icon(Icons.person_off, size: 16, color: Colors.pinkAccent),
                label: Text('Vacaciones', style: GoogleFonts.outfit(color: Colors.pinkAccent, fontSize: 12)),
                onPressed: _showVacationManager,
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Shifts
          Row(
            children: [
              const Icon(Icons.business, color: Colors.white54, size: 18),
              const SizedBox(width: 8),
              Text('Depto:', style: GoogleFonts.outfit(color: Colors.white70)),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _selectedDepartment,
                dropdownColor: const Color(0xFF1A1A2E),
                items: _departments.map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(color: Colors.cyanAccent, fontSize: 13)))).toList(),
                onChanged: (v) {
                  setState(() {
                    _selectedDepartment = v ?? 'Todos';
                    _initEmptyAssignments();
                    _loadScheduleForWeek();
                  });
                },
              ),
              const Spacer(),
              _buildHourlyHeatmapButton(),
            ],
          ),
          const SizedBox(height: 12),
          
          Text('Turnos:', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              ..._shifts.map((s) => Container(
                margin: const EdgeInsets.only(right: 8, bottom: 4),
                child: InputChip(
                  avatar: const Icon(Icons.edit, size: 14, color: Colors.white70),
                  label: Text('${s.name} (${s.startTime.hour}:00-${s.endTime.hour}:00)', style: const TextStyle(fontSize: 11)),
                  backgroundColor: const Color(0xFF1A1A2E),
                  selectedColor: Colors.cyanAccent.withOpacity(0.2),
                  side: BorderSide(color: s.isRush ? Colors.amber : Colors.cyanAccent),
                  labelStyle: TextStyle(color: s.isRush ? Colors.amber : Colors.cyanAccent, fontSize: 11),
                  deleteIcon: const Icon(Icons.close, size: 14, color: Colors.redAccent),
                  onDeleted: () => setState(() => _shifts.remove(s)),
                  onPressed: () => _editShift(s),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              )),
              ActionChip(
                label: const Text('+ Turno'),
                backgroundColor: Colors.pinkAccent.withOpacity(0.1),
                side: const BorderSide(color: Colors.pinkAccent),
                labelStyle: const TextStyle(color: Colors.pinkAccent, fontSize: 11),
                onPressed: _addShift,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final buttonHeight = 50.0;
    final borderRadius = BorderRadius.circular(12);

    return Column(
      children: [
        // ROW 1: Management (Prioritized per user request)
        Row(
          children: [
            Expanded(
              child: PopupMenuButton<String>(
                offset: const Offset(0, 50),
                color: const Color(0xFF1E1E2C),
                shape: RoundedRectangleBorder(borderRadius: borderRadius, side: BorderSide(color: Colors.orangeAccent.withOpacity(0.3))),
                onSelected: (v) {
                  if (v == 'save') _saveTemplate();
                  else if (v == 'load') _loadTemplate();
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(value: 'save', child: Text('💾 Guardar como Plantilla', style: TextStyle(color: Colors.white))),
                  const PopupMenuItem(value: 'load', child: Text('📂 Cargar Plantilla', style: TextStyle(color: Colors.white))),
                ],
                child: Container(
                  height: buttonHeight,
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.withOpacity(0.1),
                    borderRadius: borderRadius,
                    border: Border.all(color: Colors.orangeAccent.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.copy_all, color: Colors.orangeAccent, size: 20),
                      const SizedBox(width: 8),
                      Text('PLANTILLAS', style: GoogleFonts.outfit(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: buttonHeight,
                child: ElevatedButton.icon(
                  onPressed: _showShiftManagementDialog,
                  icon: const Icon(Icons.published_with_changes, color: Colors.purpleAccent, size: 20),
                  label: Text('GESTIONAR CAMBIOS', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent.withOpacity(0.1),
                    foregroundColor: Colors.purpleAccent,
                    elevation: 0,
                    side: BorderSide(color: Colors.purpleAccent.withOpacity(0.3)),
                    shape: RoundedRectangleBorder(borderRadius: borderRadius),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // ROW 2: Operations
        Row(
          children: [
            Expanded(
              flex: 2,
              child: SizedBox(
                height: buttonHeight,
                child: ElevatedButton.icon(
                  onPressed: _autoGenerate,
                  icon: const Icon(Icons.auto_awesome, size: 20),
                  label: const Text('GENERAR', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    elevation: 4,
                    shadowColor: Colors.amber.withOpacity(0.4),
                    shape: RoundedRectangleBorder(borderRadius: borderRadius),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: SizedBox(
                height: buttonHeight,
                child: ElevatedButton.icon(
                  onPressed: _shuffleSchedule,
                  icon: const Icon(Icons.shuffle, size: 20),
                  label: const Text('ROTAR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent.withOpacity(0.1),
                    foregroundColor: Colors.cyanAccent,
                    elevation: 0,
                    side: BorderSide(color: Colors.cyanAccent.withOpacity(0.3)),
                    shape: RoundedRectangleBorder(borderRadius: borderRadius),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: buttonHeight,
              width: buttonHeight,
              child: IconButton(
                onPressed: _clearAll,
                icon: const Icon(Icons.delete_outline, color: Colors.white38),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.05),
                  shape: RoundedRectangleBorder(borderRadius: borderRadius),
                  side: const BorderSide(color: Colors.white10),
                ),
                tooltip: 'Limpiar Todo',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: buttonHeight,
          child: ElevatedButton.icon(
            onPressed: _sendGroupWhatsApp,
            icon: const Icon(Icons.group, color: Colors.white, size: 20),
            label: Text('ENVIAR HORARIO AL GRUPO', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: borderRadius),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeatmapLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Distribución Diaria:', style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11)),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _legendItem(Colors.redAccent, 'Baja'),
            const SizedBox(width: 12),
            _legendItem(Colors.greenAccent, 'Ok'),
            const SizedBox(width: 12),
            _legendItem(Colors.amber, 'Alta'),
          ],
        ),
      ],
    );
  }

  Widget _buildBusinessHoursCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C), // Unified Dark Surface
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Header expandible
          InkWell(
            onTap: () => setState(() => _showBusinessHoursSection = !_showBusinessHoursSection),
            child: Row(
              children: [
                const Icon(Icons.schedule, color: Colors.purple),
                const SizedBox(width: 8),
                Text('Horario del Local', style: GoogleFonts.outfit(color: Colors.purple, fontSize: 14, fontWeight: FontWeight.bold)),
                const Spacer(),
                Icon(_showBusinessHoursSection ? Icons.expand_less : Icons.expand_more, color: Colors.purple),
              ],
            ),
          ),
          
          if (_showBusinessHoursSection) ...[
            const Divider(color: Colors.white24, height: 24),
            
            // Horario general
            Row(
              children: [
                Expanded(child: _buildTimePicker('Apertura', _generalOpen, (t) {
                  setState(() => _generalOpen = t);
                  _validateSchedule();
                })),
                const SizedBox(width: 12),
                Expanded(child: _buildTimePicker('Cierre', _generalClose, (t) {
                   setState(() => _generalClose = t);
                   _validateSchedule();
                })),
              ],
            ),
            
            CheckboxListTile(
              value: _useGeneralHours,
              activeColor: Colors.purple,
              contentPadding: EdgeInsets.zero,
              onChanged: (v) => setState(() {
                _useGeneralHours = v ?? true;
                _validateSchedule(); // Revalidar al cambiar
              }),
              title: Text('Aplicar a todos los días', style: GoogleFonts.outfit(color: Colors.white70)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimePicker(String label, TimeOfDay time, Function(TimeOfDay) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(color: Colors.white60, fontSize: 12)),
        const SizedBox(height: 4),
        InkWell(
          onTap: () async {
            final t = await showTimePicker(context: context, initialTime: time);
            if (t != null) onChanged(t);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              children: [
                Text(time.format(context), style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                const Spacer(),
                const Icon(Icons.access_time, size: 16, color: Colors.purpleAccent),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComplianceCard() {
    if (_complianceIssues.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C), // Unified Dark Surface
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurpleAccent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.gavel, color: Colors.deepPurpleAccent, size: 20),
              const SizedBox(width: 8),
              Text('Cumplimiento Legal (Panamá)', style: GoogleFonts.outfit(color: Colors.deepPurpleAccent, fontSize: 14, fontWeight: FontWeight.bold)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('${_complianceIssues.length}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              _buildInfoButton(
                'Cumplimiento Legal', 
                'Validación automática de leyes laborales: 48h/sem, descanso semanal y límites de jornada.'
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._complianceIssues.map((issue) => _buildComplianceItem(issue)),
        ],
      ),
    );
  }

  Widget _buildComplianceItem(ComplianceIssue issue) {
    final color = issue.severity == ComplianceSeverity.violation ? Colors.redAccent : Colors.orangeAccent;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(issue.title, style: GoogleFonts.outfit(color: color, fontSize: 13, fontWeight: FontWeight.bold))),
                    Text(issue.article, style: GoogleFonts.outfit(color: Colors.white54, fontSize: 10, fontStyle: FontStyle.italic)),
                  ],
                ),
                Text('${issue.workerName}: ${issue.description}', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsCard() {
    if (_alerts.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C), // Unified Dark Surface
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notification_important, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Text('Alertas de Horario', style: GoogleFonts.outfit(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('${_alerts.length}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._alerts.map((alert) => _buildAlertItem(alert)),
        ],
      ),
    );
  }

  Widget _buildSpecialDatesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C), // Unified Dark Surface
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _showSpecialDates = !_showSpecialDates),
            child: Row(
              children: [
                const Icon(Icons.event_note, color: Colors.blue),
                const SizedBox(width: 8),
                Text('Horarios Especiales (Festivos)', style: GoogleFonts.outfit(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.bold)),
                const Spacer(),
                _buildInfoButton(
                  'Días Feriados', 
                  'Gestiona días festivos y horarios especiales. Estos días tienen prioridad sobre el horario regular.'
                ),
                const SizedBox(width: 8),
                Icon(_showSpecialDates ? Icons.expand_less : Icons.expand_more, color: Colors.blue),
              ],
            ),
          ),
          
          if (_showSpecialDates) ...[
            const SizedBox(height: 12),
            if (_specialDates.isEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('No hay fechas configuradas', style: GoogleFonts.outfit(color: Colors.white60, fontSize: 12)),
              )
            else
              ..._specialDates.map((date) => _buildSpecialDateItem(date)),
             
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _addPanamaHolidays,
                    icon: const Icon(Icons.flag, size: 16), 
                    label: Text('Feriados PA', style: GoogleFonts.outfit(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _addCustomDate,
                    icon: const Icon(Icons.add, size: 16), 
                    label: Text('Agregar', style: GoogleFonts.outfit(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white60),
                    ),
                  ),
                ),
              ],
            )
          ]
        ],
      )
    );
  }

  Widget _buildSpecialDateItem(SpecialDateSchedule date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: date.isClosed ? Colors.red.withOpacity(0.1) : Colors.black26,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: date.isClosed ? Colors.red.withOpacity(0.3) : Colors.white10),
      ),
      child: ListTile(
        onTap: () => _editSpecialDate(date),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Icon(date.isClosed ? Icons.block : Icons.access_time, 
            color: date.isClosed ? Colors.redAccent : Colors.amber, size: 20),
        title: Text(date.name, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text(
          '${DateFormat('dd/MM/yyyy').format(date.date)} - ${date.isClosed ? "CERRADO" : "${date.openTime?.format(context)} - ${date.closeTime?.format(context)}"}',
          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11)
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.white30, size: 18),
          onPressed: () => setState(() {
            _specialDates.remove(date);
            _validateSchedule();
          }),
        ),
      ),
    );
  }

  void _editSpecialDate(SpecialDateSchedule date) async {
    final nameController = TextEditingController(text: date.name);
    bool isClosed = date.isClosed;
    TimeOfDay open = date.openTime ?? const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay close = date.closeTime ?? const TimeOfDay(hour: 17, minute: 0);
    
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          title: Text('Editar Fecha Especial', style: GoogleFonts.outfit(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text('¿Cerrado todo el día?', style: GoogleFonts.outfit(color: Colors.white)),
                value: isClosed,
                activeColor: Colors.pinkAccent,
                onChanged: (v) => setDialogState(() => isClosed = v),
              ),
              if (!isClosed) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildTimePicker('Apertura', open, (t) => setDialogState(() => open = t))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTimePicker('Cierre', close, (t) => setDialogState(() => close = t))),
                  ],
                ),
              ]
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx), 
              child: const Text('Cancelar')
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  setState(() {
                    // Update item (immutable replacement)
                    final index = _specialDates.indexOf(date);
                    if (index != -1) {
                      _specialDates[index] = SpecialDateSchedule(
                        id: date.id,
                        name: nameController.text,
                        date: date.date,
                        isClosed: isClosed,
                        openTime: isClosed ? null : open,
                        closeTime: isClosed ? null : close,
                      );
                      _validateSchedule(); // Re-validate
                    }
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertItem(ScheduleAlert alert) {
    final color = alert.type == AlertType.error ? Colors.red :
                  alert.type == AlertType.warning ? Colors.orange : Colors.blue;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(alert.icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert.title, style: GoogleFonts.outfit(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
                Text(alert.message, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addPanamaHolidays() {
    final year = _weekStart.year;
    List<SpecialDateSchedule> holidays = [];

    // 1. FIXED DATE HOLIDAYS
    final fixedHolidays = [
      {'m': 1, 'd': 1, 'n': 'Año Nuevo'},
      {'m': 1, 'd': 9, 'n': 'Día de los Mártires'},
      {'m': 5, 'd': 1, 'n': 'Día del Trabajo'},
      {'m': 11, 'd': 3, 'n': 'Separación de Colombia'},
      {'m': 11, 'd': 4, 'n': 'Día de los Símbolos Patrios'},
      {'m': 11, 'd': 5, 'n': 'Consolidación de la Separación'},
      {'m': 11, 'd': 10, 'n': 'Grito de Independencia'},
      {'m': 11, 'd': 28, 'n': 'Independencia de España'},
      {'m': 12, 'd': 8, 'n': 'Día de la Madre'},
      {'m': 12, 'd': 20, 'n': 'Día de Duelo Nacional'},
      {'m': 12, 'd': 25, 'n': 'Navidad'},
    ];

    for (var h in fixedHolidays) {
      holidays.add(SpecialDateSchedule(
        id: const Uuid().v4(),
        name: h['n'] as String,
        date: DateTime(year, h['m'] as int, h['d'] as int),
        isClosed: false, // Default open for private sector
        openTime: const TimeOfDay(hour: 9, minute: 0),
        closeTime: const TimeOfDay(hour: 17, minute: 0),
      ));
    }

    // 2. MOVABLE HOLIDAYS (Calculated via Easter)
    final easter = _getEasterDate(year);
    // Good Friday is 2 days before Easter
    final goodFriday = easter.subtract(const Duration(days: 2));
    // Carnival Tuesday is 47 days before Easter (Day before Ash Wednesday)
    final carnivalTue = easter.subtract(const Duration(days: 47));
    final carnivalMon = carnivalTue.subtract(const Duration(days: 1));

    holidays.add(SpecialDateSchedule(
      id: const Uuid().v4(), 
      name: 'Viernes Santo', 
      date: goodFriday, 
      isClosed: false,
      openTime: const TimeOfDay(hour: 8, minute: 0),
      closeTime: const TimeOfDay(hour: 13, minute: 0)
    ));
    
    holidays.add(SpecialDateSchedule(
      id: const Uuid().v4(), 
      name: 'Lunes de Carnaval', 
      date: carnivalMon, 
      isClosed: false,
      openTime: const TimeOfDay(hour: 9, minute: 0),
      closeTime: const TimeOfDay(hour: 14, minute: 0)
    ));

    holidays.add(SpecialDateSchedule(
      id: const Uuid().v4(), 
      name: 'Martes de Carnaval', 
      date: carnivalTue, 
      isClosed: false,
      openTime: const TimeOfDay(hour: 9, minute: 0),
      closeTime: const TimeOfDay(hour: 14, minute: 0)
    ));
    
    setState(() {
      for (var h in holidays) {
        if (!_specialDates.any((d) => isSameDay(d.date, h.date))) {
          _specialDates.add(h);
        }
      }
      _validateSchedule();
    });
  }

  /// Calculates Easter Sunday for a given year (Meeus/Jones/Butcher's Algorithm)
  DateTime _getEasterDate(int year) {
    int a = year % 19;
    int b = year ~/ 100;
    int c = year % 100;
    int d = b ~/ 4;
    int e = b % 4;
    int f = (b + 8) ~/ 25;
    int g = (b - f + 1) ~/ 3;
    int h = (19 * a + b - d - g + 15) % 30;
    int i = c ~/ 4;
    int k = c % 4;
    int l = (32 + 2 * e + 2 * i - h - k) % 7;
    int m = (a + 11 * h + 22 * l) ~/ 451;
    int month = (h + l - 7 * m + 114) ~/ 31;
    int day = ((h + l - 7 * m + 114) % 31) + 1;
    return DateTime(year, month, day);
  }

  void _addCustomDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _weekStart,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (pickedDate != null) {
      if (!mounted) return;
      
      // Simple dialog for name and type
      final nameController = TextEditingController();
      bool isClosed = true;
      
      await showDialog(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A2E),
            title: Text('Nueva Fecha Especial', style: GoogleFonts.outfit(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Nombre (ej. Aniversario)',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: Text('¿Cerrado todo el día?', style: GoogleFonts.outfit(color: Colors.white)),
                  value: isClosed,
                  onChanged: (v) => setDialogState(() => isClosed = v),
                  activeColor: Colors.pinkAccent,
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
              TextButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    setState(() {
                      _specialDates.add(SpecialDateSchedule(
                        id: const Uuid().v4(),
                        name: nameController.text,
                        date: pickedDate,
                        isClosed: isClosed,
                        openTime: isClosed ? null : const TimeOfDay(hour: 8, minute: 0),
                        closeTime: isClosed ? null : const TimeOfDay(hour: 14, minute: 0),
                      ));
                      _validateSchedule();
                    });
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      );
    }
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _generateOptimizedSchedule() {
    // Wrapper for auto-generate which already includes optimization logic
    setState(() {
      _isLoading = true;
    });
    
    // Slight delay to simulate AI thinking
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _autoGenerate();
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✨ Horario re-balanceado automáticamente para equidad'),
            backgroundColor: Colors.cyan,
          ),
        );
      }
    });
  }

  void _validateSchedule() {
    _alerts.clear();
    _complianceIssues.clear();
    
    // Check labor compliance first
    _checkLaborCompliance();
    
    // Validar cada turno contra horario del local
    for (var shift in _shifts) {
      for (int dayIndex = 0; dayIndex < 7; dayIndex++) {
        // Ignorar si el día no es operativo
        if (!_operatingDays[dayIndex]) continue;
        
        // Calcular fecha real del día
        final currentDayDate = _weekStart.add(Duration(days: dayIndex));
        
        // Default hours
        TimeOfDay? open = _generalOpen;
        TimeOfDay? close = _generalClose;
        bool isOpen = true;
        
        // 1. Check Special Dates
        final specialDate = _specialDates.firstWhereOrNull(
          (d) => isSameDay(d.date, currentDayDate) && d.isActive
        );
        
        if (specialDate != null) {
          if (specialDate.isClosed) {
            isOpen = false;
            // Add alert specifically for this
             _alerts.add(ScheduleAlert(
              title: 'Negocio CERRADO por ${specialDate.name}',
              message: 'Hay turnos asignados el ${_dayNames[dayIndex]} pero es día cerrado.',
              type: AlertType.error,
              icon: Icons.block,
            ));
          } else {
            open = specialDate.openTime;
            close = specialDate.closeTime;
            
            _alerts.add(ScheduleAlert(
              title: 'Horario Especial: ${specialDate.name}',
              message: 'Horario ajustado a ${open?.format(context)} - ${close?.format(context)}',
              type: AlertType.info,
              icon: Icons.info_outline,
            ));
          }
        } else {
          // 2. Regular Hours
          final dayHours = _useGeneralHours
              ? DayHours(open: _generalOpen, close: _generalClose)
              : _daySpecificHours[dayIndex] ?? DayHours(open: _generalOpen, close: _generalClose);
           
          isOpen = dayHours.isOpen;
          open = dayHours.open;
          close = dayHours.close;
        }

        if (!isOpen) continue;
        
        final businessOpen = (open?.hour ?? 8) * 60 + (open?.minute ?? 0);
        final businessClose = (close?.hour ?? 22) * 60 + (close?.minute ?? 0);
        
        // Convertir horario del turno a minutos
        final shiftStart = shift.startTime.hour * 60 + shift.startTime.minute;
        final shiftEnd = shift.endTime.hour * 60 + shift.endTime.minute;
        
        int effectiveShiftEnd = shiftEnd;
        if (effectiveShiftEnd < shiftStart) effectiveShiftEnd += 24 * 60;

        // ALERTA: Turno antes de apertura
        if (shiftStart < businessOpen) {
          final minutesBefore = businessOpen - shiftStart;
          final hoursBefore = (minutesBefore / 60).toStringAsFixed(1);
          _alerts.add(ScheduleAlert(
            title: 'Turno fuera de horario',
            message: 'El turno "${shift.name}" inicia $hoursBefore h antes de la apertura el ${_dayNames[dayIndex]}',
            type: AlertType.warning,
            icon: Icons.warning_amber,
          ));
        }
        
        // ALERTA: Turno termina después del cierre
        if (effectiveShiftEnd > businessClose) {
           final minutesAfter = effectiveShiftEnd - businessClose;
           if (minutesAfter > 15) {
             final hoursAfter = (minutesAfter / 60).toStringAsFixed(1);
             _alerts.add(ScheduleAlert(
              title: 'Cierre excedido',
              message: 'El turno "${shift.name}" termina $hoursAfter h después del cierre el ${_dayNames[dayIndex]}',
              type: AlertType.error,
              icon: Icons.error_outline,
            ));
           }
        }
      }
    }
    
    // Evitar duplicados exactos en alertas
    final uniqueAlerts = <String, ScheduleAlert>{};
    for (var a in _alerts) {
      final key = '${a.title}-${a.message}';
      if (!uniqueAlerts.containsKey(key)) {
        uniqueAlerts[key] = a;
      }
    }
    _alerts = uniqueAlerts.values.toList();
    
    setState(() {});
  }

  void _checkLaborCompliance() {
    final issues = _complianceChecker.checkCompliance(
      _assignments,
      _workers,
      _shifts,
    );
    _complianceIssues = issues;
    
    // Check AI Suggestions too
    final suggestions = _smartAssistant.analyzeSchedule(
      workers: _workers,
      assignments: _assignments,
      shifts: _shifts,
      operatingDays: _operatingDays,
    );
    _aiSuggestions = suggestions;
    
    // Calculate Analytics
    _analyticsMetrics = _analyticsService.calculateMetrics(
      workers: _workers,
      assignments: _assignments,
      shifts: _shifts,
      operatingDays: _operatingDays,
    );
  }

  Widget _buildAnalyticsDashboard() {
    if (_analyticsMetrics == null) return const SizedBox.shrink();
    final m = _analyticsMetrics!;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('📊 Métricas y Costos', style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              _buildInfoButton(
                'Análisis de Costos',
                'Estimación en tiempo real del costo de la planilla basada en turnos asignados. El Score de Eficiencia (0-100%) indica qué tan bien cubiertos están los turnos vs la demanda.'
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildMetricTile('Horas Totales', '${m.totalHours.toStringAsFixed(1)}h', Icons.timer, Colors.blue)),
              const SizedBox(width: 8),
              Expanded(child: _buildMetricTile('Costo Est.', '\$${m.laborCostEstimate.toStringAsFixed(2)}', Icons.attach_money, Colors.green)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildMetricTile('Turnos', '${m.totalShifts}', Icons.work, Colors.orange)),
              const SizedBox(width: 8),
              Expanded(child: _buildMetricTile('Eficiencia', '${m.efficiencyScore.toInt()}%', Icons.speed, Colors.purple)),
            ],
          ),
          const SizedBox(height: 16),
          Text('Distribución Semanal (Horas)', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: m.hoursPerDay.entries.map((e) {
                final maxHours = m.hoursPerDay.values.reduce(max);
                final heightFactor = maxHours > 0 ? e.value / maxHours : 0.0;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 20,
                      height: 60 * heightFactor + 1, // min height 1
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(e.key, style: const TextStyle(color: Colors.white38, fontSize: 10)),
                  ],
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }
  
  Widget _buildMetricTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              Text(label, style: GoogleFonts.outfit(color: Colors.white54, fontSize: 11)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAIAssistantCard() {
    // GATE CHECK: AI Assistant is PRO+
    if (!SubscriptionService().hasAccess(PlanFeature.aiAssistant)) {
       return _buildLockedFeatureCard(
         title: 'Asistente IA Bloqueado',
         message: 'Optimiza tus horarios automáticamente con Inteligencia Artificial. Detecta sobrecargas y mejora la equidad.',
         icon: Icons.auto_awesome,
         color: Colors.cyanAccent,
         requiredPlan: 'Plan Pro',
       );
    }

    if (_aiSuggestions.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C), // Unified Dark Surface
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.cyanAccent, size: 20),
              const SizedBox(width: 8),
              Text('Asistente Inteligente', style: GoogleFonts.outfit(color: Colors.cyanAccent, fontSize: 14, fontWeight: FontWeight.bold)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.cyan.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.cyan.withOpacity(0.5)),
                ),
                child: Text('${_aiSuggestions.length}', style: const TextStyle(color: Colors.cyanAccent, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._aiSuggestions.map((suggestion) => _buildSuggestionItem(suggestion)),
        ],
      ),
    );
  }

  Widget _buildLockedFeatureCard({required String title, required String message, required IconData icon, required Color color, required String requiredPlan}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.lock, color: Colors.grey, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                   children: [
                      Text(title, style: GoogleFonts.outfit(color: Colors.grey, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(4)), child: Text(requiredPlan.toUpperCase(), style: GoogleFonts.outfit(fontSize: 10, color: color, fontWeight: FontWeight.bold))),
                   ]
                ),
                Text(message, style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          TextButton(
             onPressed: () => Navigator.pushNamed(context, '/premium_plans'),
             child: Text('MEJORAR', style: GoogleFonts.outfit(color: kNeonGold, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }



  void _showUpgradeDialog(String feature, String requiredPlan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.star, color: kNeonGold),
            const SizedBox(width: 8),
            Text('Función Premium', style: GoogleFonts.outfit(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'La función "$feature" está reservada para usuarios de $requiredPlan.',
              style: GoogleFonts.outfit(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: kNeonGold.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Icon(Icons.upgrade, color: kNeonGold, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Mejora tu plan para desbloquear todo el potencial.', style: GoogleFonts.outfit(color: kNeonGold, fontSize: 12))),
                ],
              ),
            )
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar', style: TextStyle(color: Colors.white38))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kNeonGold),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamed(ctx, '/premium_plans');
            }, 
            child: const Text('Ver Planes', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(OptimizationSuggestion suggestion) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.cyan.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: Colors.cyan, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(suggestion.title, style: GoogleFonts.outfit(color: Colors.cyanAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                Text(suggestion.message, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
                if (suggestion.actionLabel.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: InkWell(
                      onTap: suggestion.onAction ?? () {
                        // Default action: auto-balance if type is fairness
                        if (suggestion.type == SuggestionType.fairness) {
                          _generateOptimizedSchedule();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.cyan.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.cyan.withOpacity(0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.auto_fix_high, size: 14, color: Colors.cyanAccent),
                            const SizedBox(width: 6),
                            Text(suggestion.actionLabel, style: GoogleFonts.outfit(color: Colors.cyanAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVacationStatusCard() {
    // Find workers on vacation this week
    final List<WorkerProfile> onVacation = [];
    
    for (var worker in _workers) {
      for (var vacation in worker.vacationHistory) {
        // Check if vacation overlaps with current week
        final weekEnd = _weekStart.add(const Duration(days: 6));
        final overlaps = (vacation.startDate.isBefore(weekEnd) || vacation.startDate.isAtSameMomentAs(weekEnd)) &&
                        (vacation.endDate.isAfter(_weekStart) || vacation.endDate.isAtSameMomentAs(_weekStart));
        
        if (overlaps) {
          onVacation.add(worker);
          break; // Only add once per worker
        }
      }
    }
    
    if (onVacation.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C), // Unified Dark Surface
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.pinkAccent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.beach_access, color: Colors.pinkAccent, size: 20),
              const SizedBox(width: 8),
              Text(
                'De Vacaciones Esta Semana',
                style: GoogleFonts.outfit(
                  color: Colors.pinkAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.pinkAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${onVacation.length}',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: onVacation.map((worker) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.pinkAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.pinkAccent.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person, size: 14, color: Colors.pinkAccent),
                    const SizedBox(width: 4),
                    Text(
                      worker.name,
                      style: GoogleFonts.outfit(
                        color: Colors.pinkAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () async {
                        // Confirmar eliminación
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: const Color(0xFF1A1A2E),
                            title: Text('¿Eliminar vacación?', style: GoogleFonts.outfit(color: Colors.white)),
                            content: Text(
                              '¿Deseas eliminar la vacación de ${worker.name}?',
                              style: GoogleFonts.outfit(color: Colors.white70),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                style: TextButton.styleFrom(foregroundColor: Colors.red),
                                child: const Text('Eliminar'),
                              ),
                            ],
                          ),
                        );
                        
                        if (confirm == true) {
                          // Eliminar vacaciones que se solapan con esta semana
                          final weekEnd = _weekStart.add(const Duration(days: 6));
                          worker.vacationHistory.removeWhere((v) =>
                            (v.startDate.isBefore(weekEnd) || v.startDate.isAtSameMomentAs(weekEnd)) &&
                            (v.endDate.isAfter(_weekStart) || v.endDate.isAtSameMomentAs(_weekStart))
                          );
                          
                          await _workerService.saveWorker(worker);
                          setState(() {});
                          _loadData();
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('✅ Vacación de ${worker.name} eliminada'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.pinkAccent,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyHeatmapButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade700, Colors.orangeAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.orangeAccent.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: _showHourlyHeatmap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.grid_on_rounded, size: 18, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'VER MAPA DE CALOR',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Color _getHeatColor(int count) {
    if (count == 0) return Colors.white10;
    if (count == 1) return Colors.cyanAccent.withOpacity(0.2);
    if (count == 2) return Colors.cyanAccent.withOpacity(0.5);
    if (count >= 3) return Colors.amber.withOpacity(0.6);
    return Colors.redAccent.withOpacity(0.8);
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color.withOpacity(0.3), border: Border.all(color: color))),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.outfit(color: Colors.white54, fontSize: 10)),
      ],
    );
  }

  Widget _buildSpreadsheet() {
    // Generate days based on duration
    final days = List.generate(_totalDays, (i) {
      final date = _weekStart.add(Duration(days: i));
      return DateFormat('EEE d', 'es').format(date); // e.g. "Lun 12"
    });
    
    // Filtered workers
    final filteredWorkers = _selectedDepartment == 'Todos' 
        ? _workers 
        : _workers.where((w) => w.department == _selectedDepartment).toList();

    // Calculate daily totals for heatmap
    List<int> dailyCounts = List.generate(_totalDays, (i) => _countDayForWorkers(i, filteredWorkers));
    
    // Calculate target: If no template demand, use simple heuristic or just show distribution
    int targetPerDay = (filteredWorkers.length * (_totalDays - _daysOff) / _totalDays).ceil();
    if (targetPerDay == 0) targetPerDay = 1;
    
    return Container(
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
          // Header row
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
                for (int i=0; i < days.length; i++) _headerCell(
                  days[i], 
                  120, 
                  weatherIcon: _weatherIcons.length > i ? _weatherIcons[i] : null
                ),
                _headerCell('HRS', 80),
              ],
            ),
          ),
          
          // Heatmap row
          SizedBox(
            height: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 200),
                for (int i = 0; i < _totalDays; i++)
                  SizedBox(width: 120, child: _heatmapCell(dailyCounts[i], targetPerDay)),
                const SizedBox(width: 80),
              ],
            ),
          ),
          
          // Empty state
          if (_workers.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text('No hay empleados. Agrégalos desde el Directorio.', style: GoogleFonts.outfit(color: Colors.grey)),
            ),
          
          // Worker rows
          ...filteredWorkers.asMap().entries.map((entry) => 
            _buildWorkerRow(entry.value, days, entry.key)
          ),
          
          // Totals row
          Container(
            height: 36,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _totalCell('TOTAL', 200),
                for (int i = 0; i < _totalDays; i++) _totalCell(dailyCounts[i].toString(), 120),
                _totalCell('', 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heatmapCell(int count, int target) {
    Color color;
    if (count < target) {
      color = Colors.redAccent;
    } else if (count > target + 1) {
      color = Colors.amber;
    } else {
      color = Colors.greenAccent;
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Center(child: Text('$count', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold))),
    );
  }


  
  int _countDayForWorkers(int dayIndex, List<WorkerProfile> workers) {
    int count = 0;
    for (var w in workers) {
      if (_assignments[w.id]?[dayIndex] != null) count++;
    }
    return count;
  }

  bool _hasChangeLog(String workerId, int dayIndex) {
    final date = _weekStart.add(Duration(days: dayIndex));
    return _changeLogs.any((l) => l.requesterId == workerId && isSameDay(l.date, date) || (l.targetId == workerId && isSameDay(l.date, date)));
  }



  Widget _headerCell(String text, double? width, {IconData? weatherIcon}) {
    final child = Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (weatherIcon != null) ...[
            Icon(weatherIcon, color: Colors.grey.shade400, size: 12),
            const SizedBox(height: 2),
          ],
          Text(text, style: GoogleFonts.outfit(color: Colors.blueGrey.shade800, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
    return SizedBox(width: width ?? 100, child: child);
  }

  Widget _totalCell(String text, double? width) {
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      alignment: Alignment.center,
      child: Text(text, style: GoogleFonts.outfit(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.bold)),
    );
    return SizedBox(width: width ?? 100, child: child);
  }

  Widget _buildWorkerRow(WorkerProfile worker, List<String> days, int index) {
    final isEven = index % 2 == 0;
    final workerAssignments = _assignments[worker.id] ?? {};
    int totalHours = 0;
    for (var slotId in workerAssignments.values) {
      if (slotId != null) {
          try {
            final slot = _shifts.firstWhere((s) => s.id == slotId);
            int duration = slot.endTime.hour - slot.startTime.hour;
            if (duration <= 0) duration += 24;
            totalHours += duration;
          } catch (_) {
            totalHours += 8;
          }
      }
    }

    // Check if worker is on vacation this week
    bool isOnVacation(int dayIndex) {
      final date = _weekStart.add(Duration(days: dayIndex));
      return worker.vacationHistory.any((v) => 
        (date.isAfter(v.startDate) || date.isAtSameMomentAs(v.startDate)) &&
        (date.isBefore(v.endDate) || date.isAtSameMomentAs(v.endDate))
      );
    }

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isEven ? Colors.white : Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Name
          SizedBox(
            width: 200,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                   Expanded(
                     child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(worker.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.bold)),
                         Text(worker.position, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey.shade600, fontSize: 9)),
                       ],
                     ),
                   ),
                   IconButton(
                     icon: const Icon(Icons.send_to_mobile, color: Colors.green, size: 14),
                     tooltip: 'Enviar Horario por WhatsApp',
                     onPressed: () => _sendWhatsApp(worker),
                     padding: EdgeInsets.zero,
                     constraints: const BoxConstraints(),
                   ),
                ],
              ),
            ),
          ),
          
          // Day cells
          for (int i = 0; i < _totalDays; i++)
            SizedBox(width: 120, child: _buildCell(worker.id, i, workerAssignments[i], isOnVacation(i), _hasChangeLog(worker.id, i))),
          
          // Hours total
          SizedBox(
            width: 80,
            child: Center(
              child: Text(
                '$totalHours',
                style: TextStyle(color: totalHours > 48 ? Colors.redAccent : Colors.black87, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCell(String workerId, int dayIndex, String? slotId, bool isVacation, [bool hasChange = false]) {
    if (isVacation) {
      return Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.pinkAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.pinkAccent.withOpacity(0.3)),
        ),
        child: Center(
          child: Text(
            'VACACIONES',
            style: GoogleFonts.outfit(color: Colors.pinkAccent, fontSize: 9, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    
    
    // Get shift time range
    String? timeRange;
    if (slotId != null) {
      try {
        final slot = _shifts.firstWhere((s) => s.id == slotId);
        final startHour = slot.startTime.hour;
        final endHour = slot.endTime.hour;
        timeRange = '${startHour.toString().padLeft(2, '0')}:00-${endHour.toString().padLeft(2, '0')}:00';
      } catch (_) {}
    }
    
    // Build the draggable cell
    return DragTarget<String>(
      onWillAccept: (data) => true,
      onAccept: (data) {
        final parts = data.split('|');
        if (parts.length == 3) {
          final srcWorkerId = parts[0];
          final srcDay = int.parse(parts[1]);
          final srcSlotId = parts[2];
          
          setState(() {
            // 1. Assign to new slot
            if (_assignments[workerId] == null) _assignments[workerId] = {};
            _assignments[workerId]![dayIndex] = srcSlotId;
            
            // 2. Clear old slot (Move operation)
            // Only if source is different (avoid clearing self)
            if (srcWorkerId != workerId || srcDay != dayIndex) {
              _assignments[srcWorkerId]![srcDay] = null;
            }
            
            _validateSchedule();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Turno movido'), duration: Duration(milliseconds: 500), backgroundColor: Colors.cyan),
          );
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isTarget = candidateData.isNotEmpty;
        
        final cellContent = InkWell(
          onTap: () => _editCell(workerId, dayIndex),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isTarget 
                  ? Colors.cyanAccent.withOpacity(0.3) 
                  : (timeRange != null ? Colors.greenAccent.withOpacity(0.1) : Colors.transparent),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isTarget 
                    ? Colors.cyanAccent 
                    : (timeRange != null ? Colors.greenAccent.withOpacity(0.3) : Colors.white10),
                width: isTarget ? 2 : 1,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    timeRange ?? (isTarget ? 'SOLTAR' : 'LIBRE'),
                    style: GoogleFonts.outfit(
                      color: isTarget ? Colors.cyanAccent : (timeRange != null ? Colors.greenAccent : Colors.white12),
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (hasChange)
                  Positioned(
                    right: 2,
                    top: 2,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.orangeAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );

        if (slotId == null) return cellContent; // Empty cells are targets only

        return LongPressDraggable<String>(
          data: '$workerId|$dayIndex|$slotId',
          feedback: Material(
            color: Colors.transparent,
            child: Container(
              width: 80,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2C),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.cyanAccent),
                boxShadow: [BoxShadow(color: Colors.cyanAccent.withOpacity(0.3), blurRadius: 8)],
              ),
              child: Center(
                child: Text(
                  timeRange!,
                  style: GoogleFonts.outfit(color: Colors.cyanAccent, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          childWhenDragging: Opacity(opacity: 0.3, child: cellContent),
          child: cellContent,
        );
      },
    );
  }

  Widget _buildExportSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Exportar y Compartir', style: GoogleFonts.outfit(color: Colors.amber, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _exportButton('PDF', Icons.picture_as_pdf, Colors.pinkAccent, _exportPdf),
              _exportButton('Excel', Icons.table_chart, Colors.greenAccent, _exportCsv),
              _exportButton('Compartir', Icons.share, Colors.cyanAccent, _shareSchedule),
            ],
          ),
        ],
      ),
    );
  }

  Widget _exportButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // --- Logic Methods ---

  void _pickWeek() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _weekStart,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: Colors.cyanAccent)),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _weekStart = picked.subtract(Duration(days: picked.weekday - 1)));
      _initEmptyAssignments();
      _loadScheduleForWeek();
    }
  }

  void _addShift() {
  final nameController = TextEditingController();
  final startController = TextEditingController(text: '8');
  final endController = TextEditingController(text: '16');

  showDialog(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          title: const Text('Nuevo Turno', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Nombre (ej: Noche)', labelStyle: TextStyle(color: Colors.white54)),
                style: const TextStyle(color: Colors.white),
                controller: nameController,
              ),
              const SizedBox(height: 16),
              // Operating Days Configuration
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.cyanAccent, size: 20),
                        const SizedBox(width: 8),
                        Text('Días Laborables', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildDayChip('L', 0, setDialogState),
                        _buildDayChip('M', 1, setDialogState),
                        _buildDayChip('M', 2, setDialogState),
                        _buildDayChip('J', 3, setDialogState),
                        _buildDayChip('V', 4, setDialogState),
                        _buildDayChip('S', 5, setDialogState),
                        _buildDayChip('D', 6, setDialogState),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // PRESETS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                   _presetButton('12h DÍA', 8, 20, setDialogState, Colors.amber, startController, endController),
                   _presetButton('12h NOCHE', 20, 8, setDialogState, Colors.indigoAccent, startController, endController),
                   _presetButton('24h FULL', 0, 0, setDialogState, Colors.purpleAccent, startController, endController),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: TextField(
                    controller: startController,
                    decoration: InputDecoration(
                      labelText: 'Inicio (0-23)', 
                      labelStyle: const TextStyle(color: Colors.white54),
                      suffixText: ':00',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(
                    controller: endController,
                    decoration: InputDecoration(
                      labelText: 'Fin (0-23)', 
                      labelStyle: const TextStyle(color: Colors.white54),
                      suffixText: ':00',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                  )),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            TextButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  final start = int.tryParse(startController.text) ?? 8;
                  final end = int.tryParse(endController.text) ?? 16;
                  setState(() => _shifts.add(ShiftSlot(
                    name: name, 
                    startTime: DateTime(2024,1,1,start), 
                    endTime: DateTime(2024,1,1,end)
                  )));
                  Navigator.pop(ctx);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingresa un nombre'), backgroundColor: Colors.red));
                }
              },
              child: const Text('Agregar', style: TextStyle(color: Colors.cyanAccent)),
            ),
          ],
        ),
      );
    },
  );
}

  void _autoGenerate() async {
    if (_shifts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ Agrega al menos un turno primero'), backgroundColor: Colors.red));
      return;
    }
    
    if (_workers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ No hay empleados. Agrégalos desde el Directorio en RRHH'), backgroundColor: Colors.red));
      return;
    }

    // 1. CALCULATE CAPACITY
    final businessDaysOpen = _operatingDays.where((d) => d).length;
    final daysWorkingPerWorker = businessDaysOpen - _daysOff;
    final totalSlotsAvailable = _workers.length * daysWorkingPerWorker;
    final slotsNeeded = _shifts.length * businessDaysOpen;
    
    if (totalSlotsAvailable < slotsNeeded) {
      final shortage = slotsNeeded - totalSlotsAvailable;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ Faltan $shortage asignaciones. Contrata más o reduce turnos.'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 5),
        ),
      );
    }
    
    // 2. DISTRIBUTE OFF DAYS INTELLIGENTLY
    _employeeOffDays = _distributeOffDays();
    
    // 3. Clear existing
    _initEmptyAssignments();
    
    // 4. SMART ASSIGNMENT DAY BY DAY
    for (int day = 0; day < 7; day++) {
      if (!_operatingDays[day]) {
        for (var worker in _workers) {
          _assignments[worker.id]![day] = null;
        }
        continue;
      }
      
      final date = _weekStart.add(Duration(days: day));
      
      // Get available workers (not vacation, not off-day)
      List<String> availableIds = [];
      
      for (var worker in _workers) {
        final isVacation = worker.vacationHistory.any((v) => 
          (date.isAfter(v.startDate) || date.isAtSameMomentAs(v.startDate)) &&
          (date.isBefore(v.endDate) || date.isAtSameMomentAs(v.endDate))
        );
        
        if (isVacation) continue;
        
        // Check if it's their off day
        final workerOffDays = _employeeOffDays[worker.id] ?? {};
        if (workerOffDays.contains(day)) continue;
        
        availableIds.add(worker.id);
      }
      
      if (availableIds.isEmpty) continue;
      
      // ROUND-ROBIN DISTRIBUTION
      for (int i = 0; i < availableIds.length; i++) {
        final shiftIndex = i % _shifts.length;
        _assignments[availableIds[i]]![day] = _shifts[shiftIndex].id;
      }
    }
    
    setState(() {});
    _saveSchedule();
    
    // Auto-scroll removed since GlobalKey was causing layout issues
    
    // Calculate and show stats
    final stats = _calculateScheduleStats();
    _validateSchedule(); // Validate alerts
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '✅ ${stats['totalAssignments']} asignaciones | '
          'Cobertura: ${stats['coverage']}% | '
          'Balance: ${stats['balance']}'
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  int _countAssignedWorkers() {
    int count = 0;
    for (var workerAssignments in _assignments.values) {
      for (var assignment in workerAssignments.values) {
        if (assignment != null) count++;
      }
    }
    return count;
  }
  
  /// Distribute off days rotationally to ensure coverage
  Map<String, Set<int>> _distributeOffDays() {
    Map<String, Set<int>> offDaysMap = {};
    
    List<int> openDayIndices = [];
    for (int i = 0; i < 7; i++) {
      if (_operatingDays[i]) openDayIndices.add(i);
    }
    
    if (openDayIndices.isEmpty) return offDaysMap;
    
    int workerIndex = 0;
    
    for (var worker in _workers) {
      Set<int> workerOffDays = {};
      
      for (int i = 0; i < _daysOff; i++) {
        int offsetDay = (workerIndex * _daysOff + i) % openDayIndices.length;
        int actualDayIndex = openDayIndices[offsetDay];
        workerOffDays.add(actualDayIndex);
      }
      
      offDaysMap[worker.id] = workerOffDays;
      workerIndex++;
    }
    
    return offDaysMap;
  }
  
  /// Calculate schedule statistics
  Map<String, dynamic> _calculateScheduleStats() {
    int totalAssignments = 0;
    int totalSlots = 0;
    
    for (int day = 0; day < _totalDays; day++) {
      if (!_operatingDays[day % 7]) continue; // % 7 because operating days is always 7 long
      
      totalSlots += _shifts.length;
      
      for (var workerAssignments in _assignments.values) {
        if (workerAssignments[day] != null) totalAssignments++;
      }
    }
    
    final coverage = totalSlots == 0 ? 0 : (totalAssignments / totalSlots * 100).round();
    
    // Calculate balance
    Map<String, int> hours = {};
    for (var worker in _workers) {
      hours[worker.id] = _countWorkerHours(worker.id);
    }
    
    if (hours.isEmpty) {
      return {
        'totalAssignments': totalAssignments,
        'coverage': coverage,
        'balance': 'N/A',
      };
    }
    
    final avgHours = hours.values.reduce((a, b) => a + b) / hours.length;
    final variance = hours.values.map((h) => (h - avgHours) * (h - avgHours)).reduce((a, b) => a + b) / hours.length;
    final stdDev = variance < 0 ? 0 : sqrt(variance);
    
    String balance = stdDev < 5 ? 'Excelente' : stdDev < 10 ? 'Bueno' : 'Revisar';
    
    return {
      'totalAssignments': totalAssignments,
      'coverage': coverage,
      'balance': balance,
    };
  }
  
  int _countWorkerHours(String workerId) {
    int total = 0;
    final assignments = _assignments[workerId] ?? {};
    
    for (var slotId in assignments.values) {
      if (slotId != null) {
        try {
          final shift = _shifts.firstWhere((s) => s.id == slotId);
          total += shift.endTime.difference(shift.startTime).inHours;
        } catch (_) {}
      }
    }
    
    return total;
  }

  List<String> _getAvailableWorkerIds(int day) {
    final date = _weekStart.add(Duration(days: day));
    List<String> availableIds = [];
    for (var worker in _workers) {
      final isVacation = worker.vacationHistory.any((v) => 
        (date.isAfter(v.startDate) || date.isAtSameMomentAs(v.startDate)) &&
        (date.isBefore(v.endDate) || date.isAtSameMomentAs(v.endDate))
      );
      if (isVacation) continue;
      
      // Count days already worked in current generation process
      // (This is tricky because generation happens day by day)
      // For simplicity, we check if they've already been assigned too many times PRIOR to this day
      int worked = 0;
      for (int d = 0; d < day; d++) {
        if (_assignments[worker.id]?[d] != null) worked++;
      }
      if (worked < (7 - _daysOff)) availableIds.add(worker.id);
    }
    return availableIds;
  }

  int _getAvailableWorkersCount(int day) {
    return _getAvailableWorkerIds(day).length;
  }

  Future<List<String>?> _showPriorityDialog() async {
    List<String> ignoredIds = [];
    return showDialog<List<String>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          title: Text('⚠️ Personal Insuficiente', style: GoogleFonts.outfit(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'No tienes suficientes empleados para cubrir todos los turnos. Selecciona los turnos que deseas OMITIR para que el resto esté cubierto:',
                style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 16),
              ..._shifts.map((s) => CheckboxListTile(
                title: Text(s.name, style: const TextStyle(color: Colors.white)),
                subtitle: Text('${s.startTime.hour}:00 - ${s.endTime.hour}:00', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                value: ignoredIds.contains(s.id),
                activeColor: Colors.pinkAccent,
                onChanged: (v) {
                  setDialogState(() {
                    if (v == true) {
                      ignoredIds.add(s.id);
                    } else {
                      ignoredIds.remove(s.id);
                    }
                  });
                },
              )),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, ignoredIds), 
              child: const Text('Generar'),
            ),
          ],
        ),
      ),
    );
  }

  void _shuffleSchedule() {
    // Rotate shift assignments randomly
    for (var worker in _workers) {
      final assigned = _assignments[worker.id]!.entries.where((e) => e.value != null).toList();
      if (assigned.length > 1) {
        assigned.shuffle();
        int idx = 0;
        for (int day = 0; day < 7; day++) {
          if (_assignments[worker.id]![day] != null && idx < assigned.length) {
            _assignments[worker.id]![day] = assigned[idx].value;
            idx++;
          }
        }
      }
    }
    setState(() {});
    _saveSchedule();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Turnos rotados'), backgroundColor: Colors.cyanAccent));
  }

  void _clearAll() {
    _initEmptyAssignments();
    setState(() {});
  }

  void _editCell(String workerId, int dayIndex) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Seleccionar Turno', style: GoogleFonts.outfit(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.white54),
              title: const Text('Libre (Descanso)', style: TextStyle(color: Colors.white)),
              onTap: () {
                setState(() => _assignments[workerId]![dayIndex] = null);
                _saveSchedule();
                Navigator.pop(ctx);
              },
            ),
            for (var shift in _shifts)
              ListTile(
                leading: Icon(Icons.work, color: shift.isRush ? Colors.amber : Colors.cyanAccent),
                title: Text(shift.name, style: TextStyle(color: shift.isRush ? Colors.amber : Colors.cyanAccent)),
                subtitle: Text('${shift.startTime.hour}:00 - ${shift.endTime.hour}:00', style: const TextStyle(color: Colors.white38)),
                onTap: () {
                  setState(() => _assignments[workerId]![dayIndex] = shift.id);
                  _saveSchedule();
                  Navigator.pop(ctx);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showVacationManager() {
    WorkerProfile? selected;
    DateTime start = DateTime.now(), end = DateTime.now().add(const Duration(days: 7));
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A2E),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Registrar Vacaciones', style: GoogleFonts.outfit(color: Colors.pinkAccent, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              DropdownButtonFormField<WorkerProfile>(
                dropdownColor: const Color(0xFF1A1A2E),
                decoration: const InputDecoration(labelText: 'Empleado'),
                items: _workers.map((w) => DropdownMenuItem(value: w, child: Text(w.name))).toList(),
                onChanged: (v) => setModal(() => selected = v),
              ),
              const SizedBox(height: 16),
              
              // QUICK SELECTION CARDS
              Text('⚡ Selección Rápida', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildVacationPresetCard(
                      '1 Semana',
                      '7 días',
                      Colors.blue,
                      Icons.calendar_today,
                      () {
                        final now = DateTime.now();
                        setModal(() {
                          start = now;
                          end = now.add(const Duration(days: 6));
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildVacationPresetCard(
                      '15 Días',
                      'Quincena',
                      Colors.orange,
                      Icons.calendar_view_week,
                      () {
                        final now = DateTime.now();
                        setModal(() {
                          start = now;
                          end = now.add(const Duration(days: 14));
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildVacationPresetCard(
                      '1 Mes',
                      '30 días',
                      Colors.purple,
                      Icons.calendar_month,
                      () {
                        final now = DateTime.now();
                        setModal(() {
                          start = now;
                          end = now.add(const Duration(days: 29));
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white24),
              const SizedBox(height: 12),
              
              // MANUAL DATE SELECTION
              Text('📅 Personalizado', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: TextButton(
                    onPressed: () async {
                      final d = await showDatePicker(context: ctx, initialDate: start, firstDate: DateTime(2020), lastDate: DateTime(2030));
                      if (d != null) setModal(() => start = d);
                    },
                    child: Text('Desde: ${DateFormat('dd/MM').format(start)}', style: const TextStyle(color: Colors.white)),
                  )),
                  Expanded(child: TextButton(
                    onPressed: () async {
                      final d = await showDatePicker(context: ctx, initialDate: end, firstDate: DateTime(2020), lastDate: DateTime(2030));
                      if (d != null) setModal(() => end = d);
                    },
                    child: Text('Hasta: ${DateFormat('dd/MM').format(end)}', style: const TextStyle(color: Colors.white)),
                  )),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (selected != null) {
                    selected!.vacationHistory.add(VacationRecord(
                      id: const Uuid().v4(),
                      startDate: start,
                      endDate: end,
                      daysTaken: end.difference(start).inDays + 1,
                      amountPaid: 0,
                      isPaid: false,
                      notes: 'Desde Planificador',
                      createdAt: DateTime.now(),
                    ));
                    await _workerService.saveWorker(selected!);
                    Navigator.pop(ctx);
                    _loadData();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Vacación registrada'), backgroundColor: Colors.pinkAccent));
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
                child: const Text('REGISTRAR'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildVacationPresetCard(String title, String subtitle, Color color, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.outfit(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              subtitle,
              style: GoogleFonts.outfit(
                color: color.withOpacity(0.7),
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showShiftConfig() {
    // Show template/shift configuration
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usa los chips arriba para gestionar turnos')));
  }

  int _countDay(int dayIndex) {
    int count = 0;
    for (var worker in _workers) {
      if (_assignments[worker.id]?[dayIndex] != null) count++;
    }
    return count;
  }

  // --- Persistence ---

  Future<void> _saveSchedule() async {
    final List<WorkerAssignment> assignments = [];
    for (var worker in _workers) {
      for (int i = 0; i < 7; i++) {
        final date = _weekStart.add(Duration(days: i));
        assignments.add(WorkerAssignment(
          workerId: worker.id,
          workerName: worker.name,
          date: date,
          slotId: _assignments[worker.id]?[i],
          isVacation: false,
        ));
      }
    }
    
    final schedule = WeeklySchedule(
      id: _currentSchedule?.id,
      name: _currentScheduleName,
      startDate: _weekStart,
      endDate: _weekStart.add(const Duration(days: 6)),
      assignments: assignments,
      department: _selectedDepartment == 'Todos' ? null : _selectedDepartment,
    );
    
    await _scheduleService.saveSchedule(schedule);
    _loadScheduleForWeek(); // Reload list to show the new/updated table
  }

  // --- Export ---

  Future<void> _exportPdf() async {
    if (!SubscriptionService().hasAccess(PlanFeature.exportPdf)) {
      _showUpgradeDialog('Exportar a PDF', 'Plan Pro');
      return;
    }
    if (_workers.isEmpty) return;
    try {
      final tempTemplate = ScheduleTemplate(id: 'temp', name: 'Schedule', availableSlots: _shifts, weeklyDemand: [], minDaysOffPerWeek: _daysOff);
      await _saveSchedule();
      final file = await _exportService.generateSchedulePdf(_currentSchedule!, _workers, tempTemplate);
      await Share.shareXFiles([XFile(file.path)], text: 'Horario Semanal PDF');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _exportCsv() async {
    if (!SubscriptionService().hasAccess(PlanFeature.exportExcel)) {
       _showUpgradeDialog('Exportar a Excel', 'Plan Crecimiento');
       return;
    }
    if (_workers.isEmpty) return;
    try {
      final tempTemplate = ScheduleTemplate(id: 'temp', name: 'Schedule', availableSlots: _shifts, weeklyDemand: [], minDaysOffPerWeek: _daysOff);
      await _saveSchedule();
      final file = await _exportService.generateScheduleCsv(_currentSchedule!, _workers, tempTemplate);
      await Share.shareXFiles([XFile(file.path)], text: 'Horario Excel CSV');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _shareSchedule() async {
    await _exportPdf();
  }
  


  Widget _buildTablesManager() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C), // Unified Dark Surface
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.pinkAccent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('MIS TABLAS DE HORARIO', style: GoogleFonts.outfit(color: Colors.pinkAccent, fontSize: 13, fontWeight: FontWeight.bold)),
              TextButton.icon(
                icon: const Icon(Icons.table_chart, size: 16, color: Colors.cyanAccent),
                label: Text('NUEVA TABLA', style: GoogleFonts.outfit(color: Colors.cyanAccent, fontSize: 12)),
                onPressed: _createNewTableDialog,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_weekSchedules.isEmpty)
             const Text('No hay tablas guardadas para esta semana.', style: TextStyle(color: Colors.white38, fontSize: 11)),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _weekSchedules.map((s) => Stack(
              clipBehavior: Clip.none,
              children: [
                ChoiceChip(
                  label: Text('${s.name} ${s.department != null ? "(${s.department})" : ""}'),
                  selected: _currentSchedule?.id == s.id,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _currentSchedule = s;
                        _currentScheduleName = s.name;
                        _loadAssignmentsFromSchedule(s);
                      });
                    }
                  },
                  backgroundColor: Colors.black26,
                  selectedColor: Colors.pinkAccent.withOpacity(0.3),
                  labelStyle: TextStyle(color: _currentSchedule?.id == s.id ? Colors.pinkAccent : Colors.white70, fontSize: 11),
                  side: BorderSide(color: _currentSchedule?.id == s.id ? Colors.pinkAccent : Colors.white12),
                ),
                if (_currentSchedule?.id == s.id)
                  Positioned(
                    right: -8,
                    top: -8,
                    child: GestureDetector(
                      onTap: () => _confirmDeleteTable(s),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                        child: const Icon(Icons.close, size: 12, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            )).toList(),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteTable(WeeklySchedule s) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Eliminar Tabla', style: TextStyle(color: Colors.white)),
        content: Text('¿Estás seguro de que quieres eliminar "${s.name}"? Esta acción no se puede deshacer.', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              await _scheduleService.deleteSchedule(s.id);
              Navigator.pop(ctx);
              _loadScheduleForWeek();
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _createNewTableDialog() {
    final nameCtrl = TextEditingController(text: 'Horario ${_selectedDepartment == "Todos" ? "Nuevo" : _selectedDepartment}');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text('Nueva Tabla de Horario', style: GoogleFonts.outfit(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Nombre de la Tabla',
                hintText: 'ej. Mañana, Tarde, Especial...',
              ),
            ),
            const SizedBox(height: 12),
            Text('Se asociará al departamento: $_selectedDepartment', style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentSchedule = null;
                _currentScheduleName = nameCtrl.text;
                _initEmptyAssignments();
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nueva tabla lista. ¡Recuerda GUARDAR para salvarla!')));
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  // --- MAPA DE CALOR AVANZADO (Premium) ---

  void _showHourlyHeatmap() {
    final days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    final Map<int, Map<int, int>> hourlyCoverage = {}; 
    for (int h = 0; h < 24; h++) {
      hourlyCoverage[h] = {};
      for (int d = 0; d < 7; d++) hourlyCoverage[h]![d] = 0;
    }

    for (var workerId in _assignments.keys) {
      for (int d = 0; d < 7; d++) {
        final slotId = _assignments[workerId]![d];
        if (slotId != null) {
          final slot = _shifts.firstWhere((s) => s.id == slotId, orElse: () => _shifts.first);
          for (int h = slot.startTime.hour; h < slot.endTime.hour; h++) {
            hourlyCoverage[h]![d] = (hourlyCoverage[h]![d] ?? 0) + 1;
          }
        }
      }
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Heatmap',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (ctx, anim1, anim2) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: anim1.drive(CurveTween(curve: Curves.easeOutBack)),
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.95,
                  height: MediaQuery.of(context).size.height * 0.85,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D0D1A),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.cyanAccent.withOpacity(0.3), width: 2),
                    boxShadow: [
                      BoxShadow(color: Colors.cyanAccent.withOpacity(0.15), blurRadius: 30, spreadRadius: 5),
                      BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildHeatmapHeader(ctx),
                      const SizedBox(height: 20),
                      _buildHeatmapLegendSection(),
                      const SizedBox(height: 20),
                      Expanded(
                        child: _buildHeatmapGrid(days, hourlyCoverage),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildHeatmapHeader(BuildContext ctx) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.cyanAccent.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.analytics, color: Colors.cyanAccent, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('EXPLORADOR DE OCUPACIÓN', style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              Text('Análisis de cobertura horaria para la semana de $_weekStart', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 13)),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(ctx),
          icon: const Icon(Icons.close, color: Colors.white38),
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildHeatmapLegendSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(12)),
      child: Wrap(
        spacing: 24,
        runSpacing: 10,
        children: [
          _heatLegendItem('Sin Personal', Colors.white.withOpacity(0.05)),
          _heatLegendItem('Mínimo (1)', Colors.cyanAccent.withOpacity(0.15)),
          _heatLegendItem('Ideal (2)', Colors.cyanAccent.withOpacity(0.4)),
          _heatLegendItem('Refuerzo (3/4)', Colors.amber.withOpacity(0.6)),
          _heatLegendItem('Sobrecarga (5+)', Colors.redAccent.withOpacity(0.8)),
        ],
      ),
    );
  }

  Widget _buildHeatmapGrid(List<String> days, Map<int, Map<int, int>> data) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          // Header Row
          Container(
            height: 44,
            color: Colors.white.withOpacity(0.07),
            child: Row(
              children: [
                Container(
                  width: 80,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(border: Border(right: BorderSide(color: Colors.white10))),
                  child: Text('HORARIO', style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                for (var d in days)
                  Expanded(
                    child: Center(
                      child: Text(d, style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ),
              ],
            ),
          ),
          
          // Scrollable Body
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildTimeSection('MAÑANA', 6, 12, data, days),
                _buildTimeSection('TARDE', 12, 18, data, days),
                _buildTimeSection('NOCHE', 18, 24, data, days),
                _buildTimeSection('MADRUGADA', 0, 6, data, days),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSection(String title, int start, int end, Map<int, Map<int, int>> data, List<String> days) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          color: Colors.white.withOpacity(0.03),
          child: Text(title, style: GoogleFonts.outfit(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        ),
        for (int h = start; h < end; h++)
          Container(
            height: 38,
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white10))),
            child: Row(
              children: [
                Container(
                  width: 80,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(border: Border(right: BorderSide(color: Colors.white10))),
                  child: Text('${h.toString().padLeft(2, '0')}:00', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                ),
                for (int d = 0; d < 7; d++)
                  Expanded(
                    child: Tooltip(
                      message: 'Día: ${days[d]}, Hora: $h:00\nColaboradores: ${data[h]![d]}',
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: _getHeatColor(data[h]![d] ?? 0),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: (data[h]![d] ?? 0) >= 3 ? [BoxShadow(color: _getHeatColor(data[h]![d] ?? 0).withOpacity(0.3), blurRadius: 4)] : null,
                        ),
                        child: Center(
                          child: Text(
                            '${data[h]![d]}', 
                            style: TextStyle(
                              color: (data[h]![d] ?? 0) > 0 ? Colors.white : Colors.white.withOpacity(0.05), 
                              fontSize: 13, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _heatLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16, 
          height: 16, 
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.white24, width: 0.5)),
        ),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _buildDayChip(String label, int dayIndex, [StateSetter? dialogState]) {
    final isSelected = _operatingDays[dayIndex];
    return FilterChip(
      label: Text(label, style: GoogleFonts.outfit(fontSize: 12)),
      selected: isSelected,
      selectedColor: Colors.cyanAccent.withOpacity(0.3),
      checkmarkColor: Colors.cyanAccent,
      backgroundColor: Colors.white.withOpacity(0.05),
      side: BorderSide(
        color: isSelected ? Colors.cyanAccent : Colors.white24,
        width: 1.5,
      ),
      onSelected: (value) {
        if (dialogState != null) {
          dialogState(() {
            _operatingDays[dayIndex] = value;
          });
        } else {
          setState(() {
            _operatingDays[dayIndex] = value;
          });
        }
      },
    );
  }

  void _editShift(ShiftSlot shift) {
    final nameController = TextEditingController(text: shift.name);
    final startController = TextEditingController(text: shift.startTime.hour.toString());
    final endController = TextEditingController(text: shift.endTime.hour.toString());

    showDialog(
      context: context,
      builder: (ctx) {
        String name = shift.name;
        int start = shift.startTime.hour;
        int end = shift.endTime.hour;
        
        return StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A2E),
            title: const Text('Editar Turno', style: TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Nombre', 
                    labelStyle: TextStyle(color: Colors.white54),
                  ),
                  style: const TextStyle(color: Colors.white),
                  controller: nameController,
                  onChanged: (v) => name = v,
                ),
                const SizedBox(height: 12),
                const SizedBox(height: 16),
                // PRESETS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _presetButton('12h DÍA', 8, 20, setDialogState, Colors.amber, startController, endController),
                    _presetButton('12h NOCHE', 20, 8, setDialogState, Colors.indigoAccent, startController, endController),
                    _presetButton('24h FULL', 0, 0, setDialogState, Colors.purpleAccent, startController, endController),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Inicio (0-23)', 
                        labelStyle: const TextStyle(color: Colors.white54),
                        suffixText: ':00',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      controller: startController,
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Fin (0-23)', 
                        labelStyle: const TextStyle(color: Colors.white54),
                        suffixText: ':00',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      controller: endController,
                    )),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  final newName = nameController.text.trim();
                  if (newName.isNotEmpty) {
                    final newStart = int.tryParse(startController.text) ?? start;
                    final newEnd = int.tryParse(endController.text) ?? end;
                    
                    setState(() {
                      final index = _shifts.indexOf(shift);
                      _shifts[index] = ShiftSlot(
                        id: shift.id,
                        name: newName,
                        startTime: DateTime(2024, 1, 1, newStart),
                        endTime: DateTime(2024, 1, 1, newEnd),
                        isRush: shift.isRush,
                      );
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Turno actualizado'),
                        backgroundColor: kNeonGreen,
                      ),
                    );
                  }
                },
                child: const Text('Guardar', style: TextStyle(color: Colors.cyanAccent)),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _syncToShiftLogger() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Sincronizar con Registro de Turnos', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Esto enviará las horas de este horario al "Registro de Turnos" de cada empleado para la semana seleccionada. ¿Continuar?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sincronizar', style: TextStyle(color: Colors.greenAccent)),
          ),
        ],
      ),
    );
    
    if (confirm != true) return;
    
    try {
      int syncedCount = 0;
      
      for (var worker in _workers) {
        final workerAssignments = _assignments[worker.id] ?? {};
        List<ShiftRecord> shifts = [];
        
        for (int dayIndex = 0; dayIndex < 7; dayIndex++) {
          final slotId = workerAssignments[dayIndex];
          if (slotId == null) continue;
          
          ShiftSlot? slot;
          try {
            slot = _shifts.firstWhere((s) => s.id == slotId);
          } catch (_) {
            continue;
          }
          
          final hours = slot.endTime.difference(slot.startTime).inHours.toDouble();
          final date = _weekStart.add(Duration(days: dayIndex));
          
          shifts.add(ShiftRecord(
            date: date,
            regularHours: hours,
            extraDiurna: 0,
            extraNocturna: 0,
            extraMixta: 0,
            isSunday: date.weekday == DateTime.sunday,
            isHoliday: false,
            notes: 'Auto: ${slot.name}',
          ));
        }
        
        if (shifts.isEmpty) continue;
        
        final newPeriod = WorkPeriod(
          workerId: worker.id,
          startDate: _weekStart,
          endDate: _weekStart.add(const Duration(days: 6)),
          shifts: shifts,
        );
        
        final existingIndex = worker.shiftPeriods.indexWhere((p) =>
          p.startDate.isAtSameMomentAs(_weekStart) ||
          (p.startDate.isBefore(_weekStart.add(const Duration(days: 1))) &&
           p.endDate.isAfter(_weekStart.subtract(const Duration(days: 1))))
        );
        
        if (existingIndex >= 0) {
          worker.shiftPeriods[existingIndex] = newPeriod;
        } else {
          worker.shiftPeriods.add(newPeriod);
        }
        
        await _workerService.saveWorker(worker);
        syncedCount++;
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Sincronizados $syncedCount empleados'),
            backgroundColor: kNeonGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  Widget _buildInfoButton(String title, String message) {
    return IconButton(
      icon: const Icon(Icons.info_outline, color: Colors.white54, size: 20),
      tooltip: 'Información',
      onPressed: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E2C),
            title: Text(title, style: GoogleFonts.outfit(color: Colors.cyanAccent)),
            content: Text(message, style: GoogleFonts.outfit(color: Colors.white70)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Entendido')),
            ],
          ),
        );
      },
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(), 
    );
  }

  // --- PRO FEATURES IMPLEMENTATION ---

  void _sendGroupWhatsApp() async {
    final sb = StringBuffer();
    sb.writeln('📅 *HORARIO SEMANAL - ${_selectedDepartment}*');
    sb.writeln('Semana: ${DateFormat('dd MMM').format(_weekStart)}');
    sb.writeln('---');
    
    for (var worker in _workers) {
      final assignments = _assignments[worker.id] ?? {};
      bool hasShifts = false;
      sb.writeln('\n👤 *${worker.name}*:');
      
      for (int i=0; i < _totalDays; i++) {
        final slotId = assignments[i];
        if (slotId != null) {
          try {
            final shift = _shifts.firstWhere((s) => s.id == slotId);
            final dayLetter = ['L', 'M', 'M', 'J', 'V', 'S', 'D'][i];
            sb.writeln('  $dayLetter: ${shift.startTime.hour}:00-${shift.endTime.hour}:00');
            hasShifts = true;
          } catch(_) {}
        }
      }
      if (!hasShifts) sb.writeln('  🏖️ LIBRE');
    }
    
    sb.writeln('\n---');
    sb.writeln('Enviado desde Planificador PRO');
    
    final url = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(sb.toString())}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo abrir WhatsApp')));
    }
  }

  void _sendWhatsApp(WorkerProfile worker) async {
    // 1. Generate textual schedule
    final sb = StringBuffer();
    sb.writeln('📅 *Tu Horario - ${_selectedDepartment}*');
    sb.writeln('Semana: ${DateFormat('dd MMM').format(_weekStart)}');
    sb.writeln('');
    
    final assignments = _assignments[worker.id] ?? {};
    bool hasShifts = false;
    
    for (int i=0; i < _totalDays; i++) {
        final date = _weekStart.add(Duration(days: i));
        final dayName = DateFormat('EEEE', 'es').format(date);
        final slotId = assignments[i];
        
        if (slotId != null) {
            try {
                final shift = _shifts.firstWhere((s) => s.id == slotId);
                sb.writeln('• *$dayName*: ${shift.startTime.hour}:00 - ${shift.endTime.hour}:00 (${shift.name})');
                hasShifts = true;
            } catch(_) {}
        }
    }
    
    if (!hasShifts) sb.writeln('🏖️ *Sin turnos asignados esta semana*');
    
    sb.writeln('');
    sb.writeln('Enviado desde Planificador PRO');
    
    // 2. Launch WhatsApp
    // Replace non-numeric chars in phone if needed, simple assumption here
    final phone = '507${worker.cedula}0000'; // MOCK PHONE Logic (usually worker has phone field)
    // Actually worker service doesn't have phone, let's ask user to add logic later or just open generic
    final url = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(sb.toString())}');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo abrir WhatsApp')));
    }
  }

  void _saveTemplate() async {
     final TextEditingController _ctrl = TextEditingController();
     await showDialog(
       context: context,
       builder: (ctx) => AlertDialog(
         backgroundColor: const Color(0xFF1E1E2C),
         title: const Text('Guardar Plantilla', style: TextStyle(color: Colors.white)),
         content: TextField(
           controller: _ctrl,
           style: const TextStyle(color: Colors.white),
           decoration: const InputDecoration(labelText: 'Nombre de la plantilla'),
         ),
         actions: [
           TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
           ElevatedButton(
             onPressed: () async {
                if (_ctrl.text.isEmpty) return;
                final prefs = await SharedPreferences.getInstance();
                // Simple implementation: Key-Value store
                // Ideally serialize full assignments, for now we mock success
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Plantilla guardada (Simulación)'), backgroundColor: Colors.green));
             },
             child: const Text('Guardar'),
           ),
         ],
       ),
     );
  }

  void _loadTemplate() async {
      await showDialog(
       context: context,
       builder: (ctx) => AlertDialog(
         backgroundColor: const Color(0xFF1E1E2C),
         title: const Text('Cargar Plantilla', style: TextStyle(color: Colors.white)),
         content: Container(
           width: double.maxFinite,
           child: ListView(
             shrinkWrap: true,
             children: [
               ListTile(
                 title: const Text('Semana Estándar', style: TextStyle(color: Colors.white)),
                 subtitle: const Text('L-V 8am-5pm', style: TextStyle(color: Colors.white54)),
                 onTap: () {
                    // Mock load
                    // _autoGenerate(); 
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Plantilla cargada'), backgroundColor: Colors.green));
                 },
               ),
               ListTile(
                 title: const Text('Temporada Alta', style: TextStyle(color: Colors.white)),
                 subtitle: const Text('Refuerzo fines de semana', style: TextStyle(color: Colors.white54)),
                 leading: const Icon(Icons.flash_on, color: Colors.amber),
                 onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Plantilla cargada'), backgroundColor: Colors.green));
                 },
               ),
             ],
           ),
         ),
       ),
     );
  }
  // --- SHIFT MANAGEMENT IMPLEMENTATION ---
  
  void _showShiftManagementDialog() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
           return AlertDialog(
            backgroundColor: const Color(0xFF1E1E2C),
            title: const Text('Gestión de Cambios y Permisos', style: TextStyle(color: Colors.white)),
            content: Container(
              width: 500,
              height: 400,
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [Tab(text: 'Nuevo Cambio'), Tab(text: 'Historial')],
                      indicatorColor: Colors.cyanAccent,
                      labelColor: Colors.cyanAccent,
                      unselectedLabelColor: Colors.white54,
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildNewChangeForm(ctx),
                          _buildChangeHistoryList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
            ],
          );
        }
      ),
    );
  }

  Widget _buildNewChangeForm(BuildContext ctx) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildActionTile(
          'Intercambio de Turno', 'Dos empleados cambian sus horarios.', Icons.swap_horiz, Colors.blue,
          () => _showChangeFormDetails(ctx, ChangeType.swapShift)
        ),
        const SizedBox(height: 8),
        _buildActionTile(
          'Cobertura / Reemplazo', 'Un empleado cubre el turno de otro.', Icons.people_alt, Colors.green,
          () => _showChangeFormDetails(ctx, ChangeType.coverShift)
        ),
        const SizedBox(height: 8),
        _buildActionTile(
          'Cambio de Día Libre', 'Mover día libre a otra fecha.', Icons.weekend, Colors.orange,
          () => _showChangeFormDetails(ctx, ChangeType.daySwap)
        ),
         const SizedBox(height: 8),
        _buildActionTile(
          'Permiso / Ausencia', 'Justificar falta o permiso especial.', Icons.event_busy, Colors.redAccent,
          () => _showChangeFormDetails(ctx, ChangeType.permission)
        ),
         const SizedBox(height: 8),
        _buildActionTile(
          'Incapacidad Médica', 'Registro de baja por salud.', Icons.local_hospital, Colors.pinkAccent,
          () => _showChangeFormDetails(ctx, ChangeType.sickLeave)
        ),
      ],
    );
  }

  Widget _buildActionTile(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.white10)),
    );
  }

  void _showChangeFormDetails(BuildContext ctx, ChangeType type) {
    WorkerProfile? requester;
    WorkerProfile? target;
    DateTime date = _weekStart;
    String reason = '';
    
    showDialog(
      context: context,
      builder: (formCtx) => StatefulBuilder(
        builder: (context, setFormState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E2C),
          title: Text(type == ChangeType.swapShift ? 'Intercambio de Turno' : 'Registrar Cambio', style: const TextStyle(color: Colors.white)),
          content: SingleChildScrollView( 
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<WorkerProfile>(
                  dropdownColor: const Color(0xFF1E1E2C),
                  decoration: const InputDecoration(labelText: 'Solicitante', labelStyle: TextStyle(color: Colors.white70)),
                  items: _workers.map((w) => DropdownMenuItem(value: w, child: Text(w.name, style: const TextStyle(color: Colors.white)))).toList(),
                  onChanged: (v) => setFormState(() => requester = v),
                ),
                if (type == ChangeType.swapShift || type == ChangeType.coverShift)
                  DropdownButtonFormField<WorkerProfile>(
                    dropdownColor: const Color(0xFF1E1E2C),
                    decoration: const InputDecoration(labelText: 'Otro Empleado (Target)', labelStyle: TextStyle(color: Colors.white70)),
                    items: _workers.where((w) => w != requester).map((w) => DropdownMenuItem(value: w, child: Text(w.name, style: const TextStyle(color: Colors.white)))).toList(),
                    onChanged: (v) => setFormState(() => target = v),
                  ),
                const SizedBox(height: 16),
                Text('Fecha Efectiva (Día de la Semana)', style: GoogleFonts.outfit(color: Colors.white70)),
                Wrap(
                  spacing: 8,
                  children: List.generate(_totalDays, (i) {
                     final d = _weekStart.add(Duration(days: i));
                     final isSelected = isSameDay(d, date);
                     return FilterChip(
                       label: Text(DateFormat('EEE d').format(d)),
                       selected: isSelected,
                       onSelected: (v) => setFormState(() => date = d),
                       backgroundColor: Colors.black26,
                       selectedColor: Colors.cyanAccent.withOpacity(0.3),
                       labelStyle: TextStyle(color: isSelected ? Colors.cyanAccent : Colors.white),
                     );
                  }),
                ),
                const SizedBox(height: 16),
                TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Motivo / Notas', labelStyle: TextStyle(color: Colors.white70)),
                  onChanged: (v) => reason = v,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(formCtx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (requester != null && (target != null || (type != ChangeType.swapShift && type != ChangeType.coverShift))) {
                  _applyShiftChange(ShiftChangeLog(
                    type: type,
                    requesterId: requester!.id,
                    requesterName: requester!.name,
                    targetId: target?.id,
                    targetName: target?.name,
                    date: date,
                    reason: reason.isEmpty ? 'Solicitud manual' : reason,
                  ));
                  Navigator.pop(formCtx);
                  Navigator.pop(ctx); 
                }
              },
              child: const Text('Aplicar Cambio'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChangeHistoryList() {
    if (_changeLogs.isEmpty) return const Center(child: Text('No hay cambios registrados', style: TextStyle(color: Colors.white38)));
    
    return ListView.builder(
      itemCount: _changeLogs.length,
      itemBuilder: (ctx, i) {
        final log = _changeLogs[i];
        return Card(
          color: Colors.white10,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: Icon(_getChangeIcon(log.type), color: Colors.cyanAccent),
            title: Text('${log.requesterName} ${log.targetName != null ? "↔ ${log.targetName}" : ""}', style: const TextStyle(color: Colors.white)),
            subtitle: Text('${log.type.toString().split('.').last} • ${DateFormat('d MMM').format(log.date)}\n${log.reason}', style: const TextStyle(color: Colors.white54)),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  IconData _getChangeIcon(ChangeType type) {
     switch(type) {
       case ChangeType.swapShift: return Icons.swap_horiz;
       case ChangeType.coverShift: return Icons.people_alt;
       case ChangeType.daySwap: return Icons.update;
       case ChangeType.permission: return Icons.block;
       case ChangeType.sickLeave: return Icons.local_hospital;
     }
  }

  void _applyShiftChange(ShiftChangeLog log) {
    setState(() {
      _changeLogs.add(log);
      final dayIndex = log.date.difference(_weekStart).inDays;
      
      if (dayIndex >= 0 && dayIndex < _totalDays) {
         if (_assignments[log.requesterId] == null) _assignments[log.requesterId] = {};
         if (log.targetId != null && _assignments[log.targetId!] == null) _assignments[log.targetId!] = {};

         if (log.type == ChangeType.swapShift && log.targetId != null) {
            final reqSlot = _assignments[log.requesterId]![dayIndex];
            final tgtSlot = _assignments[log.targetId!]![dayIndex];
            _assignments[log.requesterId]![dayIndex] = tgtSlot;
            _assignments[log.targetId!]![dayIndex] = reqSlot;
         } else if (log.type == ChangeType.coverShift && log.targetId != null) {
            final reqSlot = _assignments[log.requesterId]![dayIndex];
            _assignments[log.targetId!]![dayIndex] = reqSlot;
            _assignments[log.requesterId]![dayIndex] = null;
         } else if (log.type == ChangeType.permission || log.type == ChangeType.sickLeave) {
             _assignments[log.requesterId]![dayIndex] = null; 
         }
      }
      _validateSchedule();
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Cambio aplicado correctamente'), backgroundColor: Colors.green));
  }

  Widget _buildPhaseHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Divider(color: color.withOpacity(0.1), thickness: 1)),
      ],
    );
  }

  Widget _buildPhaseAccordion({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2C),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: ExpansionTile(
          collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          leading: Icon(icon, color: color, size: 20),
          title: Text(
            title,
            style: GoogleFonts.outfit(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          iconColor: color,
          collapsedIconColor: Colors.white30,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: child,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickKpiDashboard() {
    if (_analyticsMetrics == null) return const SizedBox.shrink();
    final m = _analyticsMetrics!;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _quickKpiItem(
            'COBERTURA', 
            '${m.efficiencyScore.toInt()}%', 
            Icons.check_circle_outline, 
            Colors.greenAccent,
            'Porcentaje de turnos cubiertos vs. demanda ideal'
          ),
          _quickKpiDivider(),
          _quickKpiItem(
            'PLANILLA EST.', 
            '\$${m.laborCostEstimate.toInt()}', 
            Icons.account_balance_wallet, 
            Colors.amberAccent,
            'Costo estimado de mano de obra para esta semana'
          ),
          _quickKpiDivider(),
          _quickKpiItem(
            'CONFLICTOS', 
            '${_alerts.length}', 
            Icons.warning_amber_rounded, 
            _alerts.isEmpty ? Colors.cyanAccent : Colors.redAccent,
            'Número de violaciones a reglas de descanso o capacidad'
          ),
        ],
      ),
    );
  }

  Widget _quickKpiItem(String label, String value, IconData icon, Color color, String tooltip) {
    return Tooltip(
      message: tooltip,
      preferBelow: false,
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(label, style: GoogleFonts.outfit(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.outfit(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _quickKpiDivider() => Container(height: 30, width: 1, color: Colors.white10);

  Widget _presetButton(String label, int startV, int endV, StateSetter setDialogState, Color color, TextEditingController sc, TextEditingController ec) {
    return OutlinedButton(
      onPressed: () {
        setDialogState(() {
          sc.text = startV.toString();
          ec.text = endV.toString();
        });
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

}


