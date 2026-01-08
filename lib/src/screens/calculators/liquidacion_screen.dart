import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:proyecto_empoderate/src/components/business_hero_header.dart';
import 'package:proyecto_empoderate/src/screens/human_resources/hr_dashboard_widgets.dart';
import '../../components/neon_widgets.dart';
import '../../components/calculator_info_panel.dart';
import '../../calculators/liquidacion_models.dart';
import '../../calculators/liquidacion_logic.dart';
// import '../../calculators/vacation_eligibility_service.dart'; // Removed
import '../../services/worker_service.dart';
import '../../calculators/salario_models.dart'; // For WorkerProfile
import '../../features/payroll/domain/payroll_record.dart'; // For PayrollRecord
import '../../services/vacation_eligibility_service.dart';
import '../../features/hr_archive/models/hr_central_record.dart';
import '../../features/hr_archive/services/hr_archive_service.dart';

// Additional imports for navigation/preview
import 'carta_preview_screen.dart';
import 'comprobante_liquidacion_screen.dart';
// Note: Ensure these imports exist. If not, paths might need adjustment.

class LiquidacionScreen extends StatefulWidget {
  static const routeName = '/liquidacion';
  
  final WorkerProfile? worker; // Optional: Pre-fill from directory
  final String? workerId;      // NEW: For deep link support

  const LiquidacionScreen({Key? key, this.worker, this.workerId}) : super(key: key);

  @override
  _LiquidacionScreenState createState() => _LiquidacionScreenState();
}

class _LiquidacionScreenState extends State<LiquidacionScreen> {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _resultsKey = GlobalKey(); // Key for auto-scroll to results

  final LiquidacionInputModel _input = LiquidacionInputModel(
    startDate: DateTime.now().subtract(const Duration(days: 365)),
    endDate: DateTime.now(),
  );

  LiquidacionResultModel? _result;
  bool _isLoading = false;
  bool _isLoadingWorker = false; // NEW: Loading state for worker fetch
  
  // History Mode State
  bool _isLoadingFromWorker = false;
  bool _useHistoryMode = false;
  DateTime _historyStart = DateTime.now().subtract(const Duration(days: 365 * 5)); // 5 years default search
  DateTime _historyEnd = DateTime.now();
  int _historyRecordsFound = 0;
  
  final VacationEligibilityService _vacationService = VacationEligibilityService();
  
  // Controllers for reactive updates
  late TextEditingController _nameCtrl;
  late TextEditingController _idCtrl;
  late TextEditingController _salaryCtrl;
  late TextEditingController _vencidosCtrl;
  late TextEditingController _accumulatedVacationsCtrl;
  late TextEditingController _accumulatedDecimoCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: _input.workerName);
    _idCtrl = TextEditingController(text: _input.workerId);
    _salaryCtrl = TextEditingController(text: _input.salary > 0 ? _input.salary.toString() : '');
    _vencidosCtrl = TextEditingController(text: _input.vacacionesExpiredDays.toString());
    _accumulatedVacationsCtrl = TextEditingController(text: _input.accumulatedIncomeVacations.toString());
    _accumulatedDecimoCtrl = TextEditingController(text: _input.accumulatedIncomeDecimo.toString());

    // Deep link support: load worker by ID if only workerId is provided
    if (widget.worker != null) {
      _loadFromWorker(widget.worker!);
    } else if (widget.workerId != null && widget.workerId!.isNotEmpty) {
      _loadWorkerById(widget.workerId!);
    }
  }
  
  /// NEW: Load worker from storage by ID (for deep link support)
  Future<void> _loadWorkerById(String workerId) async {
    setState(() => _isLoadingWorker = true);
    try {
      final worker = await WorkerService().getWorkerById(workerId);
      if (worker != null && mounted) {
        _loadFromWorker(worker);
      }
    } finally {
      if (mounted) setState(() => _isLoadingWorker = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _idCtrl.dispose();
    _salaryCtrl.dispose();
    _vencidosCtrl.dispose();
    _accumulatedVacationsCtrl.dispose();
    _accumulatedDecimoCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadFromWorker(WorkerProfile w) {
    setState(() {
      // === BASIC WORKER INFO ===
      _input.workerName = w.name;
      _input.workerId = w.cedula ?? '';
      _input.department = w.department;
      _input.position = w.position;
      _input.notes = w.notes;
      
      // === SALARY INFO ===
      _input.salary = w.basePayment;
      
      // Map PayrollFrequency to PaymentFrequency
      _input.paymentFrequency = PaymentFrequency.values.firstWhere(
          (e) => e.index == w.paymentMode.index, 
          orElse: () => PaymentFrequency.quincenal
      );
      
      // If hourly payment, set hourly rate
      if (w.paymentType == PaymentType.hourly && w.hourlyRate != null) {
        _input.hourlyRate = w.hourlyRate;
        _input.hoursPerDay = 8.0; // Default
        _input.daysPerWeek = 6.0; // Panama standard
      }
      
      // === CONTRACT INFO ===
      _input.startDate = w.startDate ?? DateTime.now().subtract(const Duration(days: 365));
      // Map WorkerContractType to ContractType
      _input.contractType = ContractType.values.firstWhere(
          (e) => e.index == w.contractType.index, 
          orElse: () => ContractType.indefinido
      );
      
      // === UPDATE CONTROLLERS ===
      _nameCtrl.text = w.name;
      _idCtrl.text = w.cedula ?? '';
      _salaryCtrl.text = w.basePayment.toStringAsFixed(2);
      
      // === HISTORICAL EARNINGS (from payroll history) ===
      if (w.payrollHistory.isNotEmpty) {
        _useHistoryMode = true;
        
        // Set date range from history
        final dates = w.payrollHistory.map((e) => e.periodEnd).toList(); 
        if (dates.isNotEmpty) {
           dates.sort();
           _historyStart = dates.first;
           _historyEnd = dates.last;
        }
        
        // Calculate total historical earnings from payroll records
        double totalHistoric = 0.0;
        for (var rec in w.payrollHistory) {
          totalHistoric += rec.grossSalary;
        }
        _input.totalHistoricEarnings = totalHistoric;
        
        // Also populate salary history for bitacora
        _input.salaryHistory = w.payrollHistory.map((rec) => SalaryHistoryEntry(
          year: rec.periodEnd.year,
          month: rec.periodEnd.month,
          amount: rec.grossSalary,
          includedInCalculation: true,
          periodLabel: rec.periodLabel,
        )).toList();
        
        // Calculate accumulated income for vacations (last 11 months of earnings)
        final elevenMonthsAgo = DateTime.now().subtract(const Duration(days: 335));
        final recentRecords = w.payrollHistory.where((r) => r.periodEnd.isAfter(elevenMonthsAgo)).toList();
        _input.accumulatedIncomeVacations = recentRecords.fold(0.0, (sum, r) => sum + r.grossSalary);
        
        // Calculate accumulated income for decimo (current period)
        // Find last decimo payment date
        DateTime lastDecimoDate = _getLastDecimoPaymentDate(DateTime.now());
        final decimoRecords = w.payrollHistory.where((r) => r.periodEnd.isAfter(lastDecimoDate)).toList();
        _input.accumulatedIncomeDecimo = decimoRecords.fold(0.0, (sum, r) => sum + r.grossSalary);
      }
    });

    // Analyze specific histories (Vacations, Decimo) - currently empty but kept for future enhancements
    _analyzeSpecificHistories(w);
  }
  
  DateTime _getLastDecimoPaymentDate(DateTime refDate) {
    // Decimo is paid on April 15, August 15, December 15
    DateTime cutoff1 = DateTime(refDate.year, 4, 15);
    DateTime cutoff2 = DateTime(refDate.year, 8, 15);
    DateTime cutoff3 = DateTime(refDate.year, 12, 15);
    
    if (refDate.isAfter(cutoff3)) return cutoff3;
    else if (refDate.isAfter(cutoff2)) return cutoff2;
    else if (refDate.isAfter(cutoff1)) return cutoff1;
    else return DateTime(refDate.year - 1, 12, 15);
  }


  void _analyzeSpecificHistories(WorkerProfile w) {
    // 1. ANALYZE VACATIONS BALANCE
    // Calculate actual pending vacation days (earned - taken)
    final pendingDays = _vacationService.getTotalPendingDays(w);
    
    setState(() {
      if (pendingDays > 0) {
        _input.hasVacationsExpired = true;
        _input.vacacionesExpiredDays = pendingDays;
        _vencidosCtrl.text = pendingDays.toString();
      }
      
      // Update accumulated controllers with calculated values
      if (_input.accumulatedIncomeVacations > 0) {
        _accumulatedVacationsCtrl.text = _input.accumulatedIncomeVacations.toStringAsFixed(2);
      }
      if (_input.accumulatedIncomeDecimo > 0) {
        _accumulatedDecimoCtrl.text = _input.accumulatedIncomeDecimo.toStringAsFixed(2);
      }
    });
  }


  Future<void> _refreshFullHistory() async {
     if (widget.worker == null) return;
     // Basic refresh logic placeholder
  }

 void _recalculateFromHistory() {
    if (widget.worker == null || widget.worker!.payrollHistory.isEmpty) return;
    
    // Simple recalculation: Sum all valid records in date range
    final historyInRange = widget.worker!.payrollHistory.where((r) {
       // Check if record date is within _historyStart and _historyEnd
       // Assuming record has 'date' or 'periodEnd'. Using periodEnd for safety.
       return r.periodEnd.isAfter(_historyStart.subtract(const Duration(days: 1))) && 
              r.periodEnd.isBefore(_historyEnd.add(const Duration(days: 1)));
    }).toList();
    
    setState(() {
      _historyRecordsFound = historyInRange.length;
      if (historyInRange.isEmpty) return;
      
      double totalGross = 0;
      for (var rec in historyInRange) {
        totalGross += rec.grossSalary;
      }
      
      // Update Inputs
      _input.totalHistoricEarnings = totalGross;
      // _input.totalHistoricEarningsFromHistory = totalGross; // Tracking logic - Removed setter logic, using field.
      
      // Populate history list for bitacora
      _input.salaryHistory = historyInRange.map((rec) => SalaryHistoryEntry(
         year: rec.periodEnd.year,
         month: rec.periodEnd.month,
         amount: rec.grossSalary,
         includedInCalculation: true,
         periodLabel: rec.periodLabel ?? DateFormat('MMM yyyy').format(rec.periodEnd)
      )).toList();
    });
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
                 title: 'Calculadora de Liquidación',
                 categoryName: 'RECURSOS HUMANOS',
                 icon: Icons.handshake,
                 onBackPressed: () => context.pop(),
               ),
               
               Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 24),
                 child: Column(
                   children: [
                     const CalculatorInfoPanel(configId: 'liquidacion'),
                     const SizedBox(height: 16),

                     // 2. DASHBOARD
                     if (_result != null)
                        Column(
                          children: [
                             LiquidacionDashboard(
                               totalLiquidacion: _result!.totalPagar,
                               prestaciones: _result!.primaAntiguedad + _result!.indemnizacion,
                               derechos: _result!.vacacionesVencidas + _result!.vacacionesProporcionales + _result!.decimoProporcional,
                             ),
                             const SizedBox(height: 24),
                          ],
                        ),
                     
                     // 3. INPUTS
                     
                     // DATOS GENERALES
                     HrGlassContainer(
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                            Text('📋 Datos Generales', style: GoogleFonts.outfit(color: kNeonGreen, fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                             NeonInput(label: 'Nombre del Trabajador', controller: _nameCtrl, onChanged: (v) => _input.workerName = v, required: true),
                             NeonInput(label: 'Cédula', controller: _idCtrl, onChanged: (v) => _input.workerId = v, required: true),
                            const SizedBox(height: 16),
                            NeonInput(label: 'Departamento (Opcional)', onChanged: (v) => _input.department = v, initialValue: _input.department),
                            NeonInput(label: 'Notas (Opcional)', onChanged: (v) => _input.notes = v, initialValue: _input.notes, maxLines: 2),
                            const SizedBox(height: 16),
                            
                            // Contract Type
                            NeonDropdown<ContractType>(
                              label: 'Tipo de Contrato',
                              value: _input.contractType,
                              items: ContractType.values.map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.toString().split('.').last.toUpperCase(), style: const TextStyle(color: Colors.white)),
                              )).toList(),
                              onChanged: (v) => setState(() => _input.contractType = v!),
                            ),
                         ],
                       ),
                     ),
                     
                     const SizedBox(height: 12),

                     // HORAS LABORALES
                     HrGlassContainer(
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                            Text('⏰ Horas Laborales', style: GoogleFonts.outfit(color: kNeonBlue, fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            NeonInput(label: 'Horas por Día', isNumber: true, initialValue: _input.hoursPerDay.toString(), onChanged: (v) => _input.hoursPerDay = double.tryParse(v) ?? 8),
                            NeonInput(label: 'Días por Semana', isNumber: true, initialValue: _input.daysPerWeek.toString(), onChanged: (v) => _input.daysPerWeek = double.tryParse(v) ?? 6),
                         ],
                       ),
                     ),
                     
                     const SizedBox(height: 12),
                     
                     // SALARIOS
                     HrGlassContainer(
                        child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                              Text('💵 Salario Base', style: GoogleFonts.outfit(color: kNeonGold, fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                               NeonInput(label: 'Salario Base (\$)', controller: _salaryCtrl, isNumber: true, onChanged: (v) => _input.salary = double.tryParse(v) ?? 0, required: true),
                              const SizedBox(height: 16),
                              NeonDropdown<PaymentFrequency>(
                                label: 'Frecuencia de Pago',
                                value: _input.paymentFrequency,
                                items: PaymentFrequency.values.map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e.toString().split('.').last.toUpperCase(), style: const TextStyle(color: Colors.white)),
                                )).toList(),
                                onChanged: (v) => setState(() => _input.paymentFrequency = v!),
                              ),
                           ],
                        )
                     ),
                     
                     const SizedBox(height: 12),
                     
                     // DATOS LABORALES (FECHAS)
                     HrGlassContainer(
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                            Text('📅 Fechas Laborales', style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            NeonDateSelector(
                              label: 'Fecha de Inicio',
                              date: _input.startDate,
                              onSelect: (d) => setState(() => _input.startDate = d),
                            ),
                            const SizedBox(height: 12),
                            NeonDateSelector(
                              label: 'Fecha de Salida',
                              date: _input.endDate,
                              onSelect: (d) => setState(() => _input.endDate = d),
                            ),
                            const SizedBox(height: 16),
                            NeonDropdown<TerminationType>(
                               label: 'Motivo de Salida',
                               value: _input.terminationType,
                               items: TerminationType.values.map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e.toString().split('.').last.replaceAll('_', ' ').toUpperCase(), style: const TextStyle(color: Colors.white)),
                               )).toList(),
                               onChanged: (v) => setState(() => _input.terminationType = v!),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 12),

                      // BASE DE CÁLCULO
                      HrGlassContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Text('💰 Base de Cálculo', style: GoogleFonts.outfit(color: kNeonGold, fontSize: 18, fontWeight: FontWeight.bold)),
                             const SizedBox(height: 16),
                             if (_useHistoryMode)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Text('✅ Usando historial de nómina detectado.', style: GoogleFonts.outfit(color: kNeonGreen, fontSize: 12)),
                                ),

                             NeonSwitch(
                               label: '¿Se dió Preaviso?',
                               value: _input.gavePreaviso,
                               onChanged: (v) => setState(() => _input.gavePreaviso = v),
                             ),
                             
                             const Divider(color: Colors.white12),
                             
                             NeonSwitch(
                               label: '¿Vacaciones Vencidas?',
                               value: _input.hasVacationsExpired,
                               onChanged: (v) => setState(() => _input.hasVacationsExpired = v),
                             ),

                             if (_input.hasVacationsExpired)
                                 NeonInput(label: 'Días Vencidos', controller: _vencidosCtrl, isNumber: true, onChanged: (v) => _input.vacacionesExpiredDays = int.tryParse(v) ?? 0),

                             const SizedBox(height: 16), 
                             NeonInput(label: 'Acumulado Vacaciones (\$)', controller: _accumulatedVacationsCtrl, isNumber: true, onChanged: (v) => _input.accumulatedIncomeVacations = double.tryParse(v) ?? 0),
                             NeonInput(label: 'Acumulado Décimo (\$)', controller: _accumulatedDecimoCtrl, isNumber: true, onChanged: (v) => _input.accumulatedIncomeDecimo = double.tryParse(v) ?? 0),
                             NeonInput(label: 'Total Ganado Histórico (Prima) (\$)', isNumber: true, onChanged: (v) => _input.totalHistoricEarnings = double.tryParse(v) ?? 0, initialValue: _input.totalHistoricEarnings > 0 ? _input.totalHistoricEarnings.toStringAsFixed(2) : ''),
                             
                             const SizedBox(height: 12),
                             ExpansionTile(
                               title: Text('Ver Bitácora de Salarios', style: GoogleFonts.outfit(color: Colors.white60, fontSize: 13)),
                               collapsedIconColor: kNeonGold,
                               iconColor: kNeonGold,
                               children: [ _buildSalaryHistoryLog() ],
                             )
                          ],
                        )
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // DEDUCCIONES
                      HrGlassContainer( 
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Text('📉 Deducciones', style: GoogleFonts.outfit(color: kNeonPink, fontSize: 18, fontWeight: FontWeight.bold)),
                             const SizedBox(height: 16),
                             NeonInput(label: 'Préstamos (\$)', isNumber: true, onChanged: (v) => _input.loans = double.tryParse(v) ?? 0, initialValue: _input.loans > 0 ? _input.loans.toString() : ''),
                             NeonInput(label: 'Otros (\$)', isNumber: true, onChanged: (v) => _input.otherDeductions = double.tryParse(v) ?? 0, initialValue: _input.otherDeductions > 0 ? _input.otherDeductions.toString() : ''),
                          ],
                        )
                      ),

                      const SizedBox(height: 32),
                      
                      // CALCULAT BUTTON
                      NeonButton(
                        text: 'CALCULAR LIQUIDACIÓN',
                        primary: true,
                        onTap: _calculateLiquidacion,
                        color: kNeonCyan,
                        textColor: Colors.white,
                        icon: Icons.calculate,
                        isLoading: _isLoading,
                      ),
                      
                      const SizedBox(height: 12),
                      
                      NeonButton(
                        text: '📁 Ver Archivo HR',
                        primary: false,
                        onTap: () => context.push('/hr_archive'),
                        color: const Color(0xFFF4D35E).withOpacity(0.2),
                        textColor: const Color(0xFFF4D35E),
                        icon: Icons.folder_open,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // INLINE RESULTS
                      if (_result != null)
                        _buildInlineResults(),
                        
                      const SizedBox(height: 50),
                   ],
                 ),
               ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildInlineResults() {
    return Column(
      children: [
         _buildResultCard('Derechos Adquiridos', [
             _buildResultRow('Vacaciones', _result!.vacacionesVencidas + _result!.vacacionesProporcionales),
             _buildResultRow('Décimo Tercer Mes', _result!.decimoProporcional),
             _buildResultRow('Prima de Antigüedad', _result!.primaAntiguedad),
         ], kNeonGreen),
         const SizedBox(height: 16),
         _buildResultCard('Indemnización', [
             _buildResultRow('Indemnización', _result!.indemnizacion),
             if (_result!.preaviso > 0) _buildResultRow('Preaviso', _result!.preaviso),
         ], Colors.orangeAccent),
         const SizedBox(height: 24),
         NeonButton(
           text: 'Ver Carta / Comprobante',
           icon: Icons.description,
           color: Colors.white10,
           textColor: Colors.white,
           onTap: () {
               Navigator.push(context, MaterialPageRoute(builder: (_) => ComprobanteLiquidacionScreen(
                 result: _result!,
                 input: _input,
               )));
           },
           primary: false,
         )
      ],
    );
  }

  Widget _buildResultCard(String title, List<Widget> children, Color color) {
    return HrGlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.outfit(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(color: Colors.white12, height: 20),
          ...children
        ],
      )
    );
  }
  
  Widget _buildResultRow(String label, double val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.outfit(color: Colors.white70)),
          Text(NumberFormat.currency(symbol: 'B/. ').format(val), style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSalaryHistoryLog() {
    return Column(
      children: _input.salaryHistory.map((entry) => ListTile(
         dense: true,
         title: Text('${entry.month}/${entry.year}', style: const TextStyle(color: Colors.white)),
         trailing: Text('\$${entry.amount.toStringAsFixed(2)}', style: const TextStyle(color: kNeonGold)),
      )).toList(),
    );
  }

  void _calculateLiquidacion() async {
     if (!_formKey.currentState!.validate()) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor complete los campos requeridos'), backgroundColor: Colors.redAccent));
        return;
     }
     
     setState(() {
        _isLoading = true;
        _result = LiquidacionLogic.calculate(_input);
        _isLoading = false;
        
        // Auto-scroll logic
        WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
        });
     });
     
     // === AUTO-SAVE TO HR ARCHIVE ===
     if (_result != null) {
       final record = HRCentralRecord(
         workerId: widget.worker?.id ?? 'manual',
         workerName: _input.workerName,
         type: _input.terminationType == TerminationType.despidoJustificado 
             ? HRRecordType.despido 
             : (_input.terminationType == TerminationType.renunciaVoluntaria 
                 ? HRRecordType.renuncia 
                 : HRRecordType.liquidacion),
         eventDate: _input.endDate,
         description: '${_input.terminationType.name} - ${DateFormat('dd/MM/yyyy').format(_input.startDate)} al ${DateFormat('dd/MM/yyyy').format(_input.endDate)}',
         amount: _result!.totalPagar,
         data: {
           'salarioMensual': _input.salary,
           'diasTrabajados': _result!.daysWorked,
           'vacaciones': _result!.vacacionesProporcionales,
           'decimo': _result!.decimoProporcional,
           'prima': _result!.primaAntiguedad,
           'indemnizacion': _result!.indemnizacion,
         },
       );
       await HRArchiveService().add(record);
       debugPrint('✅ Liquidación guardada en Archivo HR: ${_input.workerName}');
     }
  }
}
