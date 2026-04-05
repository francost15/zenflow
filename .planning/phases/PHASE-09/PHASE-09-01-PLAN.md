# PHASE-09-01-PLAN

phase_id: PHASE-09
plan_id: PHASE-09-01-PLAN

## Objetivo

Cerrar brechas de calidad detectadas tras el arreglo de build (DI en árbol de widgets, dependencias): pruebas E2E mínimas, consistencia visual en calendario, y cumplimiento de `repo_structure_test` (cada archivo por debajo de 250 líneas).

## Task Scores

| Task ID | Plan ID | Phase ID | Impact | Risk Closed | Effort | Verifiability | Dependency Unlock | Estimated | Validation Factor | Required |
|---------|---------|---------|--------|-------------|--------|---------------|------------------|-----------|------------------|----------|
| PHASE-09-01-PLAN-T01 | PHASE-09-01-PLAN | PHASE-09 | 3 | 4 | 3 | 5 | 4 | 19 | 1.0 | true |
| PHASE-09-01-PLAN-T02 | PHASE-09-01-PLAN | PHASE-09 | 3 | 3 | 2 | 4 | 3 | 15 | 1.0 | true |
| PHASE-09-01-PLAN-T03 | PHASE-09-01-PLAN | PHASE-09 | 2 | 3 | 3 | 4 | 2 | 14 | 1.0 | true |

### T01 — Integration / smoke E2E

- Añadir `integration_test/` con al menos un smoke que arranque la app (o `main_test.dart` documentado en CI) y alinear el README si el comando `integration_test/` aún no aplica.

### T02 — Calendario y `AppColors`

- Sustituir literales en `calendar_grid.dart` (y widgets relacionados) por `AppColors` para alinear acentos con el resto de la app.

### T03 — `repo_structure_test`

- Dividir o extraer widgets/helpers en `home_header.dart`, `zen_mode_screen.dart` y `create_task_dialog.dart` hasta que todos queden bajo el umbral de 250 líneas.

## Verify

```bash
flutter analyze
flutter test
flutter build linux --debug
```

## Files Modified

- TBD

## Dependencies

- PHASE-08
