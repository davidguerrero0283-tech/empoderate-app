import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../calculators/salario_models.dart';
import 'neon_widgets.dart';

/// Professional employee card component that displays worker information
/// and provides quick navigation to payroll and liquidation calculators.
/// 
/// Features:
/// - Displays employee name, position, and base salary
/// - Interactive tap to navigate to salary calculator
/// - Optional quick actions menu
/// - Visual selection state
/// - Professional dark theme design
class EmployeeCard extends StatefulWidget {
  final WorkerProfile worker;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onLiquidation;
  final bool isSelected;
  final bool showActions;
  final double? width;
  final double? height;

  const EmployeeCard({
    Key? key,
    required this.worker,
    this.onTap,
    this.onDelete,
    this.onEdit,
    this.onLiquidation,
    this.isSelected = false,
    this.showActions = true,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  State<EmployeeCard> createState() => _EmployeeCardState();
}

class _EmployeeCardState extends State<EmployeeCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        width: widget.width ?? 180,
        height: widget.height ?? 160,
        child: InkWell(
          onTap: widget.onTap ?? () => _navigateToSalaryCalculator(context),
          onLongPress: widget.showActions ? () => _showQuickActions(context) : null,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.isSelected
                  ? [
                      const Color(0xFFF4D35E).withOpacity(0.15),
                      const Color(0xFFF4D35E).withOpacity(0.05),
                    ]
                  : [
                      const Color(0xFF151C2B),
                      const Color(0xFF0F1520),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isHovered ? kNeonGold : (widget.isSelected ? const Color(0xFFF4D35E) : Colors.white.withOpacity(0.1)),
                width: _isHovered ? 2 : (widget.isSelected ? 2 : 1),
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: kNeonGold.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ]
                  : widget.isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFFF4D35E).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header: Name and Selection Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      widget.worker.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  if (widget.isSelected)
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFFF4D35E),
                      size: 16,
                    ),
                  if (widget.showActions && !widget.isSelected)
                    GestureDetector(
                      onTap: () => _showQuickActions(context),
                      child: Icon(
                        Icons.more_vert,
                        color: Colors.white.withOpacity(0.5),
                        size: 18,
                      ),
                    ),
                ],
              ),

              // Position
              Text(
                widget.worker.position,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  color: const Color(0xFF00E5FF),
                  fontSize: 12,
                ),
              ),

              const Spacer(),

              // Divider
              Container(
                height: 1,
                color: Colors.white.withOpacity(0.1),
              ),

              const SizedBox(height: 8),

              // Salary
              Row(
                children: [
                  const Icon(
                    Icons.payments_outlined,
                    color: Color(0xFF00E676),
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '\$${widget.worker.basePayment.toStringAsFixed(2)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF00E676),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // Frequency Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF00E5FF).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  _getFrequencyLabel(widget.worker.paymentMode),
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF00E5FF),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
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
    Navigator.pushNamed(
      context,
      '/salario_neto',
      arguments: widget.worker.id,
    );
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F1520),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          border: Border(
            top: BorderSide(
              color: const Color(0xFF00E5FF).withOpacity(0.5),
              width: 2,
            ),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),

                // Employee Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Text(
                        widget.worker.name,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.worker.position,
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF00E5FF),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Salary Calculator
                      _buildActionTile(
                        context,
                        icon: Icons.calculate_outlined,
                        label: 'Calcular Planilla',
                        color: const Color(0xFF00E5FF),
                        onTap: () {
                          Navigator.pop(context);
                          _navigateToSalaryCalculator(context);
                        },
                      ),

                      const SizedBox(height: 12),

                      // Liquidation
                      if (widget.onLiquidation != null)
                        _buildActionTile(
                          context,
                          icon: Icons.work_outline,
                          label: 'Calcular Liquidación',
                          color: const Color(0xFFFFAB40),
                          onTap: () {
                            Navigator.pop(context);
                            widget.onLiquidation!();
                          },
                        ),

                      if (widget.onLiquidation != null) const SizedBox(height: 12),

                      // Edit Profile
                      if (widget.onEdit != null)
                        _buildActionTile(
                          context,
                          icon: Icons.edit_outlined,
                          label: 'Editar Perfil',
                          color: const Color(0xFFF4D35E),
                          onTap: () {
                            Navigator.pop(context);
                            widget.onEdit!();
                          },
                        ),

                      if (widget.onEdit != null) const SizedBox(height: 12),

                      // Delete
                      if (widget.onDelete != null)
                        _buildActionTile(
                          context,
                          icon: Icons.delete_outline,
                          label: 'Eliminar Colaborador',
                          color: Colors.redAccent,
                          onTap: () {
                            Navigator.pop(context);
                            _confirmDelete(context);
                          },
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.3),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F1520),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.redAccent.withOpacity(0.5),
          ),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.redAccent,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Confirmar Eliminación',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar a ${widget.worker.name}?\n\nEsta acción no se puede deshacer.',
          style: GoogleFonts.outfit(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancelar',
              style: GoogleFonts.outfit(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (widget.onDelete != null) widget.onDelete!();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Eliminar',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
