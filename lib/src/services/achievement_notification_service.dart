import 'package:flutter/material.dart';

/// Modelo de un logro/achievement para mostrar al usuario
class Achievement {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final bool isMilestone;
  
  const Achievement({
    required this.title,
    required this.message,
    this.icon = Icons.celebration,
    this.color = const Color(0xFF0066CC),
    this.isMilestone = false,
  });
}

/// Servicio singleton para mostrar notificaciones de logros al usuario.
/// Catálogo completo de mensajes personalizados por cada autoRuleKey.
class AchievementNotificationService {
  static final instance = AchievementNotificationService._();
  AchievementNotificationService._();

  /// Catálogo de logros personalizados por autoRuleKey
  static final Map<String, Achievement> _achievementCatalog = {
    // ============================================================================
    // ÁREA START (Comienza Aquí)
    // ============================================================================
    'hasRubro': Achievement(
      title: '¡Perfecto inicio!',
      message: 'Ya sabemos en qué industria operas. Tu checklist personalizado está listo.',
      icon: Icons.business_center,
      color: Color(0xFFD4AF37),
    ),
    'hasBusinessProfile': Achievement(
      title: '¡Tu negocio ahora tiene identidad!',
      message: 'Tus documentos, comprobantes y cartas mostrarán esta información.',
      icon: Icons.verified,
      color: Color(0xFF0066CC),
    ),
    'hasBusinessLocation': Achievement(
      title: '¡Ubicación registrada!',
      message: 'Tu negocio ya tiene un lugar en el mapa.',
      icon: Icons.location_on,
      color: Color(0xFF00C9FF),
    ),
    'employeesCountGt0': Achievement(
      title: '¡Tu equipo está creciendo!',
      message: 'Has registrado a tu primer colaborador. Ahora puedes generar su planilla.',
      icon: Icons.person_add,
      color: Color(0xFF4CAF50),
    ),
    'hasPayrollCalc': Achievement(
      title: '¡Documento generado!',
      message: 'Tu primer comprobante está listo. Mantén tu planilla al día.',
      icon: Icons.description,
      color: Color(0xFFFF9800),
    ),
    'rubroChecklistProgressGt0': Achievement(
      title: '¡Avanzando en requisitos!',
      message: 'Has completado parte del checklist de tu rubro.',
      icon: Icons.checklist,
    ),
    'viewedRequirements': Achievement(
      title: '¡Requisitos revisados!',
      message: 'Conoces lo que necesitas para operar legalmente.',
      icon: Icons.rule,
    ),
    'rubroRequirementsDoneGte3': Achievement(
      title: '¡3 requisitos listos!',
      message: 'Estás avanzando en tu cumplimiento legal.',
      icon: Icons.task_alt,
      color: Color(0xFF4CAF50),
    ),

    // ============================================================================
    // ÁREA PAYROLL (Planilla)
    // ============================================================================
    'employeeHasRequiredFields': Achievement(
      title: '¡Colaborador completo!',
      message: 'Cargo y salario definidos. Puedes calcular su planilla.',
      icon: Icons.badge,
    ),
    'obligationsConfigured': Achievement(
      title: '¡Configuración lista!',
      message: 'Tu mes laboral está organizado.',
      icon: Icons.settings,
      color: Color(0xFF9C27B0),
    ),
    'obligationsCountGte2ThisMonth': Achievement(
      title: '¡Obligaciones activas!',
      message: 'Estás preparando tu cumplimiento laboral.',
      icon: Icons.event_available,
      color: Color(0xFF2196F3),
    ),
    'obligationsDoneGte1ThisMonth': Achievement(
      title: '¡Primera obligación cumplida!',
      message: 'Registraste tu cumplimiento. Sigue así.',
      icon: Icons.check_circle,
      color: Color(0xFF4CAF50),
    ),
    'hasObligationEvidence': Achievement(
      title: '¡Evidencia adjuntada!',
      message: 'Tienes respaldo de tu cumplimiento.',
      icon: Icons.attach_file,
    ),
    'generatedHRDoc': Achievement(
      title: '¡Documento HR generado!',
      message: 'Contrato o carta lista para usar.',
      icon: Icons.article,
    ),

    // ============================================================================
    // ÁREA ACCOUNTING (Contabilidad)
    // ============================================================================
    'hasBudget': Achievement(
      title: '¡Presupuesto definido!',
      message: 'Metas claras para tus ingresos y gastos.',
      icon: Icons.account_balance_wallet,
      color: Color(0xFF4CAF50),
    ),
    'hasIncomeTx': Achievement(
      title: '¡Venta registrada!',
      message: 'Tu flujo de caja está tomando forma.',
      icon: Icons.trending_up,
      color: Color(0xFF4CAF50),
    ),
    'hasExpenseTx': Achievement(
      title: '¡Gasto documentado!',
      message: 'Controla cada salida de dinero.',
      icon: Icons.trending_down,
      color: Color(0xFFF44336),
    ),
    'expenseCategoriesGte3': Achievement(
      title: '¡Categorías organizadas!',
      message: 'Tus cuentas están bien estructuradas.',
      icon: Icons.category,
    ),
    'openedCashflow': Achievement(
      title: '¡Flujo analizado!',
      message: 'Conoces tu liquidez actual.',
      icon: Icons.water_drop,
      color: Color(0xFF2196F3),
    ),

    // ============================================================================
    // ÁREA MARKETING (Marketing)
    // ============================================================================
    'hasPersona': Achievement(
      title: '¡Buyer persona listo!',
      message: 'Ahora sabes a quién le vendes.',
      icon: Icons.person_pin,
      color: Color(0xFFE91E63),
    ),
    'hasOffer': Achievement(
      title: '¡Oferta definida!',
      message: 'Tu producto estrella está claro.',
      icon: Icons.local_offer,
      color: Color(0xFFFF9800),
    ),
    'openedFunnel': Achievement(
      title: '¡Embudo visualizado!',
      message: 'Tus etapas de venta están mapeadas.',
      icon: Icons.filter_alt,
      color: Color(0xFF9C27B0),
    ),
    'hasCampaign': Achievement(
      title: '¡Campaña activa!',
      message: 'Estás promocionando tu negocio.',
      icon: Icons.campaign,
      color: Color(0xFFFF5722),
    ),
  };

  /// Hitos especiales (100% en un área)
  static final Map<String, Achievement> _milestoneCatalog = {
    'start_100': Achievement(
      title: '🏆 ¡Área de Inicio Completada!',
      message: 'Tu negocio tiene bases sólidas.',
      icon: Icons.emoji_events,
      color: Color(0xFFD4AF37),
      isMilestone: true,
    ),
    'payroll_100': Achievement(
      title: '🏆 ¡Planilla Dominada!',
      message: 'Tu gestión laboral es profesional.',
      icon: Icons.emoji_events,
      color: Color(0xFF4CAF50),
      isMilestone: true,
    ),
    'accounting_100': Achievement(
      title: '🏆 ¡Contabilidad en Orden!',
      message: 'Tus números están bajo control.',
      icon: Icons.emoji_events,
      color: Color(0xFF2196F3),
      isMilestone: true,
    ),
    'marketing_100': Achievement(
      title: '🏆 ¡Marketing Activado!',
      message: 'Tu estrategia comercial está en marcha.',
      icon: Icons.emoji_events,
      color: Color(0xFFE91E63),
      isMilestone: true,
    ),
    'global_100': Achievement(
      title: '🎊 ¡FELICIDADES!',
      message: 'Has completado tu ruta de emprendimiento. Tu negocio está EMPODERADO. 💪',
      icon: Icons.celebration,
      color: Color(0xFFD4AF37),
      isMilestone: true,
    ),
  };

  /// Obtiene el achievement personalizado para un autoRuleKey.
  /// Si no existe, retorna un achievement genérico.
  Achievement getAchievement(String autoRuleKey) {
    return _achievementCatalog[autoRuleKey] ??
        Achievement(
          title: '¡Logro desbloqueado!',
          message: 'Has completado: $autoRuleKey',
          icon: Icons.star,
        );
  }

  /// Obtiene el achievement de hito (milestone).
  Achievement? getMilestone(String milestoneKey) {
    return _milestoneCatalog[milestoneKey];
  }

  /// Muestra un toast de logro en la pantalla.
  /// Se llama desde donde se marca el progreso.
  void showAchievement(
    BuildContext context, {
    required Achievement achievement,
    Duration duration = const Duration(seconds: 4),
  }) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => _AchievementToast(
        achievement: achievement,
        duration: duration,
      ),
    );

    overlay.insert(overlayEntry);

    // Auto-remove después de la duración
    Future.delayed(duration + const Duration(milliseconds: 500), () {
      overlayEntry.remove();
    });
  }

  /// Muestra una celebración de hito completo (bottom sheet).
  void showMilestoneBottomSheet(
    BuildContext context, {
    required Achievement milestone,
    required int progressPercent,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (context) => _MilestoneCelebration(
        milestone: milestone,
        progressPercent: progressPercent,
      ),
    );
  }
}

// ============================================================================
// COMPONENTES VISUALES
// ============================================================================

/// Toast animado que muestra un logro
class _AchievementToast extends StatefulWidget {
  final Achievement achievement;
  final Duration duration;

  const _AchievementToast({
    required this.achievement,
    required this.duration,
  });

  @override
  State<_AchievementToast> createState() => _AchievementToastState();
}

class _AchievementToastState extends State<_AchievementToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);

    _controller.forward();

    // Auto-dismiss animation
    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.achievement.color,
                    widget.achievement.color.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: widget.achievement.color.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    widget.achievement.icon,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.achievement.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.achievement.message,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet para celebrar hitos importantes (100%)
class _MilestoneCelebration extends StatelessWidget {
  final Achievement milestone;
  final int progressPercent;

  const _MilestoneCelebration({
    required this.milestone,
    required this.progressPercent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF001B3A),
            milestone.color.withOpacity(0.3),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            milestone.icon,
            size: 80,
            color: milestone.color,
          ),
          const SizedBox(height: 24),
          Text(
            milestone.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            milestone.message,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: milestone.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: milestone.color),
            ),
            child: Text(
              'Progreso Global: $progressPercent%',
              style: TextStyle(
                color: milestone.color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: milestone.color,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Continuar →',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
