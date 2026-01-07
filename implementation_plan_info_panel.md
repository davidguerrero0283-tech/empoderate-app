# Implementation Plan - Calculator Info Panels

## Goal
Add detailed, educational info panels to the calculators to guide users on usage and interpretation of results, following the "Empodérate" premium style.

## Proposed Changes

### 1. New Component: `CalculatorInfoPanel`
Create `lib/src/components/calculator_info_panel.dart`:
- **UI Structure**: 
    - `InfoTopCard`: Reusable top banner with title, description bullets, and "Ver cómo usar" button.
    - `HowToCard`: Collapsible accordion (using `ExpansionTile` or custom state) containing:
        - Steps ("Cómo se usa")
        - Quick Example ("Ejemplo rápido")
        - Interpretation ("Cómo interpretar")
        - Common Errors ("Errores comunes")
- **Configuration**:
    - `CalculatorInfoConfig` class to hold the strings/lists for each section.
    - `CalculatorInfoData` map to store the configs for 'fixed_costs', 'margin', 'break_even'.

### 2. Integration
- **Fixed Costs Screen** (`fixed_costs_screen.dart`): Insert `CalculatorInfoPanel(configId: 'fixed_costs')` at the top of the body.
- **Margin Screen** (`margen_ganancia_screen.dart`): Replace the existing `_buildEducationBlock` with `CalculatorInfoPanel(configId: 'margin')`.
- **Break-even Screen** (`punto_equilibrio_screen.dart`): Insert `CalculatorInfoPanel(configId: 'break_even')` at the top or appropriate location.

### 3. Content Definition
Define the texts provided in the prompt strictly.

## Verification
- Check that the panel appears in all 3 screens.
- Verify "Ver cómo usar" toggles the How-To card.
- meaningful content matches the prompt.
