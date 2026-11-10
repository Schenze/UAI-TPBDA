-- =====================================================================
-- Base de datos: Stock de vehículos GT3 (UAI - TPBDA)
-- Motor: Microsoft SQL Server 2016+ (T-SQL)
-- Deriva del front-end del repo:
--   login.html  -> tabla usuario
--   index.html  -> vehículos en stock (nombre, chasis, tipo de motor),
--                  filtro por provincia/localidad y stock mínimo para alerta
-- Ejecutar completo en SSMS / Azure Data Studio.
-- =====================================================================

IF DB_ID('GT3') IS NOT NULL
BEGIN
    ALTER DATABASE GT3 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE GT3;
END
GO

CREATE DATABASE GT3;
GO

USE GT3;
GO

-- ---------------------------------------------------------------------
-- 1. Usuarios (login.html)
-- ---------------------------------------------------------------------
CREATE TABLE usuario (
    id_usuario     INT IDENTITY(1,1) CONSTRAINT PK_usuario PRIMARY KEY,
    login          VARCHAR(50)   NOT NULL CONSTRAINT UQ_usuario_login UNIQUE,
    password_hash  VARCHAR(255)  NOT NULL,   -- nunca guardar la contraseña en texto plano
    activo         BIT           NOT NULL CONSTRAINT DF_usuario_activo DEFAULT 1,
    creado_en      DATETIME2(0)  NOT NULL CONSTRAINT DF_usuario_creado DEFAULT SYSDATETIME()
);
GO

-- ---------------------------------------------------------------------
-- 2. Ubicación (filtros Provincia / Localidad)
-- ---------------------------------------------------------------------
CREATE TABLE provincia (
    id_provincia   INT IDENTITY(1,1) CONSTRAINT PK_provincia PRIMARY KEY,
    nombre         NVARCHAR(80) NOT NULL CONSTRAINT UQ_provincia_nombre UNIQUE
);

CREATE TABLE localidad (
    id_localidad   INT IDENTITY(1,1) CONSTRAINT PK_localidad PRIMARY KEY,
    id_provincia   INT          NOT NULL
                   CONSTRAINT FK_localidad_provincia REFERENCES provincia(id_provincia),
    nombre         NVARCHAR(80) NOT NULL,
    CONSTRAINT UQ_localidad UNIQUE (id_provincia, nombre)
);
GO

-- ---------------------------------------------------------------------
-- 3. Catálogo de vehículos
-- ---------------------------------------------------------------------
CREATE TABLE tipo_motor (
    id_tipo_motor  INT IDENTITY(1,1) CONSTRAINT PK_tipo_motor PRIMARY KEY,
    descripcion    NVARCHAR(80) NOT NULL CONSTRAINT UQ_tipo_motor UNIQUE   -- ej: 4.0L Bóxer 6 cilindros
);

CREATE TABLE modelo (
    id_modelo      INT IDENTITY(1,1) CONSTRAINT PK_modelo PRIMARY KEY,
    nombre         NVARCHAR(100) NOT NULL CONSTRAINT UQ_modelo_nombre UNIQUE,  -- "Nombre" del tablero
    id_tipo_motor  INT           NOT NULL
                   CONSTRAINT FK_modelo_tipo_motor REFERENCES tipo_motor(id_tipo_motor)
);
GO

-- ---------------------------------------------------------------------
-- 4. Sucursales (donde se guarda el stock) y su stock mínimo de alerta
-- ---------------------------------------------------------------------
CREATE TABLE sucursal (
    id_sucursal    INT IDENTITY(1,1) CONSTRAINT PK_sucursal PRIMARY KEY,
    nombre         NVARCHAR(100) NOT NULL CONSTRAINT UQ_sucursal_nombre UNIQUE,
    id_localidad   INT           NOT NULL
                   CONSTRAINT FK_sucursal_localidad REFERENCES localidad(id_localidad),
    stock_minimo   INT           NOT NULL CONSTRAINT DF_sucursal_stock_minimo DEFAULT 1
                   CONSTRAINT CK_sucursal_stock_minimo CHECK (stock_minimo >= 0)
                   -- "Mínimo stock para la alerta"
);
GO

-- ---------------------------------------------------------------------
-- 5. Vehículos físicos (cada uno con su chasis)
-- ---------------------------------------------------------------------
CREATE TABLE vehiculo (
    id_vehiculo    INT IDENTITY(1,1) CONSTRAINT PK_vehiculo PRIMARY KEY,
    chasis         VARCHAR(17)  NOT NULL CONSTRAINT UQ_vehiculo_chasis UNIQUE,   -- VIN: 17 caracteres
    id_modelo      INT          NOT NULL
                   CONSTRAINT FK_vehiculo_modelo REFERENCES modelo(id_modelo),
    id_sucursal    INT          NOT NULL
                   CONSTRAINT FK_vehiculo_sucursal REFERENCES sucursal(id_sucursal),
    estado         VARCHAR(10)  NOT NULL CONSTRAINT DF_vehiculo_estado DEFAULT 'EN_STOCK'
                   CONSTRAINT CK_vehiculo_estado CHECK (estado IN ('EN_STOCK', 'VENDIDO')),
    fecha_ingreso  DATE         NOT NULL CONSTRAINT DF_vehiculo_ingreso DEFAULT CAST(SYSDATETIME() AS DATE),
    fecha_egreso   DATE         NULL,
    CONSTRAINT CK_vehiculo_fechas CHECK (fecha_egreso IS NULL OR fecha_egreso >= fecha_ingreso),
    CONSTRAINT CK_vehiculo_estado_egreso CHECK (
        (estado = 'VENDIDO'  AND fecha_egreso IS NOT NULL) OR
        (estado = 'EN_STOCK' AND fecha_egreso IS NULL)
    )
);

CREATE INDEX ix_vehiculo_sucursal_estado ON vehiculo (id_sucursal, estado);
CREATE INDEX ix_vehiculo_modelo          ON vehiculo (id_modelo);
CREATE INDEX ix_localidad_provincia      ON localidad (id_provincia);
CREATE INDEX ix_sucursal_localidad       ON sucursal (id_localidad);
GO

-- ---------------------------------------------------------------------
-- 6. Vistas que alimentan el tablero (index.html)
-- ---------------------------------------------------------------------

-- Lista de vehículos en stock: Nombre / Chasis / Motor + provincia y localidad
CREATE VIEW v_vehiculos_en_stock AS
SELECT v.id_vehiculo,
       m.nombre       AS nombre,
       v.chasis       AS chasis,
       tm.descripcion AS motor,
       p.id_provincia,
       p.nombre       AS provincia,
       l.id_localidad,
       l.nombre       AS localidad,
       s.nombre       AS sucursal
FROM vehiculo v
JOIN modelo     m  ON m.id_modelo      = v.id_modelo
JOIN tipo_motor tm ON tm.id_tipo_motor = m.id_tipo_motor
JOIN sucursal   s  ON s.id_sucursal    = v.id_sucursal
JOIN localidad  l  ON l.id_localidad   = s.id_localidad
JOIN provincia  p  ON p.id_provincia   = l.id_provincia
WHERE v.estado = 'EN_STOCK';
GO

-- Stock por sucursal y alerta cuando está por debajo del mínimo
-- (incluye sucursales con 0 vehículos)
CREATE VIEW v_stock_por_sucursal AS
SELECT s.id_sucursal,
       s.nombre       AS sucursal,
       p.nombre       AS provincia,
       l.nombre       AS localidad,
       COUNT(v.id_vehiculo) AS stock,
       s.stock_minimo,
       CAST(CASE WHEN COUNT(v.id_vehiculo) < s.stock_minimo THEN 1 ELSE 0 END AS BIT) AS alerta
FROM sucursal s
JOIN localidad l ON l.id_localidad = s.id_localidad
JOIN provincia p ON p.id_provincia = l.id_provincia
LEFT JOIN vehiculo v ON v.id_sucursal = s.id_sucursal AND v.estado = 'EN_STOCK'
GROUP BY s.id_sucursal, s.nombre, p.nombre, l.nombre, s.stock_minimo;
GO

-- Total "Vehículos en stock" del tablero principal
CREATE VIEW v_total_stock AS
SELECT COUNT(*) AS vehiculos_en_stock
FROM vehiculo
WHERE estado = 'EN_STOCK';
GO

-- ---------------------------------------------------------------------
-- 7. Datos de ejemplo (las provincias/localidades del <select> del front)
-- ---------------------------------------------------------------------
INSERT INTO provincia (nombre) VALUES (N'Santa Fe'), (N'Buenos Aires'), (N'Córdoba');

INSERT INTO localidad (id_provincia, nombre) VALUES
    ((SELECT id_provincia FROM provincia WHERE nombre = N'Santa Fe'),     N'Rosario'),
    ((SELECT id_provincia FROM provincia WHERE nombre = N'Buenos Aires'), N'Rojas'),
    ((SELECT id_provincia FROM provincia WHERE nombre = N'Córdoba'),      N'Córdoba Ciudad');

INSERT INTO tipo_motor (descripcion) VALUES
    (N'4.0L Bóxer 6 cilindros atmosférico'),
    (N'3.0L Bóxer 6 cilindros biturbo');

INSERT INTO modelo (nombre, id_tipo_motor) VALUES
    (N'911 GT3',    (SELECT id_tipo_motor FROM tipo_motor WHERE descripcion LIKE N'4.0L%')),
    (N'911 GT3 RS', (SELECT id_tipo_motor FROM tipo_motor WHERE descripcion LIKE N'4.0L%')),
    (N'911 Turbo',  (SELECT id_tipo_motor FROM tipo_motor WHERE descripcion LIKE N'3.0L%'));

INSERT INTO sucursal (nombre, id_localidad, stock_minimo) VALUES
    (N'Sucursal Rosario', (SELECT id_localidad FROM localidad WHERE nombre = N'Rosario'),        3),
    (N'Sucursal Rojas',   (SELECT id_localidad FROM localidad WHERE nombre = N'Rojas'),          2),
    (N'Sucursal Córdoba', (SELECT id_localidad FROM localidad WHERE nombre = N'Córdoba Ciudad'), 2);

INSERT INTO vehiculo (chasis, id_modelo, id_sucursal, estado, fecha_ingreso, fecha_egreso) VALUES
    ('WP0ZZZ99ZNS100001', 1, 1, 'EN_STOCK', '2026-01-10', NULL),
    ('WP0ZZZ99ZNS100002', 2, 1, 'EN_STOCK', '2026-02-05', NULL),
    ('WP0ZZZ99ZNS100003', 3, 1, 'EN_STOCK', '2026-03-12', NULL),
    ('WP0ZZZ99ZNS100004', 1, 2, 'EN_STOCK', '2026-04-01', NULL),
    ('WP0ZZZ99ZNS100005', 2, 3, 'EN_STOCK', '2026-05-20', NULL),
    ('WP0ZZZ99ZNS100006', 1, 3, 'VENDIDO',  '2026-02-01', '2026-06-15');

-- Usuario de ejemplo. El hash es un placeholder: la aplicación debe generar
-- el hash real con bcrypt/argon2 (no usar HASHBYTES sin sal para contraseñas).
INSERT INTO usuario (login, password_hash) VALUES ('admin', 'REEMPLAZAR_POR_HASH_BCRYPT');
GO

-- ---------------------------------------------------------------------
-- 8. Consultas de ejemplo para el front
-- ---------------------------------------------------------------------
-- Total:                      SELECT * FROM v_total_stock;
-- Lista filtrada (Provincia): SELECT nombre, chasis, motor FROM v_vehiculos_en_stock WHERE provincia = N'Santa Fe';
-- Lista filtrada (Localidad): SELECT nombre, chasis, motor FROM v_vehiculos_en_stock WHERE localidad = N'Rosario';
-- Alertas:                    SELECT * FROM v_stock_por_sucursal WHERE alerta = 1;
