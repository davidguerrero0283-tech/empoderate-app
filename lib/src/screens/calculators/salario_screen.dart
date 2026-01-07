import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../components/neon_widgets.dart';
import '../../components/calculator_info_panel.dart';
import '../../calculators/salario_models.dart';
import '../../calculators/salario_logic.dart';
import '../../services/worker_service.dart';
import '../../features/analytics/analytics_service.dart';
import '../../features/payroll/domain/payroll_record.dart';
import '../../models/work_hours_breakdown.dart';
import 'comprobante_planilla_screen.dart';
import 'worker_detail_screen.dart';
import 'shift_logger_screen.dart';
import 'package:proyecto_empoderate/src/components/business_hero_header.dart';
import 'package:proyecto_empoderate/src/screens/human_resources/hr_dashboard_widgets.dart';
import 'package:proyecto_empoderate/src/components/employee_search_field.dart';
import 'package:proyecto_empoderate/src/services/vacation_eligibility_service.dart';

class SalarioScreen extends StatefulWidget {
  static const routeName = '/salario';
  final String? initialWorkerId;

  const SalarioScreen({Key? key, this.initialWorkerId}) : super(key: key);

  @override
  _SalarioScreenState createState() => _SalarioScreenState();
}

class _SalarioScreenState extends State<SalarioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  
  // Input Controllers
  final _nameCtrl = TextEditingController();
  final _posCtrl = TextEditingController();
  final _deptCtrl = TextEditingController();
  final _salaryCtrl = TextEditingController();

  // State
  SalarioInputModel _input = SalarioInputModel();
  SalarioResultModel? _result;
  bool _isLoading = false;
  
  // View options
  bool _showProvisions = false;
  
  // Workers Management
  List<WorkerProfile> _workers = [];
  String? _selectedWorkerId;
  
  // Custom Deductions
  final List<Map<String, dynamic>> _customDeductions = [];
  
  // Track calculated workers (workerId -> lastCalculationDate)
  final Map<String, DateTime> _calculatedWorkers = {};

  final WorkerService _workerService = WorkerService();
  final GlobalKey _resultsKey = GlobalKey();
  final GlobalKey _provisionsKey = GlobalKey();
  final VacationEligibilityService _vacationService = VacationEligibilityService();

  // Vacation integration state
  int _detectedVacationDays = 0;
  double _detectedVacationAmount = 0.0;
  bool _includeVacationPay = false;

  @override
  void initState() {
    super.initState();
    AnalyticsService().trackScreenView('CalculadoraSalario');
    _loadWorkers();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _posCtrl.dispose();
    _deptCtrl.dispose();
    _salaryCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadWorkers() async {
    final list = await _workerService.getWorkers();
    if (mounted) {
      setState(() => _workers = list);
      if (_selectedWorkerId == null && widget.initialWorkerId != null) {
        try {
          final w = list.firstWhere((element) => element.id == widget.initialWorkerId);
          _selectWorker(w);
        } catch (e) {
          debugPrint('Initial worker not found: ${widget.initialWorkerId}');
        }
      }
    }
  }

  void _selectWorker(WorkerProfile w) {
    setState(() {
      _selectedWorkerId = w.id;
      _input.workerName = w.name;
      _input.position = w.position;
      _input.companyName = w.department;
      _input.baseSalary = w.basePayment;
      _input.frequency = w.paymentMode;
      _nameCtrl.text = w.name;
      _posCtrl.text = w.position;
      _deptCtrl.text = w.department;
      _salaryCtrl.text = w.basePayment.toString();
      _result = null;

      // VACATION DETECTION LOGIC
      _detectedVacationDays = _vacationService.getVacationDaysInRange(w, _input.periodStart, _input.periodEnd);
      if (_detectedVacationDays > 0) {
        // Simple estimate: baseSalary / 30 * days
        _detectedVacationAmount = (w.basePayment / 30.0) * _detectedVacationDays;
        _includeVacationPay = true; // Auto-enable if detected
      } else {
        _detectedVacationAmount = 0.0;
        _includeVacationPay = false;
      }
    });
  }

  void _resetForm() {
    setState(() {
      _selectedWorkerId = null;
      _input = SalarioInputModel();
      _result = null;
      _nameCtrl.clear();
      _posCtrl.clear();
      _deptCtrl.clear();
      _salaryCtrl.clear();
      _customDeductions.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Formulario limpio para nuevo trabajador'))
    );
  }

  void _goToShiftLogger() {
    if (_selectedWorkerId == null) return;
    final worker = _workers.firstWhere((w) => w.id == _selectedWorkerId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShiftLoggerScreen(worker: worker),
      ),
    ).then((_) => _loadWorkers()); // Reload workers after returning
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1520),
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 50),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. HERO HEADER
              BusinessHeroHeader(
                title: 'Calculadora Salarial',
                categoryName: 'RECURSOS HUMANOS',
                icon: Icons.monetization_on,
                onBackPressed: () => Navigator.pop(context),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const CalculatorInfoPanel(configId: 'planilla'),
                    const SizedBox(height: 16),
                    
                    // Employee Search Field (replaces old carousel)
                    EmployeeSearchField(
                      workers: _workers,
                      selectedWorkerId: _selectedWorkerId,
                      calculatedWorkers: _calculatedWorkers,
                      onSelect: _selectWorker,
                      onNewEmployee: _resetForm,
                    ),
                    const SizedBox(height: 16),
                    
                    // 2. DASHBOARD
                    if (_result != null)
                      Column(
                        children: [
                          PayrollDashboard(
                            netSalary: _result!.netSalary,
                            grossSalary: _result!.totalDevengado,
                            deductions: _result!.totalDeducciones,
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),

                    // 3. INPUT SECTIONS
                    HrGlassContainer( 
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                            Text('📋 Datos Generales', style: GoogleFonts.outfit(color: kNeonGreen, fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            NeonInput(label: 'Nombre Empleado', controller: _nameCtrl, required: true, onChanged: (v) => _input.workerName = v),
                            NeonInput(label: 'Cargo', controller: _posCtrl, required: true, onChanged: (v) => _input.position = v),
                            NeonInput(label: 'Departamento', controller: _deptCtrl, onChanged: (v) => _input.companyName = v),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(child: NeonDateSelector(label: 'Inicio Periodo', date: _input.periodStart, onSelect: (d) => setState(() => _input.periodStart = d))),
                                const SizedBox(width: 12),
                                Expanded(child: NeonDateSelector(label: 'Fin Periodo', date: _input.periodEnd, onSelect: (d) => setState(() => _input.periodEnd = d))),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(child: NeonButton(text: 'Nuevo', onTap: _resetForm, color: Colors.white10, textColor: Colors.white70, icon: Icons.person_add)),
                                const SizedBox(width: 12),
                                Expanded(child: NeonButton(text: 'Guardar', onTap: _saveWorker, color: kNeonBlue.withOpacity(0.2), textColor: kNeonBlue, icon: Icons.save)),
                              ],
                            ),
                            if (_selectedWorkerId != null) ...[
                              const SizedBox(height: 12),
                              NeonButton(
                                text: '📅 Registrar Jornadas/Turnos',
                                onTap: _goToShiftLogger,
                                color: kNeonCyan.withOpacity(0.2),
                                textColor: kNeonCyan,
                                icon: Icons.schedule,
                              ),
                              const SizedBox(height: 8),
                              NeonButton(
                                text: '📁 Ver Archivo HR',
                                onTap: () => Navigator.pushNamed(context, '/hr_archive', arguments: _selectedWorkerId),
                                color: const Color(0xFFF4D35E).withOpacity(0.2),
                                textColor: const Color(0xFFF4D35E),
                                icon: Icons.folder_open,
                              ),
                            ],
                         ]
                      )
                    ),
                    const SizedBox(height: 12),

                    // Section: Salary & Pay
                    HrGlassContainer( 
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('💰 Salario & Pago', style: GoogleFonts.outfit(color: kNeonGold, fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          NeonInput(
                            label: 'Salario Base Mensual (\$)',
                            controller: _salaryCtrl,
                            isNumber: true,
                            required: true,
                            onChanged: (v) => _input.baseSalary = double.tryParse(v) ?? 0,
                          ),
                          const SizedBox(height: 20),
                          NeonDropdown<PayrollFrequency>(
                            label: 'Frecuencia de Pago',
                            value: _input.frequency,
                            items: PayrollFrequency.values.map((f) {
                              String label = f == PayrollFrequency.mensual ? 'Mensual' : (f == PayrollFrequency.quincenal ? 'Quincenal' : 'Semanal');
                              return DropdownMenuItem(value: f, child: Text(label, style: const TextStyle(color: Colors.white)));
                            }).toList(),
                            onChanged: (v) => setState(() => _input.frequency = v!),
                          ),
                          const SizedBox(height: 20),
                          Text('Jornada Laboral', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12)),
                          const SizedBox(height: 12),
                          Row(children: JornadaTipo.values.map((jt) {
                              final isSelected = _input.jornadaTipo == jt;
                              String label = jt == JornadaTipo.diurna ? 'Diurna' : (jt == JornadaTipo.mixta ? 'Mixta' : 'Nocturna');
                              return Expanded(child: GestureDetector(
                                onTap: () => setState(() => _input.jornadaTipo = jt),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    color: isSelected ? kNeonGold.withOpacity(0.2) : Colors.white10,
                                    border: Border.all(color: isSelected ? kNeonGold : Colors.white24),
                                    borderRadius: BorderRadius.circular(12)
                                  ),
                                  child: Center(child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.white70))),
                                )
                              ));
                          }).toList()),
                        ],
                      )
                    ),

                    // Vacation Detection UI
                    if (_detectedVacationDays > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: HrGlassContainer(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.beach_access, color: Colors.cyanAccent, size: 20),
                                  const SizedBox(width: 12),
                                  Text('Vacaciones Detectadas', style: GoogleFonts.outfit(color: Colors.cyanAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Se detectaron $_detectedVacationDays días de vacaciones programadas en este periodo.',
                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                              const SizedBox(height: 12),
                              NeonSwitch(
                                label: 'Incluir pago de vacaciones (\$${_detectedVacationAmount.toStringAsFixed(2)})',
                                value: _includeVacationPay,
                                onChanged: (v) => setState(() => _includeVacationPay = v),
                              ),
                            ],
                          ),
                        ),
                      ),

                  const SizedBox(height: 12),

                    // Section: Variable Income & Overtime
                    HrGlassContainer( 
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('⏱️ Tiempo Extra & Variables', style: GoogleFonts.outfit(color: kNeonCyan, fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          
                          // Overtime Row
                          Row(
                            children: [
                              Expanded(
                                child: NeonInput(
                                  label: 'H. Extras (25%)',
                                  isNumber: true,
                                  onChanged: (v) => _input.horasExtraDiurna = double.tryParse(v) ?? 0,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: NeonInput(
                                  label: 'H. Extras (50%)',
                                  isNumber: true,
                                  onChanged: (v) => _input.horasExtraNocturna = double.tryParse(v) ?? 0,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: NeonInput(
                                  label: 'H. Mixtas/Noc (75%)',
                                  isNumber: true,
                                  onChanged: (v) => _input.horasExtraMixtaNocturna = double.tryParse(v) ?? 0,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: NeonInput(
                                  label: 'Domingos/Feriados',
                                  isNumber: true,
                                  onChanged: (v) => _input.sundayAmount = double.tryParse(v) ?? 0, // Using amount field for direct Sunday value input for now, ideally should be hours
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 20),
                          const Divider(color: Colors.white10),
                          const SizedBox(height: 20),

                          Text('Ingresos Adicionales', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
                          const SizedBox(height: 12),
                          
                          Row(
                            children: [
                              Expanded(
                                child: NeonInput(
                                  label: 'Comisiones (\$)',
                                  isNumber: true,
                                  onChanged: (v) => _input.commissions = double.tryParse(v) ?? 0,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: NeonInput(
                                  label: 'Bonificaciones (\$)',
                                  isNumber: true,
                                  onChanged: (v) => _input.bonuses = double.tryParse(v) ?? 0,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          NeonInput(
                             label: 'Otros Ingresos (Viáticos/Reembolsos)',
                             isNumber: true,
                             onChanged: (v) => _input.otherIncome = double.tryParse(v) ?? 0,
                          ),
                        ],
                      )
                    ),

                    // Section: Deductions
                    HrGlassContainer( 
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('➖ Deducciones Manuales', style: GoogleFonts.outfit(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          ..._customDeductions.asMap().entries.map((entry) {
                             return ListTile(
                               title: Text(entry.value['name'], style: const TextStyle(color: Colors.white70)),
                               trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                                  Text('\$${entry.value['amount']}', style: const TextStyle(color: Colors.redAccent)),
                                  IconButton(icon: const Icon(Icons.close, color: Colors.white30, size: 16), onPressed: () {
                                     setState(() { _customDeductions.removeAt(entry.key); _updateTotalDeductions(); });
                                  })
                               ]),
                             );
                          }),
                          NeonButton(text: 'Agregar Deducción', onTap: _showAddDeductionDialog, primary: false, color: Colors.redAccent.withOpacity(0.2), textColor: Colors.redAccent, icon: Icons.add_circle_outline),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    NeonButton(text: 'CALCULAR PLANILLA', onTap: _calculate, color: kNeonCyan, textColor: Colors.white, icon: Icons.calculate, isLoading: _isLoading, primary: true),
                    
                    if (_result != null) 
                       Padding(
                         padding: const EdgeInsets.only(top: 24.0),
                         child: _buildResultSection(),
                       ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // HELPER METHODS

  Widget _buildSavedWorkersCarousel() {
    return SizedBox(
      height: 72,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _workers.length,
        itemBuilder: (context, index) {
          final w = _workers[index];
          final isSelected = _selectedWorkerId == w.id;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
               onTap: () => _showWorkerOptions(w),
               child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                     color: isSelected ? kNeonGold.withOpacity(0.2) : const Color(0xFF151C2B),
                     borderRadius: BorderRadius.circular(20),
                     border: Border.all(color: isSelected ? kNeonGold : Colors.white10),
                  ),
                  child: Center(child: Text(w.name, style: TextStyle(color: isSelected ? kNeonGold : Colors.white70))),
               )
            )
          );
        },
      ),
    );
  }

  Widget _buildResultSection() {
     return NeonCard(
       key: _resultsKey, 
       borderColor: kNeonGreen,
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
            Text('Resultado de Planilla', style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildRow('Salario Base Periodo', _result!.baseIncome),
            if (_result!.vacationPayment > 0)
              _buildRow('Pago de Vacaciones', _result!.vacationPayment, color: Colors.cyanAccent),
            
            // INCOME BREAKDOWN
            if (_result!.pagoExtras > 0)
              _buildRow('Horas Extras', _result!.pagoExtras),
            if (_result!.sundayAmount > 0)
              _buildRow('Dominical', _result!.sundayAmount),
            if (_result!.holidayAmount > 0)
              _buildRow('Feriado', _result!.holidayAmount),
            if (_result!.nightSurchargeAmount > 0)
              _buildRow('Recargo Nocturno', _result!.nightSurchargeAmount),
            if (_result!.commissionsAmount > 0)
              _buildRow('Comisiones', _result!.commissionsAmount),
            if (_result!.bonusesAmount > 0)
              _buildRow('Bonificaciones', _result!.bonusesAmount),
            if (_result!.otherIncomeAmount > 0)
              _buildRow('Otros Ingresos', _result!.otherIncomeAmount),

            const Divider(color: Colors.white10),
            _buildRow('TOTAL DEVENGADO', _result!.totalDevengado, isBold: true, color: Colors.greenAccent),
            const Divider(color: Colors.white10),
            _buildRow('Seguro Social (9.75%)', _result!.css, isNegative: true),
            _buildRow('Seguro Educativo (1.25%)', _result!.se, isNegative: true),
            if (_result!.isr > 0)
              _buildRow('Impuesto s/Renta (ISR)', _result!.isr, isNegative: true),
            
            // CUSTOM DEDUCTIONS (Detailed)
            if (_result!.customDeductions.isNotEmpty)
              ..._result!.customDeductions.map((ded) => 
                _buildRow(ded['name'] ?? 'Deducción', (ded['amount'] as num).toDouble(), isNegative: true)),
            
            if (_result!.otherDeductions > 0 && _result!.customDeductions.isEmpty)
              _buildRow('Otras Deducciones', _result!.otherDeductions, isNegative: true),

            const Divider(color: Colors.white10),
            _buildRow('TOTAL DEDUCCIONES', _result!.totalDeducciones, isBold: true, isNegative: true),
            const Divider(color: Colors.white24),
            _buildRow('SALARIO NETO', _result!.netSalary, isBold: true, color: Colors.white, fontSize: 18),
            const SizedBox(height: 12),
             NeonSwitch(
              value: _showProvisions,
              onChanged: (v) {
                setState(() => _showProvisions = v);
                if (v) _scrollTo(_provisionsKey);
              },
              label: 'Ver Provisiones (Estimadas)',
            ),
            if (_showProvisions) 
              Container(
                key: _provisionsKey,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8)),
                child: Column(
                  children: [
                     _buildRow('XIII Mes', _result!.decimoTercerMes),
                     _buildRow('Vacaciones', _result!.vacaciones),
                     _buildRow('Prima Antigüedad', _result!.primaAntiguedad),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: NeonButton(text: 'Ver Comprobante', primary: true, onTap: _navigateToPreview)),
              ],
            ),
         ],
       ),
    );
  }
  
  void _navigateToPreview() {
    if (_result == null) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => ComprobantePlanillaScreen(input: _input, result: _result!)));
  }

  Widget _buildRow(String label, double amount, {bool isBold = false, bool isNegative = false, Color? color, double? fontSize}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.outfit(color: Colors.white70, fontSize: fontSize ?? 13, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(
            '\$${amount.toStringAsFixed(2)}', 
            style: GoogleFonts.outfit(
              color: color ?? (isNegative ? Colors.redAccent : (isBold ? Colors.white : kNeonGreen)), 
              fontSize: fontSize ?? (isBold ? 15 : 13), 
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal
            )
          ),
        ],
      ),
    );
  }

  void _calculate() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Complete los campos obligatorios'), backgroundColor: Colors.redAccent));
       return;
    }
    setState(() => _isLoading = true);
    try {
      _input.customDeductions = List<Map<String, dynamic>>.from(_customDeductions);
      final res = SalarioLogic.calculate(_input);
      setState(() {
        _result = res;
        _isLoading = false;
        // Mark this worker as calculated
        if (_selectedWorkerId != null) {
          _calculatedWorkers[_selectedWorkerId!] = DateTime.now();
        }
      });
      
      // Update vacation stats in input for result mapping
      _input.vacationDays = _includeVacationPay ? _detectedVacationDays : 0;
      _input.vacationAmount = _includeVacationPay ? _detectedVacationAmount : 0.0;
      
      // === AUTO-SAVE TO PAYROLL HISTORY ===
      // Save the calculated result to worker's payrollHistory
      if (_selectedWorkerId != null) {
        final worker = _workers.firstWhere((w) => w.id == _selectedWorkerId);
        final now = DateTime.now();
        final periodLabel = '${DateFormat('dd/MM').format(_input.periodStart)} - ${DateFormat('dd/MM/yyyy').format(_input.periodEnd)}';
        final periodKey = '${_input.periodStart.year}-${_input.periodStart.month.toString().padLeft(2, '0')}';
        
        final record = PayrollRecord(
          id: 'pr_${now.millisecondsSinceEpoch}',
          periodKey: periodKey,
          periodLabel: periodLabel,
          createdAt: now,
          updatedAt: now,
          inputSnapshot: {
            'periodStart': _input.periodStart.toIso8601String(),
            'periodEnd': _input.periodEnd.toIso8601String(),
            'baseSalary': _input.baseSalary,
            'frequency': _input.frequency.index,
          },
          resultSnapshot: {
            'totalDevengado': res.totalDevengado,
            'totalDeducciones': res.totalDeducciones,
            'netSalary': res.netSalary,
          },
        );
        worker.payrollHistory.add(record);
        await _workerService.saveWorker(worker);
        debugPrint('✅ PayrollRecord guardado en historial: ${worker.name}');
      }
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
         if (_resultsKey.currentContext != null) Scrollable.ensureVisible(_resultsKey.currentContext!);
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _saveWorker() async {
    if (_input.workerName.isEmpty) return;
    
    // Create new worker or update existing
    final newWorker = WorkerProfile(
      id: _selectedWorkerId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _input.workerName,
      position: _input.position,
      department: _input.companyName,
      paymentMode: _input.frequency,
      basePayment: _input.baseSalary,
    );

    // Save Payroll Record (Only if result exists)
    if (_result != null) {
      final record = PayrollRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        periodKey: DateFormat('yyyy-MM').format(DateTime.now()),
        periodLabel: DateFormat('MMM yyyy').format(DateTime.now()),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        inputSnapshot: _input.toJson(),
        resultSnapshot: _result!.toJson(),
      );
      newWorker.payrollHistory.add(record);
    }

    // Save and Reload
    await _workerService.saveWorker(newWorker);
    _loadWorkers();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Trabajador Guardado')));
  }

  void _showAddDeductionDialog() {
    final nameCtrl = TextEditingController();
    final amtCtrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => NeonDialog(
       title: 'Nueva Deducción',
       content: Column(mainAxisSize: MainAxisSize.min, children: [
          NeonInput(label: 'Nombre', controller: nameCtrl),
          NeonInput(label: 'Monto', controller: amtCtrl, isNumber: true),
       ]),
       actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar', style: TextStyle(color: Colors.white54))),
          TextButton(onPressed: () {
             final val = double.tryParse(amtCtrl.text) ?? 0;
             if (nameCtrl.text.isNotEmpty && val > 0) {
                setState(() {
                  _customDeductions.add({'name': nameCtrl.text, 'amount': val});
                  _updateTotalDeductions();
                });
                Navigator.pop(ctx);
             }
          }, child: const Text('Agregar', style: TextStyle(color: kNeonGreen))),
       ],
    ));
  }
  
  void _updateTotalDeductions() {
    _input.otherDeductions = _customDeductions.fold(0.0, (sum, d) => sum + (d['amount'] ?? 0.0));
  }
  
  void _scrollTo(GlobalKey key) {
     if (key.currentContext != null) Scrollable.ensureVisible(key.currentContext!, duration: const Duration(milliseconds: 500));
  }

  // HELPER METHODS CONTINUED
  String _getInitials(String name) {
    name = name.trim();
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }

  void _showWorkerOptions(WorkerProfile w) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF001225),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             ListTile(
               leading: const Icon(Icons.edit, color: kNeonBlue),
               title: const Text('Cargar Datos', style: TextStyle(color: Colors.white)),
               onTap: () { Navigator.pop(ctx); _selectWorker(w); }
             ),
             ListTile(
               leading: const Icon(Icons.folder_open, color: kNeonGreen),
               title: const Text('Ver Detalle', style: TextStyle(color: Colors.white)),
               onTap: () { Navigator.pop(ctx); Navigator.push(context, MaterialPageRoute(builder: (_) => WorkerDetailScreen(worker: w, onUpdate: () => _loadWorkers()))); } 
             ),
             ListTile(
               leading: const Icon(Icons.delete, color: Colors.redAccent),
               title: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
               onTap: () { 
                 Navigator.pop(ctx); 
                 // Simple delete logic
                 setState(() { _workers.removeWhere((x) => x.id == w.id); }); 
                 _workerService.saveWorker(w); // Wait, delete logic needed in service?
               } 
             ),
          ]
        )
      )
    );
  }
}

