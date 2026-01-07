import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmpoHelpCard extends StatefulWidget {
  final Map<String, String> contextData; // industry, model, requirement, section
  final Function(String question, Map<String, String> context) onAsk;

  const EmpoHelpCard({
    Key? key,
    required this.contextData,
    required this.onAsk,
  }) : super(key: key);

  @override
  State<EmpoHelpCard> createState() => _EmpoHelpCardState();
}

class _EmpoHelpCardState extends State<EmpoHelpCard> {
  final TextEditingController _controller = TextEditingController();
  String? _lastAnswer;
  bool _isLoading = false;

  void _handleAsk([String? predefinedQuestion]) {
    final question = predefinedQuestion ?? _controller.text.trim();
    if (question.isEmpty) return;

    setState(() {
      _isLoading = true;
      _lastAnswer = null; 
    });
    
    // Simulate network delay for effect / Stub
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        widget.onAsk(question, widget.contextData);
        setState(() {
          _isLoading = false;
          _lastAnswer = "EMPO está en preparación. Tu pregunta \"$question\" quedó guardada como pendiente ✅";
          _controller.clear();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Premium Colors
    const Color goldMain = Color(0xFFD4AF37);
    const Color darkGlass = Color(0xFF151C2B);  
    final Color borderColor = goldMain.withOpacity(0.3);

    return Container(
      width: double.infinity, // Full Width
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: darkGlass.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black12, 
            blurRadius: 8, 
            offset: const Offset(0, 2)
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ROW 1: HEADER
          Row(
            children: [
               Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: goldMain.withOpacity(0.1),
                  border: Border.all(color: goldMain, width: 1.5),
                ),
                child: Icon(Icons.smart_toy_outlined, color: goldMain, size: 18),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¿Necesitas ayuda?',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    'Pregúntale a EMPO',
                    style: GoogleFonts.outfit(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // ROW 2: ANSWER BUBBLE (If any)
          if (_lastAnswer != null)
             Container(
               margin: const EdgeInsets.only(bottom: 12),
               width: double.infinity,
               padding: const EdgeInsets.all(10),
               decoration: BoxDecoration(
                 color: goldMain.withOpacity(0.1),
                 borderRadius: BorderRadius.circular(8),
                 border: Border.all(color: goldMain.withOpacity(0.2)),
               ),
               child: Text(
                 _lastAnswer!,
                 style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
               ),
             ),


          // ROW 3: INPUT + BUTTON (Responsive Layout)
          LayoutBuilder(
            builder: (context, constraints) {
              // If width is plenty (>500), put in one row. Else Column.
              bool isWide = constraints.maxWidth > 500;
              
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: _buildInput(goldMain)),
                    const SizedBox(width: 12),
                    _buildButton(goldMain),
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildInput(goldMain),
                    const SizedBox(height: 12),
                    _buildButton(goldMain),
                  ],
                );
              }
            }
          ),

          const SizedBox(height: 12),

          // ROW 4: CHIPS
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChip('¿Qué tengo que llevar?'),
              _buildChip('¿Dónde se hace?'),
              _buildChip('Errores comunes'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInput(Color goldMain) {
    return TextField(
      controller: _controller,
      style: GoogleFonts.outfit(color: Colors.white),
      maxLines: 1,
      decoration: InputDecoration(
        hintText: 'Escribe tu duda aquí...',
        hintStyle: GoogleFonts.outfit(color: Colors.white30),
        filled: true,
        fillColor: Colors.black26,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30), // Rounded pill style
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: goldMain.withOpacity(0.5)),
        ),
      ),
    );
  }

  Widget _buildButton(Color goldMain) {
    if (_isLoading) {
      return const SizedBox(width: 40, height: 40, child: Padding(
        padding: EdgeInsets.all(10.0),
        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFD4AF37)),
      ));
    }
    return ElevatedButton(
      onPressed: () => _handleAsk(),
      style: ElevatedButton.styleFrom(
        backgroundColor: goldMain,
        foregroundColor: const Color(0xFF0F1520),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
      child: Text(
        'Preguntar',
        style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildChip(String label) {
    return InkWell(
      onTap: () => _handleAsk(label),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(color: Colors.white60, fontSize: 11),
        ),
      ),
    );
  }
}

class EmpoMiniCard extends StatefulWidget {
  final Function(String question) onAsk;

  const EmpoMiniCard({Key? key, required this.onAsk}) : super(key: key);

  @override
  State<EmpoMiniCard> createState() => _EmpoMiniCardState();
}

class _EmpoMiniCardState extends State<EmpoMiniCard> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  String? _pendingMsg;

  @override
  Widget build(BuildContext context) {
    const Color goldMain = Color(0xFFD4AF37);
    const Color darkGlass = Color(0xFF151C2B);  
    final Color borderColor = goldMain.withOpacity(0.3);

    return Container(
      constraints: const BoxConstraints(maxHeight: 220),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: darkGlass.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           // Header Mini
          Row(
            children: [
               Container(
                width: 24, height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: goldMain, width: 1),
                ),
                child: Icon(Icons.smart_toy_outlined, color: goldMain, size: 14),
              ),
              const SizedBox(width: 10),
              Text(
                'Pregúntale a EMPO',
                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          if (_pendingMsg != null)
            Expanded(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: goldMain.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _pendingMsg!,
                    style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            )
          else ...[
             // Mini History Placeholder (Empty state for now or recent Q)
             Expanded(
               child: Center(
                 child: Text(
                   '¿Tienes dudas sobre este trámite?',
                   style: GoogleFonts.outfit(color: Colors.white30, fontSize: 12, fontStyle: FontStyle.italic),
                 ),
               ),
             ),
             const SizedBox(height: 10),
             // Input Row
             Row(
               children: [
                 Expanded(
                   child: SizedBox(
                     height: 36,
                     child: TextField(
                        controller: _controller,
                        style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Escribe aquí...',
                          hintStyle: GoogleFonts.outfit(color: Colors.white30, fontSize: 12),
                          filled: true,
                          fillColor: Colors.black26,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: goldMain.withOpacity(0.5))),
                        ),
                     ),
                   ),
                 ),
                 const SizedBox(width: 8),
                 SizedBox(
                   width: 36, height: 36,
                   child: IconButton(
                     onPressed: () {
                        if (_controller.text.isNotEmpty) {
                           setState(() {
                             _isLoading = true;
                           });
                           Future.delayed(const Duration(seconds: 1), () {
                             if(mounted) {
                               widget.onAsk(_controller.text);
                               setState(() {
                                 _isLoading = false;
                                 _pendingMsg = "Pregunta enviada. EMPO te responderá pronto.";
                                 _controller.clear();
                               });
                             }
                           });
                        }
                     },
                     icon: _isLoading 
                       ? Padding(padding: const EdgeInsets.all(8), child: CircularProgressIndicator(strokeWidth: 2, color: goldMain))
                       : Icon(Icons.send_rounded, color: goldMain, size: 18),
                     style: IconButton.styleFrom(
                       backgroundColor: goldMain.withOpacity(0.1),
                       shape: const CircleBorder(),
                     ),
                   ),
                 )
               ],
             )
          ]
        ],
      ),
    );
  }
}
