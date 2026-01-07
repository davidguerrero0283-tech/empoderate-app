import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'checklist_models.dart';

class ChecklistCategoryTile extends StatelessWidget {
  final ChecklistCategory category;
  final VoidCallback onTap;

  const ChecklistCategoryTile({
    Key? key,
    required this.category,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(0, 0, 0, 0.35),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.35)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.folder_open, color: Color(0xFFD4AF37), size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.title,
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFD4AF37),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.description,
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white30),
          ],
        ),
      ),
    );
  }
}

class ChecklistTaskItem extends StatefulWidget {
  final ChecklistTask task;
  final ValueChanged<bool> onChanged;

  const ChecklistTaskItem({
    Key? key,
    required this.task,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<ChecklistTaskItem> createState() => _ChecklistTaskItemState();
}

class _ChecklistTaskItemState extends State<ChecklistTaskItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Checkbox(
            value: widget.task.isCompleted,
            activeColor: const Color(0xFFD4AF37),
            checkColor: const Color(0xFF001B3A),
            onChanged: (val) {
              if (val != null) {
                widget.onChanged(val);
              }
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.task.title,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 16,
                    decoration: widget.task.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                if (widget.task.description.isNotEmpty)
                  Text(
                    widget.task.description,
                    style: GoogleFonts.outfit(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          if (widget.task.isMandatory)
            const Icon(Icons.priority_high, color: Colors.redAccent, size: 16),
        ],
      ),
    );
  }
}

class PlanAccionItemTile extends StatefulWidget {
  final PlanAccionItem item;
  final ValueChanged<bool> onChanged;

  const PlanAccionItemTile({
    Key? key,
    required this.item,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<PlanAccionItemTile> createState() => _PlanAccionItemTileState();
}

class _PlanAccionItemTileState extends State<PlanAccionItemTile> {
  @override
  Widget build(BuildContext context) {
    Color priorityColor;
    String priorityText;
    switch (widget.item.priority) {
      case 1:
        priorityColor = Colors.redAccent;
        priorityText = 'ALTA';
        break;
      case 2:
        priorityColor = Colors.orangeAccent;
        priorityText = 'MEDIA';
        break;
      default:
        priorityColor = Colors.greenAccent;
        priorityText = 'BAJA';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(0, 0, 0, 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Checkbox(
            value: widget.item.isCompleted,
            activeColor: const Color(0xFFD4AF37),
            checkColor: const Color(0xFF001B3A),
            onChanged: (val) {
              if (val != null) {
                widget.onChanged(val);
              }
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item.title,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    decoration: widget.item.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.item.description,
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: priorityColor.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              priorityText,
              style: GoogleFonts.outfit(
                color: priorityColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
