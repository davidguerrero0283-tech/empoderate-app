/// Default offline content for Obligaciones modules.
/// Used as fallback when remote JSON is unavailable.

import 'obligaciones_update_models.dart';

final Map<String, ObligacionesModuleUpdate> defaultObligacionesContent = {
  'css': ObligacionesModuleUpdate(
    moduleId: 'css',
    version: '2026.01.10',
    lastReviewed: '2026-01-10',
    summary: 'Gestión de cuotas obrero-patronales según la Caja de Seguro Social de Panamá.',
    keyPoints: [
      'Aporte del empleado: 9.75% del salario bruto.',
      'Aporte del empleador: 13.25% (escalonado según Ley 462).',
      'Presentación SIPE: hasta el día 20 de cada mes.',
      'Pago CSS: hasta el último día del mes sin recargo.',
    ],
    sources: [
      OfficialSource(title: 'SIPE - CSS', url: 'https://sipe.css.gob.pa/'),
      OfficialSource(title: 'Gaceta Oficial (Ley 462)', url: 'https://www.gacetaoficial.gob.pa/'),
    ],
    toolConfig: {
      'employeeRate': 0.0975,
      'employerRates': [
        {'from': '2025-03-01', 'rate': 0.1325},
        {'from': '2027-03-01', 'rate': 0.1425},
      ],
      'sipeDeadlineDay': 20,
    },
  ),
  'permisos': ObligacionesModuleUpdate(
    moduleId: 'permisos',
    version: '2026.01.10',
    lastReviewed: '2026-01-10',
    summary: 'Licencias y permisos laborales regulados por el Código de Trabajo y MITRADEL.',
    keyPoints: [
      'Licencia de paternidad: 3 días hábiles (Ley 27).',
      'Licencia de maternidad: 14 semanas (6 antes, 8 después del parto).',
      'Lactancia: tiempo para extracción dentro de jornada (Ley 135/2020).',
      'Subsidio maternidad CSS: requiere 9 cuotas en últimos 12 meses.',
    ],
    sources: [
      OfficialSource(title: 'MITRADEL - Licencias', url: 'https://www.mitradel.gob.pa/'),
      OfficialSource(title: 'CSS - Trámites', url: 'https://w3.css.gob.pa/'),
    ],
    toolConfig: {
      'paternityDays': 3,
      'maternityWeeks': 14,
      'maternityMinQuotas': 9,
    },
  ),
  'calendario': ObligacionesModuleUpdate(
    moduleId: 'calendario',
    version: '2026.01.10',
    lastReviewed: '2026-01-10',
    summary: 'Calendario de obligaciones laborales críticas para evitar multas.',
    keyPoints: [
      'SIPE: Presentación hasta día 20, pago hasta fin de mes.',
      'Décimo (XIII Mes): 15 de abril, 15 de agosto, 15 de diciembre.',
      'Vacaciones: mínimo 30 días después de 11 meses laborados.',
    ],
    sources: [
      OfficialSource(title: 'Gaceta Oficial (Décimos)', url: 'https://www.gacetaoficial.gob.pa/'),
      OfficialSource(title: 'SIPE - CSS', url: 'https://sipe.css.gob.pa/'),
    ],
    toolConfig: {
      'sipeDeadlineDay': 20,
      'decimoDates': ['04-15', '08-15', '12-15'],
    },
  ),
};
