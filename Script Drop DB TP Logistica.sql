USE master;
GO

-- 2. Forzar el cierre de todas las conexiones
ALTER DATABASE LogisticaTP SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

-- 3. Ahora sí, eliminar la base
DROP DATABASE LogisticaTP;
GO
