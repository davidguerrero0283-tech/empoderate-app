import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../calculators/salario_models.dart';
import 'neon_widgets.dart';

/// Compact horizontal employee card with visible action buttons
/// All actions are visible without needing long-press
class EmployeeCardCompact extends StatefulWidget {
  final WorkerProfile worker;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onLiquidation;
  final VoidCallback? onSelect;
  final bool isSelected;
  final bool showActions;

  const EmployeeCardCompact({
    Key? key,
    required this.worker,
    this.onTap,
    this.onDelete,
    this.onEdit,
    this.onLiquidation,
    this.onSelect,
    this.isSelected = false,
    this.showActions = true,
  }) : super(key: key);

  @override
  State<EmployeeCardCompact> createState() => _EmployeeCardCompactState();
}

class _EmployeeCardCompactState extends State<EmployeeCardCompact> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.isSelected
                ? [const Color(0xFFF4D35E).withOpacity(0.15), const Color(0xFFF4D35E).withOpacity(0.05)]
                : [const Color(0xFF151C2B), const Color(0xFF0F1520)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isHovered ? kNeonGold : (widget.isSelected ? const Color(0xFFF4D35E) : Colors.white.withOpacity(0.1)),
            width: _isHovered ? 2 : (widget.isSelected ? 2 : 1),
          ),
          boxShadow: _isHovered
              ? [BoxShadow(color: kNeonGold.withOpacity(0.3), blurRadius: 12)]
              : widget.isSelected
                  ? [BoxShadow(color: const Color(0xFFF4D35E).withOpacity(0.2), blurRadius: 8)]
                  : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Avatar, Name, Position, Salary
            Row(
              children: [
                // Avatar circle with initials
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E5FF).withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _getInitials(widget.worker.name),
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF00E5FF),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Name, Position, Frequency
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.worker.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          if (widget.isSelected)
                            const Icon(Icons.check_circle, color: Color(0xFFF4D35E), size: 18),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.worker.position,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(color: Colors.white54, fontSize: 14),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00E5FF).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _getFrequencyLabel(widget.worker.paymentMode),
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF00E5FF),
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Salary
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      widget.worker.paymentType == PaymentType.hourly
                          ? '\$${widget.worker.hourlyRate?.toStringAsFixed(2) ?? "0.00"}'
                          : '\$${widget.worker.basePayment.toStringAsFixed(0)}',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF00E676),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      widget.worker.paymentType == PaymentType.hourly ? 'Por Hora' : 'Base',
                      style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),

            // Action Buttons - ALWAYS VISIBLE
            if (widget.showActions) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  // Planilla Button
                  Expanded(
                    child: _buildActionButton(
                      label: 'Planilla',
                      icon: Icons.calculate,
                      color: const Color(0xFF00E5FF),
                      onTap: widget.onTap ?? () => _navigateToSalaryCalculator(context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Liquidación Button
                  if (widget.onLiquidation != null)
                    Expanded(
                      child: _buildActionButton(
                        label: 'Liquidación',
                        icon: Icons.work_outline,
                        color: const Color(0xFFFFAB40),
                        onTap: widget.onLiquidation!,
                      ),
                    ),
                  if (widget.onLiquidation != null) const SizedBox(width: 8),
                  
                  // Historial Button
                  _buildIconButton(
                    icon: Icons.history,
                    color: Colors.white70,
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/employee_history',
                      arguments: widget.worker.id,
                    ),
                    tooltip: 'Historial',
                  ),
                  const SizedBox(width: 8),

                  // Turnos Button
                  _buildIconButton(
                    icon: Icons.event_note,
                    color: kNeonCyan,
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/shift_logger',
                      arguments: {'worker': widget.worker},
                    ),
                    tooltip: 'Turnos',
                  ),
                  const SizedBox(width: 8),

                  // Edit Button
                  if (widget.onEdit != null)
                    _buildIconButton(
                      icon: Icons.edit,
                      color: const Color(0xFFF4D35E),
                      onTap: widget.onEdit!,
                      tooltip: 'Editar',
                    ),
                  if (widget.onEdit != null) const SizedBox(width: 6),
                  
                  // Delete Button
                  if (widget.onDelete != null)
                    _buildIconButton(
                      icon: Icons.delete_outline,
                      color: Colors.redAccent,
                      onTap: () => _confirmDelete(context),
                      tooltip: 'Eliminar',
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.outfit(color: color, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  String _getFrequencyLabel(PayrollFrequency freq) {
    switch (freq) {
      case PayrollFrequency.mensual:
        return 'MENSUAL';
      case PayrollFrequency.quincenal:
        return 'QUINCENAL';
      case PayrollFrequency.semanal:
        return 'SEMANAL';
    }
  }

  void _navigateToSalaryCalculator(BuildContext context) {
    Navigator.pushNamed(context, '/salario_neto', arguments: widget.worker.id);
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F1520),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber, color: Colors.redAccent),
            const SizedBox(width: 12),
            const Expanded(child: Text('Eliminar', style: TextStyle(color: Colors.white))),
          ],
        ),
        content: Text(
          '¿Eliminar a ${widget.worker.name}?\n\nEsta acción no se puede deshacer.',
          style: GoogleFonts.outfit(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onDelete?.call();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
