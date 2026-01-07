// Summary Cards Widget
// Shows quick stats: Próximos 7 días, Vencidos, Este mes

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../ui/theme/color_palette.dart';
import '../../domain/tramite_event.dart';

class SummaryCardsWidget extends StatelessWidget {
  final List<TramiteEvent> tramites;

  const SummaryCardsWidget({Key? key, required this.tramites}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();

    // Calculate stats
    final proximos7Dias = tramites.where((t) {
      final diff = t.proximaFecha.difference(now).inDays;
      return diff >= 0 && diff <= 7;
    }).length;

    final vencidos = tramites.where((t) {
      return t.proximaFecha.isBefore(now);
    }).length;

    final esteMes = tramites.where((t) {
      return t.proximaFecha.month == now.month && 
             t.proximaFecha.year == now.year;
    }).length;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            context,
            isDark,
            'Próximos 7 días',
            proximos7Dias.toString(),
            Icons.event_available,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            context,
            isDark,
            'Vencidos',
            vencidos.toString(),
            Icons.warning_amber,
            Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            context,
            isDark,
            'Este mes',
            esteMes.toString(),
            Icons.calendar_month,
            isDark ? AppColors.premiumGold : AppColors.lightAccent,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    bool isDark,
    String label,
    String value,
    IconData icon,
    Color accentColor,
  ) {
    return Card(
      elevation: isDark ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: isDark ? AppColors.surface : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              color: accentColor,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 11,
                color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
