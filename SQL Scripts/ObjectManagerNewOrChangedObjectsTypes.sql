USE [EdgeDWH]
GO
/****** Object:  StoredProcedure [dbo].[ObjectManager_NewOrChangedObjectsTypes]    Script Date: 19/11/2012 18:16:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[ObjectManager_NewOrChangedObjectsTypes]
@SPAccountID int
as
BEGIN

Declare @AddTypeDefFlag bit; 
Declare @ChangeTypeDefFlag bit; 
Declare @AlertTypeDefFlag bit; 
Declare @NewTableList as nvarchar(max);
Declare @ChangedTableList as nvarchar(max);
Declare @CurrentTable as nvarchar(1000);
Declare @CurrentTableForCLR as nvarchar(1000);
Declare @CurrentTableStructure as nvarchar(max);
Declare @SQL as nvarchar(max);

Set @AddTypeDefFlag = 'True';
Set @ChangeTypeDefFlag = 'False';
Set @AlertTypeDefFlag = 'True';

-- Drop table #Table;
-- Drop table #TableStructure;

Create table #Table (TableName nvarchar(50) NULL);
Create table #TableStructure (TableStructure nvarchar(100) NULL);
Insert into	 #Table exec [EdgeObjects].[dbo].[GetTablesNamesByAccountID] @accountID = @SPAccountID;

-- Add accountID to the table name
	Update #Table Set TableName = Convert(nvarchar(10),@SPAccountID) +'_'+TableName
	 
-- Find the missing tables in the DWH db based on CLR1 ([dbo].[GetTablesNamesByAccountID])
	Select @NewTableList = COALESCE(@NewTableList+'', '','''')+ISNULL(#Table.TableName+',','''')	
	From #Table
		left outer join [EdgeDWH].[sys].[Tables] as SysTables
			on  #Table.TableName = SysTables.Name COLLATE Hebrew_CI_AS 
				and SysTables.type = 'U'	
				and SysTables.type_desc = 'USER_TABLE' 
				-- and Isnumeric((substring(SysTables.name,0,charindex('_',SysTables.name,0)))) != 1 
				and SysTables.lob_data_space_id = 0
	Where SysTables.Name is NULL

-- Create missings tables in DWH based on CLR2 ([GetTableStructureByName]), will be added just when AddOrChangeTypeDefFlag is on
If (@AddTypeDefFlag = 1) 
	BEGIN
		While (Len(@NewTableList) > 0)
		BEGIN
			-- Find current table
				Set @CurrentTable = Substring(@NewTableList, 0, Charindex(',',@NewTableList,0))
				Set @CurrentTableForCLR = SubString(@CurrentTable,charIndex('_',@CurrentTable)+1,9999)
				
			-- Get cuurent table structure into #TableStructure
				Truncate table #TableStructure
				Set @CurrentTableStructure = NULL
				Insert into	#TableStructure EXEC [EdgeObjects].[dbo].[GetTableStructureByName_DisplayOnly] @virtualTableName = @CurrentTableForCLR
			--	Insert into	#TableStructure(TableStructure) values ('GK bigint'), ('Name nvarchar(50)'),('Budget decimal(18,2)')


				Select @CurrentTableStructure = COALESCE(@CurrentTableStructure+'', '','''')+ISNULL(TableStructure+' , ','''')	
				From #TableStructure
			-- Cut the last comma fromthe string
				Set @CurrentTableStructure = Left(@CurrentTableStructure, len(@CurrentTableStructure)-1)
	

			-- Create the SQL which will create the table
				If(@CurrentTableStructure is not null AND @CurrentTableStructure is not null)
				BEGIN
					Set @SQL =  'Create Table [EdgeDWH].[dbo].[' + @CurrentTable + '] '+
							'( '+@CurrentTableStructure+' )'
					Select @SQL
					Exec (@SQL) -- Keep the brackets !!!!!
				END
				-- Alert about the change
				If (@AlertTypeDefFlag = 1) 
					BEGIN
						Print 'Table '+ @CurrentTable +' was created '
					-- Send mail....
					END

				-- Delete current table from the string
				Set @NewTableList = Substring(@NewTableList, Charindex(',',@NewTableList,0)+1, 9999)
		END
	END 
-- Find existing but changed types based on CLR2 (all existing tables from CLR1 will be checked in this section)
If (@ChangeTypeDefFlag = 1) 
	BEGIN
		-- At this phase no auto changes are made to existing types
		Print 'At this phase no auto changes are made to existing types'
		If (@AlertTypeDefFlag = 1) 
				BEGIN
					Print 'There are changed types in the DB, look out ....'
				-- Send mail....
				END
	END

END

