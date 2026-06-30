# ranch_users_drop_salary

El campo `salary` nunca se usó en flujos reales del backend (no aparece en ningún DTO de creación/actualización ni en lógica de servicio). Se elimina del modelo de datos. Atención: esta migración borra datos existentes en esa columna si los hubiera; el rollback solo restaura la estructura, no los valores.
