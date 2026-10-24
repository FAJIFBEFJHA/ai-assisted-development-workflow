# PROJECT_CONTEXT — lab1-iot-node / Laboratorio 2

**Checkpoint:** cierre de sesión del 24/10/2026. P13 y P14 ejecutados y observados físicamente, sin evidencias específicas guardadas; P15 con evidencias físicas y métricas PHP. Revisión presencial del 21/10 sin observaciones. Fuente de verdad: código y pruebas reales > guía > acuerdos > ROADMAP > este resumen. No se repitieron pruebas durante esta actualización documental.

## Repositorios y entorno

- Producto: https://github.com/jmamanilari-cyber/lab1-iot-node (en escritorio: `D:\Proyectos\Lab1_repositorio`; en laptop: `C:\Proyecto\lab1-iot-node`).
- Continuidad: https://github.com/FAJIFBEFJHA/ai-assisted-development-workflow; documento aquí en `projects/lab1-iot-node/PROJECT_CONTEXT.md`.
- Roadmap detallado y **cronograma del 20 al 28**: `lab2/docs/ROADMAP.md` en el producto; no duplicarlo íntegramente aquí.
- Commit local comprobado del producto: **`ffc3653`** (instrumentación y resultados de latencia P15); precedentes inmediatos `807eba0` (ESP32 #3 MQTT) y `a8b0323` (MQTT seguro LAN). Su publicación no está confirmada. Antecedentes E1: `04b29a3`, `6e3816a`, `bd66035`; `4328fba` corrige PUBACK 0/16. Estado inicial: únicamente `P15_LATENCIA.patch`, `lab2/logs/` y `lab2/scripts/capture-serial.py` sin seguimiento; conservarlos. Este cierre documental queda local, sin commits/push.
- Commits precedentes: `e94abd4` SQL/PDO; `e0069b3` HTTP telemetría; `fc49604` REST restante; `c26627d` MQTT seguro local; `b7e7824` roadmap anterior. El repo de continuidad puede tener nuevos commits independientes.
- Desarrollo aislado en `lab2/`. **No modificar Lab1 histórico**, ni Lab3. Guía `docs/Laboratior 2 guia.pdf` local/no necesariamente publicada; sesiones 5–8 pertinentes, sesión 9 fuera de alcance.

## Logros probados: laptop de presentación

La laptop tiene PHP CLI **8.2.12**, PDO/pdo_mysql/JSON/OpenSSL, MariaDB **10.4.32**, Mosquitto **2.1.2**, Arduino IDE y VS Code. Repo en `C:\Proyecto\lab1-iot-node`. El menú de demostración **ya se probó en laptop el 20/10** después de actualizar Git. El puerto 1883 responde, pero no se certificó seguro. No necesita Codex CLI para presentar.

La base `lab2` existe con `devices`, `telemetry`, `configurations`, `events` y `esp32-01/02/03` (identidades persistidas; P15 aporta evidencia documentada de transmisión física simultánea). PDO y consulta preparada en UTC: `OK: conexion PDO, consulta preparada nativa y sesion UTC.` Usuario propio de BD con privilegios limitados y tokens individuales de dispositivo y admin guardados privadamente. La exclusión de secretos y el Git limpio corresponden a aquella comprobación; al inicio de este cierre solo aparecen los archivos sin seguimiento indicados arriba.

Suites ejecutadas satisfactoriamente **en laptop**:
- `c1-http.php`: T01 POST 201, T02 401, T03 422, T04 idempotencia 200/409, errores 400/403/422 y comprobación SQL.
- `c2-http.php`: cuatro endpoints REST restantes; administración, historial propio, permisos, 404/405, filtros/paginación, configuraciones y eventos.
- `d1-security.php`: broker autenticado, rechazo anónimo/clave incorrecta, ACL por nodo y subscriber sin escritura.
- `d1-mqtt.php`: envío MQTT autenticado → subscriber PHP → `TelemetryService` → MariaDB; duplicado/conflicto/identidad y reanudación controlada.
- `c1-concurrency.php`: cuatro procesos, una creación, tres duplicados, una fila.

Estas suites prueban REST/MQTT **locales en la laptop**, no el enlace Wi-Fi de la arquitectura definitiva. Posteriormente se confirmó HTTPS desde ESP32 #2 hacia el escritorio en su red anterior, como se detalla abajo. Mosquitto protegido D1 usa listener privado `127.0.0.1:1884`; broker 1883 sin seguridad comprobada. QoS 1 + `mosquitto_sub` puede ACKear antes de commit MariaDB: no afirmar cero pérdidas ante cortes inesperados. No reimportar `schema.sql` ni `seed.sql` a BD existente. Tests agregan fixtures reales de prueba y no borran datos. El 24/10 quedaron validados Apache HTTPS y acceso desde hotspot con tres nodos físicos.

## Script de demostración (ya publicado)

El menú `lab2/scripts/demo.ps1` llama dos auxiliares PHP: `demo-data.php` (consultas y auditoría sin imprimir secretos) y `demo-acl.php` (respuestas del broker ante ACL). **Los tres archivos están en GitHub** en commit `a21b529`. Usa rutas de XAMPP/Mosquitto aunque no estén en PATH y no modifica el backend.

El usuario confirmó que la versión v2 **funciona completa en el escritorio**, con salida detallada real, no solo `PASS`. Opciones: (1) dependencias, PDO y estado; (2) iniciar REST 18082/MQTT 1884; (3) REST errores, permisos, SQL; (4) ACL, ingesta y auditoría MQTT; (5) concurrencia; (6) consultar tablas y registros; (7) detener exclusivamente procesos propios. Tras opción 7 se observaron ambos puertos detenidos. Una falta de acceso PDO inicial en el escritorio se resolvió **iniciando MySQL en XAMPP**, sin modificar datos. Se usó `Unblock-File` para script descargado de ZIP; no cambiar política global de Windows.

**Laptop 20/10: menú completo verificado.** Entorno/PDO correctos; REST C1/C2 y SQL 6→9 filas; MQTT 12 ACL correctas y SQL 9→11 filas; concurrencia cuatro procesos, una inserción (11→12); consultas SQL, auditoría y detención propia de PHP/Mosquitto, dejando puertos 18082/1884 sin escucha. Fixtures de pruebas, no tres ESP32 reales. El script PowerShell se habilitó temporalmente a nivel `Process` para ejecutarlo en esa sesión.

**Incidencia MQTT 21/10 (histórica):** al no haber suscriptores coincidentes, publicaciones permitidas devolvieron código MQTT 5 `PUBACK=16`, que representa aceptación sin suscriptor; la versión de `demo-acl.php` de entonces solo admitía `0` y produjo tres falsos negativos, mientras los nueve rechazos `135` fueron correctos. La edición local inicial tuvo errores de estructura y sintaxis. **La corrección a `[0,16]` ya está publicada en `4328fba`**, comprobado en Git; no cambiar autenticación/ACL ni volver a implementarla. Sigue sin confirmarse una nueva salida final 12/12 posterior a esa corrección en ambos equipos; validar cuando corresponda, sin desplazar la prioridad de conectividad portátil.

La **presentación del 21/10 ya se realizó y no hubo observaciones del profesor**. No repetir la batería completa por rutina ni ejecutar `schema.sql`/`seed.sql`.

## Estado físico y pendientes

- Hay **tres placas ESP32 disponibles y comprobadas mediante diagnósticos básicos**. Una fue identificada como NodeMCU ESP-32S V1.1; no inferir el modelo de las otras. P13 se ejecutó y observó físicamente, sin evidencia específica guardada; P15 sí documenta la transmisión simultánea.
- Relé JQC-3FF-S-Z 5V: interfaz con BC548 NPN + resistencia 1kΩ a base, GPIO26; usuario verificó clic/activación HIGH y desactivación LOW. GND común. **Prueba inicial histórica:** COM/NO/NC sin carga. **Montaje posterior confirmado por el usuario:** LED de baja tensión con resistencia de **330 Ω** para representar iluminación. El sketch de prueba controla el relé, pero no describe el cableado del LED, qué borne COM/NO/NC se utilizó ni su alimentación exacta: conservar esos detalles pendientes de confirmación, sin importar esquemas de Lab1. No conectar red eléctrica ni manipular energizado.
- PIR compatible HC-SR501/BISS0001: OUT→GPIO27; prueba independiente de PIR/relé con **retención funcional aproximada de 10 s**, renovada con nuevas detecciones. El sketch `lab2/firmware/pruebas/pir_rele_10s/pir_rele_10s/pir_rele_10s.ino`, publicado en `6e3816a`, fija `HOLD_TIME_MS=10000UL`, renueva el tiempo mientras OUT está HIGH y apaga solo con OUT LOW y al menos 10000 ms desde la última detección registrada. No equivale a medición cuantitativa del tiempo real ni a caracterización del temporizador interno del sensor. La integración funcional de #1 y multinodo se observó en P13, sin evidencia específica guardada; siguen pendientes caracterización temporal y calibración final/rango, sin concluir defecto.
- **Pendientes principales:** prueba de carga controlada, corrección/verificación de la anomalía del registrador COM5, revisión de criterios T05–T08 y P16 (informe y demostración). P13/P14 ya se ejecutaron y observaron físicamente, pero siguen sin evidencias específicas guardadas; no están completamente documentados. No rehacer firmware ni backend validados; P09/P10 y otros detalles sin evidencia específica se delimitan en ROADMAP.
- **Son obligatorios los tres ESP32 físicos, pero no tres juegos de periféricos.** El profesor autorizó simular el `value` PIR en ESP32 #2 y #3; ESP32 #1 integra sensor PIR, relé y LED físicos. Los tres deben transmitir físicamente y tener identidad propia. Documentar expresamente qué lecturas son simuladas; no alterar el contrato solo por falta de sensores en #2/#3.

## Antecedente E1 y diagnóstico de red — cierre 23/10

Registro histórico: los bloqueos e IP siguientes corresponden al 23/10 y quedan superados para la integración portátil por el cierre del 24/10. No son configuración actual.

- Archivo: `D:\Proyectos\Lab1_repositorio\lab2\firmware\esp32_02_http\esp32_02_http.ino`. Implementa HTTPS/Bearer con TLS estricto, RSSI Wi-Fi real, PIR explícitamente simulado, SNTP tras obtener IP, secuencias y pendientes persistidos en NVS, reintentos y muestreo de aproximadamente 10 s mediante tarea FreeRTOS.
- **Parcialmente validado:** Apache HTTPS del escritorio, certificado con SAN DNS `telemetry.lab.test` y destino `192.168.0.3:8443`. La conexión TCP directa a IP conserva nombre TLS/SNI y HTTP, sin requerir resolver ese nombre por DNS. Se observaron `HTTP=201 seq=37 ack=1 PIR=SIMULADO`, luego seq 38 y 39: prueba de esa configuración anterior, no de la arquitectura definitiva ni de recuperación ante todos los cortes.
- **Claro, sin resolver:** CastleNet Infinity601, ambas bandas con SSID `RODO`; se comprobó 2,4 GHz/canal 11 y conexión del sketch diagnóstico. E1 presentó `WIFI_REASON_AUTH_FAIL` 202 y una espera cercana a 10 min. Se eliminó `begin()` periódico superpuesto a la reconexión automática, se añadieron eventos/diagnóstico y se compiló con Arduino-ESP32 3.3.8. Una prueba posterior siguió **más de 240 s sin IP**. No afirmar solución ni atribuir causa definitiva a Band Steering.
- **Hotspot Android exclusivo de 2,4 GHz:** `AP conectado | canal=6 auth=3`; `GOT_IP | IP=10.229.155.191 | tiempo_hasta_IP_ms=1227`; SNTP iniciado tras obtener IP. La asociación y DHCP funcionaron en **1,227 s**. Después: `HTTP=-1 seq=82 ack=0 PIR=SIMULADO`. El destino seguía siendo `192.168.0.3`, del escritorio/red anterior: falta comprobar acceso a la laptop en la misma red. No diagnosticar una causa HTTPS definitiva a partir de `-1` ni marcar HTTPS sobre hotspot como funcional. El pendiente seq 82 se conserva para reintento.
- **Decisión principal:** teléfono Android (hotspot 2,4 GHz) → laptop + ESP32 #1/#2/#3. La laptop ejecutará Apache/HTTPS, API PHP, MariaDB y herramientas de demostración. El escritorio queda para desarrollo y no se trasladará a la universidad. Se descarta seguir separando bandas mediante el panel Claro o depender del operador.
- **Bloqueo del 23/10, superado por P13:** sin IP/subred de laptop confirmadas ni comunicación entre clientes/HTTPS verificados en hotspot. No desactivar TLS ni cambiar el SAN para resolverlo. Los pendientes ordenados y sus dependencias están en el ROADMAP; no duplicar aquí su cronograma.

## Cierre 24/10: arquitectura y evidencias

Hotspot Android de 2,4 GHz → laptop con PHP, MariaDB, Apache HTTPS y Mosquitto. **P13 se ejecutó y observó físicamente con tres ESP32 simultáneos, sin evidencia específica guardada de esa etapa:** #1 PIR físico/HTTPS 8443; #2 PIR simulado/HTTPS 8443; #3 PIR simulado/MQTT QoS 1/TLS 8883. RSSI real; USB para alimentación/captura, telemetría por Wi-Fi. La laptop es el backend de presentación; el escritorio permanece para desarrollo.

**P14:** pruebas reales de interrupción y recuperación de Wi-Fi, servicio HTTP y MQTT ejecutadas y observadas físicamente, sin evidencias específicas guardadas. P15 sí respalda la transmisión simultánea de los tres ESP32, pero no documenta estos escenarios de recuperación ni garantiza pérdida cero en cualquier corte. PUBACK acredita al broker, no un ACK de persistencia recibido por el ESP32.

**P15:** ~20 min (1200,3180408 s), **336 filas nuevas en MariaDB: 108/108/120**, throughput agregado aproximado 0,280 mensajes/s. Coherencia agregada de conteos y confirmaciones; sin export SQL exhaustivo fila a fila ni medición de capacidad máxima.

Dos ventanas posteriores de duración interna PHP: **~300 s con 52 HTTP**, sin mediciones MQTT; **~120 s con 22 HTTP y 12 MQTT**. `TelemetryService::receive()` incluye validación, transacción, SQL y commit; no mide RTT ni latencia extremo a extremo. Muestras pequeñas y valores atípicos conservados; no combinar percentiles ni comparar transportes completos. Percentiles, máximos y límites en [P15_RESULTADOS.md](https://github.com/jmamanilari-cyber/lab1-iot-node/blob/main/lab2/docs/P15_RESULTADOS.md), secciones 9.2–9.6; usar la copia local `C:\Proyecto\lab1-iot-node\lab2\docs\P15_RESULTADOS.md` como fuente comprobada, sin asumir publicación del commit actual.

COM5 presenta repeticiones anómalas de `seq=292` previas a la ventana física; no equivalen a solicitudes ni inserts reales. Corregir/verificar `capture-serial.py` antes de otra campaña, sin alterar los logs originales. P15 registra el 24/10 UTC y comenzó el 23/10 en Perú; el checkpoint de continuidad es la sesión del 24/10.

Detalle técnico, estados P01–P16 y siguiente sesión en [ROADMAP](https://github.com/jmamanilari-cyber/lab1-iot-node/blob/main/lab2/docs/ROADMAP.md); los cambios de este cierre permanecen locales.

## Objetivos y disponibilidad hasta el 28/10

- **Mié 21/10: revisión de avance completada y sin observaciones docentes.** Se presentó el progreso del backend; las funciones de hardware todavía pendientes no se dan por concluidas.
- **Mié 28/10:** evaluación final en el puesto con rúbrica y demostraciones. Fecha interna de cierre **mar 27, ~22:30**, miércoles final solo comprobación.
- **20–21/10:** menú y revisión presencial completados. **22–23/10:** E1 y decisión de arquitectura portátil. **24/10:** P13 y P14 ejecutados y observados, sin evidencias específicas guardadas; P15 documentado. Próxima prioridad: carga controlada, COM5, revisión T05–T08 y P16; migración subordinada a la entrega. Cierre técnico 27/10 ~22:30.
- **Restricciones reales:** jueves/viernes/sábado cocina hasta ~13:00; domingo está en casa de su madre y vuelve ~19:00–20:00; suele estar despierto hasta **medianoche**, pero reservar parte final para descanso, proyecto personal y juegos. Diarias de Endfield + Wuthering Waves: **20 minutos entre ambos como máximo**, cada día. Proyecto personal: normalmente 45–60 min/día, 60–90 min en viernes/sábado cuando se pueda. No planear tareas técnicas todo el día por estar libre de clase.

## Nueva tarea — separación de repositorios y colaboradores

- **Pendiente**: crear GitHub exclusivo del Laboratorio 2; migrar `lab2/` conservando el historial pertinente, sin afectar el Lab1 histórico. Revisar rutas, enlaces y archivos secretos; probar en escritorio y laptop; solo después retirar `lab2/` del repositorio viejo. Posponer un paso destructivo si arriesga la entrega del 28/10.
- **Pendiente**: enviar invitaciones como colaboradores a los **dos compañeros**. El usuario **no quiere asignarles tareas** ni depende de sus commits; continuará personalmente desarrollo, documentación, pruebas y hardware.
- El usuario **prohibió al asistente publicar o intentar escrituras en GitHub**: solo generar parches/archivos y comandos para commits ejecutados por él.

## Instrucciones para reanudar

1. Revisar el estado Git y el cierre del 24/10 en ROADMAP; usar `lab2/docs/P15_RESULTADOS.md` para métricas. No repetir suites, análisis de logs/ZIP ni diagnóstico Claro ya documentados.
2. Delimitar prueba de carga controlada y contrastar T05–T08 con sus definiciones originales. Antes de nueva captura serie, corregir/verificar COM5. No dar criterios por aprobados automáticamente a partir de P13/P14/P15.
3. Conservar sin versionar `lab2/scripts/capture-serial.py`, logs experimentales y `P15_LATENCIA.patch`. No borrar NVS, resembrar BD ni alterar fuentes originales. Preservar CA/SAN, TLS y autenticación; no mostrar secretos ni configuraciones privadas.
4. Completar P16: informe y demostración con arquitectura portátil, evidencias y limitaciones. Mantener separados tiempos serie, duración interna PHP y métricas extremo a extremo aún no acreditadas.
5. Encargos delimitados a Codex, sin auditorías repetidas, agentes/web ni instalaciones por iniciativa; sin commits/push ni escrituras remotas. Migración y colaboradores siguen pendientes sin desplazar la evaluación.

**Primera acción de la próxima sesión:** revisar T05–T08 y definir la prueba de carga controlada; corregir/verificar el registrador COM5 antes de cualquier nueva captura. Después cerrar P16. Evaluación final: **miércoles 28/10/2026**, con laptop como servidor; cierre técnico previsto **27/10 ~22:30**.
