import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../components/premium_scaffold.dart';
import '../components/icon_gold.dart';
import '../navigation/app_routes.dart';
import 'calculators/liquidacion_screen.dart';
import 'calculators/accounting/accounting_screen.dart';
import '../components/premium_placeholders.dart';
import '../components/legal_shielding.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/info_button.dart';
import 'package:go_router/go_router.dart';
import '../components/neon_widgets.dart';

class CalculadorasScreen extends StatefulWidget {
  const CalculadorasScreen({Key? key}) : super(key: key);

  @override
  State<CalculadorasScreen> createState() => _CalculadorasScreenState();
}

class _CalculadorasScreenState extends State<CalculadorasScreen> {


  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Centro de Calculadoras',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Herramientas para cálculos clave de tu negocio',
              style: GoogleFonts.outfit(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),

            // --- PLANILLA ---
            _buildCalculatorCard(
              context,
              title: 'Liquidación Laboral Completa',
              description: 'Renuncia, despido, mutuo acuerdo, prima, décimo y vacaciones.',
              icon: Icons.gavel,
              route: AppRoutes.liquidacion,
              color: Colors.teal,
            ),
            const SizedBox(height: 16),
            _buildCalculatorCard(
              context,
              title: 'Calculadora de Salario y Planilla',
              description: 'Estima salario neto, deducciones y costos de planilla.',
              icon: Icons.people_alt_outlined,
              route: AppRoutes.salarioNeto,
              color: Colors.teal,
            ),
            const SizedBox(height: 16),
            _buildCalculatorCard(
              context,
              title: 'Comparador de Periodos',
              description: 'Analiza cambios y variaciones entre planillas.',
              icon: Icons.compare_arrows,
              route: '/period_comparison',
              color: kNeonCyan,
            ),
            const SizedBox(height: 16),
            _buildCalculatorCard(
              context,
              title: 'Costos Fijos (Overhead)',
              description: 'Calcula tus gastos operativos recurrentes.',
              icon: Icons.business,
              route: AppRoutes.fixedCosts,
              color: const Color(0xFF9575CD), // Purple
            ),

            const SizedBox(height: 24),
            Text('CONTABILIDAD', style: GoogleFonts.outfit(color: const Color(0xFFD4AF37), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 16),

            // --- CONTABILIDAD (Individual Cards) ---
            _buildCalculatorCard(
              context,
              title: 'Punto de Equilibrio',
              description: '¿Cuánto debo vender para no perder dinero?',
              icon: Icons.balance,
              route: AppRoutes.puntoEquilibrio,
              color: const Color(0xFFBA68C8), // Lila
            ),
            const SizedBox(height: 16),
            _buildCalculatorCard(
              context,
              title: 'Margen de Ganancia',
              description: 'Calcula el precio de venta rentable.',
              icon: Icons.attach_money,
              route: AppRoutes.margenGanancia,
              color: const Color(0xFF4DB6AC), // Teal
            ),
            const SizedBox(height: 16),
            _buildCalculatorCard(
              context,
              title: 'Presupuesto 50/30/20',
              description: 'Distribuye tus ingresos: necesidades, deseos, ahorro.',
              icon: Icons.pie_chart_outline,
              route: AppRoutes.budget,
              color: const Color(0xFFAED581), // Green
            ),
            const SizedBox(height: 16),
            _buildCalculatorCard(
              context,
              title: 'Flujo de Caja',
              description: 'Monitorea entradas y salidas de dinero.',
              icon: Icons.waves,
              route: AppRoutes.cashFlow,
              color: const Color(0xFF4DD0E1), // Cyan
            ),
            const SizedBox(height: 16),
            _buildCalculatorCard(
              context,
              title: 'Estimador de Impuestos',
              description: 'Anticipa cuánto pagarás de ITBMS y Renta.',
              icon: Icons.account_balance,
              route: AppRoutes.taxEstimator,
              color: const Color(0xFFE57373), // Red
            ),
            const SizedBox(height: 16),
            _buildCalculatorCard(
              context,
              title: 'ITBMS Rápido',
              description: 'Calcula el 7% de ITBMS fácilmente.',
              icon: Icons.percent,
              route: AppRoutes.itbms,
              color: const Color(0xFFFFB74D), // Orange
            ),
            const SizedBox(height: 16),
            _buildCalculatorCard(
              context,
              title: 'Préstamo / Cuota',
              description: 'Simula tu letra mensual de financiamiento.',
              icon: Icons.account_balance_wallet,
              route: AppRoutes.prestamo,
              color: const Color(0xFF90CAF9), // Blue
            ),
            const SizedBox(height: 24),
            const LegalShielding(type: ShieldType.calculators),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculatorCard(BuildContext context, {required String title, required String description, required IconData icon, String? route, VoidCallback? onTapOverride, Color color = Colors.teal}) {
    return NeonWideCard(
      borderColor: color,
      backgroundColor: const Color(0xFF001A1A),
      onTap: onTapOverride ?? () {
        if (route != null) {
          context.push(route);
        } else {
          context.push('/calculator_placeholder?title=${Uri.encodeComponent(title)}&description=${Uri.encodeComponent(description)}');
        }
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.outfit(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 16),
        ],
      ),
    );
  }
}
