USE [EdgeDWH]

drop table #table

create table #table 
(TableName nvarchar(50) NULL)

Insert into #table exec [EdgeObjects].[dbo].[GetTablesNamesByAccountID] @accountID = NULL

-- Find the missing tables in the DWH db
Select #table.TableName From #table
left outer join [edgedwh].[sys].[Tables] as SysTables
	on  #table.TableName = SysTables.Name COLLATE Hebrew_CI_AS 
		and SysTables.type = 'U'	
		and SysTables.type_desc = 'USER_TABLE' 
		and Isnumeric((substring(SysTables.name,0,charindex('_',SysTables.name,0)))) != 1 
		and SysTables.lob_data_space_id = 0
Where SysTables.Name is NULL





