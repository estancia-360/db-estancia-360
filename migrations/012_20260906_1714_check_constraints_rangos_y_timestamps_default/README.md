# check_constraints_rangos_y_timestamps_default

Cierra los ítems de BUG-10/BUG-12 de la auditoría QA E2E (2026-09-03) que no requerían
backfill de datos existentes (verificado: 0 filas violan estos rangos en la DB real antes de
aplicar):

- Pesos (`ranch_animals.weight`, `weight_records.weight`) y capacidades/hectáreas
  (`ranch_lots.capacity`, `ranch_pastures.area_hectares`) ya no aceptan valores negativos o
  cero.
- `ranch_animals.birthdate` ya no acepta fechas futuras.
- `ranch_lots`/`ranch_pastures` ganan `DEFAULT CURRENT_TIMESTAMP` en sus timestamps —eran las
  únicas dos tablas del proyecto sin default ahí, lo que rompía cualquier inserción directa.

Quedan fuera a propósito: `animal_events.id_user` nullable (DBI-04 — hay 242 eventos
históricos sin usuario que no se quiso reatribuir sin certeza) y la validación de que un lote
esté apoyado en un potrero de su misma estancia (DBI-21 — se resuelve a nivel aplicación, no
en la DB, mismo patrón que DBI-20).
