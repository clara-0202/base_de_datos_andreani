USE LogiTrack;
GO




/*

Creo las tablas de todooo, y despues le voy a insertar los datos que quiera

-- CLIENTES
CREATE TABLE Cliente (
  ClienteID INT PRIMARY KEY IDENTITY(1,1),
  Nombre NVARCHAR(100) NOT NULL,
  CUIT CHAR(11),
  Direccion NVARCHAR(200),
  Telefono NVARCHAR(20),
  Email NVARCHAR(100)
);

-- PEDIDOS
CREATE TABLE Pedido (
  PedidoID INT PRIMARY KEY IDENTITY(1,1),
  ClienteID INT NOT NULL,
  FechaPedido DATE NOT NULL,
  Estado NVARCHAR(20) DEFAULT 'Pendiente',
  TipoServicio NVARCHAR(20),
  FOREIGN KEY (ClienteID) REFERENCES Cliente(ClienteID)
);

-- PAQUETES
CREATE TABLE Paquete (
  PaqueteID INT PRIMARY KEY IDENTITY(1,1),
  PedidoID INT NOT NULL,
  Peso DECIMAL(6,2),
  Dimensiones NVARCHAR(50),
  Destino NVARCHAR(200),
  Prioridad NVARCHAR(10),
  FOREIGN KEY (PedidoID) REFERENCES Pedido(PedidoID)
);

-- CHOFERES
CREATE TABLE Chofer (
  ChoferID INT PRIMARY KEY IDENTITY(1,1),
  Nombre NVARCHAR(100) NOT NULL,
  DNI CHAR(8),
  Telefono NVARCHAR(20),
  Licencia NVARCHAR(20),
  FechaIngreso DATE
);

-- VEHÍCULOS
CREATE TABLE Vehiculo (
  VehiculoID INT PRIMARY KEY IDENTITY(1,1),
  Patente NVARCHAR(10) UNIQUE,
  Tipo NVARCHAR(50),
  Capacidad DECIMAL(6,2),
  Estado NVARCHAR(20)
);

-- ENTREGAS
CREATE TABLE Entrega (
  EntregaID INT PRIMARY KEY IDENTITY(1,1),
  ChoferID INT NOT NULL,
  VehiculoID INT NOT NULL,
  PaqueteID INT NOT NULL,
  FechaSalida DATE,
  FechaEntrega DATE,
  EstadoEntrega NVARCHAR(20),
  FOREIGN KEY (ChoferID) REFERENCES Chofer(ChoferID),
  FOREIGN KEY (VehiculoID) REFERENCES Vehiculo(VehiculoID),
  FOREIGN KEY (PaqueteID) REFERENCES Paquete(PaqueteID)
);

-- RUTAS
CREATE TABLE Ruta (
  RutaID INT PRIMARY KEY IDENTITY(1,1),
  Origen NVARCHAR(100),
  Destino NVARCHAR(100),
  DistanciaKM DECIMAL(8,2)
);

-- ENTREGAS_RUTAS (relación N:N)
CREATE TABLE Entrega_Ruta (
  EntregaID INT,
  RutaID INT,
  Orden INT,
  PRIMARY KEY (EntregaID, RutaID),
  FOREIGN KEY (EntregaID) REFERENCES Entrega(EntregaID),
  FOREIGN KEY (RutaID) REFERENCES Ruta(RutaID)
);

*/

INSERT INTO Cliente (Nombre, CUIT, Direccion, Telefono, Email)
VALUES
('Juan', '20345678901', 'Av. Siempre Viva 742', '1122334455', 'contacto@empresaa.com'),
('Emilio', '20987654321', 'Calle Falsa 123', '1199988877', 'ventas@empresab.com');

INSERT INTO Chofer (Nombre, DNI, Telefono, Licencia, FechaIngreso)
VALUES
('Juan Pérez', '30123456', '1144556677', 'L12345', '2020-05-10'),
('María Gómez', '29567890', '1188997766', 'L67890', '2021-03-22');


INSERT INTO Vehiculo (Patente, Tipo, Capacidad, Estado)
VALUES
('AB123CD', 'Camión', 5000, 'Activo'),
('EF456GH', 'Camioneta', 2000, 'Activo');


INSERT INTO Pedido (ClienteID, FechaPedido, Estado, TipoServicio)
VALUES
(1, '2025-10-10', 'Pendiente', 'Express'),
(2, '2025-10-12', 'Pendiente', 'Normal');



INSERT INTO Paquete (PedidoID, Peso, Dimensiones, Destino, Prioridad)
VALUES
(1, 15.5, '30x40x50', 'Rosario', 'Alta'),
(2, 5.0, '20x20x30', 'Córdoba', 'Media');


INSERT INTO Entrega (ChoferID, VehiculoID, PaqueteID, FechaSalida, EstadoEntrega)
VALUES
(1, 1, 1, '2025-10-13', 'En tránsito'),
(2, 2, 2, '2025-10-14', 'Pendiente');


INSERT INTO Ruta (Origen, Destino, DistanciaKM)
VALUES
('Buenos Aires', 'Rosario', 300),
('Buenos Aires', 'Córdoba', 700);



INSERT INTO Entrega_Ruta (EntregaID, RutaID, Orden)
VALUES
(1, 1, 1),
(2, 2, 1);







SELECT name FROM sys.tables;

SELECT * FROM Cliente;
SELECT * FROM Chofer;
SELECT * FROM Vehiculo;
SELECT * FROM Pedido;
SELECT * FROM Paquete;
SELECT * FROM Entrega;
SELECT * FROM Ruta;
SELECT * FROM Entrega_Ruta;





