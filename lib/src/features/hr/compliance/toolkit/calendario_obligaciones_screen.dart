import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../components/premium_scaffold.dart';
import '../../../../ui/theme/empoderate_theme.dart';
import '../../../rrhh/obligaciones/services/obligaciones_updates_service.dart';
import '../../../rrhh/obligaciones/data/obligaciones_update_models.dart';

class CalendarioObligacionesScreen extends StatefulWidget {
  const CalendarioObligacionesScreen({super.key});

  @override
  State<CalendarioObligacionesScreen> createState() => _CalendarioObligacionesScreenState();
}

class _CalendarioObligacionesScreenState extends State<CalendarioObligacionesScreen> {
  final ObligacionesUpdatesService _service = ObligacionesUpdatesService();
  
  ObligacionesModuleUpdate? _moduleData;
  bool _isLoading = true;
  bool _isOffline = false;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadModule();
  }

  Future<void> _loadModule() async {
    final data = await _service.getModule('calendario');
    final offline = await _service.isUsingOfflineContent();
    await _service.markModuleSeen('calendario', data.version);
    
    setState(() {
      _moduleData = data;
      _isLoading = false;
      _isOffline = offline;
    });
  }

  Future<void> _onRefresh() async {
    setState(() => _isRefreshing = true);
    await _service.forceRefresh();
    await _loadModule();
    setState(() => _isRefreshing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Contenido actualizado')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Calendario RRHH',
      isNeonTitle: true,
      showBackButton: true,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildVersionHeader(),
                  const SizedBox(height: 16),
                  if (_isOffline) _buildOfflineBanner(),
                  Text('Fechas límite críticas para evitar multas', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 24),
                  _buildSummarySection(),
                  const SizedBox(height: 24),
                  _buildCalendarSection(),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Herramientas'),
                  const SizedBox(height: 12),
                  _buildTools(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildVersionHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(Icons.verified, color: EmpoderateTheme.gold, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Versión: ${_moduleData?.version ?? 'N/A'} • Revisado: ${_moduleData?.lastReviewed ?? 'N/A'}',
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ),
          _isRefreshing
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : IconButton(
                  icon: const Icon(Icons.refresh, size: 18),
                  color: EmpoderateTheme.gold,
                  onPressed: _onRefresh,
                  tooltip: 'Actualizar ahora',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
        ],
      ),
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: const [
          Icon(Icons.cloud_off, color: Colors.orange, size: 18),
          SizedBox(width: 8),
          Expanded(child: Text('Modo offline: usando contenido base', style: TextStyle(color: Colors.orange, fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: EmpoderateTheme.gold, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Resumen', style: GoogleFonts.outfit(color: EmpoderateTheme.gold, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Text(_moduleData?.summary ?? '', style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 12),
          ...(_moduleData?.keyPoints ?? []).map((point) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle, color: Colors.greenAccent, size: 14),
                const SizedBox(width: 8),
                Expanded(child: Text(point, style: const TextStyle(color: Colors.white60, fontSize: 12))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: GoogleFonts.outfit(color: EmpoderateTheme.gold, fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget _buildCalendarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMonthSection('Mensual (Recurrente)', [
          _buildEventTile(day: '20', title: 'Planilla SIPE', desc: 'Fecha límite para presentación.', color: Colors.blueAccent),
          _buildEventTile(day: '30', title: 'Pago CSS', desc: 'Fecha límite de pago.', color: Colors.lightBlueAccent),
        ]),
        const SizedBox(height: 24),
        _buildMonthSection('Abril', [
          _buildEventTile(day: '15', title: 'Décimo - Primera Partida', desc: 'Meses Dic-Abr.', color: Colors.amber),
        ]),
        const SizedBox(height: 24),
        _buildMonthSection('Agosto', [
          _buildEventTile(day: '15', title: 'Décimo - Segunda Partida', desc: 'Meses Abr-Ago.', color: Colors.amber),
        ]),
        const SizedBox(height: 24),
        _buildMonthSection('Diciembre', [
          _buildEventTile(day: '15', title: 'Décimo - Tercera Partida', desc: 'Meses Ago-Dic.', color: Colors.amber),
        ]),
      ],
    );
  }

  Widget _buildMonthSection(String month, List<Widget> events) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(20)),
          child: Text(month, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
        const SizedBox(height: 12),
        ...events,
      ],
    );
  }

  Widget _buildEventTile({required String day, required String title, required String desc, required Color color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            alignment: Alignment.center,
            child: Column(
              children: [
                Text(day, style: GoogleFonts.outfit(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
                const Text('DÍA', style: TextStyle(color: Colors.white38, fontSize: 8)),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: Colors.white10, margin: const EdgeInsets.symmetric(horizontal: 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                Text(desc, style: const TextStyle(color: Colors.white60, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTools() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton('Añadir Recordatorios', Icons.notification_add, Colors.purpleAccent, () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recordatorios añadidos a tu calendario')));
          }),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton('Calc. Décimo', Icons.calculate, Colors.amber, () => context.push('/decimo_calculator')),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.2),
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.5)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}
