# Implementation Plan - Export & Share Features

## Goal
Enable users to export Fixed Costs scenarios to PDF and DOCX, share them, and manage saved scenarios (Save/Save As).

## Proposed Changes

### 1. Dependencies
- Add `docx_template` (or similar lightweight option) to `pubspec.yaml` for Word export.
- `pdf` and `printing` are already available.
- `share_plus` is already detailed.

### 2. Export Service
Create `lib/src/calculators/fixed_costs/fixed_costs_export_service.dart`:
- `pw.Document generatePdf(FixedCostsScenario scenario)`: Builds the PDF document.
- `Future<void> exportPdf(FixedCostsScenario scenario)`: Handles saving/previewing/printing.
- `Future<void> exportDocx(FixedCostsScenario scenario)`: Handles generating and saving DOCX.
- `Future<void> shareScenario(FixedCostsScenario scenario)`: Handles sharing content or files using `share_plus`.

### 3. Logic Update
Update `lib/src/calculators/fixed_costs/fixed_costs_logic.dart`:
- Ensure `saveScenario` handles updates correctly.
- Add `duplicateScenario` method for "Save As".

### 4. UI Updates
Update `lib/src/screens/calculators/fixed_costs_screen.dart`:
- **AppBar**: Add "Actions" menu (PopupMenuButton).
    - Items: Guardar, Guardar Como, Exportar PDF, Exportar Word, Compartir.
- **Save As Modal**: Simple dialog to input new name.
- **Share Logic**: Call the export service methods.

## Verification
- Verify "Save" updates the existing record.
- Verify "Save As" creates a new record.
- Verify "Export PDF" opens the print preview or shares the file.
- Verify "Export Word" saves a .docx file.
