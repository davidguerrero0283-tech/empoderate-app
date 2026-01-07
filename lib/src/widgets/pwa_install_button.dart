import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/pwa_install_service.dart';
import 'ios_install_modal.dart';

class PwaInstallButton extends StatefulWidget {
  const PwaInstallButton({Key? key}) : super(key: key);

  @override
  State<PwaInstallButton> createState() => _PwaInstallButtonState();
}

class _PwaInstallButtonState extends State<PwaInstallButton> {
  final _service = PwaInstallService();

  @override
  void initState() {
    super.initState();
    _service.init();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _service.canInstall,
      builder: (context, canInstall, child) {
        if (!canInstall) return const SizedBox.shrink();

        return Positioned(
          top: 16, // Adjust based on SafeArea or design
          right: 16,
          child: SafeArea(
            child: GestureDetector(
              onTap: () {
                if (_service.isIOS) {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const IosInstallModal(),
                  );
                } else {
                  _service.promptInstall();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _service.isIOS ? Icons.ios_share : Icons.download_rounded,
                      color: const Color(0xFF0B1220),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _service.isIOS ? 'Agregar al inicio' : 'Instalar App',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF0B1220),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
