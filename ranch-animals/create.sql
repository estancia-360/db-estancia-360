-- ============================================================
-- TABLA: ranch_animals
-- MÓDULO: Animales — Entidad central del sistema
-- ============================================================
--
-- DESCRIPCIÓN:
--   Registro de cada animal bovino de la estancia. Es la entidad
--   central que conecta todos los módulos. Cada compra, nacimiento,
--   evento sanitario, productivo o de movimiento referencia este animal.
--
-- CÓMO SE CREA UN ANIMAL:
--   a) Por nacimiento (parto): el backend lo crea automáticamente al
--      registrar un parturition con cria_status='alive' (RF-04.7).
--      Campos: id_mother=madre, id_productive_status=1, origin='born'.
--   b) Por compra: el backend lo crea al registrar animal_purchases (RF-08.2).
--      Campos: id_mother/id_father pueden ser NULL, origin='purchased'.
--
-- CATEGORIZACIÓN AUTOMÁTICA (RNF-03 — calculada por el backend, NUNCA almacenada):
--   Combina: sex, is_weaned, is_castrated, has_calved, is_sterilized y edad.
--
--   | Categoría              | sex | is_weaned | is_castrated | has_calved | is_sterilized | edad   |
--   |------------------------|-----|-----------|--------------|------------|---------------|--------|
--   | Ternera                | F   | FALSE     | -            | -          | -             | < 11m  |
--   | Ternero Macho Entero   | M   | FALSE     | FALSE        | -          | -             | < 11m  |
--   | Ternero Macho Castrado | M   | FALSE     | TRUE         | -          | -             | < 11m  |
--   | Hembra Destetada       | F   | TRUE      | -            | FALSE      | -             | < 12m  |
--   | Macho Entero Destetado | M   | TRUE      | FALSE        | -          | -             | < 12m  |
--   | Macho Castrado Dest.   | M   | TRUE      | TRUE         | -          | -             | < 12m  |
--   | Vaquilla               | F   | TRUE      | -            | FALSE      | FALSE         | >= 12m |
--   | Vaca                   | F   | -         | -            | TRUE       | -             | >= 12m |
--   | Hembra Esterilizada    | F   | -         | -            | -          | TRUE          | >= 12m |
--   | Toro                   | M   | -         | FALSE        | -          | -             | >= 12m |
--   | Novillo                | M   | -         | TRUE         | -          | -             | >= 12m |
--   (-) = el campo no es determinante para esa categoría.
--
-- ESTADOS PRODUCTIVOS (id_productive_status → productive_statuses):
--   1=Breeding(Cría) → 2=Rearing(Recría) → 3=Fattening(Engorde) → 4=Discharged(Baja)
--   El backend actualiza este campo en cada transición productiva.
--   RN-10: un animal en Baja NO puede reactivarse ni recibir nuevos eventos.
--
-- ESTADOS OPERATIVOS (id_status → animal_statuses):
--   1=Activo | 2=En Observación (cuarentena/seguimiento) | 3=Inactivo (dado de baja)
--
-- BOOLEANOS DE CICLO DE VIDA (el backend los actualiza automáticamente):
--   - is_weaned:     TRUE al registrar destete → activa transición a Recría (RN-08)
--   - has_calved:    TRUE al registrar el primer parto exitoso (RF-04.8)
--   - is_castrated:  TRUE si se registró castración (vía treatment o evento manual)
--   - is_sterilized: TRUE si la hembra fue esterilizada
--
-- REGLAS DE NEGOCIO:
--   - RN-05: code es único e irrepetible dentro de la estancia
--   - RN-06: Todo animal debe tener un id_productive_status válido en todo momento
--   - RN-10: Un animal en Baja (id_productive_status=4) no puede reactivarse
--   - RN-11: Toda cría viva debe tener id_mother NOT NULL
--
-- LÓGICA BACKEND:
--   - Crear por parto:  id_productive_status=1, id_lot=lote cría de la estancia
--   - Al destetar:      is_weaned=TRUE, id_productive_status=2, id_lot=lote recría
--   - Al ir a engorde:  id_productive_status=3, id_lot=lote engorde
--   - Al vender/morir:  id_productive_status=4, id_status=3 (Inactivo)
-- ============================================================

CREATE TABLE ranch_animals (
    id_ranch_animal BIGSERIAL,
    id_mother BIGINT,
    id_father BIGINT,
    id_ranch INT NOT NULL,
    id_breed INT NOT NULL,
    id_status INT NOT NULL,
    id_productive_status INT,
    id_lot BIGINT,
    code VARCHAR(50) NOT NULL UNIQUE,
    birthdate DATE NOT NULL,
    weight NUMERIC(12,2),
    sex CHAR(1) NOT NULL CHECK (sex IN ('M', 'F')),
    origin VARCHAR(300),
    is_castrated BOOLEAN,
    is_sterilized BOOLEAN,
    has_calved BOOLEAN,
    is_weaned BOOLEAN,
    updated_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP NOT NULL,
    PRIMARY KEY (id_ranch_animal),
    FOREIGN KEY (id_ranch) REFERENCES ranches(id_ranch),
    FOREIGN KEY (id_breed) REFERENCES animal_breeds(id_breed),
    FOREIGN KEY (id_status) REFERENCES animal_statuses(id_status),
    FOREIGN KEY (id_mother) REFERENCES ranch_animals(id_ranch_animal),
    FOREIGN KEY (id_father) REFERENCES ranch_animals(id_ranch_animal),
    FOREIGN KEY (id_productive_status) REFERENCES productive_statuses(id_productive_status),
    FOREIGN KEY (id_lot) REFERENCES ranch_lots(id_lot)
);