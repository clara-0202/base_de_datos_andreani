USE LogiTrack;
GO

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





