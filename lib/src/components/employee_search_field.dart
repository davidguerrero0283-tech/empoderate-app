import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../calculators/salario_models.dart';

/// Enhanced Searchable Employee Selector with:
/// - Live search filtering by name/position/department
/// - Checkmark (✓) indicator for calculated employees
/// - Avatar initials for quick visual identification
/// - Salary amount preview
/// - Last calculation date display
/// - "Nuevo" button integrated
class EmployeeSearchField extends StatefulWidget {
  final List<WorkerProfile> workers;
  final String? selectedWorkerId;
  final ValueChanged<WorkerProfile> onSelect;
  final VoidCallback onNewEmployee;
  final Map<String, DateTime>? calculatedWorkers; // workerId -> lastCalcDate
  
  const EmployeeSearchField({
    Key? key,
    required this.workers,
    required this.selectedWorkerId,
    required this.onSelect,
    required this.onNewEmployee,
    this.calculatedWorkers,
  }) : super(key: key);

  @override
  State<EmployeeSearchField> createState() => _EmployeeSearchFieldState();
}

class _EmployeeSearchFieldState extends State<EmployeeSearchField> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isExpanded = false;
  List<WorkerProfile> _filteredWorkers = [];
  
  @override
  void initState() {
    super.initState();
    _filteredWorkers = _sortedWorkers;
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() => _isExpanded = true);
      }
    });
  }
  
  // Sort: recently calculated first, then alphabetical
  List<WorkerProfile> get _sortedWorkers {
    final sorted = List<WorkerProfile>.from(widget.workers);
    sorted.sort((a, b) {
      final aCalc = widget.calculatedWorkers?[a.id];
      final bCalc = widget.calculatedWorkers?[b.id];
      
      // Calculated employees come first, sorted by most recent
      if (aCalc != null && bCalc != null) {
        return bCalc.compareTo(aCalc);
      } else if (aCalc != null) {
        return -1;
      } else if (bCalc != null) {
        return 1;
      }
      
      // Then alphabetical
      return a.name.compareTo(b.name);
    });
    return sorted;
  }
  
  @override
  void didUpdateWidget(covariant EmployeeSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.workers != widget.workers) {
      _filterWorkers(_searchController.text);
    }
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  
  void _filterWorkers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredWorkers = _sortedWorkers;
      } else {
        _filteredWorkers = _sortedWorkers.where((w) =>
          w.name.toLowerCase().contains(query.toLowerCase()) ||
          w.position.toLowerCase().contains(query.toLowerCase()) ||
          w.department.toLowerCase().contains(query.toLowerCase())
        ).toList();
      }
    });
  }
  
  WorkerProfile? get _selectedWorker {
    if (widget.selectedWorkerId == null) return null;
    try {
      return widget.workers.firstWhere((w) => w.id == widget.selectedWorkerId);
    } catch (_) {
      return null;
    }
  }
  
  DateTime? _lastCalcDate(String workerId) {
    return widget.calculatedWorkers?[workerId];
  }
  
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }
  
  Color _getAvatarColor(String name) {
    final colors = [
      Colors.pinkAccent,
      Colors.purpleAccent,
      Colors.blueAccent,
      Colors.cyanAccent,
      Colors.tealAccent,
      Colors.orangeAccent,
      Colors.amber,
    ];
    return colors[name.length % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    
    return TapRegion(
      onTapOutside: (event) {
        if (_isExpanded) {
          setState(() => _isExpanded = false);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search Bar + New Button
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF151C2B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isExpanded ? const Color(0xFFF4D35E) : Colors.white12,
              ),
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Icon(Icons.search, color: Colors.white38, size: 20),
                ),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: _selectedWorker != null 
                        ? _selectedWorker!.name 
                        : 'Buscar empleado...',
                      hintStyle: GoogleFonts.outfit(
                        color: _selectedWorker != null 
                          ? const Color(0xFFF4D35E)
                          : Colors.white38,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                    onChanged: _filterWorkers,
                    onTap: () {
                      _searchController.clear();
                      _filterWorkers('');
                    },
                  ),
                ),
                // Employee count badge
                if (!_isExpanded && widget.workers.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${widget.workers.length}',
                      style: GoogleFonts.outfit(color: Colors.white54, fontSize: 11),
                    ),
                  ),
                // New Employee Button
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: TextButton.icon(
                    onPressed: () {
                      _focusNode.unfocus();
                      widget.onNewEmployee();
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Nuevo'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF00E5FF),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      textStyle: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Dropdown List (visible when focused)
          if (_isExpanded && _filteredWorkers.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 4),
              constraints: const BoxConstraints(maxHeight: 280),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F2E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: _filteredWorkers.length,
                  itemBuilder: (context, index) {
                    final worker = _filteredWorkers[index];
                    final isSelected = widget.selectedWorkerId == worker.id;
                    final lastCalc = _lastCalcDate(worker.id);
                    final hasCalc = lastCalc != null;
                    
                    return Material(
                      color: isSelected 
                        ? const Color(0xFFF4D35E).withOpacity(0.1)
                        : Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          // FIRST call the selection callback to populate the form
                          widget.onSelect(worker);
                          
                          // THEN close the dropdown
                          _searchController.clear();
                          _focusNode.unfocus();
                          setState(() => _isExpanded = false);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Row(
                            children: [
                              // Avatar with initials
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: _getAvatarColor(worker.name).withOpacity(0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _getAvatarColor(worker.name).withOpacity(0.5),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    _getInitials(worker.name),
                                    style: GoogleFonts.outfit(
                                      color: _getAvatarColor(worker.name),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              
                              // Employee Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            worker.name,
                                            style: GoogleFonts.outfit(
                                              color: isSelected 
                                                ? const Color(0xFFF4D35E)
                                                : Colors.white,
                                              fontWeight: isSelected 
                                                ? FontWeight.bold 
                                                : FontWeight.w500,
                                              fontSize: 14,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        // Checkmark for calculated
                                        if (hasCalc)
                                          Container(
                                            margin: const EdgeInsets.only(left: 6),
                                            padding: const EdgeInsets.all(3),
                                            decoration: BoxDecoration(
                                              color: Colors.greenAccent.withOpacity(0.2),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.check,
                                              color: Colors.greenAccent,
                                              size: 10,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        // Position/Department
                                        if (worker.position.isNotEmpty || worker.department.isNotEmpty)
                                          Expanded(
                                            child: Text(
                                              [worker.position, worker.department]
                                                .where((s) => s.isNotEmpty)
                                                .join(' • '),
                                              style: GoogleFonts.outfit(
                                                color: Colors.white54,
                                                fontSize: 11,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        // Last calc date
                                        if (hasCalc)
                                          Text(
                                            DateFormat('dd/MM').format(lastCalc),
                                            style: GoogleFonts.outfit(
                                              color: Colors.greenAccent.withOpacity(0.7),
                                              fontSize: 10,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(width: 8),
                              
                              // Salary amount
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    currencyFormat.format(worker.basePayment),
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFFF4D35E),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    worker.paymentMode == PayrollFrequency.mensual 
                                      ? '/mes' 
                                      : worker.paymentMode == PayrollFrequency.quincenal 
                                        ? '/qna' 
                                        : '/sem',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white38,
                                      fontSize: 9,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          
          // Empty state
          if (_isExpanded && _filteredWorkers.isEmpty && _searchController.text.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F2E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, color: Colors.white38, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'No se encontraron empleados',
                    style: GoogleFonts.outfit(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
