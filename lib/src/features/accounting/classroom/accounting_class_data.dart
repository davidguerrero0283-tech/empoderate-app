import 'package:flutter/material.dart';

class AccountingClassData {
  // --- EXAMPLE DATASETS ---
  static const Map<String, dynamic> exampleDatasets = {
    'retail': {
      'name': 'Ejemplo Retail (Tienda de Ropa)',
      'sales': 12000.0,
      'fixedCosts': 4500.0,
      'varCostPct': 0.55, // 55%
      'budgetVsReal': [
        {'rubro': 'Ventas', 'presupuesto': 10000.0, 'real': 12000.0},
        {'rubro': 'Costo Mercadería', 'presupuesto': 5500.0, 'real': 6600.0},
        {'rubro': 'Alquiler', 'presupuesto': 1500.0, 'real': 1500.0},
        {'rubro': 'Nómina', 'presupuesto': 2500.0, 'real': 2800.0},
      ],
      'kpis': [
        {'kpi': 'Margen Bruto', 'formula': '(Ventas - Costos) / Ventas', 'meta': '> 40%', 'actual': '45%', 'status': 'ok'},
        {'kpi': 'Ticket Promedio', 'formula': 'Ventas / # Clientes', 'meta': '> \$25', 'actual': '\$22', 'status': 'warning'},
      ]
    },
    'restaurant': {
      'name': 'Ejemplo Restaurante',
      'sales': 18000.0,
      'fixedCosts': 7000.0,
      'varCostPct': 0.35, // 35% food cost
      'budgetVsReal': [
        {'rubro': 'Ventas', 'presupuesto': 15000.0, 'real': 18000.0},
        {'rubro': 'Insumos', 'presupuesto': 5250.0, 'real': 6300.0},
        {'rubro': 'Alquiler', 'presupuesto': 2000.0, 'real': 2000.0},
        {'rubro': 'Personal', 'presupuesto': 4500.0, 'real': 5200.0},
      ],
      'kpis': [
        {'kpi': 'Food Cost', 'formula': 'Costo Insumos / Ventas', 'meta': '< 35%', 'actual': '35%', 'status': 'ok'},
        {'kpi': 'Rotación Mesa', 'formula': 'Clientes / Mesas', 'meta': '> 3', 'actual': '2.5', 'status': 'warning'},
      ]
    },
     'services': {
      'name': 'Ejemplo Servicios (Consultoría)',
      'sales': 8000.0,
      'fixedCosts': 2000.0,
      'varCostPct': 0.10, // 10%
      'budgetVsReal': [
        {'rubro': 'Ventas', 'presupuesto': 7500.0, 'real': 8000.0},
        {'rubro': 'Materiales', 'presupuesto': 500.0, 'real': 800.0},
        {'rubro': 'Software/SaaS', 'presupuesto': 300.0, 'real': 300.0},
        {'rubro': 'Honorarios', 'presupuesto': 1000.0, 'real': 1200.0},
      ],
      'kpis': [
        {'kpi': 'Margen Neto', 'formula': 'Utilidad / Ventas', 'meta': '> 50%', 'actual': '65%', 'status': 'ok'},
      ]
    },
  };

  // --- GUIDES CONTENT ---
  static const List<Map<String, dynamic>> guides = [
    {
      'title': 'Presupuesto y Control',
      'whatIs': 'Comparar lo que planeaste gastar vs. lo que realmente gastaste.',
      'howTo': [
        'Define tus ingresos estimados.',
        'Asigna límites para gastos fijos y variables.',
        'Revisa a fin de mes y ajusta desviaciones.'
      ],
      'alerts': [
        'Gastar más del 30% en alquiler.',
        'No guardar fondo de emergencia.'
      ],
      'toolId': 'budget',
    },
    {
      'title': 'Costos y Rentabilidad',
      'whatIs': 'Entender cuánto te cuesta producir y cuánto ganas por unidad.',
      'howTo': [
        'Separa costos fijos (luz, alquiler) de variables (insumos).',
        'Calcula tu punto de equilibrio.',
        'Vigila el margen por producto.'
      ],
      'alerts': [
        'Mezclar dinero personal con el del negocio.',
        'Ignorar costos ocultos como depreciación.'
      ],
      'toolId': 'margin',
    },
    {
      'title': 'Flujo de Caja',
      'whatIs': 'El dinero real que entra y sale de tu cuenta hoy.',
      'howTo': [
        'Registra cada cobro y cada pago diario.',
        'Proyecta tus pagos fuertes de fin de mes.',
        'No confundas ventas a crédito con dinero en mano.'
      ],
      'alerts': [
        'Quedarse sin efectivo para nómina.',
        'Vender mucho pero no cobrar a tiempo.'
      ],
      'toolId': 'cash_flow',
    },
    {
      'title': 'KPIs Clave',
      'whatIs': 'Indicadores que dicen si tu negocio está sano.',
      'howTo': [
        'Mide Margen Bruto: (Ventas - Costos) / Ventas.',
        'Mide Ticket Promedio: Ventas totales / # Clientes.',
        'Mide Retención: ¿Cuántos clientes vuelven?'
      ],
      'alerts': [
        'Margen bajando mes a mes.',
        'Aumento de gastos fijos sin aumento de ventas.'
      ],
      'toolId': null,
    },
    {
      'title': 'Decisiones Típicas (Qué hacer si...)',
      'whatIs': 'Estrategias para situaciones comunes.',
      'howTo': [
        'Si falta efectivo: Negocia plazos con proveedores.',
        'Si baja la venta: Revisa precios o haz promociones puntuales.',
        'Si sube el costo: Busca insumos alternativos o ajusta precios.'
      ],
      'alerts': [
        'Pedir préstamo para pagar deudas corrientes.',
        'Bajar precios desesperadamente sin analizar margen.'
      ],
      'toolId': 'break_even',
    },
  ];
}
