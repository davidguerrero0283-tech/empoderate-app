import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_empoderate/ui/components/header/premium_header.dart';
import 'dart:typed_data';
import 'dart:convert';
import '../components/gradient_background.dart';
import '../navigation/app_routes.dart';
import '../services/business_service.dart';
import 'business_profile_components.dart';
import 'business_profile_models.dart';

class BusinessProfileReviewScreen extends StatefulWidget {
  const BusinessProfileReviewScreen({Key? key}) : super(key: key);

  @override
  State<BusinessProfileReviewScreen> createState() => _BusinessProfileReviewScreenState();
}

class _BusinessProfileReviewScreenState extends State<BusinessProfileReviewScreen> {
  BusinessProfile? _profile;
  Uint8List? _logoBytes;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await BusinessService().getProfile();
    if (mounted) {
      setState(() {
        _profile = profile;
        _isLoading = false;
        
        // Decode logo if exists
        if (profile?.logoBase64 != null && profile!.logoBase64!.isNotEmpty) {
          try {
            _logoBytes = base64Decode(profile.logoBase64!);
          } catch (e) {
            _logoBytes = null;
          }
        }
      });
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
            : _profile == null
                ? _buildEmptyState()
                : _buildProfileContent(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_outlined,
              size: 80,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'No hay perfil registrado',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Aún no has creado tu perfil de negocio.\nToca el botón de abajo para empezar.',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.businessProfileForm),
              icon: const Icon(Icons.add),
              label: Text(
                'Crear Perfil',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: const Color(0xFF001B3A),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tu Negocio',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Logo section
          if (_logoBytes != null) ...[
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD4AF37), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Image.memory(_logoBytes!, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          // Profile data
          BusinessDataCard(
            label: 'Nombre Comercial',
            value: _profile!.nombre.isNotEmpty ? _profile!.nombre : 'No especificado',
          ),
          if (_profile!.ruc.isNotEmpty)
            BusinessDataCard(
              label: 'RUC / Cédula',
              value: _profile!.ruc,
            ),
          if (_profile!.website != null && _profile!.website!.isNotEmpty)
            BusinessDataCard(
              label: 'Sitio Web',
              value: _profile!.website!,
            ),
          BusinessDataCard(
            label: 'Rubro Principal',
            value: _profile!.rubro,
          ),
          if (_profile!.actividad.isNotEmpty)
            BusinessDataCard(
              label: 'Actividad Económica',
              value: _profile!.actividad,
            ),
          BusinessDataCard(
            label: 'Fecha de Inicio',
            value: '${_profile!.fechaInicio.day.toString().padLeft(2, '0')}/${_profile!.fechaInicio.month.toString().padLeft(2, '0')}/${_profile!.fechaInicio.year}',
          ),
          if (_profile!.municipio.isNotEmpty)
            BusinessDataCard(
              label: 'Municipio / Ubicación',
              value: _profile!.municipio,
            ),
          BusinessDataCard(
            label: 'Régimen Fiscal',
            value: _profile!.regimenFiscal,
          ),
          BusinessDataCard(
            label: 'Tipo de Facturación',
            value: _profile!.tipoFacturacion,
          ),
          BusinessDataCard(
            label: 'Frecuencia de Declaraciones',
            value: _profile!.frecuenciaDeclaraciones,
          ),
          
          const SizedBox(height: 32),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.businessProfileForm),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFD4AF37)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Editar',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFD4AF37),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.reminders),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Ver recordatorios',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF001B3A),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
