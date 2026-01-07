import 'package:flutter/material.dart';

class ShopCategory {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;

  const ShopCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

const List<ShopCategory> shopCategories = [
  ShopCategory(
    id: 'guides',
    title: 'Guías Avanzadas',
    subtitle: 'Contenido premium para emprendedores',
    icon: Icons.menu_book,
  ),
  ShopCategory(
    id: 'templates',
    title: 'Plantillas Profesionales',
    subtitle: 'Formatos listos para usar',
    icon: Icons.copy,
  ),
  ShopCategory(
    id: 'ai_premium',
    title: 'Funciones Premium IA',
    subtitle: 'Potencia tu asistente inteligente',
    icon: Icons.psychology,
  ),
  ShopCategory(
    id: 'packs',
    title: 'Packs por Rubro',
    subtitle: 'Kits completos para tu nicho',
    icon: Icons.inventory_2,
  ),
  ShopCategory(
    id: 'visuals',
    title: 'Mejoras Visuales',
    subtitle: 'Skins, iconos y temas',
    icon: Icons.palette,
  ),
  ShopCategory(
    id: 'productivity',
    title: 'Herramientas Productividad',
    subtitle: 'Organización para líderes',
    icon: Icons.timer,
  ),
];
