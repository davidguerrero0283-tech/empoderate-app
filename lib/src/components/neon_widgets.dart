import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui'; // For BackdropFilter
import 'package:intl/intl.dart';
import '../navigation/app_routes.dart';

// 🎨 PALETA OFICIAL PREMIUM DARK GLOBAL
const Color kSpaceBlack = Color(0xFF020408);
const Color kDeepNavy = Color(0xFF050914);
const Color kGlassDark = Color(0x99080B12); // High opacity dark glass
const Color kGlassLight = Color(0x1AFFFFFF); // Low opacity white for highlights

// NEON ACCENTS (SOFT/REFINED)
const Color kNeonBlue = Color(0xFF448AFF); // Soft Blue
const Color kNeonCyan = Color(0xFF00E5FF); // Cyan
const Color kNeonViolet = Color(0xFFD500F9); // Violet
const Color kNeonPink = Color(0xFFFF4081); // Pink
const Color kNeonGreen = Color(0xFF00E676); // Soft Green
const Color kNeonCopper = Color(0xFFFFAB40); // Copper
const Color kNeonSilver = Color(0xFFB0BEC5); // Silver
const Color kNeonGold = Color(0xFFF4D35E); // Neon Gold
const Color kNeonYellow = Color(0xFFFFEA00); // Bright Neon Yellow
const Color kNeonOrange = Color(0xFFFF9100); // Neon Orange
const Color kNeonRed = Color(0xFFFF5252); // Neon Red / Error
const Color kNeonPurple = Color(0xFFD500F9); // Purple (Alias for Violet)
const Color kNeonBg = Color(0xFF020408); // Deep Background

// ✨ NEON HEADER (Already updated in premium_header.dart, keeping minimal here if needed or removed)
// Keeping a minimal version just in case legacy code calls it, but PremiumHeader is preferred.
class NeonHeader extends StatelessWidget {
  final VoidCallback onMenuTap;
  final VoidCallback onNotificationTap;

  const NeonHeader({
    Key? key,
    required this.onMenuTap,
    required this.onNotificationTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(); // Deprecated in favor of PremiumHeader
  }
}

class NeonSectionTitle extends StatelessWidget {
  final String title;
  final Color color;

  const NeonSectionTitle({
    Key? key,
    required this.title,
    this.color = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          color: color,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// 📦 GLOBAL GLASS CARD - UPDATED WITH HOVER SUPPORT
class NeonCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? borderColor;
  final bool isMulticolor;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final bool enableHover;

  const NeonCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.borderColor,
    this.isMulticolor = false,
    this.backgroundColor,
    this.onTap,
    this.enableHover = true,
  }) : super(key: key);

  @override
  State<NeonCard> createState() => _NeonCardState();
}

class _NeonCardState extends State<NeonCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool useHover = widget.enableHover && widget.onTap != null;
    
    return MouseRegion(
      onEnter: (useHover) ? (_) => setState(() => _isHovered = true) : null,
      onExit: (useHover) ? (_) => setState(() => _isHovered = false) : null,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: widget.margin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              if (_isHovered)
                BoxShadow(
                  color: kNeonGold.withOpacity(0.35),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              else
                const BoxShadow(
                  color: Colors.black45,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: widget.padding ?? const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: widget.backgroundColor ?? kGlassDark.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isHovered 
                      ? kNeonGold 
                      : (widget.borderColor ?? kNeonBlue).withOpacity(0.4), 
                    width: _isHovered ? 2 : 1
                  ),
                ),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 🔳 NEON INPUT (PREMIUM DARK)
class NeonInput extends StatefulWidget {
  final String label;
  final Function(String)? onChanged;
  final TextInputType? keyboardType;
  final bool isNumber;
  final String? initialValue;
  final TextEditingController? controller;
  final int maxLines;
  final String? hint;
  final String? suffixText;
  final bool obscureText; 
  final Widget? suffixIcon;
  final bool required; // New
  final String? Function(String?)? validator; // Fixed: Added field definition

  const NeonInput({
    Key? key, 
    required this.label, 
    this.onChanged, 
    this.keyboardType, 
    this.isNumber = false, 
    this.initialValue,
    this.controller,
    this.maxLines = 1,
    this.hint,
    this.suffixText,
    this.obscureText = false,
    this.suffixIcon,
    this.required = false,
    this.validator, // New
  }) : super(key: key);

  @override
  _NeonInputState createState() => _NeonInputState();
}

class _NeonInputState extends State<NeonInput> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isLocalController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController(text: widget.initialValue);
      _isLocalController = true;
    }

    _focusNode.addListener(() { 
      setState(() {}); 
      
      // AUTO-FORMAT ON BLUR (The God Mode Touch)
      if (!_focusNode.hasFocus && widget.isNumber && _controller.text.isNotEmpty) {
        try {
          String raw = _controller.text.replaceAll(',', '.');
          double val = double.parse(raw);
          String formatted = val.toStringAsFixed(2);
          
          if (_controller.text != formatted) {
            _controller.text = formatted;
            if (widget.onChanged != null) widget.onChanged!(formatted);
          }
        } catch (_) {}
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    if (_isLocalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isFocused = _focusNode.hasFocus;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.transparent, // Changed to transparent for cleaner look
          border: Border.all(
            color: isFocused ? kNeonBlue.withOpacity(0.8) : Colors.white10,
            width: isFocused ? 1.5 : 1,
          ),
        ),
        child: TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          keyboardType: widget.isNumber ? const TextInputType.numberWithOptions(decimal: true) : widget.keyboardType,
          maxLines: widget.maxLines,
          obscureText: widget.obscureText,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          validator: (value) {
            if (widget.validator != null) {
              return widget.validator!(value);
            }
            if (widget.required && (value == null || value.isEmpty)) {
              return 'Este campo es requerido';
            }
            return null;
          },
          inputFormatters: widget.isNumber 
            ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))] 
            : null,
          decoration: InputDecoration(
            labelText: widget.label,
            labelStyle: TextStyle(
              color: isFocused ? kNeonBlue : Colors.white60,
              fontSize: 14,
            ),
            hintText: widget.hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixText: widget.suffixText,
            suffixStyle: const TextStyle(color: kNeonBlue, fontWeight: FontWeight.bold),
            suffixIcon: widget.suffixIcon,
            errorStyle: const TextStyle(color: kNeonRed, fontSize: 12), // Added error style
          ),
          onChanged: (val) {
             if (widget.onChanged != null) {
               // Allow 10,50 to be parsed as 10.50
               widget.onChanged!(val.replaceAll(',', '.'));
             }
          },
        ),
      ),
    );
  }
}

// 🔽 NEON DROPDOWN (PREMIUM)
class NeonDropdown<T> extends StatelessWidget {
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String label;

  const NeonDropdown({
    Key? key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white60, fontSize: 14),
          filled: false,
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white10),
            borderRadius: BorderRadius.circular(16),
          ),
          border: OutlineInputBorder(
             borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            items: items,
            onChanged: onChanged,
            dropdownColor: const Color(0xFF050914), // Deep Navy
            style: const TextStyle(color: Colors.white, fontSize: 15),
            icon: const Icon(Icons.keyboard_arrow_down, color: kNeonBlue),
            isExpanded: true,
          ),
        ),
      ),
    );
  }
}

// 📅 NEON TABLE (PREMIUM)
class NeonTable extends StatelessWidget {
  final List<String> headers;
  final List<List<Widget>> rows; // Using Widgets for flexibility (Text, Icons, Chips)
  final Color accentColor;
  final Map<int, TableColumnWidth>? columnWidths;

  const NeonTable({
    Key? key, 
    required this.headers, 
    required this.rows, 
    this.accentColor = kNeonBlue,
    this.columnWidths,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: kGlassDark.withOpacity(0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: columnWidths,
          border: TableBorder(horizontalInside: BorderSide(color: Colors.white10, width: 0.5)),
          children: [
            // Header Row
            TableRow(
              decoration: BoxDecoration(color: accentColor.withOpacity(0.1)),
              children: headers.map((h) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Text(
                  h.toUpperCase(),
                  style: GoogleFonts.outfit(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              )).toList(),
            ),
            // Data Rows
            if (rows.isEmpty)
              TableRow(
                children: [
                   Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('No hay datos disponibles', style: GoogleFonts.outfit(color: Colors.white38)),
                  )
                ]
              )
            else
              ...rows.asMap().entries.map((entry) {
                final int idx = entry.key;
                final List<Widget> cells = entry.value;
                return TableRow(
                  decoration: BoxDecoration(
                    color: idx.isEven ? Colors.transparent : Colors.white.withOpacity(0.02),
                  ),
                  children: cells.map((cell) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    child: cell,
                  )).toList(),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}

// 🔵 NEON BUTTON (SOFT GRADIENTS)
class NeonButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool primary; 
  final Color? color;
  final Color? textColor;
  final IconData? icon;
  final bool isLoading; 

  const NeonButton({
    Key? key,
    required this.text,
    required this.onTap,
    this.primary = true,
    this.color,
    this.textColor,
    this.icon,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Primary: Blue/Cyan, Secondary: Violet
    final Color baseColor = color ?? (primary ? kNeonBlue : kNeonViolet);
    
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
             colors: [baseColor.withOpacity(0.8), baseColor.withOpacity(0.6)],
             begin: Alignment.topLeft,
             end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: baseColor.withOpacity(0.5), width: 1),
          boxShadow: [
            BoxShadow(
              color: baseColor.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: isLoading 
            ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 📊 NEON GRID CARD (GLASS + SOFT BORDER)
class NeonGridCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color neonColor;
  final VoidCallback onTap;
  final Color? backgroundColor;

  const NeonGridCard({
    Key? key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.neonColor,
    required this.onTap,
    this.backgroundColor,
  }) : super(key: key);

  @override
  State<NeonGridCard> createState() => _NeonGridCardState();
}

class _NeonGridCardState extends State<NeonGridCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _isHovered ? kNeonGold : widget.neonColor.withOpacity(0.5),
                  width: _isHovered ? 2 : 1,
                ),
                boxShadow: [
                  if (_isHovered)
                    BoxShadow(
                      color: kNeonGold.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    )
                  else
                    BoxShadow(color: Colors.black26, blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(widget.icon, color: widget.neonColor, size: 30, shadows: [BoxShadow(color: widget.neonColor.withOpacity(0.5), blurRadius: 8)]),
                  const SizedBox(height: 12),
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(color: Colors.white54, fontSize: 11),
                      maxLines: 4,
                    )
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


// 📜 NEON WIDE CARD (GLASS + SOFT BORDER)
class NeonWideCard extends StatefulWidget {
  final Widget child;
  final Color borderColor;
  final VoidCallback? onTap;
  final bool isPremium;
  final Color? backgroundColor;
  final Gradient? backgroundGradient;

  const NeonWideCard({
    Key? key,
    required this.child,
    required this.borderColor,
    this.onTap,
    this.isPremium = false,
    this.backgroundColor,
    this.backgroundGradient,
  }) : super(key: key);

  @override
  State<NeonWideCard> createState() => _NeonWideCardState();
}

class _NeonWideCardState extends State<NeonWideCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                gradient: widget.isPremium 
                  ? LinearGradient(colors: [Color(0xFF2A2000), Colors.black], begin: Alignment.topLeft, end: Alignment.bottomRight) 
                  : null,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isHovered ? kNeonGold : widget.borderColor.withOpacity(0.5),
                  width: _isHovered ? 2 : 1.0,
                ),
                boxShadow: [
                  if (_isHovered)
                    BoxShadow(
                      color: kNeonGold.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    )
                  else
                    BoxShadow(color: widget.borderColor.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

class NeonListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color iconColor;

  const NeonListTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor = kNeonBlue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white24, size: 20),
          ],
        ),
      ),
    );
  }
}


// 📅 NEON DATE SELECTOR
class NeonDateSelector extends StatelessWidget {
  final String label;
  final DateTime date;
  final Function(DateTime) onSelect;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const NeonDateSelector({
    Key? key,
    required this.label,
    required this.date,
    required this.onSelect,
    this.firstDate,
    this.lastDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: date,
            firstDate: firstDate ?? DateTime(2000),
            lastDate: lastDate ?? DateTime(2050),
            builder: (context, child) => Theme(
              data: ThemeData.dark().copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: kNeonGold,
                  onPrimary: Colors.black,
                  surface: Color(0xFF0F1520),
                  onSurface: Colors.white,
                ),
                dialogBackgroundColor: const Color(0xFF0F1520),
              ),
              child: child!,
            ),
          );
          if (picked != null) onSelect(picked);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.white60, fontSize: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.white10),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            suffixIcon: const Icon(Icons.calendar_today, color: kNeonGold, size: 18),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          child: Text(
            DateFormat('dd/MM/yyyy').format(date),
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
        ),
      ),
    );
  }
}

// 💬 NEON DIALOG
class NeonDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget> actions;

  const NeonDialog({
    Key? key, 
    required this.title, 
    required this.content, 
    required this.actions
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1520).withOpacity(0.95),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: kNeonBlue.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: kNeonBlue.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            content,
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions.map((a) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: a,
              )).toList(),
            )
          ],
        ),
      ),
    );
  }
}

// 🔘 NEON SWITCH
class NeonSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? label;

  const NeonSwitch({
    Key? key,
    required this.value,
    required this.onChanged,
     this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) Expanded(child: Text(label!, style: const TextStyle(color: Colors.white70, fontSize: 14))),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: kNeonGreen,
          activeTrackColor: kNeonGreen.withOpacity(0.3),
          inactiveThumbColor: Colors.white54,
          inactiveTrackColor: Colors.white10,
        ),
      ],
    );
  }
}
