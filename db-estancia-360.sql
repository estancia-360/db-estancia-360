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
CREATE TABLE production_types (
    id_type SERIAL,
    name VARCHAR(30) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (id_type)
);
INSERT INTO production_types (id_type,name) VALUES
(1,'Cria');
-- FIN DEL BLOQUE DE CARPETA: production-types


-- INICIO DEL BLOQUE DE CARPETA: productive-statuses
CREATE TABLE productive_statuses (
    id_productive_status int,
    name VARCHAR(50) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    primary key (id_productive_status)
);
-- FIN DEL BLOQUE DE CARPETA: productive-statuses


-- INICIO DEL BLOQUE DE CARPETA: ranch-roles
CREATE TABLE ranch_roles (
    id_role SERIAL,
    name VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (id_role)
);
INSERT INTO ranch_roles (id_role,name) VALUES
(1,'Owner'),
(2,'Worker');
-- FIN DEL BLOQUE DE CARPETA: ranch-roles


-- INICIO DEL BLOQUE DE CARPETA: roles
CREATE TABLE roles (
    id_role int not null,
    name VARCHAR(30) UNIQUE NOT NULL,
    PRIMARY KEY (id_role)
);
INSERT INTO roles (id_role, name) VALUES
    (1, 'root'),
    (2, 'admin'),
    (3, 'user');
-- FIN DEL BLOQUE DE CARPETA: roles


-- INICIO DEL BLOQUE DE CARPETA: users
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
CREATE TABLE ranches (
    id_ranch SERIAL,
    id_city INT NOT NULL,
    id_production_type INT NOT NULL,
    name VARCHAR(200) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_ranch),
    FOREIGN KEY (id_city) REFERENCES cities(id_city),
    FOREIGN KEY (id_production_type) REFERENCES production_types(id_type)
);
-- FIN DEL BLOQUE DE CARPETA: ranches


-- INICIO DEL BLOQUE DE CARPETA: ranch-users
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
CREATE TABLE ranch_lots (
    id_lot bigserial,
    id_ranch int,
    id_ranch_pasture bigint NOT NULL,
    name VARCHAR(50) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    updated_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP NOT NULL,
    primary key (id_lot),
    foreign key (id_ranch) references ranches(id_ranch),
    foreign key (id_ranch_pasture) references ranch_pastures(id_ranch_pasture)
);
-- FIN DEL BLOQUE DE CARPETA: ranch-lots


-- INICIO DEL BLOQUE DE CARPETA: ranch-animals
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
-- FIN DEL BLOQUE DE CARPETA: ranch-animals


-- INICIO DEL BLOQUE DE CARPETA: event-types
CREATE TABLE event_types (
    id_event_type int,
    name VARCHAR(50) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (id_event_type)
);
-- FIN DEL BLOQUE DE CARPETA: event-types


-- INICIO DEL BLOQUE DE CARPETA: animal-events
CREATE TABLE animal_events (
    id_animal_event bigserial,
    id_user BIGINT,
    id_ranch_animal int,
    id_event_type int,
    notes text,
    is_synced BOOLEAN NOT NULL DEFAULT FALSE,
    event_date TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    primary key (id_animal_event),
    foreign key (id_ranch_animal) references ranch_animals(id_ranch_animal),
    foreign key (id_event_type) references event_types(id_event_type),
    foreign key (id_user) references users(id_user)
);
-- FIN DEL BLOQUE DE CARPETA: animal-events


-- INICIO DEL BLOQUE DE CARPETA: animal-declared-history
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
CREATE TABLE animal_exits (
    id_exit             BIGSERIAL,
    id_event            BIGINT          NOT NULL,
    reason              VARCHAR(150),
    created_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_exit),
    FOREIGN KEY (id_event) REFERENCES animal_events(id_animal_event)
);
-- FIN DEL BLOQUE DE CARPETA: animal-exits


-- INICIO DEL BLOQUE DE CARPETA: vaccinations
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
CREATE TABLE fattening_entries (
    id_entry            BIGSERIAL,
    id_event            BIGINT          NOT NULL,  -- animal_events: animal + fecha + usuario
    system_type         VARCHAR(20)     NOT NULL
        CHECK (system_type IN (
            'field',                               -- campo abierto
            'feedlot'                              -- corral de engorde
        )),
    initial_weight      NUMERIC(8,2),              -- peso base del ciclo; weight_records registra los siguientes
    notes               TEXT,
    created_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_entry),
    FOREIGN KEY (id_event) REFERENCES animal_events(id_animal_event)
    -- el animal llega desde rearing_selections (destination='fattening') o compra directa (animal_purchases)
    -- los pesajes de control del ciclo viven en weight_records (compartida con recria)
    -- el retiro sanitario que puede bloquear la venta se consulta en treatments.withdrawal_end_date
    -- la salida comercial se registra en animal_sales (movimientos)
);
-- FIN DEL BLOQUE DE CARPETA: fattening-entries


-- INICIO DEL BLOQUE DE CARPETA: feed-records
CREATE TABLE feed_records (
    id_feed             BIGSERIAL,
    id_lot              BIGINT          NOT NULL,  -- ranch_lots: lote al que se alimenta
    id_user             BIGINT,                    -- users: quien registró (sin animal_events por ser nivel lote)
    feed_date           DATE            NOT NULL,
    feed_type           VARCHAR(150)    NOT NULL,  -- texto libre: maíz, balanceado, etc.
    quantity            NUMERIC(10,2),             -- cantidad suministrada
    unit                VARCHAR(20),               -- kg, bolsas, etc. (null = kg por defecto)
    cost                NUMERIC(10,2),             -- costo total del suministro
    notes               TEXT,
    created_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_feed),
    FOREIGN KEY (id_lot)  REFERENCES ranch_lots(id_lot),
    FOREIGN KEY (id_user) REFERENCES users(id_user)
    -- combinado con weight_records del mismo lote permite calcular conversion alimenticia (RF-06.4):
    -- consumo total (sum quantity) / ganancia total (sum weight delta) = eficiencia
);
-- FIN DEL BLOQUE DE CARPETA: feed-records

-- FIN DEL SCRIPT
