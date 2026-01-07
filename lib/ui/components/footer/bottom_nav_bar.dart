import 'package:flutter/material.dart';

class NeonBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const NeonBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90, // Increased from 80 to accommodate labels
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A0F18), Color(0xFF0B1220)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(
          top: BorderSide(color: Color(0xFFD4AF37).withOpacity(0.6), width: 1.5), // Golden border, more prominent
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFD4AF37).withOpacity(0.15), // Golden glow
            blurRadius: 15,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavBarItem(
            index: 0,
            currentIndex: currentIndex,
            icon: Icons.home_outlined, 
            label: "Inicio",
            baseColor: const Color(0xFFD4AF37), // Golden
            onTap: onTap,
          ),
          _NavBarItem(
            index: 1,
            currentIndex: currentIndex,
            icon: Icons.handyman_outlined,
            label: "Herramientas",
            baseColor: const Color(0xFFD4AF37), // Golden
            onTap: onTap,
          ),
          _NavBarItem(
            index: 2,
            currentIndex: currentIndex,
            icon: Icons.inventory_2_outlined,
            label: "Bóveda",
            baseColor: const Color(0xFFD4AF37), // Golden
            onTap: onTap,
          ),
          _NavBarItem(
            index: 3,
            currentIndex: currentIndex,
            icon: Icons.settings_outlined,
            label: "Ajustes",
            baseColor: const Color(0xFFD4AF37), // Golden
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatefulWidget {
  final int index;
  final int currentIndex;
  final IconData icon;
  final String label;
  final Color baseColor;
  final ValueChanged<int> onTap;

  const _NavBarItem({
    Key? key,
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.label,
    required this.baseColor,
    required this.onTap,
  }) : super(key: key);

  @override
  State<_NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<_NavBarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    bool isActive = widget.index == widget.currentIndex;
    
    // All icons use golden color scheme
    Color iconColor = isActive ? const Color(0xFFF4D35E) : widget.baseColor.withOpacity(0.7);
    Color labelColor = isActive ? const Color(0xFFF4D35E) : widget.baseColor.withOpacity(0.6);
    double scale = isActive ? 1.05 : (_isHovered ? 1.05 : 1.0);
    List<BoxShadow> shadows = isActive 
      ? [BoxShadow(color: const Color(0xFFF4D35E).withOpacity(0.6), blurRadius: 12)]
      : (_isHovered ? [BoxShadow(color: widget.baseColor.withOpacity(0.6), blurRadius: 8)] : []);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => widget.onTap(widget.index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: Matrix4.identity()..scale(scale),
          width: 70,
          color: Colors.transparent, 
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ICON
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: shadows,
                ),
                child: Icon(
                  widget.icon,
                  color: iconColor,
                  size: 26,
                ),
              ),
              
              const SizedBox(height: 4),
              
              // LABEL (always visible)
              Text(
                widget.label,
                style: TextStyle(
                  color: labelColor,
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 2),
              
              // UNDERLINE (Active only)
              Container(
                height: 2,
                width: isActive ? 16 : 0,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4D35E),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                     BoxShadow(color: const Color(0xFFF4D35E).withOpacity(0.8), blurRadius: 4),
                  ]
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
