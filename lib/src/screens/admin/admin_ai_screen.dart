import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/neon_widgets.dart';

class AdminAiScreen extends StatefulWidget {
  const AdminAiScreen({Key? key}) : super(key: key);

  @override
  State<AdminAiScreen> createState() => _AdminAiScreenState();
}

class _AdminAiScreenState extends State<AdminAiScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {'role': 'ai', 'content': 'Hola Admin, soy tu copiloto. ¿En qué puedo ayudarte hoy?\nPuedo analizar tendencias, sugerir contenido o revisar usuarios.'},
  ];

  void _sendMessage() {
    if (_controller.text.isEmpty) return;
    
    setState(() {
      _messages.add({'role': 'user', 'content': _controller.text});
      // Simulate AI response
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _messages.add({'role': 'ai', 'content': 'Entendido. Estoy analizando los datos para "${_controller.text}"... (Simulación)'});
            _controller.clear();
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.deepPurpleAccent.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.deepPurpleAccent),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.deepPurpleAccent),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Admin Copilot', style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('IA Avanzada para gestión', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 13)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Chat Area
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0B1120),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isAi = msg['role'] == 'ai';
                  return Align(
                    alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      constraints: const BoxConstraints(maxWidth: 600),
                      decoration: BoxDecoration(
                        color: isAi ? const Color(0xFF1E293B) : Colors.deepPurpleAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(isAi ? 4 : 16),
                          bottomRight: Radius.circular(isAi ? 16 : 4),
                        ),
                        border: Border.all(color: isAi ? Colors.white10 : Colors.deepPurpleAccent.withOpacity(0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isAi) ...[
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.auto_awesome, size: 14, color: Colors.deepPurpleAccent),
                                const SizedBox(width: 8),
                                Text('Copilot', style: GoogleFonts.outfit(color: Colors.deepPurpleAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                          Text(msg['content']!, style: GoogleFonts.outfit(color: Colors.white, height: 1.5)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Input
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: GoogleFonts.outfit(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Pregúntale a Copilot...',
                      hintStyle: TextStyle(color: Colors.white38),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send_rounded),
                  color: Colors.deepPurpleAccent,
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
