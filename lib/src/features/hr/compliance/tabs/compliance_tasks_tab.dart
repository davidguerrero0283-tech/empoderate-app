import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../hr_compliance_service.dart';
import '../hr_compliance_models.dart';
import '../modals/compliance_creation_modal.dart';
import '../../../../components/neon_widgets.dart';

class ComplianceTasksTab extends StatefulWidget {
  final VoidCallback onDataChanged;
  const ComplianceTasksTab({Key? key, required this.onDataChanged}) : super(key: key);

  @override
  State<ComplianceTasksTab> createState() => _ComplianceTasksTabState();
}

class _ComplianceTasksTabState extends State<ComplianceTasksTab> {
  List<Map<String, dynamic>> _tasks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _loading = true);
    final tasks = await HrComplianceService().getUpcomingTasks(20);
    if (mounted) {
      setState(() {
        _tasks = tasks;
        _loading = false;
      });
    }
  }

  Future<void> _markComplete(String recordId) async {
    await HrComplianceService().markAsCompleted(recordId);
    widget.onDataChanged();
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(20.0),
        child: CircularProgressIndicator(color: Colors.cyanAccent),
      ));
    }

    if (_tasks.isEmpty) {
      return Column(
        children: [
          _buildActionButtons(),
          const SizedBox(height: 20),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                children: [
                  Icon(Icons.check_circle_outline, size: 64, color: Colors.white24),
                  const SizedBox(height: 16),
                  Text(
                    '¡Todo al día!',
                    style: GoogleFonts.outfit(color: Colors.white54, fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildActionButtons(),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _tasks.length,
          itemBuilder: (context, index) {
            final task = _tasks[index];
            final record = task['record'] as HrComplianceRecord;
            final catalog = task['catalog'] as HrObligationCatalog;
            final deadline = task['deadline'] as DateTime;
            final daysLeft = task['days_left'] as int;

            return _TaskItem(
              title: catalog.title,
              deadline: DateFormat('dd MMM').format(deadline),
              daysLeft: daysLeft,
              category: catalog.category,
              priority: catalog.priority,
              onTap: () => _markComplete(record.id),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: NeonButton(
            text: "Crear con IA",
            icon: Icons.auto_awesome,
            onTap: () => _openCreationModal(true),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: NeonButton(
            text: "Crear Nuevo",
            icon: Icons.add_circle_outline,
            primary: false,
            onTap: () => _openCreationModal(false),
          ),
        ),
      ],
    );
  }

  void _openCreationModal(bool isAiMode) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ComplianceCreationModal(
        initialAiMode: isAiMode, 
        onSuccess: () {
           widget.onDataChanged();
           _loadTasks();
        }
      ),
    );
  }
}

class _TaskItem extends StatelessWidget {
  final String title;
  final String deadline;
  final int daysLeft;
  final String category;
  final String priority;
  final VoidCallback onTap;

  const _TaskItem({
    required this.title,
    required this.deadline,
    required this.daysLeft,
    required this.category,
    required this.priority,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = Colors.greenAccent;
    String statusText = 'A tiempo';
    
    if (daysLeft < 0) {
      statusColor = Colors.redAccent;
      statusText = 'Vencido';
    } else if (daysLeft <= 3) {
      statusColor = Colors.orangeAccent;
      statusText = '$daysLeft días';
    } else {
        statusText = '$daysLeft días';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C), // Dark surface
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          // Checkbox equivalent
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(50),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 2),
              ),
              child: const Icon(Icons.check, size: 16, color: Colors.transparent), // Hidden initially
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 16
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      category.toUpperCase(),
                      style: GoogleFonts.outfit(
                        color: Colors.white38, 
                        fontSize: 10,
                        letterSpacing: 1
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text(
                      priority.toUpperCase(),
                       style: GoogleFonts.outfit(
                        color: priority == 'alta' ? Colors.orangeAccent : Colors.cyanAccent, 
                        fontSize: 10,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          // Deadline Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                deadline,
                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
              ),
               Text(
                statusText,
                style: GoogleFonts.outfit(color: statusColor, fontSize: 12),
              ),
            ],
          )
        ],
      ),
    );
  }
}
