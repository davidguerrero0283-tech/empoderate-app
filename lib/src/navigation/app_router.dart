import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_routes.dart';
import '../screens/coming_soon_screen.dart'; // NEW

// Shell
import 'main_shell.dart';
import '../../ui/components/footer/bottom_nav_bar.dart';
import '../components/route_debug_badge.dart';

// Screens - Core
import '../screens/home_screen.dart';
import '../screens/tools_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/auth_screen.dart';
import '../screens/not_found_screen.dart';
import '../screens/under_construction_screen.dart'; // NEW

// Screens - Main Sections
import '../screens/human_resources_screen.dart';
import '../screens/marketing_screen.dart';
import '../screens/ai_hub_screen.dart';
import '../screens/tramites_screen.dart';
import '../screens/library_screen.dart';

// Calculators
import '../screens/calculadoras_screen.dart';
import '../screens/calculators/liquidacion_screen.dart';
import '../screens/calculators/salario_screen.dart';
import '../screens/calculators/vacation_calculator_screen.dart';
import '../screens/calculators/decimo_calculator_screen.dart';
import '../screens/calculators/itbms_screen.dart';
import '../screens/calculators/prestamo_screen.dart';
import '../screens/calculators/margen_ganancia_screen.dart';
import '../screens/calculators/fixed_costs_screen.dart';
import '../screens/calculators/payroll_history_screen.dart';
import '../screens/calculators/shift_logger_screen.dart';
import '../screens/calculators/comprobante_planilla_screen.dart';
import '../calculators/salario_models.dart';
import '../screens/legal_text_screen.dart';

// Accounting
import '../screens/calculators/accounting/accounting_v2_screen.dart';
import '../screens/calculators/accounting/accounting_managerial_screen.dart';
import '../screens/calculators/accounting/cash_flow_screen.dart';
import '../screens/calculators/accounting/tax_estimator_screen.dart';
import '../screens/calculators/accounting/budget_screen.dart';
import '../screens/calculators/accounting/accounting_tools_menu_screen.dart';
import '../features/accounting/classroom/accounting_classroom_screen.dart';

// HR
import '../screens/human_resources/employee_history_screen.dart';
import '../screens/human_resources/hr_archive_screen.dart';
import '../screens/hr_templates_screen.dart';
import '../screens/employees_grid_screen.dart';
import '../features/hr/compliance/labor_compliance_screen.dart';
import '../features/schedule_management/presentation/schedule_screen.dart';
import '../screens/human_resources/worker_form_screen.dart';

// Marketing
import '../screens/marketing/marketing_content_screen.dart';
import '../screens/marketing/marketing_funnel_screen.dart';
import '../screens/marketing/marketing_campaign_screen.dart';
import '../screens/marketing/marketing_avatar_screen.dart';
import '../screens/marketing/social_media_automation_screen.dart';

// AI
import '../screens/ia_contable_screen.dart';
import '../screens/ia_legal_screen.dart';
import '../screens/ia_marketing_screen.dart';
import '../screens/ia_ventas_screen.dart';
import '../screens/ia_productividad_screen.dart';
import '../screens/ia_docente_screen.dart';
import '../screens/chatbot_screen.dart';
import 'package:proyecto_empoderate/features/ai_texts/ui/ai_texts_screen.dart';
import 'package:proyecto_empoderate/features/ai_customers/ui/ai_customers_screen.dart';
import 'package:proyecto_empoderate/features/ai_shared/ui/ai_generic_screen.dart';
import 'package:proyecto_empoderate/features/ai_shared/domain/ai_shared_types.dart';

// Business & Checklist
import '../screens/mi_negocio_rubro_screen.dart';
import '../screens/checklist/checklist_hub_screen.dart';
import '../features/checklist/screens/checklist_rubro_selection_screen.dart';
import '../features/checklist/screens/checklist_rubro_detail_screen.dart';
import '../checklist/checklist_plan_accion_screen.dart';
import '../features/ruta_exito/ruta_exito_screen.dart';
import '../screens/checklist_tramites_screen.dart';
import '../screens/dashboard_negocio_screen.dart';

// Business Profile
import '../business_profile/business_profile_home_screen.dart';
import '../business_profile/business_profile_form_screen.dart';
import '../business_profile/business_profile_review_screen.dart';
import '../business_profile/reminder_list_screen.dart';
import '../business_profile/reminder_detail_screen.dart';

// Boveda & Docs
import '../features/boveda/screens/boveda_screen.dart';

// Blog
import '../screens/blog_main_screen.dart';
import '../screens/blog_article_screen.dart';

// SBot
import '../sbot/sbot_home_screen.dart';
import '../sbot/sbot_question_screen.dart';
import '../sbot/sbot_result_screen.dart';
import '../sbot/sbot_history_screen.dart';

// Premium & Payments
import '../screens/tienda_premium_screen.dart';
import '../screens/premium_plans_screen.dart';

// Admin
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/blog/admin_blog_screen.dart';
import '../screens/admin/blog/admin_blog_form_screen.dart';
import '../screens/admin/visibility/section_visibility_screen.dart';
import '../screens/admin/admin_analytics_screen.dart';
import '../screens/admin/admin_users_screen.dart';
import '../screens/admin/admin_content_screen.dart';
import '../screens/admin/blog/post_editor_screen.dart'; // NEW
import '../screens/admin/blog/external_blog_screen.dart'; // NEW
import '../screens/admin/admin_audit_screen.dart';
import '../screens/admin/admin_system_screen.dart';
import '../screens/admin/admin_ai_screen.dart';
import '../features/admin/layout/admin_layout.dart';

// Other Screens
import '../screens/inicio_negocio_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/quick_access_screen.dart';
import '../screens/planificador_semanal_screen.dart';
import '../screens/directorio_screen.dart';
import '../screens/decimo_tercer_mes_screen.dart';
import '../screens/punto_equilibrio_screen.dart';
import '../screens/recordatorios_screen.dart';
import '../screens/progreso_metas_screen.dart';
import '../screens/legal_screen.dart';
import '../screens/auditoria_negocio_screen.dart';
import '../screens/learning/learning_center_screen.dart';
import '../screens/learning/learning_category_screen.dart';
import '../screens/learning/course_detail_screen.dart';
import '../screens/learning/learning_repository.dart';
import '../screens/learning/learning_models.dart';
import '../screens/learning/course_module_viewer.dart';
import '../screens/learning/module_guide_screen.dart';
import '../screens/library_detail_screen.dart';
import '../screens/market_study_screen.dart';
import '../screens/requirement_detail_screen.dart';
import '../screens/calculator_placeholder_screen.dart';
import '../data/negocio/business_content_data.dart';
import '../models/business_data.dart';
import '../screens/industry_category_screen.dart';
import '../screens/niche_confirmation_screen.dart';
import '../../features/agenda_tramites/ui/agenda_tramites_screen.dart';
import '../features/pendientes/screens/pendientes_screen.dart';

// Services for loading data by ID
import '../services/worker_service.dart';
import '../calculators/salario_models.dart';

/// Global navigator key for compatibility
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// App Router configuration with go_router
class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    
    // Error handler for unknown routes
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Ruta no encontrada',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Volver al Inicio'),
            ),
          ],
        ),
      ),
    ),

    routes: [
      // ========== SHELL ROUTE (Bottom Navigation) ==========
      ShellRoute(
        builder: (context, state, child) => MainShellGoRouter(child: child),
        routes: [
          // Home
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          
          // Tools
          GoRoute(
            path: '/tools',
            name: 'tools',
            builder: (context, state) => const ToolsScreen(),
          ),
          
          // Boveda Digital
          GoRoute(
            path: '/boveda_digital',
            name: 'boveda_digital',
            builder: (context, state) => const BovedaScreen(),
          ),
          
          // Settings
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) {
              final section = state.uri.queryParameters['section'];
              return SettingsScreen(initialSection: section);
            },
            routes: [
              GoRoute(
                path: 'plan_detail',
                name: 'plan_detail',
                builder: (context, state) {
                  // final extra = state.extra as Map<String, dynamic>?;
                  // final plan = extra?['plan'];
                  // return PlanDetailScreen(plan: plan);
                  return const PremiumPlansScreen(); // Fallback to plans grid
                },
              ),
              GoRoute(
                path: 'legal_text',
                name: 'legal_text',
                builder: (context, state) {
                  final title = state.uri.queryParameters['title'] ?? '';
                  final content = state.uri.queryParameters['content'] ?? '';
                  return LegalTextScreen(title: title, content: content);
                },
              ),
            ],
          ),
          
          // Library
          GoRoute(
            path: '/library',
            name: 'library',
            builder: (context, state) => const LibraryScreen(),
            routes: [
              GoRoute(
                path: 'category/:categoryId',
                name: 'library_category',
                builder: (context, state) {
                  final categoryId = state.pathParameters['categoryId']!;
                  final extra = state.extra as Map<String, dynamic>? ?? {};
                  return LibraryDetailScreen(categoryId: categoryId, categoryMeta: extra);
                },
              ),
            ],
          ),
        ],
      ),

      // ========== AUTH ROUTES ==========
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const AuthScreen(isLoginMode: true),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const AuthScreen(isLoginMode: false),
      ),

      // ========== HUMAN RESOURCES ==========
      GoRoute(
        path: '/human_resources',
        name: 'human_resources',
        builder: (context, state) => const HumanResourcesScreen(),
      ),
      // Redirect legacy /employees route to /hr/employees
      GoRoute(
        path: '/employees',
        redirect: (context, state) => '/hr/employees',
      ),
      GoRoute(
        path: '/hr/employees',
        name: 'employees',
        builder: (context, state) => const EmployeesGridScreen(),
      ),
      GoRoute(
        path: '/hr/worker/add',
        name: 'worker_add',
        builder: (context, state) => WorkerFormScreen(onSave: () {}),
      ),
      GoRoute(
        path: '/hr/worker/edit/:workerId',
        name: 'worker_edit',
        builder: (context, state) {
          final workerId = state.pathParameters['workerId'];
          return WorkerFormScreen(workerId: workerId, onSave: () {});
        },
      ),
      GoRoute(
        path: '/employee_history/:workerId',
        name: 'employee_history',
        builder: (context, state) {
          final workerId = state.pathParameters['workerId'] ?? '';
          return EmployeeHistoryScreen(workerId: workerId);
        },
      ),
      GoRoute(
        path: '/rrhh/plantillas',
        name: 'hr_templates',
        builder: (context, state) {
          final workerId = state.uri.queryParameters['workerId'];
          final templateType = state.uri.queryParameters['templateType'];
          // Worker will be loaded in the screen if workerId is provided
          return HrTemplatesScreen(
            initialTemplateType: templateType,
            workerId: workerId,
          );
        },
      ),
      GoRoute(
        path: '/schedule_creator',
        name: 'schedule_creator',
        builder: (context, state) => const ScheduleScreen(),
      ),
      GoRoute(
        path: '/hr_archive',
        name: 'hr_archive',
        builder: (context, state) => const HRArchiveScreen(),
      ),
      GoRoute(
        path: '/payroll_history',
        name: 'payroll_history',
        builder: (context, state) => const PayrollHistoryScreen(),
      ),

      // ========== CALCULATORS (CRITICAL: Support workerId query param) ==========
      GoRoute(
        path: '/calculadoras',
        name: 'calculadoras',
        builder: (context, state) => const CalculadorasScreen(),
      ),
      GoRoute(
        path: '/liquidacion',
        name: 'liquidacion',
        builder: (context, state) {
          final workerId = state.uri.queryParameters['workerId'];
          // Pass workerId - screen will load from WorkerService
          return LiquidacionScreen(workerId: workerId);
        },
      ),
      GoRoute(
        path: '/payroll/receipt',
        name: 'payroll_receipt',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          if (extra != null) {
            try {
              final input = SalarioInputModel.fromJson(extra['input']);
              final result = SalarioResultModel.fromJson(extra['result']);
              return ComprobantePlanillaScreen(input: input, result: result);
            } catch (e) {
              return const NotFoundScreen();
            }
          }
          
          final inputJson = state.uri.queryParameters['input'];
          final resultJson = state.uri.queryParameters['result'];
          
          if (inputJson == null || resultJson == null) return const NotFoundScreen();
          
          try {
            final input = SalarioInputModel.fromJson(Map<String, dynamic>.from(Uri.decodeComponent(inputJson) as dynamic));
            final result = SalarioResultModel.fromJson(Map<String, dynamic>.from(Uri.decodeComponent(resultJson) as dynamic));
            return ComprobantePlanillaScreen(input: input, result: result);
          } catch (e) {
             return const NotFoundScreen();
          }
        },
      ),
      GoRoute(
        path: '/salario_neto',
        name: 'salario_neto',
        builder: (context, state) {
          final workerId = state.uri.queryParameters['workerId'];
          return SalarioScreen(initialWorkerId: workerId);
        },
      ),
      GoRoute(
        path: '/vacation_calculator',
        name: 'vacation_calculator',
        builder: (context, state) {
          final workerId = state.uri.queryParameters['workerId'];
          DateTime? start;
          DateTime? end;
          if (state.uri.queryParameters['startDate'] != null) {
            start = DateTime.tryParse(state.uri.queryParameters['startDate']!);
          }
           if (state.uri.queryParameters['endDate'] != null) {
            end = DateTime.tryParse(state.uri.queryParameters['endDate']!);
          }
          return VacationCalculatorScreen(
            workerId: workerId,
            initialStartDate: start,
            initialEndDate: end,
          );
        },
      ),
      GoRoute(
        path: '/decimo_calculator',
        name: 'decimo_calculator',
        builder: (context, state) {
          final workerId = state.uri.queryParameters['workerId'];
          return DecimoCalculatorScreen(workerId: workerId);
        },
      ),
      GoRoute(
        path: '/shift_logger',
        name: 'shift_logger',
        builder: (context, state) {
          final workerId = state.uri.queryParameters['workerId'];
          return ShiftLoggerScreen(workerId: workerId);
        },
      ),
      GoRoute(
        path: '/coming-soon',
        name: 'coming_soon',
        builder: (context, state) {
          final title = state.uri.queryParameters['title'] ?? 'Próximamente';
          return ComingSoonScreen(title: title);
        },
      ),
      GoRoute(
        path: '/under_construction',
        name: 'under_construction',
        builder: (context, state) {
          final title = state.uri.queryParameters['title'] ?? 'Módulo';
          final route = state.uri.queryParameters['route'] ?? 'N/A';
          return UnderConstructionScreen(title: title, route: route);
        },
      ),
      GoRoute(
        path: '/itbms',
        name: 'itbms',
        builder: (context, state) => const ItbmsScreen(),
      ),
      GoRoute(
        path: '/prestamo',
        name: 'prestamo',
        builder: (context, state) => const PrestamoScreen(),
      ),
      GoRoute(
        path: '/margen_ganancia',
        name: 'margen_ganancia',
        builder: (context, state) => const MargenGananciaScreen(),
      ),
      GoRoute(
        path: '/fixed_costs',
        name: 'fixed_costs',
        builder: (context, state) => const FixedCostsScreen(),
      ),
      GoRoute(
        path: '/decimo_tercer_mes',
        name: 'decimo_tercer_mes',
        builder: (context, state) => const DecimoTercerMesScreen(),
      ),
      GoRoute(
        path: '/punto_equilibrio',
        name: 'punto_equilibrio',
        builder: (context, state) => const PuntoEquilibrioScreen(),
      ),
      GoRoute(
        path: '/calculator_placeholder',
        name: 'calculator_placeholder',
        builder: (context, state) {
          final title = state.uri.queryParameters['title'] ?? 'Calculadora';
          final description = state.uri.queryParameters['description'] ?? '';
          return CalculatorPlaceholderScreen(title: title, description: description);
        },
      ),

      // ========== ACCOUNTING ==========
      GoRoute(
        path: '/accounting',
        name: 'accounting',
        builder: (context, state) => const AccountingV2Screen(),
      ),
      GoRoute(
        path: '/accounting_v2',
        name: 'accounting_v2',
        builder: (context, state) => const AccountingV2Screen(),
      ),
      GoRoute(
        path: '/accounting/managerial',
        name: 'accounting_managerial',
        builder: (context, state) => const AccountingManagerialScreen(),
      ),
      GoRoute(
        path: '/accounting/cash_flow',
        name: 'cash_flow',
        builder: (context, state) => const CashFlowScreen(),
      ),
      GoRoute(
        path: '/accounting/tax_estimator',
        name: 'tax_estimator',
        builder: (context, state) => const TaxEstimatorScreen(),
      ),
      GoRoute(
        path: '/accounting/budget',
        name: 'budget',
        builder: (context, state) => const BudgetScreen(),
      ),
      GoRoute(
        path: '/accounting/tools_menu',
        name: 'accounting_tools_menu',
        builder: (context, state) => const AccountingToolsMenuScreen(),
      ),
      GoRoute(
        path: '/accounting/classroom',
        name: 'accounting_classroom',
        builder: (context, state) => const AccountingClassroomScreen(),
      ),

      // ========== HUMAN RESOURCES ==========
      GoRoute(
        path: '/rrhh/cumplimiento',
        name: 'labor_compliance',
        builder: (context, state) => const LaborComplianceScreen(),
      ),

      // ========== MARKETING ==========
      GoRoute(
        path: '/marketing',
        name: 'marketing',
        builder: (context, state) => const MarketingScreen(),
      ),
      GoRoute(
        path: '/marketing/content',
        name: 'marketing_content',
        builder: (context, state) => const MarketingContentScreen(),
      ),
      GoRoute(
        path: '/marketing/funnel',
        name: 'marketing_funnel',
        builder: (context, state) => const MarketingFunnelScreen(),
      ),
      GoRoute(
        path: '/marketing/campaigns',
        name: 'marketing_campaigns',
        builder: (context, state) => const MarketingCampaignScreen(),
      ),
      GoRoute(
        path: '/marketing/avatar',
        name: 'marketing_avatar',
        builder: (context, state) => const MarketingAvatarScreen(),
      ),
      GoRoute(
        path: '/marketing/automation',
        name: 'marketing_automation',
        builder: (context, state) => const SocialMediaAutomationScreen(),
      ),

      // ========== AI HUB ==========
      GoRoute(
        path: '/ai_hub',
        name: 'ai_hub',
        builder: (context, state) => const AIHubScreen(),
      ),
      GoRoute(
        path: '/ia/chat',
        name: 'ai_chat',
        builder: (context, state) => const ChatbotScreen(),
      ),
      GoRoute(
        path: '/ia_contable',
        name: 'ia_contable',
        builder: (context, state) => const IAContableScreen(),
      ),
      GoRoute(
        path: '/ia_legal',
        name: 'ia_legal',
        builder: (context, state) => const IALegalScreen(),
      ),
      GoRoute(
        path: '/ia_marketing',
        name: 'ia_marketing',
        builder: (context, state) => const IAMarketingScreen(),
      ),
      GoRoute(
        path: '/ia_ventas',
        name: 'ia_ventas',
        builder: (context, state) => const IAVentasScreen(),
      ),
      GoRoute(
        path: '/ia_productividad',
        name: 'ia_productividad',
        builder: (context, state) => const IAProductividadScreen(),
      ),
      GoRoute(
        path: '/ia_docente',
        name: 'ia_docente',
        builder: (context, state) => const IADocenteScreen(),
      ),
      GoRoute(
        path: '/ai/texts',
        name: 'ai_texts',
        builder: (context, state) => const AiTextsScreen(),
      ),
      GoRoute(
        path: '/ai/customers',
        name: 'ai_customers',
        builder: (context, state) => const AiCustomersScreen(),
      ),
      GoRoute(
        path: '/ai/products',
        name: 'ai_products',
        builder: (context, state) => const AiGenericScreen(featureType: AiFeatureType.products),
      ),
      GoRoute(
        path: '/ai/contracts',
        name: 'ai_contracts',
        builder: (context, state) => const AiGenericScreen(featureType: AiFeatureType.contracts),
      ),
      GoRoute(
        path: '/ai/processes',
        name: 'ai_processes',
        builder: (context, state) => const AiGenericScreen(featureType: AiFeatureType.processes),
      ),
      GoRoute(
        path: '/ai/strategies',
        name: 'ai_strategies',
        builder: (context, state) => const AiGenericScreen(featureType: AiFeatureType.strategies),
      ),

      // ========== TRAMITES & LEGAL ==========
      GoRoute(
        path: '/tramites',
        name: 'tramites',
        builder: (context, state) => const TramitesScreen(),
      ),
      GoRoute(
        path: '/checklist_tramites',
        name: 'checklist_tramites',
        builder: (context, state) => const ChecklistTramitesScreen(),
      ),
      GoRoute(
        path: '/agenda_tramites',
        name: 'agenda_tramites',
        builder: (context, state) => const AgendaTramitesScreen(),
      ),
      GoRoute(
        path: '/legal',
        name: 'legal',
        builder: (context, state) => const LegalScreen(),
      ),

      // ========== CHECKLIST & RUTA EXITO ==========
      GoRoute(
        path: '/checklist',
        name: 'checklist',
        builder: (context, state) {
          final tabStr = state.uri.queryParameters['tab'];
          final initialTab = tabStr != null ? int.tryParse(tabStr) : null;
          return ChecklistHubScreen(initialTabIndex: initialTab);
        },
      ),
      GoRoute(
        path: '/checklist/rubro_selection',
        name: 'checklist_rubro_selection',
        builder: (context, state) => const ChecklistRubroSelectionScreen(),
      ),
      GoRoute(
        path: '/checklist/rubro_detail/:rubroId',
        name: 'checklist_rubro_detail',
        builder: (context, state) {
          final rubroId = state.pathParameters['rubroId'] ?? '';
          final title = state.uri.queryParameters['title'] ?? '';
          return ChecklistRubroDetailScreen(rubroId: rubroId, title: title);
        },
      ),
      GoRoute(
        path: '/plan_accion',
        name: 'plan_accion',
        builder: (context, state) => const ChecklistPlanAccionScreen(),
      ),
      GoRoute(
        path: '/ruta_emprendedor',
        name: 'ruta_emprendedor',
        builder: (context, state) => const RutaExitoScreen(),
      ),
      GoRoute(
        path: '/la_ruta_al_exito',
        name: 'la_ruta_al_exito',
        builder: (context, state) => const RutaExitoScreen(),
      ),
      GoRoute(
        path: '/camino_emprendedor',
        name: 'camino_emprendedor',
        builder: (context, state) => const RutaExitoScreen(),
      ),

      // ========== BUSINESS ==========
      GoRoute(
        path: '/mi_negocio_rubro',
        name: 'mi_negocio_rubro',
        builder: (context, state) => const MiNegocioRubroScreen(),
        routes: [
          GoRoute(
            path: 'category/:categoryId',
            name: 'industry_category',
            builder: (context, state) {
              final categoryId = state.pathParameters['categoryId'] ?? '';
              final category = categoryData.firstWhere(
                (c) => c.id == categoryId,
                orElse: () => categoryData.first,
              );
              return IndustryCategoryScreen(category: category);
            },
          ),
          GoRoute(
            path: 'category/:categoryId/rubro/:rubroId',
            name: 'niche_confirmation',
            builder: (context, state) {
              final categoryId = state.pathParameters['categoryId'] ?? '';
              final rubroId = state.pathParameters['rubroId'] ?? '';
              final category = categoryData.firstWhere(
                (c) => c.id == categoryId,
                orElse: () => categoryData.first,
              );
              final rubro = category.rubros.firstWhere(
                (r) => r.id == rubroId,
                orElse: () => category.rubros.first,
              );
              return NicheConfirmationScreen(category: category, rubro: rubro);
            },
          ),
          GoRoute(
            path: 'category/:categoryId/rubro/:rubroId/detail',
            name: 'business_rubro_detail',
            builder: (context, state) {
              final categoryId = state.pathParameters['categoryId'] ?? '';
              final rubroId = state.pathParameters['rubroId'] ?? '';
              final category = categoryData.firstWhere(
                (c) => c.id == categoryId,
                orElse: () => categoryData.first,
              );
              final rubro = category.rubros.firstWhere(
                (r) => r.id == rubroId,
                orElse: () => category.rubros.first,
              );
              return ChecklistRubroDetailScreen(
                rubroId: rubroId,
                title: rubro.name,
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/business/requirement/:requirementId',
        name: 'requirement_detail',
        builder: (context, state) {
          final requirementId = state.pathParameters['requirementId'] ?? '';
          final item = getRequirementById(requirementId);
          if (item == null) return const NotFoundScreen();
          
          final categoryName = state.uri.queryParameters['categoryName'];
          final rubroName = state.uri.queryParameters['rubroName'];
          
          return RequirementDetailScreen(
            item: item,
            categoryName: categoryName,
            rubroName: rubroName,
          );
        },
      ),
      GoRoute(
        path: '/dashboard_negocio',
        name: 'dashboard_negocio',
        builder: (context, state) => const DashboardNegocioScreen(),
      ),
      GoRoute(
        path: '/inicio_negocio',
        name: 'inicio_negocio',
        builder: (context, state) => const InicioNegocioScreen(),
      ),
      GoRoute(
        path: '/market_study',
        name: 'market_study',
        builder: (context, state) {
          final rubroId = state.uri.queryParameters['rubroId'] ?? '';
          final rubroName = state.uri.queryParameters['rubroName'] ?? '';
          return MarketStudyScreen(rubroId: rubroId, rubroName: rubroName);
        },
      ),
      GoRoute(
        path: '/auditoria',
        name: 'auditoria',
        builder: (context, state) => const AuditoriaNegocioScreen(),
      ),

      // ========== BUSINESS PROFILE ==========
      GoRoute(
        path: '/business_profile',
        name: 'business_profile',
        builder: (context, state) => const BusinessProfileHomeScreen(),
      ),
      GoRoute(
        path: '/business_profile_form',
        name: 'business_profile_form',
        builder: (context, state) => const BusinessProfileFormScreen(),
      ),
      GoRoute(
        path: '/business_profile_review',
        name: 'business_profile_review',
        builder: (context, state) => const BusinessProfileReviewScreen(),
      ),
      GoRoute(
        path: '/reminders',
        name: 'reminders',
        builder: (context, state) => const ReminderListScreen(),
      ),
      GoRoute(
        path: '/reminder_detail',
        name: 'reminder_detail',
        builder: (context, state) => const ReminderDetailScreen(),
      ),

      // ========== BLOG ==========
      GoRoute(
        path: '/blog',
        name: 'blog',
        builder: (context, state) => const BlogMainScreen(),
      ),
      GoRoute(
        path: '/blog_article',
        name: 'blog_article',
        builder: (context, state) => const BlogArticleScreen(),
      ),

      // ========== SBOT ==========
      GoRoute(
        path: '/sbot',
        name: 'sbot',
        builder: (context, state) => const SBotHomeScreen(),
      ),
      GoRoute(
        path: '/sbot_question',
        name: 'sbot_question',
        builder: (context, state) => const SBotQuestionScreen(),
      ),
      GoRoute(
        path: '/sbot_result',
        name: 'sbot_result',
        builder: (context, state) => const SBotResultScreen(),
      ),
      GoRoute(
        path: '/sbot_history',
        name: 'sbot_history',
        builder: (context, state) => const SBotHistoryScreen(),
      ),

      // ========== PREMIUM & PAYMENTS ==========
      GoRoute(
        path: '/tienda_premium',
        name: 'tienda_premium',
        builder: (context, state) => const TiendaPremiumScreen(),
      ),
      GoRoute(
        path: '/premium_plans',
        name: 'premium_plans',
        builder: (context, state) => const PremiumPlansScreen(),
      ),
      GoRoute(
        path: '/checkout/emprendedor',
        name: 'checkout_emprendedor',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Checkout Emprendedor - Placeholder')),
        ),
      ),
      GoRoute(
        path: '/checkout/pro',
        name: 'checkout_pro',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Checkout Pro - Placeholder')),
        ),
      ),
      // Payment gateway callbacks (prepared for future integration)
      GoRoute(
        path: '/pay/success',
        name: 'pay_success',
        builder: (context, state) => const PaymentSuccessScreen(),
      ),
      GoRoute(
        path: '/pay/cancel',
        name: 'pay_cancel',
        builder: (context, state) => const PaymentCancelScreen(),
      ),

      // ========== OTHER ==========
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/quick_access',
        name: 'quick_access',
        builder: (context, state) => const QuickAccessScreen(),
      ),
      GoRoute(
        path: '/planificador_semanal',
        name: 'planificador_semanal',
        builder: (context, state) => const PlanificadorSemanalScreen(),
      ),
      GoRoute(
        path: '/directorio',
        name: 'directorio',
        builder: (context, state) => const DirectorioScreen(),
      ),
      GoRoute(
        path: '/recordatorios',
        name: 'recordatorios',
        builder: (context, state) => const RecordatoriosScreen(),
      ),
      GoRoute(
        path: '/progreso_metas',
        name: 'progreso_metas',
        builder: (context, state) => const ProgresoMetasScreen(),
      ),
      GoRoute(
        path: '/learning_center',
        name: 'learning_center',
        builder: (context, state) => const LearningCenterScreen(),
        routes: [
          GoRoute(
            path: 'category/:categoryId',
            name: 'learning_category',
            builder: (context, state) {
              final categoryId = state.pathParameters['categoryId']!;
              final category = learningCategories.firstWhere(
                (c) => c.id == categoryId,
                orElse: () => learningCategories.first,
              );
              return LearningCategoryScreen(category: category);
            },
          ),
          GoRoute(
            path: 'course/:courseId',
            name: 'course_detail',
            builder: (context, state) {
              final courseId = state.pathParameters['courseId']!;
              final course = LearningRepository.courses.firstWhere(
                (c) => c.id == courseId,
                orElse: () => LearningRepository.courses.first,
              );
              return CourseDetailScreen(course: course);
            },
          ),
          GoRoute(
            path: 'course/:courseId/module/:moduleIndex',
            name: 'course_module',
            builder: (context, state) {
              final courseId = state.pathParameters['courseId']!;
              final moduleIndex = int.tryParse(state.pathParameters['moduleIndex'] ?? '0') ?? 0;
              final course = LearningRepository.courses.firstWhere(
                (c) => c.id == courseId,
                orElse: () => LearningRepository.courses.first,
              );
              final module = course.modules.length > moduleIndex 
                  ? course.modules[moduleIndex] 
                  : course.modules.first;
              return CourseModuleViewer(course: course, module: module, moduleIndex: moduleIndex);
            },
          ),
        ],
      ),

      GoRoute(
        path: '/module_guide',
        name: 'module_guide',
        builder: (context, state) => const ModuleGuideScreen(),
      ),
      GoRoute(
        path: '/pendientes',
        name: 'pendientes',
        builder: (context, state) => const PendientesScreen(),
      ),
      GoRoute(
        path: '/perfil',
        name: 'perfil',
        builder: (context, state) => const SettingsScreen(),
      ),

      // ========== ADMIN ==========
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin_dashboard',
        name: 'admin_dashboard',
        builder: (context, state) => const AdminLayout(
          currentRoute: '/admin_dashboard',
          child: AdminDashboardScreen(),
        ),
      ),
      GoRoute(
        path: '/admin_visibility',
        name: 'admin_visibility',
        builder: (context, state) => const AdminLayout(
          currentRoute: '/admin_visibility',
          child: SectionVisibilityScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/analytics',
        name: 'admin_analytics',
        builder: (context, state) => const AdminLayout(
          currentRoute: '/admin/analytics',
          child: AdminAnalyticsScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/users',
        name: 'admin_users',
        builder: (context, state) => const AdminLayout(
          currentRoute: '/admin/users',
          child: AdminUsersScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/content',
        name: 'admin_content',
        builder: (context, state) => const AdminLayout(
          currentRoute: '/admin/content',
          child: AdminContentScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/audit',
        name: 'admin_audit',
        builder: (context, state) => const AdminLayout(
          currentRoute: '/admin/audit',
          child: AdminAuditScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/system',
        name: 'admin_system',
        builder: (context, state) => const AdminLayout(
          currentRoute: '/admin/system',
          child: AdminSystemScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/ai',
        name: 'admin_ai',
        builder: (context, state) => const AdminLayout(
          currentRoute: '/admin/ai',
          child: AdminAiScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/blog',
        name: 'admin_blog',
        builder: (context, state) => const AdminLayout(
          currentRoute: '/admin/blog',
          child: ExternalBlogScreen(),
        ),
      ),
      GoRoute(
        path: '/admin_blog_form',
        name: 'admin_blog_form',
        builder: (context, state) => const AdminBlogFormScreen(),
      ),
      GoRoute(
        path: '/admin/content/editor',
        name: 'admin_blog_editor',
        builder: (context, state) {
           final id = state.uri.queryParameters['id'];
           return AdminLayout(
              currentRoute: '/admin/content', // Keep sidebar highlighted on content
              child: PostEditorScreen(draftId: id),
           );
        },
      ),
    ],
  );
}

// ========== PAYMENT PLACEHOLDER SCREENS ==========

/// Payment success screen - placeholder for gateway integration
class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionId = GoRouterState.of(context).uri.queryParameters['session_id'];
    
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 80, color: Colors.green),
            const SizedBox(height: 24),
            Text(
              '¡Pago Exitoso!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Tu suscripción ha sido activada',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (sessionId != null) ...[
              const SizedBox(height: 8),
              Text(
                'ID: $sessionId',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Ir al Inicio'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Payment cancel screen - placeholder for gateway integration
class PaymentCancelScreen extends StatelessWidget {
  const PaymentCancelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cancel, size: 80, color: Colors.orange),
            const SizedBox(height: 24),
            Text(
              'Pago Cancelado',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text('No se realizó ningún cargo a tu cuenta'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/premium_plans'),
              child: const Text('Ver Planes'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go('/'),
              child: const Text('Volver al Inicio'),
            ),
          ],
        ),
      ),
    );
  }
}

// ========== MAIN SHELL FOR GO_ROUTER ==========

/// MainShell adapted for go_router with ShellRoute
class MainShellGoRouter extends StatefulWidget {
  final Widget child;
  
  const MainShellGoRouter({super.key, required this.child});

  @override
  State<MainShellGoRouter> createState() => _MainShellGoRouterState();
}

class _MainShellGoRouterState extends State<MainShellGoRouter> {
  int _currentIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateIndexFromLocation();
  }

  void _updateIndexFromLocation() {
    final location = GoRouterState.of(context).uri.path;
    int newIndex = 0;
    
    if (location == '/tools') {
      newIndex = 1;
    } else if (location == '/boveda_digital') {
      newIndex = 2;
    } else if (location == '/settings' || location == '/perfil') {
      newIndex = 3;
    }
    
    if (newIndex != _currentIndex) {
      setState(() => _currentIndex = newIndex);
    }
  }

  void _onItemSelected(int index) {
    if (index == _currentIndex) return;
    
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/tools');
        break;
      case 2:
        context.go('/boveda_digital');
        break;
      case 3:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          widget.child,
          const RouteDebugBadge(), // Debug-only overlay
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return NeonBottomNavBar(
      currentIndex: _currentIndex,
      onTap: _onItemSelected,
    );
  }
}
