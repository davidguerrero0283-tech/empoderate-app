import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../components/premium_scaffold.dart';
import '../../components/neon_widgets.dart';
import '../../services/worker_service.dart';
import '../../calculators/salario_models.dart';
import 'hr_dashboard_widgets.dart';

class WorkerFormScreen extends StatefulWidget {
  final WorkerProfile? worker; // If null, create new
  final String? workerId;
  final Function()? onSave;

  const WorkerFormScreen({Key? key, this.worker, this.workerId, this.onSave}) : super(key: key);

  @override
  _WorkerFormScreenState createState() => _WorkerFormScreenState();
}

class _WorkerFormScreenState extends State<WorkerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  
  // Controllers
  late TextEditingController _nameCtrl;
  late TextEditingController _cedulaCtrl;
  late TextEditingController _posCtrl;
  late TextEditingController _deptCtrl;
  late TextEditingController _salaryCtrl;
  late TextEditingController _hourlyRateCtrl;
  late TextEditingController _notesCtrl;

  // State
  PayrollFrequency _frequency = PayrollFrequency.quincenal;
  WorkerContractType _contractType = WorkerContractType.indefinido;
  DateTime? _startDate;
  DateTime? _contractEnd;
  PaymentType _paymentType = PaymentType.base;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.worker != null) {
      _initControllers(widget.worker!);
    } else if (widget.workerId != null) {
      _loadWorker(widget.workerId!);
    } else {
      _initControllers(null);
    }
  }

  Future<void> _loadWorker(String id) async {
    setState(() => _isLoading = true);
    final worker = await WorkerService().getWorkerById(id);
    if (mounted) {
      if (worker != null) {
        _initControllers(worker);
      } else {
        _initControllers(null);
      }
      setState(() => _isLoading = false);
    }
  }

  void _initControllers(WorkerProfile? w) {
    _nameCtrl = TextEditingController(text: w?.name ?? '');
    _cedulaCtrl = TextEditingController(text: w?.cedula ?? '');
    _posCtrl = TextEditingController(text: w?.position ?? '');
    _deptCtrl = TextEditingController(text: w?.department ?? '');
    _salaryCtrl = TextEditingController(text: w?.basePayment.toStringAsFixed(2) ?? '');
    _hourlyRateCtrl = TextEditingController(text: w?.hourlyRate?.toStringAsFixed(2) ?? '');
    _notesCtrl = TextEditingController(text: w?.notes ?? '');
    
    if (w != null) {
      _frequency = w.paymentMode;
      _paymentType = w.paymentType;
      _contractType = w.contractType;
      _startDate = w.startDate;
      _contractEnd = w.contractEnd;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cedulaCtrl.dispose();
    _posCtrl.dispose();
    _deptCtrl.dispose();
    _salaryCtrl.dispose();
    _hourlyRateCtrl.dispose();
    _notesCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La Fecha de Inicio es obligatoria para cálculos correctos'), backgroundColor: Colors.redAccent),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    final newProfile = WorkerProfile(
      id: widget.worker?.id ?? DateTime.now().millisecondsSinceEpoch.toString(), // Simple ID gen
      name: _nameCtrl.text,
      cedula: _cedulaCtrl.text,
      position: _posCtrl.text,
      department: _deptCtrl.text,
      basePayment: _paymentType == PaymentType.base ? (double.tryParse(_salaryCtrl.text) ?? 0.0) : 0.0,
      paymentType: _paymentType,
      hourlyRate: _paymentType == PaymentType.hourly ? double.tryParse(_hourlyRateCtrl.text) : null,
      paymentMode: _frequency,
      contractType: _contractType,
      startDate: _startDate,
      contractEnd: _contractEnd,
      notes: _notesCtrl.text,
      payrollHistory: widget.worker?.payrollHistory ?? [],
      lastCalcTotal: widget.worker?.lastCalcTotal,
      lastCalcDate: widget.worker?.lastCalcDate,
    );

    try {
      await WorkerService().saveWorker(newProfile);
      
      if (widget.onSave != null) widget.onSave!();
      
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pop(context, true); // Return success
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Colaborador guardado correctamente.')));
      }
    } catch (e) {
      debugPrint('Error saving worker: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: widget.worker == null ? 'Nuevo Colaborador' : 'Editar Colaborador',
      showBackButton: true,
      useScroll: false, // We handle scrolling manually
      usePadding: false,
      body: SingleChildScrollView(
        key: const PageStorageKey<String>('worker_form_scroll'),
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 1: Personal Info
              HrGlassContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const NeonSectionTitle(title: 'Información Personal'),
                    const SizedBox(height: 20),
                    
                    NeonInput(
                      label: 'Nombre Completo',
                      controller: _nameCtrl,
                      required: true,
                    ),
                    const SizedBox(height: 16),
                    NeonInput(
                      label: 'Cédula / Pasaporte',
                      controller: _cedulaCtrl,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section 2: Job Details
              HrGlassContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const NeonSectionTitle(title: 'Detalles del Puesto'),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: NeonInput(
                            label: 'Cargo / Puesto',
                            controller: _posCtrl,
                            required: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: NeonInput(
                            label: 'Departamento',
                            controller: _deptCtrl,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Date Selectors
                    Row(
                      children: [
                        Expanded(
                          child: NeonDateSelector(
                            label: 'Fecha Inicio *',
                            date: _startDate ?? DateTime.now(),
                            onSelect: (d) {
                              final offset = _scrollController.offset;
                              setState(() => _startDate = d);
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (_scrollController.hasClients) _scrollController.jumpTo(offset);
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: NeonDropdown<WorkerContractType>(
                            label: 'Tipo de Contrato',
                            value: _contractType,
                            items: WorkerContractType.values.map((e) {
                              String label = e.toString().split('.').last;
                              label = label[0].toUpperCase() + label.substring(1);
                              return DropdownMenuItem(value: e, child: Text(label, style: GoogleFonts.outfit(color: Colors.white)));
                            }).toList(),
                            onChanged: (v) {
                              final offset = _scrollController.offset;
                              setState(() => _contractType = v!);
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (_scrollController.hasClients) _scrollController.jumpTo(offset);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    
                    if (_contractType == WorkerContractType.definido) ...[
                      const SizedBox(height: 16),
                      NeonDateSelector(
                        label: 'Fecha Finalización Contrato *',
                        date: _contractEnd ?? DateTime.now(),
                        onSelect: (d) {
                           final offset = _scrollController.offset;
                           setState(() => _contractEnd = d);
                           WidgetsBinding.instance.addPostFrameCallback((_) {
                             if (_scrollController.hasClients) _scrollController.jumpTo(offset);
                           });
                        },
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section 3: Compensation
              HrGlassContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const NeonSectionTitle(title: 'Compensación'),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: NeonDropdown<PaymentType>(
                            label: 'Tipo de Pago',
                            value: _paymentType,
                            items: const [
                              DropdownMenuItem(value: PaymentType.base, child: Text('Salario Base (Fijo)', style: TextStyle(color: Colors.white))),
                              DropdownMenuItem(value: PaymentType.hourly, child: Text('Por Hora (Variable)', style: TextStyle(color: Colors.white))),
                            ],
                            onChanged: (v) {
                              final offset = _scrollController.offset;
                              setState(() => _paymentType = v!);
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (_scrollController.hasClients) _scrollController.jumpTo(offset);
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: NeonDropdown<PayrollFrequency>(
                            label: 'Frecuencia de Pago',
                            value: _frequency,
                            items: PayrollFrequency.values.map((e) {
                              return DropdownMenuItem(value: e, child: Text(e.name.toUpperCase(), style: GoogleFonts.outfit(color: Colors.white)));
                            }).toList(),
                            onChanged: (v) {
                              final offset = _scrollController.offset;
                              setState(() => _frequency = v!);
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (_scrollController.hasClients) _scrollController.jumpTo(offset);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _paymentType == PaymentType.base
                    ? NeonInput(
                        label: 'Salario Base Mensual (\$)',
                        controller: _salaryCtrl,
                        keyboardType: TextInputType.number,
                        required: true,
                        hint: 'Ej: 300.00',
                      )
                    : NeonInput(
                        label: 'Tarifa Por Hora (\$)',
                        controller: _hourlyRateCtrl,
                        keyboardType: TextInputType.number,
                        required: true,
                        hint: 'Ej: 12.50',
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section 4: Notes
              HrGlassContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const NeonSectionTitle(title: 'Notas Adicionales'),
                    const SizedBox(height: 16),
                    NeonInput(
                      label: 'Comentarios / Bitácora',
                      controller: _notesCtrl,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline, color: Colors.blueAccent, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Este campo es privado y NO aparace en las colillas de pago.\\n'
                              'Úsalo para registrar: Evaluaciones de desempeño, incidentes, acuerdos verbales o recordatorios sobre este colaborador.',
                              style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Center(
                child: SizedBox(
                  width: 250,
                  child: NeonButton(
                    text: 'Guardar Colaborador',
                    primary: true,
                    icon: Icons.save,
                    onTap: _save,
                    isLoading: _isLoading,
                  ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector(String label, DateTime? date, Function(DateTime) onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () async {
            final d = await showDatePicker(
              context: context,
              firstDate: DateTime(2000),
              lastDate: DateTime(2050),
              initialDate: date ?? DateTime.now(),
              builder: (ctx, child) {
                return Theme(data: ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(primary: Color(0xFF00E5FF), onPrimary: Colors.black, surface: Color(0xFF001225)),
                ), child: child!);
              },
            );
            if (d != null) onSelect(d);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null ? DateFormat('dd/MM/yyyy').format(date) : 'Seleccionar Fecha', 
                  style: GoogleFonts.outfit(color: date != null ? Colors.white : Colors.white38)
                ),
                const Icon(Icons.calendar_today, color: Color(0xFF00E5FF), size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
