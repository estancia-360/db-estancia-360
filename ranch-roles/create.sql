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