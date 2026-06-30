Analiza la base de datos de este proyecto siguiendo estos pasos en orden:

1. Lee `schema/init.sql` para ver el orden global: qué grupos y tablas standalone existen
2. Por cada grupo, lee su `init.sql` para ver las tablas que contiene y su orden de dependencia
3. Por cada tabla, lee su `create.sql` para ver estructura de columnas, tipos, constraints y FKs
4. Lee cada `data.sql` para identificar qué datos son de catálogo/configuración inicial
5. Lee cada `triggers.sql` donde exista para entender lógica automática en la DB
6. Lee `migrations/` en orden para ver la historia de cambios desde el baseline

Con todo eso, produce un reporte estructurado que incluya:

- **Resumen**: qué hace esta base de datos, en una oración
- **Grupos y tablas**: lista jerárquica de grupos → tablas con descripción de cada una
- **Relaciones clave**: las FKs más importantes y qué representan
- **Datos de catálogo**: qué tablas tienen datos iniciales y qué contienen
- **Lógica en DB**: triggers existentes y qué hacen
- **Historia de cambios**: qué migraciones hay y qué cambió en cada una
- **Observaciones**: algo que llame la atención (diseño, dependencias, datos faltantes, etc.)
