
import 'package:flutter/material.dart';
import '../features/admin/visibility/visibility_service.dart';

class VisibilityBuilder extends StatelessWidget {
  final String id;
  final Widget child;
  final Widget? replacement;

  const VisibilityBuilder({
    Key? key,
    required this.id,
    required this.child,
    this.replacement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // We assume Service is init at app start. If not, it defaults to safe (false/default).
    // Ideally we use FutureBuilder but for basic UI list filtering sync access is preferred after global init.
    // If Service not ready, it might return false.
    
    final isVisible = VisibilityService.instance.isVisible(id);
    
    if (isVisible) {
      return child;
    } else {
      return replacement ?? const SizedBox.shrink();
    }
  }
}
