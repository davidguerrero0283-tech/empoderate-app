import 'package:flutter/material.dart';
import '../../ui/theme/empoderate_theme.dart';
import '../components/premium_scaffold.dart';
import '../models/notification_data.dart';

class NotificationDetailScreen extends StatelessWidget {
  final AppNotification notification;

  const NotificationDetailScreen({Key? key, required this.notification}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'DETALLE',
      showBackButton: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: notification.categoryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: notification.categoryColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(notification.categoryIcon, size: 16, color: notification.categoryColor),
                const SizedBox(width: 8),
                Text(
                  notification.categoryName.toUpperCase(),
                  style: EmpoderateTheme.titleStyle.copyWith(
                    color: notification.categoryColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          Text(
            notification.title,
            style: EmpoderateTheme.titleStyle.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 8),
          
          Text(
            'Recibido: ${_formatDate(notification.date)}',
            style: EmpoderateTheme.subtitleStyle,
          ),
          
          const SizedBox(height: 32),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: EmpoderateTheme.glass,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Text(
              notification.detailedContent ?? notification.description,
              style: EmpoderateTheme.subtitleStyle.copyWith(color: EmpoderateTheme.white.withOpacity(0.7), height: 1.5),
            ),
          ),
          
          const SizedBox(height: 32),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: EmpoderateTheme.goldStrong,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Navegación a sección relacionada — Próximamente')),
                );
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Ir a la sección relacionada'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
