import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/neon_widgets.dart';
import '../../features/system/services/system_health_service.dart';

class AdminSystemScreen extends StatefulWidget {
  const AdminSystemScreen({Key? key}) : super(key: key);

  @override
  State<AdminSystemScreen> createState() => _AdminSystemScreenState();
}

class _AdminSystemScreenState extends State<AdminSystemScreen> {
  bool _isLoading = false;
  Map<String, String> _integrityReport = {};

  @override
  void initState() {
    super.initState();
    _runIntegrityCheck();
  }

  Future<void> _runIntegrityCheck() async {
    setState(() => _isLoading = true);
    final report = await SystemHealthService.instance.checkStorageIntegrity();
    setState(() {
      _integrityReport = report;
      _isLoading = false;
    });
  }

  Future<void> _handleClearCache() async {
    setState(() => _isLoading = true);
    try {
      await SystemHealthService.instance.clearCache();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Caché y temporales eliminados correctamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleResetFlags() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Restaurar Ajustes?'),
        content: const Text('Esto activará/desactivará módulos según la configuración por defecto. ¿Continuar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Restaurar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      await SystemHealthService.instance.resetFeatureFlags();
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configuración global restaurada')),
        );
      }
    }
  }

  Future<void> _handleOptimize() async {
    setState(() => _isLoading = true);
    await SystemHealthService.instance.optimizeDatabase();
    await _runIntegrityCheck(); // Refresh report
    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Base de datos verificada y optimizada')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if any key is corrupt
    final hasIssues = _integrityReport.values.any((status) => status == 'Corrupt');
    final statusColor = hasIssues ? Colors.redAccent : Colors.greenAccent;
    final statusText = hasIssues ? 'Atención Requerida' : 'Sistema Saludable';
    final statusIcon = hasIssues ? Icons.warning_amber_rounded : Icons.check_circle;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Salud del Sistema (Real)',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),

          // Status Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [statusColor.withOpacity(0.2), statusColor.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                  child: _isLoading 
                      ? const SizedBox(width: 32, height: 32, child: CircularProgressIndicator(color: Colors.white))
                      : Icon(statusIcon, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Estado Global', style: GoogleFonts.outfit(color: statusColor, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(statusText, style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Versión local: 1.0.2-beta', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Storage Integrity Report
          const NeonSectionTitle(title: 'Integridad de Datos', color: Colors.white),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: _integrityReport.entries.map((e) => ListTile(
                dense: true,
                leading: Icon(
                  e.value == 'Healthy' ? Icons.check_circle : (e.value == 'Missing (Clean)' ? Icons.info_outline : Icons.error),
                  color: e.value == 'Healthy' ? Colors.green : (e.value == 'Missing (Clean)' ? Colors.grey : Colors.red),
                  size: 20,
                ),
                title: Text(e.key, style: const TextStyle(color: Colors.white)),
                trailing: Text(e.value, style: TextStyle(color: e.value == 'Corrupt' ? Colors.redAccent : Colors.white70)),
                onTap: e.value == 'Corrupt' ? () async {
                   // Quick repair action
                   await SystemHealthService.instance.repairKey(e.key);
                   _runIntegrityCheck();
                } : null,
              )).toList(),
            ),
          ),

          const SizedBox(height: 32),
          const NeonSectionTitle(title: 'Acciones de Mantenimiento', color: Colors.white),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: NeonButton(
                  text: 'Limpiar Caché',
                  icon: Icons.cleaning_services,
                  onTap: _isLoading ? () {} : _handleClearCache,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: NeonButton(
                  text: 'Verificar DB', // Was 'Optimizar DB'
                  icon: Icons.storage,
                  onTap: _isLoading ? () {} : _handleOptimize,
                  color: Colors.blueAccent,
                ),
              ),
               const SizedBox(width: 16),
              Expanded(
                child: NeonButton(
                  text: 'Reset Ajustes', // Was 'Reiniciar Servicios'
                  icon: Icons.restart_alt,
                  onTap: _isLoading ? () {} : _handleResetFlags,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

