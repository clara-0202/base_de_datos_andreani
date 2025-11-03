--KPI 1. Nivel de cumplimiento en entregas (On Time Delivery Rate)
USE LogisticaTP;

/* --query 1ra version moha
SELECT (SELECT COUNT(*) FROM Pedido) as Total_Pedidos, (SELECT COUNT(*) FROM Pedido WHERE id_estado = 5) as Pedidos_Entregados, COUNT(*) as Pedidos_Entregados_A_Tiempo,COUNT(*) / (SELECT COUNT(*) FROM Pedido WHERE id_estado = 5) * 100 As "% Entregados A Tiempo"
FROM Pedido p
INNER JOIN Despacho d
ON p.id_pedido = d.id_pedido
INNER JOIN Entrega e
ON e.id_despacho = d.id_despacho
WHERE e.fecha_entrega < d.fecha_llegada_estimada
AND p.id_estado = 5*/

GO
CREATE VIEW v_Nivel_Cumplimiento_Entregas AS
SELECT 
    (SELECT COUNT(*) FROM Pedido) AS Total_Pedidos,
    (SELECT COUNT(*) FROM Pedido WHERE id_estado = 5) AS Pedidos_Entregados,
    (SELECT COUNT(*) 
       FROM Pedido p
       INNER JOIN Despacho d ON p.id_pedido = d.id_pedido
       INNER JOIN Entrega e ON e.id_despacho = d.id_despacho
       WHERE e.fecha_entrega < d.fecha_llegada_estimada
         AND p.id_estado = 5) AS Pedidos_A_Tiempo,
    (SELECT (COUNT(*) * 100 / (SELECT COUNT(*) FROM Pedido WHERE id_estado = 5))
       FROM Pedido p
       INNER JOIN Despacho d ON p.id_pedido = d.id_pedido
       INNER JOIN Entrega e ON e.id_despacho = d.id_despacho
       WHERE e.fecha_entrega < d.fecha_llegada_estimada
         AND p.id_estado = 5) AS Porcentaje_Entregados_A_Tiempo