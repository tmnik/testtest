USE [TestPoem]
GO

DECLARE @RC int
DECLARE @initialNameTable nvarchar(255) = '[his_data].[ident_data]'
DECLARE @countRingBuffer nvarchar(255) ='0'
DECLARE @countTables nvarchar(255) ='4'

-- TODO: Set parameter values here.

EXECUTE @RC = [his_data].[CreateBuffer] 
   @initialNameTable 
  ,@countRingBuffer
  ,@countTables
GO
--IF (SELECT COUNT(1) FROM [his_data_Rb_1].[signal_data_2]) = 0 PRINT('YES')

--INSERT INTO [his_data_Rb_2].[signal_data_2]
--VALUES
--(1, 2, 'NULL', 'y','g') 


--TRUNCATE TABLE [[his_data_Rb_2].[signal_data_2]
--create SCHEMA [his_data_Rb_22]

--if not exists(select 
--	sch.name
--	,tbl.name
--FROM sys.schemas sch
--JOIN sys.tables tbl ON
--	sch.schema_id = tbl.schema_id
--WHERE sch.name = 'his_data_Rb_22') PRINT('YES')
