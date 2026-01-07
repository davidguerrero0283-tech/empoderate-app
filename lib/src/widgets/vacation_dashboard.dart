import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/vacation_management.dart';
import '../calculators/salario_models.dart';
import '../services/vacation_eligibility_service.dart';
import '../components/neon_widgets.dart';

/// Dashboard widget showing employees with pending vacations
class VacationPendingDashboard extends StatefulWidget {
  final Function(WorkerProfile)? onApprovePressed;
  
  const VacationPendingDashboard({Key? key, this.onApprovePressed}) : super(key: key);
  
  @override
  State<VacationPendingDashboard> createState() => _VacationPendingDashboardState();
}

class _VacationPendingDashboardState extends State<VacationPendingDashboard> {
  final VacationEligibilityService _service = VacationEligibilityService();
  List<MapEntry<WorkerProfile, List<VacationEligibility>>> _pendingList = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadPending();
  }
  
  Future<void> _loadPending() async {
    setState(() => _isLoading = true);
    try {
      final pending = await _service.getPendingVacations();
      if (mounted) {
        setState(() {
          _pendingList = pending;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading pending vacations: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const NeonCard(
        borderColor: Color(0xFFFFA500),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_pendingList.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return NeonCard(
      borderColor: const Color(0xFFFFA500), // Orange for pending
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.beach_access, color: Color(0xFFFFA500), size: 24),
              const SizedBox(width: 12),
              Text(
                'Vacaciones Pendientes',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFA500).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_pendingList.length}',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFA500),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._pendingList.map((entry) => _buildEmployeeCard(entry)),
        ],
      ),
    );
  }
  
  Widget _buildEmployeeCard(MapEntry<WorkerProfile, List<VacationEligibility>> entry) {
    final worker = entry.key;
    final eligibilities = entry.value;
    final firstEligibility = eligibilities.first;
    
    // Calculate total days available
    final totalDays = eligibilities.fold<int>(0, (sum, e) => sum + e.daysEarned);
    final daysTaken = worker.vacationHistory.fold<int>(0, (sum, v) => sum + v.daysTaken);
    final daysAvailable = totalDays - daysTaken;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFFFA500).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      worker.name,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${worker.position} • ${worker.department}',
                      style: GoogleFonts.outfit(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => widget.onApprovePressed?.call(worker),
                icon: const Icon(Icons.check_circle, color: Colors.greenAccent),
                tooltip: 'Aprobar Vacaciones',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildInfoChip(
                icon: Icons.calendar_today,
                label: 'Ingreso',
                value: DateFormat('dd/MM/yyyy').format(worker.startDate ?? DateTime.now()),
              ),
              _buildInfoChip(
                icon: Icons.timelapse,
                label: 'Antigüedad',
                value: '${firstEligibility.yearOfService} ${firstEligibility.yearOfService == 1 ? "año" : "años"}',
              ),
              _buildInfoChip(
                icon: Icons.event_available,
                label: 'Días ganados',
                value: '$totalDays días',
                color: Colors.cyanAccent,
              ),
              _buildInfoChip(
                icon: Icons.check,
                label: 'Tomados',
                value: '$daysTaken días',
                color: Colors.white54,
              ),
              _buildInfoChip(
                icon: Icons.star,
                label: 'Disponibles',
                value: '$daysAvailable días',
                color: const Color(0xFFFFD700),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color ?? Colors.white70),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.outfit(
                  color: Colors.white38,
                  fontSize: 9,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.outfit(
                  color: color ?? Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Dialog for approving vacation
class VacationApprovalDialog extends StatefulWidget {
  final WorkerProfile worker;
  final Function(DateTime start, DateTime end, int days)? onApprove;
  
  const VacationApprovalDialog({
    Key? key,
    required this.worker,
    this.onApprove,
  }) : super(key: key);
  
  @override
  State<VacationApprovalDialog> createState() => _VacationApprovalDialogState();
}

class _VacationApprovalDialogState extends State<VacationApprovalDialog> {
  DateTime? _startDate;
  DateTime? _endDate;
  int _days = 0;
  
  void _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = null;
        }
        _calculateDays();
      });
    }
  }
  
  void _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
        _calculateDays();
      });
    }
  }
  
  void _calculateDays() {
    if (_startDate != null && _endDate != null) {
      setState(() {
        _days = _endDate!.difference(_startDate!).inDays + 1;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final service = VacationEligibilityService();
    final eligibilities = service.calculateEligibility(widget.worker);
    final pendingEligibilities = eligibilities.where((e) => e.status == VacationStatus.pending).toList();
    
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A2E),
      title: Row(
        children: [
          const Icon(Icons.beach_access, color: Color(0xFFFFA500)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Aprobar Vacaciones',
              style: GoogleFonts.outfit(color: Colors.white),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.worker.name,
              style: GoogleFonts.outfit(
                color: Colors.cyanAccent,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.worker.position} • ${widget.worker.department}',
              style: GoogleFonts.outfit(color: Colors.white54),
            ),
            const Divider(color: Colors.white24, height: 32),
            if (pendingEligibilities.isNotEmpty) ...[
              Text(
                'Períodos disponibles:',
                style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 8),
              ...pendingEligibilities.map((e) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month, size: 16, color: const Color(0xFFFFD700)),
                    const SizedBox(width: 8),
                    Text(
                      'Año ${e.yearOfService}: ${e.daysEarned} días',
                      style: GoogleFonts.outfit(color: Colors.white),
                    ),
                  ],
                ),
              )),
              const Divider(color: Colors.white24, height: 32),
            ],
            Text(
              'Seleccionar fechas:',
              style: GoogleFonts.outfit(color: Colors.white70, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickStartDate,
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(
                      _startDate != null
                          ? DateFormat('dd/MM/yyyy').format(_startDate!)
                          : 'Inicio',
                      style: GoogleFonts.outfit(fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.cyanAccent,
                      side: const BorderSide(color: Colors.cyanAccent),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickEndDate,
                    icon: const Icon(Icons.event, size: 16),
                    label: Text(
                      _endDate != null
                          ? DateFormat('dd/MM/yyyy').format(_endDate!)
                          : 'Fin',
                      style: GoogleFonts.outfit(fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.cyanAccent,
                      side: const BorderSide(color: Colors.cyanAccent),
                    ),
                  ),
                ),
              ],
            ),
            if (_days > 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFD700)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event_available, color: Color(0xFFFFD700), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Total: $_days ${_days == 1 ? "día" : "días"}',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFD700),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: _startDate != null && _endDate != null
              ? () {
                  widget.onApprove?.call(_startDate!, _endDate!, _days);
                  Navigator.pop(context);
}
              : null,
          icon: const Icon(Icons.check_circle),
          label: const Text('APROBAR Y CALCULAR'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.greenAccent,
            foregroundColor: Colors.black,
          ),
        ),
      ],
    );
  }
}
