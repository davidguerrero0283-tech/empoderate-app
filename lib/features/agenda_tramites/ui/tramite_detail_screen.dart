// Tramite Detail Screen
// View full tramite details with actions

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../ui/theme/color_palette.dart';
import '../domain/tramite_event.dart';
import '../domain/agenda_rules.dart';
import '../data/agenda_repository.dart';
import 'tramite_form_screen.dart';

class TramiteDetailScreen extends StatelessWidget {
  final TramiteEvent tramite;

  const TramiteDetailScreen({Key? key, required this.tramite}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final diasRestantes = AgendaRules.diasRestantes(tramite.proximaFecha);

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.background : Colors.white,
        elevation: 0,
        title: Text(
          'Detalle del Trámite',
          style: GoogleFonts.outfit(
            color: isDark ? AppColors.premiumGold : AppColors.lightTextPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(
          color: isDark ? AppColors.premiumGold : AppColors.lightAccent,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TramiteFormScreen(tramite: tramite),
                ),
              );
              if (result == true && context.mounted) {
                Navigator.pop(context, true);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmarEliminar(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Card
            Card(
              elevation: isDark ? 4 : 2,
              color: isDark ? AppColors.surface : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tramite.titulo,
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.premiumGold : AppColors.lightAccent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatusBadge(isDark),
                        const SizedBox(width: 12),
                        Text(
                          tramite.entidad,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Details Card
            Card(
              elevation: isDark ? 4 : 2,
              color: isDark ? AppColors.surface : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                      isDark,
                      'Próxima fecha',
                      DateFormat('dd/MM/yyyy').format(tramite.proximaFecha),
                      Icons.calendar_today,
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      isDark,
                      'Días restantes',
                      _getDaysRemainingText(diasRestantes),
                      Icons.timer,
                      valueColor: _getDaysRemainingColor(diasRestantes, isDark),
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      isDark,
                      'Periodicidad',
                      tramite.periodicidad.displayName,
                      Icons.repeat,
                    ),
                    if (tramite.cadaXDias != null) ...[
                      const Divider(height: 24),
                      _buildDetailRow(
                        isDark,
                        'Cada',
                        '${tramite.cadaXDias} días',
                        Icons.event_repeat,
                      ),
                    ],
                    const Divider(height: 24),
                    _buildDetailRow(
                      isDark,
                      'Alertas',
                      '${tramite.diasAnticipacionAlerta} días antes',
                      Icons.notifications_active,
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      isDark,
                      'Categoría',
                      tramite.categoria.displayName,
                      Icons.category,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description Card
            if (tramite.descripcion.isNotEmpty)
              Card(
                elevation: isDark ? 4 : 2,
                color: isDark ? AppColors.surface : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Descripción',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.premiumGold : AppColors.lightAccent,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        tramite.descripcion,
                        style: GoogleFonts.outfit(
                          color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (tramite.descripcion.isNotEmpty)
              const SizedBox(height: 16),

            // Notes Card
            if (tramite.notas != null && tramite.notas!.isNotEmpty)
              Card(
                elevation: isDark ? 4 : 2,
                color: isDark ? AppColors.surface : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notas',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.premiumGold : AppColors.lightAccent,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        tramite.notas!,
                        style: GoogleFonts.outfit(
                          color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 32),

            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _marcarRealizado(context),
                icon: const Icon(Icons.check_circle),
                label: const Text('Marcar como Realizado'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: isDark ? AppColors.premiumGold : AppColors.lightAccent,
                  foregroundColor: isDark ? AppColors.background : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    bool isDark,
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark ? AppColors.premiumGold : AppColors.lightAccent,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? (isDark ? AppColors.textPrimary : AppColors.lightTextPrimary),
                ),
              ),
            ],
          ),
        ),
      ],
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

  Future<void> _marcarRealizado(BuildContext context) async {
    final repository = AgendaRepository();
    final updated = AgendaRules.marcarRealizado(tramite);
    await repository.upsert(updated);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trámite marcado como realizado')),
      );
      Navigator.pop(context, true);
    }
  }

  Future<void> _confirmarEliminar(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar trámite'),
        content: const Text('¿Estás seguro de que deseas eliminar este trámite?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final repository = AgendaRepository();
      await repository.delete(tramite.id);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trámite eliminado')),
        );
        Navigator.pop(context, true);
      }
    }
  }
}
