
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/checklist_model.dart';

/// Evaluates auto-completion rules for checklist items based on app state.
class ChecklistAutoRules {
  final SharedPreferences prefs;

  ChecklistAutoRules(this.prefs);

  Future<bool> evaluate(String? ruleKey) async {
    if (ruleKey == null) return false;

    switch (ruleKey) {
      // --- START (INICIO) ---
      case 'hasRubro':
        return (prefs.getString('mi_negocio.selected_rubro_id')?.isNotEmpty ?? false);
      
      case 'rubroChecklistProgressGt0':
         final count = prefs.getInt('start.checklist.done_count') ?? 0;
         return count > 0;
      
      case 'hasBusinessProfile':
         return prefs.containsKey('business_profile.name');
         
      case 'hasBusinessLocation':
         return prefs.containsKey('business_profile.province') || prefs.containsKey('business_profile.city');

      case 'viewedRequirements': 
         return (prefs.getInt('start.checklist.done_count') ?? 0) > 0; // Fallback: if they did checks, they viewed it.

      case 'rubroRequirementsDoneGte3':
         return (prefs.getInt('start.checklist.done_count') ?? 0) >= 3;

      case 'startedOnboarding':
         return prefs.getBool('onboarding.completed') ?? false; 

      case 'hasVaultDoc':
         // Any file saved?
         return false; // Not tracking files yet, leave manual.

      case 'openedBusinessChecklistScreen':
         return true; // If they see this, they opened it. (Or check a specific flag)

      case 'businessStatusInProgress':
         return true; // Logic default if in this app.

      // --- PAYROLL (PLANILLA) ---
      case 'employeesCountGt0':
         final list = prefs.getStringList('hr.employees_list');
         return (list != null && list.isNotEmpty);

      case 'employeeHasRequiredFields':
          // Heuristic: checks if we have salary data
          return true; // Simplified for now

      case 'hasPayrollCalc':
         return prefs.containsKey('calculator.salary.last_result');

      case 'obligationsConfigured':
         return prefs.containsKey('hr.last_compliance_generated');

      case 'obligationsCountGte2ThisMonth':
         // Difficult to count without repo. Assume true if configured.
         return prefs.containsKey('hr.last_compliance_generated');

      case 'obligationsDoneGte1ThisMonth':
         return false; // Leave manual for verification

      case 'hasObligationEvidence':
         return false; // Manual

      case 'generatedHRDoc':
         return false; // Manual

      case 'openedCompliance':
         return prefs.containsKey('hr.last_compliance_generated'); // If generated, they opened it.
         
      case 'payrollTrackingActive':
         return true; // Default

      // --- ACCOUNTING (CONTABILIDAD) ---
      case 'hasBudget':
         return prefs.containsKey('accounting.budget.data');
      
      case 'expenseCategoriesGte3':
         return false; // Difficult to parse JSON here easily.

      case 'hasIncomeTx':
          return prefs.containsKey('accounting.cashflow.transactions'); // Simplified

      case 'hasExpenseTx':
          return prefs.containsKey('accounting.cashflow.transactions');

      case 'openedCashflow':
          return prefs.containsKey('accounting.cashflow.transactions'); 

      case 'hasBreakEven':
          return prefs.containsKey('calculator_data.punto_equilibrio'); // Or similar

      case 'openedMonthlySummary':
          return false; 

      case 'hasAccountingNote':
          return false;

      case 'monthClosedAccounting':
          return false;
          
      case 'accountingInProgress':
          return true;

      // --- MARKETING ---
      case 'hasPersona':
         return prefs.getBool('marketing.avatar_defined') ?? false;

      case 'hasOffer':
         return false; // Manual

      case 'openedFunnel':
         return prefs.getBool('marketing.funnel_configured') ?? false;

      case 'hasCampaign':
         final count = prefs.getInt('marketing.campaign_count') ?? 0;
         return count > 0;

      case 'hasMetrics':
         return false; 

      case 'openedConversion':
         return false;

      case 'hasMainChannel':
         return false;

      case 'hasWeeklyMarketingChecklist':
         return false;

      case 'marketingActionsDoneGte1':
         return false;

      case 'marketingTrackingActive':
         return true;

      default:
        return false;
    }
  }
}
