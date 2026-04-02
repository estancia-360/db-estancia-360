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
-- CLASIFICACIÓN (id_animal_class → animal_classes):
--   La clase del animal (Ternera, Vaca, Toro, Novillo, etc.) es seleccionada
--   manualmente por el operador al registrar el animal o cuando cambia de
--   etapa productiva. No se calcula automáticamente.
--
-- ESTADOS PRODUCTIVOS (id_productive_status → productive_statuses):
--   1=Cría → 2=Recría → 3=Engorde → 4=Baja
--   El backend actualiza este campo en cada transición productiva.
--   RN-10: un animal en Baja NO puede reactivarse ni recibir nuevos eventos.
--
-- ESTADOS OPERATIVOS (id_status → animal_statuses):
--   1=Activo | 2=En Observación (cuarentena/seguimiento) | 3=Inactivo (dado de baja)
--
-- REGLAS DE NEGOCIO:
--   - RN-05: code es único e irrepetible dentro de la estancia
--   - RN-06: Todo animal debe tener un id_productive_status válido en todo momento
--   - RN-10: Un animal en Baja (id_productive_status=4) no puede reactivarse
--   - RN-11: Toda cría viva debe tener id_mother NOT NULL
--
-- LÓGICA BACKEND:
--   - Crear por parto:  id_productive_status=1, id_lot=lote cría de la estancia
--   - Al destetar:      id_productive_status=2, id_lot=lote recría
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
    id_animal_class INT NOT NULL,
    id_lot BIGINT,
    code VARCHAR(50) NOT NULL UNIQUE,
    birthdate DATE NOT NULL,
    weight NUMERIC(12,2),
    sex CHAR(1) NOT NULL CHECK (sex IN ('M', 'F')),
    origin VARCHAR(300),
    updated_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP NOT NULL,
    PRIMARY KEY (id_ranch_animal),
    FOREIGN KEY (id_ranch) REFERENCES ranches(id_ranch),
    FOREIGN KEY (id_breed) REFERENCES animal_breeds(id_breed),
    FOREIGN KEY (id_status) REFERENCES animal_statuses(id_status),
    FOREIGN KEY (id_mother) REFERENCES ranch_animals(id_ranch_animal),
    FOREIGN KEY (id_father) REFERENCES ranch_animals(id_ranch_animal),
    FOREIGN KEY (id_productive_status) REFERENCES productive_statuses(id_productive_status),
    FOREIGN KEY (id_animal_class) REFERENCES animal_classes(id_animal_class),
    FOREIGN KEY (id_lot) REFERENCES ranch_lots(id_lot)
);
