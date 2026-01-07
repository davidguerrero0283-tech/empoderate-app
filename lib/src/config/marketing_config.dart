import 'package:flutter/material.dart';
import '../navigation/app_routes.dart';

class MarketingToolConfig {
  final String id;
  final String title;
  final String subtitle;
  final String route;
  final IconData icon;
  final Color color;

  const MarketingToolConfig({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.route,
    required this.icon,
    required this.color,
  });
}

// Centralized List of Marketing Tools
final List<MarketingToolConfig> marketingTools = [
  const MarketingToolConfig(
    id: 'automation',
    title: 'Automatización IA',
    subtitle: 'Multi-Plataforma',
    route: AppRoutes.marketingAutomation,
    icon: Icons.auto_awesome,
    color: Color(0xFFD500F9), // Magenta Neon
  ),
  const MarketingToolConfig(
    id: 'content_ia',
    title: 'Contenido IA',
    subtitle: 'Generador de Ideas',
    route: AppRoutes.marketingContent,
    icon: Icons.lightbulb_outline,
    color: Color(0xFFAA00FF), // Purple
  ),
  const MarketingToolConfig(
    id: 'funnel',
    title: 'Embudo de Ventas',
    subtitle: 'Diseñador',
    route: AppRoutes.marketingFunnel,
    icon: Icons.filter_alt_outlined,
    color: Color(0xFF448AFF), // Blue Neon
  ),
  const MarketingToolConfig(
    id: 'campaigns',
    title: 'Campañas',
    subtitle: 'Planificador',
    route: AppRoutes.marketingCampaigns,
    icon: Icons.campaign_outlined,
    color: Colors.orangeAccent,
  ),
  const MarketingToolConfig(
    id: 'avatar',
    title: 'Cliente Ideal',
    subtitle: 'Definir Avatar',
    route: AppRoutes.marketingAvatar,
    icon: Icons.person_search_outlined,
    color: Colors.cyanAccent,
  ),
];
