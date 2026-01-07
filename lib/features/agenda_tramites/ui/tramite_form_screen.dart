// Tramite Form Screen
// Add or edit tramite

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../../ui/theme/color_palette.dart';
import '../domain/tramite_event.dart';
import '../domain/agenda_rules.dart';
import '../data/agenda_repository.dart';

class TramiteFormScreen extends StatefulWidget {
  final TramiteEvent? tramite;

  const TramiteFormScreen({Key? key, this.tramite}) : super(key: key);

  @override
  State<TramiteFormScreen> createState() => _TramiteFormScreenState();
}

class _TramiteFormScreenState extends State<TramiteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = AgendaRepository();
  final _uuid = const Uuid();

  late TextEditingController _tituloController;
  late TextEditingController _descripcionController;
  late TextEditingController _notasController;
  late TextEditingController _cadaXDiasController;

  late CategoriaEntidad _categoria;
  late String _entidad;
  late DateTime _fechaInicio;
  late Periodicidad _periodicidad;
  late int _diasAnticipacion;
  int? _cadaXDias;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    
    if (widget.tramite != null) {
      // Edit mode
      final t = widget.tramite!;
      _tituloController = TextEditingController(text: t.titulo);
      _descripcionController = TextEditingController(text: t.descripcion);
      _notasController = TextEditingController(text: t.notas ?? '');
      _cadaXDiasController = TextEditingController(
        text: t.cadaXDias?.toString() ?? '',
      );
      
      _categoria = t.categoria;
      _entidad = t.entidad;
      _fechaInicio = t.fechaInicio;
      _periodicidad = t.periodicidad;
      _diasAnticipacion = t.diasAnticipacionAlerta;
      _cadaXDias = t.cadaXDias;
    } else {
      // Add mode
      _tituloController = TextEditingController();
      _descripcionController = TextEditingController();
      _notasController = TextEditingController();
      _cadaXDiasController = TextEditingController();
      
      _categoria = CategoriaEntidad.otro;
      _entidad = 'Otro';
      _fechaInicio = DateTime.now();
      _periodicidad = Periodicidad.mensual;
      _diasAnticipacion = 7;
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _notasController.dispose();
    _cadaXDiasController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final now = DateTime.now();
      final proximaFecha = AgendaRules.calcularProximaFecha(
        _fechaInicio,
        _periodicidad,
        _cadaXDias,
      );
      final estado = AgendaRules.calcularEstado(proximaFecha);

      final tramite = TramiteEvent(
        id: widget.tramite?.id ?? _uuid.v4(),
        titulo: _tituloController.text.trim(),
        categoria: _categoria,
        entidad: _entidad,
        descripcion: _descripcionController.text.trim(),
        fechaInicio: _fechaInicio,
        periodicidad: _periodicidad,
        cadaXDias: _cadaXDias,
        proximaFecha: proximaFecha,
        diasAnticipacionAlerta: _diasAnticipacion,
        estado: estado,
        notas: _notasController.text.trim().isEmpty 
            ? null 
            : _notasController.text.trim(),
        createdAt: widget.tramite?.createdAt ?? now,
        updatedAt: now,
      );

      await _repository.upsert(tramite);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.background : Colors.white,
        elevation: 0,
        title: Text(
          widget.tramite == null ? 'Nuevo Trámite' : 'Editar Trámite',
          style: GoogleFonts.outfit(
            color: isDark ? AppColors.premiumGold : AppColors.lightTextPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(
          color: isDark ? AppColors.premiumGold : AppColors.lightAccent,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTextField(
              controller: _tituloController,
              label: 'Título *',
              hint: 'Ej: Declaración de Renta',
              isDark: isDark,
              validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
            ),
            const SizedBox(height: 16),

            _buildCategoriaDropdown(isDark),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _descripcionController,
              label: 'Descripción',
              hint: 'Descripción del trámite',
              isDark: isDark,
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            _buildDatePicker(isDark),
            const SizedBox(height: 16),

            _buildPeriodicidadDropdown(isDark),
            const SizedBox(height: 16),

            if (_periodicidad == Periodicidad.personalizada)
              _buildTextField(
                controller: _cadaXDiasController,
                label: 'Cada cuántos días *',
                hint: 'Ej: 90',
                isDark: isDark,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (_periodicidad == Periodicidad.personalizada) {
                    if (v?.isEmpty ?? true) return 'Requerido';
                    final num = int.tryParse(v!);
                    if (num == null || num <= 0) return 'Número inválido';
                  }
                  return null;
                },
                onChanged: (v) {
                  setState(() {
                    _cadaXDias = int.tryParse(v);
                  });
                },
              ),

            if (_periodicidad == Periodicidad.personalizada)
              const SizedBox(height: 16),

            _buildAlertasDropdown(isDark),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _notasController,
              label: 'Notas',
              hint: 'Notas adicionales',
              isDark: isDark,
              maxLines: 4,
            ),
            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                        color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    child: Text(
                      'Cancelar',
                      style: GoogleFonts.outfit(
                        color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _guardar,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: isDark ? AppColors.premiumGold : AppColors.lightAccent,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            'Guardar',
                            style: GoogleFonts.outfit(
                              color: isDark ? AppColors.background : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDark,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      style: TextStyle(
        color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
          color: isDark ? AppColors.premiumGold : AppColors.lightAccent,
        ),
        hintStyle: TextStyle(
          color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
        ),
        filled: true,
        fillColor: isDark ? AppColors.surface : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildCategoriaDropdown(bool isDark) {
    return DropdownButtonFormField<CategoriaEntidad>(
      value: _categoria,
      decoration: InputDecoration(
        labelText: 'Categoría *',
        labelStyle: TextStyle(
          color: isDark ? AppColors.premiumGold : AppColors.lightAccent,
        ),
        filled: true,
        fillColor: isDark ? AppColors.surface : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      dropdownColor: isDark ? AppColors.surface : Colors.white,
      style: TextStyle(
        color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
      ),
      items: CategoriaEntidad.values.map((cat) {
        return DropdownMenuItem(
          value: cat,
          child: Text(cat.displayName),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _categoria = value;
            _entidad = value.displayName;
          });
        }
      },
    );
  }

  Widget _buildPeriodicidadDropdown(bool isDark) {
    return DropdownButtonFormField<Periodicidad>(
      value: _periodicidad,
      decoration: InputDecoration(
        labelText: 'Periodicidad *',
        labelStyle: TextStyle(
          color: isDark ? AppColors.premiumGold : AppColors.lightAccent,
        ),
        filled: true,
        fillColor: isDark ? AppColors.surface : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      dropdownColor: isDark ? AppColors.surface : Colors.white,
      style: TextStyle(
        color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
      ),
      items: Periodicidad.values.map((per) {
        return DropdownMenuItem(
          value: per,
          child: Text(per.displayName),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _periodicidad = value);
        }
      },
    );
  }

  Widget _buildAlertasDropdown(bool isDark) {
    return DropdownButtonFormField<int>(
      value: _diasAnticipacion,
      decoration: InputDecoration(
        labelText: 'Alertas con anticipación',
        labelStyle: TextStyle(
          color: isDark ? AppColors.premiumGold : AppColors.lightAccent,
        ),
        filled: true,
        fillColor: isDark ? AppColors.surface : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      dropdownColor: isDark ? AppColors.surface : Colors.white,
      style: TextStyle(
        color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
      ),
      items: [7, 15, 30].map((dias) {
        return DropdownMenuItem(
          value: dias,
          child: Text('$dias días antes'),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _diasAnticipacion = value);
        }
      },
    );
  }

  Widget _buildDatePicker(bool isDark) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _fechaInicio,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) {
          setState(() => _fechaInicio = picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Fecha base *',
          labelStyle: TextStyle(
            color: isDark ? AppColors.premiumGold : AppColors.lightAccent,
          ),
          filled: true,
          fillColor: isDark ? AppColors.surface : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_fechaInicio.day}/${_fechaInicio.month}/${_fechaInicio.year}',
              style: TextStyle(
                color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
              ),
            ),
            Icon(
              Icons.calendar_today,
              color: isDark ? AppColors.premiumGold : AppColors.lightAccent,
            ),
          ],
        ),
      ),
    );
  }
}
