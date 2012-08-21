USE [Edge_System291]
GO
/****** Object:  StoredProcedure [dbo].[SP_RollBack_DWH]   ****
		Creator: Amit Bluman
		Created date:  08/21/2012 16:28:55
		Update date: --------
		Update description: ----------
**/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[SP_RollBack_DWH] as

-- This SP will find the "pending roll back" delivery outputs, delete it from the DWH db, and change it's status to rolledback.
-- The SP belongs to system db
Declare @DebugMode as bit;
Declare @OutputIDs as nvarchar(4000);
Declare @TableNames as nvarchar(4000);
Declare @CurrentTableName as nvarchar(4000);
Declare @CurrentOutputID as nvarchar(4000);
Declare @DWHDB as nvarchar(4000);
Declare @sql as nvarchar(4000);

--	Drop table #OutputAndTable;
--	Drop table #DistinctTables;
	
	set @DebugMode = 'False' ;
	set @DWHDB = 'EdgeDWH';
-- Find all the "pending roll back" statuses (7) in delivery output table. the data stored is table name and outputID

	select DO.OutputID as OutputID, DOP.Value as TableName
	into #OutputAndTable
	from [dbo].[DeliveryOutput] DO	
	  left outer join dbo.DeliveryOutputParameters DOP
		on DO.DeliveryID = DOP.DeliveryID and DO.OutputID = DOP.OutputID
	 where DO.Status = 7 and DOP.[Key] = 'CommitTableName';
	 
	Select distinct TableName
	into #DistinctTables
	from #OutputAndTable

 -- Populate the table names list		
	select @TableNames = COALESCE(@TableNames+'', '','''')+ ISNULL(TableName+',','''')
	from  #DistinctTables;
	
		If (@DebugMode = 'True') print '@TableNames: ' + @TableNames;
 
 -- For each table name - delete all the outputIDs in that table
while LEN(@TableNames) > 0 
	BEGIN 
-- get current table 
	set @CurrentTableName = SUBSTRING(@TableNames,0,CHARINDEX(',',@TableNames,0));
		If (@DebugMode = 'True') print 'CurrentTableName: '+ @currentTableName;

	
 -- Clear and populate the OutputID list which belongs to the current table name
	set @OutputIDs = ''''
	select @OutputIDs = COALESCE(@OutputIDs+'', '''', '''')+ISNULL(OutputID+''',''','')
	from  #OutputAndTable
	where TableName = @CurrentTableName;
	
		If (@DebugMode = 'True')  print 'OutputIDs: ' +@OutputIDs
		
-- Remove the last comma and apostrophe 
	set @OutputIDs = SUBSTRING(@OutputIDs,0,LEN(@OutputIDs)-1)
		If (@DebugMode = 'True')  print 'OutputIDs: ' +@OutputIDs

	set @sql = ''	
	set @sql = 'delete from ['+ @DWHDB + '].[dbo].['+ @CurrentTableName +'] where outputID in ('+ @OutputIDs +')';
		If (@DebugMode = 'True') print @sql
	print ' Delete outputIDs for table: ' + @CurrentTableName;
	 EXECUTE (@sql);

-- After deletion set the status to "Rolledback" in the delivery output table
	set @sql = ''
	set @sql = 'update [dbo].[DeliveryOutput] 
				set [Status] = 5 
				where outputID in ('+ @OutputIDs +')';
		If (@DebugMode = 'True') print @sql;
	
	EXECUTE (@sql)
	print ' Set rolledback status for outputIDs: ' +@OutputIDs

		print ' Delete outputIDs for table: ' + @CurrentTableName;	
-- Delete the current table name from @TableNames
	set @TableNames = SUBSTRING(@TableNames,CHARINDEX(',',@TableNames,0)+1,3999);
		If (@DebugMode = 'True') print @TableNames;
	
	END	-- While end