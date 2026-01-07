import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_empoderate/src/components/premium_scaffold.dart';
import 'package:proyecto_empoderate/src/components/neon_widgets.dart';
import '../../../navigation/app_routes.dart';

class AccountingManagerialScreen extends StatelessWidget {
  const AccountingManagerialScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Contabilidad Gerencial',
      isNeonTitle: true,
      showBackButton: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- HEADER DISCLAIMER ---
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blueAccent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Contenido educativo para la toma de decisiones. No reemplaza asesoría profesional.',
                      style: GoogleFonts.outfit(color: Colors.blueAccent[100], fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            // --- MODULES ---
            _buildModule(
              context,
              title: 'A) Fundamentos y propósito',
              description: 'Entiende la base de las finanzas de tu negocio.',
              whatIs: 'El lenguaje de los negocios para registrar y analizar transacciones.',
              utility: [
                'Tomar decisiones basadas en datos reales.',
                'Cumplir con obligaciones legales y fiscales.',
                'Medir la salud financiera de tu empresa.'
              ],
              commonErrors: [
                'Mezclar finanzas personales con las del negocio.',
                'No registrar gastos pequeños ("gastos hormiga").'
              ],
              tools: [
                _ToolLink('Presupuestos', AppRoutes.budget),
                _ToolLink('Impuestos', AppRoutes.taxEstimator),
              ],
            ),

            _buildModule(
              context,
              title: 'B) Planificación y presupuesto',
              description: 'Define tus metas y controla tus recursos.',
              whatIs: 'La hoja de ruta financiera para un periodo determinado.',
              utility: [
                'Prever ingresos y gastos futuros.',
                'Evitar sorpresas y falta de liquidez.',
                'Asignar recursos a lo que realmente importa.'
              ],
              commonErrors: [
                'Hacer un presupuesto y no revisarlo nunca.',
                'Ser demasiado optimista con los ingresos.'
              ],
              tools: [
                _ToolLink('Presupuesto 50/30/20', AppRoutes.budget),
                _ToolLink('Flujo de Caja', AppRoutes.cashFlow),
              ],
            ),

            _buildModule(
              context,
              title: 'C) Gestión de costos avanzada',
              description: 'Optimiza gastos y maximiza beneficios.',
              whatIs: 'Análisis detallado de costos fijos y variables.',
              utility: [
                'Identificar dónde se va el dinero.',
                'Calcular correctamente el precio de venta.',
                'Encontrar el punto donde empiezas a ganar.'
              ],
              commonErrors: [
                'Ignorar los costos fijos al poner precios.',
                'Confundir costo variable con gasto fijo.'
              ],
              tools: [
                _ToolLink('Costos Fijos', AppRoutes.fixedCosts),
                _ToolLink('Punto de Equilibrio', AppRoutes.puntoEquilibrio),
                _ToolLink('Margen', AppRoutes.margenGanancia),
              ],
            ),

            _buildModule(
              context,
              title: 'D) KPIs y control de desempeño',
              description: 'Mide lo que importa para mejorar.',
              whatIs: 'Indicadores Clave de Desempeño Financiero.',
              utility: [
                'Evaluar la rentabilidad real.',
                'Monitorear la liquidez inmediata.',
                'Detectar tendencias negativas a tiempo.'
              ],
              commonErrors: [
                'Medir demasiadas cosas irrelevantes.',
                'Mirar los KPIs solo cuando hay crisis.'
              ],
              tools: [
                _ToolLink('Flujo de Caja', AppRoutes.cashFlow),
                _ToolLink('Margen', AppRoutes.margenGanancia),
              ],
            ),

            _buildModule(
              context,
              title: 'E) ERP y automatización',
              description: 'Sistematiza tu gestión para crecer.',
              whatIs: 'Software para integrar operaciones (Enterprise Resource Planning).',
              utility: [
                'Ahorrar tiempo en tareas repetitivas.',
                'Reducir errores humanos en registros.',
                'Tener información integrada en tiempo real.'
              ],
              commonErrors: [
                'Implementar un sistema complejo sin procesos claros.',
                'No capacitar al equipo en el uso del software.'
              ],
              customAction: _ERPAction(
                label: 'Ver checklist de implementación',
                onTap: () => _showERPChecklist(context),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildModule(
    BuildContext context, {
    required String title,
    required String description,
    required String whatIs,
    required List<String> utility,
    required List<String> commonErrors,
    List<_ToolLink>? tools,
    _ERPAction? customAction,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          collapsedIconColor: const Color(0xFFD4AF37),
          iconColor: const Color(0xFFD4AF37),
          title: Text(
            title,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            description,
            style: GoogleFonts.outfit(color: Colors.white54, fontSize: 13),
          ),
          childrenPadding: const EdgeInsets.all(20),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('¿Qué es?'),
                Text(whatIs, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 16),

                _buildSectionTitle('¿Para qué sirve?'),
                ...utility.map((e) => _buildBullet(e)),
                const SizedBox(height: 16),

                _buildSectionTitle('Errores comunes'),
                ...commonErrors.map((e) => _buildBullet(e, color: Colors.redAccent)),
                const SizedBox(height: 20),

                if (tools != null || customAction != null) ...[
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 12),
                  Text(
                    'Herramientas Recomendadas:',
                    style: GoogleFonts.outfit(color: const Color(0xFFD4AF37), fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      if (tools != null)
                        ...tools.map((tool) => _buildToolChip(context, tool)),
                      if (customAction != null)
                        _buildActionChip(context, customAction),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Widget _buildBullet(String text, {Color color = Colors.white70}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            height: 4,
            width: 4,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: GoogleFonts.outfit(color: color, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildToolChip(BuildContext context, _ToolLink tool) {
    return ActionChip(
      backgroundColor: Colors.white.withOpacity(0.05),
      side: BorderSide(color: const Color(0xFFD4AF37).withOpacity(0.3)),
      avatar: const Icon(Icons.calculate_outlined, color: Color(0xFFD4AF37), size: 16),
      label: Text(tool.name, style: GoogleFonts.outfit(color: Colors.white, fontSize: 12)),
      onPressed: () => Navigator.pushNamed(context, tool.route),
    );
  }

  Widget _buildActionChip(BuildContext context, _ERPAction action) {
    return ActionChip(
      backgroundColor: Colors.blueAccent.withOpacity(0.1),
      side: BorderSide(color: Colors.blueAccent.withOpacity(0.3)),
      avatar: const Icon(Icons.check_circle_outline, color: Colors.blueAccent, size: 16),
      label: Text(action.label, style: GoogleFonts.outfit(color: Colors.white, fontSize: 12)),
      onPressed: action.onTap,
    );
  }

  void _showERPChecklist(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Checklist: Implementación ERP',
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDialogItem('Definir procesos actuales claramente.'),
            _buildDialogItem('Listar requerimientos (¿Qué necesito?).'),
            _buildDialogItem('Presupuestar costo de licencia + implementación.'),
            _buildDialogItem('Designar un líder de proyecto interno.'),
            _buildDialogItem('Planificar migración de datos (limpieza).'),
            _buildDialogItem('Capacitar al personal antes del "Go Live".'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: NeonButton(
                text: 'Cerrar',
                onTap: () => Navigator.pop(context),
                primary: true,
                color: const Color(0xFFD4AF37),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildDialogItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.check_box_outline_blank, color: Colors.grey, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: GoogleFonts.outfit(color: Colors.white70))),
        ],
      ),
    );
  }
}

class _ToolLink {
  final String name;
  final String route;
  _ToolLink(this.name, this.route);
}

class _ERPAction {
  final String label;
  final VoidCallback onTap;
  _ERPAction({required this.label, required this.onTap});
}
