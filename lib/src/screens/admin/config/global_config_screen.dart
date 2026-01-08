import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../components/neon_widgets.dart';
import '../../../features/admin/visibility/visibility_service.dart';
import '../../../features/admin/visibility/app_sections_registry.dart';

class GlobalConfigScreen extends StatefulWidget {
  const GlobalConfigScreen({Key? key}) : super(key: key);

  @override
  State<GlobalConfigScreen> createState() => _GlobalConfigScreenState();
}

class _GlobalConfigScreenState extends State<GlobalConfigScreen> {
  final VisibilityService _service = VisibilityService.instance;
  bool _isLoading = true;
  String? _selectedGroup;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    setState(() => _isLoading = true);
    await _service.init();
    setState(() {
      _isLoading = false;
      // Default to first group if not set
      _selectedGroup ??= AppSectionsRegistry.groupHomeMain;
    });
  }

  Future<void> _toggleSection(String id) async {
    await _service.toggle(id);
    setState(() {}); // Rebuild to update switches
  }

  @override
  Widget build(BuildContext context) {
    // Get unique groups
    final groups = AppSectionsRegistry.allSections.map((s) => s.group).toSet().toList();

    return Scaffold(
      backgroundColor: const Color(0xFF001220),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text('Configuración Global', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () async {
              await _loadConfig();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Configuración recargada')));
            },
            tooltip: 'Recargar Configuración',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
          : Column(
              children: [
                // Group Selector (Tabs)
                Container(
                  height: 60,
                  margin: const EdgeInsets.only(bottom: 20),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      final group = groups[index];
                      final isSelected = group == _selectedGroup;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: ChoiceChip(
                          label: Text(group),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedGroup = group);
                          },
                          backgroundColor: Colors.white.withOpacity(0.05),
                          selectedColor: const Color(0xFFD4AF37),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.black : Colors.white70,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Bulk Actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                             await _service.applyMVPMode();
                             setState((){});
                             if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Modo MVP Aplicado')));
                          },
                          icon: const Icon(Icons.star, size: 16),
                          label: const Text('Aplicar MVP'),
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.tealAccent),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                             await _service.applyAllOn();
                             setState((){});
                             if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Todo Activado')));
                          },
                          icon: const Icon(Icons.visibility, size: 16),
                          label: const Text('Activar Todo'),
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.blueAccent),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),

                // Feature List
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      if (_selectedGroup != null)
                        ...AppSectionsRegistry.allSections
                            .where((s) => s.group == _selectedGroup)
                            .map((section) => _buildFeatureSwitch(section)),
                            
                      const SizedBox(height: 40),
                      
                      // Debug Info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('DEBUG INFO', style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                              'Los cambios se guardan automáticamente en SharedPreferences.\nReinicia la app si algún cambio visual no se refleja inmediatamente en el menú lateral.',
                              style: TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildFeatureSwitch(AppSection section) {
    final isVisible = _service.isVisible(section.id);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isVisible 
            ? const Color(0xFF0F172A) 
            : Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isVisible ? Colors.blueAccent.withOpacity(0.3) : Colors.red.withOpacity(0.2),
        ),
      ),
      child: SwitchListTile(
        title: Text(
          section.title,
          style: GoogleFonts.outfit(
            color: isVisible ? Colors.white : Colors.white38, 
            fontWeight: FontWeight.bold
          ),
        ),
        subtitle: Text(
          'ID: ${section.id}\n${section.description}',
          style: TextStyle(color: Colors.white38, fontSize: 12),
        ),
        value: isVisible,
        onChanged: (val) => _toggleSection(section.id),
        activeColor: const Color(0xFFD4AF37),
        secondary: Icon(
          isVisible ? Icons.visibility : Icons.visibility_off,
          color: isVisible ? const Color(0xFFD4AF37) : Colors.grey,
        ),
      ),
    );
  }
}
