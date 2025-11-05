USE LogisticaTP;
GO

-- Verificar que existan cajas y lotes
SELECT TOP 5 * FROM Caja;
SELECT TOP 5 * FROM Lote;

-- Insertamos datos de prueba con cajas que contienen varios productos
-- ⚠️ Ajustá los IDs según los que tengas en tu base
INSERT INTO Caja_Detalle (id_caja, id_lote, cantidad_contenida)
VALUES
(1, 1, 50),  -- Paracetamol
(1, 2, 20),  -- Ibuprofeno
(1, 3, 30),  -- Amoxicilina (3 productos distintos en Caja 1)

(2, 4, 60),  -- Omeprazol
(2, 5, 40),  -- Enalapril (2 productos distintos en Caja 2)

(3, 6, 70),  -- Metformina (1 producto en Caja 3)
(4, 7, 15),
(4, 8, 25),
(4, 9, 10),  -- 3 productos distintos en Caja 4

(5, 10, 50); -- 1 producto en Caja 5



USE LogisticaTP;
GO

IF OBJECT_ID('dbo.vw_kpi3_consolidacion', 'V') IS NOT NULL
    DROP VIEW dbo.vw_kpi3_consolidacion;
GO

CREATE VIEW dbo.vw_kpi3_consolidacion
AS
SELECT
    ca.id_caja,
    COUNT(DISTINCT l.id_producto) AS productos_distintos,
    d.id_despacho,
    p.id_pedido,
    cli.id_cliente,
    cli.nombre AS cliente_nombre
FROM Caja ca
JOIN Caja_Detalle cd ON cd.id_caja = ca.id_caja
JOIN Lote l ON l.id_lote = cd.id_lote
JOIN Despacho_Caja dc ON dc.id_caja = ca.id_caja
JOIN Despacho d ON d.id_despacho = dc.id_despacho
JOIN Pedido p ON p.id_pedido = d.id_pedido
JOIN Cliente cli ON cli.id_cliente = p.id_cliente
GROUP BY ca.id_caja, d.id_despacho, p.id_pedido, cli.id_cliente, cli.nombre;
GO

SELECT TOP 20 * FROM vw_kpi3_consolidacion;



SELECT 
    COUNT(DISTINCT id_caja) AS cajas_enviadas,
    AVG(CAST(productos_distintos AS DECIMAL(10,2))) AS promedio_productos_por_caja
FROM dbo.vw_kpi3_consolidacion;


SELECT 
    cliente_nombre,
    COUNT(DISTINCT id_caja) AS cajas_enviadas,
    AVG(CAST(productos_distintos AS DECIMAL(10,2))) AS promedio_productos_por_caja
FROM dbo.vw_kpi3_consolidacion
GROUP BY cliente_nombre
ORDER BY promedio_productos_por_caja DESC;



SELECT 
    productos_distintos,
    COUNT(*) AS cantidad_cajas
FROM dbo.vw_kpi3_consolidacion
GROUP BY productos_distintos
ORDER BY productos_distintos;

GO
DELETE FROM Caja_Detalle;
GO

-- Ahora volvé a insertar las combinaciones variadas:
INSERT INTO Caja_Detalle (id_caja, id_lote, cantidad_contenida)
VALUES
(1, 1, 50),
(1, 2, 20),
(1, 3, 30),

(2, 4, 60),
(2, 5, 40),

(3, 6, 70),

(4, 7, 15),
(4, 8, 25),
(4, 9, 10),

(5, 10, 50);

DELETE FROM Caja_Detalle;
GO



SELECT * FROM Caja_Detalle;
GO

SELECT 
    COUNT(DISTINCT id_caja) AS cajas_enviadas,
    AVG(CAST(productos_distintos AS DECIMAL(10,2))) AS promedio_productos_por_caja
FROM dbo.vw_kpi3_consolidacion;

