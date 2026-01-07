import 'package:flutter/material.dart';
import '../../ui/theme/empoderate_theme.dart';
import '../components/premium_scaffold.dart';

class MissionHistoryDetailScreen extends StatelessWidget {
  final String title;
  final String date;
  final String description;
  final bool isDaily;

  const MissionHistoryDetailScreen({
    Key? key,
    required this.title,
    required this.date,
    required this.description,
    required this.isDaily,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'DETALLE MISIÓN',
      showBackButton: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: EmpoderateTheme.glass,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: EmpoderateTheme.goldStrong.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isDaily ? Icons.star : Icons.emoji_events,
                      color: EmpoderateTheme.goldStrong,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isDaily ? 'Misión Diaria' : 'Misión Semanal',
                            style: EmpoderateTheme.titleStyle.copyWith(
                              color: EmpoderateTheme.goldStrong,
                              fontSize: 14,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            title,
                            style: EmpoderateTheme.titleStyle.copyWith(
                              color: EmpoderateTheme.white,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildInfoRow(Icons.calendar_today, 'Completada el:', date),
                const SizedBox(height: 24),
                const Divider(color: Colors.white10),
                const SizedBox(height: 24),
                Text(
                  'Descripción',
                  style: EmpoderateTheme.titleStyle.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  description, 
                  style: EmpoderateTheme.subtitleStyle.copyWith(
                    color: EmpoderateTheme.white,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Aquí irá la explicación completa, pasos realizados y detalles adicionales sobre cómo se completó esta misión exitosamente.',
                  style: EmpoderateTheme.subtitleStyle.copyWith(
                    color: Colors.white54,
                    fontSize: 14,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 32),
                _buildRewardsSection(),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: EmpoderateTheme.goldStrong,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(
                'VOLVER AL HISTORIAL',
                style: EmpoderateTheme.titleStyle.copyWith(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 18),
        const SizedBox(width: 12),
        Text(
          label,
          style: EmpoderateTheme.subtitleStyle.copyWith(fontSize: 14),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: EmpoderateTheme.titleStyle.copyWith(color: EmpoderateTheme.white, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildRewardsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recompensas Obtenidas',
          style: EmpoderateTheme.titleStyle.copyWith(
            color: EmpoderateTheme.goldStrong,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildRewardItem(Icons.monetization_on, '50 Monedas'),
            const SizedBox(width: 16),
            _buildRewardItem(Icons.star, '100 XP'),
            const SizedBox(width: 16),
            _buildRewardItem(Icons.upgrade, 'Nivel +'),
          ],
        ),
      ],
    );
  }

  Widget _buildRewardItem(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: EmpoderateTheme.glass,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: EmpoderateTheme.goldStrong.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: EmpoderateTheme.goldStrong, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: EmpoderateTheme.titleStyle.copyWith(
              color: EmpoderateTheme.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
