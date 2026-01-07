import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:proyecto_empoderate/src/config/marketing_config.dart';
import 'package:proyecto_empoderate/src/components/premium_scaffold.dart';
import 'package:proyecto_empoderate/src/components/neon_widgets.dart';
import 'package:proyecto_empoderate/src/components/calculator_info_panel.dart';
import 'package:proyecto_empoderate/src/features/marketing/marketing_service.dart';
import 'package:go_router/go_router.dart';
import 'learning/module_guide_data.dart';

class MarketingScreen extends StatefulWidget {
  const MarketingScreen({Key? key}) : super(key: key);

  @override
  State<MarketingScreen> createState() => _MarketingScreenState();
}

class _MarketingScreenState extends State<MarketingScreen> {
  final MarketingService _service = MarketingService();
  Map<String, dynamic> _metrics = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() async {
    // Simulate loading
    await Future.delayed(const Duration(milliseconds: 500));
    final metrics = _service.getOverallMetrics();
    if (mounted) {
      setState(() {
        _metrics = metrics;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Styling constants
    final Color mainColor = const Color(0xFFD500F9); // Magenta/Violet Neon
    
    return PremiumScaffold(
      showBranding: true,
      title: 'Marketing Pro',
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFD500F9)))
        : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            
            // 1. KPI Header (Dynamic)
            _buildKpiHeader(mainColor),
            const SizedBox(height: 24),
            
            // --- NEW: EDUCATION GUIDE ---
              GestureDetector(
                onTap: () => context.push('/module_guide?type=marketing'),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ModuleGuides.marketing.themeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ModuleGuides.marketing.themeColor.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                       Container(
                         padding: const EdgeInsets.all(10),
                         decoration: BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
                         child: Icon(ModuleGuides.marketing.icon, color: ModuleGuides.marketing.themeColor, size: 24),
                       ),
                       const SizedBox(width: 16),
                       Expanded(
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text('Guía Maestra: Marketing', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                             Text('Conceptos, embudos y redes.', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
                           ],
                         ),
                       ),
                       Icon(Icons.arrow_forward_ios, color: ModuleGuides.marketing.themeColor, size: 14),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

            NeonSectionTitle(title: 'Herramientas de Crecimiento', color: mainColor),
            const SizedBox(height: 16),

            // 2. Grid Actions (Dynamic from Config)
            LayoutBuilder(
               builder: (context, constraints) {
                 // Force 2 columns on mobile, more on desktop
                 int crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
                 double spacing = 16;
                 // Calculate width safely
                 double itemWidth = (constraints.maxWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;
                 
                 return Wrap(
                   spacing: spacing,
                   runSpacing: spacing,
                   children: marketingTools.map((tool) {
                     return SizedBox(
                       width: itemWidth, 
                       child: NeonGridCard(
                          title: tool.title, 
                          subtitle: tool.subtitle, 
                          icon: tool.icon, 
                          neonColor: tool.color, 
                          onTap: () => context.push(tool.route),
                        )
                     );
                   }).toList(),
                 );
               }
            ),

            const SizedBox(height: 32),

            // 3. NEW: Educational Resources Section
            const NeonSectionTitle(title: 'Recursos Educativos', color: Color(0xFFD500F9)),
            const SizedBox(height: 16),
            
            _buildEducationalResources(),
            
            const SizedBox(height: 32),

            // 4. Metrics Benchmarks Table
            const NeonSectionTitle(title: 'Benchmarks de Métricas', color: Colors.cyanAccent),
            const SizedBox(height: 16),
            _buildMetricsBenchmarksTable(),

            const SizedBox(height: 32),

            // 5. Extended Content (Métricas de Impacto)
            NeonWideCard(
              borderColor: mainColor,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.bar_chart, color: mainColor, size: 32, shadows: [BoxShadow(color: mainColor.withOpacity(0.6), blurRadius: 8)]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tendencia de Conversiones', 
                                style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                              ),
                              Text(
                                'Últimos 30 días (Leads vs Ventas)', 
                                style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12)
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Dynamic Chart
                    SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 5,
                            getDrawingHorizontalLine: (value) => FlLine(color: Colors.white10, strokeWidth: 1),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 5,
                                reservedSize: 30,
                                getTitlesWidget: (value, meta) {
                                  return Text(value.toInt().toString(), style: GoogleFonts.outfit(color: Colors.white30, fontSize: 10));
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            // Leads Line
                            LineChartBarData(
                              spots: _service.getFunnelHistory().asMap().entries.map((e) {
                                return FlSpot(e.key.toDouble(), (e.value['leads'] as int).toDouble());
                              }).toList(),
                              isCurved: true,
                              color: Colors.cyanAccent,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [Colors.cyanAccent.withOpacity(0.3), Colors.transparent],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                            // Sales Line
                            LineChartBarData(
                              spots: _service.getFunnelHistory().asMap().entries.map((e) {
                                return FlSpot(e.key.toDouble(), (e.value['sales'] as int).toDouble());
                              }).toList(),
                              isCurved: true,
                              color: mainColor,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true, 
                                gradient: LinearGradient(
                                  colors: [mainColor.withOpacity(0.3), Colors.transparent],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLegendItem('Leads', Colors.cyanAccent),
                        const SizedBox(width: 24),
                        _buildLegendItem('Ventas', mainColor),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
    );
  }

  Widget _buildEducationalResources() {
    return Column(
      children: [
        // Social Media Presence Guide
        _buildExpandableResourceCard(
          title: 'Presencia en Redes Sociales',
          icon: Icons.share,
          color: const Color(0xFFD500F9),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Instagram: La Vitrina Visual',
                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              _buildBullet('Perfil optimizado: Bio clara con CTA, link en bio actualizado, foto profesional.'),
              _buildBullet('Contenido 70/30: 70% valor (tips, educación, entretenimiento) + 30% venta.'),
              _buildBullet('Reels diarios: Formato vertical, hook en 3 segundos, subtítulos siempre.'),
              _buildBullet('Stories interactivas: Encuestas, preguntas, "detrás de cámaras" para engagement.'),
              _buildBullet('Hashtags estratégicos: 5-10 relevantes, mezcla de populares y nicho.'),
              const SizedBox(height: 16),
              
              Text(
                'Facebook: Comunidad y Alcance Local',
                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              _buildBullet('Página de negocio completa: Horarios, ubicación, reseñas habilitadas.'),
              _buildBullet('Grupos de nicho: Crea o participa en grupos de tu industria, aporta valor.'),
              _buildBullet('Facebook Live: Transmisiones en vivo generan 6x más engagement.'),
              _buildBullet('Anuncios segmentados: Usa Ads Manager para llegar a audiencias específicas por edad, ubicación, intereses.'),
              const SizedBox(height: 16),
              
              Text(
                'TikTok: Viralidad y Tendencias',
                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              _buildBullet('Autenticidad > Producción: Videos caseros funcionan mejor que súper producidos.'),
              _buildBullet('Sigue trends: Usa audios virales y adapta a tu negocio.'),
              _buildBullet('Educa entreteniendo: "3 errores al..." o "Cómo hacer X en 30 segundos".'),
              _buildBullet('Publica 1-3 veces al día: Consistencia es clave en el algoritmo.'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // WhatsApp Sales Guide
        _buildExpandableResourceCard(
          title: 'Cómo Vender por WhatsApp',
          icon: Icons.phone_android,
          color: Colors.greenAccent,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WhatsApp es la herramienta de ventas más poderosa para PYMEs. Aquí está la estrategia completa:',
                style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 16),
              
              Text(
                '1. Configuración Profesional',
                style: GoogleFonts.outfit(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              _buildBullet('WhatsApp Business: Descarga la app empresarial (gratis).'),
              _buildBullet('Perfil completo: Logo, descripción, horario, ubicación, catálogo de productos.'),
              _buildBullet('Mensajes automáticos: Saludo inicial, mensaje de ausencia, respuestas rápidas.'),
              const SizedBox(height: 16),
              
              Text(
                '2. Estrategia de Conversación',
                style: GoogleFonts.outfit(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              _buildBullet('Responde en menos de 5 minutos: La velocidad genera confianza y cierra ventas.'),
              _buildBullet('Personaliza: Usa el nombre del cliente, recuerda conversaciones previas.'),
              _buildBullet('Vende con preguntas: "¿Para qué ocasión lo necesitas?" en vez de solo enviar precio.'),
              _buildBullet('Envía multimedia: Fotos, videos cortos del producto, notas de voz para humanizar.'),
              const SizedBox(height: 16),
              
              Text(
                '3. Cierre de Venta',
                style: GoogleFonts.outfit(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              _buildBullet('Facilita el pago: Acepta transferencias, Yappy, tarjetas. Envía datos claros.'),
              _buildBullet('Confirma el pedido: Resume lo que compraron, precio total, tiempo de entrega.'),
              _buildBullet('Seguimiento post-venta: "¿Te llegó bien?" genera recompras y reseñas.'),
              const SizedBox(height: 16),
              
              Text(
                '4. Automatización Inteligente',
                style: GoogleFonts.outfit(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              _buildBullet('Respuestas rápidas: Guarda mensajes frecuentes (precios, horarios, políticas).'),
              _buildBullet('Etiquetas: Organiza contactos (cliente nuevo, interesado, compró, VIP).'),
              _buildBullet('Listas de difusión: Envía ofertas a grupos sin crear grupos molestos.'),
              _buildBullet('Chatbots (avanzado): Herramientas como ManyChat para automatizar FAQs.'),
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb, color: Colors.amber, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Pro Tip: El 80% de ventas por WhatsApp se cierran en las primeras 3 interacciones. Sé rápido, claro y amable.',
                        style: GoogleFonts.outfit(color: Colors.amber[100], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Quick Marketing Tips
        _buildExpandableResourceCard(
          title: 'Tips Rápidos de Marketing',
          icon: Icons.tips_and_updates,
          color: Colors.orangeAccent,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTipCard('Publica a las horas pico', 'Instagram: 11am-1pm y 7pm-9pm. Facebook: 1pm-3pm. TikTok: 6am-10am y 7pm-11pm.', Icons.schedule),
              _buildTipCard('Usa llamados a la acción claros', '"Desliza arriba", "Comenta SÍ", "Envíame DM" - Dile exactamente qué hacer.', Icons.touch_app),
              _buildTipCard('Testimonios en video', 'Un cliente real hablando vale más que 100 anuncios. Pide permiso y comparte.', Icons.videocam),
              _buildTipCard('Colabora con micro-influencers', 'Mejor 10 influencers de 5k seguidores que 1 de 100k. Más engagement, menos costo.', Icons.people),
              _buildTipCard('Retargeting es oro', 'El 97% no compra la primera vez. Usa Facebook Pixel para mostrar anuncios a quienes visitaron tu sitio.', Icons.refresh),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // AI Automation for SMBs
        _buildExpandableResourceCard(
          title: 'Automatización con IA para PYMEs',
          icon: Icons.auto_awesome,
          color: Colors.purpleAccent,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'La IA ya no es solo para grandes empresas. Estas herramientas te permiten competir sin gastar fortunas:',
                style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 16),
              
              Text(
                'Creación de Contenido Automático',
                style: GoogleFonts.outfit(color: Colors.purpleAccent, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              _buildBullet('ChatGPT (Gratis/\$20/mes): Genera captions, ideas de posts, respuestas a comentarios en segundos.'),
              _buildBullet('Canva Magic Write (Gratis): Crea textos para diseños automáticamente.'),
              _buildBullet('CapCut (Gratis): Edita videos con IA, auto-subtítulos, efectos virales para TikTok/Reels.'),
              const SizedBox(height: 16),
              
              Text(
                'Programación y Publicación Automática',
                style: GoogleFonts.outfit(color: Colors.purpleAccent, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              _buildBullet('Meta Business Suite (Gratis): Programa posts en Instagram y Facebook desde un solo lugar.'),
              _buildBullet('Buffer (Gratis hasta 3 cuentas): Programa 10 posts por cuenta, analiza rendimiento.'),
              _buildBullet('Later (Gratis): Calendario visual para Instagram, programa Stories y Reels.'),
              const SizedBox(height: 16),
              
              Text(
                'Automatización por Plataforma',
                style: GoogleFonts.outfit(color: Colors.purpleAccent, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              _buildBullet('YouTube: TubeBuddy (Gratis) optimiza títulos/tags con IA. VidIQ sugiere temas virales.'),
              _buildBullet('Instagram/TikTok: Submagic (\$20/mes) agrega subtítulos animados automáticamente.'),
              _buildBullet('Facebook: ManyChat (Gratis hasta 1000 contactos) responde mensajes automáticamente.'),
              _buildBullet('WhatsApp Business: Respuestas rápidas y mensajes automáticos (gratis, nativo).'),
              const SizedBox(height: 16),
              
              Text(
                'Análisis Inteligente',
                style: GoogleFonts.outfit(color: Colors.purpleAccent, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              _buildBullet('Meta Insights (Gratis): Ve qué posts funcionan mejor, cuándo publicar, quién es tu audiencia.'),
              _buildBullet('Google Analytics (Gratis): Rastrea de dónde vienen tus clientes, qué contenido convierte.'),
              _buildBullet('Notion AI (\$10/mes): Organiza tu calendario de contenido y genera ideas automáticamente.'),
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purpleAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purpleAccent.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb, color: Colors.purpleAccent, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Estrategia PYME: Empieza con herramientas gratis (Meta Suite, ChatGPT, CapCut). Cuando generes ingresos, invierte en 1-2 herramientas premium (\$20-50/mes). La automatización te ahorra 10+ horas semanales.',
                        style: GoogleFonts.outfit(color: Colors.purpleAccent[100], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpandableResourceCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget content,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF151C2B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent,
          expansionTileTheme: const ExpansionTileThemeData(
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor: Colors.transparent,
          ),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          title: Text(
            title,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconColor: color,
          collapsedIconColor: color.withOpacity(0.5),
          children: [content],
        ),
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFFD500F9),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(String title, String description, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.orangeAccent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.outfit(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsBenchmarksTable() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F1520),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.cyanAccent.withOpacity(0.1)),
          dataRowColor: MaterialStateProperty.all(Colors.transparent),
          columnSpacing: 24,
          headingTextStyle: GoogleFonts.outfit(
            color: Colors.cyanAccent,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          dataTextStyle: GoogleFonts.outfit(color: Colors.white70, fontSize: 12),
          columns: const [
            DataColumn(label: Text('Métrica')),
            DataColumn(label: Text('Rango Ideal')),
            DataColumn(label: Text('Promedio Industria')),
            DataColumn(label: Text('Qué Significa')),
          ],
          rows: [
            _buildMetricRow('CTR', '2-5%', '1.9%', 'Click-Through Rate'),
            _buildMetricRow('CPA', '\$10-50', '\$35', 'Costo por Adquisición'),
            _buildMetricRow('ROAS', '3x-5x', '2.8x', 'Retorno de Inversión'),
            _buildMetricRow('Conv. Rate', '2-5%', '2.35%', 'Tasa de Conversión'),
            _buildMetricRow('Engagement', '3-6%', '4.2%', 'Interacción/Seguidores'),
            _buildMetricRow('CAC', '<\$100', '\$75', 'Costo Adquirir Cliente'),
          ],
        ),
      ),
    );
  }

  DataRow _buildMetricRow(String metric, String ideal, String average, String meaning) {
    return DataRow(cells: [
      DataCell(Text(metric, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600))),
      DataCell(Text(ideal, style: GoogleFonts.outfit(color: Colors.greenAccent))),
      DataCell(Text(average)),
      DataCell(Text(meaning, style: GoogleFonts.outfit(fontSize: 11))),
    ]);
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildKpiHeader(Color color) {
    // Dynamic values
    final impressions = _metrics['totalImpressions'] ?? 0;
    final conversions = _metrics['totalConversions'] ?? 0;
    final cpa = _metrics['avgCPA'] ?? 0.0;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A0D2E), // Deep Violet bg
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 20)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildKpiItem('Alcance Total', '${(impressions/1000).toStringAsFixed(1)}k', Icons.visibility),
          Container(width: 1, height: 40, color: Colors.white10),
          _buildKpiItem('Conversiones', '$conversions', Icons.shopping_bag),
          Container(width: 1, height: 40, color: Colors.white10),
          _buildKpiItem('Costo/Conv.', '\$${cpa.toStringAsFixed(2)}', Icons.monetization_on),
        ],
      ),
    );
  }

  Widget _buildKpiItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white54, size: 20),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10)),
      ],
    );
  }
}

class _MockChartPainter extends CustomPainter {
  final Color color;
  _MockChartPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    final path = Path();
    path.moveTo(0, size.height * 0.8);
    // Draw dynamic looking wave
    path.cubicTo(
      size.width * 0.25, size.height * 0.9, 
      size.width * 0.5, size.height * 0.3, 
      size.width, size.height * 0.5
    );

    canvas.drawPath(path, paint);

    // Glow
    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    
    canvas.drawPath(path, glowPaint);
    
    // Fill
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(colors: [color.withOpacity(0.2), Colors.transparent], begin: Alignment.topCenter, end: Alignment.bottomCenter)
        .createShader(Rect.fromLTWH(0, 0, size.width, size.height));
        
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();
    
    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
