import 'package:flutter/material.dart';

enum SubscriptionPlan {
  inicio,       // Free
  crecimiento,  // Basic Paid
  pro,          // Professional
  empresarial   // Enterprise
}

enum PlanFeature {
  unlimitedCalculators, // Crecimiento+
  exportExcel,          // Crecimiento+
  exportPdf,            // Pro+
  aiAssistant,          // Pro+
  advancedAudit,        // Pro+
  multiBusiness,        // Empresarial
  digitalVault,         // Pro+
  dedicatedSupport,     // Empresarial
}

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();

  factory SubscriptionService() {
    return _instance;
  }

  SubscriptionService._internal();

  // MOCK STATE - In a real app this comes from backend/purchases
  SubscriptionPlan _currentPlan = SubscriptionPlan.empresarial; // Default God Mode for Demo

  SubscriptionPlan get currentPlan => _currentPlan;

  void setPlan(SubscriptionPlan plan) {
    _currentPlan = plan;
  }

  bool hasAccess(PlanFeature feature) {
    switch (feature) {
      // INICIO (Free) gets: Basic Access only
      
      // CRECIMIENTO (Tier 1)
      case PlanFeature.unlimitedCalculators:
      case PlanFeature.exportExcel:
        return _currentPlan != SubscriptionPlan.inicio;

      // PRO (Tier 2)
      case PlanFeature.exportPdf:
      case PlanFeature.aiAssistant:
      case PlanFeature.advancedAudit:
      case PlanFeature.digitalVault:
        return _currentPlan == SubscriptionPlan.pro || _currentPlan == SubscriptionPlan.empresarial;

      // EMPRESARIAL (Tier 3)
      case PlanFeature.multiBusiness:
      case PlanFeature.dedicatedSupport:
        return _currentPlan == SubscriptionPlan.empresarial;
    }
  }

  String getPlanName() {
    switch (_currentPlan) {
      case SubscriptionPlan.inicio: return 'Plan Inicio';
      case SubscriptionPlan.crecimiento: return 'Plan Crecimiento';
      case SubscriptionPlan.pro: return 'Plan Pro';
      case SubscriptionPlan.empresarial: return 'Plan Empresarial';
    }
  }
}
