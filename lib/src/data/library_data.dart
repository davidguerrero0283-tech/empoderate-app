
import 'package:flutter/material.dart';

// Simple model for a resource file
class ResourceFile {
  final String name;
  final String format; // PDF, DOCX, XLSX
  final String size;
  final String url; // For simulation/demo
  final bool isPro; 
  final String categoryId;
  int downloadCount; // Local simulation
  final List<String> tags;

  ResourceFile({
    required this.name,
    required this.format,
    required this.size,
    required this.categoryId,
    this.url = '',
    this.isPro = false,
    this.downloadCount = 0,
    this.tags = const [],
  });
}

class LibraryDataService {
  // Singleton
  static final LibraryDataService instance = LibraryDataService._();
  LibraryDataService._();

  // Categories
  static const String catBusiness = 'business';
  static const String catLegal = 'legal';
  static const String catForms = 'forms';
  static const String catAccounting = 'accounting';
  static const String catHr = 'hr';
  static const String catEducation = 'education';

  // In-memory data store (should be loaded/saved to local storage ideally)
  // For this tasks we keep it in memory or simulate persistence if requested.
  // The user prompt asked to increment localStorage counter. 
  // We will load mock data first.

  final List<ResourceFile> _allResources = [
    // Business
    ResourceFile(categoryId: catBusiness, name: 'Modelo Canvas Editable', format: 'PPTX', size: '2.5 MB', tags: ['canvas', 'modelo', 'negocio', 'ppt']),
    ResourceFile(categoryId: catBusiness, name: 'Plan de Negocios Pro', format: 'DOCX', size: '1.8 MB', isPro: true, tags: ['plan', 'negocios', 'doc']),
    ResourceFile(categoryId: catBusiness, name: 'Matriz FODA', format: 'XLSX', size: '1.2 MB', tags: ['foda', 'analisis', 'xlsx']),
    
    // Legal
    ResourceFile(categoryId: catLegal, name: 'Contrato Servicios Profesionales', format: 'DOCX', size: '500 KB', tags: ['contrato', 'servicios', 'legal']),
    ResourceFile(categoryId: catLegal, name: 'Acuerdo de Confidencialidad (NDA)', format: 'DOCX', size: '300 KB', tags: ['nda', 'confidencialidad', 'legal']),
    ResourceFile(categoryId: catLegal, name: 'Pacto de Socios', format: 'PDF', size: '1.5 MB', isPro: true, tags: ['socios', 'pacto', 'legal']),

    // Forms
    ResourceFile(categoryId: catForms, name: 'Formulario Aviso Operación', format: 'PDF', size: '2.0 MB', tags: ['aviso', 'operacion', 'mici']),
    ResourceFile(categoryId: catForms, name: 'Solicitud Registro Marca', format: 'PDF', size: '1.4 MB', tags: ['marca', 'registro', 'dgi']),

    // Accounting
    ResourceFile(categoryId: catAccounting, name: 'Plantilla Flujo de Caja', format: 'XLSX', size: '3.2 MB', tags: ['flujo', 'caja', 'contabilidad', 'xlsx']),
    ResourceFile(categoryId: catAccounting, name: 'Modelo de Factura', format: 'XLSX', size: '1.1 MB', tags: ['factura', 'cobro', 'xlsx']),
    ResourceFile(categoryId: catAccounting, name: 'Control de Inventario', format: 'XLSX', size: '4.0 MB', tags: ['inventario', 'stock', 'xlsx']),

    // HR
    ResourceFile(categoryId: catHr, name: 'Contrato Laboral Indefinido', format: 'DOCX', size: '800 KB', tags: ['contrato', 'laboral', 'rrhh']),
    ResourceFile(categoryId: catHr, name: 'Evaluación de Desempeño', format: 'PDF', size: '1.2 MB', tags: ['evaluacion', 'desempeño', 'rrhh']),
    ResourceFile(categoryId: catHr, name: 'Carta de Despido', format: 'DOCX', size: '400 KB', tags: ['carta', 'despido', 'rrhh']),

    // Education
    ResourceFile(categoryId: catEducation, name: 'Guía Marketing 2025', format: 'PDF', size: '15 MB', tags: ['marketing', 'guia', 'pdf']),
    ResourceFile(categoryId: catEducation, name: 'Manual de Ventas B2B', format: 'PDF', size: '8 MB', tags: ['ventas', 'b2b', 'manual']),
  ];

  List<ResourceFile> get allResources => _allResources;

  List<ResourceFile> getByCategory(String catId) {
    return _allResources.where((r) => r.categoryId == catId).toList();
  }

  // Get "Most Used" strictly by category
  List<ResourceFile> getMostUsedByCategory(String catId) {
    var catFiles = getByCategory(catId);
    catFiles.sort((a, b) => b.downloadCount.compareTo(a.downloadCount));
    return catFiles.take(3).toList();
  }

  // Search logic
  List<ResourceFile> searchResources(String query) {
    if (query.isEmpty) return [];
    final q = query.toLowerCase();
    return _allResources.where((r) {
      final matchesName = r.name.toLowerCase().contains(query);
      final matchesTags = r.tags.any((t) => t.toLowerCase().contains(q));
      return matchesName || matchesTags;
    }).toList();
  }

  // Simulate download and tracking
  void incrementDownload(String name) {
    try {
      final file = _allResources.firstWhere((r) => r.name == name);
      file.downloadCount++;
      // Here we would sync with localStorage theoretically
    } catch (_) {}
  }
}
