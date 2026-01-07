import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/premium_scaffold.dart';
import '../components/employee_card_compact.dart';
import '../components/neon_widgets.dart';
import '../components/how_to_use_card.dart';
import '../services/worker_service.dart';
import '../calculators/salario_models.dart';
import 'package:go_router/go_router.dart';
import '../screens/human_resources/worker_form_screen.dart';
import 'package:proyecto_empoderate/src/components/business_hero_header.dart';
import 'package:proyecto_empoderate/src/widgets/feature_intro_screen.dart';

/// Employee Directory Screen with search and numbering
class EmployeesGridScreen extends StatefulWidget {
  const EmployeesGridScreen({Key? key}) : super(key: key);

  @override
  State<EmployeesGridScreen> createState() => _EmployeesGridScreenState();
}

class _EmployeesGridScreenState extends State<EmployeesGridScreen> {
  final WorkerService _service = WorkerService();
  List<WorkerProfile> _workers = [];
  List<WorkerProfile> _filteredWorkers = [];
  bool _isLoading = true;
  String? _selectedWorkerId;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';


  @override
  void initState() {
    super.initState();
    _loadWorkers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadWorkers() async {
    setState(() => _isLoading = true);
    try {
      final workers = await _service.getWorkers();
      if (mounted) {
        setState(() {
          _workers = workers;
          _filteredWorkers = workers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterWorkers(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredWorkers = _workers;
      } else {
        _filteredWorkers = _workers.where((w) {
          final nameLower = w.name.toLowerCase();
          final positionLower = w.position.toLowerCase();
          final queryLower = query.toLowerCase();
          return nameLower.contains(queryLower) || positionLower.contains(queryLower);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      // title: 'Base de Datos de Colaboradores', // REMOVED: Using Hero Header instead
      showBranding: true,
      useScroll: false, 
      usePadding: false,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/hr/worker/add');
          _loadWorkers();
        },
        backgroundColor: const Color(0xFF00E5FF),
        icon: const Icon(Icons.person_add, color: Colors.black),
        label: Text(
          'Nuevo',
          style: GoogleFonts.outfit(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: BusinessHeroHeader(
                    title: 'Directorio de Talento',
                    subtitle: 'Gestiona tu equipo, contratos y nómina en un solo lugar.',
                    icon: Icons.people_alt_outlined,
                    color: const Color(0xFF00E5FF),
                    stats: [
                      StatItem(
                        value: '${_workers.length}',
                        label: 'Colaboradores',
                        icon: Icons.groups,
                      ),
                      StatItem(
                        value: '\$${_workers.fold<double>(0, (sum, w) => sum + w.basePayment).toStringAsFixed(0)}',
                        label: 'Nómina Base',
                        icon: Icons.payments,
                      ),
                    ],
                  ),
                ),
                
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // How to Use Card
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: const HowToUseCard(
                          title: '¿Cómo usar el Directorio?',
                          icon: Icons.people_outline,
                          accentColor: Color(0xFF00E5FF),
                          steps: [
                            'Usa la barra de búsqueda para encontrar empleados.',
                            'Toca "Planilla" para calcular salario.',
                            'Toca "Liquidación" para calcular finiquito.',
                            'Usa los botones de editar (📝) y eliminar (🗑️).',
                          ],
                        ),
                      ),

                    // Quick Actions
                    Column(
                      children: [
                        InkWell(
                          onTap: () => context.push('/payroll_history'),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4D35E).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFF4D35E).withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.history, color: const Color(0xFFF4D35E), size: 20),
                                SizedBox(width: 8),
                                Text("Ver Historial de Planilla", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () => context.push('/schedule_creator'),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF00E5FF).withOpacity(0.15),
                                  const Color(0xFF00E5FF).withOpacity(0.05),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00E5FF).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.calendar_month, color: Color(0xFF00E5FF), size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Ir a Planificador de Horario',
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        'Asigna turnos y genera horarios',
                                        style: GoogleFonts.outfit(
                                          color: Colors.white54,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios, color: Color(0xFF00E5FF), size: 16),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),

                    // Test Data Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await _service.seedTestWorkers();
                              _loadWorkers();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('✅ 10 empleados de prueba creados'), backgroundColor: Colors.green),
                                );
                              }
                            },
                            icon: const Icon(Icons.science, size: 16),
                            label: const Text('Cargar Datos de Prueba'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.amber,
                              side: const BorderSide(color: Colors.amber),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await _service.clearTestWorkers();
                              _loadWorkers();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('🗑️ Empleados de prueba eliminados'), backgroundColor: Colors.redAccent),
                                );
                              }
                            },
                            icon: const Icon(Icons.delete_sweep, size: 16),
                            label: const Text('Limpiar Pruebas'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                              side: const BorderSide(color: Colors.redAccent),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
                
            // The Employee List (moved outside SliverToBoxAdapter so it can be a Sliver)
            _workers.isEmpty 
              ? SliverToBoxAdapter(child: _buildEmptyState())
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= _filteredWorkers.length) return null;
                      final worker = _filteredWorkers[index];
                      final originalIndex = _workers.indexOf(worker);

                      return Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Employee Number Badge
                            Container(
                              width: 32,
                              height: 32,
                              margin: const EdgeInsets.only(right: 10, top: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4D35E).withOpacity(0.15),
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFFF4D35E).withOpacity(0.4)),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '#${originalIndex + 1}',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFFF4D35E),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            // Employee Card
                            Expanded(
                              child: EmployeeCardCompact(
                                worker: worker,
                                isSelected: _selectedWorkerId == worker.id,
                                onTap: () {
                                  setState(() => _selectedWorkerId = worker.id);
                                  context.push('/salario_neto?workerId=${worker.id}');
                                },
                                onEdit: () async {
                                  await context.push('/hr/worker/edit/${worker.id}');
                                  _loadWorkers();
                                },
                                onDelete: () async {
                                  await _service.deleteWorker(worker.id);
                                  _loadWorkers();
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('${worker.name} eliminado'), backgroundColor: Colors.green),
                                    );
                                  }
                                },
                                onLiquidation: () => context.push('/liquidacion?workerId=${worker.id}'),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: _filteredWorkers.length,
                  ),
                ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)), // Bottom padding
          ],
        ),
      );
  }

  Widget _buildGrid() {
    if (_filteredWorkers.isEmpty && _searchQuery.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              const Icon(Icons.search_off, size: 48, color: Colors.white24),
              const SizedBox(height: 12),
              Text(
                'No se encontraron resultados para "$_searchQuery"',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(color: Colors.white54),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredWorkers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final worker = _filteredWorkers[index];
        final originalIndex = _workers.indexOf(worker);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Employee Number Badge
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 10, top: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF4D35E).withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFF4D35E).withOpacity(0.4)),
              ),
              alignment: Alignment.center,
              child: Text(
                '#${originalIndex + 1}',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFF4D35E),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
            // Employee Card
            Expanded(
              child: EmployeeCardCompact(
                worker: worker,
                isSelected: _selectedWorkerId == worker.id,
                onTap: () {
                  setState(() => _selectedWorkerId = worker.id);
                  context.push('/salario_neto?workerId=${worker.id}');
                },
                onEdit: () async {
                  await context.push('/hr/worker/edit/${worker.id}');
                  _loadWorkers();
                },
                onDelete: () async {
                  await _service.deleteWorker(worker.id);
                  _loadWorkers();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${worker.name} eliminado'), backgroundColor: Colors.green),
                    );
                  }
                },
                onLiquidation: () => context.push('/liquidacion?workerId=${worker.id}'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsCards() {
    final totalPayroll = _workers.fold<double>(0, (sum, w) => sum + w.basePayment);
    final avgPayroll = _workers.isEmpty ? 0 : totalPayroll / _workers.length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total',
            '${_workers.length}',
            Icons.people_outline,
            const Color(0xFF00E5FF),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Nómina Base',
            '\$${totalPayroll.toStringAsFixed(0)}',
            Icons.payments_outlined,
            const Color(0xFFF4D35E),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Promedio',
            '\$${avgPayroll.toStringAsFixed(0)}',
            Icons.trending_up,
            const Color(0xFF00E676),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: Colors.white54,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Beautiful gradient container with icon
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF00E5FF).withOpacity(0.2),
                    const Color(0xFF00E5FF).withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withOpacity(0.2),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: const Icon(
                Icons.people_outline_rounded,
                size: 70,
                color: Color(0xFF00E5FF),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Tu Equipo Empieza Aquí',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Aún no has registrado colaboradores.\nAgrega el primer miembro de tu equipo para comenzar.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: Colors.white60,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            // Call to action hint
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF00E5FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF00E5FF).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.touch_app_rounded,
                    color: Color(0xFF00E5FF),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Presiona el botón "Nuevo" para agregar',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF00E5FF),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
