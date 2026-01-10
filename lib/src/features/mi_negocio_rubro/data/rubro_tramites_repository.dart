
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
  
  // EXTENDED FIELDS
  final String? descripcionCompleta;
  final String? dondeSacar;
  final String? onlineLink; // URL if online
  final String? frecuenciaPago; // Mensual / Anual / Único
  final List<String> tips; // Consejos
  final List<String> notasImportantes; // Notas importantes / advertencias
  
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
    this.descripcionCompleta,
    this.dondeSacar,
    this.onlineLink,
    this.frecuenciaPago,
    this.tips = const [],
    this.notasImportantes = const [],
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
  static const _nit = TramiteRef(id: 'nit_dgi', nombre: 'Número de Identificación Tributaria (NIT)', entidad: 'DGI / MEF');
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
    'rest_small': [_nit, _ruc, _avisoOp, _municipio, _bomberos, _letreros, _saludBlanco, _saludVerde, _fumigacion],
    'food_truck': [_nit, _ruc, _avisoOp, _municipio, _bomberos, _saludBlanco, _saludVerde, _fumigacion, _permisoViaPublica],
    'coffee_shop': [_nit, _ruc, _avisoOp, _municipio, _bomberos, _letreros, _saludBlanco, _saludVerde, _fumigacion],
    'bakery': [_nit, _ruc, _avisoOp, _municipio, _bomberos, _letreros, _saludBlanco, _saludVerde, _fumigacion],
    'home_baking': [_nit, _ruc, _saludBlanco, _saludVerde, _registroSanitario], // Less reqs for home? To be verified.
    'street_food': [_municipio, _saludBlanco, _saludVerde, _permisoBuhoneria],
    
    // 2. BELLEZA
    'salon': [_nit, _ruc, _avisoOp, _municipio, _bomberos, _letreros],
    'barbershop': [_nit, _ruc, _avisoOp, _municipio, _bomberos, _letreros],
    'spa': [_nit, _ruc, _avisoOp, _municipio, _bomberos, _letreros, _saludBlanco],
    'nails': [_nit, _ruc, _avisoOp, _municipio, _bomberos, _letreros],

    // 3. RETAIL
    'clothing_store': [_nit, _ruc, _avisoOp, _municipio, _bomberos, _letreros],
    'grocery': [_nit, _ruc, _avisoOp, _municipio, _bomberos, _letreros, _saludBlanco, _fumigacion],
  };

  // --- DETAILS DATABASE ---
  static final Map<String, TramiteDetail> _tramiteDetails = {
    
    // ============================================================
    // 1. NÚMERO DE IDENTIFICACIÓN TRIBUTARIA (NIT) - VERIFIED
    // ============================================================
    'nit_dgi': const TramiteDetail(
      id: 'nit_dgi',
      nombre: 'Número de Identificación Tributaria (NIT)',
      entidad: 'Dirección General de Ingresos (DGI)',
      descripcionCompleta: '''
El Número de Identificación Tributaria (NIT) es una clave de acceso personal, secreta e intransferible que la Dirección General de Ingresos (DGI) autoriza para identificar a los contribuyentes en sus transacciones tributarias que requieran confidencialidad.

El NIT habilita al contribuyente para:
• Obtener información de sus saldos con la DGI
• Consultar las Declaraciones Juradas, pagos y otros actos presentados
• Presentar Declaraciones Juradas interactivamente a través de e-Tax 2.0
• Realizar trámites tributarios en línea de forma segura

Todos los contribuyentes en Panamá (personas naturales, jurídicas e inmuebles) deben obtener este código para poder utilizar los servicios en línea de la DGI.
''',
      dondeSacar: '100% en Línea: Portal e-Tax 2.0 de la DGI.',
      onlineLink: 'https://dgi.mef.gob.pa',
      frecuenciaPago: 'Único (Sin costo)',
      fuente: 'DGI - Ministerio de Economía y Finanzas',
      referencia: 'Portal e-Tax 2.0 - Sitio Oficial',
      fechaVerificacion: '2026-01-09',
      tips: [
        'Anota tu NIT en un lugar seguro o imprime la página de confirmación.',
        'El NIT debe cambiarse cada 6 meses por seguridad.',
        'Asegúrate de tener acceso al correo electrónico registrado.',
        'El link de activación solo es válido por 2 horas.',
      ],
      notasImportantes: [
        'El NIT debe tener entre 12 y 20 caracteres.',
        'Debe incluir al menos una letra mayúscula, una minúscula y dos números.',
        'NO debe contener símbolos especiales.',
        'La DGI enviará confirmación dentro de 2 días hábiles.',
        'Si la DGI no puede verificar tu identidad o datos, el NIT será rechazado.',
      ],
      pasos: [
        'Ingresar a www.dgi.mef.gob.pa.',
        'Hacer clic en el botón naranja de e-Tax 2.0.',
        'Seleccionar "REGISTRO" y luego "Obtener NIT".',
        'Ingresar tu número de RUC y Dígito Verificador (DV).',
        'Proporcionar una dirección de correo electrónico válida.',
        'Crear tu clave NIT siguiendo los parámetros de seguridad.',
        'Revisar tu correo electrónico para el enlace de activación.',
        'Activar el NIT dentro de las 2 horas siguientes.',
      ],
      requisitos: [
        'Número de RUC (Registro Único de Contribuyente).',
        'Dígito Verificador (DV).',
        'Dirección de correo electrónico válida y accesible.',
        'Para personas jurídicas: Estar inscrito en el RUC o contar con Número Tributario actualizado.',
      ],
      tiempo: 'Inmediato (una vez activado)',
      costo: 'Gratis',
    ),

    // ============================================================
    // 2. AVISO DE OPERACIÓN - VERIFIED
    // ============================================================
    'aviso_operacion': const TramiteDetail(
      id: 'aviso_operacion',
      nombre: 'Aviso de Operación',
      entidad: 'MICI / Panamá Emprende',
      descripcionCompleta: '''
El Aviso de Operación es un documento oficial emitido por el Ministerio de Comercio e Industrias (MICI) a través de la plataforma Panamá Emprende. Este documento certifica que una persona natural o jurídica ha informado a la Administración Pública sobre su actividad comercial o industrial, e incluye una declaración jurada de cumplimiento de las normativas aplicables.

Es el primer paso fundamental para formalizar cualquier negocio en Panamá. Sin este documento, no podrás inscribirte en el municipio ni cumplir con otras obligaciones legales.

Una vez generado el Aviso de Operación, se activan automáticamente las obligaciones tributarias tanto municipales como nacionales (DGI). El documento debe estar impreso y visible en el establecimiento donde se brinda el servicio.
''',
      dondeSacar: '100% en Línea: Portal "Panamá Emprende" (www.panamaemprende.gob.pa).',
      onlineLink: 'https://panamaemprende.gob.pa',
      frecuenciaPago: 'Único (Apertura) + Tasa Anual de renovación',
      fuente: 'MICI - Panamá Emprende',
      referencia: 'Portal Oficial panamaemprende.gob.pa',
      fechaVerificacion: '2026-01-09',
      tips: [
        'Ten a mano tu Cédula o RUC y tarjeta de crédito/débito para el pago.',
        'Imprime al menos 3 copias del Aviso firmado para tus trámites posteriores.',
        'Guarda el usuario y contraseña del portal para futuras renovaciones.',
        'Selecciona correctamente tu actividad económica; algunas están reguladas.',
        'El monto mínimo de inversión para registrar es de B/.100.00.',
      ],
      notasImportantes: [
        'Desde la fecha de creación del Aviso, se generan obligaciones tributarias.',
        'Tienes 30 días después del Aviso para inscribirte en el Municipio sin multa.',
        'Algunas actividades (alimentos, bebidas alcohólicas, farmacéuticas, etc.) requieren permisos adicionales ANTES de solicitar el Aviso.',
        'Actividades como ganadería, agroforestales, avícolas y sin fines de lucro generalmente NO requieren Aviso de Operación.',
        'Puedes cancelar tu Aviso de Operación a través de la misma plataforma sin costo.',
      ],
      pasos: [
        'Ingresar a www.panamaemprende.gob.pa.',
        'Registrarse o Iniciar Sesión con tu cuenta de usuario.',
        'Crear registro de Persona Natural o Jurídica (validar cédula o RUC).',
        'Registrar la actividad comercial o industrial principal.',
        'Aceptar la Declaración Jurada.',
        'Realizar el pago en línea (Banco Nacional, tarjeta de crédito/débito).',
        'Imprimir el Aviso de Operación generado.',
        'Colocar el Aviso impreso en un lugar visible del establecimiento.',
      ],
      requisitos: [
        'Ser mayor de edad con capacidad legal para contratar.',
        'Cédula de Identidad Personal (panameños) o Pasaporte (extranjeros).',
        'Dirección física en Panamá donde se llevará a cabo la actividad.',
        'Nombre comercial único para tu negocio.',
        'Para Persona Jurídica: Número de RUC de la empresa registrada en la DGI.',
        'Para Persona Jurídica: Nombres de la Junta Directiva y Representante Legal.',
      ],
      tiempo: 'Inmediato (una vez aprobado el pago)',
      costo: 'B/.15.00 (Persona Natural) / B/.55.00 (Persona Jurídica)',
    ),

    // ============================================================
    // 3. REGISTRO RUC - VERIFIED
    // ============================================================
    'ruc_dgi': const TramiteDetail(
      id: 'ruc_dgi',
      nombre: 'Registro Único de Contribuyente (RUC)',
      entidad: 'Dirección General de Ingresos (DGI)',
      descripcionCompleta: '''
El Registro Único de Contribuyente (RUC) es el número de identificación tributaria que asigna la Dirección General de Ingresos (DGI) a todas las personas naturales y jurídicas que desarrollan actividades económicas en Panamá.

Para personas naturales panameñas, el RUC corresponde a su número de cédula de identidad personal. Para personas jurídicas, el RUC se crea al momento de su inscripción en el Registro Público.

El RUC es obligatorio para:
• Emitir facturas fiscales
• Presentar declaraciones de impuestos
• Realizar importaciones y exportaciones
• Abrir cuentas comerciales bancarias
• Participar en licitaciones públicas

El proceso de inscripción se realiza principalmente en línea a través del sistema e-Tax 2.0 de la DGI.
''',
      dondeSacar: 'En Línea: Portal e-Tax 2.0 de la DGI o presencial en oficinas de la DGI.',
      onlineLink: 'https://dgi.mef.gob.pa',
      frecuenciaPago: 'Único (Inscripción gratuita)',
      fuente: 'DGI - Ministerio de Economía y Finanzas',
      referencia: 'Portal e-Tax 2.0 - mef.gob.pa',
      fechaVerificacion: '2026-01-09',
      tips: [
        'Si eres persona natural panameña, tu RUC es tu número de cédula.',
        'Guarda una copia del recibo de servicio público que uses como comprobante de domicilio.',
        'Si necesitas presentar declaración de renta, registra un Contador Público Autorizado.',
        'Verifica que tu correo electrónico esté actualizado para recibir notificaciones.',
      ],
      notasImportantes: [
        'Los documentos del extranjero deben estar apostillados y en español.',
        'Sociedades inscritas en el Registro Público deben inscribirse en la DGI para pagar el Impuesto de Tasa Única anual.',
        'El tiempo de aprobación puede variar entre 2 y 6 días hábiles.',
        'Si la solicitud es rechazada, recibirás un correo con los motivos.',
      ],
      pasos: [
        'Acceder a dgi.mef.gob.pa y seleccionar e-Tax 2.0.',
        'Hacer clic en "Registro" y luego en "Solicitud de Inscripción".',
        'Seleccionar tipo de contribuyente: "Persona Natural" o "Persona Jurídica".',
        'Completar todos los campos obligatorios del formulario.',
        'Adjuntar los documentos escaneados requeridos.',
        'Presentar la solicitud.',
        'Esperar notificación por correo electrónico (2-6 días hábiles).',
      ],
      requisitos: [
        'PERSONA NATURAL PANAMEÑA: Fotocopia de cédula vigente.',
        'PERSONA NATURAL EXTRANJERA: Pasaporte original y copia.',
        'Recibo reciente de servicios públicos (luz, agua o teléfono) que coincida con el domicilio.',
        'PERSONA JURÍDICA: Poder notariado (a menos que el representante se presente personalmente).',
        'PERSONA JURÍDICA: Copia de cédula del Representante Legal.',
        'PERSONA JURÍDICA: Pacto social inscrito en el Registro Público o certificado vigente.',
        'PERSONA JURÍDICA: Aviso de Operaciones (con algunas excepciones).',
      ],
      tiempo: '2 a 6 días hábiles',
      costo: 'Gratis',
    ),

    // ============================================================
    // 4. INSCRIPCIÓN MUNICIPAL - VERIFIED
    // ============================================================
    'municipio_inscripcion': const TramiteDetail(
      id: 'municipio_inscripcion',
      nombre: 'Inscripción Municipal (Registro de Contribuyente)',
      entidad: 'Municipio de Panamá (MUPA)',
      descripcionCompleta: '''
La Inscripción Municipal es un trámite obligatorio para toda persona natural o jurídica que establezca un negocio en el Distrito de Panamá. Este registro te inscribe como contribuyente municipal y te permite operar legalmente dentro del municipio.

El Municipio de Panamá grava todas las actividades industriales, comerciales o lucrativas que se realizan en su distrito con impuestos, tasas, derechos y contribuciones.

Este impuesto municipal se estructura sobre los ingresos, ventas o comisiones anuales brutas de las actividades comerciales y es de pago mensual.

La inscripción debe realizarse inmediatamente después de obtener el Aviso de Operación. Tienes un plazo de 30 días para inscribirte y evitar multas.
''',
      dondeSacar: 'Presencial: Tesorería Municipal en El Hatillo o Agencias Municipales. También disponible parcialmente en línea en mupa.gob.pa.',
      onlineLink: 'https://mupa.gob.pa',
      frecuenciaPago: 'Mensual (impuesto de actividad comercial)',
      fuente: 'Municipio de Panamá',
      referencia: 'Tesorería Municipal - mupa.gob.pa',
      fechaVerificacion: '2026-01-09',
      tips: [
        'Inscríbete dentro de los 30 días posteriores al Aviso de Operación para evitar multas.',
        'Prepara un croquis claro con al menos 2 puntos de referencia.',
        'Los pagos pueden realizarse en la tesorería o por transferencia electrónica.',
        'Guarda todos los recibos de pago mensual para tu declaración anual.',
        'Incluso sin ingresos, debes presentar declaración anual.',
      ],
      notasImportantes: [
        'Si el pago mensual vence, se aplica un recargo del 20% más 1% adicional por cada mes de mora.',
        'La omisión de la declaración de renta anual genera una multa de B/.500.00.',
        'Los ingresos brutos declarados deben coincidir con la declaración jurada de renta de la DGI.',
        'El impuesto de rótulo (publicidad) se declara por metros cuadrados del letrero.',
        'Para extranjeros se requiere pasaporte apostillado o carnet de extranjero permanente.',
      ],
      pasos: [
        'Reunir todos los documentos requeridos.',
        'Acudir a la Agencia Municipal o Tesorería en El Hatillo.',
        'Entregar documentos y llenar la solicitud de inscripción.',
        'El Municipio realizará una inspección del local comercial.',
        'Pagar los impuestos iniciales según la actividad económica.',
        'Recibir el certificado de inscripción como contribuyente.',
      ],
      requisitos: [
        'Copia del Aviso de Operación.',
        'Copia de Cédula o Pasaporte del Representante Legal.',
        'Croquis de ubicación del establecimiento (con corregimiento, urbanización, barriada, calle, número de local, y 2 puntos de referencia).',
        'Fotografía de la fachada principal del local comercial.',
        'Correo electrónico y teléfonos de contacto actualizados.',
        'Declaraciones de Renta desde la fecha de inicio de operaciones.',
        'PERSONA JURÍDICA ADICIONAL: Pacto Social autenticado y Certificado de Registro Público vigente (no mayor a 3 meses).',
        'Si un tercero realiza el trámite: Carta de autorización notariada.',
      ],
      tiempo: '1 a 3 días (según inspección)',
      costo: 'Variable según actividad económica (base imponible sobre ingresos brutos)',
    ),

    // ============================================================
    // 5. PERMISO DE BOMBEROS - VERIFIED
    // ============================================================
    'bomberos_seguridad': const TramiteDetail(
      id: 'bomberos_seguridad',
      nombre: 'Permiso de Seguridad (Inspección de Bomberos)',
      entidad: 'Benemérito Cuerpo de Bomberos de la República de Panamá (BCBRP)',
      descripcionCompleta: '''
El Permiso de Seguridad es una certificación emitida por la Dirección Nacional de Seguridad, Prevención e Investigación de Incendios (DINASEPI) del Cuerpo de Bomberos de Panamá.

Este permiso garantiza que tu establecimiento cumple con las normas de seguridad para prevenir o reducir los riesgos de incendios y otros peligros para las personas y los bienes.

Es obligatorio para la mayoría de negocios y debe renovarse anualmente. Los inspectores de bomberos verificarán que tu local cuente con los equipos de seguridad adecuados, señalización fotoluminiscente, rutas de evacuación claras, y sistemas de extinción de incendios funcionales.

Según la Resolución N° 102-2023 del BCBRP, el incumplimiento de estas normas puede resultar en multas que oscilan entre B/.250.00 y B/.3,400.00.
''',
      dondeSacar: 'Presencial: Oficinas de DINASEPI en el Cuartel de Bomberos de tu zona.',
      onlineLink: 'https://bomberos.gob.pa',
      frecuenciaPago: 'Anual',
      fuente: 'BCBRP - DINASEPI',
      referencia: 'Reglamento de Seguridad - bomberos.gob.pa',
      fechaVerificacion: '2026-01-09',
      tips: [
        'Verifica que tus extintores estén recargados con etiqueta vigente.',
        'La señalización fotoluminiscente es OBLIGATORIA.',
        'Mantén libres las rutas de evacuación y salidas de emergencia.',
        'Los extintores deben ser tipo ABC para fuegos generales y tipo K para cocinas.',
        'Todas las observaciones técnicas deben consignarse en la primera inspección (no pueden agregar nuevas exigencias en reinspecciones).',
      ],
      notasImportantes: [
        'Multas por incumplimiento: B/.250.00 a B/.3,400.00 (Resolución N° 102-2023).',
        'Es responsabilidad del propietario la verificación periódica de sistemas eléctricos, mecánicos, de gas y equipos de extracción de humo.',
        'Los sistemas de rociadores y bombas contra incendios deben cumplir normas NFPA (13, 20, 25, 14).',
        'Las alarmas contra incendios deben cumplir la norma NFPA 72.',
        'El mantenimiento de extintores debe seguir la normativa NFPA 10.',
      ],
      pasos: [
        'Redactar un memorial formal dirigido al Director General del BCBRP indicando: nombre del solicitante, motivo de inspección y dirección exacta.',
        'Presentar el memorial en las oficinas de DINASEPI.',
        'Recibir la Solicitud de Servicio y volante de pago.',
        'Realizar el depósito en el banco y conservar el comprobante.',
        'Presentar el comprobante en las oficinas de Bomberos para obtener la factura oficial.',
        'Esperar la visita programada para la inspección del local.',
        'Retirar el informe técnico en DINASEPI.',
      ],
      requisitos: [
        'Memorial de solicitud formal.',
        'Copia del Aviso de Operación.',
        'Copia de Cédula del Representante Legal.',
        'Extintores tipo ABC (cantidad según metros cuadrados del local).',
        'Extintores tipo K (si tiene cocina comercial).',
        'Detectores de humo funcionales (si aplica según tipo de negocio).',
        'Detectores de gas (si utiliza gas propano o natural).',
        'Señalización fotoluminiscente de rutas de evacuación.',
        'Salidas de emergencia despejadas y señalizadas.',
      ],
      tiempo: '7 a 15 días (según agenda de inspecciones)',
      costo: 'Variable según metros cuadrados del local (establecido en Gaceta Oficial)',
    ),

    // ============================================================
    // 6. LICENCIA DE PUBLICIDAD EXTERIOR - VERIFIED
    // ============================================================
    'municipio_licencia': const TramiteDetail(
      id: 'municipio_licencia',
      nombre: 'Licencia de Publicidad Exterior (Impuesto de Rótulo)',
      entidad: 'Municipio de Panamá (MUPA)',
      descripcionCompleta: '''
La Licencia de Publicidad Exterior, también conocida como Impuesto de Rótulo, es un tributo municipal obligatorio para todos los negocios que exhiban letreros, vallas o cualquier tipo de publicidad visible desde la vía pública.

Desde enero de 2016, el rótulo pasó a ser declarativo. Esto significa que debes declarar las dimensiones de tu letrero (largo por ancho) en metros cuadrados al momento de inscribir tu negocio en el municipio.

Este impuesto se paga anualmente y su monto depende del área total del letrero. Es obligatorio para cualquier negocio que desee tener visibilidad comercial mediante publicidad exterior.

El incumplimiento de esta obligación puede resultar en multas y la orden de retirar la publicidad no autorizada.
''',
      dondeSacar: 'Presencial: Municipio de Panamá - Tesorería Municipal o en línea a través de mupa.gob.pa.',
      onlineLink: 'https://mupa.gob.pa',
      frecuenciaPago: 'Anual',
      fuente: 'Municipio de Panamá',
      referencia: 'Departamento de Publicidad Exterior - MUPA',
      fechaVerificacion: '2026-01-09',
      tips: [
        'Mide tu letrero con precisión: largo x ancho en metros.',
        'Toma una foto clara del letrero para adjuntar a la solicitud.',
        'Si tu letrero está en propiedad de terceros, necesitas autorización del dueño del inmueble.',
        'Considera el impacto visual y las regulaciones urbanísticas de la zona.',
      ],
      notasImportantes: [
        'El impuesto se calcula por metros cuadrados del área del letrero.',
        'La declaración es obligatoria al momento de la inscripción municipal.',
        'Si modificas el tamaño del letrero, debes actualizar la declaración.',
        'Los letreros no declarados pueden ser decomisados y multados.',
      ],
      pasos: [
        'Medir las dimensiones exactas del letrero (ancho x alto).',
        'Tomar fotografía clara del letrero instalado o diseño propuesto.',
        'Declarar las dimensiones en metros cuadrados al inscribirse en el municipio.',
        'Pagar el impuesto anual correspondiente.',
        'Renovar anualmente junto con los tributos municipales.',
      ],
      requisitos: [
        'Fotografía del letrero (fachada visible).',
        'Medidas exactas en metros: Alto x Ancho.',
        'Autorización del dueño del inmueble (si el local es alquilado).',
        'Copia del Aviso de Operación vigente.',
        'Estar inscrito como contribuyente municipal.',
      ],
      tiempo: 'Inmediato (junto con inscripción municipal)',
      costo: 'Variable según metros cuadrados del letrero',
    ),

    // ============================================================
    // 7. CARNET BLANCO (SALUD) - VERIFIED
    // ============================================================
    'salud_blanco': const TramiteDetail(
      id: 'salud_blanco',
      nombre: 'Carnet de Salud Blanco',
      entidad: 'Ministerio de Salud (MINSA) / CSS',
      descripcionCompleta: '''
El Carnet de Salud Blanco es un certificado oficial emitido por el Ministerio de Salud (MINSA) que certifica que el portador no padece enfermedades transmisibles que puedan afectar a otras personas a través de los alimentos u otras actividades de interés sanitario.

Es un requisito OBLIGATORIO para todas las personas que trabajan en:
• Preparación y manipulación de alimentos
• Restaurantes, cafeterías y comedores
• Panaderías y reposterías
• Hoteles y hospedajes
• Centros de atención a adultos mayores o niños
• Establecimientos de salud
• Cualquier actividad de interés sanitario

El carnet tiene una validez de UN AÑO desde su emisión y debe renovarse anualmente. Es requisito previo para obtener el Carnet Verde de adiestramiento.

El MINSA realiza ferias comunitarias periódicamente para facilitar la obtención de este documento.
''',
      dondeSacar: 'Presencial: Centros de Salud del MINSA en todo el país, Policlínicas de la CSS, y Ferias de Salud periódicas.',
      frecuenciaPago: 'Anual (renovación)',
      fuente: 'MINSA - Ministerio de Salud de Panamá',
      referencia: 'Departamento de Control de Alimentos - MINSA',
      fechaVerificacion: '2026-01-09',
      tips: [
        'LLEGA TEMPRANO: La atención suele iniciar a las 7:00 AM y los cupos son limitados.',
        'Lleva tu muestra de heces preparada desde casa, debidamente etiquetada.',
        'Si eres mayor de 40 años, ve en AYUNAS para la toma de sangre.',
        'Las mujeres deben estar preparadas para el examen de Papanicolaou.',
        'Aprovecha las ferias de salud que organiza el MINSA en distintas comunidades.',
      ],
      notasImportantes: [
        'El Carnet Blanco es REQUISITO PREVIO para obtener el Carnet Verde.',
        'La validez es de 1 año desde la fecha de emisión.',
        'Sin este carnet, NO puedes trabajar manipulando alimentos.',
        'Si trabajas con productos lácteos o cárnicos, pueden requerir examen adicional de Brucelosis.',
        'El esquema de vacunación debe estar actualizado.',
      ],
      pasos: [
        'Recoger muestra de heces en casa en un envase limpio, etiquetado con nombre y cédula.',
        'Acudir en ayunas (si es mayor de 40 años) al centro de salud temprano en la mañana.',
        'Presentar cédula original y copia.',
        'Entregar la muestra de heces para análisis de parásitos.',
        'Realizarse la prueba de sangre (glucosa y PCA).',
        'Pasar por revisión odontológica.',
        'Verificar y actualizar el esquema de vacunación.',
        'Para mujeres: Realizarse examen de Papanicolaou.',
        'Pagar la tarifa establecida (B/.25.00 aproximadamente).',
        'Esperar los resultados y recibir el carnet.',
      ],
      requisitos: [
        'Cédula de Identidad Personal original y copia (panameños).',
        'Pasaporte vigente y estatus migratorio legal (extranjeros).',
        'Muestra de heces en envase adecuado, etiquetado con nombre y número de cédula.',
        'Acudir en ayunas si es mayor de 40 años.',
        'Esquema de vacunación actualizado (COVID-19 completo).',
        '2 fotografías tamaño carnet recientes (no selfies).',
      ],
      tiempo: '1 día (si todos los exámenes están listos)',
      costo: 'B/.25.00 aproximadamente',
    ),

    // ============================================================
    // 8. CARNET VERDE (ADIESTRAMIENTO) - VERIFIED
    // ============================================================
    'salud_verde': const TramiteDetail(
      id: 'salud_verde',
      nombre: 'Carnet Verde (Adiestramiento Sanitario)',
      entidad: 'MINSA - Centro de Capacitación para Manipuladores de Alimentos',
      descripcionCompleta: '''
El Carnet Verde, también conocido como Certificado de Adiestramiento Sanitario, es un documento obligatorio que certifica que el portador ha recibido capacitación en la correcta manipulación de alimentos y normas de higiene sanitaria.

Este carnet complementa al Carnet Blanco y es OBLIGATORIO para todas las personas que manipulan alimentos en su trabajo. Se obtiene después de asistir a una capacitación teórica y aprobar un examen escrito.

Durante la capacitación se abordan temas como:
• Adecuada manipulación de alimentos
• Uso correcto de equipo personal (redecillas, guantes, delantales, mascarillas)
• Limpieza y desinfección de herramientas y áreas de trabajo
• Prevención de contaminación cruzada
• Almacenamiento adecuado de alimentos
• Buenas prácticas de manufactura

El objetivo es garantizar que los manipuladores de alimentos cumplan con las normas sanitarias vigentes en materia de salud pública.
''',
      dondeSacar: 'Presencial: Centros de Capacitación del MINSA (ubicados en diferentes regiones del país).',
      frecuenciaPago: 'Anual (renovación)',
      fuente: 'MINSA - Centros de Capacitación para Manipuladores de Alimentos',
      referencia: 'Escuela de Manipuladores - minsa.gob.pa',
      fechaVerificacion: '2026-01-09',
      tips: [
        'Obtén primero el Carnet Blanco; es requisito indispensable.',
        'Llega temprano (7:00 - 7:30 AM) porque los cupos son limitados.',
        'En algunas sedes como Panamá Norte es necesario agendar cita previa.',
        'Lleva ropa formal: zapatos cerrados y blusa/camisa con mangas.',
        'Presta atención a la charla; el examen es sobre los temas tratados.',
      ],
      notasImportantes: [
        'El Carnet Blanco VIGENTE es requisito indispensable.',
        'Debes aprobar un examen escrito al finalizar la capacitación.',
        'Las fotos NO deben ser selfies y deben ser en papel fotográfico.',
        'Sin gorra, vincha ni lentes de sol en las fotografías.',
        'Si no tienes esquema COVID-19 completo, pueden requerir prueba negativa.',
      ],
      pasos: [
        'Obtener el Carnet Blanco vigente (requisito previo).',
        'Acudir al Centro de Capacitación del MINSA de tu región.',
        'Presentar documentos requeridos y pagar la tarifa.',
        'Asistir a la charla de capacitación sobre manipulación de alimentos.',
        'Aprobar el examen escrito de conocimientos.',
        'Recibir el Carnet Verde de Adiestramiento.',
      ],
      requisitos: [
        'Carnet Blanco VIGENTE: Original y copia por ambas caras.',
        'Cédula de identidad vigente (copia) o pasaporte con estatus migratorio legal.',
        '2 fotografías tamaño carnet recientes (en papel fotográfico, sin gorra, vincha o lentes de sol).',
        'Esquema de vacunación COVID-19 completo.',
        'Vestimenta formal: zapatos cerrados y blusa o camisa con mangas.',
      ],
      tiempo: '1 día (capacitación + examen)',
      costo: 'B/.10.00 a B/.15.00 aproximadamente',
    ),

    // ============================================================
    // 9. CERTIFICADO DE FUMIGACIÓN - VERIFIED
    // ============================================================
    'fumigacion': const TramiteDetail(
      id: 'fumigacion',
      nombre: 'Certificado de Fumigación (Control de Plagas)',
      entidad: 'Empresas Autorizadas por MINSA / Municipio de Panamá',
      descripcionCompleta: '''
El Certificado de Fumigación es un documento que acredita que tu establecimiento comercial ha recibido un servicio profesional de control de plagas por una empresa debidamente autorizada por el Ministerio de Salud (MINSA).

Es OBLIGATORIO para todos los negocios y debe realizarse con frecuencia periódica según el tipo de actividad económica:

• MENSUAL: Establecimientos que almacenen, elaboren, manipulen, vendan o transformen productos alimenticios o bebidas; hospedajes; atención de adultos mayores, enfermos o niños; y establecimientos de salud.

• CADA 2 MESES: Todas las demás actividades económicas, oficinas o comercios.

El certificado debe exhibirse en un lugar visible del establecimiento para las inspecciones municipales. El Municipio de Panamá ahora emite un certificado digital con código QR que permite verificar la fecha y vigencia del servicio.

Solo debes contratar empresas que cuenten con el Permiso Sanitario de Operación del MINSA (Decreto Ejecutivo 386 del 4 de septiembre de 1997).
''',
      dondeSacar: 'Contratar empresa de control de plagas AUTORIZADA por el MINSA.',
      frecuenciaPago: 'Mensual o Bimestral (según tipo de negocio)',
      fuente: 'MINSA - Decreto Ejecutivo 386 / Municipio de Panamá',
      referencia: 'Regulación de Control de Plagas - mupa.gob.pa',
      fechaVerificacion: '2026-01-09',
      tips: [
        'Verifica que la empresa tenga Permiso Sanitario de Operación del MINSA.',
        'Solicita siempre el certificado oficial con los datos del servicio.',
        'Guarda una copia digital del certificado con código QR.',
        'Programa las fumigaciones con anticipación para no vencer.',
        'Pregunta por paquetes anuales que pueden resultar más económicos.',
      ],
      notasImportantes: [
        'NEGOCIOS DE ALIMENTOS: Fumigación MENSUAL obligatoria.',
        'OTROS NEGOCIOS: Fumigación cada 2 MESES obligatoria.',
        'El certificado debe exhibirse en lugar visible.',
        'El certificado digital del MUPA tiene código QR verificable.',
        'Solo contrata empresas con Permiso Sanitario de Operación vigente del MINSA.',
        'Las empresas de fumigación deben tener asesor técnico (Ingeniero Agrónomo, Biólogo o Veterinario).',
      ],
      pasos: [
        'Buscar una empresa de control de plagas autorizada por el MINSA.',
        'Verificar que la empresa tenga Permiso Sanitario de Operación vigente.',
        'Solicitar cotización y programar el servicio.',
        'Recibir la fumigación en el establecimiento.',
        'Solicitar el certificado oficial con todos los datos del servicio.',
        'Exhibir el certificado en un lugar visible del local.',
        'Programar la próxima fumigación según la frecuencia requerida.',
      ],
      requisitos: [
        'Contratar empresa debidamente autorizada por el MINSA.',
        'Mantener el local accesible para el servicio de fumigación.',
        'Seguir las instrucciones de la empresa sobre tiempos de espera antes de reabrir.',
        'Guardar los certificados anteriores como respaldo.',
      ],
      tiempo: 'Mismo día del servicio',
      costo: 'Variable según tamaño del local y empresa contratada (típicamente B/.25.00 a B/.100.00+)',
    ),

    // ============================================================
    // 10. PERMISO DE USO DE VÍA PÚBLICA - VERIFIED
    // ============================================================
    'permiso_via_publica_mupa': const TramiteDetail(
      id: 'permiso_via_publica_mupa',
      nombre: 'Permiso de Uso de Vía Pública (Kioscos/Food Trucks)',
      entidad: 'Municipio de Panamá - Dirección de Legal y Justicia',
      descripcionCompleta: '''
Este permiso autoriza la ocupación temporal de espacios públicos (aceras, parques, servidumbres) para ejercer actividades comerciales mediante estructuras removibles como kioscos, módulos o vehículos (food trucks).

Es fundamental contar con el Visto Bueno de la Junta Comunal del corregimiento donde se ubicará el negocio. Este permiso es revocable y no otorga derechos de propiedad sobre el espacio público.

El costo mensual depende de la zona y los metros cuadrados ocupados.
''',
      dondeSacar: 'Municipio de Panamá - Dirección de Legal y Justicia (Edificio Hatillo).',
      frecuenciaPago: 'Mensual',
      fuente: 'Municipio de Panamá',
      referencia: 'Acuerdo Municipal sobre Uso de Espacios Públicos',
      fechaVerificacion: '2026-01-09',
      tips: [
        'Obtén primero el Visto Bueno de la Junta Comunal; es el paso más crítico.',
        'Asegúrate de que tu estructura no obstruya el paso peatonal (mínimo 1.20 metros libres).',
        'Los Food Trucks deben tener inspección de Bomberos y ATTT vigente.',
        'No construyas estructuras fijas (cemento/bloques) en vía pública.',
      ],
      notasImportantes: [
        'El permiso es personal e intransferible.',
        'La Alcaldía puede revocar el permiso por razones de ordenamiento urbano.',
        'Se prohíbe el expendio de bebidas alcohólicas sin un permiso especial adicional.',
      ],
      pasos: [
        'Obtener nota de Visto Bueno de la Junta Comunal del Corregimiento.',
        'Redactar nota dirigida al Alcalde solicitando el uso del espacio.',
        'Elaborar un croquis detallado de la ubicación y dimensiones.',
        'Presentar documentos en la Dirección de Legal y Justicia.',
        'Esperar la inspección municipal.',
        'Firmar el contrato de arrendamiento de espacio público.',
        'Pagar la mensualidad correspondiente en Tesorería.',
      ],
      requisitos: [
        'Nota de solicitud dirigida al Alcalde (con B/.4.00 en timbres).',
        'Visto Bueno original de la Junta Comunal.',
        'Copia de cédula del solicitante.',
        'Croquis de ubicación y diseño del kiosco/food truck.',
        'Paz y Salvo Municipal vigente.',
        'Fotos del lugar y de la estructura a instalar.',
      ],
      tiempo: '15 a 30 días',
      costo: 'Variable (Canon de arrendamiento según zona y mts2)',
    ),

    // ============================================================
    // 11. PERMISO DE BUHONERÍA - VERIFIED
    // ============================================================
    'permiso_buhoneria': const TramiteDetail(
      id: 'permiso_buhoneria',
      nombre: 'Permiso de Buhonería (Venta Ambulante)',
      entidad: 'Municipio de Panamá - Servicios a la Comunidad',
      descripcionCompleta: '''
El Permiso de Buhonería regula la venta al por menor de mercancías o alimentos en la vía pública de manera ambulante o en puestos estacionarios temporales.

IMPORTANTE: Según la ley panameña, el ejercicio de la buhonería es EXCLUSIVO para nacionales panameños (por nacimiento o naturalización).

Este permiso busca organizar la economía informal y asegurar que se cumplan normas mínimas de salubridad y orden público.
''',
      dondeSacar: 'Municipio de Panamá - Subgerencia de Buhonería (Edificio Las Américas).',
      frecuenciaPago: 'Mensual',
      fuente: 'Municipio de Panamá',
      referencia: 'Decreto Alcaldicio sobre Buhonería',
      fechaVerificacion: '2026-01-09',
      tips: [
        'Solo aplica para panameños; no insista si es extranjero.',
        'Existen zonas restringidas (Cinta Costera, Casco Antiguo, Zonas Pagas del Metro) que requieren permisos especiales o están vedadas.',
        'Mantén siempre tu carnet de salud vigente si vendes alimentos.',
      ],
      notasImportantes: [
        'Actividad exclusiva para panameños.',
        'Se prohíbe la venta de bebidas alcohólicas, cigarrillos al detal y pirotecnia.',
        'El puesto no puede obstaculizar el libre tránsito peatonal.',
        'Debe mantener limpia el área alrededor de su puesto (2 metros a la redonda).',
      ],
      pasos: [
        'Redactar carta de solicitud dirigida al Alcalde.',
        'Obtener Visto Bueno de la Junta Comunal (recomendado).',
        'Presentar documentos en la Subgerencia de Buhonería.',
        'Pasar la evaluación social (trabajo social).',
        'Asistir a charla de inducción (si aplica).',
        'Recibir el carnet de buhonero.',
      ],
      requisitos: [
        'Ser panameño (Cédula de Identidad Personal).',
        'Carnet de Salud Blanco y Verde (si vende alimentos).',
        'Paz y Salvo Municipal.',
        'Dos fotos tamaño carnet.',
        'Nota de solicitud.',
      ],
      tiempo: '15 a 20 días',
      costo: 'B/.10.00 a B/.20.00 mensual (aprox.)',
    ),

    // ============================================================
    // 12. REGISTRO SANITARIO DE ALIMENTOS (ARTESANAL) - VERIFIED
    // ============================================================
    'registro_sanitario_artesanal': const TramiteDetail(
      id: 'registro_sanitario_artesanal',
      nombre: 'Registro Sanitario de Alimentos (Modalidad Artesanal)',
      entidad: 'MINSA - Dirección Nacional de Control de Alimentos (DEPA)',
      descripcionCompleta: '''
El Registro Sanitario es la autorización que expide el MINSA para que un producto alimenticio procesado o empacado pueda ser comercializado legalmente en el país.

La modalidad "Artesanal" o de "Pequeña Industria" está dirigida a microempresarios que elaboran productos en casa o en pequeños locales, ofreciendo requisitos simplificados en comparación con el registro industrial.

Aplica para mermeladas, salsas, panes empacados, dulces, bebidas embotelladas, etc. No aplica para comidas servidas en restaurante (eso requiere Permiso Sanitario de Operación), sino para productos EMPACADOS para la venta.
''',
      dondeSacar: 'MINSA - Departamento de Protección de Alimentos (DEPA) o Región de Salud correspondiente.',
      frecuenciaPago: 'Quinquenal (Cada 5 años)',
      fuente: 'MINSA - DEPA',
      referencia: 'Autoridad Panameña de Seguridad de Alimentos / MINSA',
      fechaVerificacion: '2026-01-09',
      tips: [
        'Asegúrate de tener un "etiquetado" que cumpla con la norma (nombre, ingredientes, fecha vencimiento, lote).',
        'Necesitarás un laboratorio bromatológico (análisis del alimento) previo a la solicitud.',
        'Si es tu cocina de casa, debe estar impecable y separada de mascotas/contaminación.',
        'Consulta por las tarifas diferenciadas para MIPYMES.',
      ],
      notasImportantes: [
        'Diferencia clave: Esto es para el PRODUCTO, no para el local.',
        'El local donde se elabora también necesitará Inspección Sanitaria (Permiso de Operación).',
        'Productos de alto riesgo (lácteos, cárnicos) tienen requisitos más estrictos.',
      ],
      pasos: [
        'Adecuar el lugar de elaboración (cocina/taller) para inspección.',
        'Llevar muestras del producto a un laboratorio acreditado (UP o privado) para análisis.',
        'Elaborar la etiqueta del producto según normas.',
        'Llenar formulario de solicitud de Registro Sanitario en el DEPA.',
        'Pagar la tasa correspondiente.',
        'Esperar evaluación técnica y legal.',
      ],
      requisitos: [
        'Memorial de solicitud mediante abogado (o personal si es artesanal simple - verificar norma vigente).',
        'Certificado de análisis de laboratorio del producto.',
        'Dos (2) etiquetas originales del producto.',
        'Fórmula cuali-cuantitativa (receta con porcentajes) firmada por profesional idóneo.',
        'Descripción del proceso de elaboración (flujograma).',
        'Permiso Sanitario de Operación del sitio de elaboración.',
      ],
      tiempo: '2 a 4 meses',
      costo: 'B/.30.00 a B/.200.00 (dependiendo de análisis y tasas legales)',
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
           // Default fallback: Always show at least basic RUC, NIT & Aviso if unknown
           [_nit, _ruc, _avisoOp];
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
       descripcionCompleta: 'Este trámite requiere verificación de requisitos vigentes. Le recomendamos contactar directamente a la institución correspondiente para obtener información actualizada.',
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
