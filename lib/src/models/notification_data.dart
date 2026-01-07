import 'package:flutter/material.dart';

enum NotificationCategory {
  misiones,
  progreso,
  ia,
  recordatorios,
}

class AppNotification {
  final String id;
  final String title;
  final String description;
  final NotificationCategory category;
  final DateTime date;
  final bool isRead;
  final String? detailedContent;

  const AppNotification({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.date,
    this.isRead = false,
    this.detailedContent,
  });

  Color get categoryColor {
    switch (category) {
      case NotificationCategory.misiones:
        return const Color(0xFFD4AF37); // Gold
      case NotificationCategory.progreso:
        return Colors.blue; 
      case NotificationCategory.ia:
        return Colors.purpleAccent;
      case NotificationCategory.recordatorios:
        return Colors.orangeAccent;
    }
  }

  IconData get categoryIcon {
    switch (category) {
      case NotificationCategory.misiones:
        return Icons.star;
      case NotificationCategory.progreso:
        return Icons.trending_up;
      case NotificationCategory.ia:
        return Icons.psychology;
      case NotificationCategory.recordatorios:
        return Icons.access_time;
    }
  }
  
  String get categoryName {
    switch (category) {
      case NotificationCategory.misiones:
        return 'Misiones';
      case NotificationCategory.progreso:
        return 'Progreso';
      case NotificationCategory.ia:
        return 'IA y Recomendaciones';
      case NotificationCategory.recordatorios:
        return 'Recordatorios';
    }
  }
}

final List<AppNotification> mockNotifications = [
  AppNotification(
    id: '1',
    title: 'Misión diaria disponible',
    description: 'Completa una acción hoy para avanzar tu negocio.',
    category: NotificationCategory.misiones,
    date: DateTime.now(),
    isRead: false,
    detailedContent: 'Tienes 3 nuevas misiones diarias disponibles. Complétalas antes de medianoche para ganar monedas extra y subir de nivel.',
  ),
  AppNotification(
    id: '2',
    title: 'Paso 5 completado',
    description: 'Has finalizado "Paz y Salvo". ¡Sigue así!',
    category: NotificationCategory.progreso,
    date: DateTime.now().subtract(const Duration(hours: 2)),
    isRead: true,
    detailedContent: 'Felicidades por completar el paso 5 de la Fase 1. El siguiente paso es "Registro DGI". Prepárate consultando la guía rápida.',
  ),
  AppNotification(
    id: '3',
    title: 'Consejo de IA',
    description: 'Optimiza tus posts de Instagram con estos tips.',
    category: NotificationCategory.ia,
    date: DateTime.now().subtract(const Duration(days: 1)),
    isRead: false,
    detailedContent: 'Nuestra IA de Marketing ha analizado tendencias recientes. Te sugerimos publicar reels cortos mostrando el proceso de tu producto para aumentar el alcance.',
  ),
  AppNotification(
    id: '4',
    title: 'Revisar impuestos',
    description: 'Recuerda preparar tu declaración mensual.',
    category: NotificationCategory.recordatorios,
    date: DateTime.now().subtract(const Duration(days: 2)),
    isRead: true,
    detailedContent: 'Es fin de mes. Recuerda revisar tus facturas y preparar la declaración de ITBMS. Usa la calculadora de impuestos para facilitar el trabajo.',
  ),
  AppNotification(
    id: '5',
    title: 'Recompensa semanal',
    description: 'Has ganado 50 XP por constancia.',
    category: NotificationCategory.misiones,
    date: DateTime.now().subtract(const Duration(days: 3)),
    isRead: true,
    detailedContent: '¡Excelente trabajo! Has completado todas las misiones de la semana pasada. Disfruta de tu recompensa de XP y monedas.',
  ),
];
