# PROJECT_CONTEXT — lab1-iot-node / Laboratorio 2

**Checkpoint:** 19 de octubre de 2026, cierre de sesión. Fuente de verdad: código y pruebas reales > guía > acuerdos > `lab2/docs/ROADMAP.md` > este resumen.

## Repositorios y entorno

- Producto: https://github.com/jmamanilari-cyber/lab1-iot-node (en escritorio: `D:\Proyectos\Lab1_repositorio`; en laptop: `C:\Proyecto\lab1-iot-node`).
- Continuidad: https://github.com/FAJIFBEFJHA/ai-assisted-development-workflow; documento aquí en `projects/lab1-iot-node/PROJECT_CONTEXT.md`.
- Roadmap detallado y **cronograma del 20 al 28**: `lab2/docs/ROADMAP.md` en el producto; no duplicarlo íntegramente aquí.
- `main` del producto verificado en GitHub: **`a21b529`**, `feat(lab2): add interactive demonstration tool`; contiene **demo.ps1, demo-data.php, demo-acl.php** (comprobado). El commit antiguo `1609ae9` fue modificado con amend; el SHA actual es `a21b529`. Confirmar `git log -1` local.
- Commits precedentes: `e94abd4` SQL/PDO; `e0069b3` HTTP telemetría; `fc49604` REST restante; `c26627d` MQTT seguro local; `b7e7824` roadmap anterior. El repo de continuidad puede tener nuevos commits independientes.
- Desarrollo aislado en `lab2/`. **No modificar Lab1 histórico**, ni Lab3. Guía `docs/Laboratior 2 guia.pdf` local/no necesariamente publicada; sesiones 5–8 pertinentes, sesión 9 fuera de alcance.

## Logros probados: laptop de presentación

La laptop tiene PHP CLI **8.2.12**, PDO/pdo_mysql/JSON/OpenSSL, MariaDB **10.4.32**, Mosquitto **2.1.2**, Arduino IDE y VS Code. Repo clonado en `C:\Proyecto\lab1-iot-node`, inicialmente `b7e7824` limpio; GitHub avanzó posteriormente a `a21b529`, **falta ejecutar `git pull --ff-only` y validar el menú en la laptop**. El puerto 1883 responde, pero no se certificó seguro. No necesita Codex CLI para presentar.

La base `lab2` existe con `devices`, `telemetry`, `configurations`, `events` y `esp32-01/02/03` (filas seed, **no tres placas físicas**). PDO y consulta preparada en UTC: `OK: conexion PDO, consulta preparada nativa y sesion UTC.` Usuario propio de BD con privilegios limitados, tokens de dispositivo y admin guardados privadamente, confirmados con `git check-ignore` y Git limpio.

Suites ejecutadas satisfactoriamente **en laptop**:
- `c1-http.php`: T01 POST 201, T02 401, T03 422, T04 idempotencia 200/409, errores 400/403/422 y comprobación SQL.
- `c2-http.php`: cuatro endpoints REST restantes; administración, historial propio, permisos, 404/405, filtros/paginación, configuraciones y eventos.
- `d1-security.php`: broker autenticado, rechazo anónimo/clave incorrecta, ACL por nodo y subscriber sin escritura.
- `d1-mqtt.php`: envío MQTT autenticado → subscriber PHP → `TelemetryService` → MariaDB; duplicado/conflicto/identidad y reanudación controlada.
- `c1-concurrency.php`: cuatro procesos, una creación, tres duplicados, una fila.

REST/MQTT operan **localmente**, no por Wi-Fi desde ESP32. Mosquitto protegido D1 usa listener privado `127.0.0.1:1884`; broker 1883 sin seguridad comprobada. QoS 1 + `mosquitto_sub` puede ACKear antes de commit MariaDB: no afirmar cero pérdidas ante cortes inesperados. No reimportar `schema.sql` ni `seed.sql` a BD existente. Tests agregan fixtures reales de prueba y no borran datos.

## Script de demostración (ya publicado)

El menú `lab2/scripts/demo.ps1` llama dos auxiliares PHP: `demo-data.php` (consultas y auditoría sin imprimir secretos) y `demo-acl.php` (respuestas del broker ante ACL). **Los tres archivos están en GitHub** en commit `a21b529`. Usa rutas de XAMPP/Mosquitto aunque no estén en PATH y no modifica el backend.

El usuario confirmó que la versión v2 **funciona completa en el escritorio**, con salida detallada real, no solo `PASS`. Opciones: (1) dependencias, PDO y estado; (2) iniciar REST 18082/MQTT 1884; (3) REST errores, permisos, SQL; (4) ACL, ingesta y auditoría MQTT; (5) concurrencia; (6) consultar tablas y registros; (7) detener exclusivamente procesos propios. Tras opción 7 se observaron ambos puertos detenidos. Una falta de acceso PDO inicial en el escritorio se resolvió **iniciando MySQL en XAMPP**, sin modificar datos. Se usó `Unblock-File` para script descargado de ZIP; no cambiar política global de Windows.

**Todavía no se ejecutó demo v2 en laptop.** Para el día 20, cuando la laptop esté disponible:

```powershell
cd C:\Proyecto\lab1-iot-node
git status --short
git pull --ff-only origin main
.\lab2\scripts\demo.ps1
```

Iniciar MySQL desde XAMPP, probar menú 1→2→3→4→5→6→7 y observar salidas. No mostrar secretos, no añadir scripts o instalaciones innecesarias. Si Git no está limpio, **no forzar `pull`**; revisar primero.

## Estado físico y pendientes

- Hay tres placas ESP32; solo una **NodeMCU ESP-32S V1.1** comprobada. Otras dos no verificadas, sin sensores conectados.
- Relé JQC-3FF-S-Z 5V: interfaz con BC548 NPN + resistencia 1kΩ a base, GPIO26; usuario verificó clic/activación HIGH y desactivación LOW. GND común, bornes de carga vacíos. No conectar red eléctrica ni manipular energizado.
- PIR compatible HC-SR501/BISS0001: OUT→GPIO27, detección básica correcta según usuario/videos. Sensibilidad/alcance parecen demasiado altos, calibración y tiempo de retención sin medir; no concluir que está defectuoso. LED rojo y verde externos todavía desconectados.
- **Falta:** terminar E0 (calibrar PIR, integrar PIR+relé+LED, verificar ESP32 #2/#3), E1 firmware primer nodo con seq resistente a reinicios y HTTP/MQTT reales, D2 MQTT seguro por LAN, E2 tres nodos físicos concurrentes, T05–T08/throughput/p50/p95 y documentación final.
- Si faltan periféricos para #2/#3, no asumir compra obligatoria: confirmar con docente si cada nodo necesita sensor físico; si se usan datos emulados, etiquetarlos claramente y no confundir con mediciones PIR.

## Objetivos y disponibilidad hasta el 28/10

- **Mié 21/10:** revisión de avance por el profesor en el puesto, **no exposición formal**. Mostrar desde laptop: REST, MQTT D1, validación, ACL, duplicados, SQL, concurrencia. Software local probado; no atribuir funciones físicas aún pendientes.
- **Mié 28/10:** evaluación final en el puesto con rúbrica y demostraciones. Fecha interna de cierre **mar 27, ~22:30**, miércoles final solo comprobación.
- **Mar 20:** laptop 14:00–16:30, verificación final opcional 21:30–22:30. **Mié 21** verificación 17:00–18:15 y laboratorio 19:20–21:00. **Jue 22** calibración PIR/integración. **Vie 23** placas #2/#3 y firmware/HTTP. **Sáb 24** MQTT por LAN + primer nodo real. **Dom 25** solo 20:30–22:00 documentación, visita familiar. **Lun 26** integración multinodo y evidencias. **Mar 27** rendimiento, informe, commits y sincronización laptop. Ver bloques exactos en ROADMAP.
- **Restricciones reales:** jueves/viernes/sábado cocina hasta ~13:00; domingo está en casa de su madre y vuelve ~19:00–20:00; suele estar despierto hasta **medianoche**, pero reservar parte final para descanso, proyecto personal y juegos. Diarias de Endfield + Wuthering Waves: **20 minutos entre ambos como máximo**, cada día. Proyecto personal: normalmente 45–60 min/día, 60–90 min en viernes/sábado cuando se pueda. No planear tareas técnicas todo el día por estar libre de clase.

## Instrucciones para reanudar

1. Mañana iniciar por **verificar demo en la laptop**, no volver a instalar dependencias ni rehacer B/C1/C2/D1.
2. En cada sesión, mirar `git status --short --untracked-files=all`, `git log -3 --oneline` y la etapa pertinente del ROADMAP. En escritorio quedó constancia de archivos sin seguimiento: `LEEME_DEMO.txt`, `docs/Laboratior 2 guia.pdf`, `docs/SoftwareTele-Lab-1(2).pdf`; **no agregarlos automáticamente**. `demo-acl.php` ya quedó versionado en `a21b529`.
3. Evitar mostrar/publicar `database.local.php`, `test-tokens.local.json`, `admin.local.json`, `mqtt.local.php`, `config/mqtt-private/`, claves Wi-Fi y cola/auditoría privada. Revisar staged con `git diff --cached --name-only` y `git diff --cached --check`.
4. Codex: solo encargos delimitados, sin auditorías repetidas, agentes/web ni instalaciones por iniciativa; informar cambios, resultados y bloqueos, sin commits automáticos.
5. Conservar resultados auténticos. Separar **software probado localmente**, **hardware probado aisladamente**, **hardware integrado** y **trabajo pendiente**.

**Primera acción de la próxima sesión:** comprobar que `a21b529` está en la laptop y que el menú demuestra todos los casos después de un arranque normal de XAMPP y Mosquitto. Después, el miércoles solo presentar el avance.
