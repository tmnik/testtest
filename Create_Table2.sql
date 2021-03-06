USE [TestPoem]
GO
/****** Object:  StoredProcedure [his_data].[CreateTable_2]    Script Date: 18.10.2020 21:47:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- процедура для создания таблиц 
--CREATE
ALTER 
PROCEDURE [his_data].[CreateTable_2]
										(
											@initialNameTable	nvarchar(255)
											,@countRingBuffer	nvarchar(255)	= '1'
											,@countTables		nvarchar(255)   = '5'

										)
AS
BEGIN
	DECLARE @i int = 1		--счетчик буферных колец
	DECLARE @j int			--счетчик таблиц 

	DECLARE @b nchar(1) = nchar(10)
	
	--проверка на количество колец (минимум 1)
	IF CONVERT(int,@countRingBuffer) < 1 SET @countRingBuffer ='1'


	--проверка на количество таблиц (минимум 3, максимум 100)
	IF CONVERT(int,@countTables) < 3 SET @countTables = '3'
	IF CONVERT(int,@countTables) > 100  SET @countTables = '100'

	--цикл для прогона по буферным кольцам
	WHILE @i <= CONVERT(int,@countRingBuffer) 
	
	BEGIN
		SET @j = 1 --счетчик таблиц i-го буферного кольца

		-- создаем таблицу со счетчиком уже существующих таблиц i-го буферного кольца
		SELECT	
			SUBSTRING(tab.name,CHARINDEX ( '_',tab.name, 11) + 1,len(tab.name)) AS count_table
		INTO #tableCountTable
		FROM sys.schemas sch
		JOIN sys.tables tab ON
			tab.schema_id = sch.schema_id
		WHERE sch.name LIKE ('his_data_Rb_' + CONVERT(nvarchar(255),@i))

		SELECT * FROM #tableCountTable


		-- цикл для создания таблиц
		WHILE @j <= CONVERT(int,@countTables)
			
		BEGIN
			DECLARE @cmd nvarchar(4000) =''

			IF (SELECT OBJECT_ID('[his_data_Rb_'+ CONVERT(nvarchar,@i) +'].[signal_data_' + CONVERT(nvarchar,@j) +']')) IS NULL
			BEGIN
				SET @cmd = ''
				SET @cmd = @cmd + 'SELECT *' + @b 
							+ 'INTO [his_data_Rb_'+ CONVERT(nvarchar,@i) +'].[signal_data_' + CONVERT(nvarchar,@j) +']'+ @b 
							+ 'FROM' + @initialNameTable + @b 
							+ 'WHERE 0 = 1'+ @b 
				PRINT(@cmd)
				EXEC (@cmd)
			END

			SET @j = @j + 1 
		END

		declare @a int = (SELECT ISNULL(MAX(CONVERT(int,count_table)),0) FROM #tableCountTable)
		PRINT('@max = ' + CONVERT(nvarchar,@a))

		-- цикл для удаления таблиц, в случае, если существуют таблицы больше заданного количества таблиц
		WHILE @j <= (SELECT ISNULL(MAX(CONVERT(int,count_table)),0) FROM #tableCountTable)
		BEGIN
			--PRINT('WHILE DROP @j=' + CONVERT(varchar,@j) )

			IF (SELECT OBJECT_ID('[his_data_Rb_'+ CONVERT(nvarchar,@i) +'].[signal_data_' + CONVERT(nvarchar,@j) +']')) IS NOT NULL
			BEGIN
				--PRINT('IF DROP')
				SET @cmd = ''
				SET @cmd = @cmd + 
						--+'IF (SELECT COUNT(1) FROM [his_data_Rb_'+ CONVERT(nvarchar,@i) +'].[signal_data_' + CONVERT(nvarchar,@j) +']) = 0' + @b
						--+ 'BEGIN' + @b
						+ 'DROP TABLE [his_data_Rb_'+ CONVERT(nvarchar,@i) +'].[signal_data_' + CONVERT(nvarchar,@j) +']' + @b
						--+ 'END' + @b
				PRINT(@cmd)
				EXEC (@cmd)
			END
			SET @j = @j + 1 
		END

		IF object_id('tempdb.dbo.#tableCountTable') IS NOT NULL DROP TABLE #tableCountTable
		
		SET @i = @i + 1
	END

END
