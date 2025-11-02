
CREATE DATABASE LogisticaTP;
GO

USE LogisticaTP;
GO
CREATE TABLE Estado_Pedido (
    id_estado INT IDENTITY(1,1) PRIMARY KEY,
    nombre_estado VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(255) NULL
);

CREATE TABLE Estado_Despacho (
    id_estado INT IDENTITY(1,1) PRIMARY KEY,
    nombre_estado VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(255) NULL
);

-- 2) Entidades principales
CREATE TABLE Cliente (
    id_cliente INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(200) NOT NULL,
    direccion VARCHAR(300) NULL,
    tipo_cliente VARCHAR(50) NULL, -- farm/ hospital / drogueria...
    cuit VARCHAR(30) NULL,
    contacto VARCHAR(100) NULL
);

CREATE TABLE Producto (
    id_producto INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(200) NOT NULL,
    principio_activo VARCHAR(200) NULL,
    condicion_conservacion VARCHAR(200) NULL
);

CREATE TABLE Lote (
    id_lote INT IDENTITY(1,1) PRIMARY KEY,
    id_producto INT NOT NULL,
    fecha_ingreso DATE NOT NULL,
    fecha_vencimiento DATE NOT NULL,
    cantidad_disponible INT NOT NULL CHECK (cantidad_disponible >= 0),
    estado_lote VARCHAR(50) NULL, -- ej. VIGENTE/VENCIDO/CUARENTENA
    ubicacion VARCHAR(100) NULL,
    CONSTRAINT FK_Lote_Producto FOREIGN KEY (id_producto) REFERENCES Producto(id_producto)
);

CREATE TABLE Vehiculo (
    id_vehiculo INT IDENTITY(1,1) PRIMARY KEY,
    patente VARCHAR(20) NULL,
    tipo_vehiculo VARCHAR(50) NULL,
    capacidad INT NULL -- capacidad en unidades o kg
);

CREATE TABLE Caja (
    id_caja INT IDENTITY(1,1) PRIMARY KEY,
    codigo_qr VARCHAR(100) UNIQUE NULL,
    codigo_barras VARCHAR(100) UNIQUE NULL,
    tipo_caja VARCHAR(50) NULL,
    peso_total DECIMAL(9,2) NULL,
    volumen DECIMAL(9,3) NULL
);

CREATE TABLE Operario (
    id_operario INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(200) NOT NULL,
    turno VARCHAR(50) NULL,
    sector VARCHAR(100) NULL
);

-- 3) Pedido y su normalización de estado
CREATE TABLE Pedido (
    id_pedido INT IDENTITY(1,1) PRIMARY KEY,
    id_cliente INT NOT NULL,
    fecha_pedido DATE NOT NULL,
    id_estado INT NOT NULL,
    comentario VARCHAR(500) NULL,
    CONSTRAINT FK_Pedido_Cliente FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
    CONSTRAINT FK_Pedido_Estado FOREIGN KEY (id_estado) REFERENCES Estado_Pedido(id_estado)
);

-- 4) Detalle del pedido
CREATE TABLE Detalle_Pedido (
    id_detalle_pedido INT IDENTITY(1,1) PRIMARY KEY,
    id_pedido INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad_solicitada INT NOT NULL CHECK (cantidad_solicitada > 0),
    unidad_medida VARCHAR(20) NULL,
    CONSTRAINT FK_DetallePedido_Pedido FOREIGN KEY (id_pedido) REFERENCES Pedido(id_pedido),
    CONSTRAINT FK_DetallePedido_Producto FOREIGN KEY (id_producto) REFERENCES Producto(id_producto)
);

-- 5) Picking (cabecera) y Picking_Detalle (detalle por lote)
CREATE TABLE Picking (
    id_picking INT IDENTITY(1,1) PRIMARY KEY,
    id_detalle_pedido INT NOT NULL,
    id_operario INT NOT NULL,
    fecha_hora DATETIME NOT NULL DEFAULT GETDATE(),
    resultado_validacion VARCHAR(100) NULL, -- OK, ERROR, PARCIAL...
    comentarios VARCHAR(500) NULL,
    CONSTRAINT FK_Picking_DetallePedido FOREIGN KEY (id_detalle_pedido) REFERENCES Detalle_Pedido(id_detalle_pedido),
    CONSTRAINT FK_Picking_Operario FOREIGN KEY (id_operario) REFERENCES Operario(id_operario)
);

-- Picking_Detalle: un picking puede extraer de varios lotes (o fracciones)
CREATE TABLE Picking_Detalle (
    id_picking_detalle INT IDENTITY(1,1) PRIMARY KEY,
    id_picking INT NOT NULL,
    id_lote INT NOT NULL,
    cantidad_extraida INT NOT NULL CHECK (cantidad_extraida > 0),
    CONSTRAINT FK_PickingDetalle_Picking FOREIGN KEY (id_picking) REFERENCES Picking(id_picking),
    CONSTRAINT FK_PickingDetalle_Lote FOREIGN KEY (id_lote) REFERENCES Lote(id_lote)
);

-- 6) Caja_Detalle (N:M Caja <-> Lote)
CREATE TABLE Caja_Detalle (
    id_caja INT NOT NULL,
    id_lote INT NOT NULL,
    cantidad_contenida INT NOT NULL CHECK (cantidad_contenida >= 0),
    PRIMARY KEY (id_caja, id_lote),
    CONSTRAINT FK_CajaDetalle_Caja FOREIGN KEY (id_caja) REFERENCES Caja(id_caja),
    CONSTRAINT FK_CajaDetalle_Lote FOREIGN KEY (id_lote) REFERENCES Lote(id_lote)
);

-- 7) Despacho y Despacho_Caja
CREATE TABLE Despacho (
    id_despacho INT IDENTITY(1,1) PRIMARY KEY,
    id_vehiculo INT NULL,
    id_pedido INT NULL, -- un despacho puede agrupar 1..N pedidos (si querés 1 pedido por despacho sacá NULL)
    fecha_salida DATETIME NULL,
    fecha_llegada_estimada DATETIME NULL,
    fecha_entrega_real DATETIME NULL,
    id_estado INT NULL,
    CONSTRAINT FK_Despacho_Vehiculo FOREIGN KEY (id_vehiculo) REFERENCES Vehiculo(id_vehiculo),
    CONSTRAINT FK_Despacho_Pedido FOREIGN KEY (id_pedido) REFERENCES Pedido(id_pedido),
    CONSTRAINT FK_Despacho_Estado FOREIGN KEY (id_estado) REFERENCES Estado_Despacho(id_estado)
);

CREATE TABLE Despacho_Caja (
    id_despacho INT NOT NULL,
    id_caja INT NOT NULL,
    PRIMARY KEY (id_despacho, id_caja),
    CONSTRAINT FK_DespachoCaja_Despacho FOREIGN KEY (id_despacho) REFERENCES Despacho(id_despacho),
    CONSTRAINT FK_DespachoCaja_Caja FOREIGN KEY (id_caja) REFERENCES Caja(id_caja)
);

-- 8) Entrega (registro final de entrega al cliente)
CREATE TABLE Entrega (
    id_entrega INT IDENTITY(1,1) PRIMARY KEY,
    id_despacho INT NOT NULL,
    id_cliente INT NOT NULL,
    fecha_entrega DATE NOT NULL,
    hora TIME NULL,
    temperatura_registrada VARCHAR(50) NULL,
    conformidad VARCHAR(50) NULL,
    CONSTRAINT FK_Entrega_Despacho FOREIGN KEY (id_despacho) REFERENCES Despacho(id_despacho),
    CONSTRAINT FK_Entrega_Cliente FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente)
);

-- 9) Incidencias (por picking o por despacho)
CREATE TABLE Incidencia (
    id_incidencia INT IDENTITY(1,1) PRIMARY KEY,
    id_picking INT NULL,
    id_despacho INT NULL,
    tipo_incidencia VARCHAR(100) NULL,
    descripcion VARCHAR(1000) NULL,
    fecha_hora DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Incidencia_Picking FOREIGN KEY (id_picking) REFERENCES Picking(id_picking),
    CONSTRAINT FK_Incidencia_Despacho FOREIGN KEY (id_despacho) REFERENCES Despacho(id_despacho)
);
-- 10) Índices y optimizaciones básicas (FKs suelen recibir índices)
CREATE INDEX IX_DetallePedido_Pedido ON Detalle_Pedido(id_pedido);
CREATE INDEX IX_DetallePedido_Producto ON Detalle_Pedido(id_producto);

CREATE INDEX IX_Picking_DetallePedido ON Picking(id_detalle_pedido);
CREATE INDEX IX_Picking_Operario ON Picking(id_operario);

CREATE INDEX IX_PickingDetalle_Lote ON Picking_Detalle(id_lote);
CREATE INDEX IX_CajaDetalle_Lote ON Caja_Detalle(id_lote);

CREATE INDEX IX_Despacho_Vehiculo ON Despacho(id_vehiculo);
CREATE INDEX IX_Despacho_Pedido ON Despacho(id_pedido);

GO

SELECT DB_NAME() AS BaseActual; 
USE LogisticaTP;
GO

EXEC sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL';
EXEC sp_MSforeachtable 'DROP TABLE ?';
GO
SELECT name 
FROM sys.tables 
ORDER BY name;

-- 6) Caja_Detalle (N:M Caja <-> Lote)
CREATE TABLE Caja_Detalle (
    id_caja INT NOT NULL,
    id_lote INT NOT NULL,
    cantidad_contenida INT NOT NULL CHECK (cantidad_contenida >= 0),
    PRIMARY KEY (id_caja, id_lote),
    CONSTRAINT FK_CajaDetalle_Caja FOREIGN KEY (id_caja) REFERENCES Caja(id_caja),
    CONSTRAINT FK_CajaDetalle_Lote FOREIGN KEY (id_lote) REFERENCES Lote(id_lote)
);

-- 7) Despacho_Caja
CREATE TABLE Despacho_Caja (
    id_despacho INT NOT NULL,
    id_caja INT NOT NULL,
    PRIMARY KEY (id_despacho, id_caja),
    CONSTRAINT FK_DespachoCaja_Despacho FOREIGN KEY (id_despacho) REFERENCES Despacho(id_despacho),
    CONSTRAINT FK_DespachoCaja_Caja FOREIGN KEY (id_caja) REFERENCES Caja(id_caja)
);

-- 8) Entrega
CREATE TABLE Entrega (
    id_entrega INT IDENTITY(1,1) PRIMARY KEY,
    id_despacho INT NOT NULL,
    id_cliente INT NOT NULL,
    fecha_entrega DATE NOT NULL,
    hora TIME NULL,
    temperatura_registrada VARCHAR(50) NULL,
    conformidad VARCHAR(50) NULL,
    CONSTRAINT FK_Entrega_Despacho FOREIGN KEY (id_despacho) REFERENCES Despacho(id_despacho),
    CONSTRAINT FK_Entrega_Cliente FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente)
);

-- 9) Incidencia
CREATE TABLE Incidencia (
    id_incidencia INT IDENTITY(1,1) PRIMARY KEY,
    id_picking INT NULL,
    id_despacho INT NULL,
    tipo_incidencia VARCHAR(100) NULL,
    descripcion VARCHAR(1000) NULL,
    fecha_hora DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Incidencia_Picking FOREIGN KEY (id_picking) REFERENCES Picking(id_picking),
    CONSTRAINT FK_Incidencia_Despacho FOREIGN KEY (id_despacho) REFERENCES Despacho(id_despacho)
);


INSERT INTO Estado_Pedido (nombre_estado, descripcion) VALUES
('Pendiente','Pedido recibido, sin procesar'),
('En preparación','En proceso de preparación en almacén'),
('En picking','Extracción en curso'),
('Despachado','Pedido listo para envío'),
('Entregado','Pedido entregado al cliente'),
('Cancelado','Pedido anulado'),
('Rechazado','Error de validación'),
('Facturado','Con documentación completa'),
('Aprobado','Aprobado por control de stock'),
('En revisión','Pendiente de control de calidad');

INSERT INTO Estado_Despacho (nombre_estado, descripcion) VALUES
('Planificado','Despacho programado'),
('En ruta','Vehículo en tránsito'),
('Entregado','Despacho completado'),
('Incidencia','Problema durante envío'),
('Reprogramado','Cambio de fecha'),
('Preparando','Preparando consolidación'),
('Cancelado','Anulado por control'),
('Validando','Esperando control'),
('Confirmado','Aprobado para salida'),
('Demorado','Retrasado por logística');


INSERT INTO Estado_Pedido (nombre_estado, descripcion) VALUES
('Pendiente','Pedido recibido, sin procesar'),
('En preparación','En proceso de preparación en almacén'),
('En picking','Extracción en curso'),
('Despachado','Pedido listo para envío'),
('Entregado','Pedido entregado al cliente'),
('Cancelado','Pedido anulado'),
('Rechazado','Error de validación'),
('Facturado','Con documentación completa'),
('Aprobado','Aprobado por control de stock'),
('En revisión','Pendiente de control de calidad');

INSERT INTO Estado_Despacho (nombre_estado, descripcion) VALUES
('Planificado','Despacho programado'),
('En ruta','Vehículo en tránsito'),
('Entregado','Despacho completado'),
('Incidencia','Problema durante envío'),
('Reprogramado','Cambio de fecha'),
('Preparando','Preparando consolidación'),
('Cancelado','Anulado por control'),
('Validando','Esperando control'),
('Confirmado','Aprobado para salida'),
('Demorado','Retrasado por logística');

INSERT INTO Producto (nombre, principio_activo, condicion_conservacion) VALUES
('Paracetamol 500mg', 'Paracetamol', 'Temperatura ambiente'),
('Ibuprofeno 400mg', 'Ibuprofeno', 'Temperatura ambiente'),
('Amoxicilina 500mg', 'Amoxicilina', 'Ambiente seco'),
('Omeprazol 20mg', 'Omeprazol', 'Temperatura ambiente'),
('Enalapril 10mg', 'Enalapril', 'Lugar seco y fresco'),
('Metformina 850mg', 'Metformina', 'Temperatura ambiente'),
('Atorvastatina 20mg', 'Atorvastatina', 'Menos de 25°C'),
('Loratadina 10mg', 'Loratadina', 'Ambiente seco'),
('Salbutamol Inhalador', 'Salbutamol', 'Ambiente fresco'),
('Amiodarona 200mg', 'Amiodarona', 'Lugar seco');

INSERT INTO Lote (id_producto, fecha_ingreso, fecha_vencimiento, cantidad_disponible, estado_lote, ubicacion)
VALUES
(1,'2025-01-10','2027-01-10',500,'VIGENTE','A1'),
(2,'2025-02-15','2026-12-01',400,'VIGENTE','A2'),
(3,'2025-03-05','2026-05-30',350,'VIGENTE','B1'),
(4,'2025-01-25','2026-10-15',300,'VIGENTE','B2'),
(5,'2025-04-20','2026-08-10',250,'VIGENTE','C1'),
(6,'2025-05-05','2027-01-05',600,'VIGENTE','C2'),
(7,'2025-06-01','2026-12-15',450,'VIGENTE','D1'),
(8,'2025-06-10','2026-07-01',500,'VIGENTE','D2'),
(9,'2025-07-01','2026-09-30',200,'CUARENTENA','E1'),
(10,'2025-07-15','2026-10-01',150,'VIGENTE','E2');

INSERT INTO Vehiculo (patente, tipo_vehiculo, capacidad) VALUES
('AA123BB','Camión','1000'),
('AB456CD','Camión','1200'),
('AC789EF','Furgón','800'),
('AD111GH','Camioneta','600'),
('AE222IJ','Camión refrigerado','900'),
('AF333KL','Camioneta','700'),
('AG444MN','Camión','1000'),
('AH555OP','Furgón','850'),
('AI666QR','Camión','950'),
('AJ777ST','Camión','1100');

INSERT INTO Operario (nombre, turno, sector) VALUES
('Juan Pérez','Mañana','Picking'),
('María García','Tarde','Picking'),
('Luis Fernández','Noche','Embalaje'),
('Ana Martínez','Mañana','Control'),
('Carlos Gómez','Tarde','Despacho'),
('Laura Ruiz','Mañana','Control'),
('Pedro Silva','Noche','Picking'),
('Lucía Torres','Tarde','Embalaje'),
('Hernán Díaz','Mañana','Picking'),
('Sofía Vega','Tarde','Despacho');

INSERT INTO Pedido (id_cliente, fecha_pedido, id_estado, comentario) VALUES
(1,'2025-10-20',1,'Pedido inicial'),
(2,'2025-10-20',2,'Urgente'),
(3,'2025-10-21',3,'Pedido parcial'),
(4,'2025-10-21',1,'Entrega programada'),
(5,'2025-10-22',1,'Reposición'),
(6,'2025-10-22',4,'Ya en despacho'),
(7,'2025-10-23',5,'Entregado'),
(8,'2025-10-23',2,'Pendiente validación'),
(9,'2025-10-24',3,'En picking'),
(10,'2025-10-25',6,'Cancelado');

INSERT INTO Detalle_Pedido (id_pedido, id_producto, cantidad_solicitada, unidad_medida) VALUES
(1,1,100,'cajas'),
(1,2,50,'cajas'),
(2,3,80,'cajas'),
(3,4,70,'cajas'),
(4,5,40,'blisters'),
(5,6,60,'blisters'),
(6,7,90,'cajas'),
(7,8,30,'blisters'),
(8,9,25,'unidades'),
(9,10,15,'unidades'),
(10,1,10,'cajas');

INSERT INTO Picking (id_detalle_pedido, id_operario, resultado_validacion) VALUES
(1,1,'OK'),(2,2,'OK'),(3,3,'OK'),(4,1,'OK'),(5,2,'OK'),
(6,3,'OK'),(7,4,'PARCIAL'),(8,5,'OK'),(9,6,'OK'),(10,7,'ERROR');

INSERT INTO Picking_Detalle (id_picking, id_lote, cantidad_extraida) VALUES
(1,1,80),(2,2,50),(3,3,60),(4,4,50),(5,5,40),
(6,6,55),(7,7,40),(8,8,25),(9,9,10),(10,10,5);

INSERT INTO Caja (codigo_qr, codigo_barras, tipo_caja, peso_total, volumen) VALUES
('QR001','CB001','Mediana',10.5,0.3),
('QR002','CB002','Grande',15.2,0.4),
('QR003','CB003','Mediana',9.8,0.25),
('QR004','CB004','Chica',5.0,0.15),
('QR005','CB005','Grande',14.5,0.4),
('QR006','CB006','Mediana',10.0,0.3),
('QR007','CB007','Grande',15.5,0.45),
('QR008','CB008','Chica',6.0,0.2),
('QR009','CB009','Grande',14.0,0.4),
('QR010','CB010','Mediana',9.5,0.28);
INSERT INTO Cliente (nombre, direccion, tipo_cliente, cuit, contacto) VALUES
('Farmacia Central', 'Av. Corrientes 1234, CABA', 'Farmacia', '30-12345678-9', 'María López'),
('Hospital San Martín', 'Belgrano 555, La Plata', 'Hospital', '30-98765432-1', 'Dr. Gómez'),
('Droguería Norte', 'Ruta 8 Km 45, Pilar', 'Droguería', '30-11122333-4', 'Carlos Ruiz'),
('Hospital Italiano', 'Gascon 450, CABA', 'Hospital', '30-55566677-8', 'Lucía Méndez'),
('Farmacia Belgrano', 'Juramento 2500, CABA', 'Farmacia', '30-44455566-7', 'Ana Torres'),
('Hospital El Cruce', 'Av. Calchaquí 5400, Quilmes', 'Hospital', '30-22233344-5', 'Dr. Pereyra'),
('Farmacia Mitre', 'Mitre 980, Morón', 'Farmacia', '30-10101010-1', 'Hernán Soto'),
('Farmacia Salud', 'Av. San Martín 1200, Lanús', 'Farmacia', '30-22221111-9', 'Paula Álvarez'),
('Clínica del Sol', 'Av. Rivadavia 7200, CABA', 'Clínica', '30-98989898-7', 'Dr. López'),
('Droguería Sur', 'Ruta 205 Km 25, Ezeiza', 'Droguería', '30-87878787-3', 'Javier Díaz');


INSERT INTO Caja_Detalle (id_caja, id_lote, cantidad_contenida) VALUES
(1,1,20),(2,2,30),(3,3,25),(4,4,15),(5,5,10),
(6,6,30),(7,7,25),(8,8,20),(9,9,10),(10,10,15);

INSERT INTO Despacho (id_vehiculo, id_pedido, fecha_salida, fecha_llegada_estimada, id_estado) VALUES
(1,1,'2025-10-22 08:00','2025-10-22 14:00',1),
(2,2,'2025-10-22 09:00','2025-10-22 15:00',2),
(3,3,'2025-10-23 07:30','2025-10-23 12:00',2),
(4,4,'2025-10-23 10:00','2025-10-23 16:00',1),
(5,5,'2025-10-24 08:30','2025-10-24 14:00',1),
(6,6,'2025-10-24 09:00','2025-10-24 15:00',2),
(7,7,'2025-10-25 07:00','2025-10-25 13:00',3),
(8,8,'2025-10-25 10:00','2025-10-25 18:00',1),
(9,9,'2025-10-26 09:00','2025-10-26 15:00',2),
(10,10,'2025-10-26 10:00','2025-10-26 17:00',4);

INSERT INTO Despacho_Caja (id_despacho, id_caja) VALUES
(1,1),(2,2),(3,3),(4,4),(5,5),(6,6),(7,7),(8,8),(9,9),(10,10);


INSERT INTO Entrega (id_despacho, id_cliente, fecha_entrega, hora, temperatura_registrada, conformidad)
VALUES
(1,1,'2025-10-22','13:45','22°C','OK'),
(2,2,'2025-10-22','15:00','20°C','OK'),
(3,3,'2025-10-23','12:15','23°C','OK'),
(4,4,'2025-10-23','16:20','21°C','OK'),
(5,5,'2025-10-24','13:30','24°C','OK'),
(6,6,'2025-10-24','15:10','19°C','OK'),
(7,7,'2025-10-25','12:40','21°C','OK'),
(8,8,'2025-10-25','17:50','23°C','OK'),
(9,9,'2025-10-26','14:30','22°C','OK'),
(10,10,'2025-10-26','16:45','20°C','Demora');

INSERT INTO Incidencia (id_picking, id_despacho, tipo_incidencia, descripcion)
VALUES
(7,7,'Falta stock','Cantidad incompleta para Atorvastatina'),
(10,10,'Error picking','Producto equivocado cargado'),
(9,9,'Demora transporte','Retraso por congestión'),
(8,8,'Caja dañada','Caja húmeda en control'),
(6,6,'Error validación','Diferencia detectada en cantidad'),
(5,5,'Retraso salida','Demora en control'),
(4,4,'Producto faltante','Lote 4 con merma'),
(3,3,'Rotura','Producto dañado en embalaje'),
(2,2,'Error sistema','Lectura QR fallida'),
(1,1,'Demora operario','Retraso en picking inicial');


SELECT t.name AS Tabla, SUM(p.rows) AS Registros
FROM sys.tables t
JOIN sys.partitions p ON t.object_id = p.object_id
WHERE p.index_id IN (0,1)
GROUP BY t.name
ORDER BY Tabla;


SELECT * FROM Cliente;
SELECT * FROM Producto;
SELECT * FROM Lote;
SELECT * FROM Pedido;
SELECT * FROM Detalle_Pedido;
SELECT * FROM Picking;
SELECT * FROM Caja;
SELECT * FROM Caja_Detalle;
SELECT * FROM Despacho;
SELECT * FROM Despacho_Caja;
SELECT * FROM Entrega;
SELECT * FROM Incidencia;
SELECT * FROM Estado_Pedido;
SELECT * FROM Estado_Despacho;
SELECT * FROM Picking_Detalle;


SELECT name 
FROM sys.tables 
WHERE name LIKE '%Picking%';

CREATE TABLE Picking_Detalle (
    id_picking_detalle INT IDENTITY(1,1) PRIMARY KEY,
    id_picking INT NOT NULL,
    id_lote INT NOT NULL,
    cantidad_extraida INT NOT NULL CHECK (cantidad_extraida > 0),
    CONSTRAINT FK_PickingDetalle_Picking FOREIGN KEY (id_picking) REFERENCES Picking(id_picking),
    CONSTRAINT FK_PickingDetalle_Lote FOREIGN KEY (id_lote) REFERENCES Lote(id_lote)
);
GO

SELECT name, create_date 
FROM sys.tables 
WHERE name = 'Picking';

SELECT DB_NAME() AS Base_Actual;
USE LogisticaTP;
GO


USE LogisticaTP;
GO
DROP TABLE IF EXISTS Picking;
GO
CREATE TABLE Picking (
    id_picking INT IDENTITY(1,1) PRIMARY KEY,
    id_detalle_pedido INT NOT NULL,
    id_operario INT NOT NULL,
    fecha_hora DATETIME NOT NULL DEFAULT GETDATE(),
    resultado_validacion VARCHAR(100) NULL,
    comentarios VARCHAR(500) NULL,
    CONSTRAINT FK_Picking_DetallePedido FOREIGN KEY (id_detalle_pedido) REFERENCES Detalle_Pedido(id_detalle_pedido),
    CONSTRAINT FK_Picking_Operario FOREIGN KEY (id_operario) REFERENCES Operario(id_operario)
);
GO



















