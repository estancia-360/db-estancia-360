# bug04_bug10_ranch_animals_local_id_users_unique

Dos correcciones de la auditoría QA E2E (`AuditoriaQAEstancia360 by claudio`, 2026-09-03):

- **BUG-04**: `ranch_animals.local_id` pasa de único global a único por estancia
  (`UNIQUE(id_ranch, local_id)`) — evitaba que un local_id repetido entre dos estancias
  distintas hiciera que el sync de una "pisara" silenciosamente el registro de la otra.
- **BUG-10**: `users.email` y `users.ci` ganan un índice único real en DB (parcial, solo
  sobre `is_deleted = false`) — antes la unicidad solo se validaba en la aplicación antes del
  INSERT, lo cual no cierra una condición de carrera entre dos registros simultáneos.
