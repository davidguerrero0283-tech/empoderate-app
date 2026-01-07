import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/checklist_model.dart';
import '../../navigation/app_routes.dart';
import 'checklist_auto_rules.dart';

class BusinessSignalsLoader {
  final SharedPreferences prefs;
  late ChecklistAutoRules _rules;

  BusinessSignalsLoader(this.prefs) {
    _rules = ChecklistAutoRules(prefs);
  }

  Future<List<ChecklistItem>> loadAllSignals() async {
    final allItems = <ChecklistItem>[];

    // 1. INICIO (START) - 10 ITEMS
    allItems.addAll([
       _item('start_1_rubro', ProgressArea.start, 'Elegir rubro de negocio', 'Define en qué industria operas.', 1, AppRoutes.miNegocioRubro, autoKey: 'hasRubro', priority: 5),
       _item('start_2_checklist', ProgressArea.start, 'Completar checklist por rubro', 'Avanza en requisitos de tu industria.', 2, AppRoutes.miNegocioRubro, autoKey: 'rubroChecklistProgressGt0', priority: 5),
       _item('start_3_profile', ProgressArea.start, 'Guardar datos básicos', 'Define nombre y ubicación del negocio.', 3, AppRoutes.businessProfile, autoKey: 'hasBusinessProfile', priority: 4),
       _item('start_4_location', ProgressArea.start, 'Definir ubicación/operación', 'Provincia, ciudad y área.', 4, AppRoutes.businessProfile, autoKey: 'hasBusinessLocation', priority: 3),
       _item('start_5_reqs', ProgressArea.start, 'Revisar requisitos iniciales', 'Conoce lo que necesitas.', 5, AppRoutes.miNegocioRubro, autoKey: 'viewedRequirements', priority: 3),
       _item('start_6_reqs_done', ProgressArea.start, 'Marcar 3 requisitos listos', 'Avanza en tu cumplimiento.', 6, AppRoutes.miNegocioRubro, autoKey: 'rubroRequirementsDoneGte3', priority: 4),
       _item('start_7_route', ProgressArea.start, 'Activar Ruta al Éxito', 'Inicia tu camino de crecimiento.', 7, AppRoutes.laRutaAlExito, autoKey: 'startedOnboarding', priority: 4),
       _item('start_8_vault', ProgressArea.start, 'Guardar 1 documento en Bóveda', 'Organiza tus papeles clave.', 8, AppRoutes.bovedaDigital, autoKey: 'hasVaultDoc', priority: 2),
       _item('start_9_hub', ProgressArea.start, 'Ver Estado de tu negocio', 'Revisa tu checklist completo.', 9, AppRoutes.checklist, autoKey: 'openedBusinessChecklistScreen', priority: 2),
       _item('start_10_status', ProgressArea.start, 'Negocio "En curso"', 'Confirma que estás operando.', 10, AppRoutes.checklist, autoKey: 'businessStatusInProgress', priority: 1),
    ]);

    // 2. PLANILLA (PAYROLL) - 10 ITEMS
    allItems.addAll([
       _item('pay_1_reg_emp', ProgressArea.payroll, 'Registrar primer colaborador', 'Agrega a tu equipo.', 1, AppRoutes.humanResources, autoKey: 'employeesCountGt0', priority: 5),
       _item('pay_2_emp_data', ProgressArea.payroll, 'Datos del colaborador', 'Completa cargo y salario.', 2, AppRoutes.humanResources, autoKey: 'employeeHasRequiredFields', priority: 4),
       _item('pay_3_calc', ProgressArea.payroll, 'Hacer cálculo de salario', 'Estima deducciones y neto.', 3, AppRoutes.salarioNeto, autoKey: 'hasPayrollCalc', priority: 4),
       _item('pay_4_config_obs', ProgressArea.payroll, 'Configurar Obligaciones', 'Define mes de inicio laboral.', 4, '/rrhh/cumplimiento', autoKey: 'obligationsConfigured', priority: 5),
       _item('pay_5_create_obs', ProgressArea.payroll, 'Crear 2 obligaciones', 'Prepara tu mes laboral.', 5, '/rrhh/cumplimiento', autoKey: 'obligationsCountGte2ThisMonth', priority: 4),
       _item('pay_6_mark_done', ProgressArea.payroll, 'Marcar 1 obligación lista', 'Registra cumplimiento.', 6, '/rrhh/cumplimiento', autoKey: 'obligationsDoneGte1ThisMonth', priority: 3),
       _item('pay_7_evidence', ProgressArea.payroll, 'Adjuntar evidencia', 'Sube comprobante a una tarea.', 7, '/rrhh/cumplimiento', autoKey: 'hasObligationEvidence', priority: 3),
       _item('pay_8_doc', ProgressArea.payroll, 'Generar documento', 'Contrato o carta (si aplica).', 8, AppRoutes.humanResources, autoKey: 'generatedHRDoc', priority: 2),
       _item('pay_9_progress', ProgressArea.payroll, 'Revisar progreso mensual', 'Verifica tu dashboard HR.', 9, '/rrhh/cumplimiento', autoKey: 'openedCompliance', priority: 2),
       _item('pay_10_track', ProgressArea.payroll, 'Seguimiento activo', 'Mantén tu planilla al día.', 10, AppRoutes.humanResources, autoKey: 'payrollTrackingActive', priority: 1),
    ]);

    // 3. CONTABILIDAD (ACCOUNTING) - 10 ITEMS
    allItems.addAll([
       _item('acc_1_budget', ProgressArea.accounting, 'Crear Presupuesto Base', 'Define ingresos y gastos meta.', 1, AppRoutes.budget, autoKey: 'hasBudget', priority: 5),
       _item('acc_2_cats', ProgressArea.accounting, 'Definir 3 categorías', 'Organiza tus cuentas.', 2, AppRoutes.budget, autoKey: 'expenseCategoriesGte3', priority: 4),
       _item('acc_3_income', ProgressArea.accounting, 'Registrar 1 ingreso', 'Documenta tus ventas.', 3, AppRoutes.cashFlow, autoKey: 'hasIncomeTx', priority: 4),
       _item('acc_4_expense', ProgressArea.accounting, 'Registrar 1 gasto', 'Controla tus salidas.', 4, AppRoutes.cashFlow, autoKey: 'hasExpenseTx', priority: 4),
       _item('acc_5_cashflow', ProgressArea.accounting, 'Ver Flujo de Caja', 'Analiza tu liquidez.', 5, AppRoutes.cashFlow, autoKey: 'openedCashflow', priority: 3),
       _item('acc_6_breakeven', ProgressArea.accounting, 'Definir Punto de Equilibrio', '¿Cuánto debes vender?', 6, AppRoutes.puntoEquilibrio, autoKey: 'hasBreakEven', priority: 3),
       _item('acc_7_summary', ProgressArea.accounting, 'Ver resumen mensual', 'Consulta tus números.', 7, AppRoutes.accountingToolsMenu, autoKey: 'openedMonthlySummary', priority: 2),
       _item('acc_8_note', ProgressArea.accounting, 'Guardar 1 nota contable', 'Bitácora de movimientos.', 8, AppRoutes.accountingToolsMenu, autoKey: 'hasAccountingNote', priority: 2),
       _item('acc_9_close', ProgressArea.accounting, 'Cerrar mes (simulado)', 'Confirma tus cifras.', 9, AppRoutes.accountingToolsMenu, autoKey: 'monthClosedAccounting', priority: 1),
       _item('acc_10_status', ProgressArea.accounting, 'Contabilidad "En curso"', 'Mantén el control.', 10, AppRoutes.accountingToolsMenu, autoKey: 'accountingInProgress', priority: 1),
    ]);

    // 4. MARKETING - 10 ITEMS
    allItems.addAll([
       _item('mkt_1_avatar', ProgressArea.marketing, 'Definir Cliente Ideal', '¿Quién es tu buyer persona?', 1, AppRoutes.marketingAvatar, autoKey: 'hasPersona', priority: 5),
       _item('mkt_2_offer', ProgressArea.marketing, 'Definir oferta principal', 'Describe tu producto estrella.', 2, AppRoutes.marketingContent, autoKey: 'hasOffer', priority: 4),
       _item('mkt_3_funnel', ProgressArea.marketing, 'Abrir Embudo de Ventas', 'Visualiza tus etapas.', 3, AppRoutes.marketingFunnel, autoKey: 'openedFunnel', priority: 4),
       _item('mkt_4_campaign', ProgressArea.marketing, 'Registrar 1 campaña', 'Promociona tu negocio.', 4, AppRoutes.marketingCampaigns, autoKey: 'hasCampaign', priority: 4),
       _item('mkt_5_metrics', ProgressArea.marketing, 'Registrar 1 métrica', 'Mide resultados.', 5, AppRoutes.marketingFunnel, autoKey: 'hasMetrics', priority: 3),
       _item('mkt_6_conversion', ProgressArea.marketing, 'Revisar conversión', 'Analiza desempeño.', 6, AppRoutes.marketingFunnel, autoKey: 'openedConversion', priority: 3),
       _item('mkt_7_channel', ProgressArea.marketing, 'Definir canal principal', 'IG, FB, Web, etc.', 7, AppRoutes.marketing, autoKey: 'hasMainChannel', priority: 2),
       _item('mkt_8_checklist', ProgressArea.marketing, 'Checklist semanal', 'Rutina de marketing.', 8, AppRoutes.marketing, autoKey: 'hasWeeklyMarketingChecklist', priority: 2),
       _item('mkt_9_action', ProgressArea.marketing, 'Completar 1 acción', 'Ejecuta tu plan.', 9, AppRoutes.marketing, autoKey: 'marketingActionsDoneGte1', priority: 2),
       _item('mkt_10_track', ProgressArea.marketing, 'Seguimiento activo', 'No pares de vender.', 10, AppRoutes.marketing, autoKey: 'marketingTrackingActive', priority: 1),
    ]);

    // EVALUACIÓN (Async)
    final processedItems = <ChecklistItem>[];
    for (var item in allItems) {
      bool isDone = false;
      if (item.autoRuleKey != null) {
         isDone = await _rules.evaluate(item.autoRuleKey!);
      }
      processedItems.add(item.copyWith(done: isDone));
    }

    return processedItems;
  }

  ChecklistItem _item(String id, ProgressArea area, String title, String desc, int order, String route, {String? autoKey, bool isOptional=false, int priority = 3}) {
    return ChecklistItem(
      id: id,
      area: area,
      title: title,
      description: desc,
      order: order,
      route: route,
      autoRuleKey: autoKey,
      isOptional: isOptional,
      priority: priority,
      done: false, // Evaluated later
      updatedAt: DateTime.now(),
    );
  }
}
