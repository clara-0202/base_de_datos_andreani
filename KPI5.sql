SELECT TOP (1) * FROM dbo.Incidencia;          -- ¿existe y tiene datos?
SELECT TOP (1) i.id_incidencia FROM dbo.Incidencia AS i;  -- ¿reconoce el alias i?