-- Basic Structure of the database


GO 
CREATE PROC clearAllTables 
AS
EXEC sp_MSForEachTable 'DISABLE TRIGGER ALL ON ?'
EXEC sp_MSForEachTable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL'
EXEC sp_MSForEachTable 'SET QUOTED_IDENTIFIER ON; DELETE FROM ?'
EXEC sp_MSForEachTable 'ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL'
EXEC sp_MSForEachTable 'ENABLE TRIGGER ALL ON ?'

GO

-----todo, NOT YET

--CREATE PROC dropAllProceduresFumctionsViews
--AS
--	DROP PROCEDURE 
--GO
--DROP PROCEDURE clearAllTables
GO

CREATE PROC dropAllTables
AS
	DECLARE @sql NVARCHAR(MAX);
	SET @sql = N'';

	SELECT @sql = @sql + N'
	  ALTER TABLE ' + QUOTENAME(s.name) + N'.'
	  + QUOTENAME(t.name) + N' DROP CONSTRAINT '
	  + QUOTENAME(c.name) + ';'
	FROM sys.objects AS c
	INNER JOIN sys.tables AS t
	ON c.parent_object_id = t.[object_id]
	INNER JOIN sys.schemas AS s 
	ON t.[schema_id] = s.[schema_id]
	WHERE c.[type] IN ('D','C','F','PK','UQ')
	ORDER BY c.[type];

	EXEC sys.sp_executesql @sql;
	EXEC sp_msforeachtable 'DROP TABLE ?';
GO

