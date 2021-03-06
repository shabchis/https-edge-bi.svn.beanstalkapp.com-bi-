USE [EdgeDWH]

drop table #table

create table #table 
(TableName nvarchar(50) NULL)

Insert into #table exec [EdgeObjects].[dbo].[GetTablesNamesByAccountID] @accountID = NULL

-- Find the missing tables in the DWH db based on CLR1 ([dbo].[GetTablesNamesByAccountID])
Select #table.TableName 
From #table
	left outer join [edgedwh].[sys].[Tables] as SysTables
		on  #table.TableName = SysTables.Name COLLATE Hebrew_CI_AS 
			and SysTables.type = 'U'	
			and SysTables.type_desc = 'USER_TABLE' 
			and Isnumeric((substring(SysTables.name,0,charindex('_',SysTables.name,0)))) != 1 
			and SysTables.lob_data_space_id = 0
Where SysTables.Name is NULL

-- Create missings tables in DWH based on CLR2 ([GetTableStructureByName]), will be added just when AddOrChangeTypeDefFlag is on

-- Find existing but changed types based on CLR2 (all existing tables from CLR1 will be checked in this section)

-- Update type changing (will be changed just when AddOrChangeTypeDefFlag is on)

-- After definition sync (previous code), the data will be loaded to a specific table based on CLR3 ([GetDataByVirtualTableName])
-- This section can be performed by calling SSIS process with parameters








