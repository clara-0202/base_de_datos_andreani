--Listar productos cuyos lotes están por vencer dentro de X días. Ideal para el área de control de calidad o stock.
USE LogisticaTP;
GO

ALTER PROCEDURE dbo.sp_AlertaLotesVencidos
    @dias_aviso INT = 500
AS
BEGIN
    SELECT 
        p.nombre AS producto,
        l.id_lote,
        l.fecha_ingreso,
        l.fecha_vencimiento,
        l.cantidad_disponible,
        DATEDIFF(DAY, GETDATE(), l.fecha_vencimiento) AS dias_para_vencer,
        l.estado_lote
    FROM Lote l
    INNER JOIN Producto p ON p.id_producto = l.id_producto
    WHERE 
        DATEDIFF(DAY, GETDATE(), l.fecha_vencimiento) <= @dias_aviso
        AND l.estado_lote = 'VIGENTE'
    ORDER BY l.fecha_vencimiento ASC;
END;
GO