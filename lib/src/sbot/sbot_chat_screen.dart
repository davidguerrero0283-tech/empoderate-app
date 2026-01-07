import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/premium_scaffold.dart';
import 'sbot_components.dart';
import 'ai_model.dart';

class SBotChatScreen extends StatefulWidget {
  final AiPersonality personality;
  final String? initialPrompt; // New parameter

  const SBotChatScreen({
    Key? key,
    required this.personality,
    this.initialPrompt,
  }) : super(key: key);

  @override
  State<SBotChatScreen> createState() => _SBotChatScreenState();
}

class _SBotChatScreenState extends State<SBotChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Add initial system greeting
    _messages.add(ChatMessage(
      text: "Hola, soy tu ${widget.personality.name}. ${widget.personality.description} ¿En qué puedo ayudarte hoy?",
      isUser: false,
    ));

    // Handle initial prompt if present
    if (widget.initialPrompt != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleSend(widget.initialPrompt!);
      });
    }
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

  void _handleSend(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isTyping = true;
      _controller.clear();
    });
    _scrollToBottom();

    // Simulate AI processing
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(ChatMessage(
            text: _generateMockResponse(text),
            isUser: false,
          ));
        });
        _scrollToBottom();
      }
    });
  }

  String _generateMockResponse(String input) {
    // Basic mock logic based on keywords
    final lowerInput = input.toLowerCase();
    
    // Check for template keywords or specific tasks
    if (lowerInput.contains('reporte') || lowerInput.contains('contable')) {
      return "Entendido. Aquí tienes el esquema del reporte solicitado:\n\n1. Resumen de Ingresos\n2. Gastos Fijos vs Variables\n3. Estimación de Impuestos\n4. Margen Neto\n\n(Esta es una simulación. En la versión completa, aquí se generaría el PDF/Excel).";
    }
    if (lowerInput.contains('contrato') || lowerInput.contains('renuncia')) {
      return "Claro, puedo ayudarte con ese documento legal. Basado en el código de trabajo de Panamá (MITRADEL), aquí tienes los puntos clave que debe incluir:\n\n- Partes involucradas\n- Fechas y duración\n- Salario desglosado\n- Funciones\n\n¿Quieres que genere el borrador completo?";
    }
    if (lowerInput.contains('plan') || lowerInput.contains('calendario')) {
      return "¡Excelente iniciativa! Aquí tienes una propuesta para tu plan:\n\nLunes: Video educativo\nMartes: Testimonio de cliente\nMiércoles: Tip rápido (Reel)\nJueves: TBT o Historia de la marca\nViernes: Venta directa/Oferta\n\nRecuerda usar hashtags locales.";
    }

    return "Gracias por tu consulta. Como ${widget.personality.role}, analizaré tu solicitud sobre '$input'. \n\nPara darte la mejor respuesta, necesito que confirmes algunos detalles de tu negocio. ¿Podrías elaborar un poco más?";
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: widget.personality.name,
      subtitle: widget.personality.role,
      useScroll: false,
      usePadding: false,
      body: Column(
        children: [
          // Chat Area
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _ChatBubble(message: msg);
              },
            ),
          ),

          // Typing Indicator
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  const SizedBox(width: 8, height: 8, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFD4AF37))),
                  const SizedBox(width: 8),
                  Text(
                    'Generando respuesta...',
                    style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),

          // Templates / Input Area
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF001229),
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Auto-prompts Horizontal List
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.personality.autoPrompts.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final prompt = widget.personality.autoPrompts[index];
                      return ActionChip(
                        label: Text(prompt),
                        backgroundColor: const Color(0xFF002A5C),
                        labelStyle: GoogleFonts.outfit(color: const Color(0xFFD4AF37), fontSize: 12),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        onPressed: () => _handleSend(prompt),
                      );
                    },
                  ),
                ),
                
                // Templates Horizontal List
                SizedBox(
                  height: 50,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.personality.templates.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final temp = widget.personality.templates[index];
                      return ActionChip(
                        label: Text(temp.title),
                        backgroundColor: const Color(0xFF002A5C),
                        labelStyle: GoogleFonts.outfit(color: const Color(0xFFD4AF37), fontSize: 12),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        onPressed: () => _handleSend(temp.prompt),
                      );
                    },
                  ),
                ),
                // Button to open templates modal
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: _showTemplates,
                    child: const Text('Usar plantilla'),
                  ),
                ),
                
                // Input Field
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          style: GoogleFonts.outfit(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Escribe a tu experto...',
                            hintStyle: GoogleFonts.outfit(color: Colors.white30),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.05),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onSubmitted: _handleSend,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFD4AF37),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send_rounded, color: Colors.black, size: 20),
                          onPressed: () => _handleSend(_controller.text),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // Method to show templates in a modal bottom sheet
  void _showTemplates() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF001229),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Plantillas disponibles', style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.personality.templates.length,
                  itemBuilder: (context, index) {
                    final temp = widget.personality.templates[index];
                    return ListTile(
                      title: Text(temp.title, style: GoogleFonts.outfit(color: Colors.white)),
                      subtitle: Text(temp.prompt, style: GoogleFonts.outfit(color: Colors.white70)),
                      onTap: () {
                        Navigator.pop(context);
                        _handleSend(temp.prompt);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: message.isUser ? const Color(0xFFD4AF37) : const Color(0xFF002A5C),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: message.isUser ? const Radius.circular(16) : Radius.zero,
            bottomRight: message.isUser ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Text(
          message.text,
          style: GoogleFonts.outfit(
            color: message.isUser ? Colors.black : Colors.white,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
