// Data models for dynamic form fields in AI Generic features
// These models capture all necessary data to generate complete documents without placeholders

/// Form data for Product/Service catalog generation
class ProductFormData {
  final String price;              // B/. amount
  final String material;           // Materials/composition
  final String dimensions;         // Size/measurements
  final String warranty;           // Warranty period in months/years
  final String deliveryTime;       // Delivery timeframe
  final String phone;              // Contact WhatsApp/phone
  final String email;              // Contact email
  final String address;            // Physical location

  ProductFormData({
    this.price = '',
    this.material = '',
    this.dimensions = '',
    this.warranty = '',
    this.deliveryTime = '',
    this.phone = '',
    this.email = '',
    this.address = '',
  });

  Map<String, dynamic> toJson() => {
    'price': price,
    'material': material,
    'dimensions': dimensions,
    'warranty': warranty,
    'deliveryTime': deliveryTime,
    'phone': phone,
    'email': email,
    'address': address,
  };

  factory ProductFormData.fromJson(Map<String, dynamic> json) => ProductFormData(
    price: json['price'] ?? '',
    material: json['material'] ?? '',
    dimensions: json['dimensions'] ?? '',
    warranty: json['warranty'] ?? '',
    deliveryTime: json['deliveryTime'] ?? '',
    phone: json['phone'] ?? '',
    email: json['email'] ?? '',
    address: json['address'] ?? '',
  );
}

/// Form data for Contract generation
class ContractFormData {
  final String party1Name;         // Arrendador/Empleador/Contratante
  final String party1Id;           // Cédula/RUC
  final String party1Address;      // Address
  final String party2Name;         // Arrendatario/Trabajador/Contratista
  final String party2Id;           // Cédula/RUC
  final String party2Address;      // Address
  final String amount;             // Salario/Renta/Honorarios
  final String startDate;          // Start date
  final String endDate;            // End date (if applicable)
  final String propertyAddress;    // For lease contracts
  final String position;           // For employment contracts
  final String services;           // For services contracts

  ContractFormData({
    this.party1Name = '',
    this.party1Id = '',
    this.party1Address = '',
    this.party2Name = '',
    this.party2Id = '',
    this.party2Address = '',
    this.amount = '',
    this.startDate = '',
    this.endDate = '',
    this.propertyAddress = '',
    this.position = '',
    this.services = '',
  });

  Map<String, dynamic> toJson() => {
    'party1Name': party1Name,
    'party1Id': party1Id,
    'party1Address': party1Address,
    'party2Name': party2Name,
    'party2Id': party2Id,
    'party2Address': party2Address,
    'amount': amount,
    'startDate': startDate,
    'endDate': endDate,
    'propertyAddress': propertyAddress,
    'position': position,
    'services': services,
  };

  factory ContractFormData.fromJson(Map<String, dynamic> json) => ContractFormData(
    party1Name: json['party1Name'] ?? '',
    party1Id: json['party1Id'] ?? '',
    party1Address: json['party1Address'] ?? '',
    party2Name: json['party2Name'] ?? '',
    party2Id: json['party2Id'] ?? '',
    party2Address: json['party2Address'] ?? '',
    amount: json['amount'] ?? '',
    startDate: json['startDate'] ?? '',
    endDate: json['endDate'] ?? '',
    propertyAddress: json['propertyAddress'] ?? '',
    position: json['position'] ?? '',
    services: json['services'] ?? '',
  );
}

/// Form data for Process/SOP generation
class ProcessFormData {
  final String responsibleName;    // Person responsible
  final String responsibleTitle;   // Job title
  final String approverName;       // Who approves
  final String department;         // Department/area
  final String targetPersonnel;    // Who executes (roles)
  final String estimatedTime;      // Time per process

  ProcessFormData({
    this.responsibleName = '',
    this.responsibleTitle = '',
    this.approverName = '',
    this.department = '',
    this.targetPersonnel = '',
    this.estimatedTime = '',
  });

  Map<String, dynamic> toJson() => {
    'responsibleName': responsibleName,
    'responsibleTitle': responsibleTitle,
    'approverName': approverName,
    'department': department,
    'targetPersonnel': targetPersonnel,
    'estimatedTime': estimatedTime,
  };

  factory ProcessFormData.fromJson(Map<String, dynamic> json) => ProcessFormData(
    responsibleName: json['responsibleName'] ?? '',
    responsibleTitle: json['responsibleTitle'] ?? '',
    approverName: json['approverName'] ?? '',
    department: json['department'] ?? '',
    targetPersonnel: json['targetPersonnel'] ?? '',
    estimatedTime: json['estimatedTime'] ?? '',
  );
}

/// Form data for Strategy/Business Plan generation
class StrategyFormData {
  final String budget;             // Total budget
  final String marketingBudget;    // Marketing budget
  final String techBudget;         // Technology budget
  final String responsibleName;    // Project owner
  final String responsibleTitle;   // Job title
  final String targetCustomers;    // New customer goal
  final String salesIncrease;      // Sales increase %

  StrategyFormData({
    this.budget = '',
    this.marketingBudget = '',
    this.techBudget = '',
    this.responsibleName = '',
    this.responsibleTitle = '',
    this.targetCustomers = '',
    this.salesIncrease = '',
  });

  Map<String, dynamic> toJson() => {
    'budget': budget,
    'marketingBudget': marketingBudget,
    'techBudget': techBudget,
    'responsibleName': responsibleName,
    'responsibleTitle': responsibleTitle,
    'targetCustomers': targetCustomers,
    'salesIncrease': salesIncrease,
  };

  factory StrategyFormData.fromJson(Map<String, dynamic> json) => StrategyFormData(
    budget: json['budget'] ?? '',
    marketingBudget: json['marketingBudget'] ?? '',
    techBudget: json['techBudget'] ?? '',
    responsibleName: json['responsibleName'] ?? '',
    responsibleTitle: json['responsibleTitle'] ?? '',
    targetCustomers: json['targetCustomers'] ?? '',
    salesIncrease: json['salesIncrease'] ?? '',
  );
}
