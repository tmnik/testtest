USE [TestPoem]
GO
/****** Object:  StoredProcedure [his_data].[CreateSchema]    Script Date: 18.10.2020 21:47:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- процедура для создания схем 
--CREATE
ALTER 
PROCEDURE [his_data].[CreateSchema]
										(
											@countRingBuffer	nvarchar(255)	= '1'
											,@countTables       nvarchar(255)   = '5'
										)
AS
BEGIN
	DECLARE @i			int				= 1
	DECLARE @j			int				
	DECLARE @cmd		nvarchar(4000) 
	DECLARE @b			nchar(1)		= nchar(10)

	IF object_id('tempdb.dbo.#tableCountSchema') IS NOT NULL DROP TABLE #tableCountSchema

	-- создаем таблицу со счетчиком уже существующих буферных колец
	SELECT
		SUBSTRING(s.name,CHARINDEX ( '_',s.name, 10 ) + 1,len(s.name)) AS count_schema
	INTO #tableCountSchema
	FROM sys.schemas s
	WHERE s.name LIKE 'his_data_Rb%'

	SELECT * FROM #tableCountSchema

	-- проверка на количество буферных колец 
	IF CONVERT(int,@countRingBuffer) < 1 SET @countRingBuffer = '1'

	--цикл для создания буферных колец
	WHILE  @i <= CONVERT(int,@countRingBuffer)	

	BEGIN
		-- если кольцо не сущесвует, создаем кольцо 
		IF  @i NOT IN (SELECT count_schema FROM #tableCountSchema)
		BEGIN
			SET @cmd = ''
			SET @cmd = @cmd + 'CREATE SCHEMA [his_data_Rb_' + CONVERT(nvarchar, @i) +']' + @b
		END

		SET @i = @i + 1
		PRINT(@cmd)
		EXEC (@cmd)

	END

	-- заведем счетчик для удаления колец, превышающих заданное количество 
	-- прежде чем удалить схему, нужно удалить таблицы, принадлежащие этой схеме
	DECLARE @i_drop	int	= CONVERT(int,@countRingBuffer)	+ 1

	IF CONVERT(int,(SELECT MAX(count_schema) FROM #tableCountSchema)) > CONVERT(int,@countRingBuffer)
	BEGIN

		WHILE @i_drop <= CONVERT(int,(SELECT MAX(count_schema) FROM #tableCountSchema))
		BEGIN
			SET @cmd = ''
			SET @j = 1
			IF @i_drop IN (SELECT count_schema FROM #tableCountSchema)
			BEGIN
				-- создаем таблицу со счетчиком уже существующих таблиц i-го буферного кольца, которое нужно удалить
				SELECT	
					SUBSTRING(tab.name,CHARINDEX ( '_',tab.name, 11) + 1,len(tab.name)) AS count_table
				INTO #tableCountTable
				FROM sys.schemas sch
				JOIN sys.tables tab ON
					tab.schema_id = sch.schema_id
				WHERE sch.name LIKE ('his_data_Rb_' + CONVERT(nvarchar(255),@i_drop))


				-- цикл для удаления таблиц, принадлежащих буферному кольцу, которое будем удалять 
				WHILE @j <= CONVERT(int,(SELECT ISNULL(MAX(count_table),0) FROM #tableCountTable))
					BEGIN
					IF (SELECT OBJECT_ID('[his_data_Rb_'+ CONVERT(nvarchar,@i_drop) +'].[signal_data_' + CONVERT(nvarchar,@j) +']')) IS NOT NULL
					BEGIN
						SET @cmd = @cmd + 'IF (SELECT COUNT(1) FROM [his_data_Rb_'+ CONVERT(nvarchar,@i) +'].[signal_data_' + CONVERT(nvarchar,@j) +']) = 0' + @b
								+ 'BEGIN' + @b
								+ 'DROP TABLE [his_data_Rb_'+ CONVERT(nvarchar,@i_drop) +'].[signal_data_' + CONVERT(nvarchar,@j) +']' + @b
								+ 'END' + @b
					END
					SET @j = @j + 1
				END

				SET @cmd = @cmd + 'IF NOT EXISTS(SELECT'+ @b
						+ 'sch.name' + @b
						+ ',tbl.name' + @b
						+ 'FROM sys.schemas sch' + @b
						+ 'JOIN sys.tables tbl ON' + @b
						+ 'sch.schema_id = tbl.schema_id' + @b
						+ 'WHERE sch.name = ''his_data_Rb_' + CONVERT(nvarchar(255),@i_drop)+ ''')' + @b
						+ 'BEGIN' + @b
						+ 'DROP SCHEMA [his_data_Rb_' + CONVERT(nvarchar, @i_drop) +']' + @b
						+ 'END' + @b
				PRINT(@cmd)
				EXEC (@cmd)

				IF object_id('tempdb.dbo.#tableCountTable') IS NOT NULL DROP TABLE #tableCountTable
			END
			SET @i_drop =  @i_drop + 1

		END
	END

END
