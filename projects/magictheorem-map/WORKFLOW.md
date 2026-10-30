# WORKFLOW

## Inicio y recuperación de sesión

1. Leer `PROJECT_PROFILE.md` y `PROJECT_CONTEXT.md` para identificar la única tarea activa.
2. Comprobar el estado del repositorio del producto y, cuando corresponda, del repositorio de workflow. Distinguir los cambios locales de lo confirmado en el remoto.
3. Consultar únicamente los archivos del producto pertinentes para el tramo o la decisión en curso. Resolver cualquier discrepancia entre el checkpoint y el estado real antes de avanzar.

## Trabajo sobre el beatmap

1. Acotar un tramo pequeño y definir qué quedará terminado y cómo se revisará.
2. El usuario coloca y ajusta los objetos en osu!lazer, usando el timing provisional mientras no decida cambiarlo.
3. Reproducir y revisar manualmente el tramo en osu!lazer. Registrar lo observado y los ajustes pendientes sin declarar verificado lo que aún no se ha probado.
4. Documentar en el repositorio del producto las decisiones de mapping o timing que deban persistir. Mantener en este workflow solo el estado necesario para recuperar la colaboración.

## Cierre y sincronización

1. Confirmar el último tramo trabajado y el resultado de su revisión manual.
2. Revisar los cambios y el estado de Git en el repositorio afectado. Actualizar `PROJECT_CONTEXT.md` con un checkpoint comprobable y una sola próxima tarea.
3. Si corresponde publicar cambios, hacer commit y push en cada repositorio por separado; confirmar el resultado del remoto antes de informar que quedó sincronizado.

No añadir scripts ni automatizaciones hasta que exista una necesidad concreta.
