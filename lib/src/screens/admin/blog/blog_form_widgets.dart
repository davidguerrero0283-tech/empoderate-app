import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RichTextToolbar extends StatelessWidget {
  final TextEditingController controller;

  const RichTextToolbar({Key? key, required this.controller}) : super(key: key);

  void _insertTag(String open, String close) {
    final text = controller.text;
    final selection = controller.selection;
    
    if (selection.start < 0) return;

    final newText = text.replaceRange(
      selection.start,
      selection.end,
      '$open${text.substring(selection.start, selection.end)}$close',
    );

    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: selection.end + open.length + close.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF001220),
        border: Border(bottom: BorderSide(color: const Color(0xFF00E5FF).withOpacity(0.3))),
      ),
      child: Wrap(
        spacing: 8,
        children: [
          _ToolButton(label: 'B', onTap: () => _insertTag('<b>', '</b>')),
          _ToolButton(label: 'I', onTap: () => _insertTag('<i>', '</i>')),
          _ToolButton(label: 'H2', onTap: () => _insertTag('<h2>', '</h2>')),
          _ToolButton(label: 'Link', onTap: () => _insertTag('<a href="">', '</a>')),
          _ToolButton(label: 'P', onTap: () => _insertTag('<p>', '</p>')),
          _ToolButton(label: 'List', onTap: () => _insertTag('<ul>\n<li>', '</li>\n</ul>')),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ToolButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF00E5FF).withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: const Color(0xFF00E5FF),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class NeonTagInput extends StatefulWidget {
  final List<String> initialTags;
  final Function(List<String>) onChanged;

  const NeonTagInput({
    Key? key,
    required this.initialTags,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<NeonTagInput> createState() => _NeonTagInputState();
}

class _NeonTagInputState extends State<NeonTagInput> {
  final TextEditingController _controller = TextEditingController();
  late List<String> _tags;

  @override
  void initState() {
    super.initState();
    _tags = List.from(widget.initialTags);
  }

  void _addTag() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && !_tags.contains(text)) {
      setState(() {
        _tags.add(text);
        _controller.clear();
      });
      widget.onChanged(_tags);
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
    widget.onChanged(_tags);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Etiquetas (Tags)',
          style: GoogleFonts.outfit(color: const Color(0xFF00E5FF), fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF001220).withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: GoogleFonts.outfit(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Agregar tag...',
                        hintStyle: TextStyle(color: Colors.white30),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _addTag(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Color(0xFF00E5FF)),
                    onPressed: _addTag,
                  ),
                ],
              ),
              if (_tags.isNotEmpty) ...[
                const Divider(color: Colors.white10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _tags.map((tag) => Chip(
                    label: Text(tag, style: GoogleFonts.outfit(color: Colors.white)),
                    backgroundColor: const Color(0xFF00E5FF).withOpacity(0.2),
                    deleteIcon: const Icon(Icons.close, size: 14, color: Colors.white70),
                    onDeleted: () => _removeTag(tag),
                    side: BorderSide.none,
                  )).toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
