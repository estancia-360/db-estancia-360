# ranch_pastures

Representa la división física del campo de una estancia (potreros). Dentro de un potrero se agrupan uno o más lotes de animales.

## Columnas

| Columna | Tipo | Nulo | Default | Descripción |
|---------|------|------|---------|-------------|
| id_ranch_pasture | BIGSERIAL | NO | autoincremental | Identificador único del potrero |
| id_ranch | INT | SÍ | — | Estancia a la que pertenece el potrero |
| name | VARCHAR(50) | NO | — | Nombre del potrero |
| area_hectares | DECIMAL(12,2) | NO | — | Superficie del potrero en hectáreas |
| description | TEXT | SÍ | — | Descripción libre del potrero (ej. "campo natural", "campo sembrado") |
| is_active | BOOLEAN | NO | TRUE | Indica si el potrero está activo; en FALSE deja de recibir animales/lotes |
| updated_at | TIMESTAMP | NO | — | Fecha de última modificación del registro |
| created_at | TIMESTAMP | NO | — | Fecha de creación del potrero |
| local_id | VARCHAR(100) | SÍ | — | Identificador generado en el dispositivo móvil para sincronización offline; único, permite idempotencia al sincronizar |

## Relaciones

| Columna | Referencia | Descripción |
|---------|------------|-------------|
| id_ranch | ranches.id_ranch | Estancia dueña del potrero |

## Reglas de negocio

- Un potrero contiene uno o más lotes (ranch_lots); un lote siempre pertenece a un potrero, y un animal siempre pertenece a un lote (y por extensión a un potrero).
- Al crear un potrero se debe verificar que id_ranch pertenezca al usuario que lo registra.
- Al desactivar un potrero (is_active=FALSE) se debe verificar que no tenga lotes activos asociados.

## Notas técnicas

- local_id tiene constraint UNIQUE y fue agregado mediante ALTER TABLE posterior a la creación original; soporta el patrón offline-first de idempotencia en sincronización.
