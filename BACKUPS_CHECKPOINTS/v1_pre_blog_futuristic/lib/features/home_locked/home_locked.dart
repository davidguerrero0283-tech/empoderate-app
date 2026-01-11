/*
🔒 LOCKED MODULE — HOME CARD (DO NOT MODIFY)
- This module is stable and must NOT be changed by automated refactors or future tasks.
- If changes are needed, create a new backup version:
  BACKUPS_UI/HOME_CARD_LOCKED/v2/
*/

import 'package:flutter/material.dart';
import 'package:proyecto_empoderate/src/models/checklist_model.dart';
import 'home_start_block.dart';
import 'home_locked_theme.dart';

/// 🔒 LOCKED - Public wrapper for the Home Start Block.
/// This is the ONLY export from this module.
/// DO NOT import home_start_block.dart directly from outside this folder.
class HomeLockedCard extends StatelessWidget {
  final BusinessProgressModel? dashboard;

  const HomeLockedCard({super.key, this.dashboard});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: buildHomeLockedTheme(context),
      child: HomeStartBlock(dashboard: dashboard),
    );
  }
}
