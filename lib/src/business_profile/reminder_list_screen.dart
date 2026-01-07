import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_empoderate/ui/components/header/premium_header.dart';
import '../components/gradient_background.dart';
import '../navigation/app_routes.dart';
import 'business_profile_models.dart';
import 'reminder_service_placeholder.dart';
import 'business_profile_components.dart';

class ReminderListScreen extends StatefulWidget {
  const ReminderListScreen({Key? key}) : super(key: key);

  @override
  State<ReminderListScreen> createState() => _ReminderListScreenState();
}

class _ReminderListScreenState extends State<ReminderListScreen> {
  final ReminderServicePlaceholder _service = ReminderServicePlaceholder();
  late List<BusinessReminder> _reminders;

  @override
  void initState() {
    super.initState();
    // Mock profile for generating reminders
    final mockProfile = BusinessProfile(
      nombre: 'Demo',
      ruc: '8-000-0000', 
      rubro: 'Servicios',
      actividad: 'Demo',
      fechaInicio: DateTime.now(),
      regimenFiscal: 'Jurídica',
      municipio: 'Panamá',
      tipoFacturacion: 'Fiscal',
      frecuenciaDeclaraciones: 'Mensual',
    );
    _reminders = _service.generarRecordatorios(mockProfile);
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
                'Recordatorios',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tus próximas obligaciones y alertas',
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _reminders.length,
                itemBuilder: (context, index) {
                  final reminder = _reminders[index];
                  return ReminderTile(
                    reminder: reminder,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.reminderDetail,
                        arguments: reminder,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
