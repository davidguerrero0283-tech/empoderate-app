import 'package:flutter/material.dart';

// --- MODELS ---

class VaultMetadata {
  final String docType; // e.g., "RUC", "AVISO_OPERACION"
  final String category; // e.g., "Impuestos / DGI"
  final List<String> tags; // e.g., ["DGI", "RUC"]
  final String evidenceHint; // e.g., "Sube PDF o captura"

  const VaultMetadata({
    required this.docType,
    required this.category,
    required this.tags,
    required this.evidenceHint,
  });
}

class RequirementItem {
  final String id;
  final String title;
  final String shortDesc;
  final IconData icon;
  final String whatIsIt; // Qué es
  final List<String> whyNeeded; // Por qué lo necesitas
  final List<String> steps; // Pasos típicos
  final List<String> commonRequirements; // Requisitos comunes
  final List<String> tips; // Errores frecuentes / Tips
  final Map<String, String> officialLinks; // Label -> URL
  
  final bool vaultEnabled;
  final VaultMetadata? vaultMeta;

  const RequirementItem({
    required this.id,
    required this.title,
    required this.shortDesc,
    required this.icon,
    required this.whatIsIt,
    required this.whyNeeded,
    required this.steps,
    required this.commonRequirements,
    required this.tips,
    required this.officialLinks,
    this.vaultEnabled = false,
    this.vaultMeta,
  });
}

class BusinessSection {
  final String id;
  final String title;
  final List<RequirementItem> items;

  const BusinessSection({
    required this.id,
    required this.title,
    required this.items,
  });
}

class BusinessModelContent {
  final String id;
  final String title;
  final List<BusinessSection> sections;

  const BusinessModelContent({
    required this.id,
    required this.title,
    required this.sections,
  });
}

// --- CONTENT REPOSITORY ---

/// Helper for official links
const kLinkDGI = 'https://dgi.mef.gob.pa/';
const kLinkPanamaEmprende = 'https://www.panamaemprende.gob.pa/';
const kLinkMitradel = 'https://www.mitradel.gob.pa/';
const kLinkMinsa = 'https://www.minsa.gob.pa/';
const kLinkDigerpi = 'https://www.digerpi.gob.pa/';
const kLinkBomberos = 'https://www.bomberos.gob.pa/';

/// List of all defined business models for global lookup
final List<BusinessModelContent> allBusinessModels = [
  restaurantSmallContent,
  foodTruckContent,
  cafeContent,
  bakeryContent,
  fastFoodContent,
  cateringContent,
  barberContent,
  // salonContent, // Add others as they are defined...
];

/// Global helper to find a requirement by ID across all models
RequirementItem? getRequirementById(String id) {
  for (final model in allBusinessModels) {
    for (final section in model.sections) {
      for (final item in section.items) {
        if (item.id == id) return item;
      }
    }
  }
  return null;
}

/// Content for "Restaurante pequeño"
final restaurantSmallContent = BusinessModelContent(
  id: 'restaurante_pequeno', // Must match ID used in navigation if present
  title: 'Restaurante Pequeño',
  sections: [
    // 1) Requisitos Legales
    BusinessSection(
      id: 'legales',
      title: '1. Requisitos Legales',
      items: [
        RequirementItem(
          id: 'ruc_dgi',
          title: 'Registro Único de Contribuyente (RUC)',
          shortDesc: 'Registro base ante la DGI para operar legalmente.',
          icon: Icons.assignment_ind_outlined,
          whatIsIt: 'Es el número de identificación tributaria de tu empresa (o personal si eres persona natural) ante la Dirección General de Ingresos (DGI).',
          whyNeeded: [
            'Obligatorio para facturar y pagar impuestos.',
            'Requisito previo para el Aviso de Operación.',
            'Evita sanciones por operar en la informalidad.',
          ],
          steps: [
            'Ingresa al sistema e-Tax 2.0 de la DGI.',
            'Llena el formulario de inscripción (Persona Natural o Jurídica).',
            'Adjunta cédula o pacto social según corresponda.',
            'Recibirás tu número de RUC y DIGITO VERIFICADOR (DV).',
          ],
          commonRequirements: [
            'Cédula de identidad vigente.',
            'Pacto Social (si es sociedad).',
            'Recibo de utilidad pública (agua/luz) del domicilio.',
          ],
          tips: [
            'Si eres Persona Natural, tu RUC suele ser tu cédula con DV 00 o similar.',
            'Conserva tu NIT (clave de acceso) en lugar seguro.',
          ],
          officialLinks: {'DGI Panamá': kLinkDGI},
          vaultEnabled: true,
          vaultMeta: VaultMetadata(
            docType: 'RUC',
            category: 'Impuestos / DGI',
            tags: ['DGI', 'RUC', 'Legal'],
            evidenceHint: 'Sube tu Certificado de Inscripción',
          ),
        ),
        RequirementItem(
          id: 'aviso_operacion',
          title: 'Aviso de Operación',
          shortDesc: 'La licencia comercial para abrir al público.',
          icon: Icons.storefront_outlined,
          whatIsIt: 'Es la licencia que notifica al Estado que vas a iniciar una actividad comercial. Se tramita vía "Panamá Emprende".',
          whyNeeded: [
            'Es ilegal abrir al público sin este aviso.',
            'Lo solicitan bancos, proveedores y municipios.',
            'Define tus actividades y obligaciones fiscales.',
          ],
          steps: [
            'Tener el RUC activo.',
            'Registrarse en www.panamaemprende.gob.pa.',
            'Llenar la solicitud declarando actividad, ubicación y metros del local.',
            'Pagar la tasa correspondiente (varía por actividad).',
          ],
          commonRequirements: [
            'RUC y datos del representante legal.',
            'Ubicación exacta del local.',
            'Cantidad de empleados estimada.',
          ],
          tips: [
            'Verifica bien la "Actividad Económica" para evitar problemas de zonificación.',
            'Imprime el Aviso y colócalo en lugar visible del local.',
          ],
          officialLinks: {'Panamá Emprende': kLinkPanamaEmprende},
          vaultEnabled: true,
          vaultMeta: VaultMetadata(
            docType: 'AVISO_OPERACION',
            category: 'Legal / Panamá Emprende',
            tags: ['AvisoOperacion', 'Legal', 'Licencia'],
            evidenceHint: 'Sube el PDF del Aviso generado',
          ),
        ),
        RequirementItem(
          id: 'registro_marca',
          title: 'Registro de Marca (Opcional)',
          shortDesc: 'Protege el nombre y logo de tu restaurante.',
          icon: Icons.verified_outlined, // Changed to outline
          whatIsIt: 'Trámite ante la DIGERPI para tener derecho exclusivo sobre el nombre y logo de tu negocio.',
          whyNeeded: [
            'Evita que otros usen tu nombre.',
            'Te da valor comercial y seriedad.',
            'Vital si planeas franquiciar a futuro.',
          ],
          steps: [
            'Búsqueda de antecedentes (verificar si el nombre está libre).',
            'Solicitud de registro mediante abogado.',
            'Publicación en el BORME (Boletín oficial).',
            'Emisión del certificado (si no hay oposiciones).',
          ],
          commonRequirements: [
            'Logo en formato digital.',
            'Poder a un abogado idóneo.',
            'Pago de tasas de registro.',
          ],
          tips: [
            'Es un proceso que toma meses; inícialo pronto si tu marca es clave.',
            'No inviertas en letreros caros hasta estar seguro de que la marca es registrable.',
          ],
          officialLinks: {'DIGERPI': kLinkDigerpi},
          vaultEnabled: true,
          vaultMeta: VaultMetadata(
            docType: 'REGISTRO_MARCA',
            category: 'Propiedad Intelectual',
            tags: ['Marca', 'DIGERPI', 'Logo'],
            evidenceHint: 'Certificado de Registro o Solicitud',
          ),
        ),
      ],
    ),
    
    // 2) Permisos y Salud
    BusinessSection(
      id: 'salud',
      title: '2. Permisos y Salud',
      items: [
        RequirementItem(
          id: 'permiso_sanitario',
          title: 'Permiso Sanitario de Operación',
          shortDesc: 'Autorización de MINSA para locales de alimentos.',
          icon: Icons.health_and_safety_outlined,
          whatIsIt: 'Certificado emitido por el Ministerio de Salud (MINSA) que avala que tu local cumple normas de higiene.',
          whyNeeded: [
            'Obligatorio para vender comida.',
            'Garantiza seguridad a tus clientes.',
            'Evita clausuras inmediatas por inspección.',
          ],
          steps: [
            'Adecuar el local (trampas de grasa, superficies lavables, etc.).',
            'Solicitar inspección al Centro de Salud regional.',
            'Pasar la inspección sanitaria.',
            'Pagar las tasas correspondientes.',
          ],
          commonRequirements: [
            'Croquis del local.',
            'Fumigación vigente.',
            'Personal con carnés de salud.',
          ],
          tips: [
            'La trampa de grasa es el punto #1 de fallo en inspecciones.',
            'Mantén bitácoras de limpieza visibles.',
          ],
          officialLinks: {'MINSA': kLinkMinsa},
        ),
        RequirementItem(
          id: 'carnes_salud',
          title: 'Carnés de Salud (Manipuladores)',
          shortDesc: 'Blanco y Verde para todo el personal.',
          icon: Icons.badge_outlined,
          whatIsIt: 'Documentos personales que certifican buena salud (Blanco) y capacitación en manipulación (Verde).',
          whyNeeded: [
            'Ninguna persona puede tocar alimentos sin ellos.',
            'Multas severas por cada empleado sin carné.',
          ],
          steps: [
            'Exámenes médicos (laboratorio, odontología).',
            'Tramitar Carné Blanco (buena salud) en Centro de Salud.',
            'Asistir a curso de manipulación de alimentos.',
            'Obtener Carné Verde (adiestramiento).',
          ],
          commonRequirements: [
            'Fotos tamaño carné.',
            'Cédula vigente.',
            'Resultados de laboratorios.',
          ],
          tips: [
            'El Carné Blanco vence anualmente; el Verde cada 5 años (varía).',
            'No permitas personal en cocina sin carné, es riesgo crítico.',
          ],
          officialLinks: {'MINSA': kLinkMinsa},
        ),
      ],
    ),
    
    // 3) Municipales y Seguridad
    BusinessSection(
      id: 'municipales',
      title: '3. Municipales y Seguridad',
      items: [
        RequirementItem(
          id: 'municipio',
          title: 'Inscripción y Rótulos Municipales',
          shortDesc: 'Pago de impuestos municipales y publicidad exterior.',
          icon: Icons.account_balance_outlined,
          whatIsIt: 'Registro en el Municipio de tu distrito (ej: Panamá, San Miguelito) para pagar impuestos locales.',
          whyNeeded: [
            'Obligatorio tras sacar el Aviso de Operación.',
            'Permite colocar letreros legalmente.',
          ],
          steps: [
            'Presentar Aviso de Operación en el Municipio.',
            'Declarar monto de inversión/ventas inicial.',
            'Gestionar permiso de publicidad exterior (si tienes letrero).',
          ],
          commonRequirements: [
            'Aviso de Operación impreso.',
            'Cédula del representante.',
            'Foto y medidas del letrero (si aplica).',
          ],
          tips: [
            'Hazlo inmediatamente después del Aviso de Operación para evitar multas por desacato (tienes días límite).',
          ],
          officialLinks: {'Panamá Emprende (Info General)': kLinkPanamaEmprende},
          vaultEnabled: true,
          vaultMeta: VaultMetadata(
            docType: 'PERMISO_MUNICIPAL',
            category: 'Municipal / Alcaldía',
            tags: ['Municipio', 'Impuestos', 'Rótulos'],
            evidenceHint: 'Comprobante de inscripción municipal',
          ),
        ),
        RequirementItem(
          id: 'bomberos',
          title: 'Permiso de Bomberos (Seguridad)',
          shortDesc: 'Certificación de seguridad y gas.',
          icon: Icons.fire_extinguisher_outlined,
          whatIsIt: 'Inspección de la DINASEPI para verificar extintores, alarmas y sistemas de gas.',
          whyNeeded: [
            'Requisito vital para el Permiso de Ocupación y Operación.',
            'Seguridad real ante incendios (especialmente cocinas).',
          ],
          steps: [
            'Instalar extintores (Sello ABC, K para cocina).',
            'Prueba de hermeticidad del sistema de gas (si usas gas).',
            'Solicitar inspección a Bomberos.',
            'Pagar tasa anual.',
          ],
          commonRequirements: [
            'Certificado de prueba de gas (por idóneo).',
            'Factura de extintores.',
            'Planos eléctricos (si aplica).',
          ],
          tips: [
            'El sistema de gas debe ser inspeccionado por un fontanero idóneo antes de llamar a Bomberos.',
            'Ten el extintor Tipo K cerca de la freidora/estufa.',
          ],
          officialLinks: {'Bomberos Panamá': kLinkBomberos},
          vaultEnabled: true,
          vaultMeta: VaultMetadata(
            docType: 'CERT_BOMBEROS',
            category: 'Seguridad / Bomberos',
            tags: ['Bomberos', 'Seguridad', 'Gas'],
            evidenceHint: 'Certificado de inspección bomberos',
          ),
        ),
      ],
    ),
    
    // 4) Operación y Local
    BusinessSection(
      id: 'operacion',
      title: '4. Operación y Local',
      items: [
        RequirementItem(
          id: 'contrato_local',
          title: 'Contrato de Arrendamiento',
          shortDesc: 'Legaliza la tenencia de tu espacio.',
          icon: Icons.vpn_key_outlined,
          whatIsIt: 'Acuerdo legal con el dueño del local comercial.',
          whyNeeded: [
            'Sin local, no puedes sacar Aviso de Operación ni permisos.',
            'Protege tu inversión en remodelaciones.',
          ],
          steps: [
            'Negociar términos (tiempo, canon, período de gracia).',
            'Firma notariada.',
            'Registro ante MIVIOT (opcional pero recomendado para garantías).',
          ],
          commonRequirements: [
            'Depósito de garantía.',
            'Referencias comerciales.',
          ],
          tips: [
            'Pide "meses de gracia" para remodelar antes de empezar a pagar renta.',
            'Verifica que el uso de suelo permita "Restaurante" antes de firmar.',
          ],
          officialLinks: {},
        ),
        RequirementItem(
          id: 'proveedores',
          title: 'Proveedores e Inventario',
          shortDesc: 'Cadena de suministro y control.',
          icon: Icons.inventory_2_outlined,
          whatIsIt: 'Establecer relaciones con quienes te venden insumos y cómo lo controlas.',
          whyNeeded: [
            'Calidad consistente de la comida.',
            'Costos controlados para rentabilidad.',
          ],
          steps: [
            'Listar insumos críticos.',
            'Cotizar con al menos 3 proveedores por rubro.',
            'Negociar días de crédito.',
          ],
          commonRequirements: [
            'Ficha técnica de productos.',
            'Registro Sanitario de productos empacados.',
          ],
          tips: [
            'No dependas de un solo proveedor para ingredientes clave.',
            'Lleva inventario diario de proteínas y licores.',
          ],
          officialLinks: {},
        ),
      ],
    ),

    // 5) Finanzas
    BusinessSection(
      id: 'finanzas',
      title: '5. Finanzas e Impuestos',
      items: [
         RequirementItem(
          id: 'cuenta_bancaria',
          title: 'Cuenta Bancaria Comercial',
          shortDesc: 'Separa finanzas personales del negocio.',
          icon: Icons.account_balance_wallet_outlined,
          whatIsIt: 'Cuenta a nombre de la empresa (o RUC comercial) para manejar ingresos y gastos.',
          whyNeeded: [
            'Orden contable.',
            'Requisito para puntos de venta (POS).',
          ],
          steps: [
            'Elegir banco y solicitar requisitos.',
            'Entregar Aviso, RUC, Cédula, Referencias.',
            'Esperar aprobación (Compliance).',
          ],
          commonRequirements: [
            'Depósito inicial.',
            'Proyección de ingresos.',
          ],
          tips: [
            'Los bancos pueden tardar semanas en abrir cuentas jurídicas; inicia el trámite temprano.',
          ],
          officialLinks: {},
        ),
        RequirementItem(
          id: 'itbms',
          title: 'Obligaciones de ITBMS',
          shortDesc: 'Impuesto de traslado de bienes.',
          icon: Icons.percent_outlined,
          whatIsIt: 'Impuesto del 7% (general) 10% (Alcohol) sobre ventas.',
          whyNeeded: [
            'Si facturas más de cierta cantidad anual (ej. \$36k, varía) eres contribuyente.',
            'Evasión fiscal es delito grave.',
          ],
          steps: [
            'Determinar si tus ingresos estimados superan el techo exento.',
            'Registrarse como contribuyente ITBMS (DGI).',
            'Configurar la impresora fiscal.',
          ],
          commonRequirements: [
            'Equipo fiscal autorizado.',
          ],
          tips: [
            'Consulta a un contador idóneo desde el día 1.',
            'Todo el ITBMS cobrado no es tuyo, es del Estado.',
          ],
          officialLinks: {'DGI': kLinkDGI},
        ),
      ],
    ),
    
    // 6) Personal
     BusinessSection(
      id: 'personal',
      title: '6. Personal y Planilla',
      items: [
        RequirementItem(
          id: 'css_patronal',
          title: 'Inscripción Patronal CSS',
          shortDesc: 'Seguridad Social para empleados.',
          icon: Icons.people_alt_outlined,
          whatIsIt: 'Registro de la empresa en la Caja de Seguro Social para pagar cuotas empleado-patrono.',
          whyNeeded: [
            'Obligatorio desde el primer empleado.',
            'Cubre salud y jubilación del equipo.',
          ],
          steps: [
            'Llenar formulario de inscripción en CSS.',
            'Presentar Aviso de Operación y RUC.',
            'Obtener Número Patronal.',
            'Acceder al SIPE (Sistema de Ingresos y Prestaciones).',
          ],
          commonRequirements: [
            'Croquis de ubicación.',
            'Copia de cédulas.',
          ],
          tips: [
            'El SIPE es digital, pero la inscripción inicial suele ser presencial.',
          ],
          officialLinks: {},
        ),
        RequirementItem(
          id: 'mitradel_contratos',
          title: 'Contratos MITRADEL',
          shortDesc: 'Registro de contratos laborales.',
          icon: Icons.gavel_outlined,
          whatIsIt: 'Validación de contratos de trabajo ante el Ministerio de Trabajo.',
          whyNeeded: [
            'Protección jurídica para ambas partes.',
            'Evita demandas laborales mal fundamentadas.',
          ],
          steps: [
            'Redactar contrato (definir salario, horario, tipo).',
            'Firmar por ambas partes.',
            'Sellar en MITRADEL (físico o digital con Panamá Digital).',
          ],
          commonRequirements: [
            '3 copias del contrato.',
          ],
          tips: [
            'El período de prueba (3 meses) debe estar escrito en el contrato para ser válido.',
          ],
          officialLinks: {'MITRADEL': kLinkMitradel},
        ),
      ],
    ),
  ],
);

/// Content for "Food Truck"
final foodTruckContent = BusinessModelContent(
  id: 'food_truck',
  title: 'Food Truck',
  sections: [
    BusinessSection(
      id: 'legales',
      title: '1. Requisitos Legales',
      items: [
        restaurantSmallContent.sections[0].items[0], // RUC
        restaurantSmallContent.sections[0].items[1], // Aviso Operación
        RequirementItem(
          id: 'registro_vehicular',
          title: 'Registro Vehicular y Revisado',
          shortDesc: 'Trámites del vehículo/remolque.',
          icon: Icons.directions_car_filled_outlined,
          whatIsIt: 'Registro del camión o remolque ante el Municipio y ATTT.',
          whyNeeded: ['Es ilegal circular sin placa.', 'El seguro lo exige.'],
          steps: ['Revisado vehicular anual.', 'Pago de placa municipal.', 'Seguro de daños a terceros.'],
          commonRequirements: ['Registro único vehicular.', 'Poliza de seguro.'],
          tips: ['Asegúrate que el seguro cubra uso comercial.'],
          officialLinks: {},
          vaultEnabled: true,
          vaultMeta: VaultMetadata(
             docType: 'REGISTRO_VEHICULAR',
             category: 'Vehículo',
             tags: ['Placa', 'ATTT'],
             evidenceHint: 'Foto del registro único',
          ),
        ),
      ],
    ),
    BusinessSection(
      id: 'permisos',
      title: '2. Permisos y Ubicación',
      items: [
        restaurantSmallContent.sections[1].items[0], // Permiso Sanitario (Base)
        restaurantSmallContent.sections[1].items[1], // Carnés Salud
        RequirementItem(
          id: 'permiso_ubicacion',
          title: 'Permiso de Ubicación (Alcaldía)',
          shortDesc: 'Autorización para estacionar y vender.',
          icon: Icons.location_on_outlined,
          whatIsIt: 'Permiso municipal para ocupar un espacio público o privado para venta.',
          whyNeeded: ['No puedes estacionarte donde quieras.', 'Evita remoción con grúa.'],
          steps: ['Solicitud a la alcaldía (Buhonería o Espacio Público).', 'O contrato de alquiler en plaza privada (Food Court).'],
          commonRequirements: ['Croquis de ubicación.', 'Visto bueno de junta comunal.'],
          tips: ['Las plazas privadas de Food Trucks son más seguras y fáciles de tramitar que la calle.'],
          officialLinks: {},
        ),
         RequirementItem(
          id: 'bomberos_gas',
          title: 'Bomberos (Gas y Extintores)',
          shortDesc: 'Seguridad en espacios reducidos.',
          icon: Icons.fire_extinguisher_outlined,
          whatIsIt: 'Certificación de seguridad estricta por uso de gas en vehículo.',
          whyNeeded: ['Alto riesgo de incendio en food trucks.', 'Requisito obligatorio.'],
          steps: ['Instalar sistema de gas certificado.', 'Extintor Tipo K a mano.', 'Inspección de DINASEPI.'],
          commonRequirements: ['Prueba de hermeticidad reciente.'],
          tips: ['Ventilación adecuada es clave para pasar la inspección y por salud.'],
          officialLinks: {'Bomberos': kLinkBomberos},
        ),
      ],
    ),
    restaurantSmallContent.sections[4], // Finanzas
    restaurantSmallContent.sections[5], // Personal
  ],
);

/// Content for "Cafetería"
final cafeContent = BusinessModelContent(
  id: 'cafe',
  title: 'Cafetería',
  sections: [
    restaurantSmallContent.sections[0], // Legal
    restaurantSmallContent.sections[1], // Health
    restaurantSmallContent.sections[2], // Municipal
    BusinessSection(
      id: 'operacion_cafe',
      title: '4. Operación Especializada',
      items: [
        RequirementItem(
          id: 'maquina_espresso',
          title: 'Máquina de Espresso',
          shortDesc: 'El corazón del negocio.',
          icon: Icons.coffee_maker_outlined,
          whatIsIt: 'Equipo profesional para extracción de café.',
          whyNeeded: ['Define la calidad de tu producto principal.', 'Alta inversión inicial.'],
          steps: ['Cotizar marcas (La Marzocco, Simonelli, etc.).', 'Instalar filtro de agua dedicado (CRÍTICO).', 'Mantenimiento preventivo.'],
          commonRequirements: ['Instalación eléctrica 220v usualmente.'],
          tips: ['El agua sin filtrar arruinará tu máquina en 6 meses.'],
          officialLinks: {},
        ),
        RequirementItem(
          id: 'barista',
          title: 'Barista Capacitado',
          shortDesc: 'Personal clave.',
          icon: Icons.person_outline,
          whatIsIt: 'Experto en preparación de café.',
          whyNeeded: ['Una buena máquina con mal barista = mal café.'],
          steps: ['Contratar experiencia o capacitar con cursos.', 'Carnés de salud vigentes.'],
          commonRequirements: ['Certificaciones SCA (opcional pero bueno).'],
          tips: ['Tú como dueño deberías saber hacer café también.'],
          officialLinks: {},
        ),
      ],
    ),
    restaurantSmallContent.sections[4], // Finanzas
    restaurantSmallContent.sections[5], // Personal
  ],
);

/// Content for "Panadería"
final bakeryContent = BusinessModelContent(
  id: 'bakery',
  title: 'Panadería / Repostería',
  sections: [
    restaurantSmallContent.sections[0], // Legal
    BusinessSection(
      id: 'salud_industrial',
      title: '2. Permisos y Salud (Industrial)',
      items: [
        RequirementItem(
          id: 'permiso_sanitario_fabrica',
          title: 'Licencia Industrial / Sanitaria',
          shortDesc: 'Para producción de alimentos.',
          icon: Icons.factory_outlined,
          whatIsIt: 'Permiso para transformar materia prima (harina) en producto.',
          whyNeeded: ['La panadería es manufactura, no solo venta.', 'Normas de higiene más estrictas.'],
          steps: ['Área de producción separada de venta.', 'Flujo de proceso lineal.', 'Control de plagas estricto (harina atrae todo).'],
          commonRequirements: ['Trampas de grasa.', 'Mallas contra insectos.'],
          tips: ['El manejo de temperaturas en harinas y levaduras es vital.'],
          officialLinks: {'MINSA': kLinkMinsa},
        ),
        restaurantSmallContent.sections[1].items[1], // Carnés
      ],
    ),
    BusinessSection(
      id: 'bomberos_hornos',
      title: '3. Seguridad (Hornos)',
      items: [
        RequirementItem(
          id: 'seguridad_hornos',
          title: 'Seguridad en Hornos',
          shortDesc: 'Gas y calor industrial.',
          icon: Icons.local_fire_department_outlined,
          whatIsIt: 'Certificación específica para hornos industriales.',
          whyNeeded: ['Riesgo de fuga de gas y altas temperaturas.'],
          steps: ['Instalación de gas certificada.', 'Extractores de calor potentes.', 'Extintores cercanos.'],
          commonRequirements: ['Prueba de hermeticidad anual.'],
          tips: ['El calor excesivo afecta el rendimiento del personal y las masas.'],
          officialLinks: {'Bomberos': kLinkBomberos},
        ),
       restaurantSmallContent.sections[2].items[0], // Municipio
      ],
    ),
    restaurantSmallContent.sections[4], // Finanzas
    restaurantSmallContent.sections[5], // Personal
  ],
);

/// Content for "Fast Food"
final fastFoodContent = BusinessModelContent(
  id: 'fast_food',
  title: 'Puesto de Comida Rápida',
  sections: [
    restaurantSmallContent.sections[0], // Legal
    BusinessSection(
      id: 'ubicacion_kiosco',
      title: '2. Ubicación y Kiosco',
      items: [
        RequirementItem(
          id: 'permiso_kiosco',
          title: 'Permiso de Kiosco/Uso de Suelo',
          shortDesc: 'Si estás en vía pública o plaza.',
          icon: Icons.store_mall_directory_outlined,
          whatIsIt: 'Permiso municipal o privado para estructura semi-fija.',
          whyNeeded: ['Regula el espacio físico y estética.', 'Evita desalojos.'],
          steps: ['Solicitud a la alcaldía o administración de plaza.', 'Pago de mensualidad/arriendo.'],
          commonRequirements: ['Diseño del kiosco aprobado.'],
          tips: ['Asegura acceso a agua potable y electricidad legal.'],
          officialLinks: {},
        ),
        restaurantSmallContent.sections[1].items[0], // Sanitario
        restaurantSmallContent.sections[1].items[1], // Carnés
      ],
    ),
    BusinessSection(
      id: 'operacion_rapida',
      title: '3. Operación Ágil',
      items: [
        RequirementItem(
          id: 'equipos_freidoras',
          title: 'Freidoras y Planchas',
          shortDesc: 'Equipos de alto rendimiento.',
          icon: Icons.bolt_outlined,
          whatIsIt: 'Maquinaria para cocción rápida.',
          whyNeeded: ['La velocidad es tu propuesta de valor.'],
          steps: ['Instalación eléctrica adecuada (alto consumo).', 'Trampa de grasa (obligatoria incluso en kioscos).'],
          commonRequirements: ['Campana extractora (olores).'],
          tips: ['El aceite sucio daña el sabor y la salud. Filtra o cámbialo a diario.'],
          officialLinks: {},
        ),
      ],
    ),
    restaurantSmallContent.sections[4], // Finanzas
    restaurantSmallContent.sections[5], // Personal
  ],
);

/// Content for "Catering"
final cateringContent = BusinessModelContent(
  id: 'catering',
  title: 'Servicio de Catering',
  sections: [
    BusinessSection(
      id: 'legal_catering',
      title: '1. Requisitos Legales',
      items: [
        restaurantSmallContent.sections[0].items[0], // RUC
        restaurantSmallContent.sections[0].items[1], // Aviso: "Servicio de suministro de comidas"
      ],
    ),
    BusinessSection(
      id: 'salud_catering',
      title: '2. Salud y Transporte',
      items: [
        RequirementItem(
          id: 'cocina_base',
          title: 'Centro de Producción (Cocina Base)',
          shortDesc: 'Lugar legal donde cocinas.',
          icon: Icons.kitchen_outlined,
          whatIsIt: 'Local aprobado por MINSA donde se preparan los alimentos antes de servir.',
          whyNeeded: ['No es legal cocinar catering comercial en cocina doméstica sin adecuar.', 'Auditorías de clientes corporativos.'],
          steps: ['Adecuar cocina separada de área doméstica.', 'Permiso sanitario de operación.'],
          commonRequirements: ['Acero inoxidable', 'Áreas lavables'],
          tips: ['Si empiezas, puedes alquilar una "Dark Kitchen" o cocina compartida con permiso.'],
          officialLinks: {'MINSA': kLinkMinsa},
        ),
        RequirementItem(
           id: 'permiso_transporte',
           title: 'Permiso Sanitario Vehicular',
           shortDesc: 'Para trasladar comida.',
           icon: Icons.local_shipping_outlined,
           whatIsIt: 'Permiso del MINSA para el vehículo que mueve alimentos.',
           whyNeeded: ['Garantiza cadena de frío/calor.', 'Evita multas en operativos de calle.'],
           steps: ['Inspección vehicular de salud.', 'Revisión de hieleras/cambros.'],
           commonRequirements: ['Vehículo limpio, exclusivo para carga (preferible).'],
           tips: ['Usa "Cambros" térmicos certificados para mantener temperatura segura >60°C o <5°C.'],
           officialLinks: {},
        ),
      ],
    ),
     BusinessSection(
      id: 'logistica',
      title: '3. Logística y Eventos',
      items: [
         RequirementItem(
           id: 'contratos_eventos',
           title: 'Contrato de Servicio',
           shortDesc: 'Protege tu pago.',
           icon: Icons.description_outlined,
           whatIsIt: 'Documento legal que define menú, hora, cantidad y precio.',
           whyNeeded: ['El cliente puede cambiar requisitos a última hora.', 'Garantiza cobro de anticipo.'],
           steps: ['Redactar modelo de contrato.', 'Firmar con cada cliente.', 'Cobrar 50% anticipado.'],
           commonRequirements: [],
           tips: ['Nunca inicies compras sin el 50% de anticipo en banco.'],
           officialLinks: {},
        ),
      ],
    ),
    restaurantSmallContent.sections[4], // Finanzas
    restaurantSmallContent.sections[5], // Personal
  ],
);


// --- BELLEZA CONTENT ---

/// Content for "Barber Shop"
final barberContent = BusinessModelContent(
  id: 'barber',
  title: 'Barbería',
  sections: [
    restaurantSmallContent.sections[0], // Legal
    BusinessSection(
      id: 'salud_barberia',
      title: '2. Salud e Higiene',
      items: [
        restaurantSmallContent.sections[1].items[0], // Permiso Sanitario (Base)
        RequirementItem(
          id: 'esterilizacion',
          title: 'Esterilización de Herramientas',
          shortDesc: 'Navajas y tijeras requieren cuidado crítico.',
          icon: Icons.cleaning_services_outlined,
          whatIsIt: 'Protocolo de limpieza de equipos corto-punzantes.',
          whyNeeded: ['Riesgo alto de transmisión de enfermedades (VIH, Hepatitis).', 'Exigencia sanitaria.'],
          steps: ['Tener autoclave o esterilizador UV.', 'Usar navajas desechables (obligatorio).', 'Recipiente de "punzocortantes".'],
          commonRequirements: ['Alcohol al 70%.', 'Líquidos virucidas.'],
          tips: ['El cliente de hoy se fija si sacas la navaja nueva del paquete. Hazlo frente a él.'],
          officialLinks: {'MINSA': kLinkMinsa},
        ),
        restaurantSmallContent.sections[1].items[1], // Carnes Salud (Manipulador aplica a contacto físico)
      ],
    ),
    BusinessSection(
      id: 'licencias_pro',
      title: '3. Profesional',
      items: [
         RequirementItem(
          id: 'tecnico_belleza',
          title: 'Licencia de Técnico en Belleza',
          shortDesc: 'Acreditación profesional.',
          icon: Icons.school_outlined,
          whatIsIt: 'Certificado de la Junta Técnica de Cosmetología (si aplica a barbería técnica).',
          whyNeeded: ['Profesionaliza tu servicio.', 'Requerido para contratar extranjeros como técnicos.'],
          steps: ['Presentar diploma de escuela técnica.', 'Examen ante la Junta Técnica.'],
          commonRequirements: ['Copia de cédula.', 'Diploma validado.'],
          tips: ['Muchos barberos son empíricos, pero certificarse permite cobrar más.'],
          officialLinks: {},
        ),
      ],
    ),
    restaurantSmallContent.sections[4], // Finanzas
    restaurantSmallContent.sections[5], // Personal
  ],
);

/// Content for "Salon de Belleza"
final salonContent = BusinessModelContent(
  id: 'salon',
  title: 'Salón de Belleza',
  sections: [
    restaurantSmallContent.sections[0], // Legal
    BusinessSection(
      id: 'operacion_salon',
      title: '2. Insumos y Seguridad',
      items: [
        restaurantSmallContent.sections[1].items[0], // Sanitario
         RequirementItem(
          id: 'quimicos_permisos',
          title: 'Manejo de Químicos (Tintes/Keratinas)',
          shortDesc: 'Ventilación y seguridad.',
          icon: Icons.science_outlined,
          whatIsIt: 'Regulaciones sobre uso de productos con formol o amoníaco.',
          whyNeeded: ['El formol es cancerígeno y está regulado.', 'La ventilación es obligatoria por ley laboral.'],
          steps: ['Instalar extractores de aire potentes.', 'Usar productos con Registro Sanitario Panameño.'],
          commonRequirements: ['Mascarillas para el personal.', 'Guantes de nitrilo.'],
          tips: ['Evita productos "brujos" sin registro; una inspección de Farmacia y Drogas te decomisa todo.'],
          officialLinks: {'MINSA': kLinkMinsa},
        ),
      ],
    ),
    restaurantSmallContent.sections[4], // Finanzas
    restaurantSmallContent.sections[5], // Personal
  ],
);

/// Content for "Spa / Estética"
final spaContent = BusinessModelContent(
  id: 'spa',
  title: 'Spa y Estética',
  sections: [
    restaurantSmallContent.sections[0], // Legal
    BusinessSection(
      id: 'salud_spa',
      title: '2. Regulación Médica/Estética',
      items: [
        RequirementItem(
          id: 'licencia_cosmetologia',
          title: 'Licencia de Cosmetología',
          shortDesc: 'Obligatoria para tratamientos de piel.',
          icon: Icons.face_retouching_natural_outlined,
          whatIsIt: 'Licencia idónea para realizar procedimientos no invasivos en piel.',
          whyNeeded: ['Es ILEGAL hacer faciales o masajes reductores sin idoneidad.', 'Riesgo de cárcel por mala praxis.'],
          steps: ['Título universitario o técnico en Estética.', 'Registro ante Consejo Técnico de Salud.'],
          commonRequirements: ['Diploma apostillado (si es extranjero).'],
          tips: ['NO hagas inyectables (Botox, rellenos) si no eres médico. Es ejercicio ilegal de la medicina.'],
          officialLinks: {'Consejo Técnico': kLinkMinsa},
        ),
        restaurantSmallContent.sections[1].items[0], // Sanitario Local
      ],
    ),
     BusinessSection(
      id: 'equipos_spa',
      title: '3. Equipos Estéticos',
      items: [
        RequirementItem(
          id: 'registro_equipos',
          title: 'Registro de Equipos (Láser/Cavitación)',
          shortDesc: 'Permisos de Farmacia y Drogas.',
          icon: Icons.settings_input_component_outlined,
          whatIsIt: 'Autorización de uso para aparatología estética.',
          whyNeeded: ['Equipos sin registro son decomisados.', 'Seguridad del paciente.'],
          steps: ['Comprar a distribuidores autorizados en Panamá.', 'Solicitar manuales en español y registro sanitario del equipo.'],
          commonRequirements: ['Mantenimiento certificado anual.'],
          tips: ['Cuidado con máquinas baratas de internet; no suelen tener registro sanitario y no las podrás usar legalmente.'],
          officialLinks: {},
        ),
      ],
    ),
    restaurantSmallContent.sections[4], // Finanzas
    restaurantSmallContent.sections[5], // Personal
  ],
);

/// Content for "Nail Bar"
final nailsContent = BusinessModelContent(
  id: 'nails',
  title: 'Sala de Uñas (Nail Bar)',
  sections: [
    restaurantSmallContent.sections[0], // Legal
    BusinessSection(
      id: 'ventilacion_uñas',
      title: '2. Salud Ocupacional',
      items: [
        RequirementItem(
          id: 'extractor_polvo',
          title: 'Extractores de Polvo y Olores',
          shortDesc: 'Salud de tus técnicas.',
          icon: Icons.air_outlined,
          whatIsIt: 'Sistemas para aspirar el polvo de acrílico y vapores de monómero.',
          whyNeeded: ['El "pulmón de manicurista" es una enfermedad real.', 'El olor a monómero aleja clientes.'],
          steps: ['Mesas con extractor incorporado.', 'Ventilación cruzada en el local.'],
          commonRequirements: ['Mascarillas N95 para personal.'],
          tips: ['Invierte en mesas con aspiradora; tus empleadas durarán más años contigo y se enfermarán menos.'],
          officialLinks: {},
        ),
         restaurantSmallContent.sections[1].items[0], // Sanitario
      ],
    ),
    restaurantSmallContent.sections[4], // Finanzas
    restaurantSmallContent.sections[5], // Personal
  ],
);

// --- COMERCIO / RETAIL CONTENT ---

/// Content for "Minisuper / Abarrotería" (Comida Venta al por menor)
final minisuperContent = BusinessModelContent(
  id: 'minisuper',
  title: 'Minisúper',
  sections: [
    restaurantSmallContent.sections[0], // Legal
    BusinessSection(
      id: 'salud_minisuper',
      title: '2. Salud y Plagas',
      items: [
        restaurantSmallContent.sections[1].items[0], // Permiso Sanitario Local
        restaurantSmallContent.sections[1].items[1], // Carnés (manipuladores para embutidos/pan)
        RequirementItem(
          id: 'fumigacion_control',
          title: 'Control de Plagas Estricto',
          shortDesc: 'Certificado obligatorio.',
          icon: Icons.pest_control_outlined,
          whatIsIt: 'Contrato mensual con fumigadora idónea.',
          whyNeeded: ['Almacenas comida: riesgo alto de roedores y cucarachas.', 'Requisito para Permiso Sanitario.'],
          steps: ['Contratar empresa con licencia MINSA.', 'Guardar certificados de fumigación (se pegan en la pared).'],
          commonRequirements: ['Guardar recibos.'],
          tips: ['No uses veneno casero; si hay inspección y ven "Racumín" te multan. Debe ser certificado.'],
          officialLinks: {},
        ),
      ],
    ),
    restaurantSmallContent.sections[2], // Municipales
    restaurantSmallContent.sections[4], // Finanzas
    restaurantSmallContent.sections[5], // Personal
  ],
);

/// Content for "Tienda de Ropa / Accesorios" (Retail General)
final retailStoreContent = BusinessModelContent(
  id: 'retail_store',
  title: 'Tienda de Ropa / Accesorios',
  sections: [
    restaurantSmallContent.sections[0], // Legal
    restaurantSmallContent.sections[2], // Municipales (important for rotulos)
    BusinessSection(
      id: 'consumer_protection',
      title: '2. Protección al Consumidor',
      items: [
        RequirementItem(
          id: 'acodeco_precios',
          title: 'Precios a la Vista',
          shortDesc: 'Normativa ACODECO.',
          icon: Icons.price_check_outlined,
          whatIsIt: 'Obligación de etiquetar precio en cada artículo o en anaquel.',
          whyNeeded: ['Multas de ACODECO frecuentes por falta de precios.', 'Derecho del consumidor.'],
          steps: ['Etiquetadora manual o códigos de barra.', 'Lista de precios visible.'],
          commonRequirements: ['Política de garantía visible.'],
          tips: ['Nunca cobres en caja un precio mayor al marcado; es sancionable.'],
          officialLinks: {},
        ),
      ],
    ),
    restaurantSmallContent.sections[4], // Finanzas
    restaurantSmallContent.sections[5], // Personal
  ],
);

// --- SERVICIOS PROFESIONALES CONTENT ---

final professionalContent = BusinessModelContent(
  id: 'professional',
  title: 'Servicios Profesionales',
  sections: [
    BusinessSection(
      id: 'legal_pro',
      title: '1. Legal e Idoneidad',
      items: [
         restaurantSmallContent.sections[0].items[0], // RUC
         RequirementItem(
          id: 'aviso_operacion_servicio',
          title: 'Aviso de Operación (Servicios)',
          shortDesc: 'Categoría Clase B (sin local).',
          icon: Icons.class_outlined,
          whatIsIt: 'Licencia para ejercer profesiones liberales o técnicas.',
          whyNeeded: ['Formaliza tu práctica.', 'Necesario para facturar a empresas.'],
          steps: ['Declarar actividad (Consultoría, Contabilidad, etc.).'],
          commonRequirements: ['Idoneidad profesional (si aplica: CPA, Abogado, Ing).'],
          tips: ['Si trabajas desde casa, puedes sacar aviso digital sin local comercial físico (depende zona).'],
          officialLinks: {'Panamá Emprende': kLinkPanamaEmprende},
        ),
      ],
    ),
    BusinessSection(
      id: 'contratos_pro',
      title: '2. Gestión de Clientes',
      items: [
        RequirementItem(
          id: 'contrato_servicios',
          title: 'Contrato de Servicios',
          shortDesc: 'Reglas claras.',
          icon: Icons.history_edu_outlined,
          whatIsIt: 'Documento que detalla alcance, entregables y pagos.',
          whyNeeded: ['Evita el "scope creep" (trabajo extra gratis).', 'Seguridad de cobro.'],
          steps: ['Redactar modelo estándar.', 'Definir cláusulas de confidencialidad.'],
          commonRequirements: [],
          tips: ['Pide anticipo del 50% siempre.'],
          officialLinks: {},
        ),
      ],
    ),
    restaurantSmallContent.sections[4], // Finanzas
  ],
);

// --- TRANSPORTE CONTENT ---

final transportContent = BusinessModelContent(
  id: 'transport',
  title: 'Transporte / Delivery',
  sections: [
    restaurantSmallContent.sections[0], // Legal
    BusinessSection(
      id: 'vehicular_transporte',
      title: '2. Vehículo y Licencia',
      items: [
        RequirementItem(
          id: 'licencia_conducir',
          title: 'Licencia Comercial (E1/E2)',
          shortDesc: 'No basta la particular.',
          icon: Icons.drive_eta_outlined,
          whatIsIt: 'Licencia adecuada para transporte remunerado (Taxi, App, Carga).',
          whyNeeded: ['Seguro no cubre si usas licencia incorrecta.', 'Multas de tránsito.'],
          steps: ['Curso de manejo comercial.', 'Examen ATTT.'],
          commonRequirements: ['Paz y salvo ATTT.', 'Prueba antidoping.'],
          tips: ['Revisa la vigencia; la comercial vence más rápido que la particular.'],
          officialLinks: {},
        ),
         RequirementItem(
          id: 'seguro_comercial',
          title: 'Seguro Comercial / Carga',
          shortDesc: 'Cobertura real.',
          icon: Icons.health_and_safety_outlined,
          whatIsIt: 'Póliza que declara uso "Comercial" del vehículo.',
          whyNeeded: ['Seguro particular NO PAGA si chocas trabajando.'],
          steps: ['Cotizar con corredor.', 'Endosar póliza a acreedor si hay préstamo.'],
          commonRequirements: [],
          tips: ['Es más caro, pero indispensable.'],
          officialLinks: {},
        ),
      ],
    ),
    restaurantSmallContent.sections[4], // Finanzas
  ],
);

// --- EDUCACIÓN CONTENT ---

final educationContent = BusinessModelContent(
  id: 'education',
  title: 'Educación / Tutorías',
  sections: [
    restaurantSmallContent.sections[0], // Legal
    restaurantSmallContent.sections[2], // Municipales
     BusinessSection(
      id: 'meduca_acreditacion',
      title: '2. Acreditación Académica',
      items: [
        RequirementItem(
          id: 'resuelto_meduca',
          title: 'Resuelto MEDUCA (Academias)',
          shortDesc: 'Para escuelas formales.',
          icon: Icons.school_outlined,
          whatIsIt: 'Permiso del Ministerio de Educación para certificar estudios.',
          whyNeeded: ['Si quieres dar diplomas válidos.', 'Genera confianza.'],
          steps: ['Presentar pensum académico.', 'Inspección de infraestructura.'],
          commonRequirements: ['Psicólogo en planta (según nivel).'],
          tips: ['Si son cursos libres (no formales), no necesitas Resuelto MEDUCA obligatoriamente, pero acláralo.'],
          officialLinks: {},
        ),
      ],
    ),
     restaurantSmallContent.sections[5], // Personal (Profesores)
  ],
);

// --- SALUD / FITNESS CONTENT ---

final healthContent = BusinessModelContent(
  id: 'health_wellness',
  title: 'Salud y Bienestar',
  sections: [
    BusinessSection(
      id: 'legal_health',
      title: '1. Legal e Idoneidad',
      items: [
        restaurantSmallContent.sections[0].items[0], // RUC
        RequirementItem(
          id: 'certificacion_entrenador',
          title: 'Certificación Idónea',
          shortDesc: 'Entrenador / Terapeuta.',
          icon: Icons.fitness_center_outlined,
          whatIsIt: 'Diploma que avala tus conocimientos anatómicos.',
          whyNeeded: ['Responsabilidad civil por lesiones.', 'Credibilidad.'],
          steps: ['Curso certificado.', 'Idoneidad del Consejo Técnico (si es Fisioterapia).'],
          commonRequirements: ['Certificado CPR (Primeros aux).'],
          tips: ['Ten siempre un seguro de responsabilidad civil por si un cliente se lesiona.'],
          officialLinks: {},
        ),
      ],
    ),
    restaurantSmallContent.sections[2], // Municipales
    restaurantSmallContent.sections[4], // Finanzas
  ],
);

// --- DIGITAL SERVICES CONTENT ---

final digitalContent = BusinessModelContent(
  id: 'digital',
  title: 'Servicios Digitales',
  sections: [
     BusinessSection(
      id: 'legal_digital',
      title: '1. Legal y Contratos',
      items: [
        restaurantSmallContent.sections[0].items[0], // RUC
         RequirementItem(
          id: 'aviso_digital',
          title: 'Aviso de Operación',
          shortDesc: 'Actividad 620 (Informática).',
          icon: Icons.computer_outlined,
          whatIsIt: 'Registro de la empresa de servicios.',
          whyNeeded: ['Para facturar a clientes corporativos.', 'Deducir gastos.'],
          steps: ['Panamá Emprende > Servicios.'],
          commonRequirements: [],
          tips: ['Muchos freelancers operan informal, pero pierden clientes grandes por no dar factura fiscal.'],
          officialLinks: {},
        ),
        RequirementItem(
          id: 'contrato_sla',
          title: 'Acuerdo Nivel Servicio (SLA)',
          shortDesc: 'Promesa de tiempos.',
          icon: Icons.timer_outlined,
          whatIsIt: 'Cláusula contractual sobre tiempos de respuesta y entregas.',
          whyNeeded: ['Gestión de expectativas.', 'Evita clientes tóxicos.'],
          steps: ['Definir horarios de atención.', 'Tiempos de entrega.'],
          commonRequirements: [],
          tips: ['Cobra extra por urgencias fuera de SLA.'],
          officialLinks: {},
        ),
      ],
    ),
    restaurantSmallContent.sections[4], // Finanzas
  ],
);

// --- EVENTOS CONTENT ---

final eventsContent = BusinessModelContent(
  id: 'events',
  title: 'Organización de Eventos',
  sections: [
    restaurantSmallContent.sections[0], // Legal
    BusinessSection(
      id: 'logistica_eventos',
      title: '2. Logística y Riesgo',
      items: [
        RequirementItem(
          id: 'seguro_rc_eventos',
          title: 'Seguro Resp. Civil Eventos',
          shortDesc: 'Por si algo sale mal.',
          icon: Icons.shield_outlined,
          whatIsIt: 'Póliza temporal por día de evento o anual.',
          whyNeeded: ['Accidentes de invitados.', 'Daños al local alquilado.'],
          steps: ['Cotizar con aseguradora por evento.'],
          commonRequirements: [],
          tips: ['Muchos hoteles exigen esta póliza para dejarte trabajar en sus salones.'],
          officialLinks: {},
        ),
        RequirementItem(
          id: 'transporte_carga',
          title: 'Transporte de Carga',
          shortDesc: 'Mover decoración.',
          icon: Icons.local_shipping_outlined,
          whatIsIt: 'Vehículo comercial para mover mobiliario.',
          whyNeeded: ['No dañes tu auto personal.', 'Capacidad de carga.'],
          steps: ['Comprar pick-up o panel comercial.', 'Rotularlo (publicidad gratis).'],
          commonRequirements: [],
          tips: [],
          officialLinks: {},
        ),
      ],
    ),
    restaurantSmallContent.sections[4], // Finanzas
  ],
);

// --- EMPRENDIMIENTO CASERO CONTENT ---

final homeBizContent = BusinessModelContent(
  id: 'home_biz',
  title: 'Emprendimiento en Casa',
  sections: [
    BusinessSection(
      id: 'legal_home',
      title: '1. Formalización Simple',
      items: [
        restaurantSmallContent.sections[0].items[0], // RUC (Persona natural)
        RequirementItem(
          id: 'aviso_artesanal',
          title: 'Registro Emprendedor',
          shortDesc: 'Beneficios fiscales.',
          icon: Icons.handyman_outlined,
          whatIsIt: 'Registros (AMPYME o MICI Artesanías) para exenciones.',
          whyNeeded: ['Exoneración de impuesto sobre la renta (2 primeros años AMPYME).'],
          steps: ['Registro Empresarial AMPYME.'],
          commonRequirements: ['Curso de gestión empresarial.'],
          tips: ['Aprovecha el capital semilla si concursas.'],
          officialLinks: {'AMPYME': 'https://www.ampyme.gob.pa/'},
        ),
      ],
    ),
    BusinessSection(
      id: 'operacion_home',
      title: '2. Separación Vida/Trabajo',
      items: [
         RequirementItem(
          id: 'espacio_trabajo',
          title: 'Espacio Delimitado',
          shortDesc: 'Tu oficina/taller.',
          icon: Icons.home_work_outlined,
          whatIsIt: 'Área de la casa exclusiva para el negocio.',
          whyNeeded: ['Productividad mental.', 'Deducir gastos (proporcional) si eres formal.'],
          steps: ['Asignar una habitación o mesa fija.'],
          commonRequirements: [],
          tips: ['Establece horarios aunque estés en casa.'],
          officialLinks: {},
        ),
      ],
    ),
    restaurantSmallContent.sections[4], // Finanzas
  ],
);
