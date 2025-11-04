--CTE 1: Peso total transportado por despacho
WITH PesoPorDespacho AS (
    SELECT 
        d.id_despacho,
        v.id_vehiculo,
        v.tipo_vehiculo,
        v.capacidad,
        SUM(c.peso_total) AS peso_transportado
    FROM Despacho d
    JOIN Vehiculo v ON v.id_vehiculo = d.id_vehiculo
    JOIN Despacho_Caja dc ON dc.id_despacho = d.id_despacho
    JOIN Caja c ON c.id_caja = dc.id_caja
    GROUP BY d.id_despacho, v.id_vehiculo, v.tipo_vehiculo, v.capacidad
),

--CTE 2: Agregar información de zona de entrega
DespachoConZona AS (
    SELECT 
        pd.id_despacho,
        pd.id_vehiculo,
        pd.tipo_vehiculo,
        pd.capacidad,
        pd.peso_transportado,
        CASE
            WHEN cl.direccion LIKE '%CABA%' THEN 'CABA'
            WHEN cl.direccion LIKE '%La Plata%' THEN 'La Plata'
            WHEN cl.direccion LIKE '%Quilmes%' THEN 'Quilmes'
            WHEN cl.direccion LIKE '%Lanús%' THEN 'Lanús'
            WHEN cl.direccion LIKE '%Morón%' THEN 'Morón'
            WHEN cl.direccion LIKE '%Pilar%' THEN 'Pilar'
            ELSE 'Otras zonas'
        END AS zona
    FROM PesoPorDespacho pd
    JOIN Entrega e ON e.id_despacho = pd.id_despacho
    JOIN Cliente cl ON cl.id_cliente = e.id_cliente
)

--CTE 3: Calcular ocupación individual y promediar por tipo y zona
SELECT 
    zona,
    tipo_vehiculo,
    ROUND(AVG((CAST(peso_transportado AS FLOAT) / capacidad) * 100), 2) AS promedio_ocupacion_pct
FROM DespachoConZona
GROUP BY zona, tipo_vehiculo
ORDER BY zona, tipo_vehiculo;