import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../ui/theme/empoderate_theme.dart';
import '../components/premium_scaffold.dart';

/// Wrapper reutilizable para pantallas con carga de datos asíncrona.
/// Previene pantallas negras al manejar todos los estados posibles:
/// - Loading: muestra spinner + texto
/// - Error: muestra mensaje + botón reintentar
/// - Empty: muestra estado vacío premium
/// - Content: muestra el contenido real
class SafeAsyncScreen<T> extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Future<T> Function() futureBuilder;
  final Widget Function(BuildContext context, T data) builder;
  final bool Function(T data)? emptyCheck;
  final String? emptyMessage;
  final String? emptyIcon;
  final VoidCallback? onEmptyAction;
  final String? emptyActionLabel;
  final bool showBackButton;
  final Widget? floatingActionButton;

  const SafeAsyncScreen({
    Key? key,
    required this.title,
    this.subtitle,
    required this.futureBuilder,
    required this.builder,
    this.emptyCheck,
    this.emptyMessage,
    this.emptyIcon,
    this.onEmptyAction,
    this.emptyActionLabel,
    this.showBackButton = true,
    this.floatingActionButton,
  }) : super(key: key);

  @override
  State<SafeAsyncScreen<T>> createState() => _SafeAsyncScreenState<T>();
}

class _SafeAsyncScreenState<T> extends State<SafeAsyncScreen<T>> {
  late Future<T> _future;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _future = widget.futureBuilder();
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: widget.title,
      subtitle: widget.subtitle,
      showBackButton: widget.showBackButton,
      useScroll: false,
      usePadding: false,
      floatingActionButton: widget.floatingActionButton,
      body: FutureBuilder<T>(
        future: _future,
        builder: (context, snapshot) {
          // ESTADO 1: LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          // ESTADO 2: ERROR
          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          // ESTADO 3: NO DATA (null)
          if (!snapshot.hasData) {
            return _buildEmptyState('No se encontraron datos');
          }

          final data = snapshot.data!;

          // ESTADO 4: EMPTY (custom check)
          if (widget.emptyCheck != null && widget.emptyCheck!(data)) {
            return _buildEmptyState(
              widget.emptyMessage ?? 'No hay información disponible',
            );
          }

          // ESTADO 5: CONTENT
          return widget.builder(context, data);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(EmpoderateTheme.cyanAccent),
          ),
          const SizedBox(height: 24),
          Text(
            'Cargando...',
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.redAccent.withOpacity(0.7),
            ),
            const SizedBox(height: 24),
            Text(
              'Error al cargar',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error.length > 200 ? '${error.substring(0, 200)}...' : error,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: Colors.white60,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh, color: Colors.black),
              label: Text(
                'Reintentar',
                style: GoogleFonts.outfit(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: EmpoderateTheme.goldStrong,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getEmptyIcon(),
              size: 80,
              color: Colors.white24,
            ),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: Colors.white54,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (widget.onEmptyAction != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: widget.onEmptyAction,
                icon: const Icon(Icons.add, color: Colors.black),
                label: Text(
                  widget.emptyActionLabel ?? 'Agregar',
                  style: GoogleFonts.outfit(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: EmpoderateTheme.cyanAccent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getEmptyIcon() {
    switch (widget.emptyIcon) {
      case 'folder':
        return Icons.folder_open;
      case 'people':
        return Icons.people_outline;
      case 'document':
        return Icons.description_outlined;
      case 'calendar':
        return Icons.event_note;
      default:
        return Icons.inbox_outlined;
    }
  }
}
