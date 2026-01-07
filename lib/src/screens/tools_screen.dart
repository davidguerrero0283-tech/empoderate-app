import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/premium_scaffold.dart';
import '../components/legal_shielding.dart';
import '../navigation/app_routes.dart';
import 'package:go_router/go_router.dart';

// Definición de colores locales para consistencia (sería ideal importar un archivo de tema)
const Color kNeonBg = Color(0xFF0B1220);
const Color kNeonCyan = Color(0xFF00F3FF);
const Color kNeonGold = Color(0xFFF4D35E);
const Color kNeonPurple = Color(0xFFA45CFF);
const Color kNeonBlue = Color(0xFF00C9FF);
const Color kNeonPink = Color(0xFFFF4DFF);

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Herramientas Inteligentes IA',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📌 2. SUBTÍTULO & BUSCADOR
          _buildSubtitle(),
          const SizedBox(height: 16),
          const LegalShielding(type: ShieldType.ai),
          const SizedBox(height: 24),
          _buildSearchBar(),
          const SizedBox(height: 32),

          // 📌 6. SECCIÓN DESTACADA PREMIUM
          _buildPremiumBanner(),
          const SizedBox(height: 48),

          // 📌 3. CATEGORÍAS (Usando Wrap/LayoutBuilder para responsive)
          _buildCategorySection(
            context, 
            title: 'Documentos y Contratos IA', 
            color: kNeonPurple, 
            tools: [
              {'title': 'Contratos Laborales', 'desc': 'Genera contratos listos para firmar.', 'icon': Icons.description_outlined, 'route': AppRoutes.humanResources},
              {'title': 'Contratos Comerciales', 'desc': 'Acuerdos B2B y alianzas.', 'icon': Icons.business_center_outlined, 'route': AppRoutes.legal},
              {'title': 'Políticas Internas', 'desc': 'Reglamentos y normas de empresa.', 'icon': Icons.policy_outlined, 'route': AppRoutes.humanResources},
              {'title': 'Términos y Condiciones', 'desc': 'Protección legal para tu servicio.', 'icon': Icons.gavel_outlined, 'route': AppRoutes.legal},
            ]
          ),
          const SizedBox(height: 48),

          _buildCategorySection(
            context, 
            title: 'Análisis y Optimización IA', 
            color: kNeonBlue, 
            tools: [
              {'title': 'Análisis de Costos', 'desc': 'Detecta gastos innecesarios.', 'icon': Icons.analytics_outlined, 'route': AppRoutes.fixedCosts},
              {'title': 'Optimizar Precios', 'desc': 'Estrategia de pricing inteligente.', 'icon': Icons.price_check_outlined, 'route': AppRoutes.margenGanancia},
              {'title': 'Procesos y Flujos', 'desc': 'Identifica cuellos de botella.', 'icon': Icons.account_tree_outlined, 'route': AppRoutes.auditoria},
              {'title': 'Rentabilidad', 'desc': 'Proyección de ROI en segundos.', 'icon': Icons.show_chart_outlined, 'route': AppRoutes.puntoEquilibrio},
            ]
          ),
          const SizedBox(height: 48),

          _buildCategorySection(
            context, 
            title: 'Marketing y Ventas IA', 
            color: kNeonPink, 
            tools: [
              {'title': 'Contenido Redes', 'desc': 'Posts virales y calendarios.', 'icon': Icons.share_outlined, 'route': AppRoutes.marketing},
              {'title': 'Campañas Ads', 'desc': 'Copywriting para Facebook/Google.', 'icon': Icons.campaign_outlined, 'route': AppRoutes.marketing},
              {'title': 'Descripciones', 'desc': 'Textos persuasivos para productos.', 'icon': Icons.shopping_bag_outlined, 'route': AppRoutes.marketing},
              {'title': 'Asistente Logos', 'desc': 'Ideación de identidad visual.', 'icon': Icons.palette_outlined, 'route': AppRoutes.marketing}, 
            ]
          ),
          const SizedBox(height: 48),

          _buildCategorySection(
            context, 
            title: 'Asistentes Especializados', 
            color: kNeonGold, 
            tools: [
              {'title': 'RUC y DGI', 'desc': 'Asesoría fiscal en tiempo real.', 'icon': Icons.receipt_long_outlined, 'route': AppRoutes.tramites},
              {'title': 'Planillas MITRADEL', 'desc': 'Cálculos y gestión de nómina.', 'icon': Icons.badge_outlined, 'route': AppRoutes.salarioNeto},
              {'title': 'Estudios Mercado', 'desc': 'Analiza competencia y tendencias.', 'icon': Icons.radar_outlined, 'route': AppRoutes.miNegocioRubro},
            ]
          ),
          
          const SizedBox(height: 60), // Bottom padding
        ],
      ),
    );
  }

  // Header removed, managed by PremiumScaffold

  Widget _buildSubtitle() {
    return Text(
      'Automatiza procesos, genera documentos, analiza datos y obtén asesoría instantánea para tu negocio.',
      style: GoogleFonts.outfit(
        color: Colors.white.withOpacity(0.85),
        fontSize: 16,
        fontWeight: FontWeight.w300,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05), // Glass dark
        border: Border.all(color: kNeonCyan.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: kNeonCyan.withOpacity(0.1), blurRadius: 10),
        ],
      ),
      child: TextField(
        style: GoogleFonts.outfit(color: Colors.white),
        decoration: InputDecoration(
          icon: const Icon(Icons.search, color: kNeonCyan),
          hintText: 'Buscar herramienta IA...',
          hintStyle: GoogleFonts.outfit(color: Colors.white38),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildPremiumBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kNeonGold.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kNeonGold, width: 1.5),
        boxShadow: [
          BoxShadow(color: kNeonGold.withOpacity(0.1), blurRadius: 20),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kNeonGold.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.stars, color: kNeonGold, size: 32),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Funciones IA Premium',
                  style: GoogleFonts.outfit(
                    color: kNeonGold,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Automatizaciones avanzadas, documentos inteligentes y análisis profundo.',
                  style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: kNeonGold, size: 20),
        ],
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context, {required String title, required Color color, required List<Map<String, dynamic>> tools}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4, 
              height: 24, 
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 22, // H2
                fontWeight: FontWeight.w600,
                shadows: [
                  BoxShadow(color: color.withOpacity(0.4), blurRadius: 8),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            // Responsive: 3 cols (wide), 2 cols (tablet), 1 col (mobile)
            int cols = 1;
            if (constraints.maxWidth > 900) cols = 3;
            else if (constraints.maxWidth > 600) cols = 2;
            
            double spacing = 20;
            double itemWidth = (constraints.maxWidth - (spacing * (cols - 1))) / cols;
            
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: tools.map((tool) => SizedBox(
                width: itemWidth,
                child: _AIToolCard(
                  title: tool['title'],
                  desc: tool['desc'],
                  icon: tool['icon'],
                  color: color,
                  onTap: () {
                    if (tool.containsKey('route')) {
                      context.push(tool['route']);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Herramienta "${tool['title']}" en desarrollo con IA.'))
                      );
                    }
                  },
                ),
              )).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _AIToolCard extends StatefulWidget {
  final String title;
  final String desc;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AIToolCard({
    Key? key,
    required this.title,
    required this.desc,
    required this.icon,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  State<_AIToolCard> createState() => _AIToolCardState();
}

class _AIToolCardState extends State<_AIToolCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1929).withOpacity(0.8), // Dark translucent
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered ? widget.color : widget.color.withOpacity(0.3),
              width: _isHovered ? 1.5 : 1,
            ),
            boxShadow: _isHovered 
              ? [BoxShadow(color: widget.color.withOpacity(0.3), blurRadius: 15)] 
              : [BoxShadow(color: Colors.black26, blurRadius: 5)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedScale(
                scale: _isHovered ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 28),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.title,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18, // H3
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.desc,
                style: GoogleFonts.outfit(
                  color: Colors.white60,
                  fontSize: 12,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
