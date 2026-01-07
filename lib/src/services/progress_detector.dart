import 'package:shared_preferences/shared_preferences.dart';
import '../models/checklist_model.dart';
import '../services/business_service.dart';
import '../services/worker_service.dart';

/// Detecta automáticamente el progreso del usuario basándose en datos existentes.
/// Se usa al iniciar la app para marcar items retroactivamente.
class ProgressDetector {
  /// Detecta todos los logros basados en datos guardados del usuario.
  /// Retorna un mapa de autoRuleKey -> bool indicando qué debería estar completado.
  static Future<Map<String, bool>> detectAll() async {
    final detected = <String, bool>{};

    try {
      final prefs = await SharedPreferences.getInstance();

      // ========================================================================
      // ÁREA START (Comienza Aquí)
      // ========================================================================

      // hasRubro: ¿Usuario seleccionó un rubro?
      final selectedRubro = prefs.getString('selected_niche');
      detected['hasRubro'] = selectedRubro != null && selectedRubro.isNotEmpty;

      // hasBusinessProfile: ¿Usuario tiene perfil de negocio guardado?
      final businessProfile = await BusinessService().getProfile();
      detected['hasBusinessProfile'] = businessProfile != null &&
          businessProfile.nombre.isNotEmpty &&
          businessProfile.ruc.isNotEmpty;

      // hasBusinessLocation: ¿Usuario definió ubicación?
      detected['hasBusinessLocation'] = businessProfile != null &&
          businessProfile.municipio.isNotEmpty;

      // employeesCountGt0: ¿Usuario tiene al menos 1 empleado?
      final employees = await WorkerService().getWorkers();
      detected['employeesCountGt0'] = employees.isNotEmpty;

      // hasPayrollCalc: ¿Usuario generó al menos 1 comprobante? (detectar por historial)
      // Por ahora lo dejamos en false, se marcará cuando genere el primero
      detected['hasPayrollCalc'] = false;

      // rubroChecklistProgressGt0: ¿Usuario avanzó en checklist de rubro?
      // Esto depende de la implementación de checklist por rubro
      detected['rubroChecklistProgressGt0'] = false;

      // viewedRequirements: ¿Usuario vio los requisitos?
      detected['viewedRequirements'] = prefs.getBool('viewed_requirements') ?? false;

      // rubroRequirementsDoneGte3: ¿Usuario completó 3+ requisitos?
      detected['rubroRequirementsDoneGte3'] = false; // Se detectará desde el sistema de requisitos

      // ========================================================================
      // ÁREA PAYROLL (Planilla)
      // ========================================================================

      // employeeHasRequiredFields: ¿Empleado tiene datos completos?
      final hasCompleteEmployee = employees.any((emp) =>
          emp.position.isNotEmpty && (emp.basePayment > 0 || (emp.hourlyRate ?? 0) > 0));
      detected['employeeHasRequiredFields'] = hasCompleteEmployee;

      // obligationsConfigured: ¿Usuario configuró obligaciones?
      detected['obligationsConfigured'] = prefs.getBool('obligations_configured') ?? false;

      // obligationsCountGte2ThisMonth: ¿Usuario tiene 2+ obligaciones este mes?
      detected['obligationsCountGte2ThisMonth'] = false; // Se detectará desde HR Compliance

      // obligationsDoneGte1ThisMonth: ¿Usuario completó 1+ obligación?
      detected['obligationsDoneGte1ThisMonth'] = false;

      // hasObligationEvidence: ¿Usuario adjuntó evidencia?
      detected['hasObligationEvidence'] = false;

      // generatedHRDoc: ¿Usuario generó documento HR (carta/contrato)?
      detected['generatedHRDoc'] = false;

      // ========================================================================
      // ÁREA ACCOUNTING (Contabilidad)
      // ========================================================================

      // hasBudget: ¿Usuario creó presupuesto?
      detected['hasBudget'] = prefs.getBool('has_budget') ?? false;

      // hasIncomeTx: ¿Usuario registró ingreso?
      detected['hasIncomeTx'] = prefs.getBool('has_income_tx') ?? false;

      // hasExpenseTx: ¿Usuario registró gasto?
      detected['hasExpenseTx'] = prefs.getBool('has_expense_tx') ?? false;

      // expenseCategoriesGte3: ¿Usuario tiene 3+ categorías?
      detected['expenseCategoriesGte3'] = false;

      // openedCashflow: ¿Usuario abrió flujo de caja?
      detected['openedCashflow'] = prefs.getBool('opened_cashflow') ?? false;

      // ========================================================================
      // ÁREA MARKETING (Marketing)
      // ========================================================================

      // hasPersona: ¿Usuario definió cliente ideal?
      detected['hasPersona'] = prefs.getBool('has_persona') ?? false;

      // hasOffer: ¿Usuario definió oferta principal?
      detected['hasOffer'] = prefs.getBool('has_offer') ?? false;

      // openedFunnel: ¿Usuario abrió embudo?
      detected['openedFunnel'] = prefs.getBool('opened_funnel') ?? false;

      // hasCampaign: ¿Usuario registró campaña?
      detected['hasCampaign'] = prefs.getBool('has_campaign') ?? false;

      print('🔍 ProgressDetector: Detected ${detected.values.where((v) => v).length} completed items');
      
      return detected;
    } catch (e) {
      print('❌ Error in ProgressDetector: $e');
      return detected;
    }
  }

  /// Detecta un autoRuleKey específico.
  static Future<bool> detect(String autoRuleKey) async {
    final all = await detectAll();
    return all[autoRuleKey] ?? false;
  }
}
