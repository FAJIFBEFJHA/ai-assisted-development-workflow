# PROJECT_CONTEXT — lab1-iot-node / Laboratorio 2

Actualizado: 2026-10-18 (cierre de diagnóstico E0). **Este archivo sirve para retomar, no sustituye la comprobación del repositorio.**

## Fuentes
- Producto: https://github.com/jmamanilari-cyber/lab1-iot-node
- Roadmap: `lab2/docs/ROADMAP.md` del producto.
- Workflow: https://github.com/FAJIFBEFJHA/ai-assisted-development-workflow
- Local habitual: `D:\Proyectos\Lab1_repositorio`. Lab1 histórico **no modificar**.
- Especificación local: `docs/Laboratior 2 guia.pdf`. Sesiones 5–8 pertinentes; sesión 9 corresponde al Lab3.

## Checkpoint software publicado
Remoto producto verificado: `c26627d` — integración segura MQTT D1. Commits anteriores: `e94abd4` SQL/PDO, `e0069b3` HTTP C1, `fc49604` REST C2. **No hay confirmación de cambios o commits locales posteriores de hardware; consultar `git status`.**

- PHP 8.2, MariaDB 10.4, XAMPP. Cuatro tablas: devices/telemetry/configurations/events; UNIQUE(device_id,seq); 3 identidades sembradas, no equivalen a 3 placas físicas.
- Cinco endpoints REST implementados y probados: POST `/api/v1/telemetry`, GET `/api/v1/devices`, GET `/api/v1/devices/{id}/telemetry`, PUT `/api/v1/devices/{id}/config`, GET `/api/v1/events`.
- C1: T01 201, T02 401, T03 422, T04 200 duplicado/409 conflicto. 400 JSON, 403 identidad, 422 límites; concurrencia 4 procesos→1 fila. Regresión C1 después de C2 exitosa.
- C2: autenticación administrativa, parámetros, paginación, 404, filtros de historial, configuración persistida sin implicar entrega física.
- D1: Mosquitto 2.1.2, broker aislado **127.0.0.1:1884**, cuentas/ACL por nodo y subscriber PHP CLI que invoca `TelemetryService` existente. Pruebas de acceso e ingesta publicadas; consultar `lab2/docs/MQTT_D1.md`. Broker original 1883 no certificado seguro. PUBACK de `mosquitto_sub` precede potencialmente commit SQL; no garantizar pérdida cero.
- No hay firmware E1 integrado confirmado. Sin tres nodos físicos operativos ni métricas p50/p95.
- No repetir `schema.sql` ni `seed.sql` contra MariaDB existente.

## Hardware E0: lo observado
- Tres ESP32 en total; **solo una** NodeMCU ESP-32S V1.1 de 38 pines comprobada. Otras dos sin componentes y funcionamiento desconocido.
- Relé JQC-3FF-S-Z 5 V activo LOW: fallo directo con HIGH 3,3 V de GPIO26. El usuario montó **BC548 NPN + resistencia 1 kΩ** y confirmó activación/desactivación por GPIO26 en sketch de diagnóstico. Relé VCC 5V, GND común, IN al colector, emisor GND, base a GPIO26 por resistencia. Bornes COM/NO/NC sin carga. LEDs externos aún sin reconectar.
- PIR **compatible HC-SR501**, chip BISS0001, jumper H/L, dos potenciómetros. Señales identificadas físicamente GND/OUT/VCC. Se probó aisladamente con OUT en GPIO27; el usuario y videos apoyan detección básica. **Pendiente sensibilidad/alcance/retención**: no se midió rango ni se comprobó tasa de falsas detecciones. No afirmar sensor defectuoso.
- Desconectar USB antes de cambios físicos; no usar red eléctrica en bornes del relé.

## ÚNICA tarea de reanudación
**E0: calibrar PIR antes de unir sensores.** Identificar potenciómetros de sensibilidad/tiempo y jumper sin adivinar sentidos. Ajustar un parámetro por vez; esperar ~60 s de estabilización; registrar distancia de activación, tiempo retenido, retorno a SIN MOVIMIENTO y detecciones en quietud. Después comprobar PIR+relé+LED en conjunto y evaluar ESP32 #2/#3. Terminar E0 antes de E1 y D2 LAN, salvo cambio expreso de prioridades.

DONE WHEN: datos reales del ajuste, circuito combinado verificado, estado de las otras dos placas conocido. NO hacer: auditar otra vez C1–D1, modificar Lab1, instalar paquetes sin causa, crear cifras artificiales, confundir software probado con hardware verificado.

## Contratos y precauciones
`node_id` autenticado; `seq` único incluso tras reinicio y reintento mismo contenido; `timestamp` Unix UTC o null (sin inventar reloj); `received_at` backend; PIR `value` 0/1; `rssi` -127..0/null; extensiones documentadas. MQTT y HTTP deben compartir TelemetryService.

Privados (nunca subir ni mostrar): `lab2/config/database.local.php`, `test-tokens.local.json`, token admin, `lab2/config/mqtt-private/`, contraseñas Wi-Fi, colas/logs privados. Consultar `.gitignore` y `git diff --cached --name-only` antes de commit.

## Comandos de inicio (PowerShell)
```powershell
cd D:\Proyectos\Lab1_repositorio
git status --short --untracked-files=all
git log -3 --oneline
git fetch origin
```
Codex: `codex.cmd resume` si sirve conservar sesión. Trabajar una tarea pequeña cada vez, Medium, sin subagentes/web/auditorías generales. Al finalizar, verificación real → revisar cambios privados → commit/push separado → actualizar docs. Los commits realizados directamente en GitHub requieren `git pull --ff-only` local antes de continuar.
