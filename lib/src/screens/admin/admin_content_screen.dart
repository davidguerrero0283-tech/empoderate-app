import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/neon_widgets.dart';
import '../../components/how_to_use_card.dart';

class AdminContentScreen extends StatefulWidget {
  const AdminContentScreen({Key? key}) : super(key: key);

  @override
  State<AdminContentScreen> createState() => _AdminContentScreenState();
}

class _AdminContentScreenState extends State<AdminContentScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock Data
  final Map<String, List<String>> _content = {
    'Blog': ['Introducción a Finanzas', 'Beneficios de PWA', 'Tutorial Flutter'],
    'Cursos': ['Curso Básico de Nómina', 'Masterclass Legal'],
    'Recursos': ['Calculadora XLS', 'Plantilla Contratos'],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  void _addContent() {
    // Simple mock add
    final currentTabName = _getTabName(_tabController.index);
    setState(() {
      _content[currentTabName]!.add('Nuevo borrador ${DateTime.now().minute}');
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Añadido a $currentTabName')));
  }

  String _getTabName(int index) {
    if (index == 0) return 'Blog';
    if (index == 1) return 'Cursos';
    return 'Recursos';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001220),
      appBar: AppBar(
        title: Text('Gestor de Contenido (CMS)', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFD4AF37),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Blog & Noticias'),
            Tab(text: 'Cursos'),
            Tab(text: 'Recursos'),
          ],
        ),
      ),
      body: Column(
        children: [
          // How to Use Card
          const Padding(
            padding: EdgeInsets.all(20),
            child: HowToUseCard(
              title: '¿Cómo gestionar contenido?',
              icon: Icons.article_outlined,
              accentColor: Color(0xFFD4AF37),
              steps: [
                'Navega entre las pestañas (Blog, Cursos, Recursos) para ver cada tipo de contenido.',
                'Toca el botón "Nuevo" para crear un borrador en la pestaña actual.',
                'Usa el ícono de basura para eliminar contenido existente.',
                'Los contenidos se guardan como borradores hasta que los publiques.',
              ],
            ),
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildList('Blog'),
                _buildList('Cursos'),
                _buildList('Recursos'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addContent,
        backgroundColor: const Color(0xFFD4AF37),
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text('Nuevo', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildList(String category) {
    final items = _content[category] ?? [];
    if (items.isEmpty) {
      return Center(child: Text('Sin contenido en $category', style: const TextStyle(color: Colors.white54)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: ListTile(
            leading: Icon(
              category == 'Blog' ? Icons.article : category == 'Cursos' ? Icons.school : Icons.download, 
              color: const Color(0xFFD4AF37)
            ),
            title: Text(items[index], style: GoogleFonts.outfit(color: Colors.white)),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.white24, size: 20),
              onPressed: () {
                setState(() {
                  _content[category]!.removeAt(index);
                });
              },
            ),
          ),
        );
      },
    );
  }
}
