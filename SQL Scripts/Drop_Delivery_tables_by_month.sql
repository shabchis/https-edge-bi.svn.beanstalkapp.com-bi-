USE [Deliveries]
GO
/****** Object:  StoredProcedure [dbo].[Drop_Delivery_tables_by_month]    Script Date: 09/06/2014 13:24:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Amit
-- Create date: 9/6/14
-- Description:	Delete Deliveries Tables by Month (YYYYMM), the parameter to pass in month too delete in YYYYMM format,
--				The deletion will be performed on tables and views.
-- =============================================
ALTER PROCEDURE [dbo].[Drop_Delivery_tables_by_month]
 
@MONTH NVARCHAR(100) --Date from delivery table name in Format YYYYMM

AS
BEGIN
	DECLARE @TABLENAME_TO_DELETE NVARCHAR(1000);
	DECLARE @VIEWNAME_TO_DELETE  NVARCHAR(1000);

	SET NOCOUNT ON;

	DECLARE index_cursor_table CURSOR FOR 
			
		SELECT 'DROP TABLE ' + [name] 
		FROM sysobjects
		WHERE	[type] in ('U') 
				AND [name] like '%_'+@MONTH+'%'	

	OPEN index_cursor_table

	FETCH NEXT FROM index_cursor_table 
	INTO @TABLENAME_TO_DELETE

	WHILE @@FETCH_STATUS = 0
		BEGIN
			-- Drop the table
			EXEC (@TABLENAME_TO_DELETE)	
			PRINT @TABLENAME_TO_DELETE	
					
		-- Get the next index
		FETCH NEXT FROM index_cursor_table 
		INTO @TABLENAME_TO_DELETE 

	END 
	CLOSE index_cursor_table
	DEALLOCATE index_cursor_table
	

	-- Cursor for views
	DECLARE index_cursor_view CURSOR FOR 
			
		SELECT 'DROP VIEW ' + [name] 
		FROM sysobjects
		WHERE	[type] in ('V') 
				AND [name] like '%_'+@MONTH+'%'	

	OPEN index_cursor_view

	FETCH NEXT FROM index_cursor_view 
	INTO @VIEWNAME_TO_DELETE

	WHILE @@FETCH_STATUS = 0
		BEGIN
			-- Drop the table
			EXEC (@VIEWNAME_TO_DELETE)	
			PRINT @VIEWNAME_TO_DELETE	
					
		-- Get the next index
		FETCH NEXT FROM index_cursor_view 
		INTO @VIEWNAME_TO_DELETE 

	END 
	CLOSE index_cursor_view
	DEALLOCATE index_cursor_view

	-- Debug
	-- EXEC [dbo].[Drop_Delivery_tables_by_month] 201401
END


