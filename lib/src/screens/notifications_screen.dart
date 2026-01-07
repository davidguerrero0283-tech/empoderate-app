import 'package:flutter/material.dart';
import '../../ui/theme/empoderate_theme.dart';
import '../components/premium_scaffold.dart';
import '../models/notification_data.dart';
import 'notification_detail_screen.dart';
import '../components/info_button.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Group notifications
    final missions = mockNotifications.where((n) => n.category == NotificationCategory.misiones).toList();
    final progress = mockNotifications.where((n) => n.category == NotificationCategory.progreso).toList();
    final ai = mockNotifications.where((n) => n.category == NotificationCategory.ia).toList();
    final reminders = mockNotifications.where((n) => n.category == NotificationCategory.recordatorios).toList();

    return PremiumScaffold(
      title: 'NOTIFICACIONES',
      showBackButton: true,
      floatingActionButton: InfoButton(
        title: 'Cómo funcionan las Notificaciones en Empodérate',
        content: '''
La sección de Notificaciones es el lugar donde recibirás todos los avisos importantes relacionados con tu avance dentro de Empodérate y el estado de tu negocio. Aquí encontrarás recordatorios, alertas, sugerencias personalizadas y mensajes generados por la IA, organizados de manera clara para que no pierdas información relevante.

Las notificaciones pueden recordarte tareas pendientes, misiones diarias, avances en la Ruta del Emprendedor, vencimientos de trámites, actualizaciones importantes, recomendaciones financieras, oportunidades de aprendizaje y avisos sobre herramientas relevantes para tu negocio. Cada notificación tiene el propósito de ayudarte a mantener orden y evitar que se te pase algo importante.

Algunas notificaciones se generan según tu actividad dentro de la app; por ejemplo, si no has revisado tus costos en varios días, si tienes una misión sin completar, o si la IA detecta que tu negocio podría mejorar en alguna área específica. Otras notificaciones están relacionadas con tus preferencias y ajustes, para que solo recibas lo que te sea útil.

Esta sección también puede funcionar como un historial: si no viste una notificación antes, puedes revisarla más tarde y ponerte al día. La idea es que siempre tengas claridad sobre lo que ocurre dentro de tu proceso de emprendimiento sin sentirte abrumado.

El Centro de Avisos es una herramienta clave para apoyarte en tu crecimiento, mantener tu estructura y prepararte para los siguientes pasos.
''' 
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Alertas y Novedades',
            style: EmpoderateTheme.subtitleStyle,
          ),
          const SizedBox(height: 24),
          
          if (missions.isNotEmpty) ...[
            _buildSectionHeader('Misiones', Icons.star, EmpoderateTheme.goldStrong),
            ...missions.map((n) => _NotificationCard(notification: n)).toList(),
            const SizedBox(height: 20),
          ],
    
          if (progress.isNotEmpty) ...[
            _buildSectionHeader('Progreso del Negocio', Icons.trending_up, Colors.blue),
            ...progress.map((n) => _NotificationCard(notification: n)).toList(),
            const SizedBox(height: 20),
          ],
    
          if (ai.isNotEmpty) ...[
            _buildSectionHeader('IA y Recomendaciones', Icons.psychology, Colors.purpleAccent),
            ...ai.map((n) => _NotificationCard(notification: n)).toList(),
            const SizedBox(height: 20),
          ],
          
          if (reminders.isNotEmpty) ...[
            _buildSectionHeader('Recordatorios Importantes', Icons.access_time, Colors.orangeAccent),
            ...reminders.map((n) => _NotificationCard(notification: n)).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: EmpoderateTheme.titleStyle.copyWith(
              color: EmpoderateTheme.white,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;

  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotificationDetailScreen(notification: notification),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead 
              ? EmpoderateTheme.glass.withOpacity(0.02)
              : EmpoderateTheme.glass,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notification.isRead 
                ? Colors.white10 
                : notification.categoryColor.withOpacity(0.5),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: notification.categoryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(notification.categoryIcon, color: notification.categoryColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: EmpoderateTheme.titleStyle.copyWith(
                            color: EmpoderateTheme.white,
                            fontSize: 16,
                            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        'Hoy', 
                        style: EmpoderateTheme.subtitleStyle.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.description,
                    style: EmpoderateTheme.subtitleStyle.copyWith(fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Ver detalle',
                        style: EmpoderateTheme.titleStyle.copyWith(
                          color: notification.categoryColor,
                          fontSize: 12,
                        ),
                      ),
                      Icon(Icons.chevron_right, color: notification.categoryColor, size: 14),
                    ],
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
