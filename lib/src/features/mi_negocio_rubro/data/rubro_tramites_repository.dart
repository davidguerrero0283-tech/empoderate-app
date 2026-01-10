
import 'package:flutter/material.dart';

// --- MODELS ---

class TramiteRef {
  final String id;
  final String nombre;
  final String? entidad;

  const TramiteRef({
    required this.id,
    required this.nombre,
    this.entidad,
  });
}

class TramiteDetail {
  final String id;
  final String nombre;
  final String? entidad;
  final List<String> pasos;
  final List<String> requisitos;
  final String? tiempo;
  final String? costo;
  
  // NEW FIELDS
  final String? dondeSacar;
  final String? onlineLink; // URL if online
  final String? frecuenciaPago; // Mensual / Anual / Único
  final List<String> tips; // Consejos
  
  // PROMPT 99: VALIDATION & TRACEABILITY
  final String? fuente;         // e.g. "MICI - Panamá Emprende", "Decreto Ejecutivo X"
  final String? referencia;     // e.g. "Sitio Web Oficial"
  final String? fechaVerificacion; // YYYY-MM-DD
  final String? observacion;

  const TramiteDetail({
    required this.id,
    required this.nombre,
    this.entidad,
    this.pasos = const [],
    this.requisitos = const [],
    this.tiempo,
    this.costo,
    this.dondeSacar,
    this.onlineLink,
    this.frecuenciaPago,
    this.tips = const [],
    this.fuente,
    this.referencia,
    this.fechaVerificacion,
    this.observacion,
  });
}

// --- REPOSITORY ---

class RubroTramitesRepository {
  
  // --- CONSTANTS: VERIFIED COMMON TRAMITES (Panamá) ---
  // Sources: Panamá Emprende, Municipios, Bomberos, MINSA (General)
  
  static const _avisoOp = TramiteRef(id: 'aviso_operacion', nombre: 'Aviso de Operación', entidad: 'MICI / Panamá Emprende');
  static const _municipio = TramiteRef(id: 'municipio_inscripcion', nombre: 'Inscripción Municipal', entidad: 'Municipio de Panamá');
  static const _bomberos = TramiteRef(id: 'bomberos_seguridad', nombre: 'Permiso de Seguridad (Inspección)', entidad: 'Cuerpo de Bomberos');
  static const _letreros = TramiteRef(id: 'municipio_licencia', nombre: 'Licencia de Publicidad Ext.', entidad: 'Municipio de Panamá');
  static const _saludBlanco = TramiteRef(id: 'salud_blanco', nombre: 'Carnet Blanco (Salud)', entidad: 'MINSA / CSS');
  static const _saludVerde = TramiteRef(id: 'salud_verde', nombre: 'Carnet Verde (Adiestramiento)', entidad: 'MINSA (Escuela)');
  static const _fumigacion = TramiteRef(id: 'fumigacion', nombre: 'Certificado de Fumigación', entidad: 'Control de Plagas'); 
  static const _ruc = TramiteRef(id: 'ruc_dgi', nombre: 'Registro RUC', entidad: 'DGI / MEF');

  // --- PLACEHOLDERS FOR BATCH 1 (Por Confirmar) ---
  static const _permisoViaPublica = TramiteRef(id: 'permiso_via_publica_mupa', nombre: 'Permiso de Uso de Vía Pública', entidad: 'Municipio de Panamá');
  static const _permisoBuhoneria = TramiteRef(id: 'permiso_buhoneria', nombre: 'Permiso de Buhonería', entidad: 'Municipio de Panamá');
  static const _registroSanitario = TramiteRef(id: 'registro_sanitario_artesanal', nombre: 'Registro Sanitario (Artesanal)', entidad: 'MINSA / EPA');

  // --- RUBRO MAPPING (Batch 1 + Expansion) ---
  static final Map<String, List<TramiteRef>> _rubroTramites = {
    // 1. COMIDA
    'rest_small': [_avisoOp, _municipio, _bomberos, _letreros, _saludBlanco, _saludVerde, _fumigacion, _ruc],
    'food_truck': [_avisoOp, _municipio, _bomberos, _saludBlanco, _saludVerde, _fumigacion, _ruc, _permisoViaPublica],
    'coffee_shop': [_avisoOp, _municipio, _bomberos, _letreros, _saludBlanco, _saludVerde, _fumigacion, _ruc],
    'bakery': [_avisoOp, _municipio, _bomberos, _letreros, _saludBlanco, _saludVerde, _fumigacion, _ruc],
    'home_baking': [_ruc, _saludBlanco, _saludVerde, _registroSanitario], // Less reqs for home? To be verified.
    'street_food': [_municipio, _saludBlanco, _saludVerde, _permisoBuhoneria],
    
    // 2. BELLEZA
    'salon': [_avisoOp, _municipio, _bomberos, _letreros, _ruc], // Salud often not strict req for ALL salon staff unless massage/skin? Verified needed.
    'barbershop': [_avisoOp, _municipio, _bomberos, _letreros, _ruc],
    'spa': [_avisoOp, _municipio, _bomberos, _letreros, _saludBlanco, _ruc],
    'nails': [_avisoOp, _municipio, _bomberos, _letreros, _ruc],

    // 3. RETAIL
    'clothing_store': [_avisoOp, _municipio, _bomberos, _letreros, _ruc],
    'grocery': [_avisoOp, _municipio, _bomberos, _letreros, _saludBlanco, _fumigacion, _ruc],
  };

  // --- DETAILS DATABASE ---
  static final Map<String, TramiteDetail> _tramiteDetails = {
    
    // 1. AVISO DE OPERACIÓN (VERIFIED)
    'aviso_operacion': const TramiteDetail(
      id: 'aviso_operacion',
      nombre: 'Aviso de Operación',
      entidad: 'MICI / Panamá Emprende',
      dondeSacar: '100% en Línea: Portal "Panamá Emprende".',
      onlineLink: 'https://panamaemprende.gob.pa',
      frecuenciaPago: 'Único (Apertura) + Tasa Anual',
      fuente: 'MICI - Panamá Emprende',
      referencia: 'Portal Oficial',
      fechaVerificacion: '2025-01-09',
      tips: [
        'Ten a mano tu Cédula o RUC y tarjeta de crédito/débito.',
        'Imprime 3 copias del Aviso firmado.',
      ],
      pasos: [
        'Ingresar a www.panamaemprende.gob.pa.',
        'Iniciar Sesión o Crear Cuenta.',
        'Generar Aviso de Operación.',
        'Pagar boleta (\$15 PN / \$55 PJ).',
      ],
      requisitos: [
        'Cédula de Identidad Personal.',
        'Nombre comercial único.',
        'Ubicación física exacta.',
      ],
      tiempo: 'Inmediato',
      costo: '\$15.00 (PN) / \$55.00 (PJ)',
    ),

    // 2. INSCRIPCIÓN MUNICIPAL (VERIFIED)
    'municipio_inscripcion': const TramiteDetail(
      id: 'municipio_inscripcion',
      nombre: 'Inscripción Municipal',
      entidad: 'Municipio de Panamá',
      dondeSacar: 'Hatillo (Tesorería) o Agencias Municipales.',
      frecuenciaPago: 'Mensual',
      fuente: 'Municipio de Panamá',
      referencia: 'Tesorería Municipal',
      fechaVerificacion: '2025-01-09',
      tips: [
        'Plazo: 30 días post-Aviso de Operación para evitar multa.',
      ],
      pasos: [
        'Acudir a Agencia Municipal.',
        'Entregar documentos.',
        'Pagar impuestos iniciales.',
      ],
      requisitos: [
        'Copia de Aviso de Operación.',
        'Copia de Cédula.',
        'Recibo de Agua/Luz (Ubicación).',
      ],
      tiempo: '1 - 2 días',
      costo: 'Base según actividad',
    ),

    // 3. BOMBEROS (VERIFIED)
    'bomberos_seguridad': const TramiteDetail(
      id: 'bomberos_seguridad',
      nombre: 'Permiso de Seguridad (Inspección)',
      entidad: 'BCBRP (Dinasepi)',
      dondeSacar: 'Oficina de Seguridad (Cuartel de zona).',
      frecuenciaPago: 'Anual',
      fuente: 'BCBRP Donasepi',
      referencia: 'Reglamento de Seguridad',
      fechaVerificacion: '2025-01-09',
      tips: [
        'Extintores deben ser nuevos o recargados c/etiqueta vigente.',
        'Señalización fotoluminiscente es obligatoria.',
      ],
      pasos: [
        'Solicitar inspección en ventanilla.',
        'Pagar boleta.',
        'Recibir inspección.',
      ],
      requisitos: [
        'Aviso de Operación.',
        'Extintores (ABC/K).',
        'Detectores de humo/gas (si aplica).',
      ],
      tiempo: '7 - 15 días',
      costo: 'Variable (según m2)',
    ),

    // 4. LICENCIA PUBLICIDAD (VERIFIED)
    'municipio_licencia': const TramiteDetail(
      id: 'municipio_licencia',
      nombre: 'Licencia de Publicidad Ext.',
      entidad: 'Municipio de Panamá',
      dondeSacar: 'Municipio de Panamá.',
      frecuenciaPago: 'Anual',
      fuente: 'Municipio de Panamá',
      referencia: 'Publicidad Exterior',
      fechaVerificacion: '2025-01-09',
      pasos: [
        'Declarar letrero.',
        'Pagar impuesto.',
      ],
      requisitos: [
        'Foto del letrero.',
        'Medidas (Alto x Ancho).',
        'Autorización dueño del inmueble.',
      ],
      tiempo: 'Inmediato',
      costo: 'Variable (según m2)',
    ),

    // 5. RUC (VERIFIED)
    'ruc_dgi': const TramiteDetail(
      id: 'ruc_dgi',
      nombre: 'Registro RUC',
      entidad: 'DGI / MEF',
      dondeSacar: 'En Línea (e-Tax 2.0).',
      fuente: 'DGI Panamá',
      referencia: 'e-Tax 2.0',
      fechaVerificacion: '2025-01-09',
      pasos: [
        'Solicitar NIT.',
        'Actualizar obligaciones.',
      ],
      requisitos: [
        'Cédula.',
        'Correo electrónico.',
      ],
      tiempo: 'Inmediato',
      costo: 'Gratis',
    ),
    
    // 6. SALUD (Semi-Verified - Standard Process)
    'salud_blanco': const TramiteDetail(
      id: 'salud_blanco',
      nombre: 'Carnet Blanco (Salud)',
      entidad: 'MINSA / CSS',
      fuente: 'MINSA',
      fechaVerificacion: '2025-01-09',
      tips: ['Madrugar para cupo es esencial.'],
      pasos: ['Exámenes laboratorio.', 'Revisión médica.', 'Revisión odontológica.'],
      requisitos: ['Cédula.', 'Fotos.', 'Pago (~25 USD).'],
      tiempo: '1 día',
      costo: '~\$25.00',
    ),
    'salud_verde': const TramiteDetail(
      id: 'salud_verde',
      nombre: 'Carnet Verde (Adiestramiento)',
      entidad: 'Escuela Manipuladores',
      fuente: 'MINSA',
      fechaVerificacion: '2025-01-09',
      requisitos: ['Carnet Blanco Vigente.', 'Charla aprobada.'],
      costo: '\$10.00',
    ),
    
    // 7. FUMIGACION (Standard Practice - Keeping minimal as per prompt 99)
     'fumigacion': const TramiteDetail(
      id: 'fumigacion',
      nombre: 'Certificado de Fumigación',
      entidad: 'Privado / Control de Plagas',
      fuente: 'Código Sanitario (Referencia)',
      tips: ['Asegura que la empresa emita certificado válido.'],
      tiempo: 'Horas',
    ),
  };

  // --- PUBLIC METHODS ---

  static String _normalizeId(String id) {
    String s = id.toLowerCase().trim().replaceAll('-', '_').replaceAll(' ', '_');
    if (s == 'restaurante_pequeno' || s == 'restaurante_pequeño' || s == 'small_restaurant') {
      return 'rest_small';
    }
    return s;
  }

  static List<TramiteRef> getTramitesForRubro(String categoryId, String rubroId) {
    final normalizedId = _normalizeId(rubroId);
    return _rubroTramites[normalizedId] ?? 
           // Default fallback: Always show at least basic RUC & Aviso if unknown
           [_avisoOp, _ruc];
  }

  static TramiteDetail getTramiteDetail(String tramiteId) {
    // 1. Try to find verified detail
    if (_tramiteDetails.containsKey(tramiteId)) {
      return _tramiteDetails[tramiteId]!;
    }
    
    // 2. TEMPLATE ENGINE: "POR CONFIRMAR"
    // If not found in our verified list, return a safe placeholder
    return _buildUnverifiedDetail(tramiteId);
  }
  
  static TramiteDetail _buildUnverifiedDetail(String id) {
     final properName = id.replaceAll('_', ' ').toUpperCase();
     // Extract potential entity from ID if possible or use generic
     String? entityHint = 'Institución Correspondiente';
     if(id.contains('municip')) entityHint = 'Municipio';
     if(id.contains('minsa') || id.contains('salud')) entityHint = 'MINSA';
     if(id.contains('bomber')) entityHint = 'Bomberos';
     
     return TramiteDetail(
       id: id,
       nombre: properName,
       entidad: entityHint,
       dondeSacar: 'Pendiente de confirmación oficial.',
       tips: [
         'Este trámite requiere verificación de requisitos vigentes.',
         'Contactar directamente a: $entityHint.'
       ],
       pasos: [
         'Consultar sitio web oficial o acudir a la entidad.',
         'Validar lista de requisitos actualizados.',
       ],
       requisitos: [
         'Por confirmar.',
       ],
       tiempo: 'Por confirmar',
       costo: 'Por confirmar',
       fuente: 'Pendiente de Validar',
       referencia: 'Sin referencia oficial',
       fechaVerificacion: null,
     );
  }
}
