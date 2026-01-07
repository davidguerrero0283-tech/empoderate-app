// Tramite Card Widget
// Premium card for displaying tramite information

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../ui/theme/color_palette.dart';
import '../../domain/tramite_event.dart';
import '../../domain/agenda_rules.dart';

class TramiteCard extends StatelessWidget {
  final TramiteEvent tramite;
  final VoidCallback onTap;
  final VoidCallback onMarcarRealizado;
  final VoidCallback onEditar;

  const TramiteCard({
    Key? key,
    required this.tramite,
    required this.onTap,
    required this.onMarcarRealizado,
    required this.onEditar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final diasRestantes = AgendaRules.diasRestantes(tramite.proximaFecha);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isDark ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getBorderColor(isDark),
          width: 1.5,
        ),
      ),
      color: isDark ? AppColors.surface : Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Icon + Title + Badge
              Row(
                children: [
                  _buildIcon(isDark),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tramite.titulo,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.premiumGold : AppColors.lightAccent,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tramite.entidad,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(isDark),
                ],
              ),
              const SizedBox(height: 12),

              // Date and Days Remaining
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('dd/MM/yyyy').format(tramite.proximaFecha),
                    style: GoogleFonts.outfit(
                      color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _getDaysRemainingText(diasRestantes),
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _getDaysRemainingColor(diasRestantes, isDark),
                    ),
                  ),
                ],
              ),

              // Actions
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onMarcarRealizado,
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Realizado'),
                    style: TextButton.styleFrom(
                      foregroundColor: isDark ? AppColors.premiumGold : AppColors.lightAccent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: onEditar,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Editar'),
                    style: TextButton.styleFrom(
                      foregroundColor: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(bool isDark) {
    IconData icon;
    Color color;

    switch (tramite.categoria) {
      case CategoriaEntidad.dgi:
        icon = Icons.account_balance;
        color = Colors.blue;
        break;
      case CategoriaEntidad.municipio:
        icon = Icons.location_city;
        color = Colors.orange;
        break;
      case CategoriaEntidad.mitradel:
        icon = Icons.work;
        color = Colors.purple;
        break;
      case CategoriaEntidad.css:
        icon = Icons.health_and_safety;
        color = Colors.green;
        break;
      case CategoriaEntidad.minsa:
        icon = Icons.local_hospital;
        color = Colors.red;
        break;
      case CategoriaEntidad.otro:
        icon = Icons.description;
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildStatusBadge(bool isDark) {
    Color bgColor;
    Color textColor;
    String text;

    switch (tramite.estado) {
      case EstadoTramite.vencido:
        bgColor = Colors.red.withOpacity(0.2);
        textColor = Colors.red;
        text = 'Vencido';
        break;
      case EstadoTramite.pendiente:
        bgColor = Colors.orange.withOpacity(0.2);
        textColor = Colors.orange;
        text = 'Próximo';
        break;
      case EstadoTramite.alDia:
        bgColor = Colors.green.withOpacity(0.2);
        textColor = Colors.green;
        text = 'Al día';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Color _getBorderColor(bool isDark) {
    switch (tramite.estado) {
      case EstadoTramite.vencido:
        return Colors.red.withOpacity(0.5);
      case EstadoTramite.pendiente:
        return (isDark ? AppColors.premiumGold : AppColors.lightAccent).withOpacity(0.5);
      case EstadoTramite.alDia:
        return Colors.green.withOpacity(0.3);
    }
  }

  String _getDaysRemainingText(int dias) {
    if (dias < 0) {
      return 'Vencido hace ${-dias} días';
    } else if (dias == 0) {
      return 'Vence hoy';
    } else if (dias == 1) {
      return 'Falta 1 día';
    } else {
      return 'Faltan $dias días';
    }
  }

  Color _getDaysRemainingColor(int dias, bool isDark) {
    if (dias < 0) {
      return Colors.red;
    } else if (dias <= 7) {
      return Colors.orange;
    } else {
      return isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    }
  }
}
