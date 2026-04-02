-- ==========================================================
-- SCRIPT COMPLETO GENERADO AUTOMÁTICAMENTE (SEGÚN init.sql PRINCIPAL)
-- ==========================================================

-- ==========================================================
-- DROP ALL TABLES
-- ==========================================================
DO $$ DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') LOOP
        EXECUTE 'DROP TABLE IF EXISTS public.' || quote_ident(r.tablename) || ' CASCADE';
    END LOOP;
END $$;
-- cria
-- recria
-- movimientos
-- sanidad
-- engorde

-- INICIO DEL BLOQUE DE CARPETA: countries
-- ============================================================
-- TABLA: countries  [CATÁLOGO — datos fijos del sistema]
-- MÓDULO: Base geográfica
-- ============================================================
-- Países disponibles para el registro de estancias.
-- La jerarquía geográfica es: countries → regions → cities → ranches.
-- ============================================================
CREATE TABLE countries (
    id_country SERIAL,
    name VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (id_country)
);
INSERT INTO countries (id_country,name) VALUES
(1,'Argentina'),
(2,'Brasil'),
(3,'Uruguay'),
(4,'Paraguay'),
(5,'Bolivia'),
(6,'Chile'),
(7,'Peru'),
(8,'Ecuador'),
(9,'Colombia'),
(10,'Venezuela');
-- FIN DEL BLOQUE DE CARPETA: countries


-- INICIO DEL BLOQUE DE CARPETA: regions
-- ============================================================
-- TABLA: regions  [CATÁLOGO — datos fijos del sistema]
-- MÓDULO: Base geográfica
-- ============================================================
-- Regiones / departamentos por país. Nivel 2 de la jerarquía geográfica.
-- countries → regions → cities → ranches.
-- ============================================================
CREATE TABLE regions (
    id_region SERIAL,
    id_country INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (id_region),
    FOREIGN KEY (id_country) REFERENCES countries(id_country)
);
-- Insertar departamentos como regiones de bolivia
INSERT INTO regions (id_region,id_country,name) VALUES
(1,5,'La Paz'),
(2,5,'Cochabamba'),
(3,5,'Santa Cruz'),
(4,5,'Oruro'),
(5,5,'Potosi'),
(6,5,'Tarija'),
(7,5,'Chuquisaca'),
(8,5,'Beni'),
(9,5,'Pando');
-- FIN DEL BLOQUE DE CARPETA: regions


-- INICIO DEL BLOQUE DE CARPETA: cities
-- ============================================================
-- TABLA: cities  [CATÁLOGO — datos fijos del sistema]
-- MÓDULO: Base geográfica
-- ============================================================
-- Ciudades / municipios por región. Nivel 3 de la jerarquía geográfica.
-- Una estancia (ranches) pertenece a una ciudad.
-- countries → regions → cities → ranches.
-- ============================================================
CREATE TABLE cities (
    id_city SERIAL,
    id_region INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (id_city),
    FOREIGN KEY (id_region) REFERENCES regions(id_region)
);
-- insertar ciudades de las regiones de bolivia
INSERT INTO cities (id_city,id_region,name) VALUES
(1,1,'La Paz'),
(2,1,'El Alto'),
(3,1,'Achocalla'),
(4,2,'Cochabamba'),
(5,2,'Quillacollo'),
(6,2,'Sacaba'),
(7,3,'Santa Cruz de la Sierra'),
(8,3,'Montero'),
(9,3,'La Guardia'),
(10,4,'Oruro'),
(11,4,'Huanuni'),
(12,4,'Caracollo'),
(13,5,'Potosi'),
(14,5,'Uyuni'),
(15,5,'Tupiza'),
(16,6,'Tarija'),
(17,6,'Yacuiba'),
(18,6,'Bermejo'),
(19,7,'Sucre'),
(20,7,'Yamparáez'),
(21,7,'Zudañez'),
(22,8,'Trinidad'),
(23,8,'Riberalta'),
(24,8,'Guayaramerin'),
(25,9,'Cobija'),
(26,9,'Porvenir'),
(27,9,'Filadelfia');
-- FIN DEL BLOQUE DE CARPETA: cities


-- INICIO DEL BLOQUE DE CARPETA: production-types
-- ============================================================
-- TABLA: production_types  [CATÁLOGO — datos fijos del sistema]
-- MÓDULO: Gestión de Estancias
-- ============================================================
-- Rubros productivos disponibles. Se relaciona con las estancias
-- vía ranch_production_types (ManyToMany). Una estancia puede tener
-- uno o más rubros activos.
--
-- VALORES FIJOS (data.sql):
--   1=Cría    — Módulo reproductivo (breeding_services, parturitions, etc.)
--   2=Recría  — Módulo de crecimiento (weight_records, rearing_selections)
--   3=Engorde — Módulo de terminación (fattening_entries, feed_records)
-- ============================================================
CREATE TABLE production_types (
    id_type SERIAL,
    name VARCHAR(30) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (id_type)
);
INSERT INTO production_types (id_type,name) VALUES
(1,'Cria'),
(2,'Recria'),
(3,'Engorde');
-- FIN DEL BLOQUE DE CARPETA: production-types


-- INICIO DEL BLOQUE DE CARPETA: productive-statuses
-- ============================================================
-- TABLA: productive_statuses  [CATÁLOGO — datos fijos del sistema]
-- MÓDULO: Animales
-- ============================================================
-- Etapas del ciclo de vida productivo bovino.
-- El backend actualiza id_productive_status en ranch_animals
-- automáticamente con cada transición del ciclo.
--
-- VALORES FIJOS (data.sql) y su flujo:
--   1=Breeding (Cría)    → Estado inicial de todo animal nacido/comprado
--   2=Rearing  (Recría)  → Se asigna automáticamente al destetar (weanings)
--   3=Fattening(Engorde) → Se asigna al ingresar a engorde (fattening_entries)
--   4=Discharged(Baja)   → Se asigna al vender (animal_sales) o morir (animal_exits)
--
-- RN-10: Un animal en estado 4 (Baja) no puede reactivarse.
-- ============================================================
CREATE TABLE productive_statuses (
    id_productive_status int,
    name VARCHAR(50) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    primary key (id_productive_status)
);
INSERT INTO productive_statuses (id_productive_status, name) VALUES
(1, 'Cría'),
(2, 'Recría'),
(3, 'Engorde'),
(4, 'Baja');
-- FIN DEL BLOQUE DE CARPETA: productive-statuses


-- INICIO DEL BLOQUE DE CARPETA: ranch-roles
-- ============================================================
-- TABLA: ranch_roles  [CATÁLOGO — datos fijos del sistema]
-- MÓDULO: Gestión de Usuarios y Roles
-- ============================================================
-- Roles que puede tener un usuario dentro de una estancia específica.
-- Distinto de roles (que son roles del sistema global).
--
-- VALORES FIJOS (data.sql):
--   1=Owner         — Dueño. Solo 1 por estancia. Aprueba compras y ventas.
--   2=Worker        — Trabajador. Registra eventos productivos y sanitarios.
--   3=Administrator — Administrador. Gestiona trabajadores.
--
-- Permisos detallados en la lógica de ranch_users.
-- ============================================================
CREATE TABLE ranch_roles (
    id_role SERIAL,
    name VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (id_role)
);
INSERT INTO ranch_roles (id_role,name) VALUES
(1,'Dueño'),
(2,'Trabajador'),
(3,'Administrador');
-- FIN DEL BLOQUE DE CARPETA: ranch-roles


-- INICIO DEL BLOQUE DE CARPETA: roles
-- ============================================================
-- TABLA: roles  [CATÁLOGO — datos fijos del sistema]
-- MÓDULO: Usuarios del sistema (rol global)
-- ============================================================
-- Roles globales del sistema (distinto de ranch_roles que son roles
-- dentro de una estancia específica). Controlan el acceso al backend.
--
-- VALORES FIJOS (data.sql):
--   1=root  — Superadmin del sistema (Estancia360 internamente)
--   2=admin — Administrador del sistema
--   3=user  — Usuario final (ganadero)
-- ============================================================
CREATE TABLE roles (
    id_role int not null,
    name VARCHAR(30) UNIQUE NOT NULL,
    PRIMARY KEY (id_role)
);
INSERT INTO roles (id_role, name) VALUES
    (1, 'Root'),
    (2, 'Admin'),
    (3, 'Usuario');
-- FIN DEL BLOQUE DE CARPETA: roles


-- INICIO DEL BLOQUE DE CARPETA: users
-- ============================================================
-- TABLA: users
-- MÓDULO: Gestión de Usuarios del sistema
-- ============================================================
--
-- DESCRIPCIÓN:
--   Usuarios registrados en el sistema Estancia360. Cada usuario puede
--   pertenecer a una o más estancias con distintos roles (ranch_users).
--
-- ROLES DEL SISTEMA (id_role → roles):
--   3=user  — Ganadero / usuario final (rol típico de quien se registra)
--   2=admin — Administrador del sistema (Estancia360)
--   1=root  — Superadmin interno
--
-- MODO OFFLINE:
--   El sistema soporta máximo 2 usuarios offline por estancia:
--   el Owner y el Administrator. Sin conexión, estos dos usuarios
--   pueden registrar eventos que luego se sincronizan.
--
-- CAMPOS:
--   - ci:               cédula de identidad (identificación nacional)
--   - fullname:         nombre completo del usuario
--   - paternal_surname: apellido paterno (opcional)
--   - maternal_surname: apellido materno (opcional)
--   - password:         almacenada encriptada (bcrypt) (RNF-05.1)
--   - is_deleted:       borrado lógico (preserva historial de eventos)
-- ============================================================
CREATE TABLE users (
    id_user SERIAL,
    id_role INT NOT NULL,
    ci VARCHAR(20) NOT NULL,
    fullname VARCHAR(150) NOT NULL,
    paternal_surname VARCHAR(100),
    maternal_surname VARCHAR(100),
    email VARCHAR(150) NOT NULL,
    password VARCHAR(255) NOT NULL,
    celphone VARCHAR(20),
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_user),
    FOREIGN KEY (id_role) REFERENCES roles(id_role)
);
-- FIN DEL BLOQUE DE CARPETA: users


-- INICIO DEL BLOQUE DE CARPETA: ranches
-- ============================================================
-- TABLA: ranches
-- MÓDULO: Gestión de Estancias
-- ============================================================
--
-- DESCRIPCIÓN:
--   Representa una unidad productiva ganadera. Es el contenedor de todos
--   los recursos del sistema: animales, potreros, lotes y usuarios.
--   Cada animal, potrero y lote pertenece a exactamente una estancia.
--
-- RUBROS PRODUCTIVOS:
--   Los rubros activos (Cría, Recría, Engorde) se gestionan en la tabla
--   ranch_production_types (relación ManyToMany). Una estancia puede
--   tener uno o más rubros habilitados (RF-01.4).
--   RF-01.5: Los módulos productivos solo operan si el rubro está habilitado.
--
-- REGLAS DE NEGOCIO:
--   - RN-01: Cada estancia tiene un único dueño (Owner en ranch_users).
--   - RN-02: Toda estancia debe tener al menos un rubro productivo activo.
--   - RF-01.1: Se registra con nombre, ciudad (→ región → país).
--
-- USUARIOS DE LA ESTANCIA:
--   Se gestionan en ranch_users. Los roles posibles son:
--   Owner (Dueño), Administrator (Administrador), Worker (Trabajador).
--
-- LÓGICA BACKEND (al crear una estancia):
--   1. Crear el registro en ranches
--   2. Crear ranch_users para el creador con id_role=1 (Owner)
--   3. Crear ranch_production_types con los rubros seleccionados
--
-- NOTA: No tiene id_production_type directo. Los rubros están en
--   ranch_production_types para soportar múltiples rubros por estancia.
-- ============================================================
CREATE TABLE ranches (
    id_ranch    SERIAL,
    id_city     INT             NOT NULL,
    name        VARCHAR(200)    NOT NULL,
    created_at  TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_ranch),
    FOREIGN KEY (id_city) REFERENCES cities(id_city)
);
-- FIN DEL BLOQUE DE CARPETA: ranches


-- INICIO DEL BLOQUE DE CARPETA: ranch-production-types
-- ============================================================
-- TABLA: ranch_production_types
-- MÓDULO: Gestión de Estancias
-- ============================================================
-- Tabla de unión ManyToMany entre ranches y production_types.
-- Define qué rubros productivos tiene habilitados cada estancia.
-- RF-01.4: Toda estancia debe tener al menos un rubro activo.
-- RF-01.5: Los módulos productivos solo operan si su rubro está aquí.
--
-- LÓGICA BACKEND:
--   Antes de permitir cualquier acción de módulo (ej: crear fattening_entry),
--   el backend verifica que el id_production_type correspondiente esté
--   registrado aquí para la estancia del animal. Si no está → rechazar.
-- ============================================================
CREATE TABLE ranch_production_types (
    id_ranch            INT     NOT NULL,
    id_production_type  INT     NOT NULL,
    PRIMARY KEY (id_ranch, id_production_type),
    FOREIGN KEY (id_ranch)           REFERENCES ranches(id_ranch),
    FOREIGN KEY (id_production_type) REFERENCES production_types(id_type)
);
-- FIN DEL BLOQUE DE CARPETA: ranch-production-types


-- INICIO DEL BLOQUE DE CARPETA: ranch-users
-- ============================================================
-- TABLA: ranch_users
-- MÓDULO: Gestión de Usuarios y Roles
-- ============================================================
--
-- DESCRIPCIÓN:
--   Tabla de relación entre usuarios del sistema y estancias.
--   Define qué rol tiene cada usuario dentro de cada estancia.
--   Un usuario puede estar en múltiples estancias con roles distintos.
--
-- ROLES EN LA ESTANCIA (id_role → ranch_roles):
--   1 = Owner (Dueño):
--       - Solo uno por estancia (RN-01)
--       - Puede crear/eliminar Administradores (RN-03)
--       - Aprueba movimientos externos: compras y ventas (RN-16 / RF-02.5)
--   2 = Worker (Trabajador):
--       - Puede registrar eventos productivos y sanitarios
--       - No puede crear usuarios ni aprobar movimientos externos
--   3 = Administrator (Administrador):
--       - Puede registrar y gestionar trabajadores (RF-02.3)
--       - No puede crear ni eliminar otros Administradores
--
-- REGLAS DE NEGOCIO:
--   - RN-01: Cada estancia tiene un único Owner.
--   - RN-03: Solo el Owner puede crear o eliminar Administradores.
--   - RN-04: Los usuarios solo pueden operar dentro de la estancia asignada.
--   - RF-02.1: El sistema soporta máximo 2 usuarios offline por estancia:
--               el Owner y el Administrator.
--
-- CAMPOS:
--   - salary:      salario del empleado en la estancia (solo aplica a Workers)
--   - is_deleted:  borrado lógico (no se elimina el registro por trazabilidad)
-- ============================================================
CREATE TABLE ranch_users (
    id_user int not null,
    id_ranch int not null,
    id_role int not null,
    salary decimal(12,2),
    is_deleted boolean default false,
    created_at timestamp default current_timestamp,
    updated_at timestamp default current_timestamp,
    primary key (id_user, id_ranch),
    foreign key (id_user) references users(id_user),
    foreign key (id_ranch) references ranches(id_ranch),
    foreign key (id_role) references ranch_roles(id_role)
)
-- FIN DEL BLOQUE DE CARPETA: ranch-users


-- INICIO DEL BLOQUE DE CARPETA: animal-breeds
-- ============================================================
-- TABLA: animal_breeds  [CATÁLOGO — gestionado por la estancia]
-- MÓDULO: Animales
-- ============================================================
-- Catálogo de razas bovinas disponibles. Cada animal tiene asignada
-- una raza (ranch_animals.id_breed). Las razas son gestionadas por
-- la estancia (pueden agregar las que usen). Es_active permite
-- desactivar razas sin eliminar el historial.
-- ============================================================
CREATE TABLE animal_breeds (
    id_breed SERIAL,
    name VARCHAR(30) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (id_breed)
);
INSERT INTO animal_breeds (id_breed, name, is_active) VALUES
(1, 'VACA', TRUE);
-- FIN DEL BLOQUE DE CARPETA: animal-breeds


-- INICIO DEL BLOQUE DE CARPETA: animal-statuses
-- ============================================================
-- TABLA: animal_statuses  [CATÁLOGO — datos fijos del sistema]
-- MÓDULO: Animales
-- ============================================================
-- Estado operativo del animal (independiente del estado productivo).
-- Un animal puede estar en Engorde (productivo) y En Observación (operativo)
-- al mismo tiempo si tiene una cuarentena activa.
--
-- VALORES FIJOS (data.sql):
--   1=Activo       — Estado normal
--   2=En observación — Cuarentena o seguimiento especial (health_incidents)
--   3=Inactivo     — Animal dado de baja del sistema (al registrar salida o venta)
-- ============================================================
CREATE TABLE animal_statuses (
    id_status SERIAL,
    name VARCHAR(30) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (id_status)
);
INSERT INTO animal_statuses (id_status, name) VALUES
(1, 'Activo'),
(2, 'Observación'),
(3, 'Inactivo');
-- FIN DEL BLOQUE DE CARPETA: animal-statuses


-- INICIO DEL BLOQUE DE CARPETA: ranch-pastures
-- ============================================================
-- TABLA: ranch_pastures
-- MÓDULO: Gestión de Estancias — Potreros (Paddocks)
-- ============================================================
--
-- DESCRIPCIÓN:
--   Representa la división física del campo de una estancia. Los
--   potreros son los espacios físicos (hectáreas) donde se agrupan
--   los lotes de animales. Dentro de un potrero puede haber uno o
--   más lotes (ranch_lots).
--
-- RELACIÓN CON LOTES:
--   Un potrero (ranch_pasture) contiene uno o más lotes (ranch_lots).
--   Un lote siempre pertenece a un potrero.
--   Un animal siempre pertenece a un lote (y por ende a un potrero).
--
-- CAMPOS:
--   - area_hectares: superficie del potrero en hectáreas
--   - description:   descripción libre (ej: "campo natural", "campo sembrado")
--   - is_active:     FALSE si el potrero fue desactivado (deja de recibir animales)
--
-- LÓGICA BACKEND:
--   Al crear un potrero: verificar que id_ranch pertenezca al usuario.
--   Al desactivar (is_active=FALSE): verificar que no tenga lotes activos.
-- ============================================================
CREATE TABLE ranch_pastures (
    id_ranch_pasture bigserial,
    id_ranch int,
    name VARCHAR(50) NOT NULL,
    area_hectares DECIMAL(12, 2) NOT NULL,
    description TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    updated_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP NOT NULL,
    primary key (id_ranch_pasture),
    foreign key (id_ranch) references ranches(id_ranch)
);
-- FIN DEL BLOQUE DE CARPETA: ranch-pastures


-- INICIO DEL BLOQUE DE CARPETA: ranch-lots
-- ============================================================
-- TABLA: ranch_lots
-- MÓDULO: Gestión de Estancias — Lotes de Animales
-- ============================================================
--
-- DESCRIPCIÓN:
--   Representa un grupo de animales dentro de un potrero. Los lotes son
--   la unidad de manejo operativo del sistema: los pesajes, traslados y
--   alimentación se gestionan a nivel de lote. Todo animal pertenece
--   a un lote (ranch_animals.id_lot).
--
-- TIPOS DE LOTE (lot_type):
--   - breeding:     lote para vacas en ciclo reproductivo (módulo Cría)
--   - rearing:      lote para animales en crecimiento post-destete (Recría)
--   - fattening:    lote para animales en terminación antes de venta (Engorde)
--   - reproductive: lote para toros y reproductores
--   - general:      lote mixto o sin clasificación específica
--
--   El tipo de lote determina qué módulo puede operar sobre él.
--   RF-01.5: Los módulos solo operan si la estancia tiene habilitado el
--   rubro correspondiente (ranch_production_types).
--
-- RELACIÓN CON MÓDULOS:
--   - Lotes 'rearing':    destino en weanings.id_lot_dest y rearing_selections.id_lot_dest
--   - Lotes 'fattening':  destino en fattening_entries (referenciado vía animal_events)
--   - Todos los lotes:    destino en animal_transfers.id_lot_dest
--   - Todos los lotes:    referenciado en feed_records.id_lot (alimentación)
--   - Todos los lotes:    referenciado en weight_records.id_lot (pesajes)
--
-- CAMPOS:
--   - capacity: número máximo de animales que el lote puede contener (RF-01.6).
--               NULL = sin límite definido. El backend puede alertar si se supera.
--   - is_active: FALSE si el lote fue cerrado (ya no acepta nuevos animales)
--
-- LÓGICA BACKEND:
--   Al asignar un animal a un lote: verificar que el lote es del tipo correcto
--   para la etapa productiva del animal y que la estancia tiene ese rubro activo.
-- ============================================================
CREATE TABLE ranch_lots (
    id_lot              BIGSERIAL,
    id_ranch            INT,
    id_ranch_pasture    BIGINT          NOT NULL,
    name                VARCHAR(50)     NOT NULL,
    lot_type            VARCHAR(30)
        CHECK (lot_type IN (
            'breeding',
            'rearing',
            'fattening',
            'reproductive',
            'general'
        )),
    capacity            INT,                           -- capacidad máxima de animales del lote (RF-01.6)
    is_active           BOOLEAN         NOT NULL DEFAULT TRUE,
    updated_at          TIMESTAMP       NOT NULL,
    created_at          TIMESTAMP       NOT NULL,
    PRIMARY KEY (id_lot),
    FOREIGN KEY (id_ranch) REFERENCES ranches(id_ranch),
    FOREIGN KEY (id_ranch_pasture) REFERENCES ranch_pastures(id_ranch_pasture)
);
-- FIN DEL BLOQUE DE CARPETA: ranch-lots


-- INICIO DEL BLOQUE DE CARPETA: animal-classes
-- ============================================================
-- TABLA: animal_classes
-- MÓDULO: Animales — Catálogo de categorías bovinas
-- ============================================================
--
-- DESCRIPCIÓN:
--   Catálogo de las categorías (clases) de bovinos que maneja el sistema.
--   La categoría de cada animal es seleccionada manualmente por el
--   operador al momento del registro o cuando cambia de etapa productiva.
--   Ya no se calcula automáticamente a partir de booleanos.
--
-- CATEGORÍAS (según ANEXO 1 del documento de diseño):
--
--   TERNEROS — animales jóvenes, no destetados, menores de 11 meses
--   ┌─────────────────────────┬─────┐
--   │ Ternera                 │  F  │
--   │ Ternero Macho Entero    │  M  │
--   │ Ternero Macho Castrado  │  M  │
--   └─────────────────────────┴─────┘
--
--   DESTETADOS — animales post-destete, hasta el año de edad
--   ┌─────────────────────────┬─────┐
--   │ Hembra Destetada        │  F  │
--   │ Macho Entero Destetado  │  M  │
--   │ Macho Castrado Destetado│  M  │
--   └─────────────────────────┴─────┘
--
--   ADULTOS — animales de 12 meses o más
--   ┌─────────────────────────┬─────┐
--   │ Vaquilla                │  F  │
--   │ Vaca                    │  F  │
--   │ Hembra Esterilizada     │  F  │
--   │ Toro                    │  M  │
--   │ Novillo                 │  M  │
--   └─────────────────────────┴─────┘
--
-- COLUMNAS:
--   - sex: sexo al que aplica esta categoría (F=Hembra, M=Macho).
--     Permite filtrar opciones en el formulario de registro según el sexo
--     del animal que se está dando de alta.
--   - is_active: permite deshabilitar categorías sin eliminar registros
--     históricos que ya la usen.
-- ============================================================
CREATE TABLE animal_classes (
    id_animal_class INT,
    name            VARCHAR(100) NOT NULL,
    sex             CHAR(1)      NOT NULL CHECK (sex IN ('M', 'F')),
    is_active       BOOLEAN      NOT NULL DEFAULT TRUE,
    PRIMARY KEY (id_animal_class)
);
-- Catálogo de categorías bovinas (ANEXO 1 — Clasificación de Bovinos)
INSERT INTO animal_classes (id_animal_class, name, sex) VALUES
-- ── TERNEROS (no destetados, < 11 meses) ─────────────────────────────────
(1,  'Ternera',                 'F'),
(2,  'Ternero Macho Entero',    'M'),
(3,  'Ternero Macho Castrado',  'M'),
-- ── DESTETADOS (post-destete, hasta el año) ───────────────────────────────
(4,  'Hembra Destetada',        'F'),
(5,  'Macho Entero Destetado',  'M'),
(6,  'Macho Castrado Destetado','M'),
-- ── ADULTOS (≥ 12 meses) ─────────────────────────────────────────────────
(7,  'Vaquilla',                'F'),
(8,  'Vaca',                    'F'),
(9,  'Hembra Esterilizada',     'F'),
(10, 'Toro',                    'M'),
(11, 'Novillo',                 'M');
-- FIN DEL BLOQUE DE CARPETA: animal-classes


-- INICIO DEL BLOQUE DE CARPETA: ranch-animals
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
-- FIN DEL BLOQUE DE CARPETA: ranch-animals


-- INICIO DEL BLOQUE DE CARPETA: event-types
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
INSERT INTO event_types (id_event_type, name) VALUES
(1,  'Servicio de monta'),
(2,  'Diagnóstico de gestación'),
(3,  'Parto'),
(4,  'Destete'),
(5,  'Registro de peso'),
(6,  'Selección de recría'),
(7,  'Compra'),
(8,  'Venta'),
(9,  'Transferencia'),
(10, 'Salida'),
(11, 'Vacunación'),
(12, 'Tratamiento'),
(13, 'Incidente sanitario'),
(14, 'Entrada a engorde');
-- FIN DEL BLOQUE DE CARPETA: event-types


-- INICIO DEL BLOQUE DE CARPETA: animal-events
-- ============================================================
-- TABLA: animal_events
-- MÓDULO: Core — Tabla pivot central de TODOS los módulos
-- ============================================================
--
-- DESCRIPCIÓN:
--   Es la tabla más importante del sistema. CADA acción que le
--   ocurre a un animal genera primero un registro aquí. Luego,
--   la tabla de detalle del módulo correspondiente referencia
--   este id_animal_event.
--
--   Patrón: animal_events (cabecera) → tabla de detalle (cuerpo)
--
--   Esto garantiza:
--     • Trazabilidad cronológica completa de cada animal (RNF-02)
--     • Registro del usuario responsable en cada acción (RF-02.6)
--     • Un único punto de control para sincronización offline (RNF-01.4)
--
-- FLUJO DE NEGOCIO:
--   1. El usuario registra un evento desde la app móvil (offline)
--   2. La app crea primero el registro en animal_events
--   3. Luego crea el registro de detalle que referencia id_animal_event
--   4. is_synced = FALSE indica que está pendiente de enviar al servidor
--   5. Al sincronizar, is_synced pasa a TRUE
--
-- REGLAS DE NEGOCIO:
--   - RNF-02.1: Todo evento es inmutable una vez creado. Las correcciones
--               se realizan creando un nuevo evento, nunca editando.
--   - RN-15: Todo evento debe registrar el usuario responsable (id_user).
--   - RN-14: Todo cambio de estado productivo genera automáticamente un registro aquí.
--
-- TABLAS DE DETALLE QUE REFERENCIAN ESTA TABLA:
--   Cría:        breeding_services, gestation_diagnoses, parturitions, weanings
--   Recría:      weight_records, rearing_selections
--   Movimientos: animal_purchases, animal_sales, animal_transfers, animal_exits
--   Sanidad:     vaccinations, treatments, health_incidents
--   Engorde:     fattening_entries
--
-- TIPOS DE EVENTO (event_types.id_event_type):
--   1  = service           → breeding_services
--   2  = diagnosis         → gestation_diagnoses
--   3  = birth             → parturitions
--   4  = weaning           → weanings
--   5  = weight_record     → weight_records
--   6  = rearing_selection → rearing_selections
--   7  = purchase          → animal_purchases
--   8  = sale              → animal_sales
--   9  = transfer          → animal_transfers
--   10 = exit              → animal_exits
--   11 = vaccination       → vaccinations
--   12 = treatment         → treatments
--   13 = health_incident   → health_incidents
--   14 = fattening_entry   → fattening_entries
--
-- LÓGICA BACKEND (al crear cualquier evento el servicio debe):
--   1. Verificar que id_ranch_animal existe y pertenece a la estancia del usuario
--   2. Verificar que el animal NO está en estado productivo 'Baja' (id_productive_status=4) → RN-10
--   3. Crear el registro en animal_events
--   4. Retornar el id_animal_event para que el servicio de detalle lo use
--
-- CAMPOS:
--   - event_date: fecha real del evento en campo (puede diferir de created_at en offline)
--   - notes:      observación libre del operador de campo
--   - is_synced:  FALSE = pendiente de sincronizar; TRUE = ya en servidor central
-- ============================================================
CREATE TABLE animal_events (
    id_animal_event BIGSERIAL,
    id_user         BIGINT,
    id_ranch_animal INT,
    id_event_type   INT,
    notes           TEXT,
    is_synced       BOOLEAN   NOT NULL DEFAULT FALSE,
    event_date      TIMESTAMP NOT NULL,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_animal_event),
    FOREIGN KEY (id_ranch_animal) REFERENCES ranch_animals(id_ranch_animal),
    FOREIGN KEY (id_event_type)   REFERENCES event_types(id_event_type),
    FOREIGN KEY (id_user)         REFERENCES users(id_user)
);
-- FIN DEL BLOQUE DE CARPETA: animal-events


-- INICIO DEL BLOQUE DE CARPETA: animal-declared-history
-- ============================================================
-- TABLA: animal_declared_history
-- MÓDULO: Cría — Historial Productivo Previo Declarado
-- ============================================================
--
-- DESCRIPCIÓN:
--   Permite registrar el historial productivo de animales que ingresan
--   al sistema cuando ya tienen historia previa (pre-digitalización).
--   Es de carácter REFERENCIAL, no se usa para calcular indicadores
--   actuales del sistema (RF-03.10).
--
-- CUÁNDO SE USA:
--   Al registrar una vaca comprada o al inicializar el sistema en una
--   estancia existente. El operador declara cuántos partos tuvo la vaca
--   antes de entrar al sistema, el año del último parto, y el promedio
--   de peso al destete histórico.
--
-- IMPORTANTE:
--   - Un animal puede tener 0 o 1 registros en esta tabla.
--   - No genera animal_event (no es un evento del ciclo productivo).
--   - Los indicadores del módulo Cría (tasa de preñez, etc.) se calculan
--     solo sobre los eventos registrados en el sistema, no sobre este
--     historial declarado.
--
-- CAMPOS:
--   - prev_births_count:      cantidad de partos antes de entrar al sistema
--   - prev_last_birth_year:   año del último parto previo
--   - prev_avg_weaning_weight:peso promedio al destete de crías anteriores (kg)
--   - notes:                  observaciones adicionales del operador
-- ============================================================
CREATE TABLE animal_declared_history (
    id_history BIGSERIAL,
    id_ranch_animal BIGINT NOT NULL,
    prev_births_count INT,
    prev_last_birth_year INT,
    prev_avg_weaning_weight DECIMAL(10, 2),
    notes TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_history),
    FOREIGN KEY (id_ranch_animal) REFERENCES ranch_animals(id_ranch_animal)
);
-- FIN DEL BLOQUE DE CARPETA: animal-declared-history


-- INICIO DEL BLOQUE DE CARPETA: breeding-services
-- ============================================================
-- TABLA: breeding_services
-- MÓDULO: Cría — Paso 1: Servicio Reproductivo
-- ============================================================
--
-- DESCRIPCIÓN:
--   Registra el servicio reproductivo dado a una vaca (hembra en etapa
--   Cría). Es el primer paso del ciclo reproductivo. Sin un servicio
--   registrado no se puede hacer diagnóstico ni registrar parto (RN-12).
--
-- FLUJO EN EL MÓDULO CRÍA:
--   breeding_services → gestation_diagnoses → parturitions → weanings
--
-- CÓMO SE USA:
--   El usuario selecciona la vaca a servir, elige el tipo de servicio
--   y fecha. El backend crea primero el animal_event (tipo 'service'),
--   luego crea este registro referenciando ese evento.
--
-- TIPOS DE SERVICIO:
--   - natural:                 monta natural, requiere id_animal_male (el toro)
--   - artificial_insemination: IA, requiere semen_breed y technician (RF-04.2)
--   - embryo_transfer:         transferencia embrionaria
--
-- REGLAS DE NEGOCIO:
--   - RN-13: Una vaca con diagnóstico 'pregnant' activo NO puede recibir un
--             nuevo servicio hasta que ese ciclo reproductivo finalice (parto o vacía).
--   - RF-04.1: El animal servido debe ser hembra (sex='F') en estado productivo
--               Cría (id_productive_status=1).
--   - RF-04.2: En IA se deben registrar semen_breed y technician.
--
-- LÓGICA BACKEND (al crear un servicio):
--   1. Verificar que el animal existe, es hembra y pertenece a la estancia
--   2. Verificar que NO tiene un gestation_diagnosis activo con result='pregnant'
--      (consulta: SELECT * FROM gestation_diagnoses WHERE id_service IN (servicios
--       del animal) AND result='pregnant' AND no tiene parturition asociado)
--   3. Crear animal_event (id_event_type=1 'service')
--   4. Crear breeding_services referenciando ese evento
--
-- CAMPOS:
--   - id_animal_male:    FK al toro utilizado (solo en servicio natural; NULL en IA)
--   - semen_breed:       raza del semen (solo en IA; NULL en natural)
--   - technician:        nombre del técnico (solo en IA)
--   - reproductive_lot:  referencia al lote reproductivo si aplica (texto libre)
-- ============================================================
CREATE TABLE breeding_services (
    id_service BIGSERIAL,
    id_event bigint NOT NULL,
    id_animal_male bigint,
    service_type varchar(30) NOT NULL CHECK (service_type IN ('natural','artificial_insemination','embryo_transfer')),
    semen_breed varchar(100),
    technician varchar(150),
    reproductive_lot varchar(100),
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_service),
    FOREIGN KEY (id_event) REFERENCES animal_events(id_animal_event) ON DELETE CASCADE,
    FOREIGN KEY (id_animal_male) REFERENCES ranch_animals(id_ranch_animal) ON DELETE CASCADE
);
-- FIN DEL BLOQUE DE CARPETA: breeding-services


-- INICIO DEL BLOQUE DE CARPETA: gestation-diagnoses
-- ============================================================
-- TABLA: gestation_diagnoses
-- MÓDULO: Cría — Paso 2: Diagnóstico de Gestación
-- ============================================================
--
-- DESCRIPCIÓN:
--   Registra el diagnóstico de gestación de una vaca después de un
--   servicio. Siempre referencia un breeding_service previo (RF-04.5).
--   Este diagnóstico es el que habilita el registro de un parto.
--
-- FLUJO EN EL MÓDULO CRÍA:
--   breeding_services → gestation_diagnoses → parturitions → weanings
--
-- CÓMO SE USA:
--   El veterinario o responsable diagnóstica si la vaca quedó preñada.
--   Se crea un animal_event (tipo 'diagnosis') y luego este registro.
--
-- RESULTADOS POSIBLES:
--   - pregnant: la vaca está gestante → activa la posibilidad de registrar parto
--   - empty:    la vaca resultó vacía → se puede intentar nuevo servicio
--
-- REGLAS DE NEGOCIO:
--   - RF-04.5 / RN-12: No puede registrarse un parto (parturitions) sin que
--     exista un gestation_diagnosis con result='pregnant' asociado.
--   - RF-04.4: Se debe registrar método, resultado, días estimados de gestación,
--     fecha estimada de parto y nombre del veterinario.
--   - Una vaca puede tener múltiples diagnósticos en su vida (uno por ciclo).
--     Solo el más reciente con result='pregnant' sin parto asociado es "activo".
--
-- LÓGICA BACKEND (al crear un diagnóstico):
--   1. Verificar que el id_service existe y pertenece al mismo animal
--   2. Crear animal_event (id_event_type=2 'diagnosis')
--   3. Crear gestation_diagnoses con id_service
--   4. Si result='pregnant': marcar ciclo como activo (no hay acción directa en DB,
--      se consulta dinámicamente en la validación del servicio nuevo - RN-13)
--   5. Si result='empty': el animal puede recibir nuevo servicio
--
-- CAMPOS:
--   - id_service:      servicio del que deriva este diagnóstico (obligatorio)
--   - method:          palpation (palpación rectal) | ultrasound (ecografía)
--   - result:          pregnant | empty
--   - gestation_days:  días estimados de gestación al momento del diagnóstico
--   - estimated_birth: fecha estimada de parto (calculada por el vet)
--   - veterinarian:    nombre del veterinario responsable (texto libre)
-- ============================================================
CREATE TABLE gestation_diagnoses (
    id_diagnosis SERIAL,
    id_event bigint NOT NULL,
    id_service bigint NOT NULL,
    method varchar(20) NOT NULL CHECK (method IN ('palpation','ultrasound')),
    result varchar(20) NOT NULL CHECK (result IN ('pregnant','empty')),
    gestation_days int,
    estimated_birth date,
    veterinarian varchar(150),
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_diagnosis),
    FOREIGN KEY (id_event) REFERENCES animal_events(id_animal_event) ON DELETE CASCADE,
    FOREIGN KEY (id_service) REFERENCES breeding_services(id_service) ON DELETE CASCADE
);
-- FIN DEL BLOQUE DE CARPETA: gestation-diagnoses


-- INICIO DEL BLOQUE DE CARPETA: parturitions
-- ============================================================
-- TABLA: parturitions
-- MÓDULO: Cría — Paso 3: Registro de Parto
-- ============================================================
--
-- DESCRIPCIÓN:
--   Registra el parto de una vaca. Requiere un diagnóstico de gestación
--   previo con result='pregnant'. Si la cría nace viva, el backend crea
--   automáticamente un nuevo registro en ranch_animals (RF-04.7).
--
-- FLUJO EN EL MÓDULO CRÍA:
--   breeding_services → gestation_diagnoses → parturitions → weanings
--
-- CÓMO SE USA:
--   El usuario registra el parto indicando fecha, tipo de parto, estado de
--   la cría y condición de la madre. Si la cría está viva, la app debe
--   pedir datos adicionales (código de caravana, raza, sexo) para crear
--   el animal de la cría automáticamente.
--
-- REGLAS DE NEGOCIO:
--   - RF-04.5 / RN-12: No puede registrarse un parto sin un gestation_diagnosis
--     con result='pregnant' asociado al mismo animal. El backend valida que
--     id_diagnosis tenga result='pregnant' y que pertenezca a la misma vaca.
--   - RF-04.7: Si cria_status='alive', el backend DEBE crear automáticamente
--     un registro en ranch_animals para la cría con id_mother=madre del parto.
--   - RF-04.8: Al registrar el primer parto con cria_status='alive', el backend
--     actualiza has_calved=TRUE en ranch_animals de la madre.
--   - RN-11: Toda cría viva debe vincularse a la madre (id_mother en ranch_animals).
--
-- LÓGICA BACKEND (al crear un parto):
--   1. Verificar que id_diagnosis existe, tiene result='pregnant' y no tiene
--      parturition ya asociado (un diagnóstico solo genera un parto)
--   2. Crear animal_event (id_event_type=3 'birth') con el id del animal madre
--   3. Si cria_status='alive':
--      a. Crear ranch_animals para la cría (id_mother=madre, id_productive_status=1,
--         id_ranch=misma estancia, id_lot=lote de cría, code=dato del formulario)
--      b. Guardar id del nuevo animal en parturitions.id_cria
--   4. Si cria_status='dead':
--      a. Crear parturitions con id_cria=NULL
--   5. Si es el primer parto (has_calved=FALSE en la madre):
--      a. Actualizar ranch_animals: has_calved=TRUE para la madre
--   6. Crear parturitions con todos los datos
--
-- CAMPOS:
--   - id_diagnosis:     diagnóstico de gestación que habilita este parto
--   - birth_type:       normal | assisted (asistido) | cesarean (cesárea)
--   - id_cria:          FK al nuevo animal creado (NULL si la cría nació muerta)
--   - cria_weight:      peso al nacer de la cría (en gramos o kg según convenga)
--   - cria_status:      alive | dead
--   - mother_condition: condición post-parto de la madre: good | regular | bad
-- ============================================================
CREATE TABLE parturitions (
    id_parturition BIGSERIAL,
    id_event bigint NOT NULL,
    id_diagnosis bigint NOT NULL,
    birth_type varchar(20) NOT NULL CHECK (birth_type IN ('normal','assisted','cesarean')),
    id_cria BIGINT,
    cria_weight int,
    cria_status varchar(20) NOT NULL CHECK (cria_status IN ('alive','dead')),
    mother_condition varchar(20) CHECK (mother_condition IN ('good','regular','bad')),
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_parturition),
    FOREIGN KEY (id_event) REFERENCES animal_events(id_animal_event) ON DELETE CASCADE,
    FOREIGN KEY (id_diagnosis) REFERENCES gestation_diagnoses(id_diagnosis) ON DELETE CASCADE,
    FOREIGN KEY (id_cria) REFERENCES ranch_animals(id_ranch_animal) ON DELETE CASCADE
);
-- FIN DEL BLOQUE DE CARPETA: parturitions


-- INICIO DEL BLOQUE DE CARPETA: weanings
-- ============================================================
-- TABLA: weanings
-- MÓDULO: Cría — Paso 4 (Final): Destete
-- ============================================================
--
-- DESCRIPCIÓN:
--   Registra el destete de una cría. Es el evento que finaliza el ciclo
--   de Cría y da inicio al de Recría. Es el ÚNICO mecanismo para pasar
--   un animal a estado productivo Recría (RN-08 / RF-04.12).
--
-- FLUJO EN EL MÓDULO CRÍA:
--   breeding_services → gestation_diagnoses → parturitions → weanings
--   (El destete se registra en el animal CRÍA, no en la madre)
--
-- CÓMO SE USA:
--   El usuario selecciona la cría a destetar, registra peso, edad en días
--   y el lote de recría destino. La cría DEBE tener id_productive_status=1
--   (Cría) para poder ser destetada.
--
-- REGLAS DE NEGOCIO:
--   - RN-08 / RF-04.12: Solo mediante un destete registrado un animal pasa
--     a Recría. No hay otro camino.
--   - RF-04.11: Al registrar el destete, el backend actualiza automáticamente
--     en ranch_animals de la cría: is_weaned=TRUE, id_productive_status=2
--     (Recría) y id_lot=id_lot_dest.
--   - RF-04.10: Se debe registrar fecha, peso al destete, edad en días y
--     lote destino.
--
-- LÓGICA BACKEND (al registrar un destete):
--   1. Verificar que id_cria existe y tiene id_productive_status=1 (Cría)
--   2. Verificar que id_lot_dest existe, es del tipo 'rearing' y pertenece
--      a una estancia con rubro Recría habilitado (ranch_production_types)
--   3. Crear animal_event (id_event_type=4 'weaning') con id_ranch_animal=id_cria
--   4. Crear weanings con el evento creado
--   5. Actualizar ranch_animals del animal cría:
--      - is_weaned = TRUE
--      - id_productive_status = 2 (Rearing)
--      - id_lot = id_lot_dest
--      - updated_at = NOW()
--
-- CAMPOS:
--   - id_event:      evento de destete (animal_events con id_event_type=4)
--                    IMPORTANTE: el id_ranch_animal del evento apunta a la CRÍA, no a la madre
--   - id_cria:       el animal que se desteta (redundante con el evento, para claridad)
--   - id_lot_dest:   lote de recría al que ingresa la cría después del destete
--   - weaning_weight:peso de la cría al momento del destete (indicador clave de Cría)
--   - weaning_age:   edad en días al destete (indicador de 'edad al primer destete')
-- ============================================================
CREATE TABLE weanings (
    id_weaning BIGSERIAL,
    id_event bigint NOT NULL,
    id_cria bigint NOT NULL,
    id_lot_dest bigint NOT NULL,
    weaning_weight numeric(10,2),
    weaning_age int,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_weaning),
    FOREIGN KEY (id_event) REFERENCES animal_events(id_animal_event) ON DELETE CASCADE,
    FOREIGN KEY (id_cria) REFERENCES ranch_animals(id_ranch_animal) ON DELETE CASCADE,
    FOREIGN KEY (id_lot_dest) REFERENCES ranch_lots(id_lot) ON DELETE CASCADE
);
-- FIN DEL BLOQUE DE CARPETA: weanings


-- INICIO DEL BLOQUE DE CARPETA: weight-records
-- ============================================================
-- TABLA: weight_records
-- MÓDULO: Recría y Engorde — Pesajes periódicos
-- ============================================================
--
-- DESCRIPCIÓN:
--   Registra los pesajes periódicos de los animales. Es compartida
--   entre los módulos Recría y Engorde. Cada registro es un punto
--   de peso en el tiempo para un animal específico.
--
-- CÓMO SE CALCULA ADG (Average Daily Gain / Ganancia Diaria de Peso):
--   ADG = (peso_actual - peso_anterior) / días_entre_pesajes
--   El backend calcula esto al momento de consulta usando los registros
--   de weight_records del animal ordenados por event_date. (RF-05.4)
--
-- INDICADORES QUE ALIMENTA:
--   - Recría: ADG, peso promedio del lote, desvío, ranking (RF-05.4)
--   - Engorde: pesajes de control y ganancia diaria (RF-06.3)
--   - Conversión alimenticia (RF-06.4):
--     Eficiencia = sum(feed_records.quantity) / sum(weight_delta) del mismo lote
--
-- REGLAS:
--   - El animal debe estar en estado productivo Recría o Engorde.
--   - id_lot debe ser el lote actual del animal al momento del pesaje.
--
-- LÓGICA BACKEND (al crear un pesaje):
--   1. Crear animal_event (id_event_type=5 'weight_record')
--   2. Crear weight_records referenciando ese evento
--   3. Actualizar ranch_animals.weight con el nuevo peso (peso actual)
--
-- CAMPOS:
--   - id_lot:         lote del animal al momento del pesaje (para calcular
--                     promedios y rankings por lote)
--   - weight:         peso en kg
--   - weight_type:    scale=pesado en balanza | estimated=estimado visualmente
--   - body_condition: condición corporal 1-5 (escala BCS ganadera)
--   - age_days:       edad del animal en días al momento del pesaje
-- ============================================================
CREATE TABLE weight_records (
    id_weight           BIGSERIAL,
    id_event            BIGINT          NOT NULL,
    id_lot              BIGINT          NOT NULL,
    weight              NUMERIC(8,2)    NOT NULL,
    weight_type         VARCHAR(20)     NOT NULL
        CHECK (weight_type IN ('scale', 'estimated')),
    body_condition      SMALLINT
        CHECK (body_condition BETWEEN 1 AND 5),
    age_days            INT,
    notes               TEXT,
    created_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_weight),
    FOREIGN KEY (id_event) REFERENCES animal_events(id_animal_event),
    FOREIGN KEY (id_lot)   REFERENCES ranch_lots(id_lot)
);
-- FIN DEL BLOQUE DE CARPETA: weight-records


-- INICIO DEL BLOQUE DE CARPETA: rearing-selections
-- ============================================================
-- TABLA: rearing_selections
-- MÓDULO: Recría — Selección para Reposición o Engorde
-- ============================================================
--
-- DESCRIPCIÓN:
--   Registra la decisión de destino de un animal al finalizar la etapa
--   de Recría. Es el evento que determina si el animal va a reposición
--   (queda en la estancia como reproductor), a engorde (ciclo de
--   terminación) o a venta directa.
--
-- DESTINOS POSIBLES:
--   - replacement: el animal es seleccionado como futuro reproductor.
--                  Permanece en la estancia, su estado productivo permanece
--                  en Recría hasta ingresar a ciclo reproductivo.
--   - fattening:   el animal pasa a Engorde. El backend debe crear
--                  adicionalmente un fattening_entry (RF-05.6 / RN-09).
--                  Requiere que la estancia tenga rubro Engorde habilitado.
--   - sale:        el animal se vende directamente desde Recría.
--                  El backend debe crear un animal_sale (Movimientos).
--
-- REGLAS DE NEGOCIO:
--   - RF-05.5: Se evalúa peso, condición corporal y score genético.
--   - RN-09: Un animal pasa a Engorde solo si está en Recría y la estancia
--            tiene el rubro Engorde habilitado (ranch_production_types).
--
-- LÓGICA BACKEND (al crear una selección):
--   1. Verificar que el animal está en id_productive_status=2 (Recría)
--   2. Crear animal_event (id_event_type=6 'rearing_selection')
--   3. Crear rearing_selections
--   4. Si destination='fattening':
--      a. Crear animal_event (id_event_type=14 'fattening_entry')
--      b. Crear fattening_entries
--      c. Actualizar ranch_animals: id_productive_status=3, id_lot=id_lot_dest
--   5. Si destination='sale':
--      a. Crear animal_event (id_event_type=8 'sale')
--      b. Crear animal_sales
--      c. Actualizar ranch_animals: id_productive_status=4, id_status=3
--
-- CAMPOS:
--   - id_lot_dest:         lote destino (aplica si destination='fattening' o 'replacement')
--   - weight_at_selection: peso al momento de la selección
--   - body_condition:      condición corporal 1-5
--   - genetic_score:       puntaje genético (evaluación del criador)
--   - age_days:            edad del animal en días al seleccionar
-- ============================================================
CREATE TABLE rearing_selections (
    id_selection        BIGSERIAL,
    id_event            BIGINT          NOT NULL,
    id_lot_dest         BIGINT,
    destination         VARCHAR(20)     NOT NULL
        CHECK (destination IN ('replacement', 'fattening', 'sale')),
    weight_at_selection NUMERIC(8,2),
    body_condition      SMALLINT
        CHECK (body_condition BETWEEN 1 AND 5),
    genetic_score       NUMERIC(5,2),
    age_days            INT,
    notes               TEXT,
    created_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_selection),
    FOREIGN KEY (id_event)    REFERENCES animal_events(id_animal_event),
    FOREIGN KEY (id_lot_dest) REFERENCES ranch_lots(id_lot)
);
-- FIN DEL BLOQUE DE CARPETA: rearing-selections


-- INICIO DEL BLOQUE DE CARPETA: animal-purchases
-- ============================================================
-- TABLA: animal_purchases
-- MÓDULO: Movimientos — Compra de Animales
-- ============================================================
--
-- DESCRIPCIÓN:
--   Registra la compra de un animal externo que ingresa a la estancia.
--   Al registrar una compra, el backend también crea automáticamente el
--   registro del nuevo animal en ranch_animals (RF-08.2).
--
-- REGLAS DE NEGOCIO:
--   - RN-16: Solo el Dueño (Owner) puede ejecutar y aprobar compras.
--   - RF-08.2: Al comprar se crea automáticamente el animal en el sistema.
--   - El animal creado puede entrar en cualquier estado productivo según
--     su etapa de vida (Cría, Recría o Engorde).
--
-- LÓGICA BACKEND (al registrar una compra):
--   1. Verificar que quien registra es Owner (id_role=1 en ranch_users)
--   2. Crear el animal en ranch_animals con los datos del formulario
--   3. Crear animal_event (id_event_type=7 'purchase') para el nuevo animal
--   4. Crear animal_purchases con los datos comerciales
--
-- CAMPOS:
--   - supplier:       nombre del proveedor / vendedor
--   - origin:         lugar de procedencia del animal
--   - purchase_price: precio total de compra
--   - price_per_kg:   precio por kilogramo (indicador comercial)
-- ============================================================
CREATE TABLE animal_purchases (
    id_purchase         BIGSERIAL,
    id_event            BIGINT          NOT NULL,
    supplier            VARCHAR(150),
    origin              VARCHAR(150),
    purchase_price      NUMERIC(12,2),
    price_per_kg        NUMERIC(8,2),
    created_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_purchase),
    FOREIGN KEY (id_event) REFERENCES animal_events(id_animal_event)
);
-- FIN DEL BLOQUE DE CARPETA: animal-purchases


-- INICIO DEL BLOQUE DE CARPETA: animal-sales
-- ============================================================
-- TABLA: animal_sales
-- MÓDULO: Movimientos — Venta de Animales
-- ============================================================
--
-- DESCRIPCIÓN:
--   Registra la venta de un animal. Es el evento de salida comercial.
--   Al registrar una venta, el animal pasa a estado Baja (Discharged).
--
-- REGLAS DE NEGOCIO:
--   - RN-16: Solo el Dueño (Owner) puede ejecutar ventas.
--   - RN-18 / RF-06.6: Un animal con período de retiro sanitario activo
--     NO puede registrarse como vendido. El backend debe verificar que
--     treatments.withdrawal_end_date < CURRENT_DATE para el animal.
--   - RF-06.5: Se debe registrar fecha, peso final, precio por kg y comprador.
--
-- LÓGICA BACKEND (al registrar una venta):
--   1. Verificar que quien registra es Owner (id_role=1 en ranch_users)
--   2. Verificar que el animal no tiene tratamiento con withdrawal_end_date >= HOY
--      (SELECT * FROM treatments t JOIN animal_events ae ON ... WHERE withdrawal_end_date >= NOW())
--   3. Crear animal_event (id_event_type=8 'sale')
--   4. Crear animal_sales
--   5. Actualizar ranch_animals: id_productive_status=4 (Baja), id_status=3 (Inactivo)
--
-- CAMPOS:
--   - buyer:       nombre del comprador
--   - destination: destino/frigorífico al que va el animal
--   - sale_price:  precio total de venta
--   - price_per_kg:precio por kilogramo
-- ============================================================
CREATE TABLE animal_sales (
    id_sale             BIGSERIAL,
    id_event            BIGINT          NOT NULL,
    buyer               VARCHAR(150),
    destination         VARCHAR(150),
    sale_price          NUMERIC(12,2),
    price_per_kg        NUMERIC(8,2),
    created_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_sale),
    FOREIGN KEY (id_event) REFERENCES animal_events(id_animal_event)
);
-- FIN DEL BLOQUE DE CARPETA: animal-sales


-- INICIO DEL BLOQUE DE CARPETA: animal-transfers
-- ============================================================
-- TABLA: animal_transfers
-- MÓDULO: Movimientos — Traslados Internos de Animales
-- ============================================================
--
-- DESCRIPCIÓN:
--   Registra el traslado de un animal de un lote a otro dentro de la
--   misma estancia. El cambio de potrero se infiere del cambio de lote
--   (cada lote pertenece a un potrero, si los potreros son distintos
--   es un traslado de potrero; si son el mismo es traslado de lote).
--
-- MOTIVOS DE TRASLADO (reason):
--   - management: reajuste de carga o manejo operativo
--   - breeding:   traslado para incorporar al ciclo reproductivo
--   - rearing:    traslado entre lotes de recría
--   - fattening:  traslado entre lotes de engorde
--   - health:     cuarentena o separación por evento sanitario
--
-- LÓGICA BACKEND (al registrar un traslado):
--   1. Crear animal_event (id_event_type=9 'transfer')
--   2. Crear animal_transfers con lote origen y destino
--   3. Actualizar ranch_animals.id_lot = id_lot_dest del animal
--
-- CAMPOS:
--   - id_lot_origin: lote de donde sale el animal (lote actual antes del traslado)
--   - id_lot_dest:   lote al que ingresa el animal
--   - reason:        motivo del traslado (categorizado)
-- ============================================================
CREATE TABLE animal_transfers (
    id_transfer         BIGSERIAL,
    id_event            BIGINT          NOT NULL,
    id_lot_origin       BIGINT          NOT NULL,
    id_lot_dest         BIGINT          NOT NULL,
    reason              VARCHAR(30)
        CHECK (reason IN (
            'management',
            'breeding',
            'rearing',
            'fattening',
            'health'
        )),
    created_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_transfer),
    FOREIGN KEY (id_event)      REFERENCES animal_events(id_animal_event),
    FOREIGN KEY (id_lot_origin) REFERENCES ranch_lots(id_lot),
    FOREIGN KEY (id_lot_dest)   REFERENCES ranch_lots(id_lot)
);
-- FIN DEL BLOQUE DE CARPETA: animal-transfers


-- INICIO DEL BLOQUE DE CARPETA: animal-exits
-- ============================================================
-- TABLA: animal_exits
-- MÓDULO: Movimientos — Muertes y Descartes
-- ============================================================
--
-- DESCRIPCIÓN:
--   Registra la salida definitiva de un animal por muerte, descarte,
--   pérdida u otra causa no comercial. Al registrar una salida, el
--   animal pasa a estado Baja (Discharged) e Inactivo.
--
-- CAUSAS (reason):
--   - death:    muerte natural o accidental
--   - discard:  descarte productivo (animal sin rendimiento, baja calidad genética)
--   - loss:     pérdida (animal no localizado, robo)
--   - other:    otra causa; debe documentarse en el campo notes
--
-- REGLAS DE NEGOCIO:
--   - RF-08.5: Se debe registrar la causa de la salida.
--   - RN-10: Un animal dado de baja NO puede reactivarse.
--
-- LÓGICA BACKEND (al registrar una salida):
--   1. Crear animal_event (id_event_type=10 'exit')
--   2. Crear animal_exits
--   3. Actualizar ranch_animals:
--      - id_productive_status = 4 (Discharged / Baja)
--      - id_status = 3 (Inactivo)
--
-- CAMPOS:
--   - reason: causa de la salida (categorizado con CHECK)
--   - notes:  detalle adicional obligatorio si reason='other'
-- ============================================================
CREATE TABLE animal_exits (
    id_exit             BIGSERIAL,
    id_event            BIGINT          NOT NULL,
    reason              VARCHAR(30)     NOT NULL
        CHECK (reason IN (
            'death',       -- muerte natural o accidental
            'discard',     -- descarte productivo (animal sin rendimiento)
            'loss',        -- pérdida (animal no localizado)
            'other'        -- otra causa documentada en notes
        )),
    notes               TEXT,
    created_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_exit),
    FOREIGN KEY (id_event) REFERENCES animal_events(id_animal_event)
);
-- FIN DEL BLOQUE DE CARPETA: animal-exits


-- INICIO DEL BLOQUE DE CARPETA: vaccinations
-- ============================================================
-- TABLA: vaccinations
-- MÓDULO: Sanidad — Vacunaciones
-- ============================================================
--
-- DESCRIPCIÓN:
--   Registra las vacunas aplicadas a un animal. Aplica en cualquier
--   etapa productiva (Cría, Recría, Engorde). Incluye también la
--   aplicación de antiparasitarios sin período de retiro.
--
-- REGLAS DE NEGOCIO:
--   - RF-07.1: Registrar vacuna, dosis y responsable (mínimo).
--   - RN-17: Todo registro sanitario debe asociarse a un animal específico.
--   - Para antiparasitarios CON período de retiro usar treatments (no esta tabla).
--
-- LÓGICA BACKEND (al registrar una vacunación):
--   1. Crear animal_event (id_event_type=11 'vaccination')
--   2. Crear vaccinations referenciando ese evento
--
-- CAMPOS:
--   - vaccine_name: nombre de la vacuna o antiparasitario (texto libre)
--   - dose:         dosis aplicada (ej: '5ml', '2cc')
--   - responsible:  nombre del responsable o veterinario
--   - notes:        observaciones adicionales
-- ============================================================
CREATE TABLE vaccinations (
    id_vaccination      BIGSERIAL,
    id_event            BIGINT          NOT NULL,
    vaccine_name        VARCHAR(150)    NOT NULL,
    dose                VARCHAR(50),
    responsible         VARCHAR(150),
    notes               TEXT,
    created_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_vaccination),
    FOREIGN KEY (id_event) REFERENCES animal_events(id_animal_event)
);
-- FIN DEL BLOQUE DE CARPETA: vaccinations


-- INICIO DEL BLOQUE DE CARPETA: treatments
-- ============================================================
-- TABLA: treatments
-- MÓDULO: Sanidad — Tratamientos Médicos
-- ============================================================
--
-- DESCRIPCIÓN:
--   Registra tratamientos médicos aplicados a un animal (medicamentos,
--   antibióticos, antiparasitarios con retiro). El período de retiro
--   (withdrawal) es clave: un animal bajo retiro activo NO puede venderse
--   (RN-18 / RF-06.6).
--
-- PERÍODO DE RETIRO:
--   withdrawal_days: días de retiro sanitario del medicamento.
--   withdrawal_end_date: fecha calculada de fin del retiro.
--     Cálculo: withdrawal_end_date = event_date + withdrawal_days días.
--   El backend calcula withdrawal_end_date automáticamente.
--   Al intentar registrar una venta, el backend verifica:
--     SELECT * FROM treatments WHERE id_animal = X AND withdrawal_end_date >= NOW()
--     Si hay resultado → bloquear la venta.
--
-- REGLAS DE NEGOCIO:
--   - RF-07.2: Registrar enfermedad, medicamento, dosis, duración y responsable.
--   - RF-07.5: El sistema debe registrar y respetar el período de retiro.
--   - RN-17: Todo tratamiento asociado a un animal específico.
--   - RN-18: Bloquear venta si withdrawal_end_date >= fecha actual.
--
-- LÓGICA BACKEND (al registrar un tratamiento):
--   1. Crear animal_event (id_event_type=12 'treatment')
--   2. Calcular withdrawal_end_date = event_date + withdrawal_days (si aplica)
--   3. Crear treatments
--
-- CAMPOS:
--   - illness:            enfermedad o diagnóstico (texto libre)
--   - medication:         medicamento aplicado (obligatorio)
--   - dose:               dosis aplicada
--   - duration_days:      duración total del tratamiento en días
--   - withdrawal_days:    días de retiro del medicamento (0 o NULL = sin retiro)
--   - withdrawal_end_date:fecha fin del retiro (calculada automáticamente)
--   - responsible:        veterinario o responsable
-- ============================================================
CREATE TABLE treatments (
    id_treatment        BIGSERIAL,
    id_event            BIGINT          NOT NULL,
    illness             VARCHAR(150),
    medication          VARCHAR(150)    NOT NULL,
    dose                VARCHAR(50),
    duration_days       INT,
    withdrawal_days     INT,
    withdrawal_end_date DATE,
    responsible         VARCHAR(150),
    notes               TEXT,
    created_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_treatment),
    FOREIGN KEY (id_event) REFERENCES animal_events(id_animal_event)
);
-- FIN DEL BLOQUE DE CARPETA: treatments


-- INICIO DEL BLOQUE DE CARPETA: health-incidents
-- ============================================================
-- TABLA: health_incidents
-- MÓDULO: Sanidad — Eventos Sanitarios
-- ============================================================
--
-- DESCRIPCIÓN:
--   Registra eventos sanitarios que no son vacunaciones ni tratamientos
--   directos. Incluye la detección de enfermedades y la declaración
--   de cuarentena. La mortalidad se registra en animal_exits (Movimientos).
--
-- TIPOS DE INCIDENTE:
--   - illness_detected: se detectó una enfermedad o síntoma en el animal.
--                       Puede acompañarse de un treatment posterior.
--   - quarantine:       el animal fue separado del resto del lote por riesgo
--                       sanitario. El backend debe actualizar id_status=2
--                       (En Observación) en ranch_animals.
--
-- REGLAS DE NEGOCIO:
--   - RF-07.3: El sistema registra enfermedades detectadas y cuarentenas.
--   - RN-17: Todo incidente asociado a un animal específico.
--
-- LÓGICA BACKEND (al registrar un incidente):
--   1. Crear animal_event (id_event_type=13 'health_incident')
--   2. Crear health_incidents
--   3. Si incident_type='quarantine': actualizar ranch_animals.id_status=2
--   4. Al marcar resolved_at: si el animal estaba en cuarentena,
--      volver ranch_animals.id_status=1 (Activo)
--
-- CAMPOS:
--   - incident_type: illness_detected | quarantine
--   - description:   descripción del incidente (síntomas, observaciones)
--   - resolved_at:   fecha en que se resolvió el incidente (NULL = aún activo)
--   - notes:         notas adicionales del responsable
-- ============================================================
CREATE TABLE health_incidents (
    id_incident         BIGSERIAL,
    id_event            BIGINT          NOT NULL,
    incident_type       VARCHAR(30)     NOT NULL
        CHECK (incident_type IN (
            'illness_detected',
            'quarantine'
        )),
    description         VARCHAR(300),
    resolved_at         DATE,
    notes               TEXT,
    created_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_incident),
    FOREIGN KEY (id_event) REFERENCES animal_events(id_animal_event)
);
-- FIN DEL BLOQUE DE CARPETA: health-incidents


-- INICIO DEL BLOQUE DE CARPETA: fattening-entries
-- ============================================================
-- TABLA: fattening_entries
-- MÓDULO: Engorde — Ingreso al Ciclo de Engorde
-- ============================================================
--
-- DESCRIPCIÓN:
--   Registra el ingreso formal de un animal al ciclo de Engorde.
--   Un animal puede llegar a Engorde desde Recría (rearing_selection
--   con destination='fattening') o por compra directa (animal_purchases
--   con el animal ya en estado Engorde).
--
-- REGLAS DE NEGOCIO:
--   - RN-09: Un animal pasa a Engorde solo si está en Recría Y la estancia
--             tiene el rubro Engorde habilitado (ranch_production_types).
--   - RF-06.1: Registrar fecha, peso inicial y tipo de sistema.
--
-- LÓGICA BACKEND (al registrar un ingreso a engorde):
--   1. Verificar que el animal tiene id_productive_status=2 (Recría)
--   2. Verificar que la estancia tiene id_production_type=3 (Engorde) activo
--   3. Crear animal_event (id_event_type=14 'fattening_entry')
--   4. Crear fattening_entries
--   5. Actualizar ranch_animals: id_productive_status=3 (Fattening)
--
-- INDICADORES DEL CICLO DE ENGORDE (calculados, no almacenados):
--   - Ganancia de peso: weight_records (pesajes posteriores) - initial_weight
--   - Conversión alimenticia (RF-06.4):
--       consumo = SUM(feed_records.quantity) del lote en el período
--       ganancia = SUM(delta de weight_records) del animal en el período
--       eficiencia = consumo / ganancia
--   - La salida comercial se registra en animal_sales (Movimientos)
--   - El retiro sanitario que puede bloquear la venta: treatments.withdrawal_end_date
--
-- CAMPOS:
--   - system_type:    field=campo abierto | feedlot=corral de engorde
--   - initial_weight: peso al inicio del ciclo de engorde (base para calcular ganancia)
-- ============================================================
CREATE TABLE fattening_entries (
    id_entry            BIGSERIAL,
    id_event            BIGINT          NOT NULL,
    system_type         VARCHAR(20)     NOT NULL
        CHECK (system_type IN (
            'field',      -- campo abierto
            'feedlot'     -- corral de engorde
        )),
    initial_weight      NUMERIC(8,2),             -- peso base del ciclo; weight_records registra los siguientes
    notes               TEXT,
    created_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_entry),
    FOREIGN KEY (id_event) REFERENCES animal_events(id_animal_event)
);
-- FIN DEL BLOQUE DE CARPETA: fattening-entries


-- INICIO DEL BLOQUE DE CARPETA: feed-records
-- ============================================================
-- TABLA: feed_records
-- MÓDULO: Engorde — Registro de Alimentación por Lote
-- ============================================================
--
-- DESCRIPCIÓN:
--   Registra el suministro de alimento a un LOTE de animales. Es la
--   ÚNICA tabla transaccional del sistema que no pasa por animal_events,
--   porque la alimentación se gestiona a nivel de lote, no por animal
--   individual (una sola medición para todo el lote).
--
-- POR ESO TIENE SU PROPIO is_synced:
--   Al no estar vinculada a animal_events, necesita su propio campo
--   is_synced para el seguimiento offline (RNF-01.4).
--
-- CÓMO SE USA (RF-06.2):
--   El responsable registra qué se le dio al lote, cuánto y a qué costo.
--   El tipo de alimento es texto libre (maíz, balanceado, heno, etc.).
--   La cantidad y unidad permiten calcular el consumo total del período.
--
-- CONVERSIÓN ALIMENTICIA (RF-06.4 — calculada, no almacenada):
--   Para un lote en un período:
--   consumo_total  = SUM(quantity) de feed_records del lote en el período
--   ganancia_total = SUM(delta de weight entre registros de weight_records)
--   eficiencia     = consumo_total / ganancia_total
--   → Este cálculo lo hace el backend al consultar indicadores de Engorde.
--
-- REGLAS:
--   - El lote debe ser de tipo 'fattening' para registrar alimentación de Engorde.
--     (También puede usarse para lotes 'rearing' si corresponde.)
--   - id_user es quien registra (no genera animal_event, no hay id_event_type).
--
-- CAMPOS:
--   - id_lot:     lote al que se suministró el alimento
--   - id_user:    usuario que registró el suministro
--   - feed_date:  fecha del suministro
--   - feed_type:  tipo de alimento (texto libre: maíz, balanceado, heno, etc.)
--   - quantity:   cantidad suministrada
--   - unit:       unidad (kg, bolsas, fardos; NULL = kg por defecto)
--   - cost:       costo total del suministro (indicador económico)
--   - is_synced:  FALSE = pendiente de sincronizar (propio de esta tabla)
-- ============================================================
CREATE TABLE feed_records (
    id_feed             BIGSERIAL,
    id_lot              BIGINT          NOT NULL,
    id_user             BIGINT,
    feed_date           DATE            NOT NULL,
    feed_type           VARCHAR(150)    NOT NULL,                   -- texto libre: maíz, balanceado, etc.
    quantity            NUMERIC(10,2),                             -- cantidad suministrada
    unit                VARCHAR(20),                               -- kg, bolsas, etc. (null = kg por defecto)
    cost                NUMERIC(10,2),                             -- costo total del suministro
    notes               TEXT,
    is_synced           BOOLEAN         NOT NULL DEFAULT FALSE,    -- RNF-01.4: única tabla fuera de animal_events
    created_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_feed),
    FOREIGN KEY (id_lot)  REFERENCES ranch_lots(id_lot),
    FOREIGN KEY (id_user) REFERENCES users(id_user)
);
-- FIN DEL BLOQUE DE CARPETA: feed-records

-- FIN DEL SCRIPT
