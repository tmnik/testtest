USE [TestPoem]
GO
/****** Object:  StoredProcedure [his_data].[CopyStructure]    Script Date: 18.10.2020 21:46:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- процедура для формирвоания 
ALTER PROCEDURE [his_data].[CopyStructure]
										(
										@initialNameTable	nvarchar(255)
										,@str				nvarchar(4000) OUTPUT
										)
AS
BEGIN
	IF object_id('tempdb.dbo.#temporaryTable') IS NOT NULL DROP TABLE #temporaryTable

	SELECT 
		col.name AS column_name
		,typ.name AS type_name
		,CASE col.is_nullable 
			WHEN 1 THEN 'NULL'
			ELSE 'NOT NULL'
		END AS nullable
		,CASE typ.name  
			WHEN 'varchar' THEN '('+ CONVERT(nvarchar,syscol.prec) +')'
			WHEN 'nvarchar' THEN '('+ CONVERT(nvarchar,syscol.prec) +')'
			WHEN 'nchar' THEN '('+ CONVERT(nvarchar,syscol.prec) +')'
			WHEN 'char' THEN '('+ CONVERT(nvarchar,syscol.prec) +')'
			WHEN 'binary' THEN '('+ CONVERT(nvarchar,syscol.prec) +')'
			WHEN 'varbinary' THEN '('+ CONVERT(nvarchar,syscol.prec) +')'
			ELSE ''
		END AS size
	INTO #temporaryTable
	FROM sys.schemas sch
	JOIN sys.tables tbl ON
		sch.schema_id = tbl.schema_id
	JOIN sys.columns col ON
		tbl.object_id = col.object_id
	JOIN  sys.types typ ON
		typ.system_type_id = col.system_type_id
	JOIN sys.syscolumns syscol ON
		tbl.object_id = syscol.id AND syscol.name = col.name
	WHERE tbl.object_id = OBJECT_ID(@initialNameTable) AND typ.name <>'sysname'

	SELECT * FROM #temporaryTable

	--DECLARE @str nvarchar(4000) = ''
	SET @str = ''
	SELECT @str = @str  + column_name + ' ' + type_name 
		+ size + ' ' + nullable + ',' + nchar(10) 
	FROM #temporaryTable

	SET @str = (SELECT SUBSTRING(@str, 1, len(@str)-2))
	PRINT(@str)
END
