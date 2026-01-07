import 'package:flutter/material.dart';
import '../features/accounting/classroom/accounting_classroom_screen.dart';

import '../screens/auditoria_negocio_screen.dart';
import '../screens/home_screen.dart';
import '../screens/tools_screen.dart';
import '../screens/library_screen.dart';
import '../screens/human_resources_screen.dart';
import '../screens/marketing_screen.dart';
import '../screens/ai_hub_screen.dart';
import '../screens/tramites_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/inicio_negocio_screen.dart';
import '../screens/sbot_screen.dart';
import '../screens/mi_negocio_rubro_screen.dart';
import '../screens/calculadoras_screen.dart';
import '../screens/calculators/liquidacion_screen.dart';
import '../screens/calculators/payroll_history_screen.dart';
import '../screens/calculators/itbms_screen.dart';
import '../screens/calculators/prestamo_screen.dart';
import '../screens/calculators/margen_ganancia_screen.dart';

import '../screens/recordatorios_screen.dart';
import '../screens/progreso_metas_screen.dart';
import '../screens/blog_main_screen.dart';
import '../screens/blog_article_screen.dart';
import '../screens/legal_screen.dart';
import '../sbot/sbot_home_screen.dart';
import '../sbot/sbot_question_screen.dart';
import '../sbot/sbot_result_screen.dart';
import '../sbot/sbot_history_screen.dart';
import '../screens/checklist/checklist_hub_screen.dart';
import '../features/checklist/screens/checklist_rubro_selection_screen.dart';
import '../features/checklist/screens/checklist_rubro_detail_screen.dart';
import '../checklist/checklist_plan_accion_screen.dart';
import '../business_profile/business_profile_home_screen.dart';
import '../business_profile/business_profile_form_screen.dart';
import '../business_profile/business_profile_review_screen.dart';
import '../business_profile/reminder_list_screen.dart';
import '../business_profile/reminder_detail_screen.dart';
import '../screens/learning/learning_center_screen.dart';
import '../screens/calculators/salario_screen.dart';
import '../screens/calculators/fixed_costs_screen.dart';
import '../screens/calculators/accounting/cash_flow_screen.dart';
import '../screens/calculators/accounting/tax_estimator_screen.dart';
import '../screens/calculators/accounting/budget_screen.dart';
import '../screens/calculators/accounting/accounting_tools_menu_screen.dart';
import '../screens/calculators/accounting/accounting_screen.dart';
import '../features/boveda/screens/boveda_screen.dart';

import '../screens/calculators/accounting/accounting_v2_screen.dart';
import '../screens/calculators/accounting/accounting_managerial_screen.dart';
import '../screens/decimo_tercer_mes_screen.dart';
import '../screens/punto_equilibrio_screen.dart';
import '../screens/checklist_tramites_screen.dart';
import '../features/ruta_exito/ruta_exito_screen.dart'; // NEW - Simplified version
import '../screens/ia_contable_screen.dart';
import '../screens/ia_legal_screen.dart';
import '../screens/ia_marketing_screen.dart';
import '../screens/ia_ventas_screen.dart';
import '../screens/ia_productividad_screen.dart';
import '../screens/ia_docente_screen.dart';
import '../screens/planificador_semanal_screen.dart';
import '../screens/dashboard_negocio_screen.dart';
import '../screens/directorio_screen.dart';
import '../screens/employees_grid_screen.dart';

import '../screens/tienda_premium_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/quick_access_screen.dart';
import 'main_shell.dart';
import '../screens/chatbot_screen.dart';
import '../screens/calculator_placeholder_screen.dart';
import '../screens/register_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/blog/admin_blog_screen.dart';
import '../screens/admin/blog/admin_blog_form_screen.dart';
import '../screens/premium_plans_screen.dart';
import '../screens/auth_screen.dart';
import '../features/hr/compliance/labor_compliance_screen.dart';
import '../features/admin/visibility/app_sections_registry.dart'; // Registry
import '../features/admin/visibility/visibility_service.dart'; // Service
import '../screens/not_found_screen.dart'; // 404
import '../features/admin/layout/admin_layout.dart';
import '../screens/admin/visibility/section_visibility_screen.dart';
import '../screens/admin/admin_analytics_screen.dart';
import '../screens/admin/admin_users_screen.dart';
import '../screens/admin/admin_content_screen.dart';
import '../screens/admin/admin_audit_screen.dart';
import '../screens/admin/admin_system_screen.dart';
import '../screens/admin/admin_ai_screen.dart';

// New Marketing Screens
import '../screens/marketing/marketing_content_screen.dart';
import '../screens/marketing/marketing_funnel_screen.dart';
import '../screens/marketing/marketing_campaign_screen.dart';
import '../screens/marketing/marketing_avatar_screen.dart';
import '../screens/marketing/social_media_automation_screen.dart';
import '../../features/agenda_tramites/ui/agenda_tramites_screen.dart';
import '../features/pendientes/screens/pendientes_screen.dart';
import '../screens/learning/module_guide_screen.dart';
import 'package:proyecto_empoderate/features/ai_texts/ui/ai_texts_screen.dart';
import 'package:proyecto_empoderate/features/ai_customers/ui/ai_customers_screen.dart';
import 'package:proyecto_empoderate/features/ai_shared/ui/ai_generic_screen.dart';
import 'package:proyecto_empoderate/features/ai_shared/domain/ai_shared_types.dart';

import '../screens/hr_templates_screen.dart';
import '../screens/human_resources/employee_history_screen.dart';
import '../screens/human_resources/hr_archive_screen.dart';
import '../screens/calculators/vacation_calculator_screen.dart';
import '../screens/calculators/decimo_calculator_screen.dart';
import '../screens/calculators/shift_logger_screen.dart';
import '../features/schedule_management/presentation/schedule_screen.dart';
import '../screens/market_study_screen.dart';
import '../screens/calculators/period_comparison_screen.dart';
import '../screens/tools/import_shifts_screen.dart';
import '../calculators/salario_models.dart'; // Needed for WorkerProfile argument

class AppRoutes {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  static const String root = '/';
  
  static const String register = '/register';
  static const String login = '/login'; 
  static const String home = '/'; 
  static const String admin = '/admin'; // V2 Entry Point
  static const String home_screen_widget = '/home_only'; 
  static const String adminDashboard = '/admin_dashboard';
  static const String adminBlog = '/admin_blog';
  static const String adminBlogForm = '/admin_blog_form';
  static const String adminVisibility = '/admin_visibility';

  static const String adminAnalytics = '/admin/analytics';
  static const String adminUsers = '/admin/users';
  static const String adminContent = '/admin/content';
  static const String adminAudit = '/admin/audit';
  static const String adminSystem = '/admin/system';
  static const String adminAi = '/admin/ai';
  static const String aiChat = '/ia/chat';
  static const String tools = '/tools';
  static const String library = '/library';
  static const String profile = '/perfil';
  static const String accounting = '/accounting';
  static const String humanResources = '/human_resources';
  static const String marketing = '/marketing';
  static const String aiHub = '/ai_hub';
  static const String tramites = '/tramites';
  static const String settings = '/settings';
  static const String settingsLegal = '/ajustes_legales';
  static const String aiTexts = '/ai/texts';
  static const String aiCustomers = '/ai/customers';
  static const String aiProducts = '/ai/products';
  static const String aiContracts = '/ai/contracts';
  static const String aiProcesses = '/ai/processes';
  static const String aiStrategies = '/ai/strategies';
  
  // Feature Routes
  static const String salarioNeto = '/salario_neto';
  static const String decimoTercerMes = '/decimo_tercer_mes';
  static const String puntoEquilibrio = '/punto_equilibrio';
  static const String checklistTramites = '/checklist_tramites';
  static const String rutaEmprendedor = '/ruta_emprendedor';
  
  // Marketing Tools
  static const String marketingContent = '/marketing/content';
  static const String marketingFunnel = '/marketing/funnel';
  static const String marketingCampaigns = '/marketing/campaigns';
  static const String marketingAvatar = '/marketing/avatar';
  static const String marketingAutomation = '/marketing/automation';
  
  // IA & Placeholders
  static const String iaContable = '/ia_contable';
  static const String iaLegal = '/ia_legal';
  static const String iaMarketing = '/ia_marketing';
  static const String iaVentas = '/ia_ventas';
  static const String iaProductividad = '/ia_productividad';
  static const String iaDocente = '/ia_docente';
  static const String planificadorSemanal = '/planificador_semanal';
  static const String misionesDiarias = '/module_guide'; // Redirect zombie to guide
  static const String directorio = '/directorio';
  static const String employees = '/employees';
  static const String dashboardNegocio = '/dashboard_negocio';

  static const String tiendaPremium = '/tienda_premium';
  static const String premiumPlans = '/premium_plans';
  static const String checkoutEmprendedor = '/checkout/emprendedor';
  static const String checkoutPro = '/checkout/pro';
  static const String notifications = '/notifications';
  
  static const String quickAccess = '/quick_access';
  static const String inicioNegocio = '/inicio_negocio';
  static const String sbot = '/sbot';
  static const String sbotQuestion = '/sbot_question';
  static const String sbotResult = '/sbot_result';
  static const String sbotHistory = '/sbot_history';
  static const String miNegocioRubro = '/mi_negocio_rubro';
  static const String calculadoras = '/calculadoras';
  static const String calculatorPlaceholder = '/calculator_placeholder';
  static const String liquidacion = '/liquidacion';
  static const String itbms = '/itbms';
  static const String prestamo = '/prestamo';
  static const String margenGanancia = '/margen_ganancia';
  static const String bovedaDigital = '/boveda_digital';
  static const String recordatorios = '/recordatorios';
  static const String progresoMetas = '/progreso_metas';
  static const String blog = '/blog'; 
  static const String blogArticle = '/blog_article'; 
  static const String legal = '/legal';
  static const String auditoria = '/auditoria';
  static const String checklist = '/checklist';
  static const String checklistRubroSelection = '/checklist/rubro_selection';
  static const String checklistRubroDetail = '/checklist/rubro_detail';
  static const String planAccion = '/plan_accion';
  static const String businessProfile = '/business_profile';
  static const String businessProfileForm = '/business_profile_form';
  static const String businessProfileReview = '/business_profile_review';
  static const String reminders = '/reminders';
  static const String reminderDetail = '/reminder_detail';
  static const String learningCenter = '/learning_center';
  static const String caminoEmprendedor = '/camino_emprendedor'; 
  static const String laRutaAlExito = '/la_ruta_al_exito';
  static const String fixedCosts = '/fixed_costs';
  static const String cashFlow = '/accounting/cash_flow';
  static const String taxEstimator = '/accounting/tax_estimator';
  static const String budget = '/accounting/budget';
  static const String accountingToolsMenu = '/accounting/tools_menu';
  static const String accountingClassroom = '/accounting/classroom';
  static const String accountingV2 = '/accounting_v2';
  static const String accountingManagerial = '/accounting/managerial';
  
  static const String agendaTramites = '/agenda_tramites';
  static const String pendientes = '/pendientes';

  // --- ROUTE GUARD HELPER ---
  static Widget _guard(String sectionId, Widget page) {
    if (!VisibilityService.instance.isVisible(sectionId)) {
      return const NotFoundScreen();
    }
    return page;
  }

  static WidgetBuilder _guardedRoute(String sectionId, Widget Function(BuildContext) builder) {
    return (context) {
      if (!VisibilityService.instance.isVisible(sectionId)) {
        return const NotFoundScreen();
      }
      return builder(context);
    };
  }

  static final Map<String, WidgetBuilder> routes = {
    root: (_) => const MainShell(),
    register: (_) => const AuthScreen(isLoginMode: false),
    login: (_) => const AuthScreen(isLoginMode: true),
    'auth': (_) => const AuthScreen(isLoginMode: true),

    adminBlog: (_) => const AdminBlogScreen(),
    adminBlogForm: (_) => const AdminBlogFormScreen(),
    adminVisibility: (_) => const SectionVisibilityScreen(),
    aiChat: (_) => const ChatbotScreen(),
    tools: (_) => const ToolsScreen(),
    library: (_) => const LibraryScreen(),
    profile: (_) => const SettingsScreen(),
    accounting: (_) => const AccountingV2Screen(), // REDIRECT TO V2
    humanResources: _guardedRoute('home.hr', (_) => const HumanResourcesScreen()),
    marketing: _guardedRoute('home.marketing', (_) => const MarketingScreen()),
    aiHub: _guardedRoute('tools.ai_chat', (_) => const AIHubScreen()), // Optional mapping
    tramites: (_) => const TramitesScreen(),
    aiTexts: (context) => const AiTextsScreen(),
    aiCustomers: (context) => const AiCustomersScreen(),
    aiProducts: (context) => const AiGenericScreen(featureType: AiFeatureType.products),
    aiContracts: (context) => const AiGenericScreen(featureType: AiFeatureType.contracts),
    aiProcesses: (context) => const AiGenericScreen(featureType: AiFeatureType.processes),
    aiStrategies: (context) => const AiGenericScreen(featureType: AiFeatureType.strategies),
    settings: (_) => const SettingsScreen(),
    AppRoutes.settingsLegal: (_) => const SettingsScreen(initialSection: 'legales'),
    rutaEmprendedor: (_) => const RutaExitoScreen(),
    laRutaAlExito: _guardedRoute('home.ruta_exito', (_) => const RutaExitoScreen()),
    
    // Marketing Module
    marketingContent: (_) => const MarketingContentScreen(),
    marketingFunnel: (_) => const MarketingFunnelScreen(),
    marketingCampaigns: (_) => const MarketingCampaignScreen(),
    marketingAvatar: (_) => const MarketingAvatarScreen(),
    marketingAutomation: (_) => const SocialMediaAutomationScreen(),
    
    // IA & Features
    iaContable: (_) => const IAContableScreen(),
    iaLegal: (_) => const IALegalScreen(),
    iaMarketing: (_) => const IAMarketingScreen(),
    iaVentas: (_) => const IAVentasScreen(),
    iaProductividad: (_) => const IAProductividadScreen(),
    iaDocente: (_) => const IADocenteScreen(),
    planificadorSemanal: (_) => const PlanificadorSemanalScreen(),
    // misionesDiarias: (_) => const MisionesDiariasScreen(), // DELETED
    directorio: (_) => const DirectorioScreen(),
    employees: (_) => const EmployeesGridScreen(),
    dashboardNegocio: (_) => const DashboardNegocioScreen(),

    tiendaPremium: (_) => const TiendaPremiumScreen(),
    premiumPlans: (_) => const PremiumPlansScreen(),
    checkoutEmprendedor: (_) => const Scaffold(body: Center(child: Text('Checkout Emprendedor Placeholder'))),
    checkoutPro: (_) => const Scaffold(body: Center(child: Text('Checkout Pro Placeholder'))),
    notifications: (_) => const NotificationsScreen(),
    
    // Others
    inicioNegocio: (_) => const InicioNegocioScreen(),
    sbot: (_) => const SBotHomeScreen(),
    sbotQuestion: (_) => const SBotQuestionScreen(),
    sbotResult: (_) => const SBotResultScreen(),
    sbotHistory: (_) => const SBotHistoryScreen(),
    quickAccess: (_) => const QuickAccessScreen(),
    miNegocioRubro: _guardedRoute('home.my_business', (_) => const MiNegocioRubroScreen()),
    calculadoras: _guardedRoute('tools.calculators', (_) => const CalculadorasScreen()),
    // Calculators
    liquidacion: (context) {
       final args = ModalRoute.of(context)?.settings.arguments;
       WorkerProfile? worker;
       if (args is WorkerProfile) worker = args;
       return LiquidacionScreen(worker: worker);
    },
    itbms: (_) => const ItbmsScreen(),
    prestamo: (_) => const PrestamoScreen(),
    margenGanancia: (_) => const MargenGananciaScreen(),
    '/vacation_calculator': (context) {
      final args = ModalRoute.of(context)?.settings.arguments as WorkerProfile?;
      return VacationCalculatorScreen(worker: args);
    },
    '/decimo_calculator': (context) {
      final args = ModalRoute.of(context)?.settings.arguments as WorkerProfile?;
      return DecimoCalculatorScreen(worker: args);
    },
    '/payroll_history': (_) => const PayrollHistoryScreen(),
    '/hr_archive': (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) return HRArchiveScreen(initialWorkerId: args);
      return const HRArchiveScreen();
    },
    calculatorPlaceholder: (_) => const CalculatorPlaceholderScreen(),
    salarioNeto: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      String? initialId;
      if (args is String) initialId = args;
      return SalarioScreen(initialWorkerId: initialId);
    },
    decimoTercerMes: (_) => const DecimoTercerMesScreen(),
    puntoEquilibrio: (_) => const PuntoEquilibrioScreen(),
    checklistTramites: (_) => const ChecklistTramitesScreen(),
    bovedaDigital: (_) => const BovedaScreen(),
    recordatorios: (_) => const RecordatoriosScreen(),
    progresoMetas: (_) => const ProgresoMetasScreen(),
    blog: _guardedRoute('home.blog', (_) => const BlogMainScreen()),
    blogArticle: _guardedRoute('home.blog', (_) => const BlogArticleScreen()),
    legal: (_) => const LegalScreen(),
    auditoria: _guardedRoute('tools.audit', (_) => const AuditoriaNegocioScreen()),
    checklist: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      final initialIndex = args is int ? args : null;
      return ChecklistHubScreen(initialTabIndex: initialIndex);
    },
    checklistRubroSelection: (_) => const ChecklistRubroSelectionScreen(),
    checklistRubroDetail: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return ChecklistRubroDetailScreen(
        rubroId: args['rubroId'],
        title: args['title'],
      );
    },
    planAccion: (_) => const ChecklistPlanAccionScreen(),
    businessProfile: (_) => const BusinessProfileHomeScreen(),
    businessProfileForm: (_) => const BusinessProfileFormScreen(),
    businessProfileReview: (_) => const BusinessProfileReviewScreen(),
    reminders: (_) => const ReminderListScreen(),
    reminderDetail: (_) => const ReminderDetailScreen(),
    learningCenter: _guardedRoute('tools.courses', (_) => const LearningCenterScreen()),
    caminoEmprendedor: (_) => const RutaExitoScreen(),
    // Accounting Module
    AppRoutes.cashFlow: (_) => const CashFlowScreen(),
    AppRoutes.taxEstimator: (_) => const TaxEstimatorScreen(),
    AppRoutes.budget: (_) => const BudgetScreen(),
    AppRoutes.accountingToolsMenu: (_) => const AccountingToolsMenuScreen(),
    AppRoutes.accountingClassroom: (_) => const AccountingClassroomScreen(),
    AppRoutes.accountingV2: (_) => const AccountingV2Screen(),
    AppRoutes.accountingManagerial: (_) => const AccountingManagerialScreen(),
    '/rrhh/cumplimiento': (_) => const LaborComplianceScreen(),

    '/rrhh/plantillas': (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return HrTemplatesScreen(
        initialTemplateType: args?['templateType'],
        worker: args?['worker'],
      );
    },
    AppRoutes.agendaTramites: (_) => const AgendaTramitesScreen(),
    AppRoutes.pendientes: (_) => const PendientesScreen(),
    '/employee_history': (context) {
      final args = ModalRoute.of(context)?.settings.arguments as String;
      return EmployeeHistoryScreen(workerId: args);
    },
    '/shift_logger': (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      return ShiftLoggerScreen(
        worker: args['worker'],
        existingPeriod: args['existingPeriod'],
      );
    },
    '/schedule_creator': (_) => const ScheduleScreen(),
    '/market_study': (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return MarketStudyScreen(
        rubroId: args?['rubroId'] ?? '',
        rubroName: args?['rubroName'] ?? '',
      );
    },
    '/module_guide': (_) => const ModuleGuideScreen(),
    '/period_comparison': (_) => const PeriodComparisonScreen(),
    '/tools/import_shifts': (_) => const ImportShiftsScreen(),

    // ADMIN PRO ROUTES (V2 FORCED)
    '/admin': (_) => const AdminDashboardScreen(), // Direct mapping to V2 Dashboard
    adminDashboard: (_) => const AdminLayout(currentRoute: adminDashboard, child: AdminDashboardScreen()),
    adminVisibility: (_) => const AdminLayout(currentRoute: adminVisibility, child: SectionVisibilityScreen()), // Flags
    adminAnalytics: (_) => const AdminLayout(currentRoute: adminAnalytics, child: AdminAnalyticsScreen()),
    adminUsers: (_) => const AdminLayout(currentRoute: adminUsers, child: AdminUsersScreen()),
    adminContent: (_) => const AdminLayout(currentRoute: adminContent, child: AdminContentScreen()),
    adminAudit: (_) => const AdminLayout(currentRoute: adminAudit, child: AdminAuditScreen()),
    adminSystem: (_) => const AdminLayout(currentRoute: adminSystem, child: AdminSystemScreen()),
    adminAi: (_) => const AdminLayout(currentRoute: adminAi, child: AdminAiScreen()),

    fixedCosts: (_) => const FixedCostsScreen(),
  };
}
