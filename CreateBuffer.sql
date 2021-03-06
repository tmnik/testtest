USE [TestPoem]
GO
/****** Object:  StoredProcedure [his_data].[CreateBuffer]    Script Date: 18.10.2020 21:46:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- процедура для создания схем 
--CREATE
ALTER 
PROCEDURE [his_data].[CreateBuffer]
										(
											  @initialNameTable	nvarchar(255)
											, @countRingBuffer	nvarchar(255)	= '1'
											, @countTables		nvarchar(255)   = '5'
										)
AS
BEGIN	
	DECLARE @i		int				= 1
	DECLARE @str	nvarchar(4000)
	DECLARE @cmd	nvarchar(4000) 
	DECLARE @b		nchar(1)		= nchar(10)


	--копируем структуру таблицы 
	EXEC [his_data].[CopyStructure] @initialNameTable
							,@str output

	-- создаем схему, если ее не существует 
	EXEC [his_data].[CreateSchema]  @countRingBuffer
								,@countTables

	---- создаем таблицу, если ее не существует 
	--EXEC [his_data].[CreateTable] @str
	--							,@countRingBuffer
	--							,@countTables

	-- создаем таблицу, если ее не существует 
	EXEC [his_data].[CreateTable_2] @initialNameTable
								,@countRingBuffer
								,@countTables
END
