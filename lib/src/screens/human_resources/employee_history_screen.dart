import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../components/premium_scaffold.dart';
import '../../components/neon_widgets.dart';
import '../../calculators/salario_models.dart';
import '../../calculators/vacation_models.dart';
import '../../calculators/decimo_models.dart';
import '../../services/worker_service.dart';

/// Pantalla de historial completo del empleado con 3 tabs
class EmployeeHistoryScreen extends StatefulWidget {
  final String workerId;
  final WorkerProfile? worker; // Optional pre-loaded worker
  final String? initialTab; // NEW: Support for specific tab (e.g., 'payroll')

  const EmployeeHistoryScreen({
    Key? key,
    required this.workerId,
    this.worker,
    this.initialTab,
  }) : super(key: key);

  @override
  State<EmployeeHistoryScreen> createState() => _EmployeeHistoryScreenState();
}

class _EmployeeHistoryScreenState extends State<EmployeeHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final WorkerService _service = WorkerService();
  WorkerProfile? _worker;
  bool _isLoading = true;
  bool _hasError = false; // NEW: Track error state separately
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Set initial tab safely
    if (widget.initialTab == 'payroll') _tabController.index = 0;
    else if (widget.initialTab == 'vacation') _tabController.index = 1;
    else if (widget.initialTab == 'decimo') _tabController.index = 2; // Default to 0 or specific index for decimo if needed, usually 2 but check tabs order

    // Force load if worker not provided
    if (widget.worker != null) {
      _worker = widget.worker;
      _isLoading = false;
    } else {
      _loadWorker();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadWorker() async {
    // 1. Initial validation
    if (widget.workerId.isEmpty) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMsg = "ID de empleado no válido";
          _isLoading = false;
        });
      }
      return;
    }
    
    try {
      // 2. Async Load
      final workers = await _service.getWorkers();
      
      // 3. Safe Lookup using cast + orElse
      final WorkerProfile? found = workers
          .cast<WorkerProfile?>()
          .firstWhere((w) => w?.id == widget.workerId, orElse: () => null);
      
      if (!mounted) return;

      // 4. Handle Result
      if (found != null) {
        setState(() {
          _worker = found;
          _hasError = false;
          _errorMsg = null;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _errorMsg = "Empleado no encontrado";
          _isLoading = false;
        });
      }

    } catch (e, st) {
      debugPrint('❌ Error loading worker: $e\n$st');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMsg = "Error al cargar: $e";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // GUARANTEE: Always return a Scaffold
    return PremiumScaffold(
      title: 'Historial Laboral',
      showBranding: true,
      useScroll: false, // CRITICAL: Allow Expanded/TabBarView to work
      usePadding: false, // CRITICAL: We manage padding inside children
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_hasError || _worker == null) {
      return _buildErrorState();
    }
    
    // FASE B: Single View Mode for 'payroll'
    // If tab param is 'payroll', we show ONLY the payroll list, no tabs.
    if (widget.initialTab == 'payroll') {
      return Column(
        children: [
          _buildWorkerHeader(), // Keep identity info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            color: const Color(0xFF0F1520),
            child: Text(
              'Historial de Planillas',
              style: GoogleFonts.outfit(
                color: kNeonGreen,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ),
          Expanded(child: _buildPayrollTab()), // Reuse existing list builder
        ],
      );
    }
    
    // Default: Full History with Tabs
    return Column(
      children: [
        _buildWorkerHeader(),
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildPayrollTab(),
              _buildVacationTab(),
              _buildDecimoTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWorkerHeader() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kNeonBlue.withOpacity(0.15),
            kNeonViolet.withOpacity(0.10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kNeonBlue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: kNeonBlue.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _worker!.name.isNotEmpty ? _worker!.name[0].toUpperCase() : '?',
                style: GoogleFonts.outfit(
                  color: kNeonBlue,
                  fontSize: 24,
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
                  _worker!.name,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _worker!.position,
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                if (_worker!.department.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    _worker!.department,
                    style: GoogleFonts.outfit(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF151C2B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: kNeonBlue.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: kNeonBlue,
        unselectedLabelColor: Colors.white54,
        labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
        tabs: const [
          Tab(text: '💰 Planillas'),
          Tab(text: '🏖️ Vacaciones'),
          Tab(text: '🎁 Décimos'),
        ],
      ),
    );
  }

  Widget _buildPayrollTab() {
    final payrolls = _worker!.payrollHistory;
    
    if (payrolls.isEmpty) {
      return _buildEmptyState(
        icon: Icons.receipt_long,
        title: 'Sin planillas registradas',
        subtitle: 'Las planillas guardadas aparecerán aquí',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: payrolls.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final payroll = payrolls[index];
        final fmt = DateFormat('dd/MM/yyyy');
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF151C2B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kNeonGold.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${fmt.format(payroll.periodStart)} - ${fmt.format(payroll.periodEnd)}',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'B/. ${payroll.netSalary.toStringAsFixed(2)}',
                    style: GoogleFonts.outfit(
                      color: kNeonGold,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildStat('Bruto', 'B/. ${payroll.grossSalary.toStringAsFixed(2)}'),
                  ),
                  Expanded(
                    child: _buildStat('Neto', 'B/. ${payroll.netSalary.toStringAsFixed(2)}'),
                  ),
                  Expanded(
                    child: _buildStat('Deducciones', 'B/. ${payroll.totalDeducciones.toStringAsFixed(2)}'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVacationTab() {
    final vacations = _worker!.vacationHistory;
    
    if (vacations.isEmpty) {
      return Column(
        children: [
          Expanded(
            child: _buildEmptyState(
              icon: Icons.beach_access,
              title: 'Sin vacaciones registradas',
              subtitle: 'Los registros de vacaciones aparecerán aquí',
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: NeonButton(
              text: 'Agregar Vacaciones',
              onTap: () async {
                final result = await context.push('/vacation_calculator?workerId=${_worker!.id}');
                if (result == true) _loadWorker();
              },
              icon: Icons.add,
              primary: false,
              color: kNeonBlue.withOpacity(0.2),
              textColor: kNeonBlue,
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: vacations.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final vacation = vacations[index];
              
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF151C2B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: vacation.isPaid ? kNeonGold.withOpacity(0.3) : kNeonBlue.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              vacation.isPaid ? Icons.payments : Icons.flight_takeoff,
                              color: vacation.isPaid ? kNeonGold : kNeonBlue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              vacation.isPaid ? 'Vacaciones Pagadas' : 'Vacaciones Tomadas',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      vacation.periodLabel,
                      style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStat('Días', '${vacation.daysTaken}'),
                        ),
                        if (vacation.isPaid)
                          Expanded(
                            child: _buildStat('Monto', 'B/. ${vacation.amountPaid.toStringAsFixed(2)}'),
                          ),
                      ],
                    ),
                    if (vacation.notes.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        vacation.notes,
                        style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: NeonButton(
            text: 'Agregar Vacaciones',
            onTap: () async {
              final result = await context.push('/vacation_calculator?workerId=${_worker!.id}');
              if (result == true) _loadWorker();
            },
            icon: Icons.add,
            primary: false,
            color: kNeonBlue.withOpacity(0.2),
            textColor: kNeonBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildDecimoTab() {
    final decimos = _worker!.decimoHistory;
    
    if (decimos.isEmpty) {
      return Column(
        children: [
          Expanded(
            child: _buildEmptyState(
              icon: Icons.card_giftcard,
              title: 'Sin décimos registrados',
              subtitle: 'Los pagos de décimo 13vo mes aparecerán aquí',
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: NeonButton(
              text: 'Calcular Décimo',
              onTap: () async {
                final result = await context.push('/decimo_calculator?workerId=${_worker!.id}');
                if (result == true) _loadWorker();
              },
              icon: Icons.calculate,
              primary: false,
              color: kNeonGreen.withOpacity(0.2),
              textColor: kNeonGreen,
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: decimos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final decimo = decimos[index];
              
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF151C2B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kNeonGreen.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          decimo.periodLabel,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'B/. ${decimo.netAmount.toStringAsFixed(2)}',
                          style: GoogleFonts.outfit(
                            color: kNeonGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      decimo.periodRange,
                      style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStat('Bruto', 'B/. ${decimo.grossAmount.toStringAsFixed(2)}'),
                        ),
                        Expanded(
                          child: _buildStat('CSS', 'B/. ${decimo.ssDeduction.toStringAsFixed(2)}'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: NeonButton(
            text: 'Calcular Décimo',
            onTap: () async {
              final result = await context.push('/decimo_calculator?workerId=${_worker!.id}');
              if (result == true) _loadWorker();
            },
            icon: Icons.calculate,
            primary: false,
            color: kNeonGreen.withOpacity(0.2),
            textColor: kNeonGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.white24),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: const Icon(Icons.person_off, size: 48, color: Colors.red),
            ),
            const SizedBox(height: 24),
            Text(
              _errorMsg ?? 'Empleado no encontrado',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'El ID "${widget.workerId}" generó un problema o no existe.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
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
                backgroundColor: kNeonBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
