import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../components/premium_scaffold.dart';
import '../../components/neon_widgets.dart';
import '../../calculators/salario_models.dart';
import '../../calculators/salario_logic.dart';
import '../../calculators/pa_recargo_rules.dart'; // Import DiaTipo
import '../../features/payroll/domain/payroll_record.dart';
import '../../calculators/shift_models.dart'; // Import ShiftRecord
import '../../services/worker_service.dart';

class PayrollBatchScreen extends StatefulWidget {
  final List<WorkerProfile> selectedWorkers;

  const PayrollBatchScreen({Key? key, required this.selectedWorkers}) : super(key: key);

  @override
  _PayrollBatchScreenState createState() => _PayrollBatchScreenState();
}

class _PayrollBatchScreenState extends State<PayrollBatchScreen> {
  // Global Settings
  PayrollFrequency _frequency = PayrollFrequency.quincenal;
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  int _selectedQuincena = 1;

  // Worker Specifics (Days/Hours worked overrides could go here, but for V1 we assume full time)
  bool _isProcessing = false;
  Map<String, double> _results = {}; // WorkerID -> NetSalary

  Future<void> _processBatch() async {
    setState(() => _isProcessing = true);

    // 1. Generate Period Logic
    DateTime periodStart;
    DateTime periodEnd;
    String periodLabel;
    String periodKey;

    if (_frequency == PayrollFrequency.mensual) {
      periodStart = DateTime(_selectedYear, _selectedMonth, 1);
      final lastDay = DateTime(_selectedYear, _selectedMonth + 1, 0).day;
      periodEnd = DateTime(_selectedYear, _selectedMonth, lastDay);
      periodLabel = '${DateFormat('MMMM yyyy', 'es').format(periodStart)}';
      periodKey = '${_selectedYear}-${_selectedMonth.toString().padLeft(2, '0')}';
    } else {
      // Quincena
      if (_selectedQuincena == 1) {
        periodStart = DateTime(_selectedYear, _selectedMonth, 1);
        periodEnd = DateTime(_selectedYear, _selectedMonth, 15);
        periodLabel = '1ra Quincena ${DateFormat('MMM yyyy', 'es').format(periodStart)}';
        periodKey = '${_selectedYear}-${_selectedMonth.toString().padLeft(2, '0')}-Q1';
      } else {
        periodStart = DateTime(_selectedYear, _selectedMonth, 16);
        final lastDay = DateTime(_selectedYear, _selectedMonth + 1, 0).day;
        periodEnd = DateTime(_selectedYear, _selectedMonth, lastDay);
        periodLabel = '2da Quincena ${DateFormat('MMM yyyy', 'es').format(periodStart)}';
        periodKey = '${_selectedYear}-${_selectedMonth.toString().padLeft(2, '0')}-Q2';
      }
    }

    // 2. Loop Workers
    for (var worker in widget.selectedWorkers) {
      double calcBase = worker.basePayment;
      double? explicitRate;
      
      // Calculate derived/assumed base for period if Base Salary
      if (worker.paymentType == PaymentType.base) {
        if (worker.paymentMode == PayrollFrequency.mensual && _frequency == PayrollFrequency.quincenal) {
          calcBase = worker.basePayment / 2;
        }
      } else {
        // Hourly Worker: Base is 0, we use hours
        calcBase = 0;
        explicitRate = worker.hourlyRate ?? 0;
      }
      
      // FETCH REAL SHIFTS for this worker in this period
      final periodShifts = _getShiftsForPeriod(worker, periodStart, periodEnd);
      
      // Sum Hours from Real Data
      double totalRegular = 0;
      double totalExtraDiu = 0;
      double totalExtraNoc = 0;
      double totalExtraMix = 0;
      double totalHolidayAmt = 0;
      double totalSundayAmt = 0;

      for (var s in periodShifts) {
         totalRegular += s.regularHours;
         totalExtraDiu += s.extraDiurna;
         totalExtraNoc += s.extraNocturna;
         totalExtraMix += s.extraMixta;
         // TODO: Add Holiday/Sunday amount logic if needed, or pass hours if model supports
      }

      // If no shifts found but user is Salaried, we assume standard week (optional: could warn)
      // For V1 Real Data: We pass the found hours.
      
      final input = SalarioInputModel(
        workerName: worker.name,
        position: worker.position,
        periodStart: periodStart,
        periodEnd: periodEnd,
        baseSalary: calcBase,
        explicitHourlyRate: explicitRate,
        frequency: _frequency,
        workHoursPerDay: 8,
        diaTipo: DiaTipo.normal,
        // Real Data Injection
        horasDiurnasOrd: (worker.paymentType == PaymentType.hourly) ? totalRegular : 0, 
        // For Base workers, regular hours are covered by baseSalary usually. 
        // Only set proper hours if Hourly.
        
        horasExtraDiurna: totalExtraDiu,
        horasExtraNocturna: totalExtraNoc,
        horasExtraMixtaNocturna: totalExtraMix,
      );

      final result = SalarioLogic.calculate(input);

      // 3. Save Record
      final record = PayrollRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString() + worker.id,
        periodKey: periodKey,
        periodLabel: periodLabel,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        inputSnapshot: input.toJson(),
        resultSnapshot: result.toJson(),
        notes: 'Generado desde Planilla Masiva (${periodShifts.length} turnos encontrados)',
      );

      // Update Worker
      // We need to fetch fresh in case it changed? No, we have the object.
      // But to save, we need to add to list.
      // Copy existing history
      List<PayrollRecord> newHistory = List.from(worker.payrollHistory);
      
      // Check overwrite
      final existingIndex = newHistory.indexWhere((r) => r.periodKey == periodKey);
      if (existingIndex != -1) {
        newHistory[existingIndex] = record;
      } else {
        newHistory.add(record);
       // Sort by periodKey desc
        newHistory.sort((a, b) => b.periodKey.compareTo(a.periodKey));
      }

      final updatedWorker = WorkerProfile(
        id: worker.id,
        name: worker.name,
        cedula: worker.cedula,
        position: worker.position,
        department: worker.department,
        basePayment: worker.basePayment,
        paymentMode: worker.paymentMode, // Keep original preference
        contractType: worker.contractType,
        startDate: worker.startDate,
        notes: worker.notes,
        lastCalcTotal: result.netSalary,
        lastCalcDate: DateTime.now(),
        payrollHistory: newHistory,
      );

      await WorkerService().saveWorker(updatedWorker);
      _results[worker.id] = result.netSalary;
    }

    setState(() => _isProcessing = false);
    
    // Show Summary Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F1520),
        title: Text('Planilla Generada', style: GoogleFonts.outfit(color: Colors.white)),
        content: Text('Se ha procesado el pago para ${widget.selectedWorkers.length} colaboradores.', style: GoogleFonts.outfit(color: Colors.white70)),
        actions: [
          TextButton(
            child: const Text('Cerrar'),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context); // Go back to directory
            },
          )
        ],
      ),
    );
  }

  List<ShiftRecord> _getShiftsForPeriod(WorkerProfile worker, DateTime start, DateTime end) {
    List<ShiftRecord> foundShifts = [];
    // Normalize range to end of day
    final rangeStart = DateTime(start.year, start.month, start.day);
    final rangeEnd = DateTime(end.year, end.month, end.day, 23, 59, 59);

    for (var period in worker.shiftPeriods) {
       for (var shift in period.shifts) {
         if (shift.date.isAfter(rangeStart.subtract(const Duration(seconds: 1))) && 
             shift.date.isBefore(rangeEnd.add(const Duration(seconds: 1)))) {
           foundShifts.add(shift);
         }
       }
    }
    return foundShifts;
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Generar Planilla Masiva',
      subtitle: '${widget.selectedWorkers.length} colaboradores seleccionados',
      showBackButton: true,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Period Configuration
            NeonCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text('Configuración del Periodo', style: GoogleFonts.outfit(color: const Color(0xFF00E5FF), fontWeight: FontWeight.bold)),
                   const SizedBox(height: 16),
                   Row(
                     children: [
                       Expanded(
                         child: DropdownButtonFormField<int>(
                           value: _selectedMonth,
                           dropdownColor: const Color(0xFF0F1520),
                           style: GoogleFonts.outfit(color: Colors.white),
                           decoration: const InputDecoration(labelText: 'Mes', border: OutlineInputBorder()),
                           items: List.generate(12, (index) => DropdownMenuItem(
                             value: index + 1,
                             child: Text(DateFormat('MMMM', 'es').format(DateTime(2022, index + 1))),
                           )),
                           onChanged: (v) => setState(() => _selectedMonth = v!),
                         ),
                       ),
                       const SizedBox(width: 16),
                       Expanded(
                         child: DropdownButtonFormField<int>(
                           value: _selectedYear,
                           dropdownColor: const Color(0xFF0F1520),
                           style: GoogleFonts.outfit(color: Colors.white),
                           decoration: const InputDecoration(labelText: 'Año', border: OutlineInputBorder()),
                           items: [2024, 2025, 2026].map((y) => DropdownMenuItem(value: y, child: Text(y.toString()))).toList(),
                           onChanged: (v) => setState(() => _selectedYear = v!),
                         ),
                       ),
                     ],
                   ),
                   const SizedBox(height: 16),
                   DropdownButtonFormField<PayrollFrequency>(
                     value: _frequency,
                     dropdownColor: const Color(0xFF0F1520),
                     style: GoogleFonts.outfit(color: Colors.white),
                     decoration: const InputDecoration(labelText: 'Frecuencia', border: OutlineInputBorder()),
                     items: [PayrollFrequency.quincenal, PayrollFrequency.mensual].map((f) => 
                       DropdownMenuItem(value: f, child: Text(f.name.toUpperCase()))
                     ).toList(),
                     onChanged: (v) => setState(() => _frequency = v!),
                   ),
                   if (_frequency == PayrollFrequency.quincenal)
                     Padding(
                       padding: const EdgeInsets.only(top: 16),
                       child: DropdownButtonFormField<int>(
                         value: _selectedQuincena,
                         dropdownColor: const Color(0xFF0F1520),
                         style: GoogleFonts.outfit(color: Colors.white),
                         decoration: const InputDecoration(labelText: 'Quincena', border: OutlineInputBorder()),
                         items: const [
                           DropdownMenuItem(value: 1, child: Text('1ra Quincena (1-15)')),
                           DropdownMenuItem(value: 2, child: Text('2da Quincena (16-Fin)')),
                         ],
                         onChanged: (v) => setState(() => _selectedQuincena = v!),
                       ),
                     ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            Expanded(
              child: ListView.builder(
                itemCount: widget.selectedWorkers.length,
                itemBuilder: (ctx, i) {
                  final w = widget.selectedWorkers[i];
                  final isDone = _results.containsKey(w.id);
                  return Card(
                    color: Colors.white10,
                    child: ListTile(
                      title: Text(w.name, style: GoogleFonts.outfit(color: Colors.white)),
                      subtitle: Text(w.position, style: GoogleFonts.outfit(color: Colors.white54)),
                      trailing: isDone 
                        ? Text('\$${_results[w.id]!.toStringAsFixed(2)}', style: GoogleFonts.outfit(color: Colors.greenAccent, fontWeight: FontWeight.bold))
                        : const Icon(Icons.pending, color: Colors.white24),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
            NeonButton(
              text: _isProcessing ? 'Procesando...' : 'Procesar Planilla',
              primary: true,
              isLoading: _isProcessing,
              icon: Icons.play_arrow,
              onTap: _processBatch,
            )
          ],
        ),
      ),
    );
  }
}
