import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_empoderate/src/components/premium_scaffold.dart';
import 'package:proyecto_empoderate/src/components/neon_widgets.dart';
import 'package:proyecto_empoderate/src/features/marketing/marketing_service.dart';
import 'package:proyecto_empoderate/src/components/premium_pink_neon_accordion.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/repositories/checklist_repository.dart';

class MarketingAvatarScreen extends StatefulWidget {
  const MarketingAvatarScreen({Key? key}) : super(key: key);

  @override
  State<MarketingAvatarScreen> createState() => _MarketingAvatarScreenState();
}

class _MarketingAvatarScreenState extends State<MarketingAvatarScreen> {
  final _ageCtrl = TextEditingController();
  final _genderCtrl = TextEditingController();
  final _interestsCtrl = TextEditingController();
  
  bool _isLoading = false;
  Map<String, dynamic>? _profile;
  final _service = MarketingService();

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Cliente Ideal (Avatar)',
      isNeonTitle: true,
      showBackButton: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 60),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // 1. EDUCATIONAL INTRO
            _buildIntroSection(),
            const SizedBox(height: 24),
            
            // 2. STEP-BY-STEP GUIDE
            _buildGuideSection(),
            const SizedBox(height: 32),

            // 3. GENERATOR TOOL
            const NeonSectionTitle(title: 'Generador Automático', color: Colors.cyanAccent),
            const SizedBox(height: 16),
            _buildAvatarForm(),
            
            const SizedBox(height: 30),
            if (_isLoading)
              const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
            else if (_profile != null)
              _buildResults()
            else
              _buildPlaceholder(),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF151C2B).withOpacity(0.40),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.cyanAccent.withOpacity(0.1),
                ),
                child: const Icon(Icons.psychology, color: Colors.cyanAccent, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¿Qué es un "Avatar" de Cliente?',
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'No puedes venderle a "todo el mundo". Un Avatar es una representación ficticia de tu comprador perfecto. Entenderlo te permite crear mensajes que conecten emocionalmente y vendan más.',
                      style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGuideSection() {
    return PremiumPinkNeonAccordion(
      title: "Guía Paso a Paso para Definirlo",
      content: Column(
        children: [
          _buildGuideStep(
            '1', 
            'Datos Demográficos', 
            'Define quién es: Edad, género, ubicación, profesión, estado civil. Esto te dice DÓNDE encontrarlo.'
          ),
          _buildGuideStep(
            '2', 
            'Puntos de Dolor (Pain Points)', 
            '¿Qué le quita el sueño? ¿Qué problema urgente necesita resolver? Aquí es donde ocurre la venta.'
          ),
          _buildGuideStep(
            '3', 
            'Deseos y Transformación', 
            '¿En quién se quiere convertir? Tu producto no es el fin, es el vehículo para esa transformación.'
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.cyanAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.cyanAccent, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Usa la herramienta de abajo 👇 para que la IA genere un perfil base por ti en segundos.',
                    style: GoogleFonts.outfit(color: Colors.cyanAccent, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildGuideStep(String number, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24, height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white10,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
            child: Text(number, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                Text(desc, style: GoogleFonts.outfit(color: Colors.white60, fontSize: 12, height: 1.3)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAvatarForm() {
    return NeonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: NeonInput(
                  label: 'Edad Aprox.',
                  controller: _ageCtrl,
                  hint: 'Ej. 25-34',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NeonInput(
                  label: 'Género',
                  controller: _genderCtrl,
                  hint: 'Ej. Mujeres, Hombres...',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          NeonInput(
            label: 'Intereses / Nicho',
            controller: _interestsCtrl,
            hint: 'Ej. Moda sostenible, Fitness casero, Tecnología...',
          ),
          const SizedBox(height: 24),
          NeonButton(
            text: "Generar Perfil con IA",
            icon: Icons.person_search,
            color: Colors.cyanAccent,
            textColor: Colors.black,
            onTap: _generate,
          )
        ],
      ),
    );
  }

  Future<void> _generate() async {
    if (_interestsCtrl.text.isEmpty) return;
    
    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    final inputs = {
      'age': _ageCtrl.text,
      'gender': _genderCtrl.text,
      'interests': _interestsCtrl.text,
    };
    
    final result = await _service.generateAvatarProfile(inputs);
    
    if (mounted) {
      setState(() {
        _profile = result;
        _isLoading = false;
        
        // SIGNAL UPDATE
        SharedPreferences.getInstance().then((prefs) {
          prefs.setBool('marketing.avatar_defined', true);
          ChecklistRepository().refresh();
        });
      });
    }
  }

  Widget _buildResults() {
    return Column(
      children: [
        const NeonSectionTitle(title: 'Perfil Generado', color: Colors.cyanAccent),
        const SizedBox(height: 10),
        
        NeonWideCard(
          borderColor: Colors.cyanAccent,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.cyanAccent.withOpacity(0.2),
                      radius: 24,
                      child: const Icon(Icons.person, color: Colors.cyanAccent),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _profile!['name'],
                            style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Resumen Ejecutivo',
                            style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    _profile!['summary'],
                    style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14, height: 1.5, fontStyle: FontStyle.italic),
                  ),
                ),
                const SizedBox(height: 20),
                _buildListSection('Dolores / Problemas', _profile!['painPoints'], Colors.redAccent, Icons.error_outline),
                const SizedBox(height: 16),
                _buildListSection('Deseos / Objetivos', _profile!['desires'], Colors.greenAccent, Icons.check_circle_outline),
                const SizedBox(height: 16),
                _buildListSection('Objeciones Comunes', _profile!['objections'], Colors.orangeAccent, Icons.help_outline),
              ],
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
  
  Widget _buildListSection(String title, List<dynamic> items, Color color, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(title, style: GoogleFonts.outfit(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 10),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Container(width: 4, height: 4, decoration: BoxDecoration(color: Colors.white30, shape: BoxShape.circle)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(item, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, height: 1.3))),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_pin_circle_outlined, size: 48, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text(
            'Completa el formulario arriba para\ngenerar tu avatar detallado',
            style: GoogleFonts.outfit(color: Colors.white38),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
