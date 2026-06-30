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