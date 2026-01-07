import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../components/premium_scaffold.dart';
import '../components/neon_widgets.dart';

class DirectorioScreen extends StatefulWidget {
  const DirectorioScreen({Key? key}) : super(key: key);

  @override
  _DirectorioScreenState createState() => _DirectorioScreenState();
}

class _DirectorioScreenState extends State<DirectorioScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Show exit notice before opening external URLs
  Future<void> _showExitNoticeAndLaunch(String entityName, String url) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF001225),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: kNeonGold, width: 1.5)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: kNeonGold, size: 28),
            const SizedBox(width: 12),
            Text(
              'Saliendo de la App',
              style: GoogleFonts.outfit(color: kNeonGold, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          'Vas a salir de la App. Serás redirigido al sitio oficial de $entityName.\n\n'
          'La disponibilidad de esa página es responsabilidad de la entidad, no de esta aplicación.',
          style: GoogleFonts.roboto(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: GoogleFonts.outfit(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kNeonGold,
              foregroundColor: Colors.black,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text('Continuar', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (result == true) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No se pudo abrir el enlace'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  // Launch phone dialer
  Future<void> _launchPhone(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // Launch maps with coordinates
  Future<void> _launchMaps(double lat, double lng, String placeName) async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  bool _matchesSearch(String text) {
    if (_searchQuery.isEmpty) return true;
    return text.toLowerCase().contains(_searchQuery.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'DIRECTORIO DE CONTACTOS',
      subtitle: 'Entidades y servicios útiles para tu negocio',
      showBackButton: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            NeonInput(
              label: 'Buscar contacto',
              hint: 'Ej: MITRADEL, Banco, Contador...',
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
            const SizedBox(height: 24),

            // ========== CARD 1: ENTIDADES GUBERNAMENTALES ==========
            if (_matchesSearch('MITRADEL') || _matchesSearch('CSS') || _matchesSearch('DGI') || _matchesSearch('Municipio') || _searchQuery.isEmpty) ...[
              _buildSectionTitle('🏛️ ENTIDADES GUBERNAMENTALES'),
              NeonCard(
                borderColor: kNeonBlue,
                child: Column(
                  children: [
                    if (_matchesSearch('MITRADEL'))
                      _buildContactTile(
                        title: 'MITRADEL',
                        subtitle: 'Ministerio de Trabajo y Desarrollo Laboral',
                        icon: Icons.account_balance,
                        onWebTap: () => _showExitNoticeAndLaunch('MITRADEL', 'https://www.mitradel.gob.pa'),
                        onPhoneTap: () => _launchPhone('+507-504-1500'),
                        onLocationTap: () => _launchMaps(8.9936, -79.5207, 'MITRADEL Panamá'),
                      ),
                    if (_matchesSearch('CSS'))
                      _buildContactTile(
                        title: 'CSS',
                        subtitle: 'Caja de Seguro Social',
                        icon: Icons.health_and_safety,
                        onWebTap: () => _showExitNoticeAndLaunch('CSS', 'https://www.css.gob.pa'),
                        onPhoneTap: () => _launchPhone('+507-501-6000'),
                        onLocationTap: () => _launchMaps(9.0042, -79.5141, 'CSS Panamá'),
                      ),
                    if (_matchesSearch('DGI'))
                      _buildContactTile(
                        title: 'DGI',
                        subtitle: 'Dirección General de Ingresos',
                        icon: Icons.receipt_long,
                        onWebTap: () => _showExitNoticeAndLaunch('DGI', 'https://www.dgi.gob.pa'),
                        onPhoneTap: () => _launchPhone('+507-507-7070'),
                        onLocationTap: () => _launchMaps(8.9774, -79.5186, 'DGI Panamá'),
                      ),
                    if (_matchesSearch('Municipio'))
                      _buildContactTile(
                        title: 'Municipio de Panamá',
                        subtitle: 'Alcaldía de Panamá',
                        icon: Icons.location_city,
                        onWebTap: () => _showExitNoticeAndLaunch('Municipio de Panamá', 'https://www.panama.gob.pa'),
                        onPhoneTap: () => _launchPhone('+507-511-9000'),
                        onLocationTap: () => _launchMaps(8.9830, -79.5199, 'Municipio de Panamá'),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // ========== CARD 2: SERVICIOS PROFESIONALES ==========
            if (_matchesSearch('Contador') || _matchesSearch('Abogado') || _matchesSearch('Fumigación') || _searchQuery.isEmpty) ...[
              _buildSectionTitle('💼 SERVICIOS PROFESIONALES'),
              NeonCard(
                borderColor: kNeonGreen,
                child: Column(
                  children: [
                    if (_matchesSearch('Contador'))
                      _buildContactTile(
                        title: 'Contadores Certificados',
                        subtitle: 'Próximamente: Directorio de contadores recomendados',
                        icon: Icons.calculate,
                        isPlaceholder: true,
                      ),
                    if (_matchesSearch('Abogado'))
                      _buildContactTile(
                        title: 'Abogados Laborales',
                        subtitle: 'Próximamente: Directorio de abogados laborales',
                        icon: Icons.gavel,
                        isPlaceholder: true,
                      ),
                    if (_matchesSearch('Fumigación'))
                      _buildContactTile(
                        title: 'Control de Fumigación',
                        subtitle: 'Gestiona y programa fumigaciones regulares',
                        icon: Icons.pest_control,
                        onInternalTap: () {
                          // Navigate to Fumigation Tracker (if it exists)
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Módulo de Fumigación en desarrollo')),
                          );
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // ========== CARD 3: BANCA Y FINANZAS ==========
            if (_matchesSearch('Banco') || _searchQuery.isEmpty) ...[
              _buildSectionTitle('🏦 BANCA Y FINANZAS'),
              NeonCard(
                borderColor: kNeonGold,
                child: Column(
                  children: [
                    _buildContactTile(
                      title: 'Banco Nacional de Panamá',
                      subtitle: 'Créditos y servicios bancarios',
                      icon: Icons.account_balance,
                      onWebTap: () => _showExitNoticeAndLaunch('Banco Nacional', 'https://www.banconal.com.pa'),
                    ),
                    _buildContactTile(
                      title: 'Banco General',
                      subtitle: 'Soluciones financieras empresariales',
                      icon: Icons.account_balance,
                      onWebTap: () => _showExitNoticeAndLaunch('Banco General', 'https://www.bgeneral.com'),
                    ),
                    _buildContactTile(
                      title: 'Banistmo',
                      subtitle: 'Préstamos y cuentas de negocio',
                      icon: Icons.account_balance,
                      onWebTap: () => _showExitNoticeAndLaunch('Banistmo', 'https://www.banistmo.com'),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          color: kNeonGold,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildContactTile({
    required String title,
    required String subtitle,
    required IconData icon,
    VoidCallback? onWebTap,
    VoidCallback? onPhoneTap,
    VoidCallback? onLocationTap,
    VoidCallback? onInternalTap,
    bool isPlaceholder = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: kNeonGold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: kNeonGold, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.roboto(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isPlaceholder) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (onWebTap != null)
                  Expanded(
                    child: _buildActionButton(
                      label: 'Web',
                      icon: Icons.language,
                      color: kNeonBlue,
                      onTap: onWebTap,
                    ),
                  ),
                if (onWebTap != null && (onPhoneTap != null || onLocationTap != null))
                  const SizedBox(width: 8),
                if (onPhoneTap != null)
                  Expanded(
                    child: _buildActionButton(
                      label: 'Llamar',
                      icon: Icons.phone,
                      color: kNeonGreen,
                      onTap: onPhoneTap,
                    ),
                  ),
                if (onPhoneTap != null && onLocationTap != null)
                  const SizedBox(width: 8),
                if (onLocationTap != null)
                  Expanded(
                    child: _buildActionButton(
                      label: 'Ubicación',
                      icon: Icons.location_on,
                      color: Colors.redAccent,
                      onTap: onLocationTap,
                    ),
                  ),
                if (onInternalTap != null)
                  Expanded(
                    child: _buildActionButton(
                      label: 'Abrir',
                      icon: Icons.arrow_forward,
                      color: kNeonGold,
                      onTap: onInternalTap,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.roboto(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
