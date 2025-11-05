-- parametos de período
DECLARE @desde DATETIME = '2025-10-20',
        @hasta DATETIME = '2025-10-27';

;WITH
-- incidencias con error de lote
cte_incidencias_lote AS (
    SELECT DISTINCT
        i.id_picking,
        CONVERT(date, i.fecha_hora) AS dia
    FROM dbo.Incidencia AS i
    WHERE i.id_picking IS NOT NULL
      AND i.fecha_hora >= @desde AND i.fecha_hora < @hasta
      AND (
            i.tipo_incidencia LIKE '%Error%'
         OR i.descripcion LIKE '%lote%'
         OR i.descripcion LIKE '%vencim%'
         OR i.descripcion LIKE '%traza%'
         OR i.descripcion LIKE '%validaci%'
      )
),
-- pickings en ERROR con lotes no vigentes
cte_picking_lote_error AS (
    SELECT DISTINCT
        p.id_picking,
        CONVERT(date, p.fecha_hora) AS dia
    FROM dbo.Picking AS p
    JOIN dbo.Picking_Detalle AS pd ON pd.id_picking = p.id_picking
    JOIN dbo.Lote AS l ON l.id_lote = pd.id_lote
    WHERE p.fecha_hora >= @desde AND p.fecha_hora < @hasta
      AND p.resultado_validacion = 'ERROR'
      AND l.estado_lote IN ('VENCIDO','CUARENTENA')
),
-- Unión de señales
cte_pickings_error_lote AS (
    SELECT id_picking, dia FROM cte_incidencias_lote
    UNION
    SELECT id_picking, dia FROM cte_picking_lote_error
),
-- mapear a pedidos (unidad del KPI)
cte_pedidos_error AS (
    SELECT DISTINCT
        CONVERT(date, pel.dia) AS dia,
        dp.id_pedido
    FROM cte_pickings_error_lote AS pel
    JOIN dbo.Picking AS p  ON p.id_picking = pel.id_picking
    JOIN dbo.Detalle_Pedido AS dp ON dp.id_detalle_pedido = p.id_detalle_pedido
),
-- pedidos validados (denominador)
cte_pedidos_validados AS (
    SELECT DISTINCT
        CONVERT(date, p.fecha_hora) AS dia,
        dp.id_pedido
    FROM dbo.Picking AS p
    JOIN dbo.Detalle_Pedido AS dp ON dp.id_detalle_pedido = p.id_detalle_pedido
    WHERE p.fecha_hora >= @desde AND p.fecha_hora < @hasta
),
-- Agregación final
cte_final AS (
    SELECT
        d.dia,
        COUNT(DISTINCT n.id_pedido) AS pedidos_con_error_lote,
        COUNT(DISTINCT d.id_pedido) AS pedidos_validados,
        CAST(100.0 * COUNT(DISTINCT n.id_pedido) / NULLIF(COUNT(DISTINCT d.id_pedido),0) AS DECIMAL(5,2)) AS tasa_error_lote_pct
    FROM cte_pedidos_validados AS d
    LEFT JOIN cte_pedidos_error AS n
      ON n.dia = d.dia AND n.id_pedido = d.id_pedido
    GROUP BY d.dia
)
SELECT *
FROM cte_final
ORDER BY dia;