import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../ui/theme/empoderate_theme.dart';
import '../components/premium_scaffold.dart';
import '../models/business_data.dart';
import '../data/repositories/checklist_repository.dart';
import 'package:go_router/go_router.dart';
import 'business_rubro_detail_screen.dart';

class NicheConfirmationScreen extends StatefulWidget {
  final IndustryCategory category;
  final BusinessRubro rubro;

  const NicheConfirmationScreen({
    Key? key,
    required this.category,
    required this.rubro,
  }) : super(key: key);

  @override
  State<NicheConfirmationScreen> createState() => _NicheConfirmationScreenState();
}

class _NicheConfirmationScreenState extends State<NicheConfirmationScreen> {
  bool _isLoading = false;
  bool _alreadySelected = false;

  @override
  void initState() {
    super.initState();
    _checkCurrentStatus();
  }

  Future<void> _checkCurrentStatus() async {
    final repo = ChecklistRepository();
    try {
      final item = repo.currentItems.firstWhere((i) => i.id == 'start_1_rubro', orElse: () => throw 'Item not found');
      if (item.done) {
        setState(() => _alreadySelected = true);
      }
    } catch (_) {}
  }

  Future<void> _handleConfirm() async {
    setState(() => _isLoading = true);

    // 1. Mark as Done
    final repo = ChecklistRepository();
    try {
      // If NOT already done, mark it.
      // If already done (Switching), strictly speaking we don't need to mark it again, 
      // but calling toggle off then on or just leaving it is fine. 
      // The requirement was just "automatic check".
      
      final item = repo.currentItems.firstWhere((i) => i.id == 'start_1_rubro', orElse: () => throw 'Item not found');
      if (!item.done) {
        await repo.toggleItemDone('start_1_rubro');
      }
      // If already done, we keep it done. 
      // (Optional: We could log a "niche_switched" event here).

    } catch (e) {
      // Fail safe
      await repo.toggleItemDone('start_1_rubro');
    }

    // Small delay for effect
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    
    // 2. Navigate (Replace so they can't go back to confirmation easily)
    context.go('/mi_negocio_rubro/category/${widget.category.id}/rubro/${widget.rubro.id}/detail');
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'CONFIRMA TU CAMINO',
      showBackButton: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning if switching
            if (_alreadySelected)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Ya tienes un rubro seleccionado. Cambiarlo podría afectar tu progreso actual.',
                        style: GoogleFonts.outfit(color: Colors.orange[100], fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

            Text(
              '¿Deseas escoger este rubro?',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Al confirmar, iniciaremos tu plan de trabajo personalizado.',
              style: GoogleFonts.outfit(color: Colors.white60, fontSize: 14),
            ),
            const SizedBox(height: 30),

            // Hero Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0F1520),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(color: const Color(0xFFD4AF37).withOpacity(0.1), blurRadius: 20, spreadRadius: 0),
                ],
              ),
              child: Column(
                children: [
                  Icon(widget.category.icon, size: 48, color: const Color(0xFFD4AF37)),
                  const SizedBox(height: 16),
                  Text(
                    widget.category.name.toUpperCase(),
                    style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.rubro.name,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Recomendado',
                      style: GoogleFonts.outfit(color: const Color(0xFFD4AF37), fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Next Steps
            Text('PRÓXIMOS PASOS:', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            _buildNextStep('1', 'Checklist de Trámites', 'Generaremos la lista de permisos municipales y sanitarios para ${widget.rubro.name}.'),
            _buildNextStep('2', 'Plan de Negocio', 'Validaremos tu idea y modelo de ingresos.'),
            _buildNextStep('3', 'Formalización', 'Te guiaremos paso a paso para legalizar tu empresa.'),

            const SizedBox(height: 40),

            // Buttons
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isLoading 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                  : Text(
                      _alreadySelected ? 'CAMBIAR Y COMENZAR' : 'CONFIRMAR Y COMENZAR',
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => context.pop(),
                child: Text('Elegir otro', style: GoogleFonts.outfit(color: Colors.white54)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextStep(String number, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28, height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
            ),
            child: Text(number, style: GoogleFonts.outfit(color: const Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(desc, style: GoogleFonts.outfit(color: Colors.white60, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
