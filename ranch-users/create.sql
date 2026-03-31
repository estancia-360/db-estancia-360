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