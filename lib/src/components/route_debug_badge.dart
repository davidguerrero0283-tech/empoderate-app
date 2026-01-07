import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

/// Debug-only badge showing current route
/// Only visible when kDebugMode is true
class RouteDebugBadge extends StatelessWidget {
  const RouteDebugBadge({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Only show in debug mode
    if (!kDebugMode) {
      return const SizedBox.shrink();
    }

    final router = GoRouter.of(context);
    final currentLocation = router.routeInformationProvider.value.uri.toString();

    return Positioned(
      bottom: 100, // Above bottom nav
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFD4AF37).withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_on,
              size: 12,
              color: Color(0xFFD4AF37),
            ),
            const SizedBox(width: 4),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: Text(
                currentLocation,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  color: const Color(0xFFD4AF37),
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
