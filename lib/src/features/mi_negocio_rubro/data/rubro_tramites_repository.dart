
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
  });
}

// --- REPOSITORY ---

class RubroTramitesRepository {
  
  // SEED DATA (Expert Content - Panama)
  // Key matches canonical ID: "rest_small"
  // ORDER: Logical Sequence for opening
  static final Map<String, List<TramiteRef>> _rubroTramites = {
    'rest_small': [
      // 1. Foundation
      const TramiteRef(id: 'aviso_operacion', nombre: 'Aviso de Operación', entidad: 'MICI / Panamá Emprende'),
      // 2. Municipal
      const TramiteRef(id: 'municipio_inscripcion', nombre: 'Inscripción Municipal', entidad: 'Municipio de Panamá'),
      // 3. Safety Check
      const TramiteRef(id: 'bomberos_seguridad', nombre: 'Permiso de Seguridad (Inspección)', entidad: 'Cuerpo de Bomberos'),
      // 4. Signage
      const TramiteRef(id: 'municipio_licencia', nombre: 'Licencia de Publicidad Ext.', entidad: 'Municipio de Panamá'),
      // 5. Health (Personnel)
      const TramiteRef(id: 'salud_blanco', nombre: 'Carnet Blanco (Salud)', entidad: 'MINSA / CSS'),
      const TramiteRef(id: 'salud_verde', nombre: 'Carnet Verde (Adiestramiento)', entidad: 'MINSA (Escuela)'),
      // 6. Health (Premises)
      const TramiteRef(id: 'fumigacion', nombre: 'Certificado de Fumigación', entidad: 'Control de Plagas'),
      // 0. Prerequisite (often done before)
      const TramiteRef(id: 'ruc_dgi', nombre: 'Registro RUC', entidad: 'DGI'),
    ],
  };

  static final Map<String, TramiteDetail> _tramiteDetails = {
    // 1. AVISO DE OPERACIÓN
    'aviso_operacion': const TramiteDetail(
      id: 'aviso_operacion',
      nombre: 'Aviso de Operación',
      entidad: 'MICI / Panamá Emprende',
      // DETAILS
      dondeSacar: '100% en Línea a través del portal "Panamá Emprende". No necesitas ir físicamente al MICI.',
      onlineLink: 'https://panamaemprende.gob.pa',
      frecuenciaPago: 'Único (Apertura) + Tasa Anual de \$300 (si es Jurídica) o Impuesto Inmueble (si aplica)',
      tips: [
        'Ten a mano tu Cédula o RUC y tarjeta de crédito/débito para el pago.',
        'Imprime 3 copias del Aviso firmado: una para el local (visible), una para el Municipio, y una de respaldo.',
        'La actividad "Restaurante" requiere venta de licor aparte si aplica. Si solo es comida, usa "Expendio de Comidas".',
        '¡OJO! Al generar el Aviso, automáticamente quedas sujeto a impuestos municipales desde esa fecha.',
      ],
      pasos: [
        'Ingresar a www.panamaemprende.gob.pa.',
        'Crear cuenta o Iniciar Sesión.',
        'Seleccionar "Generar Aviso de Operación".',
        'Definir Actividad (Venta de Comidas y Bebidas).',
        'Declarar ubicación exacta (con corregimiento).',
        'Pagar la boleta (\$15 PN / \$55 PJ).',
        'Descargar PDF del Aviso.',
      ],
      requisitos: [
        'Cédula de Identidad Personal vigente.',
        'Nombre del establecimiento (que no esté usado).',
        'Ubicación física (Dirección exacta).',
        'Capital inicial de inversión (Estimado).',
      ],
      tiempo: 'Inmediato (15-30 minutos)',
      costo: '\$15.00 (Persona Natural) / \$55.00 (Jurídica)',
    ),

    // 2. INSCRIPCIÓN MUNICIPAL
    'municipio_inscripcion': const TramiteDetail(
      id: 'municipio_inscripcion',
      nombre: 'Inscripción Municipal',
      entidad: 'Municipio de Panamá',
      dondeSacar: 'Departamento de Tesorería Municipal (Hatillo) o Centros de Pago (Agencias).',
      frecuenciaPago: 'Mensual (Impuestos Municipales)',
      tips: [
        'Tienes 30 días después de sacar el Aviso de Operación para inscribirte sin multa.',
        'Debes llevar el Aviso de Operación impreso.',
        'Pide tu "Número de Contribuyente" para pagar online en el futuro.',
      ],
      pasos: [
        'Ir a la Agencia Municipal más cercana.',
        'Llenar formulario de inscripción.',
        'Entregar copia de Aviso de Operación y Cédula.',
        'Pagar impuestos iniciales (rotulos, limpieza, etc).',
      ],
      requisitos: [
        'Aviso de Operación (Copia).',
        'Cédula del Propietario (Copia).',
        'Recibo de agua/luz o contrato de arrendamiento.',
        'Croquis simple de ubicación.',
      ],
      tiempo: '1 - 2 días',
      costo: 'Gratis inscripción / Impuesto mensual variable',
    ),

    // 3. BOMBEROS
    'bomberos_seguridad': const TramiteDetail(
      id: 'bomberos_seguridad',
      nombre: 'Permiso de Seguridad (Bomberos)',
      entidad: 'BCBRP (Dinasepi)',
      dondeSacar: 'Cuartel de Bomberos (Oficina de Seguridad) de tu zona.',
      frecuenciaPago: 'Anual (Renovación de Permiso)',
      tips: [
        'Compra extintores NUEVOS, no recargados viejos para empezar.',
        'Para cocina necesitas extintor tipo K (Plateado) y tipo ABC (Rojo) para el salón.',
        'La señalización de salida debe ser luminosa o fotoluminiscente.',
      ],
      pasos: [
        'Solicitar inspección en la ventanilla única o cuartel.',
        'Pagar boleta de inspección.',
        'Recibir visita de inspectores (revisarán extintores y gas).',
        'Si aprueban, retirar el Certificado de Seguridad.',
      ],
      requisitos: [
        'Aviso de Operación.',
        'Extintores (ABC 10lbs mínimo y/o Tipo K).',
        'Señalización de "Salida", "Extintor".',
        'Detectores de humo (según local).',
      ],
      tiempo: '7 - 15 días laborables',
      costo: 'Aprox \$50 - \$150 según metraje',
    ),

    // 4. LICENCIA PUBLICIDAD
    'municipio_licencia': const TramiteDetail(
      id: 'municipio_licencia',
      nombre: 'Licencia de Publicidad Ext.',
      entidad: 'Municipio de Panamá',
      dondeSacar: 'Municipio de Panamá (Depto de Publicidad).',
      frecuenciaPago: 'Anual',
      tips: [
        'Toma una foto clara del letrero ya instalado (o el arte).',
        'Mide el letrero (Alto x Ancho) en metros.',
        'Si no lo declaras, te pueden multar en una inspección.',
      ],
      pasos: [
        'Declarar el letrero en el Municipio.',
        'Entregar foto y medidas.',
        'Pagar el impuesto anual.',
      ],
      requisitos: [
        'Foto del letrero.',
        'Medidas del letrero.',
        'Permiso del dueño del edificio (si alquilas).',
      ],
      tiempo: 'Inmediato (al inscribir)',
      costo: '\$10 - \$20 por m2 (Estimado)',
    ),

    // 5. SALUD - BLANCO
    'salud_blanco': const TramiteDetail(
      id: 'salud_blanco',
      nombre: 'Carnet Blanco (Salud)',
      entidad: 'MINSA / CSS',
      dondeSacar: 'Centro de Salud (MINSA) o Policlínica (CSS).',
      frecuenciaPago: 'Anual (Renovación)',
      tips: [
        'Llega MUY temprano (4:00 AM - 5:00 AM) para conseguir cupo.',
        'Lleva tus muestras (heces/orina) en envases estériles comprados en farmacia.',
        'Debes tener tus dientes sanos (te revisará un odontólogo).',
      ],
      pasos: [
        'Madrugar para cupo.',
        'Entregar muestras y sacar sangre.',
        'Revisión médica y dental.',
        'Retirar carnet (mismo día o día siguiente).',
      ],
      requisitos: [
        'Cédula.',
        '2 Fotos tamaño carnet.',
        'Pago (~20-25 USD en Minsa).',
      ],
      tiempo: '1 día completo',
      costo: '\$20.00 - \$25.00',
    ),

    // 6. SALUD - VERDE
    'salud_verde': const TramiteDetail(
      id: 'salud_verde',
      nombre: 'Carnet Verde (Adiestramiento)',
      entidad: 'Escuela de Manipuladores',
      dondeSacar: 'Escuela de Manipuladores de Alimentos (Juana Diaz u otros).',
      frecuenciaPago: 'Renovación cada 5 años (varía).',
      tips: [
        'ES OBLIGATORIO tener el Carnet Blanco PRIMERO.',
        'Es una charla/clase teórica de un día o media jornada.',
        'Presta atención, hay un examen simple al final.',
      ],
      pasos: [
        'Ir con el Carnet Blanco vigente.',
        'Pagar la inscripción del curso.',
        'Asistir a la charla (higiene, manipulación cruzada, etc).',
        'Aprobar y recibir carnet.',
      ],
      requisitos: [
        'Carnet Blanco Físico.',
        'Cédula.',
        'Fotos tamaño carnet.',
      ],
      tiempo: '1 - 2 días',
      costo: '\$10.00',
    ),

    // 7. FUMIGACIÓN
    'fumigacion': const TramiteDetail(
      id: 'fumigacion',
      nombre: 'Certificado de Fumigación',
      entidad: 'Privado (Empresas Certificadas)',
      dondeSacar: 'Empresas de control de plagas (buscar en Google/Directorios).',
      frecuenciaPago: 'Trimestral (Cada 3 meses obligatorio).',
      tips: [
        'Exige que te den el Certificado Oficial (sticker) para pegar en la entrada.',
        'La empresa debe estar certificada por Salud, si no, no vale.',
        'Guarda la factura.',
      ],
      pasos: [
        'Agendar cita.',
        'Despejar área de cocina.',
        'Fumigación (usualmente noche o día de cierre).',
        'Colocar sticker visible.',
      ],
      requisitos: [
        'Local listo para fumigar.',
      ],
      tiempo: '1 - 2 horas',
      costo: '\$40 - \$80 (Depende tamaño)',
    ),

    // 8. RUC
    'ruc_dgi': const TramiteDetail(
      id: 'ruc_dgi',
      nombre: 'Registro RUC',
      entidad: 'DGI',
      dondeSacar: 'En Línea (DGI e-Tax 2.0).',
      frecuenciaPago: 'N/A',
      tips: [
        'Si eres Persona Natural, tu RUC es tu Cédula con el DV (Dígito Verificador).',
        'Necesitas tu NIT (clave de internet) para declarar impuestos.',
        'Vincula tu cuenta bancaria para pagar impuestos online.',
      ],
      pasos: [
        'Entrar a dgi.mef.gob.pa',
        'Solicitar NIT.',
        'Actualizar datos comericiales.',
      ],
      requisitos: [
        'Cédula.',
        'Correo electrónico.',
      ],
      tiempo: 'Inmediato',
      costo: 'Gratis',
    ),
  };


  // --- METHODS ---

  static String _normalizeId(String id) {
    String s = id.toLowerCase().trim().replaceAll('-', '_').replaceAll(' ', '_');
    // ALIAS MAPPING
    if (s == 'restaurante_pequeno' || s == 'restaurante_pequeño' || s == 'small_restaurant') {
      return 'rest_small';
    }
    return s;
  }

  static List<TramiteRef> getTramitesForRubro(String categoryId, String rubroId) {
    final normalizedId = _normalizeId(rubroId);
    // Return specific list if exists, otherwise empty (Anti-invention rule)
    return _rubroTramites[normalizedId] ?? []; 
  }

  static TramiteDetail? getTramiteDetail(String tramiteId) {
    if (_tramiteDetails.containsKey(tramiteId)) {
      return _tramiteDetails[tramiteId];
    }
    
    // Fallback for known IDs in references to avoid crashing, but keep minimal
    // This allows the "Pendiente de completar" screen to show AT LEAST the title.
    return TramiteDetail(
      id: tramiteId,
      nombre: _guessName(tramiteId),
      entidad: null,
      pasos: [],
      requisitos: [],
    );
  }

  static String _guessName(String id) {
     return id.replaceAll('_', ' ').toUpperCase();
  }
}
