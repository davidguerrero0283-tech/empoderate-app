import 'package:flutter/material.dart';

class BusinessRubro {
  final String id;
  final String name;
  final String description;
  final Color? color;
  
  // Enhanced List Fields
  final List<String> tags;
  final String? investmentLevel;
  final String? timeEstimate;

  const BusinessRubro({
    required this.id,
    required this.name,
    required this.description,
    this.color,
    this.tags = const [],
    this.investmentLevel,
    this.timeEstimate,
  });
}

class IndustryCategory {
  final String id;
  final String name;
  final IconData icon;
  final List<BusinessRubro> rubros;

  const IndustryCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.rubros,
  });
}

const List<IndustryCategory> categoryData = [
  IndustryCategory(
    id: 'food',
    name: 'Comidas / Restaurantes',
    icon: Icons.restaurant,
    rubros: [
      BusinessRubro(
        id: 'rest_small', 
        name: 'Restaurante pequeño', 
        description: 'Local físico con mesas.', 
        color: Colors.orangeAccent,
        tags: ['TRADICIONAL', 'ALTA DEMANDA'],
        investmentLevel: '\$\$\$',
        timeEstimate: '3-4 Meses',
      ),
      BusinessRubro(
        id: 'food_truck', 
        name: 'Food truck', 
        description: 'Venta de comida móvil.', 
        color: Colors.redAccent,
        tags: ['ALTA RENTABILIDAD', 'TENDENCIA'],
        investmentLevel: '\$\$',
        timeEstimate: '2 Meses',
      ),
      BusinessRubro(
        id: 'cafe', 
        name: 'Cafetería', 
        description: 'Café y postres.', 
        color: Colors.brown,
        tags: ['POPULAR'],
        investmentLevel: '\$\$',
        timeEstimate: '2-3 Meses',
      ),
      BusinessRubro(
        id: 'bakery', 
        name: 'Panadería / Repostería', 
        description: 'Pan y dulces.', 
        color: Colors.orange,
        tags: ['ESENCIAL'],
        investmentLevel: '\$\$',
        timeEstimate: '2 Meses',
      ),
      BusinessRubro(
        id: 'fast_food', 
        name: 'Puesto de comida rápida', 
        description: 'Comida al paso.', 
        color: Colors.red,
        tags: ['BAJA INVERSIÓN', 'RÁPIDO'],
        investmentLevel: '\$',
        timeEstimate: '1 Mes',
      ),
      BusinessRubro(
        id: 'catering', 
        name: 'Catering', 
        description: 'Servicio de comida para eventos.', 
        color: Colors.deepOrange,
        tags: ['BAJO RIESGO'],
        investmentLevel: '\$',
        timeEstimate: '1 Mes',
      ),
    ],
  ),
  IndustryCategory(
    id: 'beauty',
    name: 'Belleza / Estética',
    icon: Icons.brush,
    rubros: [
      BusinessRubro(
        id: 'barber', 
        name: 'Barbería', 
        description: 'Cortes y cuidado masculino.', 
        color: Colors.blueGrey,
        tags: ['POPULAR', 'FÁCIL INICIO'],
        investmentLevel: '\$',
        timeEstimate: '1 Mes',
      ),
      BusinessRubro(
        id: 'salon', 
        name: 'Salón de belleza', 
        description: 'Estética general.', 
        color: Colors.pinkAccent,
        tags: ['ALTA DEMANDA'],
        investmentLevel: '\$\$',
        timeEstimate: '2 Meses',
      ),
      BusinessRubro(
        id: 'spa', 
        name: 'Spa', 
        description: 'Relajación y masajes.', 
        color: Colors.teal,
        tags: ['PREMIUM'],
        investmentLevel: '\$\$\$',
        timeEstimate: '3 Meses',
      ),
      BusinessRubro(
        id: 'nails', 
        name: 'Uñas / Lash / Microblading', 
        description: 'Cuidado específico.', 
        color: Colors.purpleAccent,
        tags: ['ALTA RENTABILIDAD'],
        investmentLevel: '\$',
        timeEstimate: '1 Mes',
      ),
    ],
  ),
  IndustryCategory(
    id: 'retail',
    name: 'Comercio / Tiendas',
    icon: Icons.store,
    rubros: [
      BusinessRubro(
        id: 'minisuper', 
        name: 'Minisúper', 
        description: 'Venta de víveres.', 
        color: Colors.green,
        tags: ['ESENCIAL'],
        investmentLevel: '\$\$',
        timeEstimate: '2 Meses',
      ),
      BusinessRubro(
        id: 'clothing', 
        name: 'Tienda de ropa', 
        description: 'Moda y textiles.', 
        color: Colors.indigo,
        tags: ['ONLINE / FÍSICO'],
        investmentLevel: '\$\$',
        timeEstimate: '1 Mes',
      ),
      BusinessRubro(
        id: 'accessories', 
        name: 'Tienda de accesorios', 
        description: 'Bisutería y complementos.', 
        color: Colors.pink,
        tags: ['BAJA INVERSIÓN'],
        investmentLevel: '\$',
        timeEstimate: '1 Mes',
      ),
      BusinessRubro(
        id: 'healthy', 
        name: 'Tienda saludable', 
        description: 'Productos naturales.', 
        color: Colors.lightGreen,
        tags: ['NICHO'],
        investmentLevel: '\$\$',
        timeEstimate: '2 Meses',
      ),
    ],
  ),
  IndustryCategory(
    id: 'pro_services',
    name: 'Servicios Profesionales',
    icon: Icons.work,
    rubros: [
      BusinessRubro(id: 'consulting', name: 'Consultoría', description: 'Asesoría experta.', color: Colors.blue, tags: ['B2B'], investmentLevel: '\$', timeEstimate: 'Inmediato'),
      BusinessRubro(id: 'photo', name: 'Fotografía', description: 'Servicios visuales.', color: Colors.cyan, tags: ['CREATIVO'], investmentLevel: '\$', timeEstimate: '1 Mes'),
      BusinessRubro(id: 'admin', name: 'Administración', description: 'Gestión empresarial.', color: Colors.grey, tags: ['B2B'], investmentLevel: '\$', timeEstimate: 'Inmediato'),
      BusinessRubro(id: 'arch', name: 'Arquitectura / Diseño', description: 'Planos y espacios.', color: Colors.tealAccent, tags: ['PROFESIONAL'], investmentLevel: '\$', timeEstimate: 'Inmediato'),
    ],
  ),
  IndustryCategory(
    id: 'transport',
    name: 'Transporte',
    icon: Icons.directions_car,
    rubros: [
      BusinessRubro(id: 'private_transport', name: 'Transporte privado', description: 'Traslado de personas.', color: Colors.yellow, tags: ['AUTO PROPIO'], investmentLevel: '\$', timeEstimate: '1 Sem'),
      BusinessRubro(id: 'delivery', name: 'Moto-delivery', description: 'Entregas rápidas.', color: Colors.deepOrangeAccent, tags: ['RÁPIDO'], investmentLevel: '\$', timeEstimate: '1 Sem'),
      BusinessRubro(id: 'moving', name: 'Mudanzas', description: 'Traslado de bienes.', color: Colors.brown, tags: ['LOGÍSTICA'], investmentLevel: '\$\$', timeEstimate: '1 Mes'),
    ],
  ),
  IndustryCategory(
    id: 'education',
    name: 'Educación y Cursos',
    icon: Icons.school,
    rubros: [
      BusinessRubro(id: 'tutoring', name: 'Tutorías', description: 'Clases particulares.', color: Colors.lightBlue, tags: ['REMOTO'], investmentLevel: '\$', timeEstimate: 'Inmediato'),
      BusinessRubro(id: 'courses', name: 'Cursos presenciales', description: 'Talleres grupales.', color: Colors.blueAccent, tags: ['GRUPAL'], investmentLevel: '\$', timeEstimate: '1 Mes'),
      BusinessRubro(id: 'academy', name: 'Academia pequeña', description: 'Centro de enseñanza.', color: Colors.indigoAccent, tags: ['EDUCACIÓN'], investmentLevel: '\$\$', timeEstimate: '3 Meses'),
      BusinessRubro(id: 'music_art', name: 'Banda musical / Arte', description: 'Enseñanza artística.', color: Colors.purple, tags: ['ARTE'], investmentLevel: '\$', timeEstimate: '1 Mes'),
    ],
  ),
  IndustryCategory(
    id: 'health',
    name: 'Salud y Bienestar',
    icon: Icons.fitness_center,
    rubros: [
      BusinessRubro(id: 'trainer', name: 'Entrenador personal', description: 'Fitness guiado.', color: Colors.redAccent, tags: ['SALUD'], investmentLevel: '\$', timeEstimate: 'Certificación'),
      BusinessRubro(id: 'massage', name: 'Masajista', description: 'Terapia física.', color: Colors.teal, tags: ['BIENESTAR'], investmentLevel: '\$', timeEstimate: '1 Mes'),
      BusinessRubro(id: 'yoga', name: 'Yoga / Pilates', description: 'Bienestar cuerpo y mente.', color: Colors.lightGreenAccent, tags: ['TREND'], investmentLevel: '\$', timeEstimate: '1 Mes'),
    ],
  ),
  IndustryCategory(
    id: 'digital',
    name: 'Servicios Digitales',
    icon: Icons.computer,
    rubros: [
      BusinessRubro(id: 'marketing', name: 'Marketing digital', description: 'Gestión de redes.', color: Colors.purpleAccent, tags: ['REMOTO', 'ALTA DEMANDA'], investmentLevel: '\$', timeEstimate: 'Inmediato'),
      BusinessRubro(id: 'design', name: 'Diseño gráfico', description: 'Identidad visual.', color: Colors.pinkAccent, tags: ['REMOTO', 'CREATIVO'], investmentLevel: '\$', timeEstimate: 'Inmediato'),
      BusinessRubro(id: 'community', name: 'Community manager', description: 'Gestión de comunidades.', color: Colors.cyanAccent, tags: ['REMOTO'], investmentLevel: '\$', timeEstimate: 'Inmediato'),
      BusinessRubro(id: 'ecommerce', name: 'Ecommerce', description: 'Venta en línea.', color: Colors.blueAccent, tags: ['SCALABLE'], investmentLevel: '\$', timeEstimate: '1 Mes'),
    ],
  ),
  IndustryCategory(
    id: 'events',
    name: 'Eventos / Recepciones',
    icon: Icons.celebration,
    rubros: [
      BusinessRubro(id: 'decor', name: 'Decoración de eventos', description: 'Ambientación.', color: Colors.purpleAccent, tags: ['CREATIVO'], investmentLevel: '\$', timeEstimate: '1 Mes'),
      BusinessRubro(id: 'catering_events', name: 'Catering', description: 'Comida para fiestas.', color: Colors.deepOrange, tags: ['SERVICIO'], investmentLevel: '\$', timeEstimate: '1 Mes'),
      BusinessRubro(id: 'kids_party', name: 'Fiestas infantiles', description: 'Animación y juegos.', color: Colors.lightBlueAccent, tags: ['DIVERSIÓN'], investmentLevel: '\$', timeEstimate: '1 Mes'),
    ],
  ),
  IndustryCategory(
    id: 'home_biz',
    name: 'Emprendimientos desde Casa',
    icon: Icons.home_work,
    rubros: [
      BusinessRubro(id: 'desserts', name: 'Postres desde casa', description: 'Repostería casera.', color: Colors.pinkAccent, tags: ['CASERO', 'BAJA INVERSIÓN'], investmentLevel: '\$', timeEstimate: 'Inmediato'),
      BusinessRubro(id: 'jewelry', name: 'Bisutería', description: 'Accesorios hechos a mano.', color: Colors.amberAccent, tags: ['HANDMADE'], investmentLevel: '\$', timeEstimate: '1 Sem'),
      BusinessRubro(id: 'handmade', name: 'Ropa / Accesorios', description: 'Confección artesanal.', color: Colors.cyan, tags: ['CREATIVO'], investmentLevel: '\$', timeEstimate: '1 Sem'),
    ],
  ),
];
