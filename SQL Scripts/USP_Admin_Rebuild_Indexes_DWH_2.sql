USE [Seperia_DWH]
GO
/****** Object:  StoredProcedure [dbo].[USP_Admin_Rebuild_Indexes_DWH_2]    Script Date: 10/02/2014 15:47:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER proc [dbo].[USP_Admin_Rebuild_Indexes_DWH_2]
As
DECLARE @TableName nvarchar(500),
@TableIndexName nvarchar(500),
@SQL nvarchar(4000)

DECLARE index_cursor CURSOR FOR 

	SELECT OBJECT_NAME(object_id) AS TableName, Name AS TableIndexName
	FROM  sys.indexes
	WHERE name is not null 
		AND OBJECT_NAME(object_id) is not null 
		AND OBJECT_NAME(object_id) in ( SELECT table_name 
										FROM Seperia_Admin.dbo.Tables_to_be_indexed
										WHERE DB_name = 'Seperia_DWH') 

OPEN index_cursor

FETCH NEXT FROM index_cursor 
INTO @TableName, @TableIndexName
 
WHILE @@FETCH_STATUS = 0
	BEGIN 
        set @SQL= 'ALTER INDEX ' + @TableIndexName + ' ON ' + @TableName + ' REBUILD WITH (FILLFACTOR = 80, SORT_IN_TEMPDB = ON,' 
				+ ' STATISTICS_NORECOMPUTE = ON);'		 

	PRINT @SQL

    EXEC sp_executesql @SQL

	-- Get the next index.
	FETCH NEXT FROM index_cursor 
	INTO @TableName, @TableIndexName

END 

CLOSE index_cursor
DEALLOCATE index_cursor


