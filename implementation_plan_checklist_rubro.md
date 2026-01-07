# Implementation Plan - Checklist por Rubro

## Goal
Implement the "Trámites por Rubro" (Industry Specific) functionality using the new Checklist system, allowing users to select their business type and see specific requirements.

## Proposed Changes

### 1. Data Models
Update `lib/src/features/checklist/checklist_model.dart`:
- No major changes needed, but might add `industry` field if we want to filter by it, or just keep separate lists in `ChecklistData`.

### 2. Logic & Data
Update `lib/src/features/checklist/checklist_data.dart`:
- Add `rubroItems`: A map or list of items specific to industries like 'Restaurante', 'Retail', 'Servicios'.
    - *Example Restaurant*: "Carnet de Manipulación de Alimentos", "Fumigación Mensual", "Trampa de Grasa".
    - *Example Retail*: "Inventario Inicial", "Política de Devoluciones".

Update `lib/src/features/checklist/checklist_service.dart`:
- Add `loadItemsForRubro(String rubroId)`.
- Add persistence for rubro-specific items (key: `checklist_status_rubro_$id`).

### 3. UI Implementation
Create `lib/src/features/checklist/screens/checklist_rubro_selection_screen.dart`:
- A screen to select the industry (Restaurante, Retail, Servicios, Construcción).

Create `lib/src/features/checklist/screens/checklist_rubro_detail_screen.dart`:
- Similar to `ChecklistTramitesScreen` but focused on the specific industry items.
- Reuse `_CheckItem` logic.

### 4. Integration
- Update `ChecklistTramitesScreen`:
    - Link "Trámites según tipo de negocio" to `ChecklistRubroSelectionScreen`.
- Update `AppRoutes` to include new screens.

## Verification
- Select "Restaurante" -> Verify specific items appear (Carnet de salud).
- Check item -> Verify persistence.
