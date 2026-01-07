import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../components/premium_scaffold.dart';
import '../../../components/neon_widgets.dart';
import '../../../features/admin/visibility/app_sections_registry.dart';
import '../../../features/admin/visibility/visibility_service.dart';

class SectionVisibilityScreen extends StatefulWidget {
  const SectionVisibilityScreen({Key? key}) : super(key: key);

  @override
  State<SectionVisibilityScreen> createState() => _SectionVisibilityScreenState();
}

class _SectionVisibilityScreenState extends State<SectionVisibilityScreen> {
  final VisibilityService _service = VisibilityService.instance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _service.init();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _toggle(String id) async {
    await _service.toggle(id);
    setState(() {}); // Refresh UI
  }

  Future<void> _applyMVP() async {
    setState(() => _isLoading = true);
    await _service.applyMVPMode();
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Modo MVP Aplicado (Solo esenciales)')));
  }

  Future<void> _applyAll() async {
    setState(() => _isLoading = true);
    await _service.applyAllOn();
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Todas las secciones visibles')));
  }

  Future<void> _restoreEssentials() async {
    setState(() => _isLoading = true);
    await _service.restoreEssentials();
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tarjetas esenciales restauradas')));
  }

  @override
  Widget build(BuildContext context) {
    // Group sections
    final sections = AppSectionsRegistry.allSections;
    final groups = <String, List<AppSection>>{};
    
    for (var s in sections) {
      if (!groups.containsKey(s.group)) {
        groups[s.group] = [];
      }
      groups[s.group]!.add(s);
    }

    return PremiumScaffold(
      title: 'Visibilidad de Secciones',
      showBackButton: true,
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (sections.isEmpty)
                     Container(
                       padding: const EdgeInsets.all(24),
                       decoration: BoxDecoration(
                         color: Colors.redAccent.withOpacity(0.1),
                         borderRadius: BorderRadius.circular(16),
                         border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                       ),
                       child: Column(
                         children: [
                           const Icon(Icons.warning_amber, color: Colors.orange, size: 48),
                           const SizedBox(height: 16),
                           Text(
                             'No se encontraron secciones registradas',
                             style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                             textAlign: TextAlign.center,
                           ),
                           const SizedBox(height: 8),
                           const Text(
                             'El registro de secciones parece estar vacío. Intenta reiniciar la app o contacta soporte.',
                             style: TextStyle(color: Colors.white54),
                             textAlign: TextAlign.center,
                           ),
                         ],
                       ),
                     ),

                  // Actions Header
                  Row(
                    children: [
                      Expanded(
                        child: NeonButton(
                          text: "Modo MVP",
                          onTap: _applyMVP,
                          color: Colors.greenAccent,
                          primary: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: NeonButton(
                          text: "Mostrar Todo",
                          onTap: _applyAll,
                          color: Colors.blueGrey,
                          primary: false,
                        ),
                      ),
                      Expanded(
                        child: NeonButton(
                          text: "Restaurar Esenciales",
                          onTap: _restoreEssentials,
                          color: Colors.amberAccent,
                          primary: false,
                          icon: Icons.restore,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Section Lists via ListView.builder for performance
                  ListView.builder(
                    shrinkWrap: true, // Needed if inside SingleChildScrollView, but better to replace SingleScrollView if list is huge. 
                    // However, we have a header above. For true lazy loading, we'd use CustomScrollView/Slivers.
                    // For now, let's keep SingleChildScrollView but optimize the children generation if possible, 
                    // OR switch to CustomScrollView. 
                    // Given the structure, just generating tiles on demand is better.
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      final entry = groups.entries.elementAt(index);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          NeonSectionTitle(title: entry.key, color: const Color(0xFFD4AF37)),
                          const SizedBox(height: 16),
                          ...entry.value.map((section) => _buildSwitchTile(section)).toList(),
                          const SizedBox(height: 24),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSwitchTile(AppSection section) {
    // Optimization: Don't rebuild if not visible? No, we need it.
    // Logic extracted to avoid inline map complexity
    final isVisible = _service.isVisible(section.id);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151C2B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isVisible ? const Color(0xFFD4AF37).withOpacity(0.5) : Colors.white10,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.title,
                  style: GoogleFonts.outfit(
                    color: isVisible ? Colors.white : Colors.white54,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  section.description,
                  style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12),
                ),
                Text(
                  'ID: ${section.id}',
                  style: GoogleFonts.robotoMono(color: Colors.white24, fontSize: 10),
                ),
              ],
            ),
          ),
          Switch(
            value: isVisible,
            activeColor: const Color(0xFFD4AF37),
            onChanged: (v) => _toggle(section.id),
          ),
        ],
      ),
    );
  }
}
