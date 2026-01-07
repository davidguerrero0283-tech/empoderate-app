import 'package:proyecto_empoderate/src/navigation/app_routes.dart';
import 'checklist_model.dart';

class ChecklistData {
  static final List<ChecklistItem> defaultItems = [
    // --- LEGAL ---
    ChecklistItem(
      id: 'aviso_operacion',
      title: 'Aviso de Operación',
      description: 'Documento fundamental para operar legalmente en Panamá (PanamaEmprende).',
      category: ChecklistCategory.legal,
      frequency: 'Único',
    ),
    ChecklistItem(
      id: 'pacto_social',
      title: 'Pacto Social (Sociedades)',
      description: 'Solo para Personas Jurídicas. Escritura de constitución inscrita en Registro Público.',
      category: ChecklistCategory.legal,
      frequency: 'Único',
    ),
    
    // --- FISCAL (DGI) ---
    ChecklistItem(
      id: 'inscripcion_dgi',
      title: 'Inscripción en la DGI (RUC/NIT)',
      description: 'Registro Único de Contribuyente y Número de Identificación Tributaria.',
      category: ChecklistCategory.fiscal,
      frequency: 'Único',
    ),
    ChecklistItem(
      id: 'facturacion_electronica',
      title: 'Facturación Electrónica / Fiscal',
      description: 'Adopción de sistema de facturación electrónica o equipo fiscal autorizado.',
      category: ChecklistCategory.fiscal,
      frequency: 'Único',
    ),
    ChecklistItem(
      id: 'declaracion_renta',
      title: 'Declaración Jurada de Renta',
      description: 'Presentación anual de ingresos y gastos (Formulario 1 DGI).',
      category: ChecklistCategory.fiscal,
      frequency: 'Anual (Marzo)',
      toolRoute: AppRoutes.taxEstimator,
    ),
    ChecklistItem(
      id: 'itbms',
      title: 'Declaración de ITBMS (7%)',
      description: 'Pago mensual o trimestral del impuesto de transferencia (si aplica).',
      category: ChecklistCategory.fiscal,
      frequency: 'Mensual',
      toolRoute: AppRoutes.taxEstimator,
    ),

    // --- MUNICIPAL ---
    ChecklistItem(
      id: 'inscripcion_municipio',
      title: 'Inscripción Municipal',
      description: 'Registro en el municipio del distrito donde opera el negocio.',
      category: ChecklistCategory.municipal,
      frequency: 'Único',
    ),
    ChecklistItem(
      id: 'pago_impuesto_municipal',
      title: 'Pago de Impuestos Municipales',
      description: 'Cuota mensual establecida por el municipio (rótulos, actividad, etc).',
      category: ChecklistCategory.municipal,
      frequency: 'Mensual',
    ),
    ChecklistItem(
      id: 'inspeccion_bomberos',
      title: 'Permiso de Bomberos',
      description: 'Certificación de seguridad del local comercial (DOB).',
      category: ChecklistCategory.municipal,
      frequency: 'Anual',
    ),

    // --- LABORAL / RRHH ---
    ChecklistItem(
      id: 'inscripcion_css',
      title: 'Inscripción Patronal CSS',
      description: 'Registro del negocio como empleador ante la Caja de Seguro Social.',
      category: ChecklistCategory.laboral,
      frequency: 'Único',
    ),
    ChecklistItem(
      id: 'contratos_trabajo',
      title: 'Registro de Contratos (Mitradel)',
      description: 'Los contratos deben sellarse digital o físicamente en Min. Trabajo.',
      category: ChecklistCategory.laboral,
      frequency: 'Por Empleado',
    ),
    ChecklistItem(
      id: 'sipe_planilla',
      title: 'Planilla Mensual (SIPE)',
      description: 'Presentación y pago de cuotas empleado-empleador CSS.',
      category: ChecklistCategory.laboral,
      frequency: 'Mensual',
      toolRoute: AppRoutes.salarioNeto,
    ),
    
    // --- OPERATIVO ---
    ChecklistItem(
      id: 'cuenta_bancaria',
      title: 'Cuenta Bancaria Comercial',
      description: 'Separar finanzas personales de las del negocio.',
      category: ChecklistCategory.operativo,
      frequency: 'Único',
      toolRoute: AppRoutes.cashFlow,
    ),
    ChecklistItem(
      id: 'registro_marca',
      title: 'Registro de Marca (DIGERP)',
      description: 'Protección legal del nombre y logo de tu negocio (Opcional pero recomendado).',
      category: ChecklistCategory.operativo,
      frequency: 'Único',
    ),
  ];

  static final List<ChecklistItem> rubroItems = [
    // --- RESTAURANTE ---
    ChecklistItem(
      id: 'carnet_salud_blanco',
      title: 'Carnet de Salud (Blanco)',
      description: 'Certificado de buena salud. Obligatorio para todo el personal.',
      category: ChecklistCategory.laboral,
      frequency: 'Anual',
      rubroId: 'restaurante',
    ),
    ChecklistItem(
      id: 'carnet_salud_verde',
      title: 'Carnet de Manipulación (Verde)',
      description: 'Curso de manipulación de alimentos. Obligatorio para cocineros y saloneros.',
      category: ChecklistCategory.laboral,
      frequency: 'Quinquenal (5 años)',
      rubroId: 'restaurante',
    ),
    ChecklistItem(
      id: 'fumigacion',
      title: 'Certificado de Fumigación',
      description: 'Control de plagas obligatorio por el MINSA.',
      category: ChecklistCategory.operativo,
      frequency: 'Trimestral / Mensual',
      rubroId: 'restaurante',
    ),
    ChecklistItem(
      id: 'trampa_grasa',
      title: 'Mantenimiento Trampa de Grasa',
      description: 'Limpieza y registro para evitar multas ambientales.',
      category: ChecklistCategory.operativo,
      frequency: 'Mensual / Semanal',
      rubroId: 'restaurante',
    ),

    // --- RETAIL (TIENDA) ---
    ChecklistItem(
      id: 'letrero_publicidad',
      title: 'Permiso de Publicidad Exterior',
      description: 'Pago de impuesto municipal por letreros visibles.',
      category: ChecklistCategory.municipal,
      frequency: 'Anual',
      rubroId: 'retail',
    ),
    ChecklistItem(
      id: 'libro_quejas',
      title: 'Libro de Quejas (ACODECO)',
      description: 'Debe estar visible y disponible para clientes.',
      category: ChecklistCategory.legal,
      frequency: 'Permanente',
      rubroId: 'retail',
    ),
    ChecklistItem(
      id: 'politica_garantia',
      title: 'Política de Garantía Visible',
      description: 'Letrero con condiciones de cambio y devolución (Ley 45).',
      category: ChecklistCategory.legal,
      frequency: 'Permanente',
      rubroId: 'retail',
    ),

    // --- SERVICIOS PRO ---
    ChecklistItem(
      id: 'idoneidad',
      title: 'Idoneidad Profesional',
      description: 'Registro ante la Junta Técnica correspondiente (Abogados, CPA, Ing).',
      category: ChecklistCategory.legal,
      frequency: 'Único',
      rubroId: 'servicios',
    ),
    ChecklistItem(
      id: 'contrato_servicios',
      title: 'Contrato de Servicios Estándar',
      description: 'Modelo de contrato para clientes para proteger tu trabajo.',
      category: ChecklistCategory.legal,
      frequency: 'Único',
      rubroId: 'servicios',
    ),
  ];
}
