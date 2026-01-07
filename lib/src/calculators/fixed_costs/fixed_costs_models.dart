import 'dart:convert';

enum CostFrequency {
  diario,
  semanal,
  quincenal,
  mensual,
  bimestral,
  trimestral,
  semestral,
  anual
}

extension CostFrequencyExtension on CostFrequency {
  String get label {
    switch (this) {
      case CostFrequency.diario: return 'Diario';
      case CostFrequency.semanal: return 'Semanal';
      case CostFrequency.quincenal: return 'Quincenal';
      case CostFrequency.mensual: return 'Mensual';
      case CostFrequency.bimestral: return 'Bimestral';
      case CostFrequency.trimestral: return 'Trimestral';
      case CostFrequency.semestral: return 'Semestral';
      case CostFrequency.anual: return 'Anual';
    }
  }

  double get monthlyFactor {
    // Convert to monthly equivalent
    switch (this) {
      case CostFrequency.diario: return 365 / 12;
      case CostFrequency.semanal: return 52 / 12;
      case CostFrequency.quincenal: return 26 / 12; // Approx 2.166
      case CostFrequency.mensual: return 1.0;
      case CostFrequency.bimestral: return 0.5;
      case CostFrequency.trimestral: return 1/3;
      case CostFrequency.semestral: return 1/6;
      case CostFrequency.anual: return 1/12;
    }
  }
}

class FixedCostItem {
  final String id;
  String name;
  String category;
  CostFrequency frequency;
  double amount;
  String? notes;
  
  FixedCostItem({
    required this.id,
    required this.name,
    required this.category,
    required this.frequency,
    required this.amount,
    this.notes,
  });

  double get monthlyEquivalent => amount * frequency.monthlyFactor;
  double get annualEquivalent => monthlyEquivalent * 12;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'frequency': frequency.index,
      'amount': amount,
      'notes': notes,
    };
  }

  factory FixedCostItem.fromMap(Map<String, dynamic> map) {
    return FixedCostItem(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      frequency: CostFrequency.values[map['frequency']],
      amount: map['amount'],
      notes: map['notes'],
    );
  }
}

class FixedCostsScenario {
  final String id;
  String name;
  List<FixedCostItem> items;
  DateTime lastUpdated;

  FixedCostsScenario({
    required this.id,
    required this.name,
    required this.items,
    required this.lastUpdated,
  });

  double get totalMonthly => items.fold(0, (sum, item) => sum + item.monthlyEquivalent);
  double get totalAnnual => totalMonthly * 12;
  double get dailyEquivalent => totalAnnual / 365;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'items': items.map((x) => x.toMap()).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory FixedCostsScenario.fromMap(Map<String, dynamic> map) {
    return FixedCostsScenario(
      id: map['id'],
      name: map['name'],
      items: List<FixedCostItem>.from(map['items']?.map((x) => FixedCostItem.fromMap(x))),
      lastUpdated: DateTime.parse(map['lastUpdated']),
    );
  }
  
  String toJson() => json.encode(toMap());
  
  factory FixedCostsScenario.fromJson(String source) => FixedCostsScenario.fromMap(json.decode(source));
}
