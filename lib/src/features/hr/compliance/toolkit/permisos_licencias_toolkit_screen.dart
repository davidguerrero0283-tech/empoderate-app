import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../components/premium_scaffold.dart';
import '../../../../ui/theme/empoderate_theme.dart';
import '../../../rrhh/obligaciones/services/obligaciones_updates_service.dart';
import '../../../rrhh/obligaciones/data/obligaciones_update_models.dart';

class PermisosLicenciasToolkitScreen extends StatefulWidget {
  const PermisosLicenciasToolkitScreen({super.key});

  @override
  State<PermisosLicenciasToolkitScreen> createState() => _PermisosLicenciasToolkitScreenState();
}

class _PermisosLicenciasToolkitScreenState extends State<PermisosLicenciasToolkitScreen> {
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
    final data = await _service.getModule('permisos');
    final offline = await _service.isUsingOfflineContent();
    await _service.markModuleSeen('permisos', data.version);
    
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

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Permisos y Licencias',
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
                  _buildHeaderSection(),
                  const SizedBox(height: 24),
                  _buildSummarySection(),
                  const SizedBox(height: 24),
                  _buildLicensesSection(),
                  const SizedBox(height: 24),
                  _buildToolsGrid(),
                  const SizedBox(height: 24),
                  _buildSourcesSection(),
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

  Widget _buildHeaderSection() {
    return Text(
      'Guía oficial sobre ausencias remuneradas y derechos del trabajador según la legislación panameña actual.',
      style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
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

  Widget _buildLicensesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Licencias Comunes', style: GoogleFonts.outfit(color: EmpoderateTheme.gold, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildLicenseCard(
          title: 'Licencia de Paternidad',
          badge: 'Ley 27',
          content: '3 días hábiles remunerados para el padre, a partir del nacimiento del hijo.',
          color: Colors.blueAccent,
          icon: Icons.child_care,
        ),
        const SizedBox(height: 12),
        _buildLicenseCard(
          title: 'Lactancia Materna',
          badge: 'Ley 135',
          content: 'Tiempo para extracción de leche dentro de la jornada laboral.',
          color: Colors.pinkAccent,
          icon: Icons.baby_changing_station,
        ),
        const SizedBox(height: 12),
        _buildLicenseCard(
          title: 'Licencia de Maternidad',
          badge: 'CSS / Código',
          content: '14 semanas de descanso retribuido (6 antes y 8 después del parto).',
          color: Colors.purpleAccent,
          icon: Icons.pregnant_woman,
        ),
      ],
    );
  }

  Widget _buildLicenseCard({required String title, required String badge, required String content, required Color color, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
                      child: Text(badge, style: const TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(content, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolsGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildToolButton(
            icon: Icons.description_outlined,
            label: 'Generar Solicitud',
            color: Colors.tealAccent,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Abriendo Plantillas...'))),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildToolButton(
            icon: Icons.open_in_browser,
            label: 'Trámite CSS',
            color: Colors.blueAccent,
            onTap: () => _launchUrl('https://w3.css.gob.pa/'),
          ),
        ),
      ],
    );
  }

  Widget _buildToolButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(12),
            color: color.withOpacity(0.1),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSourcesSection() {
    final sources = _moduleData?.sources ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Fuentes Oficiales', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...sources.map((s) => _buildLinkButton(s.title, s.url)),
      ],
    );
  }

  Widget _buildLinkButton(String text, String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton.icon(
        onPressed: () => _launchUrl(url),
        icon: const Icon(Icons.link, size: 16),
        label: Text(text),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white70,
          side: const BorderSide(color: Colors.white24),
          alignment: Alignment.centerLeft,
          minimumSize: const Size(double.infinity, 40),
        ),
      ),
    );
  }
}
