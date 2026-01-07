import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/theme_manager.dart'; // Import ThemeManager
import '../components/premium_scaffold.dart';
import '../components/neon_widgets.dart';
import 'legal_text_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends StatefulWidget {
  final String? initialSection;
  const SettingsScreen({Key? key, this.initialSection}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _legalSectionKey = GlobalKey();
  
  // Settings state
  bool _notificationsEnabled = true;
  bool _marketingNotifications = false;
  bool _soundEnabled = true;
  String _appVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
    
    if (widget.initialSection == 'legales') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToLegal();
      });
    }
  }
  
  Future<void> _loadAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = packageInfo.version;
      });
    } catch (e) {
      // If package_info fails, keep default version
    }
  }
  
  void _scrollToLegal() {
     if (_legalSectionKey.currentContext != null) {
       Scrollable.ensureVisible(
         _legalSectionKey.currentContext!, 
         duration: const Duration(milliseconds: 500), 
         curve: Curves.easeInOut
       );
     }
  }

  Future<void> _toggleTheme(bool value) async {
    await ThemeManager.instance.toggleTheme(value);
  }
  
  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF001225),
        title: Text('Limpiar Caché', style: GoogleFonts.outfit(color: const Color(0xFFF4D35E))),
        content: Text(
          '¿Estás seguro de que deseas limpiar la caché? Esto puede mejorar el rendimiento pero eliminará datos temporales.',
          style: GoogleFonts.outfit(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: GoogleFonts.outfit(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Caché limpiada exitosamente', style: GoogleFonts.outfit()),
                  backgroundColor: const Color(0xFFF4D35E),
                ),
              );
            },
            child: Text('Limpiar', style: GoogleFonts.outfit(color: const Color(0xFFF4D35E))),
          ),
        ],
      ),
    );
  }
  
  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exportando datos...', style: GoogleFonts.outfit()),
        backgroundColor: const Color(0xFF001225),
      ),
    );
  }

  void _openLegalPage(String type) {
    String title = '';
    String content = '';

    switch (type) {
      case 'aviso':
        title = 'Aviso Legal';
        content = '''INFORMACIÓN GENERAL

EMPODÉRATE es una plataforma digital diseñada para ayudar a emprendedores y pequeñas empresas en Panamá a gestionar sus operaciones de manera eficiente.

TITULAR DE LA APLICACIÓN
Esta aplicación es desarrollada y mantenida como un proyecto independiente. Los datos procesados se almacenan localmente en tu dispositivo para garantizar tu privacidad.

OBJETO
La aplicación EMPODÉRATE tiene como objetivo proporcionar herramientas de gestión empresarial, calculadoras laborales, recursos educativos y asistencia mediante inteligencia artificial para facilitar la toma de decisiones informadas.

RESPONSABILIDAD
La información proporcionada en esta aplicación tiene carácter informativo y educativo. No constituye asesoría legal, contable o financiera profesional. Para decisiones críticas de negocio, se recomienda consultar con profesionales certificados.

EXACTITUD DE LA INFORMACIÓN
Nos esforzamos por mantener la información actualizada y precisa. Sin embargo, las leyes y regulaciones pueden cambiar. El usuario es responsable de verificar la información con fuentes oficiales cuando sea necesario.

PROPIEDAD INTELECTUAL
Todos los contenidos, diseños, código y materiales de EMPODÉRATE están protegidos por derechos de autor. El uso de la aplicación no otorga ningún derecho de propiedad sobre estos elementos.

MODIFICACIONES
Nos reservamos el derecho de modificar este aviso legal en cualquier momento. Los cambios serán notificados dentro de la aplicación.

CONTACTO
Para consultas o sugerencias, puedes contactarnos a través de los canales oficiales de la aplicación.

Última actualización: Diciembre 2025''';
        break;
      case 'terminos':
        title = 'Términos y Condiciones';
        content = '''TÉRMINOS Y CONDICIONES DE USO

Al utilizar EMPODÉRATE, aceptas los siguientes términos y condiciones:

1. ACEPTACIÓN DE TÉRMINOS
Al descargar, instalar o usar esta aplicación, confirmas que has leído, entendido y aceptado estos términos en su totalidad.

2. USO PERMITIDO
EMPODÉRATE está diseñada para:
• Gestionar información de tu negocio
• Calcular nóminas y liquidaciones laborales
• Acceder a recursos educativos sobre emprendimiento
• Utilizar herramientas de planificación empresarial
• Consultar con asistentes de IA especializados

3. USO PROHIBIDO
No está permitido:
• Usar la aplicación para fines ilegales
• Intentar acceder a código fuente o realizar ingeniería inversa
• Distribuir o comercializar la aplicación sin autorización
• Usar la aplicación para dañar a terceros
• Sobrecargar los servicios mediante uso automatizado

4. PRIVACIDAD Y DATOS
• Tus datos se almacenan localmente en tu dispositivo
• No compartimos tu información personal con terceros
• Eres responsable de mantener copias de seguridad de tu información
• Consulta nuestra Política de Privacidad para más detalles

5. CALCULADORAS LABORALES
Las calculadoras de salario y liquidación:
• Se basan en la legislación laboral panameña vigente
• Proporcionan estimaciones informativas
• No sustituyen el cálculo oficial de un contador o abogado
• Pueden requerir verificación para casos especiales

6. CONTENIDO GENERADO POR IA
Los asistentes de inteligencia artificial:
• Proporcionan sugerencias y orientación general
• No constituyen asesoría profesional certificada
• Pueden cometer errores o proporcionar información incompleta
• Deben usarse como complemento, no como única fuente

7. DISPONIBILIDAD DEL SERVICIO
Nos esforzamos por mantener la aplicación disponible, pero no garantizamos:
• Funcionamiento ininterrumpido
• Ausencia total de errores
• Compatibilidad con todas las versiones de sistemas operativos

8. LIMITACIÓN DE RESPONSABILIDAD
EMPODÉRATE no se hace responsable de:
• Decisiones tomadas basándose únicamente en la información de la app
• Pérdidas económicas derivadas del uso de las herramientas
• Errores en cálculos o información proporcionada
• Problemas técnicos o pérdida de datos

9. ACTUALIZACIONES
Podemos actualizar la aplicación para:
• Mejorar funcionalidades
• Corregir errores
• Actualizar información legal
• Añadir nuevas características

10. TERMINACIÓN
Nos reservamos el derecho de suspender o terminar el acceso a la aplicación en caso de violación de estos términos.

11. MODIFICACIONES
Estos términos pueden modificarse. Los cambios importantes serán notificados en la aplicación.

12. LEY APLICABLE
Estos términos se rigen por las leyes de la República de Panamá.

Al continuar usando EMPODÉRATE, confirmas tu aceptación de estos términos.

Última actualización: Diciembre 2025''';
        break;
      case 'privacidad':
        title = 'Política de Privacidad';
        content = '''POLÍTICA DE PRIVACIDAD

En EMPODÉRATE, tu privacidad es nuestra prioridad. Esta política explica cómo manejamos tu información.

1. INFORMACIÓN QUE RECOPILAMOS

DATOS LOCALES
• Información de tu negocio (nombre, rubro, datos fiscales)
• Perfiles de empleados que crees
• Cálculos de nómina y liquidaciones
• Documentos y archivos en la Bóveda Digital
• Tareas y agenda de trámites
• Preferencias de la aplicación

DATOS DE USO
• Estadísticas anónimas de uso de funciones
• Registro de errores para mejorar la aplicación
• Preferencias de configuración

2. CÓMO USAMOS TU INFORMACIÓN

• ALMACENAMIENTO LOCAL: Todos tus datos empresariales y personales se guardan únicamente en tu dispositivo
• MEJORA DEL SERVICIO: Datos anónimos de uso nos ayudan a mejorar funcionalidades
• PERSONALIZACIÓN: Tus preferencias se usan para adaptar la experiencia
• SOPORTE: Información de errores nos ayuda a resolver problemas

3. COMPARTIR INFORMACIÓN

NO COMPARTIMOS:
• Datos de tu negocio
• Información de empleados
• Documentos personales
• Cálculos financieros

SERVICIOS DE TERCEROS:
• Google Fonts para tipografías
• Servicios de IA para asistentes virtuales (solo consultas, no datos sensibles)
• Analytics anónimo para mejorar la app

4. SEGURIDAD DE DATOS

MEDIDAS DE PROTECCIÓN:
• Almacenamiento local encriptado
• No transmisión de datos sensibles a servidores externos
• Acceso protegido a funciones críticas
• Recomendamos usar contraseña en tu dispositivo

TU RESPONSABILIDAD:
• Mantener tu dispositivo seguro
• Realizar copias de seguridad periódicas
• No compartir acceso a tu dispositivo con personas no autorizadas

5. BÓVEDA DIGITAL

Los documentos que subas a la Bóveda Digital:
• Se almacenan localmente en tu dispositivo
• No se sincronizan con la nube automáticamente
• Son accesibles solo desde tu dispositivo
• Puedes eliminarlos en cualquier momento

6. CALCULADORAS Y DATOS LABORALES

• Los datos de empleados se guardan localmente
• Los cálculos se procesan en tu dispositivo
• No enviamos información salarial a servidores externos
• Puedes exportar o eliminar estos datos cuando desees

7. INTELIGENCIA ARTIFICIAL

Cuando usas los asistentes de IA:
• Las consultas pueden procesarse en servicios externos
• No incluimos datos sensibles en las consultas
• Las respuestas son generales y no se vinculan a tu identidad
• No almacenamos historial de conversaciones en servidores

8. COOKIES Y TECNOLOGÍAS SIMILARES

• Usamos almacenamiento local para preferencias
• No usamos cookies de seguimiento
• No compartimos datos con redes publicitarias

9. TUS DERECHOS

Tienes derecho a:
• ACCEDER a todos tus datos almacenados
• MODIFICAR o actualizar tu información
• ELIMINAR tus datos en cualquier momento
• EXPORTAR tu información
• RECHAZAR funciones opcionales

10. DATOS DE MENORES

EMPODÉRATE está diseñada para uso empresarial por personas mayores de 18 años. No recopilamos intencionalmente datos de menores.

11. CAMBIOS EN ESTA POLÍTICA

Podemos actualizar esta política para:
• Reflejar cambios en la aplicación
• Cumplir con nuevas regulaciones
• Mejorar la claridad y transparencia

Te notificaremos sobre cambios importantes.

12. RETENCIÓN DE DATOS

• Los datos se mantienen mientras uses la aplicación
• Puedes eliminar datos en cualquier momento
• Al desinstalar la app, los datos locales se eliminan

13. TRANSFERENCIA INTERNACIONAL

Como los datos se almacenan localmente, no hay transferencia internacional de información personal.

14. CONTACTO

Para consultas sobre privacidad o ejercer tus derechos, contáctanos a través de los canales oficiales de la aplicación.

COMPROMISO

Nos comprometemos a proteger tu privacidad y manejar tu información con total transparencia y respeto.

Última actualización: Diciembre 2025''';
        break;
    }

    context.push('/settings/legal_text?title=${Uri.encodeComponent(title)}&content=${Uri.encodeComponent(content)}');
  }

  @override
  Widget build(BuildContext context) {
    // Listen to ThemeManager updates
    return AnimatedBuilder(
      animation: ThemeManager.instance,
      builder: (context, _) {
        final isDarkMode = ThemeManager.instance.isDarkMode;

        return PremiumScaffold(
          title: 'AJUSTES',
          showBackButton: true,
          body: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // APPEARANCE SECTION
                _buildSectionTitle('Apariencia'),
                NeonCard(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      SwitchListTile(
                        activeColor: const Color(0xFFF4D35E),
                        title: Text('Cambiar a tema claro', style: GoogleFonts.outfit(color: Colors.white)),
                        subtitle: Text('Activa para usar el tema claro', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
                        value: !isDarkMode, // Inverted - switch ON = light theme
                        onChanged: (value) => _toggleTheme(!value), // Invert the value
                      ),
                    ],
                  ),
                ),
                
                // NOTIFICATIONS SECTION
                _buildSectionTitle('Notificaciones'),
                NeonCard(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      SwitchListTile(
                        activeColor: const Color(0xFFF4D35E),
                        title: Text('Notificaciones', style: GoogleFonts.outfit(color: Colors.white)),
                        subtitle: Text('Recibe alertas y recordatorios', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
                        value: _notificationsEnabled,
                        onChanged: (v) => setState(() => _notificationsEnabled = v),
                      ),
                      SwitchListTile(
                        activeColor: const Color(0xFFF4D35E),
                        title: Text('Sonido', style: GoogleFonts.outfit(color: Colors.white)),
                        subtitle: Text('Reproducir sonido en notificaciones', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
                        value: _soundEnabled,
                        onChanged: (v) => setState(() => _soundEnabled = v),
                      ),
                      SwitchListTile(
                        activeColor: const Color(0xFFF4D35E),
                        title: Text('Consejos y sugerencias', style: GoogleFonts.outfit(color: Colors.white)),
                        subtitle: Text('Recibe tips para mejorar tu negocio', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
                        value: _marketingNotifications,
                        onChanged: (v) => setState(() => _marketingNotifications = v),
                      ),
                    ],
                  ),
                ),

                // DATA MANAGEMENT SECTION
                _buildSectionTitle('Gestión de Datos'),
                NeonCard(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.download_outlined, color: Color(0xFFF4D35E)),
                        title: Text('Exportar datos', style: GoogleFonts.outfit(color: Colors.white)),
                        subtitle: Text('Descarga una copia de tu información', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
                        trailing: const Icon(Icons.chevron_right, color: Colors.white30),
                        onTap: _exportData,
                      ),
                      const Divider(color: Colors.white10, height: 1),
                      ListTile(
                        leading: const Icon(Icons.cleaning_services_outlined, color: Colors.orangeAccent),
                        title: Text('Limpiar caché', style: GoogleFonts.outfit(color: Colors.white)),
                        subtitle: Text('Libera espacio eliminando archivos temporales', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
                        trailing: const Icon(Icons.chevron_right, color: Colors.white30),
                        onTap: _clearCache,
                      ),
                    ],
                  ),
                ),

                // LEGAL SECTION
                Container(
                   key: _legalSectionKey,
                   child: _buildSectionTitle('Legal'),
                ),
                NeonCard(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      _buildLegalTile('Aviso Legal', Icons.description_outlined, 'aviso'),
                      const Divider(color: Colors.white10, height: 1),
                      _buildLegalTile('Términos y Condiciones', Icons.gavel_outlined, 'terminos'),
                      const Divider(color: Colors.white10, height: 1),
                      _buildLegalTile('Política de Privacidad', Icons.privacy_tip_outlined, 'privacidad'),
                    ],
                  ),
                ),
                
                // HELP & SUPPORT SECTION
                _buildSectionTitle('Ayuda y Soporte'),
                NeonCard(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.help_outline, color: Color(0xFFF4D35E)),
                        title: Text('Centro de ayuda', style: GoogleFonts.outfit(color: Colors.white)),
                        subtitle: Text('Preguntas frecuentes y tutoriales', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
                        trailing: const Icon(Icons.chevron_right, color: Colors.white30),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Centro de ayuda próximamente', style: GoogleFonts.outfit())),
                          );
                        },
                      ),
                      const Divider(color: Colors.white10, height: 1),
                      ListTile(
                        leading: const Icon(Icons.feedback_outlined, color: Color(0xFFF4D35E)),
                        title: Text('Enviar comentarios', style: GoogleFonts.outfit(color: Colors.white)),
                        subtitle: Text('Comparte tus sugerencias', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
                        trailing: const Icon(Icons.chevron_right, color: Colors.white30),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gracias por tu interés en mejorar EMPODÉRATE', style: GoogleFonts.outfit())),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                // ABOUT SECTION
                _buildSectionTitle('Acerca de'),
                NeonCard(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.info_outline, color: Color(0xFFF4D35E)),
                        title: Text('Versión', style: GoogleFonts.outfit(color: Colors.white)),
                        subtitle: Text(_appVersion, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
                      ),
                      const Divider(color: Colors.white10, height: 1),
                      ListTile(
                        title: Text('EMPODÉRATE', style: GoogleFonts.outfit(color: const Color(0xFFF4D35E), fontWeight: FontWeight.bold)),
                        subtitle: Text('Tu aliado para gestionar y hacer crecer tu negocio', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                Center(
                  child: Text(
                    'Hecho con ❤️ para emprendedores panameños',
                    style: GoogleFonts.outfit(color: Colors.white30, fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.outfit(
          color: const Color(0xFFF4D35E),
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildLegalTile(String title, IconData icon, String type) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: GoogleFonts.outfit(color: Colors.white)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white30),
      onTap: () => _openLegalPage(type),
    );
  }
}
