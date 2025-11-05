-- KPI 2
USE LogisticaTP;
GO

-- VISTA: Trazabilidad Completa

CREATE OR ALTER VIEW VW_Trazabilidad_Lote AS
WITH InfoLoteProducto AS (
    SELECT 
        L.id_lote,
        L.fecha_ingreso,
        L.fecha_vencimiento,
        L.cantidad_disponible,
        L.estado_lote,
        L.ubicacion,
        P.nombre AS producto,
        P.principio_activo,
        P.condicion_conservacion
    FROM Lote L
    INNER JOIN Producto P ON L.id_producto = P.id_producto
),
MovimientosLote AS (
    SELECT 
        PKD.id_lote,
        PK.fecha_hora AS picking_fecha,
        PKD.cantidad_extraida,
        PK.resultado_validacion,
        O.nombre AS operario,
        PED.id_pedido,
        PED.fecha_pedido,
        C.nombre AS cliente,
        C.tipo_cliente,
        C.direccion,
        C.contacto,
        CJ.codigo_qr,
        E.fecha_entrega,
        E.temperatura_registrada,
        E.conformidad
    FROM Picking_Detalle PKD
    INNER JOIN Picking PK ON PKD.id_picking = PK.id_picking
    INNER JOIN Detalle_Pedido DP ON PK.id_detalle_pedido = DP.id_detalle_pedido
    INNER JOIN Pedido PED ON DP.id_pedido = PED.id_pedido
    INNER JOIN Cliente C ON PED.id_cliente = C.id_cliente
    INNER JOIN Operario O ON PK.id_operario = O.id_operario
    LEFT JOIN Caja_Detalle CJD ON PKD.id_lote = CJD.id_lote
    LEFT JOIN Caja CJ ON CJD.id_caja = CJ.id_caja
    LEFT JOIN Despacho_Caja DC ON CJ.id_caja = DC.id_caja
    LEFT JOIN Despacho D ON DC.id_despacho = D.id_despacho AND PED.id_pedido = D.id_pedido
    LEFT JOIN Entrega E ON D.id_despacho = E.id_despacho
)
SELECT 
    ILP.*,
    ML.picking_fecha,
    ML.cantidad_extraida,
    ML.resultado_validacion,
    ML.operario,
    ML.id_pedido,
    ML.fecha_pedido,
    ML.cliente,
    ML.tipo_cliente,
    ML.direccion,
    ML.contacto,
    ML.codigo_qr,
    ML.fecha_entrega,
    ML.temperatura_registrada,
    ML.conformidad,
    DATEDIFF(DAY, ILP.fecha_ingreso, ML.fecha_entrega) AS dias_transito
FROM InfoLoteProducto ILP
LEFT JOIN MovimientosLote ML ON ILP.id_lote = ML.id_lote;
GO

-- PROCEDIMIENTO: Recall de Lote (Retiro del Mercado)

CREATE OR ALTER PROCEDURE SP_Recall_Lote
    @id_lote INT
AS
BEGIN
    SET NOCOUNT ON;
    
    WITH ClientesAfectados AS (
        SELECT DISTINCT
            C.nombre AS Cliente,
            C.tipo_cliente AS Tipo,
            C.direccion AS Direccion,
            C.contacto AS Contacto,
            C.cuit AS CUIT,
            PKD.cantidad_extraida AS Cantidad_Recibida,
            E.fecha_entrega AS Fecha_Entrega,
            CJ.codigo_qr AS Codigo_Rastreo
        FROM Lote L
        INNER JOIN Picking_Detalle PKD ON L.id_lote = PKD.id_lote
        INNER JOIN Picking PK ON PKD.id_picking = PK.id_picking
        INNER JOIN Detalle_Pedido DP ON PK.id_detalle_pedido = DP.id_detalle_pedido
        INNER JOIN Pedido PED ON DP.id_pedido = PED.id_pedido
        INNER JOIN Cliente C ON PED.id_cliente = C.id_cliente
        LEFT JOIN Caja_Detalle CJD ON L.id_lote = CJD.id_lote
        LEFT JOIN Caja CJ ON CJD.id_caja = CJ.id_caja
        LEFT JOIN Despacho_Caja DC ON CJ.id_caja = DC.id_caja
        LEFT JOIN Despacho D ON DC.id_despacho = D.id_despacho
        LEFT JOIN Entrega E ON D.id_despacho = E.id_despacho
        WHERE L.id_lote = @id_lote
    )
    SELECT * FROM ClientesAfectados ORDER BY Fecha_Entrega DESC;
    
    SELECT 
        COUNT(DISTINCT cliente) AS Total_Clientes_Afectados,
        SUM(Cantidad_Recibida) AS Total_Unidades_Distribuidas
    FROM ClientesAfectados;
END;
GO

-- VISTA: Control FEFO - Lotes Próximos a Vencer

CREATE OR ALTER VIEW VW_Lotes_Proximos_Vencer AS
SELECT 
    L.id_lote,
    P.nombre AS producto,
    L.fecha_vencimiento,
    L.cantidad_disponible,
    L.ubicacion,
    DATEDIFF(DAY, GETDATE(), L.fecha_vencimiento) AS dias_para_vencer,
    CASE 
        WHEN DATEDIFF(DAY, GETDATE(), L.fecha_vencimiento) < 0 THEN 'VENCIDO'
        WHEN DATEDIFF(DAY, GETDATE(), L.fecha_vencimiento) <= 30 THEN 'CRITICO'
        WHEN DATEDIFF(DAY, GETDATE(), L.fecha_vencimiento) <= 60 THEN 'ALERTA'
        ELSE 'NORMAL'
    END AS prioridad
FROM Lote L
INNER JOIN Producto P ON L.id_producto = P.id_producto
WHERE L.cantidad_disponible > 0;
GO

-- ANÁLISIS POR DIMENSIONES

-- Resumen por Lote
WITH ResumenLote AS (
    SELECT 
        id_lote,
        producto,
        estado_lote,
        COUNT(DISTINCT id_pedido) AS pedidos,
        COUNT(DISTINCT cliente) AS clientes,
        SUM(cantidad_extraida) AS total_despachado
    FROM VW_Trazabilidad_Lote
    WHERE id_pedido IS NOT NULL
    GROUP BY id_lote, producto, estado_lote
)
SELECT * FROM ResumenLote ORDER BY id_lote;

GO


-- Ver trazabilidad del Lote 1
SELECT * FROM VW_Trazabilidad_Lote WHERE id_lote = 1;

-- Simular recall del Lote 5
EXEC SP_Recall_Lote @id_lote = 5;

-- Lotes con alerta de vencimiento
SELECT * FROM VW_Lotes_Proximos_Vencer WHERE prioridad IN ('CRITICO', 'ALERTA');

GO

