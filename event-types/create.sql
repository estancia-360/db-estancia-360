-- ============================================================
-- TABLA: event_types  [CATÁLOGO — datos fijos del sistema]
-- MÓDULO: Core
-- ============================================================
-- Catálogo de los tipos de evento posibles. Cada registro en
-- animal_events tiene un id_event_type que determina a qué tabla
-- de detalle corresponde el evento.
--
-- VALORES FIJOS (data.sql):
--   1=service, 2=diagnosis, 3=birth, 4=weaning, 5=weight_record,
--   6=rearing_selection, 7=purchase, 8=sale, 9=transfer,
--   10=exit, 11=vaccination, 12=treatment, 13=health_incident, 14=fattening_entry
-- ============================================================

CREATE TABLE event_types (
    id_event_type int,
    name VARCHAR(50) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (id_event_type)
);