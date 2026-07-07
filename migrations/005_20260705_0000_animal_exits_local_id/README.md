# animal_exits_local_id

El módulo Movimientos (backend) necesita idempotencia offline en las 3 tablas que maneja.
`movements` y `movement_animals` ya tenían `local_id` desde su creación; `animal_exits` había
quedado afuera. Se agrega para que las bajas offline también sean idempotentes ante reintentos
de sync.
