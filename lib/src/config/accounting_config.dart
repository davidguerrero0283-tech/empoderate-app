import 'package:flutter/material.dart';
import '../navigation/app_routes.dart';

enum AccountingCategory { main, extra }

class AccountingToolConfig {
  final String id;
  final String title;
  final String description;
  final String route;
  final IconData icon;
  final Color color;
  final AccountingCategory category;
  /// Order in the learning/execution path (1 = first step)
  final int order;
  /// Contextual tip explaining WHY this tool matters
  final String? contextTip;
  /// ID of the recommended next tool after completing this one
  final String? nextStepId;
  /// Label for the action button (e.g., "Calcular", "Analizar", "Iniciar")
  final String actionLabel;

  const AccountingToolConfig({
    required this.id,
    required this.title,
    required this.description,
    required this.route,
    required this.icon,
    required this.color,
    required this.category,
    this.order = 99, // Default to end of list
    this.contextTip,
    this.nextStepId,
    this.actionLabel = 'Abrir',
  });
}

// Centralized List of Accounting Tools - Ordered Sequentially
final List<AccountingToolConfig> accountingTools = [
  // --- MAIN TOOLS (Strategic Path) ---
  // STEP 1: Understand your costs first
  const AccountingToolConfig(
    id: 'fixed_costs',
    title: '1. Costos Fijos',
    description: 'Conoce cuánto te cuesta operar antes de vender un solo producto.',
    route: AppRoutes.fixedCosts,
    icon: Icons.business,
    color: Color(0xFF9575CD), // Deep Purple
    category: AccountingCategory.main,
    order: 1,
    contextTip: '¿Por qué empezar aquí? Porque si no conoces tus costos, no sabes si realmente ganas o pierdes.',
    nextStepId: 'break_even',
    actionLabel: 'CALCULAR COSTOS',
  ),
  // STEP 2: Find your break-even point
  const AccountingToolConfig(
    id: 'break_even',
    title: '2. Punto de Equilibrio',
    description: 'Descubre cuánto debes vender para cubrir todos tus gastos.',
    route: AppRoutes.puntoEquilibrio,
    icon: Icons.balance,
    color: Color(0xFFBA68C8), // Purple
    category: AccountingCategory.main,
    order: 2,
    contextTip: 'Una vez que conoces tus costos, puedes calcular el mínimo de ventas para no perder dinero.',
    nextStepId: 'margin',
    actionLabel: 'ENCONTRAR EQUILIBRIO',
  ),
  // STEP 3: Set your margins
  const AccountingToolConfig(
    id: 'margin',
    title: '3. Margen de Ganancia',
    description: 'Define el precio de venta que te deje ganancia real.',
    route: AppRoutes.margenGanancia,
    icon: Icons.attach_money,
    color: Color(0xFF4DB6AC), // Teal
    category: AccountingCategory.main,
    order: 3,
    contextTip: 'Ahora que sabes tu equilibrio, puedes definir precios que generen ganancia, no solo sobrevivencia.',
    nextStepId: 'budget',
    actionLabel: 'CALCULAR MARGEN',
  ),
  // STEP 4: Plan your budget
  const AccountingToolConfig(
    id: 'budget',
    title: '4. Presupuesto 50/30/20',
    description: 'Distribuye tus ingresos: necesidades, deseos y ahorro.',
    route: AppRoutes.budget,
    icon: Icons.pie_chart_outline,
    color: Color(0xFFAED581), // Green
    category: AccountingCategory.main,
    order: 4,
    contextTip: 'Con ganancia proyectada, ahora planifica cómo distribuir ese dinero sabiamente.',
    nextStepId: 'cash_flow',
    actionLabel: 'CREAR PRESUPUESTO',
  ),
  // STEP 5: Monitor cash flow
  const AccountingToolConfig(
    id: 'cash_flow',
    title: '5. Flujo de Caja',
    description: 'Monitorea entradas y salidas: ¿te sobra o falta dinero?',
    route: AppRoutes.cashFlow,
    icon: Icons.waves,
    color: Color(0xFF4DD0E1), // Cyan
    category: AccountingCategory.main,
    order: 5,
    contextTip: 'Este es el latido de tu negocio. Revísalo mensualmente para anticipar problemas.',
    nextStepId: 'tax_estimator',
    actionLabel: 'VER FLUJO',
  ),
  // STEP 6: Estimate taxes
  const AccountingToolConfig(
    id: 'tax_estimator',
    title: '6. Estimador de Impuestos',
    description: 'Anticipa cuánto deberás pagar de ITBMS y Renta.',
    route: AppRoutes.taxEstimator,
    icon: Icons.account_balance,
    color: Color(0xFFE57373), // Red/Pink
    category: AccountingCategory.main,
    order: 6,
    contextTip: 'Evita sorpresas fiscales. Provisiona desde ahora para no descapitalizarte.',
    nextStepId: null, // End of main path
    actionLabel: 'ESTIMAR IMPUESTOS',
  ),

  // --- EXTRA TOOLS (Quick Utilities) ---
  const AccountingToolConfig(
    id: 'itbms',
    title: 'ITBMS Rápido',
    description: 'Calcula el 7% de ITBMS fácilmente',
    route: AppRoutes.itbms,
    icon: Icons.percent,
    color: Color(0xFFFFB74D), // Orange
    category: AccountingCategory.extra,
    order: 10,
    actionLabel: 'CALCULAR',
  ),
  const AccountingToolConfig(
    id: 'loan',
    title: 'Préstamo / Cuota',
    description: 'Simula tu letra mensual de financiamiento.',
    route: AppRoutes.prestamo,
    icon: Icons.account_balance_wallet,
    color: Color(0xFF90CAF9), // Blue
    category: AccountingCategory.extra,
    order: 11,
    actionLabel: 'SIMULAR',
  ),
  const AccountingToolConfig(
    id: 'salary',
    title: 'Salario Neto',
    description: 'Calcula deducciones de SS y SE.',
    route: AppRoutes.salarioNeto,
    icon: Icons.person_outline,
    color: Color(0xFF64B5F6), // Light Blue
    category: AccountingCategory.extra,
    order: 12,
    actionLabel: 'CALCULAR',
  ),
  const AccountingToolConfig(
    id: 'liquidation',
    title: 'Liquidación Laboral',
    description: 'Calcula prestaciones por terminación (aprox).',
    route: AppRoutes.liquidacion,
    icon: Icons.exit_to_app,
    color: Color(0xFFE57373), // Red
    category: AccountingCategory.extra,
    order: 13,
    actionLabel: 'CALCULAR',
  ),
];

/// Get the next recommended tool by ID
AccountingToolConfig? getNextTool(String currentId) {
  final current = accountingTools.firstWhere((t) => t.id == currentId, orElse: () => accountingTools.first);
  if (current.nextStepId == null) return null;
  return accountingTools.firstWhere((t) => t.id == current.nextStepId, orElse: () => accountingTools.first);
}
