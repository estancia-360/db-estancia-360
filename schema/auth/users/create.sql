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
--   - reset_code_hash / reset_code_expires_at: código de "recuperar contraseña" vigente,
--     hasheado (bcrypt, igual que password) — nunca se guarda en texto plano. NULL cuando no
--     hay ningún código pendiente (se limpian al usarse o al pedir uno nuevo).
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
    reset_code_hash VARCHAR(255),
    reset_code_expires_at TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_user),
    FOREIGN KEY (id_role) REFERENCES roles(id_role)
);