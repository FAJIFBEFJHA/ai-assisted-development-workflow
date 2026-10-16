# PROJECT_CONTEXT — lab1-iot-node / Laboratorio 2

**Checkpoint:** octubre de 2026. Estado basado en salidas verificadas y reportes de Codex en esta conversación. **Revalidar Git y las pruebas al reanudar; este archivo no sustituye al repositorio.**

## Proyecto y fuentes de verdad

- **Repositorio del producto:** https://github.com/jmamanilari-cyber/lab1-iot-node
- **Repositorio de continuidad:** https://github.com/FAJIFBEFJHA/ai-assisted-development-workflow
- **Carpeta del proyecto nuevo:** `lab2/` dentro del repositorio del producto. Laboratorio 1 histórico: **no modificar**.
- **Guía principal:** `docs/Laboratior 2 guia.pdf` en el repositorio local (en la última comprobación, PDF nuevo aún sin seguimiento Git).
- **Clases usadas para decidir el alcance:** sesiones 5–8; sesión 9 introduce Edge Computing/Lab 3, **fuera de alcance** de Lab 2. Codex reportó no tener disponibles las sesiones 5–9 localmente; no volver a buscarlas ni analizarlas completas sin necesidad.
- **Orden de autoridad:** código y ejecuciones reales > guía del laboratorio > decisiones confirmadas > contexto y roadmap > chat. No declarar completado lo que no se ha ejecutado.

## Objetivo y arquitectura acordada

Laboratorio 2: backend PHP/MariaDB multinodo para **3 nodos ESP32** que aceptará telemetría por HTTP y MQTT. Separación **Controller (HTTP), Service (dominio e idempotencia), Repository (PDO/MySQL), Subscriber (MQTT CLI)**. REST y MQTT invocarán exactamente el **mismo `TelemetryService`**; el Subscriber no duplicará lógica SQL.

Cinco rutas obligatorias:

```text
POST /api/v1/telemetry
GET  /api/v1/devices
GET  /api/v1/devices/{id}/telemetry
PUT  /api/v1/devices/{id}/config
GET  /api/v1/events
```

Diseño: PHP 8.2 sin framework, XAMPP local, MariaDB 10.4, PDO nativo con consultas preparadas. No construir dashboard, Edge Computing ni otras partes del Laboratorio 3.

## Estado implementado y verificado

**Etapa A (diseño):** guía revisada; contrato y arquitectura acordados; carpeta `lab2/{config,docs,firmware,public,sql,src}` creada.

**Etapa B (SQL y PDO):** Codex reportó la creación de:

```text
lab2/sql/schema.sql
lab2/sql/seed.sql
lab2/src/Database.php
lab2/config/database.example.php
lab2/sql/check-connection.php
```

También actualizó `lab2/README.md` y `.gitignore`.

**Comprobado por salidas del usuario:**

- MariaDB **10.4.32** aceptó `SOURCE .../lab2/sql/schema.sql` sin errores y creó la base `lab2` con tablas `devices`, `telemetry`, `configurations`, `events`.
- `seed.sql`: **3 filas insertadas**, sin duplicados ni advertencias. Dispositivos: `esp32-01`, `esp32-02`, `esp32-03` (IDs 1, 2, 3).
- `SHOW INDEX FROM telemetry`: UNIQUE `(device_id,seq)`, índice `(device_id,ts)` e índice `(device_id,received_at)` presentes.
- Comprobación PHP: `OK: conexion PDO, consulta preparada nativa y sesion UTC.`
- `git check-ignore lab2/config/database.local.php` confirmó que Git ignora las credenciales privadas.
- Codex informó validación de sintaxis de los tres archivos PHP; el usuario **no ha confirmado** todavía una prueba REST o MQTT.

**No verificado/pendiente:** no existe evidencia de endpoints REST ejecutándose, autenticación de dispositivos, suscriptor MQTT, tres nodos reales en paralelo, pruebas T01–T08, carga o métricas. No se ha confirmado en la conversación el **commit/push** de los archivos de la etapa B después de las indicaciones de Git. Revisar Git antes de asumirlo. El remoto puede no incluir aún `lab2/`.

## Contratos y decisiones que no se deben reabrir sin causa

- Tabla `devices`: `node_id` único, `token_hash`, `last_seen`.
- Tabla `telemetry`: FK `device_id`, `seq`, `ts` nullable (Unix UTC segundos), `received_at` UTC asignado por backend, `value`, `rssi`, `extensions` JSON opcional. UNIQUE `(device_id,seq)`.
- Otras tablas: `configurations` (única por dispositivo/clave) y `events`.
- Los **tres tokens de dispositivo no están activos** tras el seed (`token_hash=NULL`). Se necesitará aprovisionamiento seguro para probar REST.
- `value` es numérico; dominio PIR 0/1. `rssi` -127..0 o `null`.
- `seq` debe mantenerse único por nodo tras reinicios; resolver persistencia al adaptar firmware, sin almacenar en flash cada mensaje y sin reconstruir secuencias a partir de tiempo.
- `timestamp` sin sincronización debe ser `null`; **no inventarlo** ni confundirlo con `received_at`.
- REST: 201 registro nuevo; propuesta 200 duplicado idéntico; 409 mismo `(device_id,seq)` con contenido diferente. Errores 400/401/403/404/422/500 según causa. Documentar y probar.
- MQTT: verificar broker real, controlar credenciales y ACL; ACK de aplicación solo después de persistencia si se implementa ese protocolo; evitar que scripts antiguos del Lab 1 emitan ACK falsos.
- `schema.sql` falla deliberadamente si existe `lab2`; **NO volver a importar** el esquema ni seed en la base existente como parte de una sesión rutinaria.

## Próxima tarea exacta

**Confirmar el checkpoint Git de la etapa SQL/PDO antes de autorizar la API REST.**

```text
1. Desde la raíz del repositorio del producto, ejecutar:
   git status --short --untracked-files=all
   git log -1 --oneline
2. Si lab2/ continúa sin commit, revisar los archivos staged y excluir
   config/database.local.php; crear un commit específico de SQL/PDO.
3. Verificar que el checkpoint local conserva el resultado de PDO.
4. Después de cerrar ese checkpoint, encargar a Codex solo el
   TelemetryService + autenticación + cinco endpoints REST dentro de lab2/.
```

**DONE WHEN:** línea base Git identificada; SQL/PDO preservados sin credenciales y tarea REST delimitada. **OUT OF SCOPE:** MQTT, cambios de firmware, Lab 1, dashboards, Lab 3, cambios especulativos de arquitectura.

## Política para Codex: minimizar consumo de tokens

- Continuar en la misma sesión si conserva contexto útil; de lo contrario leer primero **este archivo** y la sección necesaria de `ROADMAP.md`.
- GPT-6.1-Sol/Medium era la configuración observada, no un requisito universal. `workspace-write` solo al implementar; `read-only` para analizar.
- No repetir auditoría integral ni releer los PDF completos. No subagentes, web, instalaciones ni nuevos frameworks salvo necesidad explícita.
- Un encargo acotado por etapa; pruebas mínimas focalizadas; no imprimir archivos completos ni largas transcripciones.
- Limitar cada informe de Codex a: archivos modificados, pruebas ejecutadas, resultados, bloqueos y próximo paso (aprox. 250–300 palabras).
- No crear commits automáticamente: revisar primero cambios, omitir archivos privados y confirmar estado real.
- Diferenciar siempre **propuesta**, **implementado**, **verificado** y **publicado en GitHub**.

## Recordatorio rápido del entorno

- Windows + PowerShell; XAMPP con PHP **8.2.12**, MariaDB **10.4.32**, Apache disponible. Mosquitto no verificado en la sesión de preparación.
- Comprobación PDO (desde la raíz del producto, con PHP de XAMPP):

```powershell
& "C:\xampp\php\php.exe" .\lab2\sql\check-connection.php
```

- Configuración privada local: `lab2/config/database.local.php`; **ignorada por Git**. Nunca copiar su contenido a GitHub ni al chat.
- Verificar Git: `git status --short --untracked-files=all` y `git diff --cached --name-only` antes de confirmar cambios.
- Ruta absoluta local usada durante la sesión: `D:\Proyectos\Lab1_repositorio` (orientativa, no usar como supuesto en otros dispositivos).

## Referencia de pruebas del Laboratorio 2

- T01 POST correcto → 201 y una fila.
- T02 token inválido → 401, cero filas nuevas.
- T03 campos obligatorios ausentes → 422 con detalle.
- T04 repetición de mensaje → sin duplicación.
- T05 tres nodos concurrentes → asociación correcta.
- Complementarias planificadas: T06 secuencia/reinicio y reloj sin sincronizar, T07 identidad MQTT y deduplicación HTTP/MQTT, T08 carga con throughput, errores y latencias p50/p95.

## Uso de repositorios

- **Producto:** implementación, datos de prueba no secretos, guía (si autorizada), `lab2/docs/ROADMAP.md`, tests, evidencias reales, diagramas y documentación para entregar.
- **Workflow:** `projects/lab1-iot-node/PROJECT_CONTEXT.md` (este archivo): checkpoint reanudable y preferencias operativas para asistentes.
- No hacer dos copias autoritativas del roadmap. Si alguna herramienta necesita el plan, referenciar el archivo del producto y leer solo la etapa pertinente.
