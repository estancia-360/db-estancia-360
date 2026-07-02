# ajustes_catalogo_pesos_usuarios

Tres correcciones pedidas juntas en la misma sesión de trabajo, agrupadas en una sola
migración porque forman parte del mismo lote de ajustes:

1. `animal_classes` id=10 estaba mal cargado como "Toro", corregido a "Torillo".
2. `ranch_users.salary` nunca se usó en flujos reales del backend — se elimina.
3. Todas las columnas de peso del sistema se unifican a `NUMERIC(6,2)` (máximo 4 dígitos
   enteros + 2 decimales), consistente con `parturitions.cria_weight` que ya tenía ese rango.
