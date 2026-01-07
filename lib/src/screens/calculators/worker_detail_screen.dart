
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../human_resources/worker_form_screen.dart'; // Import Form
import 'package:intl/intl.dart';
import '../../components/premium_scaffold.dart';
import '../../components/neon_widgets.dart';
import '../../calculators/salario_models.dart';
import '../../services/worker_service.dart';
import '../../features/payroll/domain/payroll_record.dart'; // Import PayrollRecord
import 'salario_screen.dart'; // To edit/re-open calculator
import 'liquidacion_screen.dart'; // To bridge integration
import 'package:go_router/go_router.dart';
import 'comprobante_planilla_screen.dart';
import '../human_resources/worker_dashboard_widgets.dart';

class WorkerDetailScreen extends StatefulWidget {
  final WorkerProfile worker;
  final Function() onUpdate; // Callback to refresh parent list

  const WorkerDetailScreen({Key? key, required this.worker, required this.onUpdate}) : super(key: key);

  @override
  _WorkerDetailScreenState createState() => _WorkerDetailScreenState();
}

class _WorkerDetailScreenState extends State<WorkerDetailScreen> {
  late WorkerProfile _worker;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _worker = widget.worker;
  }

  Future<void> _refreshWorker() async {
    final workers = await WorkerService().getWorkers();
    try {
      final updated = workers.firstWhere((w) => w.id == _worker.id);
      setState(() => _worker = updated);
      widget.onUpdate();
    } catch (e) {
      // Worker might have been deleted
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: _worker.name.toUpperCase(),
      subtitle: _worker.position,
      showBackButton: true,
      useScroll: true,
      body: Padding( // Added Padding to ensure content isn't flush against edges
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            NeonCard(
              child: Column(
                children: [
                   Icon(Icons.account_circle, size: 60, color: Colors.white70),
                   SizedBox(height: 10),
                   Text(_worker.name, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                   Text(_worker.position, style: GoogleFonts.outfit(fontSize: 14, color: Colors.white70)),
                   if (_worker.department.isNotEmpty)
                      Text(_worker.department, style: GoogleFonts.outfit(fontSize: 12, color: Colors.white38)),
                   
                   Divider(color: Colors.white24, height: 30),
                   
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                     children: [
                       _buildStat('Pago', _worker.paymentMode.name.toUpperCase()),
                       _buildStat('Salario Base', '\$${_worker.basePayment.toStringAsFixed(2)}'),
                     ],
                   )
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // ACTIONS
            Row(
              children: [
                _isProcessing 
                        ? const Expanded(child: Center(child: CircularProgressIndicator()))
                        : Expanded(
                           child: NeonButton(
                             text: 'Editar Perfil',
                             icon: Icons.edit,
                             primary: true,
                             onTap: () async {
                               // Navigate to Edit Form
                               await context.push('/hr/worker/edit/${_worker.id}');
                               // Refresh local worker? 
                               // Ideally onSave callback or reload.
                               // For now, we pop back or trigger update.
                               if (widget.onUpdate != null) widget.onUpdate!();
                               
                               // We should rebuild this screen... easier to just pop and reopen or set State if we had a reload mechanism.
                               // Let's pop to directory to force refresh for simplify.
                               Navigator.pop(context);
                             },
                           ),
                        ),  SizedBox(width: 12),
                Expanded(
                  child: NeonButton(
                    text: 'Liquidar Trabajador',
                    icon: Icons.person_remove,
                    primary: true,
                    color: Colors.redAccent,
                    onTap: _goToLiquidacion,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 30),
            
            // DASHBOARD
            if (_worker.payrollHistory.isNotEmpty) ...[
               WorkerAnnualSummary(history: _worker.payrollHistory),
               SizedBox(height: 24),
               SalaryHistoryChart(history: _worker.payrollHistory),
               SizedBox(height: 30),
            ],

            NeonSectionTitle(title: 'Historial de Planillas', color: kNeonGold),
            SizedBox(height: 10),
            
            if (_worker.payrollHistory.isEmpty)
               Center(child: Text('No hay registros guardados.', style: GoogleFonts.outfit(color: Colors.white38))),
            
            ..._worker.payrollHistory.map((record) {
               return Container(
                 margin: const EdgeInsets.only(bottom: 12),
                 decoration: BoxDecoration(
                   color: Colors.white.withOpacity(0.05),
                   borderRadius: BorderRadius.circular(12),
                   border: Border.all(color: Colors.white10),
                 ),
                 child: ListTile(
                   contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                   title: Text(record.periodLabel, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)), 
                   subtitle: Text('Neto: \$${record.netSalary.toStringAsFixed(2)}', style: GoogleFonts.outfit(color: kNeonGreen)),
                   trailing: Row(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       // View Receipt
                       IconButton(
                         tooltip: 'Ver Comprobante',
                         icon: const Icon(Icons.receipt_long, color: Colors.white70),
                         onPressed: () {
                           // Reconstruct
                            final input = SalarioInputModel.fromJson(record.inputSnapshot);
                            final result = SalarioResultModel.fromJson(record.resultSnapshot);
                            
                            context.push('/payroll/receipt', extra: {
                              'input': record.inputSnapshot,
                              'result': record.resultSnapshot,
                            });
                         },
                       ),
                       // Load/Edit (Pop)
                       IconButton(
                         tooltip: 'Cargar/Editar',
                         icon: const Icon(Icons.edit_note, color: kNeonBlue),
                         onPressed: () {
                           Navigator.pop(context, {
                             'action': 'LOAD_SNAPSHOT',
                             'snapshot': record.inputSnapshot
                           });
                         },
                       ),
                       // Duplicate
                       IconButton(
                         tooltip: 'Duplicar a otro periodo',
                         icon: const Icon(Icons.copy, color: kNeonGold),
                         onPressed: () {
                           Navigator.pop(context, {
                             'action': 'DUPLICATE_SNAPSHOT',
                             'snapshot': record.inputSnapshot
                           });
                         },
                       ),
                       // Delete
                       IconButton(
                         tooltip: 'Eliminar',
                         icon: const Icon(Icons.delete, color: Colors.redAccent),
                         onPressed: () => _deleteHistoryItem(record),
                       ),
                     ],
                   ),
                 ),
               );
            }).toList(),
            
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10)),
        Text(value, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
  
  void _goToLiquidacion() {
    context.push('/liquidacion?workerId=${_worker.id}');
  }
  
  Future<void> _deleteHistoryItem(PayrollRecord record) async {
    bool confirm = await showDialog(
      context: context, 
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF001225),
        title: const Text('¿Borrar registro?', style: TextStyle(color: Colors.white)),
        content: const Text('Se eliminará permanentemente.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Borrar', style: TextStyle(color: Colors.red))),
        ],
      )
    ) ?? false;
    
    if (confirm) {
      _worker.payrollHistory.removeWhere((r) => r.id == record.id);
      await WorkerService().saveWorker(_worker);
      _refreshWorker();
    }
  }
}
