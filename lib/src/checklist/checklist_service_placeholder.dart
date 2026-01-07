import 'checklist_models.dart';

class ChecklistServicePlaceholder {
  List<ChecklistCategory> getCategoriesForRubro(String rubroId) {
    return [
      ChecklistCategory(
        id: '1',
        title: 'Formalización legal',
        description: 'Pasos para registrar tu empresa',
        tasks: [
          ChecklistTask(id: '1a', title: 'Registro Público', description: 'Inscribir sociedad', isMandatory: true),
          ChecklistTask(id: '1b', title: 'Aviso de Operación', description: 'Obtener aviso en Panamá Emprende', isMandatory: true),
        ],
      ),
      ChecklistCategory(
        id: '2',
        title: 'Obligaciones laborales',
        description: 'Contratos y CSS',
        tasks: [
          ChecklistTask(id: '2a', title: 'Inscripción CSS', description: 'Registrar empresa en CSS', isMandatory: true),
          ChecklistTask(id: '2b', title: 'Contratos de trabajo', description: 'Redactar y firmar contratos'),
        ],
      ),
      ChecklistCategory(
        id: '3',
        title: 'Operación diaria',
        description: 'Procesos clave',
        tasks: [
          ChecklistTask(id: '3a', title: 'Apertura de cuenta bancaria', description: 'Cuenta corporativa'),
          ChecklistTask(id: '3b', title: 'Sistema de facturación', description: 'Elegir software o imprenta'),
        ],
      ),
    ];
  }

  List<PlanAccionItem> getPlanAccionBase(String rubroId) {
    return [
      PlanAccionItem(id: 'p1', title: 'Definir modelo de negocio', description: 'Clarificar propuesta de valor', categoryId: 'plan', priority: 1),
      PlanAccionItem(id: 'p2', title: 'Presupuesto inicial', description: 'Calcular costos de arranque', categoryId: 'finanzas', priority: 1),
      PlanAccionItem(id: 'p3', title: 'Estrategia de marketing', description: 'Planear lanzamiento', categoryId: 'marketing', priority: 2),
      PlanAccionItem(id: 'p4', title: 'Contratar personal', description: 'Buscar primeros empleados', categoryId: 'rrhh', priority: 3),
    ];
  }
}
