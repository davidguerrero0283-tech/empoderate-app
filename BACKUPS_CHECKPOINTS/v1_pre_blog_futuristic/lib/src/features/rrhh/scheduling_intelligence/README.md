# RRHH Smart Scheduling v1 🧠

Sistema inteligente de planificación de horarios con motor de reglas, puntajes, explicaciones, simulaciones y auditoría.

## 🎯 Características

### 1. Motor de Reglas Dual
- **Hard Constraints (Bloqueantes)**: Reglas que NO se pueden violar
- **Soft Constraints (Puntuación)**: Preferencias que mejoran la calidad del horario

### 2. Sistema de Explicaciones
Cada sugerencia incluye:
- Resumen ejecutivo
- Razones detalladas con impactos (+/-)
- Restricciones verificadas
- Delta de equidad

### 3. Simulación de Cambios
Antes de aplicar cambios, simula:
- Violaciones de reglas hard
- Score total + desglose
- Métricas de equidad
- Alternativas optimizadas

### 4. Auditoría Completa
Registra:
- Quién hizo el cambio
- Cuándo se hizo
- Estado before/after
- Motivo del cambio
- Cambio en score

## 🚀 Activación

### Feature Flag

En `lib/src/features/schedule_management/logic/schedule_controller.dart`:

```dart
bool enableSmartSchedulingV1 = true; // Set to true to enable
```

### Configuración de Pesos

En `ScheduleConfig`:

```dart
softConstraintWeights: {
  'fairness': 0.4,      // Equidad en distribución
  'preferences': 0.3,    // Preferencias de empleados
  'fatigue': 0.2,        // Prevención de fatiga
  'stability': 0.1,      // Estabilidad de horarios
}
```

Ajusta estos valores según tus prioridades. La suma debe ser 1.0.

## 📐 Hard Constraints (Reglas Bloqueantes)

### 1. Descanso Mínimo
- **Descripción**: Horas mínimas entre turnos
- **Configuración**: `minHoursRestBetweenShifts` (default: 12h)
- **Ejemplo**: Si trabajas hasta las 10pm, no puedes trabajar antes de las 10am del día siguiente

### 2. Máximo Horas Semanales
- **Descripción**: Límite legal de horas por semana
- **Configuración**: `maxHoursPerWeek` (default: 48h - Panamá Law)
- **Ejemplo**: No se puede asignar más de 48 horas semanales

### 3. Máximo Días Consecutivos
- **Descripción**: Días máximos de trabajo sin descanso
- **Configuración**: `maxConsecutiveDays` (default: 6)
- **Ejemplo**: Después de 6 días trabajando, se requiere 1 día de descanso

### 4. No Asignar en Licencias
- **Tipos cubiertos**:
  - Vacaciones programadas
  - Licencias médicas
  - Maternidad/Paternidad
  - Incapacidades
- **Automático**: El sistema verifica `unavailableDates` y `isOnMaternityLeave`

### 5. No Solapamientos
- **Descripción**: Un empleado no puede tener 2 turnos simultáneos
- **Verificación**: Automática en asignaciones

### 6. Elegibilidad por Rol
- **Descripción**: Solo asignar turnos para los cuales el empleado está calificado
- **Configuración**: `eligibleShiftIds` (vacío = todos los turnos)

### 7. Cobertura Mínima
- **Descripción**: Cada turno debe tener mínimo X empleados
- **Configuración**: `minCoveragePerShift` (default: 1)

### 8. Feriados
- **Fuente**: Cache local de feriados de Panamá
- **Aplicación**: Pago doble, restricciones especiales

## 📊 Soft Constraints (Puntuación 0-100)

### 1. Equidad (40% peso default)
Distribuye equitativamente:
- Turnos nocturnos
- Fines de semana
- Feriados
- Turnos "rush" (picos de demanda)

**Cálculo**: Desviación estándar de distribución

### 2. Preferencias (30% peso default)
Respeta:
- Días libres preferidos
- Horarios preferidos
- Solicitudes especiales

**Cálculo**: % de preferencias satisfechas

### 3. Prevención de Fatiga (20% peso default)
Evita:
- Muchos turnos pesados consecutivos
- Cambios frecuentes de horario
- Turnos dobles

**Cálculo**: Score de fatiga acumulada

### 4. Estabilidad (10% peso default)
Minimiza:
- Cambios de último minuto
- Variabilidad semanal excesiva

**Cálculo**: Diferencia con patrones históricos

## 🔧 Uso Práctico

### En Auto-Generación

```dart
// El sistema automáticamente usa inteligencia si el flag está activo
await controller.autoGenerateSchedule(config: myConfig);

// Internamente:
if (enableSmartSchedulingV1) {
  result = await intelligenceService.generateOptimalSchedule(context);
  // Incluye explicaciones automáticas
}
```

### En Solicitudes de Cambio

```dart
// Simula antes de aplicar
final simulation = await simulationService.simulateChange(
  context: scheduleContext,
  proposedChange: newAssignment,
);

if (simulation.hasHardViolations) {
  // Muestra violaciones al usuario
  showDialog(violations: simulation.hardViolations);
  return; // NO aplicar
}

// Muestra preview con score
showPreview(
  currentScore: simulation.scoreBefore,
  newScore: simulation.scoreAfter,
  reasons: simulation.topReasons,
);
```

### Ver Explicación

```dart
// Obtén explicación de una asignación
final explanation = intelligenceService.explainAssignment(
  worker: employee,
  shift: proposedShift,
  context: scheduleContext,
);

// Mostrar al usuario
showDialog(
  title: explanation.summary,
  content: explanation.reasons,
  metrics: explanation.fairnessDelta,
);
```

## 📱 UI Integrada

### 1. Botón "Ver Explicación"
- Ubicación: En cada celda de asignación del grid
- Acción: Muestra por qué se sugiere/no sugiere ese turno

### 2. Modal "Vista Previa"
Aparece en:
- Auto-generación de horarios
- Solicitudes de cambio de turno

Muestra:
- Score actual vs propuesto
- Top 5 razones del cambio
- Violaciones críticas (si existen)
- Alternativas sugeridas

### 3. Panel de Auditoría
- Historial de cambios
- Filtros por empleado, fecha, tipo
- Exportable a CSV

## 🧪 Pruebas Incluidas

### Test 1: No Asigna en Maternidad
```dart
worker.isOnMaternityLeave = true;
result = intelligenceService.canAssign(worker, shift);
assert(result.isBlocked == true);
assert(result.reason == "Empleada en licencia de maternidad");
```

### Test 2: Respeta Descanso Mínimo
```dart
worker.lastShiftEnd = DateTime(2024, 1, 1, 22, 0); // 10pm
proposedShift.start = DateTime(2024, 1, 2, 6, 0);  // 6am next day
result = intelligenceService.canAssign(worker, proposedShift);
assert(result.isBlocked == true); // Solo 8h de descanso
```

### Test 3: Simulación Bloquea Violaciones
```dart
simulation = simulationService.simulate(illegalChange);
assert(simulation.hasHardViolations == true);
assert(simulation.canApply == false);
```

### Test 4: Explicación No Vacía
```dart
explanation = intelligenceService.explain(assignment);
assert(explanation.summary.isNotEmpty);
assert(explanation.reasons.length > 0);
```

## 📂 Estructura de Archivos

```
lib/src/features/rrhh/scheduling_intelligence/
├── models/
│   ├── schedule_context.dart         # Agregador de contexto
│   ├── suggestion.dart                # Sugerencia con score
│   ├── explanation.dart               # Explicación detallada
│   ├── constraint_result.dart         # Resultado de validación
│   └── audit_event.dart               # Evento de auditoría
│
├── rules/
│   ├── hard_constraints.dart          # Restricciones bloqueantes
│   ├── soft_constraints.dart          # Restricciones de calidad
│   └── rule_engine.dart               # Motor de evaluación
│
├── services/
│   ├── scheduling_intelligence_service.dart  # Servicio principal
│   ├── schedule_simulation_service.dart      # Simulación de cambios
│   ├── schedule_audit_service.dart           # Registro de auditoría
│   └── schedule_fairness_service.dart        # Cálculo de equidad
│
└── utils/
    ├── schedule_metrics.dart          # Métricas y KPIs
    └── time_utils.dart                # Utilidades de tiempo
```

## 🎨 Personalización Avanzada

### Crear Constraint Personalizado

```dart
class CustomConstraint implements SoftConstraint {
  @override
  double evaluate(ScheduleContext context, Assignment assignment) {
    // Tu lógica aquí
    return score; // 0-100
  }
  
  @override
  String get name => "Mi Regla Custom";
  
  @override
  String explain(ScheduleContext context, Assignment assignment) {
    return "Razón de la evaluación";
  }
}

// Registrar
softConstraints.add(CustomConstraint());
```

### Ajustar Límites por Empleado

```dart
WorkerConstraints customConstraints = WorkerConstraints(
  workerId: "123",
  maxHoursPerWeek: 40, // Part-time
  maxConsecutiveDays: 4, // Menos días
  minHoursRestBetweenShifts: 16, // Más descanso
  preferredOffDays: [DateTime.sunday], // Domingos libres
);
```

## 📈 Métricas de Calidad

El sistema genera automáticamente:
- **Utilization Rate**: % de horas cubiertas vs necesarias
- **Fairness Score**: Distribución equitativa (0-100)
- **Satisfaction Score**: Preferencias satisfechas (0-100)
- **Compliance Score**: Cumplimiento legal (0-100)
- **Stability Index**: Consistencia de horarios (0-100)

## 🔐 Auditoría y Trazabilidad

Cada cambio registra:
```json
{
  "timestamp": "2024-01-15T10:30:00Z",
  "userId": "manager_123",
  "action": "ASSIGNMENT_CHANGED",
  "workerId": "emp_456",
  "before": {...},
  "after": {...},
  "reason": "Emergency coverage",
  "scoreBefore": 85.3,
  "scoreAfter": 82.1,
  "topReasons": [...]
}
```

## 🚨 Troubleshooting

### Problema: "Score muy bajo"
**Solución**: Revisa los pesos en `softConstraintWeights`. Puede que estés priorizando un constraint difícil de satisfacer.

### Problema: "Muchas violaciones hard"
**Solución**: Relaja los límites en `ScheduleConfig` o verifica que los datos de entrada (vacaciones, disponibilidad) estén correctos.

### Problema: "El sistema no sugiere nada"
**Solución**: Asegúrate de tener suficientes empleados elegibles para cubrir los turnos requeridos.

## 📝 Changelog

### v1.0.0 (Enero 2024)
- ✅ Motor de reglas dual (hard + soft)
- ✅ Sistema de explicaciones
- ✅ Simulación de cambios
- ✅ Auditoría completa
- ✅ Integración con UI existente
- ✅ Feature flag

## 🤝 Contribuir

Para agregar nuevas reglas o mejorar el sistema:
1. Crea una nueva constraint en `rules/`
2. Registra en el engine correspondiente
3. Agrega tests
4. Actualiza este README

## 📞 Soporte

Para preguntas o issues:
- Revisa la documentación inline en cada archivo
- Consulta los tests como ejemplos de uso
- Verifica los logs de auditoría para debugging

---

**Desarrollado con ❤️ para Empodérate RRHH**
