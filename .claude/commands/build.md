Ejecutá el script de build desde la raíz del proyecto:

```bash
npm run build
```

Luego leé el archivo `db-output.sql` generado y reportá:
- Cuántas tablas/grupos fueron incluidos
- El orden final de carga (útil para detectar errores de dependencia)
- Si hay alguna advertencia de `[WARN] Not found` en la salida del script

Si el usuario quiere usar el output para inicializar una DB:
```bash
psql -U user -d dbname -f db-output.sql
```

Recordá que `db-output.sql` está en `.gitignore` — es un archivo generado, no se sube al repo.
