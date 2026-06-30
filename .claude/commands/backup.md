Creá un backup de la base de datos en el directorio `backups/`.

Primero leé `.env` para obtener las credenciales (DB_HOST, DB_PORT, DB_USER, DB_NAME).

Preguntame una descripción breve del backup (ej: "before_migration_005", "pre_launch", "post_seed").

Luego mostrá el comando exacto a correr:

```bash
pg_dump -U {DB_USER} -h {DB_HOST} -p {DB_PORT} -d {DB_NAME} -F p \
  -f backups/$(date +%Y%m%d_%H%M%S)_{descripcion}.sql
```

El formato del nombre es: `YYYYMMDD_HHMMSS_descripcion.sql`

Recordá que los `.sql` dentro de `backups/` están en `.gitignore` — no se suben al repo.
El directorio `backups/` sí está trackeado (gracias al `.gitkeep`).

Después de correr el comando, verificá que el archivo existe y mostrá su tamaño.
