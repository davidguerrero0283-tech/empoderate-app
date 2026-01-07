import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../ui/theme/empoderate_theme.dart';
import '../components/premium_scaffold.dart';
import '../components/neon_widgets.dart';
import '../components/legal_shielding.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // State
  String _selectedMode = 'guide'; // 'guide', 'quick'
  String _selectedTopic = 'General';
  final List<String> _topics = ['General', 'Trámites', 'RRHH', 'Contabilidad', 'Marketing'];
  bool _isLoading = false;

  final List<Map<String, dynamic>> _messages = [];

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    
    setState(() {
      _messages.add({
        'isUser': true,
        'text': text,
        'time': 'Ahora',
      });
      _controller.clear();
      _isLoading = true;
    });

    _scrollToBottom();

    // Mock AI Response with "Smart" Logic
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      
      final response = _generateSmartResponse(text);
      
      setState(() {
        _isLoading = false;
        _messages.add({
          'isUser': false,
          'text': response['text'],
          'time': 'Ahora',
          'actions': response['actions'] // List of {label, route}
        });
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
        );
      }
    });
  }

  Map<String, dynamic> _generateSmartResponse(String input) {
    final lowerInput = input.toLowerCase();
    
    // Quick Mode
    if (_selectedMode == 'quick') {
      return {
        'text': 'Entendido. Según tu consulta sobre "$_selectedTopic", te recomiendo revisar nuestra base de conocimientos o usar la herramienta de búsqueda. Para una guía detallada, cambia al modo "Guía paso a paso".',
        'actions': <Map<String, String>>[]
      };
    }

    // Guide Mode (Logic based on keywords)
    if (lowerInput.contains('contrato') || _selectedTopic == 'RRHH') {
      return {
        'text': '### Guía de Contratación 🤝\n\nPara formalizar una relación laboral en Panamá, sigue estos pasos:\n\n1. **Define el tipo de contrato**: Definido, Indefinido o Por Obra.\n2. **Redacta el documento**: Debe incluir salario, horario y funciones.\n3. **Firma y Sellado**: Debes registrarlo en el MITRADEL.\n\nHe encontrado herramientas útiles para ti:',
        'actions': [
          {'label': 'Ir a RRHH', 'route': '/human_resources'},
          {'label': 'Calculadora Salario', 'route': '/salario_neto'}
        ]
      };
    }
    
    if (lowerInput.contains('registro') || lowerInput.contains('aviso') || _selectedTopic == 'Trámites') {
       return {
        'text': '### Formalización de Negocio 🏛️\n\nPara operar legalmente:\n\n1. **Aviso de Operación**: Tramítalo en PanamáEmprende.\n2. **Municipio**: Inscribe tu negocio en el municipio correspondiente.\n3. **DGI**: Obtén tu RUC y NIT.\n\n¿Necesitas ayuda con los requisitos?',
        'actions': [
          {'label': 'Ver Checklist Trámites', 'route': '/checklist_tramites'},
        ]
      };
    }

    if (lowerInput.contains('costo') || lowerInput.contains('presupuesto') || _selectedTopic == 'Contabilidad') {
       return {
        'text': '### Control Financiero 💰\n\nOrganizar tus números es clave:\n\n*   **Costos Fijos**: Alquiler, salarios, servicios.\n*   **Costos Variables**: Materia prima, comisiones.\n\nUsa nuestras calculadoras para estimar tu margen.',
        'actions': [
          {'label': 'Calculadora Costos', 'route': '/fixed_costs'},
          {'label': 'Margen Ganancia', 'route': '/margen_ganancia'}
        ]
      };
    }

    // Default General
    return {
      'text': 'Gracias por tu consulta sobre **$_selectedTopic**. \n\nPara este tema, te sugiero comenzar con un **Plan de Acción**:\n\n1. Define tu objetivo claro.\n2. Revisa los recursos disponibles en la Biblioteca.\n3. Consulta con un especialista si es un tema delicado.\n\n¿Quieres que profundice en algún punto?',
      'actions': [
        {'label': 'Ir a Biblioteca', 'route': '/library'},
        {'label': 'Ver Guía Rápida', 'route': '/guia_rapida'}
      ]
    };
  }
  
  void _populateInput(String text) {
    _controller.text = text;
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'CHATBOT IA PRO',
      showBackButton: true,
      useScroll: false,
      body: Column(
        children: [
          // CONTROLS AREA
          _buildControls(),
          
          Expanded(
            child: Container(
              color: Colors.transparent,
              child: _messages.isEmpty 
                ? _buildWelcomeDashboard() 
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length) {
                         return _buildLoadingBubble();
                      }
                      final msg = _messages[index];
                      return _ChatBubble(
                        isUser: msg['isUser'],
                        text: msg['text'],
                        time: msg['time'],
                        actions: msg['actions'],
                      );
                    },
                  ),
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }
  
  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Column(
        children: [
          // MODE SELECTOR
          Row(
            children: [
              Expanded(child: _buildModeBtn('Guía paso a paso', 'guide')),
              const SizedBox(width: 12),
              Expanded(child: _buildModeBtn('Respuesta rápida', 'quick')),
            ],
          ),
          const SizedBox(height: 12),
          // TOPIC SELECTOR
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedTopic,
                dropdownColor: const Color(0xFF1E293B),
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
                style: GoogleFonts.outfit(color: Colors.white),
                items: _topics.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (val) => setState(() => _selectedTopic = val!),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildModeBtn(String label, String val) {
    final isSelected = _selectedMode == val;
    return GestureDetector(
      onTap: () => setState(() => _selectedMode = val),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? EmpoderateTheme.cyanAccent.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? EmpoderateTheme.cyanAccent : Colors.white12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            color: isSelected ? Colors.white : Colors.white60,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal
          ),
        ),
      ),
    );
  }
  
  Widget _buildLoadingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: EmpoderateTheme.deepBlue,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16)
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16, height: 16, 
              child: CircularProgressIndicator(strokeWidth: 2, color: EmpoderateTheme.cyanAccent)
            ),
            const SizedBox(width: 12),
            Text('Escribiendo...', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWelcomeDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.auto_awesome, size: 48, color: EmpoderateTheme.cyanAccent),
          const SizedBox(height: 16),
          Text(
            '¿En qué puedo ayudarte hoy?',
            style: EmpoderateTheme.titleStyle.copyWith(fontSize: 24),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
             'Selecciona un tema y el modo de respuesta que prefieras.',
             style: GoogleFonts.outfit(color: Colors.white60, fontSize: 16),
             textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          Text('Ejemplos de preguntas:', style: GoogleFonts.outfit(color: EmpoderateTheme.goldStrong, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildIdeaCard(double.infinity, 'Quiero formalizar mi negocio en Panamá', Icons.store, Colors.blueAccent),
          const SizedBox(height: 12),
          _buildIdeaCard(double.infinity, '¿Cómo calculo las prestaciones laborales?', Icons.calculate, Colors.greenAccent),
          const SizedBox(height: 12),
          _buildIdeaCard(double.infinity, 'Tips para mejorar mis ventas en Instagram', Icons.trending_up, Colors.purpleAccent),

          const SizedBox(height: 32),
          const LegalShielding(type: ShieldType.ai),
        ],
      ),
    );
  }
  
  Widget _buildIdeaCard(double width, String text, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => _populateInput(text),
      child: Container(
        width: width,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color.withOpacity(0.5), size: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1120), 
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                   const SizedBox(width: 16),
                   Expanded(
                     child: TextField(
                       controller: _controller,
                       style: GoogleFonts.outfit(color: Colors.white),
                       decoration: InputDecoration(
                         hintText: 'Escribe aquí...',
                         hintStyle: GoogleFonts.outfit(color: Colors.white38),
                         border: InputBorder.none,
                         isDense: true,
                         contentPadding: const EdgeInsets.symmetric(vertical: 14),
                       ),
                       onSubmitted: (_) => _sendMessage(),
                     ),
                   ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: EmpoderateTheme.cyanAccent, 
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: EmpoderateTheme.cyanAccent.withOpacity(0.3), blurRadius: 10)],
              ),
              child: const Icon(Icons.send, color: Colors.black, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final bool isUser;
  final String text;
  final String time;
  final List<dynamic>? actions;

  const _ChatBubble({
    Key? key,
    required this.isUser,
    required this.text,
    required this.time,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = isUser ? EmpoderateTheme.primaryBlue : const Color(0xFF1E293B);
    final borderColor = isUser ? EmpoderateTheme.purpleAccent : Colors.white12;
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: isUser ? const Radius.circular(18) : Radius.zero,
      bottomRight: isUser ? Radius.zero : const Radius.circular(18),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: align,
        children: [
           Container(
             padding: const EdgeInsets.all(16),
             decoration: BoxDecoration(
               color: bgColor,
               borderRadius: radius,
               border: Border.all(color: borderColor.withOpacity(0.5)),
             ),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(
                   text,
                   style: GoogleFonts.outfit(
                     color: Colors.white,
                     fontSize: 15,
                     height: 1.5,
                   ),
                 ),
                 
                 if (actions != null && actions!.isNotEmpty) ...[
                   const SizedBox(height: 16),
                   const Divider(color: Colors.white10),
                   const SizedBox(height: 8),
                   Text('RECOMENDADO:', style: GoogleFonts.outfit(color: EmpoderateTheme.cyanAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                   const SizedBox(height: 8),
                   ...actions!.map((action) => _buildActionBtn(context, action)),
                 ]
               ],
             ),
           ),
           Padding(
             padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
             child: Text(time, style: GoogleFonts.outfit(color: Colors.white24, fontSize: 10)),
           ),
        ],
      ),
    );
  }
  
  Widget _buildActionBtn(BuildContext context, dynamic action) {
    return GestureDetector(
      onTap: () {
        if (action['route'] != null) {
          Navigator.pushNamed(context, action['route']);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: EmpoderateTheme.cyanAccent.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
             Icon(Icons.bolt, color: EmpoderateTheme.cyanAccent, size: 14),
             const SizedBox(width: 8),
             Text(
               action['label'] ?? 'Abrir',
               style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
             ),
             const Spacer(),
             Icon(Icons.arrow_forward, color: Colors.white54, size: 14),
          ],
        ),
      ),
    );
  }
}
