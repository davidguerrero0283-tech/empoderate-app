import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../components/neon_widgets.dart';
import '../../components/premium_scaffold.dart';
import '../../calculators/salario_models.dart';
import '../../calculators/shift_models.dart';
import '../../services/worker_service.dart';
import 'salario_screen.dart';

/// ============================================================================
/// REGISTRO DE TURNOS - Pantalla para registrar horas trabajadas día por día
/// ============================================================================
/// 
/// FLUJO DE USO:
/// 1. Desde el Directorio de Empleados → Detalle del trabajador → "Registrar Turnos"
/// 2. Seleccionar el periodo (quincena)
/// 3. Llenar las horas de cada día
/// 4. Guardar → Los datos se almacenan en worker.shiftPeriods
/// 5. Ir a Calcular Salario → Las horas extra se convierten en pagos
/// ============================================================================

class ShiftLoggerScreen extends StatefulWidget {
  final WorkerProfile? worker;
  final String? workerId; // NEW: For deep link support
  final WorkPeriod? existingPeriod;

  const ShiftLoggerScreen({
    Key? key,
    this.worker,
    this.workerId,
    this.existingPeriod,
  }) : super(key: key);

  @override
  _ShiftLoggerScreenState createState() => _ShiftLoggerScreenState();
}

class _ShiftLoggerScreenState extends State<ShiftLoggerScreen> {
  late DateTime _startDate;
  late DateTime _endDate;
  List<ShiftRecord> _shifts = [];
  bool _isLoading = false;
  bool _showHelp = true;
  bool _isLoadingWorker = false;
  bool _workerNotFound = false; // NEW: Track if workerId was given but not found
  WorkerProfile? _loadedWorker;

  @override
  void initState() {
    super.initState();
    _loadedWorker = widget.worker;
    
    // DEBUG: Log workerId received
    debugPrint('🔍 ShiftLoggerScreen initState - workerId: ${widget.workerId}, worker: ${widget.worker?.name}');
    
    // Deep link support: load worker by ID if needed
    if (_loadedWorker == null && widget.workerId != null && widget.workerId!.isNotEmpty) {
      debugPrint('🔍 ShiftLoggerScreen: Loading worker by ID: ${widget.workerId}');
      _loadWorkerById(widget.workerId!);
    } else {
      _initShifts();
    }
  }
  
  /// Load worker by ID for deep link support
  Future<void> _loadWorkerById(String workerId) async {
    setState(() {
      _isLoadingWorker = true;
      _workerNotFound = false;
    });
    try {
      final worker = await WorkerService().getWorkerById(workerId);
      if (mounted) {
        if (worker != null) {
          debugPrint('✅ ShiftLoggerScreen: Worker loaded successfully: ${worker.name}');
          setState(() => _loadedWorker = worker);
          _initShifts();
        } else {
          debugPrint('❌ ShiftLoggerScreen: Worker NOT FOUND for id: $workerId');
          setState(() => _workerNotFound = true);
        }
      }
    } catch (e) {
      debugPrint('❌ Error loading worker for shifts: $e');
      if (mounted) setState(() => _workerNotFound = true);
    } finally {
      if (mounted) setState(() => _isLoadingWorker = false);
    }
  }
  
  void _initShifts() {
    if (widget.existingPeriod != null) {
      _startDate = widget.existingPeriod!.startDate;
      _endDate = widget.existingPeriod!.endDate;
      _shifts = List.from(widget.existingPeriod!.shifts);
      _showHelp = false; // Hide help if editing existing period
    } else {
      // Default to current quincena
      final now = DateTime.now();
      if (now.day <= 15) {
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = DateTime(now.year, now.month, 15);
      } else {
        _startDate = DateTime(now.year, now.month, 16);
        _endDate = DateTime(now.year, now.month + 1, 0); // Last day of month
      }
      _generateShifts();
    }
  }
  
  // Helper to get current worker
  WorkerProfile? get _currentWorker => _loadedWorker ?? widget.worker;

  void _generateShifts() {
    _shifts.clear();
    DateTime current = _startDate;
    while (current.isBefore(_endDate.add(const Duration(seconds: 1)))) {
      _shifts.add(ShiftRecord(
        date: current,
        isSunday: current.weekday == DateTime.sunday,
      ));
      current = current.add(const Duration(days: 1));
    }
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    
    final newPeriod = WorkPeriod(
      id: widget.existingPeriod?.id,
      workerId: _currentWorker?.id ?? '',
      startDate: _startDate,
      endDate: _endDate,
      shifts: _shifts,
    );

    final worker = _currentWorker;
    if (worker == null) {
      setState(() => _isLoading = false);
      return;
    }
    final index = worker.shiftPeriods.indexWhere((p) => p.id == newPeriod.id);
    
    if (index >= 0) {
      worker.shiftPeriods[index] = newPeriod;
    } else {
      worker.shiftPeriods.add(newPeriod);
    }

    await WorkerService().saveWorker(worker);
    
    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Turnos guardados correctamente'), backgroundColor: kNeonGreen),
      );
      Navigator.pop(context, true);
    }
  }

  void _goToSalaryCalculator() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SalarioScreen(initialWorkerId: _currentWorker?.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show loading state if worker is being fetched
    if (_isLoadingWorker) {
      return PremiumScaffold(
        title: 'Registro de Turnos',
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: kNeonCyan),
              const SizedBox(height: 16),
              Text('Cargando datos del empleado...', 
                style: GoogleFonts.outfit(color: Colors.white70)),
            ],
          ),
        ),
      );
    }
    
    // Show error state if workerId was given but not found
    if (_workerNotFound) {
      return PremiumScaffold(
        title: 'Registro de Turnos',
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_off, size: 48, color: Colors.red),
                ),
                const SizedBox(height: 20),
                Text('Empleado no encontrado', 
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('El ID "${widget.workerId}" no existe en el directorio.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(color: Colors.white54, fontSize: 14)),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/hr/employees');
                    }
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Volver al Directorio'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kNeonCyan,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    // Show select worker state if no worker provided
    if (_currentWorker == null) {
      return PremiumScaffold(
        title: 'Registro de Turnos',
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kNeonGold.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_search, size: 48, color: kNeonGold),
                ),
                const SizedBox(height: 20),
                Text('Empleado: No seleccionado', 
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Selecciona un empleado desde el directorio para registrar sus turnos.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(color: Colors.white54, fontSize: 14)),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => context.push('/hr/employees'),
                  icon: const Icon(Icons.people),
                  label: const Text('Ir al Directorio de Empleados'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kNeonGold,
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    return PremiumScaffold(
      title: 'Registro de Turnos',
      subtitle: _currentWorker!.name,
      actions: [
        IconButton(
          icon: const Icon(Icons.file_upload, color: Colors.greenAccent),
          onPressed: () => context.push('/tools/import_shifts'),
          tooltip: 'Importar Excel',
        ),
        IconButton(
          icon: const Icon(Icons.save, color: kNeonCyan),
          onPressed: _isLoading ? null : _save,
          tooltip: 'Guardar Turnos',
        ),
        IconButton(
          icon: const Icon(Icons.star, color: kNeonGold),
          onPressed: _fillDemoData,
          tooltip: 'Llenar datos de ejemplo',
        ),
        IconButton(
          icon: const Icon(Icons.exit_to_app, color: kNeonGreen),
          onPressed: _goToSalaryCalculator,
          tooltip: 'Ir a Calcular Salario',
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === DEBUG BANNER (only in debug mode) ===
            if (kDebugMode)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.yellow.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.yellow),
                ),
                child: Text(
                  'DEBUG: workerId="${widget.workerId ?? "NULL"}" | worker="${_currentWorker?.name ?? "NULL"}"',
                  style: const TextStyle(color: Colors.yellow, fontSize: 11, fontFamily: 'monospace'),
                ),
              ),
            
            // === EMPLOYEE CONTEXT HEADER ===
            _buildEmployeeContextHeader(),
            
            // === HELP PANEL ===
            if (_showHelp) _buildHelpPanel(),
            
            // === PERIOD SELECTOR ===
            _buildPeriodSelector(),
            const SizedBox(height: 16),
            
            // === WORKER PAYMENT INFO ===
            _buildWorkerPaymentInfo(),
            const SizedBox(height: 16),
            
            // === SUMMARY CARD ===
            _buildSummaryCard(),
            const SizedBox(height: 20),
            
            // === SHIFT CARDS ===
            Text('📅 Registro Diario', style: GoogleFonts.outfit(color: kNeonGold, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._shifts.asMap().entries.map((entry) => _buildShiftCard(entry.key, entry.value)).toList(),
            
            const SizedBox(height: 24),
            
            // === ACTION BUTTONS ===
            Row(
              children: [
                Expanded(
                  child: NeonButton(
                    text: '💾 GUARDAR REGISTROS',
                    onTap: _save,
                    isLoading: _isLoading,
                    color: kNeonCyan,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: NeonButton(
                    text: '📊 CALCULAR SALARIO CON ESTOS TURNOS',
                    onTap: () async {
                      await _save();
                      _goToSalaryCalculator();
                    },
                    color: kNeonGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpPanel() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kNeonBlue.withOpacity(0.2), kNeonCyan.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kNeonCyan.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('💡 ¿Cómo usar esta pantalla?', style: GoogleFonts.outfit(color: kNeonCyan, fontSize: 16, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white38, size: 18),
                onPressed: () => setState(() => _showHelp = false),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildHelpRow('1️⃣', 'Selecciona el periodo de la quincena'),
          _buildHelpRow('2️⃣', 'Llena las horas de cada día:'),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHelpItem('Regular', 'Horas normales (ej: 8)'),
                _buildHelpItem('Ext Diu', 'Horas extra diurnas (+25%)'),
                _buildHelpItem('Ext Noc', 'Horas extra nocturnas (+50%)'),
                _buildHelpItem('Ext Mix', 'Horas extra mixtas (+75%)'),
              ],
            ),
          ),
          _buildHelpRow('3️⃣', 'Marca si fue Feriado o Domingo'),
          _buildHelpRow('4️⃣', 'Guarda y ve a "Calcular Salario"'),
        ],
      ),
    );
  }

  Widget _buildHelpRow(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text('$emoji $text', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)),
    );
  }

  Widget _buildHelpItem(String label, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(4)),
            child: Text(label, style: GoogleFonts.outfit(color: kNeonGold, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          Text(desc, style: GoogleFonts.outfit(color: Colors.white54, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final totalRegular = _shifts.fold<double>(0, (sum, s) => sum + s.regularHours);
    final totalExtraDiu = _shifts.fold<double>(0, (sum, s) => sum + s.extraDiurna);
    final totalExtraNoc = _shifts.fold<double>(0, (sum, s) => sum + s.extraNocturna);
    final totalExtraMix = _shifts.fold<double>(0, (sum, s) => sum + s.extraMixta);
    final totalHours = totalRegular + totalExtraDiu + totalExtraNoc + totalExtraMix;
    final holidays = _shifts.where((s) => s.isHoliday).length;
    final sundays = _shifts.where((s) => s.isSunday).length;

    return NeonCard(
      borderColor: kNeonGreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('📊 Resumen del Periodo', style: GoogleFonts.outfit(color: kNeonGreen, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('Total Horas', totalHours.toStringAsFixed(1), kNeonCyan),
              _buildSummaryItem('Regular', totalRegular.toStringAsFixed(1), Colors.white60),
              _buildSummaryItem('Extra', (totalExtraDiu + totalExtraNoc + totalExtraMix).toStringAsFixed(1), kNeonGold),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('Feriados', holidays.toString(), kNeonPink),
              _buildSummaryItem('Domingos', sundays.toString(), kNeonBlue),
              _buildSummaryItem('Días', _shifts.length.toString(), Colors.white38),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.outfit(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10)),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return NeonCard(
      borderColor: kNeonGold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('📆 Periodo de Trabajo', style: GoogleFonts.outfit(color: kNeonGold, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDateField('Desde', _startDate, (d) {
                  setState(() {
                    _startDate = d;
                    _generateShifts();
                  });
                }),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateField('Hasta', _endDate, (d) {
                  setState(() {
                    _endDate = d;
                    _generateShifts();
                  });
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(String label, DateTime value, Function(DateTime) onSelect) {
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          builder: (context, child) => Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(primary: kNeonGold, onPrimary: Colors.black),
            ),
            child: child!,
          ),
        );
        if (d != null) onSelect(d);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11)),
            Text(DateFormat('dd/MM/yyyy').format(value), style: GoogleFonts.outfit(color: Colors.white, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftCard(int index, ShiftRecord shift) {
    final isWeekend = shift.date.weekday == DateTime.saturday || shift.date.weekday == DateTime.sunday;
    final color = shift.isHoliday ? kNeonPink : (isWeekend ? kNeonBlue : Colors.white24);
    final hasData = shift.regularHours > 0 || shift.extraDiurna > 0 || shift.extraNocturna > 0 || shift.extraMixta > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasData ? kNeonGreen.withOpacity(0.08) : kGlassDark.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: hasData ? kNeonGreen.withOpacity(0.5) : color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  shift.dayLabel,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              Row(
                children: [
                  _buildToggle('Feriado', shift.isHoliday, (v) => setState(() => _shifts[index] = _updateShift(shift, isHoliday: v))),
                  const SizedBox(width: 8),
                  _buildToggle('Dom', shift.isSunday, (v) => setState(() => _shifts[index] = _updateShift(shift, isSunday: v))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSmallInput('Regular', shift.regularHours, (v) => _shifts[index] = _updateShift(shift, reg: v)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSmallInput('Ext Diu', shift.extraDiurna, (v) => _shifts[index] = _updateShift(shift, d25: v)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSmallInput('Ext Noc', shift.extraNocturna, (v) => _shifts[index] = _updateShift(shift, d50: v)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSmallInput('Ext Mix', shift.extraMixta, (v) => _shifts[index] = _updateShift(shift, d75: v)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(String label, bool value, Function(bool) onChanged) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: value ? kNeonGold.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: value ? kNeonGold : Colors.white10),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: value ? kNeonGold : Colors.white38,
            fontSize: 10,
            fontWeight: value ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSmallInput(String label, double value, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10)),
        const SizedBox(height: 4),
        TextField(
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            fillColor: Colors.white.withOpacity(0.05),
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          ),
          onChanged: (v) {
            final val = double.tryParse(v) ?? 0;
            onChanged(val);
          },
          controller: TextEditingController(text: value > 0 ? value.toString() : '')..selection = TextSelection.fromPosition(TextPosition(offset: (value > 0 ? value.toString() : '').length)),
        ),
      ],
    );
  }

  ShiftRecord _updateShift(ShiftRecord s, {double? reg, double? d25, double? d50, double? d75, bool? isHoliday, bool? isSunday}) {
    return ShiftRecord(
      id: s.id,
      date: s.date,
      regularHours: reg ?? s.regularHours,
      extraDiurna: d25 ?? s.extraDiurna,
      extraNocturna: d50 ?? s.extraNocturna,
      extraMixta: d75 ?? s.extraMixta,
      isHoliday: isHoliday ?? s.isHoliday,
      isSunday: isSunday ?? s.isSunday,
      notes: s.notes,
    );
  }

  void _fillDemoData() {
    setState(() {
      for (int i = 0; i < _shifts.length; i++) {
        final s = _shifts[i];
        // Fill with typical work week data
        if (s.date.weekday != DateTime.sunday) {
          _shifts[i] = ShiftRecord(
            id: s.id,
            date: s.date,
            regularHours: 8, // 8 hours normal work
            extraDiurna: i % 3 == 0 ? 2 : 0, // Some days have overtime
            extraNocturna: i % 5 == 0 ? 1 : 0, // Occasional night overtime
            extraMixta: 0,
            isHoliday: i == 0, // First day is holiday for demo
            isSunday: s.date.weekday == DateTime.sunday,
          );
        } else {
          // Sunday - worked with premium
          _shifts[i] = ShiftRecord(
            id: s.id,
            date: s.date,
            regularHours: 4, // Half day on Sunday
            extraDiurna: 0,
            extraNocturna: 0,
            extraMixta: 0,
            isHoliday: false,
            isSunday: true,
          );
        }
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Datos de ejemplo cargados'),
        backgroundColor: kNeonGreen,
      ),
    );
  }

  Widget _buildWorkerPaymentInfo() {
    final worker = _currentWorker;
    if (worker == null) return const SizedBox.shrink();
    
    final isHourly = worker.paymentType == PaymentType.hourly;
    final rate = isHourly 
        ? (worker.hourlyRate ?? (worker.basePayment / 208)) 
        : worker.basePayment;
    final rateLabel = isHourly ? 'por hora' : 'base ${worker.paymentMode.name}';
    
    return NeonCard(
      borderColor: kNeonCyan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isHourly ? Icons.access_time : Icons.account_balance_wallet,
                color: isHourly ? kNeonGold : kNeonCyan,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isHourly ? '⏱️ Pago por Hora' : '💵 Salario Base',
                style: GoogleFonts.outfit(
                  color: isHourly ? kNeonGold : kNeonCyan,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tarifa $rateLabel:',
                style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
              ),
              Text(
                'B/. ${rate.toStringAsFixed(2)}',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          if (!isHourly) ...[
            const SizedBox(height: 8),
            Text(
              '💡 Este empleado tiene salario base. Las horas extra se calculan sobre el equivalente por hora.',
              style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              '💡 Este empleado cobra por hora. El total se calcula multiplicando horas × tarifa.',
              style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }

  // ========= EMPLOYEE CONTEXT HEADER =========
  Widget _buildEmployeeContextHeader() {
    final worker = _currentWorker;
    if (worker == null) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kNeonCyan.withOpacity(0.15), kNeonBlue.withOpacity(0.08)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kNeonCyan.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: kNeonCyan.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                worker.name.isNotEmpty ? worker.name[0].toUpperCase() : '?',
                style: GoogleFonts.outfit(
                  color: kNeonCyan,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Empleado: ${worker.name}',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (worker.position.isNotEmpty)
                  Text(
                    worker.position,
                    style: GoogleFonts.outfit(color: Colors.white60, fontSize: 13),
                  ),
                const SizedBox(height: 4),
                Text(
                  '📝 Registrando turnos para este empleado',
                  style: GoogleFonts.outfit(color: kNeonCyan, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
