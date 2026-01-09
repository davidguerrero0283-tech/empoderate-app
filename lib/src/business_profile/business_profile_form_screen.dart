import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proyecto_empoderate/ui/components/header/premium_header.dart';
import '../components/gradient_background.dart';
import 'business_profile_components.dart';
import 'business_profile_models.dart';
import '../services/business_service.dart';
import '../services/progress_tracker_service.dart';
import '../services/achievement_notification_service.dart';

class BusinessProfileFormScreen extends StatefulWidget {
  const BusinessProfileFormScreen({Key? key}) : super(key: key);

  @override
  State<BusinessProfileFormScreen> createState() => _BusinessProfileFormScreenState();
}

class _BusinessProfileFormScreenState extends State<BusinessProfileFormScreen> {
  final _nombreController = TextEditingController();
  final _rucController = TextEditingController();
  final _websiteController = TextEditingController();
  final _actividadController = TextEditingController();
  final _municipioController = TextEditingController();
  final _fechaInicioController = TextEditingController();
  
  String? _rubro;
  String? _regimenFiscal;
  String? _tipoFacturacion;
  String? _frecuenciaDeclaraciones;
  
  // Logo state
  String? _logoBase64;
  Uint8List? _logoBytes;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await BusinessService().getProfile();
    if (profile != null) {
      setState(() {
        _nombreController.text = profile.nombre;
        _rucController.text = profile.ruc;
        _websiteController.text = profile.website ?? '';
        _actividadController.text = profile.actividad;
        _municipioController.text = profile.municipio;
        _fechaInicioController.text = "${profile.fechaInicio.day}/${profile.fechaInicio.month}/${profile.fechaInicio.year}";
        
        _rubro = profile.rubro.isNotEmpty ? profile.rubro : null;
        _regimenFiscal = profile.regimenFiscal.isNotEmpty ? profile.regimenFiscal : null;
        _tipoFacturacion = profile.tipoFacturacion.isNotEmpty ? profile.tipoFacturacion : null;
        _frecuenciaDeclaraciones = profile.frecuenciaDeclaraciones.isNotEmpty ? profile.frecuenciaDeclaraciones : null;
        
        // Load logo
        _logoBase64 = profile.logoBase64;
        if (_logoBase64 != null && _logoBase64!.isNotEmpty) {
          try {
            _logoBytes = base64Decode(_logoBase64!);
          } catch (e) {
            _logoBytes = null;
          }
        }
      });
    }
  }

  Future<void> _pickLogo() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _logoBytes = bytes;
          _logoBase64 = base64Encode(bytes);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imagen: $e'))
        );
      }
    }
  }
  
  void _removeLogo() {
    setState(() {
      _logoBytes = null;
      _logoBase64 = null;
    });
  }

  Future<void> _saveProfile() async {
    if (_nombreController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El nombre es obligatorio')));
      return;
    }

    final newProfile = BusinessProfile(
      nombre: _nombreController.text,
      ruc: _rucController.text,
      logoBase64: _logoBase64,
      website: _websiteController.text.isNotEmpty ? _websiteController.text : null,
      rubro: _rubro ?? 'Otros',
      actividad: _actividadController.text,
      fechaInicio: DateTime.now(), // Simplified parsing or keep existing if logical
      regimenFiscal: _regimenFiscal ?? 'Persona Natural',
      municipio: _municipioController.text,
      tipoFacturacion: _tipoFacturacion ?? 'Manual',
      frecuenciaDeclaraciones: _frecuenciaDeclaraciones ?? 'Mensual',
    );

    await BusinessService().saveProfile(newProfile);

    // ✨ NUEVO: Marcar progreso automáticamente
    if (_nombreController.text.isNotEmpty && _rucController.text.isNotEmpty) {
      await ProgressTrackerService.instance.markCompleted('hasBusinessProfile');
      
      // Mostrar notificación de logro
      if (mounted) {
        final achievement = AchievementNotificationService.instance.getAchievement('hasBusinessProfile');
        AchievementNotificationService.instance.showAchievement(context, achievement: achievement);
      }
    }

    // Marcar ubicación si está definida
    if (_municipioController.text.isNotEmpty) {
      await ProgressTrackerService.instance.markCompleted('hasBusinessLocation');
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil de empresa actualizado')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: PremiumHeader(showBackButton: true),
      ),
      body: GradientBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Perfil de Negocio',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Datos para tus comprobantes y trámites.',
                style: GoogleFonts.roboto(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 24),
              
              // Logo Section
              Text(
                'Logo de la Empresa',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sube el logo de tu empresa para que aparezca automáticamente en todos tus documentos',
                style: GoogleFonts.roboto(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 12),
              
              // Logo preview and buttons - Compact professional design
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo preview box - compact
                  if (_logoBytes != null) ...[
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFD4AF37), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD4AF37).withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Image.memory(_logoBytes!, fit: BoxFit.contain),
                    ),
                    const SizedBox(width: 16),
                  ],
                  // Buttons column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _pickLogo,
                          icon: const Icon(Icons.image, size: 18),
                          label: Text(
                            _logoBytes == null ? 'Seleccionar Logo' : 'Cambiar Logo',
                            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0066CC),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        if (_logoBytes != null) ...[
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: _removeLogo,
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: Text(
                              'Quitar Logo',
                              style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red[400],
                              side: BorderSide(color: Colors.red[400]!),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Informative card about logo usage
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0066CC).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF0066CC).withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF0066CC), size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¿Dónde aparecerá tu logo?',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tu logo se mostrará automáticamente en:',
                            style: GoogleFonts.roboto(color: Colors.white70, fontSize: 12),
                          ),
                          const SizedBox(height: 6),
                          _buildInfoBullet('📄 Comprobantes de pago de planilla'),
                          _buildInfoBullet('📋 Comprobantes de liquidación'),
                          _buildInfoBullet('✉️ Cartas y documentos oficiales'),
                          const SizedBox(height: 8),
                          Text(
                            'El logo se redimensiona automáticamente y se guarda con tu perfil. Puedes cambiarlo o quitarlo en cualquier momento.',
                            style: GoogleFonts.roboto(
                              color: Colors.white60,
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              BusinessInputField(
                label: 'Nombre Comercial',
                controller: _nombreController,
                placeholder: 'Ej: Panadería La Espiga Dorada',
              ),
              BusinessInputField(
                label: 'RUC / Cédula (Opcional)',
                controller: _rucController,
                placeholder: 'Ej: 12345678-1-123456',
                suffixIcon: _rucController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54, size: 18),
                        onPressed: () {
                          setState(() {
                            _rucController.clear();
                          });
                        },
                      )
                    : null,
              ),
              BusinessInputField(
                label: 'Sitio Web (Opcional)',
                controller: _websiteController,
                placeholder: 'Ej: www.mipaginaweb.com',
                keyboardType: TextInputType.url,
              ),
              BusinessDropdownField(
                label: 'Rubro Principal',
                value: _rubro,
                items: const ['Comercio', 'Servicios', 'Industria', 'Tecnología', 'Restaurante', 'Otro'],
                onChanged: (val) => setState(() => _rubro = val),
              ),
              BusinessInputField(
                label: 'Actividad Económica (Aviso)',
                controller: _actividadController,
                placeholder: 'Ej: Venta de pan y repostería',
              ),
              // ... existing fields ...
              BusinessInputField(
                label: 'Municipio / Ubicación',
                controller: _municipioController,
                placeholder: 'Ej: Panamá, Bella Vista',
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Guardar Datos',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF001B3A),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Colors.white70, fontSize: 14)),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.roboto(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
