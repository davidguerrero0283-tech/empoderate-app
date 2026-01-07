import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../../components/premium_scaffold.dart';
import '../../components/neon_widgets.dart';
import '../../calculators/vacation_models.dart';
import '../../calculators/salario_models.dart'; // For WorkerProfile
import '../../services/worker_service.dart';
import '../../services/pdf_service.dart';
import '../../../features/hr/vacation/domain/vacation_calculator_service.dart' as vac_service;
import '../../features/payroll/domain/payroll_deductions_service.dart'; // Fixed path
import '../../utils/carta_generator.dart';
import 'package:uuid/uuid.dart';

class VacationCalculatorScreen extends StatefulWidget {
  final WorkerProfile? worker;
  final String? workerId; // Deep link support
  final DateTime? initialStartDate; // NEW
  final DateTime? initialEndDate;   // NEW

  const VacationCalculatorScreen({
    Key? key, 
    this.worker, 
    this.workerId,
    this.initialStartDate,
    this.initialEndDate,
  }) : super(key: key);

  @override
  State<VacationCalculatorScreen> createState() => _VacationCalculatorScreenState();
}

class _VacationCalculatorScreenState extends State<VacationCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final WorkerService _workerService = WorkerService();
  final vac_service.VacationCalculatorService _vacationService = vac_service.VacationCalculatorService();
  final PayrollDeductionsService _deductionsService = PayrollDeductionsService(); // NEW
  
  // MODO
  bool _manualMode = true; // Default MANUAL
  bool _isLoadingEmployees = false;
  bool _loadingTimedOut = false;
  
  // EMPLOYEE MODE
  String? _selectedWorkerId;
  WorkerProfile? get _selectedWorker => _workers.firstWhereOrNull((w) => w.id == _selectedWorkerId);
  List<WorkerProfile> _workers = [];
  
  // MANUAL INPUTS
  late DateTime _serviceStartDate;
  late DateTime _serviceEndDate;
  vac_service.PayrollFrequency _payrollFrequency = vac_service.PayrollFrequency.monthly;
  final TextEditingController _lastSalaryController = TextEditingController();
  bool _hasVariableComponents = false;
  final TextEditingController _ordinaryMonthsController = TextEditingController();
  final TextEditingController _workdaysController = TextEditingController(text: '242');
  
  // DEDUCTIONS STATE
  bool _applyCSS = true;
  bool _applySE = true;
  bool _applyISR = false;
  final TextEditingController _otherDeductionsController = TextEditingController();
  final TextEditingController _isrAmountController = TextEditingController();

  // RESULT
  LegalVacationResult? _legalResult;
  PayrollDeductions? _deductionsResult; // NEW
  
  @override
  void initState() {
    super.initState();
    // Initialize dates
    _serviceStartDate = widget.initialStartDate ?? DateTime.now().subtract(const Duration(days: 365));
    _serviceEndDate = widget.initialEndDate ?? DateTime.now();

    _selectedWorkerId = widget.worker?.id ?? widget.workerId;
    
    // Auto-load logic
    if (_selectedWorkerId != null) {
      _manualMode = false;
      _autoFillFromEmployee();
    }
    
    _tryLoadEmployees();
  }
  
  void _loadWorkerById(String id) async {
    setState(() {
      _isLoadingEmployees = true;
      _manualMode = false; // Intento cargar empleado
    });
    
    try {
      final worker = await _workerService.getWorkerById(id);
      if (mounted) {
        setState(() {
          _isLoadingEmployees = false;
          if (worker != null) {
            _selectedWorkerId = worker.id;
            _workers = [worker]; // Show at least this one
            _autoFillFromEmployee();
          } else {
            _manualMode = true; // Fallback
          }
        });
        
        // Load others in background
        _tryLoadEmployees();
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingEmployees = false);
    }
  }
  
  void _tryLoadEmployees() async {
    setState(() {
      _isLoadingEmployees = true;
      _loadingTimedOut = false;
    });
    
    // Timeout de 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      if (_isLoadingEmployees && mounted) {
        setState(() => _loadingTimedOut = true);
      }
    });
    
    try {
      final workers = await _workerService.getWorkers();
      if (mounted) {
        setState(() {
          _workers = workers;
          _isLoadingEmployees = false;
          
          if (workers.isEmpty) {
            _manualMode = true; // Force manual if no employees
          } else {
             // Safety: Ensure selected worker is in the list
             if (_selectedWorkerId != null && !workers.any((w) => w.id == _selectedWorkerId)) {
               _selectedWorkerId = null;
             }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingEmployees = false;
          _manualMode = true; // Force manual on error
        });
      }
    }
  }
  
  void _autoFillFromEmployee() {
    if (_selectedWorker == null) return;
    
    // Auto-fill available data
    _lastSalaryController.text = _selectedWorker!.basePayment.toStringAsFixed(2);
    
    // Assume monthly by default
    _payrollFrequency = vac_service.PayrollFrequency.monthly;
    
    // Service dates (estimate if not available)
    if (_selectedWorker!.startDate != null) {
      _serviceStartDate = _selectedWorker!.startDate!;
    }
    _serviceEndDate = DateTime.now();
    
    // === LOAD FROM PAYROLL HISTORY ===
    _loadFromPayrollHistory();
  }
  
  /// Calculates totals from the last 11 months of payroll history
  void _loadFromPayrollHistory() {
    if (_selectedWorker == null) return;
    
    final payrollHistory = _selectedWorker!.payrollHistory;
    if (payrollHistory.isEmpty) {
      // No history available, keep manual entry mode
      return;
    }
    
    // Get last 11 months of records
    final now = DateTime.now();
    final elevenMonthsAgo = DateTime(now.year, now.month - 11, now.day);
    
    final relevantRecords = payrollHistory.where((record) {
      try {
        return record.periodStart.isAfter(elevenMonthsAgo);
      } catch (_) {
        return false;
      }
    }).toList();
    
    if (relevantRecords.isEmpty) return;
    
    // Calculate total ordinary earnings (gross salary)
    double totalOrdinary = 0;
    int totalWorkdays = 0;
    
    for (final record in relevantRecords) {
      totalOrdinary += record.grossSalary;
      // Estimate workdays based on period (approximate)
      final days = record.periodEnd.difference(record.periodStart).inDays;
      // Assume ~22 workdays per month, ~11 per quincena
      totalWorkdays += (days > 20 ? 22 : 11);
    }
    
    // Fill the fields
    if (totalOrdinary > 0) {
      _ordinaryMonthsController.text = totalOrdinary.toStringAsFixed(2);
    }
    if (totalWorkdays > 0) {
      _workdaysController.text = totalWorkdays.toString();
    }
    
    // Enable variable components mode since we have history
    setState(() {
      _hasVariableComponents = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Datos cargados de ${relevantRecords.length} registros de nómina'),
        backgroundColor: kNeonGreen,
      ),
    );
  }
  
  /// Shows a dialog with the payroll history
  void _showPayrollHistoryDialog() {
    if (_selectedWorker == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione un empleado primero'), backgroundColor: Colors.orange),
      );
      return;
    }
    
    final history = _selectedWorker!.payrollHistory;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        title: Row(
          children: [
            Icon(Icons.history, color: kNeonCyan),
            const SizedBox(width: 8),
            Text('Historial de Planilla', style: GoogleFonts.outfit(color: Colors.white)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: history.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 48, color: Colors.white38),
                      const SizedBox(height: 12),
                      Text('No hay registros de nómina', style: GoogleFonts.outfit(color: Colors.white54)),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final record = history[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(record.periodLabel, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                              Text('Bruto: B/. ${record.grossSalary.toStringAsFixed(2)}', style: GoogleFonts.outfit(color: kNeonGreen, fontSize: 12)),
                            ],
                          ),
                          Text('B/. ${record.netSalary.toStringAsFixed(2)}', style: GoogleFonts.outfit(color: kNeonCyan, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar', style: TextStyle(color: kNeonCyan)),
          ),
          if (history.isNotEmpty)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _loadFromPayrollHistory();
              },
              style: ElevatedButton.styleFrom(backgroundColor: kNeonGreen),
              child: const Text('Usar estos datos'),
            ),
        ],
      ),
    );
  }
  
  void _calculate() {
    if (!_formKey.currentState!.validate()) return;
    
    final lastSalary = double.tryParse(_lastSalaryController.text) ?? 0;
    if (lastSalary <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Salario base debe ser mayor a 0'), backgroundColor: Colors.red),
      );
      return;
    }
    
    // Calculate days accrued
    final daysAccrued = _vacationService.computeVacationDaysAccrued(
      startDate: _serviceStartDate,
      endDate: _serviceEndDate,
    );
    
    // Prepare earnings data
    final ordinaryTotal = double.tryParse(_ordinaryMonthsController.text) ?? 0;
    final ordinary11Months = _hasVariableComponents && ordinaryTotal > 0
        ? List.filled(11, ordinaryTotal / 11)
        : List.filled(11, lastSalary);
    final extraordinary11Months = List.filled(11, 0.0);
    final workdays = int.tryParse(_workdaysController.text) ?? 242;
    
    // Calculate pay
    final vacationPay = _vacationService.computeVacationPay(
      frequency: _payrollFrequency,
      lastBaseSalary: lastSalary,
      hasVariableComponentsOrRecentRaise: _hasVariableComponents,
      last11MonthsOrdinaryEarnings: ordinary11Months,
      last11MonthsExtraordinaryEarnings: extraordinary11Months,
      ordinaryWorkdaysServedLast11Months: workdays,
      vacationDaysToPay: daysAccrued,
    );
    
    // Get method
    final avgMonthly = ordinary11Months.fold(0.0, (a, b) => a + b) / 11;
    final method = _vacationService.getCalculationMethod(
      frequency: _payrollFrequency,
      hasVariableComponentsOrRecentRaise: _hasVariableComponents,
      lastBaseSalary: lastSalary,
      avgMonthly11: avgMonthly,
    );
    
    // Calculate Net
    final deductions = _deductionsService.calculate(
      grossAmount: vacationPay,
      applyCSS: _applyCSS,
      applySE: _applySE,
      applyISR: _applyISR,
      isrAmount: double.tryParse(_isrAmountController.text) ?? 0,
      otherDeductions: double.tryParse(_otherDeductionsController.text) ?? 0,
    );
    
    setState(() {
      _legalResult = LegalVacationResult(
        daysAccrued: daysAccrued,
        vacationPay: vacationPay,
        calculationMethod: method,
      );
      _deductionsResult = deductions;
    });
  }

  void _showDocument() {
    if (_legalResult == null || _selectedWorker == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Realice el cálculo y seleccione un empleado primero')),
      );
      return;
    }

    final content = CartaGenerator.generateVacationRequest(
      _selectedWorker!, 
      _serviceStartDate, 
      _serviceEndDate,
      days: _legalResult!.daysAccrued.toInt(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2B),
        title: Text('Solicitud de Vacaciones', style: GoogleFonts.outfit(color: Colors.white)),
        content: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white.withOpacity(0.05),
            child: Text(content, style: GoogleFonts.firaCode(color: Colors.white70, fontSize: 12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CERRAR')),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Descargando PDF...')));
              Navigator.pop(context);
            },
            child: const Text('DESCARGAR PDF'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveCalculation() async {
    if (_legalResult == null || _selectedWorker == null) return;

    setState(() => _isLoadingEmployees = true);
    
    try {
      final record = VacationRecord(
        id: Uuid().v4(),
        startDate: _serviceStartDate,
        endDate: _serviceEndDate,
        daysTaken: _legalResult!.daysAccrued.toInt(),
        amountPaid: _deductionsResult?.netAmount ?? _legalResult!.vacationPay,
        isPaid: true,
        createdAt: DateTime.now(),
      );

      final updatedWorker = _selectedWorker!.copyWith(
        vacationHistory: [..._selectedWorker!.vacationHistory, record],
      );

      await _workerService.saveWorker(updatedWorker);
      
      if (mounted) {
        // Reload workers to pick up the updated worker with vacation history
        _tryLoadEmployees();
        setState(() {
          _selectedWorkerId = updatedWorker.id;
          _isLoadingEmployees = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Cálculo guardado en el historial del empleado'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingEmployees = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error al guardar: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _sendByEmail() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función de envío por correo electrónico se integrará con el servicio de mensajería Pro.')),
    );
  }
  
  void _clear() {
    setState(() {
      _legalResult = null;
      _deductionsResult = null;
      _serviceStartDate = DateTime.now().subtract(const Duration(days: 365));
      _serviceEndDate = DateTime.now();
      _lastSalaryController.text = '1000';
      _hasVariableComponents = false;
      _ordinaryMonthsController.text = '0';
      _otherDeductionsController.text = '0';
      _isrAmountController.text = '0';
    });
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Calculadora de Vacaciones',
      showBranding: true,
      useScroll: false,
      usePadding: false,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // LOADING STATE
              if (_isLoadingEmployees && !_loadingTimedOut)
                _buildLoadingIndicator(),
              
              if (_loadingTimedOut)
                _buildTimeoutMessage(),
              
              // MODE TOGGLE
              if (!_isLoadingEmployees || _loadingTimedOut)
                _buildModeToggle(),
              
              const SizedBox(height: 20),
              
              // EMPLOYEE SELECTOR (if not manual mode)
              if (!_manualMode && _workers.isNotEmpty)
                _buildEmployeeSelector(),
              
              const SizedBox(height: 20),
              
              // INPUTS
              _buildInputSection(),
              
              const SizedBox(height: 20),
              
              // DEDUCTIONS
              _buildDeductionsSection(),
              
              const SizedBox(height: 24),
              
              // CALCULATE BUTTON
              NeonButton(
                text: 'CALCULAR VACACIONES',
                icon: Icons.calculate,
                onTap: _calculate,
                color: kNeonGreen,
              ),
              
              const SizedBox(height: 12),
              
              // CLEAR BUTTON
              OutlinedButton.icon(
                onPressed: _clear,
                icon: const Icon(Icons.clear_all),
                label: Text('Limpiar', style: GoogleFonts.outfit()),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  side: const BorderSide(color: Colors.white24),
                ),
              ),
              
              // RESULT
              if (_legalResult != null) ...[
                const SizedBox(height: 32),
                _buildResult(),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kNeonBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kNeonBlue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const CircularProgressIndicator(strokeWidth: 2),
          const SizedBox(width: 16),
          Expanded(
            child: Text('Cargando empleados...', style: GoogleFonts.outfit(color: Colors.white70)),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTimeoutMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kNeonGold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kNeonGold),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: kNeonGold),
              const SizedBox(width: 12),
              Expanded(
                child: Text('La carga está tardando más de lo esperado', 
                           style: GoogleFonts.outfit(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => setState(() {
              _manualMode = true;
              _isLoadingEmployees = false;
            }),
            style: ElevatedButton.styleFrom(backgroundColor: kNeonGold),
            child: Text('Continuar en Modo Manual', style: GoogleFonts.outfit(color: Colors.black)),
          ),
        ],
      ),
    );
  }
  
  Widget _buildModeToggle() {
    if (_workers.isEmpty && !_isLoadingEmployees) {
      // Force manual, no toggle
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text('Modo: MANUAL (sin empleados registrados)', 
                   style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)),
      );
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text('Modo:', style: GoogleFonts.outfit(color: Colors.white70)),
          const SizedBox(width: 12),
          Expanded(
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('MANUAL')),
                ButtonSegment(value: false, label: Text('CON EMPLEADO')),
              ],
              selected: {_manualMode},
              onSelectionChanged: (Set<bool> newSelection) {
                setState(() {
                  _manualMode = newSelection.first;
                  if (!_manualMode && _workers.isNotEmpty && _selectedWorkerId == null) {
                     _selectedWorkerId = _workers.first.id;
                     _autoFillFromEmployee();
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmployeeSelector() {
    if (_workers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text('No hay empleados registrados', style: TextStyle(color: Colors.white70)),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kNeonBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kNeonBlue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Seleccionar Empleado', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedWorkerId,
            dropdownColor: const Color(0xFF1A1F2E),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF151C2B),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            style: GoogleFonts.outfit(color: Colors.white),
            items: _workers.map((w) => DropdownMenuItem<String>(
              value: w.id,
              child: Text(w.name),
            )).toList(),
            onChanged: (id) {
              setState(() {
                _selectedWorkerId = id;
                _autoFillFromEmployee();
              });
            },
          ),
          const SizedBox(height: 12),
          // === HISTORIAL DE PLANILLA BUTTON ===
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showPayrollHistoryDialog,
              icon: Icon(Icons.history, color: kNeonCyan),
              label: Text('📋 Historial de Planilla', style: GoogleFonts.outfit(color: kNeonCyan)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: kNeonCyan.withOpacity(0.5)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Service Dates
        Text('PERÍODO DE SERVICIO', style: GoogleFonts.outfit(color: kNeonBlue, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildDateField('Fecha Inicio', _serviceStartDate, (date) => setState(() => _serviceStartDate = date))),
            const SizedBox(width: 12),
            Expanded(child: _buildDateField('Fecha Fin/Corte', _serviceEndDate, (date) => setState(() => _serviceEndDate = date))),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // Payroll Frequency
        Text('FRECUENCIA DE PAGO', style: GoogleFonts.outfit(color: kNeonGreen, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        DropdownButtonFormField<vac_service.PayrollFrequency>(
          value: _payrollFrequency,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF151C2B),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          dropdownColor: const Color(0xFF1A2332),
          style: GoogleFonts.outfit(color: Colors.white),
          items: [
            DropdownMenuItem(value: vac_service.PayrollFrequency.monthly, child: Text('Mensual')),
            DropdownMenuItem(value: vac_service.PayrollFrequency.biweekly, child: Text('Quincenal')),
            DropdownMenuItem(value: vac_service.PayrollFrequency.weekly, child: Text('Semanal')),
            DropdownMenuItem(value: vac_service.PayrollFrequency.daily, child: Text('Por Día')),
            DropdownMenuItem(value: vac_service.PayrollFrequency.hourly, child: Text('Por Hora')),
          ],
          onChanged: (freq) => setState(() => _payrollFrequency = freq!),
        ),
        
        const SizedBox(height: 20),
        
        // Last Salary
        Text('ÚLTIMO SALARIO BASE', style: GoogleFonts.outfit(color: kNeonPurple, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextFormField(
          controller: _lastSalaryController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixText: 'B/. ',
            filled: true,
            fillColor: const Color(0xFF151C2B),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          style: GoogleFonts.outfit(color: Colors.white),
          validator: (v) => (double.tryParse(v ?? '0') ?? 0) <= 0 ? 'Requerido' : null,
        ),
        
        const SizedBox(height: 20),
        
        // Variable Components Toggle
        SwitchListTile(
          title: Text('Tiene variables o aumento reciente', style: GoogleFonts.outfit(color: Colors.white)),
          value: _hasVariableComponents,
          activeColor: kNeonGreen,
          onChanged: (v) => setState(() => _hasVariableComponents = v),
        ),
        
        if (_hasVariableComponents) ...[
          const SizedBox(height: 12),
          
          // === TOTAL ORDINARIO ===
          Text('Total ordinario 11 meses (simplificado)', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
          Text(
            '💡 Suma de todos los salarios regulares recibidos en los últimos 11 meses. NO incluye el mes de vacaciones.',
            style: GoogleFonts.outfit(color: kNeonCyan.withOpacity(0.7), fontSize: 10),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _ordinaryMonthsController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              prefixText: 'B/. ',
              hintText: 'Ej: 12000',
              filled: true,
              fillColor: const Color(0xFF151C2B),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            style: GoogleFonts.outfit(color: Colors.white),
          ),
          const SizedBox(height: 16),
          
          // === JORNADAS ORDINARIAS ===
          Text('Jornadas ordinarias servidas (últimos 11 meses)', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
          Text(
            '💡 Días efectivamente trabajados en 11 meses. Se obtiene del registro de turnos o nómina. Ej: 22 días/mes × 11 meses = 242 días.',
            style: GoogleFonts.outfit(color: kNeonCyan.withOpacity(0.7), fontSize: 10),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _workdaysController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: 'Ej: 242',
              helperText: '22 días × 11 meses = 242',
              helperStyle: GoogleFonts.outfit(color: Colors.white38, fontSize: 10),
              filled: true,
              fillColor: const Color(0xFF151C2B),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            style: GoogleFonts.outfit(color: Colors.white),
          ),
        ],
      ],
    );
  }

  Widget _buildDeductionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('DEDUCCIONES', style: GoogleFonts.outfit(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            children: [
              SwitchListTile(
                title: Text('Seguro Social (9.75%)', style: GoogleFonts.outfit(color: Colors.white)),
                value: _applyCSS,
                activeColor: Colors.redAccent,
                onChanged: (v) => setState(() => _applyCSS = v),
              ),
              SwitchListTile(
                title: Text('Seguro Educativo (1.25%)', style: GoogleFonts.outfit(color: Colors.white)),
                value: _applySE,
                activeColor: Colors.redAccent,
                onChanged: (v) => setState(() => _applySE = v),
              ),
              SwitchListTile(
                title: Text('ISR (Impuesto sobre la Renta)', style: GoogleFonts.outfit(color: Colors.white)),
                value: _applyISR,
                activeColor: Colors.redAccent,
                onChanged: (v) => setState(() => _applyISR = v),
              ),
              if (_applyISR)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextFormField(
                    controller: _isrAmountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Monto ISR',
                      prefixText: 'B/. ',
                      filled: true,
                      fillColor: const Color(0xFF151C2B),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    style: GoogleFonts.outfit(color: Colors.white),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextFormField(
                  controller: _otherDeductionsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Otros Descuentos',
                    prefixText: 'B/. ',
                    filled: true,
                    fillColor: const Color(0xFF151C2B),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  style: GoogleFonts.outfit(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildDateField(String label, DateTime date, Function(DateTime) onChanged) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFF151C2B),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(DateFormat('dd/MM/yyyy').format(date), style: GoogleFonts.outfit(color: Colors.white)),
      ),
    );
  }
  
  Widget _buildResult() {
    final r = _legalResult!;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kNeonGreen.withOpacity(0.2), kNeonBlue.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kNeonGreen, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: kNeonGreen, size: 28),
              const SizedBox(width: 12),
              Text('RESULTADO LEGAL (Art. 54)', 
                   style: GoogleFonts.outfit(color: kNeonGreen, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          _buildResultRow('Días Devengados:', '${r.daysAccrued.toStringAsFixed(2)} días'),
          _buildResultRow('Pago Vacaciones (Bruto):', 'B/. ${r.vacationPay.toStringAsFixed(2)}', isBold: true, fontSize: 16),
          
          if (_deductionsResult != null) ...[
            const Divider(color: Colors.white24, height: 24),
            _buildResultRow('(-) Seguro Social:', 'B/. ${_deductionsResult!.css.toStringAsFixed(2)}', color: Colors.white70),
            _buildResultRow('(-) Seguro Educativo:', 'B/. ${_deductionsResult!.se.toStringAsFixed(2)}', color: Colors.white70),
            if (_deductionsResult!.isr > 0)
              _buildResultRow('(-) ISR:', 'B/. ${_deductionsResult!.isr.toStringAsFixed(2)}', color: Colors.white70),
            if (_deductionsResult!.other > 0)
              _buildResultRow('(-) Otros Descuentos:', 'B/. ${_deductionsResult!.other.toStringAsFixed(2)}', color: Colors.white70),
            
            const Divider(color: Colors.white24, height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kNeonGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kNeonGreen.withOpacity(0.5)),
              ),
              child: _buildResultRow(
                'PAGO NETO:', 
                'B/. ${_deductionsResult!.netAmount.toStringAsFixed(2)}', 
                isBold: true, 
                fontSize: 20, 
                color: kNeonGreen
              ),
            ),
          ],
          
          const Divider(color: Colors.white24, height: 24),
          _buildResultRow('Método de Cálculo:', r.calculationMethod, color: kNeonBlue),
          
          const SizedBox(height: 24),
          
          // ACTION BUTTONS
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showDocument,
                  icon: const Icon(Icons.description, color: Colors.black),
                  label: Text('VER DOCUMENTO', style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kNeonBlue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          const SizedBox(height: 12),
          // === EXPORT PDF BUTTON ===
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _exportPdf,
              icon: const Icon(Icons.picture_as_pdf, color: Colors.black),
              label: Text('EXPORTAR PDF', style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: kNeonCyan,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _saveCalculation,
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: Text('GUARDAR', style: GoogleFonts.outfit(color: Colors.white)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: kNeonPurple),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _sendByEmail,
                  icon: const Icon(Icons.send, color: Colors.white),
                  label: Text('ENVIAR', style: GoogleFonts.outfit(color: Colors.white)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: kNeonGreen),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      )
    );
  }
  
  Future<void> _exportPdf() async {
    if (_legalResult == null) return;
    
    // Calculate deductions for PDF receipt
    double amount = _legalResult!.vacationPay;
    double ss = _applyCSS ? amount * 0.0975 : 0;
    double se = _applySE ? amount * 0.0125 : 0;
    double isr = _applyISR ? (double.tryParse(_isrAmountController.text) ?? 0) : 0;

    double net = amount - ss - se - isr;

    try {
      await PdfService.generateVacacionesPdf(
        workerName: _selectedWorker?.name ?? 'Colaborador',
        companyName: 'EMPRESA DEMO', // TODO: Get from company profile
        serviceStart: _serviceStartDate,
        serviceEnd: _serviceEndDate,
        diasVacaciones: _legalResult!.daysAccrued.toInt(), // Cast to int
        salarioPromedio: 0,
        montoVacaciones: amount,
        deduccionCSS: ss,
        deduccionSE: se,
        deduccionISR: isr,
        netoVacaciones: net,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al generar PDF: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  
  Widget _buildResultRow(String label, String value, {bool isBold = false, double fontSize = 14, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.outfit(color: Colors.white70, fontSize: fontSize)),
          Flexible(
            child: Text(value, 
                       textAlign: TextAlign.right,
                       style: GoogleFonts.outfit(
                         color: color ?? Colors.white, 
                         fontWeight: isBold ? FontWeight.bold : FontWeight.normal, 
                         fontSize: fontSize)),
          ),
        ],
      ),
    );
  }
}
