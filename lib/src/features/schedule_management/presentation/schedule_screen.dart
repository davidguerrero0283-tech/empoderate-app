import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_empoderate/src/components/premium_scaffold.dart';
import 'package:proyecto_empoderate/src/components/business_hero_header.dart';
import 'package:proyecto_empoderate/src/components/neon_widgets.dart';
import 'package:proyecto_empoderate/src/features/schedule_management/logic/schedule_controller.dart';
import 'widgets/schedule_grid.dart';
import 'widgets/schedule_kpi_stats.dart';
import 'widgets/export_controls.dart';
import 'widgets/shift_management_dialog.dart';
import 'widgets/shift_change_request_dialog.dart';
import 'widgets/business_settings_dialog.dart';
import 'widgets/auto_schedule_config_dialog.dart';
import 'widgets/schedule_heatmap.dart';
import 'widgets/vacation_alert.dart';
import 'widgets/template_manager_dialog.dart';
import 'package:proyecto_empoderate/src/features/rrhh/scheduling_intelligence/models/auto_schedule_config.dart';
import 'package:proyecto_empoderate/src/features/rrhh/scheduling_intelligence/models/tuning_feedback.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ScheduleController()..initialize()..loadData()..loadChangeRequests(),
      child: const _ScheduleContent(),
    );
  }
}

class _ScheduleContent extends StatefulWidget {
  const _ScheduleContent({Key? key}) : super(key: key);

  @override
  State<_ScheduleContent> createState() => __ScheduleContentState();
}

class __ScheduleContentState extends State<_ScheduleContent> {
  bool _showHeatmap = false;

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<ScheduleController, bool>((c) => c.isLoading);

    return PremiumScaffold(
      title: 'Planificador PRO',
      subtitle: 'Horarios Semanales',
      usePadding: false,
      useScroll: false, 
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAiAssistant(context),
        icon: const Icon(Icons.auto_awesome, color: Colors.white),
        label: const Text('Asistente IA'),
        backgroundColor: Colors.purpleAccent,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // HERO HEADER
                  const BusinessHeroHeader(
                    title: 'Planificador de Horarios',
                    subtitle: 'Gestión Administrativa Simplificada',
                    icon: Icons.calendar_month,
                    color: Colors.cyanAccent,
                    isCompact: true,
                  ),
                  const SizedBox(height: 16),
                  
                  // QUICK ACTIONS (Directorio & More)
                  _buildQuickActions(context),
                  const SizedBox(height: 16),

                  // DATE NAVIGATOR (New Feature)
                  const _DateNavigator(),
                  const SizedBox(height: 16),
                  
                  // KPI STATS
                  const ScheduleKPIStats(),
                  const SizedBox(height: 16),
                  
                  // VACATION ALERT
                  Consumer<ScheduleController>(
                    builder: (context, controller, _) => VacationAlert(controller: controller),
                  ),
                  
                  // NEW: Vacation Calculator Button
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/vacation_calculator'),
                      icon: const Icon(Icons.beach_access, size: 20),
                      label: Text('CALCULAR VACACIONES', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kNeonBlue.withOpacity(0.2),
                        foregroundColor: kNeonBlue,
                        side: BorderSide(color: kNeonBlue, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // GRID (ALWAYS VISIBLE)
                  const ScheduleGrid(),
                  const SizedBox(height: 24),

                  // HEATMAP TOGGLE & SECTION
                  _buildHeatmapSection(),
                  
                  const SizedBox(height: 24),

                  // EXPORT & SAVE CONTROLS
                  const ExportControls(),
                  const SizedBox(height: 100), // Extra space for FAB
                ],
              ),
            ),
    );
  }

  Widget _buildHeatmapSection() {
    return Column(
      children: [
        // Section Header / Toggle
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  color: Colors.white10,
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: () => setState(() => _showHeatmap = !_showHeatmap),
                icon: Icon(
                  _showHeatmap ? Icons.visibility_off : Icons.visibility,
                  color: _showHeatmap ? Colors.purpleAccent : Colors.cyanAccent,
                  size: 18,
                ),
                label: Text(
                  _showHeatmap ? 'Ocultar Mapa de Calor' : 'Ver Mapa de Calor',
                  style: TextStyle(
                    color: _showHeatmap ? Colors.purpleAccent : Colors.cyanAccent,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: _showHeatmap ? Colors.purpleAccent.withOpacity(0.1) : Colors.cyanAccent.withOpacity(0.05),
                  side: BorderSide(
                    color: _showHeatmap ? Colors.purpleAccent : Colors.cyanAccent.withOpacity(0.5),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 1,
                  color: Colors.white10,
                ),
              ),
            ],
          ),
        ),
        
        if (_showHeatmap) ...[
          const SizedBox(height: 16),
          Container(
            height: 600,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2C),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purpleAccent.withOpacity(0.3)),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Análisis de Cobertura (Mapa de Calor)',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                
                // EDUCATIONAL SECTION
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.purpleAccent.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.purpleAccent.withOpacity(0.2)),
                  ),
                  child: ExpansionTile(
                    title: const Row(
                      children: [
                        Icon(Icons.help_outline, color: Colors.purpleAccent, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Guía: ¿Cómo interpretar y usar este mapa?',
                          style: TextStyle(color: Colors.purpleAccent, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    childrenPadding: const EdgeInsets.all(16),
                    children: [
                      _buildInfoItem(
                        '¿Qué es y para qué sirve?',
                        'Es una representación visual de cuántos empleados tienes trabajando en cada hora del día. Sirve para **balancear tu nómina**: evitar pagar horas extra innecesarias (muchos empleados) o perder ventas por falta de personal (pocos empleados).',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoItem(
                        '¿Cómo se usa (Código de Colores)?',
                        '• 🟢 **Verde/Azul (Baja Intensidad):** Pocos empleados. Ideal para horas "valle" o de poca venta.\n'
                        '• 🟡 **Amarillo (Media Intensidad):** Cobertura normal.\n'
                        '• 🔴 **Rojo (Alta Intensidad):** Muchos empleados simultáneamente. Útil para horas pico, pero costoso si no hay ventas.'
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('💡 Ejemplo Práctico:', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            const Text(
                              'Si tu negocio abre a las 8:00 AM y ves una casilla **ROJA** a esa hora, significa que entraron todos tus empleados al mismo tiempo. \n\n'
                              '**Sugerencia:** Escaloan los ingresos (ej: unos a las 8:00, otros a las 10:00) para tener más "fuerza" (color rojo) al mediodía cuando hay más clientes, y ahorrar dinero en la mañana.',
                              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Consumer<ScheduleController>(
                    builder: (context, controller, _) => ScheduleHeatmap(controller: controller),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoItem(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 4),
        Text(content, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.3)),
      ],
    );
  }

  void _showAiAssistant(BuildContext context) {
    final controller = context.read<ScheduleController>();
    final pendingCount = controller.pendingRequests.length;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E2C),
      isScrollControlled: true, // Allow full height if needed
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => ChangeNotifierProvider.value(
        value: controller,
        child: Consumer<ScheduleController>(
          builder: (context, controller, _) {
            final pendingCount = controller.pendingRequests.length;
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('✨ Asistente de Planificación', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text(
                        'Optimiza tu gestión de personal con herramientas inteligentes. Selecciona una opción para empezar:',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 20),
                      
                      // 1. SETUP & DEFINITION
                      _buildAiOption(Icons.settings, 'Gestionar Turnos', 'Crear, editar y eliminar turnos', () {
                        _showShiftManagement(context, controller);
                      }),
                      _buildAiOption(Icons.business, 'Configuración del Negocio', 'Días, horarios, almuerzo', () {
                        _showBusinessSettings(context, controller);
                      }),
                      
                      const Divider(color: Colors.grey),

                      // 2. REQUESTS & GENERATION (User's Logical Flow)
                      _buildAiOption(Icons.swap_horiz, 'Solicitar Cambio', 'Permisos, intercambios, incapacidades', () {
                        _showChangeRequestDialog(context, controller);
                      }),
                      
                      _buildAiOption(Icons.tune, 'Generar Personalizado (Avanzado)', 'Configurar reglas, turnos y restricciones', () async {
                        // 1. Show Configuration Dialog
                        final config = await showDialog(
                          context: context,
                          builder: (_) => AutoScheduleConfigDialog(controller: controller),
                        );

                        if (config != null) { // If not cancelled
                          // 2. Execute Generation with Config
                          await controller.autoGenerateSchedule(config: config);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Horario generado con configuración personalizada')),
                            );
                          }
                          Navigator.pop(context); // Close AI Assistant
                        }
                      }),

                      _buildAiOption(Icons.flash_on, 'Generar Automático (Rápido)', 'Crear horario con configuración estándar', () async {
                        Navigator.pop(context); // Close sheet first
                        
                        // Execute Default Generation directly
                        await controller.autoGenerateSchedule(
                          config: AutoScheduleConfig.defaultConfig(), // Ensure this factory exists or use constructor
                        );
                        
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('⚡ Horario generado automáticamente'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      }),

                      const Divider(color: Colors.grey),

                      // 3. OPTIMIZATION & TOOLS
                      _buildAiOption(Icons.lightbulb_outline, 'Ver Sugerencias', 'Optimización inteligente', () {
                        _showSuggestionsDialog(context, controller);
                      }),
                      _buildAiOption(Icons.bookmark_border, 'Plantillas de Horarios', 'Guardar y reutilizar configuraciones', () {
                        Navigator.pop(context); // Close AI Assistant first
                        _showTemplateManager(context, controller);
                      }),
                      
                      _buildAiOption(
                        Icons.pending_actions, 
                        'Solicitudes Pendientes', 
                        pendingCount > 0 ? '$pendingCount pendientes' : 'Sin solicitudes',
                        () {
                          _showPendingRequests(context, controller);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showChangeRequestDialog(BuildContext context, ScheduleController controller) {
    showDialog(
      context: context,
      builder: (_) => ShiftChangeRequestDialog(controller: controller),
    );
  }

  void _showPendingRequests(BuildContext context, ScheduleController controller) {
    showDialog(
      context: context,
      builder: (_) => PendingRequestsPanel(controller: controller),
    );
  }

  void _showBusinessSettings(BuildContext context, ScheduleController controller) {
    showDialog(
      context: context,
      builder: (_) => BusinessSettingsDialog(controller: controller),
    );
  }

  void _showTemplateManager(BuildContext context, ScheduleController controller) {
    showDialog(
      context: context,
      builder: (_) => TemplateManagerDialog(controller: controller),
    );
  }

  void _showSuggestionsDialog(BuildContext context, ScheduleController controller) {
    final suggestions = controller.getOptimizationSuggestions();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        title: const Text('💡 Sugerencias de Optimización', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          child: suggestions.isEmpty
              ? const Center(child: Text('¡Todo está optimizado!', style: TextStyle(color: Colors.green)))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: suggestions.length,
                  itemBuilder: (context, index) {
                    final s = suggestions[index];
                    return Card(
                      color: Colors.white.withOpacity(0.05),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: Icon(
                          s.isHighPriority ? Icons.priority_high : Icons.info_outline,
                          color: s.isHighPriority ? Colors.redAccent : Colors.amber,
                        ),
                        title: Text(s.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.message, style: const TextStyle(color: Colors.white70)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                if (s.explanation != null)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: OutlinedButton.icon(
                                      icon: const Icon(Icons.analytics, size: 14, color: Colors.cyanAccent),
                                      label: const Text('Ver Análisis', style: TextStyle(color: Colors.cyanAccent, fontSize: 12)),
                                      style: OutlinedButton.styleFrom(
                                        visualDensity: VisualDensity.compact,
                                        side: const BorderSide(color: Colors.cyanAccent, width: 0.5),
                                      ),
                                      onPressed: () {
                                        // Show explanation logic (same as before)
                                        final exp = s.explanation; 
                                        showDialog(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            backgroundColor: const Color(0xFF1E1E2C),
                                            title: Text(exp.summary, style: const TextStyle(color: Colors.white)),
                                            content: SizedBox(
                                              width: 300,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Impacto: ${exp.scoreChange > 0 ? '+' : ''}${exp.scoreChange} pts', 
                                                    style: TextStyle(
                                                      color: exp.scoreChange > 0 ? Colors.green : Colors.red, 
                                                      fontWeight: FontWeight.bold
                                                    )
                                                  ),
                                                  const SizedBox(height: 12),
                                                  const Text('Razones:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                                  ...exp.reasons.map<Widget>((r) => Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                                                    child: Text('• $r', style: const TextStyle(color: Colors.white70)),
                                                  )).toList(),
                                                ],
                                              ),
                                            ),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  
                                // FEEDBACK BUTTONS (Auto-Tuning)
                                IconButton(
                                  icon: const Icon(Icons.thumb_up, color: Colors.green, size: 18),
                                  tooltip: 'Aceptar (Reforzar pesos)',
                                  onPressed: () {
                                    controller.handleSuggestionAction(suggestion: s, isAccepted: true);
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gracias por tu feedback. El sistema aprenderá de esto.')));
                                  },
                                ),
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.thumb_down, color: Colors.redAccent, size: 18),
                                  tooltip: 'Rechazar (Ajustar pesos)',
                                  color: const Color(0xFF1E1E2C),
                                  onSelected: (value) {
                                    RejectionReason reason;
                                    switch(value) {
                                      case 'fairness': reason = RejectionReason.fairness; break;
                                      case 'fatigue': reason = RejectionReason.fatigue; break;
                                      case 'preference': reason = RejectionReason.preference; break;
                                      default: reason = RejectionReason.other;
                                    }
                                    controller.handleSuggestionAction(suggestion: s, isAccepted: false, rejectionReason: reason);
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sugerencia rechazada. Ajustando pesos...')));
                                  },
                                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                    const PopupMenuItem<String>(value: 'fairness', child: Text('Es injusto para otros', style: TextStyle(color: Colors.white))),
                                    const PopupMenuItem<String>(value: 'fatigue', child: Text('Genera mucha fatiga', style: TextStyle(color: Colors.white))),
                                    const PopupMenuItem<String>(value: 'preference', child: Text('Preferencia personal', style: TextStyle(color: Colors.white))),
                                    const PopupMenuItem<String>(value: 'other', child: Text('Otro motivo', style: TextStyle(color: Colors.white))),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
        ],
      ),
    );
  }

  void _showShiftManagement(BuildContext context, ScheduleController controller) {
    showDialog(
      context: context,
      builder: (_) => ShiftListDialog(controller: controller),
    );
  }

  Widget _buildAiOption(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.purpleAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: Colors.purpleAccent),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),
      onTap: onTap,
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        children: [
          // Button 1: Load All Employees
          Expanded(
            child: InkWell(
              onTap: () async {
                final controller = context.read<ScheduleController>();
                final result = await controller.loadAllEmployeesToSchedule();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result ? '✅ ${controller.workers.length} empleados cargados al horario' : '❌ Error al cargar empleados'),
                      backgroundColor: result ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2C),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.greenAccent.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.group_add, color: Colors.greenAccent, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cargar Empleados',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Agregar todos al horario',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.download, color: Colors.greenAccent, size: 16),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Button 2: Directorio
          Expanded(
            child: InkWell(
              onTap: () => context.push('/hr/employees'),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2C),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.cyanAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.people_alt_outlined, color: Colors.cyanAccent, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Directorio',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Ver perfiles',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.cyanAccent, size: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateNavigator extends StatelessWidget {
  const _DateNavigator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ScheduleController>();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.cyanAccent, size: 20),
            onPressed: () => controller.previousWeek(),
          ),
          Column(
            children: [
              Text(
                'SEMANA ACTUAL',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 10, letterSpacing: 1.5),
              ),
              const SizedBox(height: 4),
              Text(
                controller.currentWeekLabel.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white, 
                  fontSize: 16, 
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.cyanAccent, size: 20),
            onPressed: () => controller.nextWeek(),
          ),
        ],
      ),
    );
  }
}
