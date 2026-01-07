import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../components/premium_scaffold.dart';
import '../../../components/neon_widgets.dart';
import '../../../components/how_to_use_card.dart';
import '../../../../ui/theme/empoderate_theme.dart';
import '../services/pendiente_service.dart';

class PendientesScreen extends StatefulWidget {
  const PendientesScreen({Key? key}) : super(key: key);

  @override
  State<PendientesScreen> createState() => _PendientesScreenState();
}

class _PendientesScreenState extends State<PendientesScreen> {
  final _service = PendienteService();
  final _controller = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initService();
  }

  Future<void> _initService() async {
    await _service.init();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _add() {
    if (_controller.text.isNotEmpty) {
      _service.add(_controller.text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'MIS PENDIENTES',
      subtitle: 'Organiza tus tareas diarias.',
      isNeonTitle: true,
      useScroll: false, // We handle our own scroll
      usePadding: false,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: EmpoderateTheme.goldStrong))
          : ListenableBuilder(
              listenable: _service,
              builder: (context, _) {
                return Column(
                  children: [
                    // Help Card: Para qué sirve
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
                      child: HowToUseCard(
                        title: '¿Para qué sirve Mis Pendientes?',
                        icon: Icons.info_outline,
                        accentColor: EmpoderateTheme.goldStrong,
                        steps: [
                          'Lleva un registro simple de tus tareas diarias del negocio.',
                          'No pierdas de vista actividades importantes.',
                          'Diferente a la Agenda de Trámites (que es para obligaciones legales).',
                          'Ideal para recordatorios rápidos como: llamar proveedor, revisar inventario.',
                        ],
                      ),
                    ),

                    // Help Card: Cómo usar
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
                      child: HowToUseCard(
                        title: '¿Cómo usar esta sección?',
                        icon: Icons.help_outline,
                        accentColor: EmpoderateTheme.cyanAccent,
                        steps: [
                          'Escribe tu tarea en el campo de texto y presiona Enter o el botón +.',
                          'Toca el checkbox para marcar una tarea como completada.',
                          'Usa el ícono de basura para eliminar tareas.',
                          'Tus pendientes se guardan automáticamente en tu dispositivo.',
                        ],
                      ),
                    ),

                    // INPUT AREA
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: NeonCard(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  hintText: 'Agregar nueva tarea...',
                                  hintStyle: TextStyle(color: Colors.white24),
                                  border: InputBorder.none,
                                ),
                                onSubmitted: (_) => _add(),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle, color: EmpoderateTheme.goldStrong),
                              onPressed: _add,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // LIST
                    Expanded(
                      child: _service.items.isEmpty
                          ? _buildEmpty()
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: _service.items.length,
                              itemBuilder: (context, index) {
                                final item = _service.items[index];
                                return _buildItem(item);
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, size: 64, color: Colors.white10),
          const SizedBox(height: 16),
          Text(
            '¡Todo al día!',
            style: GoogleFonts.outfit(color: Colors.white30, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega una tarea para comenzar',
            style: GoogleFonts.outfit(color: Colors.white24, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(PendienteModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.isCompleted ? Colors.transparent : Colors.white10,
        ),
      ),
      child: ListTile(
        leading: Checkbox(
          value: item.isCompleted,
          activeColor: EmpoderateTheme.goldStrong,
          checkColor: Colors.black,
          onChanged: (_) => _service.toggle(item.id),
        ),
        title: Text(
          item.title,
          style: GoogleFonts.outfit(
            color: item.isCompleted ? Colors.white24 : Colors.white,
            decoration: item.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.white24, size: 20),
          onPressed: () => _service.remove(item.id),
        ),
      ),
    );
  }
}
