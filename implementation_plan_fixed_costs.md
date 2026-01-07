# Implementation Plan - Fixed Costs Calculator

## Goal
Create a professional "Fixed Costs (Overhead)" calculator within the "Centro de Calculadoras" that allows users to track recurring costs, prorate them, and calculate break-even points.

## Proposed Changes

### 1. Data Models
Create `lib/src/calculators/fixed_costs/fixed_costs_models.dart`:
- `enum CostFrequency`: Daily, Weekly, Biweekly, Monthly, Bimonthly, Quarterly, Semiannual, Annual.
- `class FixedCostItem`: id, name, category, frequency, amount, notes.
- `class FixedCostsScenario`: id, name, items (List<FixedCostItem>).

### 2. Logic & Persistence
Create `lib/src/calculators/fixed_costs/fixed_costs_logic.dart`:
- Calculation methods for monthly/annual equivalents.
- `class FixedCostsService`: methods to save/load scenarios using `SharedPreferences`.

### 3. UI Implementation
Create `lib/src/screens/calculators/fixed_costs_screen.dart`:
- **Header**: KPI Cards (Total Monthly, Annual, Daily).
- **Body**: 
    - Quick Add Chips.
    - Data Table (Name, Freq, Amount, Monthly Eq, Actions).
- **Footer/Tabs**: 
    - Tab 1: Summary (Category breakdown chart/list).
    - Tab 2: Break-even Point (Inputs for Price/Variable Cost).

### 4. Integration
- Update `lib/src/navigation/app_routes.dart`: Add `fixedCosts` route.
- Update `lib/src/screens/calculadoras_screen.dart`: Replace placeholder item with real navigation.

## Verification
- Manual verification of calculations (e.g., proper annual to monthly conversation).
- check persistence by reloading app (simulated).
- Verify navigation from Calculator Center.
