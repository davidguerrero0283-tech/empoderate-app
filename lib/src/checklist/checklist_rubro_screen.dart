import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_empoderate/ui/components/header/premium_header.dart';
import '../components/gradient_background.dart';
import 'checklist_models.dart';
import 'checklist_service_placeholder.dart';
import 'checklist_components.dart';

class ChecklistRubroScreen extends StatefulWidget {
  const ChecklistRubroScreen({Key? key}) : super(key: key);

  @override
  State<ChecklistRubroScreen> createState() => _ChecklistRubroScreenState();
}

class _ChecklistRubroScreenState extends State<ChecklistRubroScreen> {
  final ChecklistServicePlaceholder _service = ChecklistServicePlaceholder();
  late List<ChecklistCategory> _categories;

  @override
  void initState() {
    super.initState();
    _categories = _service.getCategoriesForRubro('placeholder_id');
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
                'Selecciona una categoría',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return Column(
                    children: [
                      ChecklistCategoryTile(
                        category: category,
                        onTap: () {
                          _showTasksModal(context, category);
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTasksModal(BuildContext context, ChecklistCategory category) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF001B3A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.title,
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFD4AF37),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: category.tasks.length,
                      itemBuilder: (context, index) {
                        final task = category.tasks[index];
                        return ChecklistTaskItem(
                          task: task,
                          onChanged: (val) {
                            setState(() {
                              task.isCompleted = val;
                            });
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
      },
    );
  }
}
