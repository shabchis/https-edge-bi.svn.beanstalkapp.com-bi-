USE [EdgeDWH]
GO
/****** Object:  StoredProcedure [dbo].[ObjectManager_GetTableListAndQuery]    Script Date: 21/11/2012 17:27:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Amit Bluman
-- Create date: 21/11/2012
-- Description:	This SP will be called from SSIS, the SSIS should call with accountID.
--				The SP will return the set of tables and select query based on the CLR3 + index considering.
-- =============================================
ALTER PROCEDURE [dbo].[ObjectManager_GetTableListAndQuery]
	@SSISAccountID int
AS
BEGIN
	
	SET NOCOUNT ON;

-- Declare @SSISAccountID int;
Declare @SQL as nvarchar(max);

-- Set @SSISAccountID = 10035;

-- This will be replaced with the CLR1 called per accountID

Select	TableName + '| ' + 'Select ' + TableSelect + ' From [EdgeObjects].[dbo].' + TableFrom + ' Where ' +TableWhere as TableSelect
from [EdgeObjects].[dbo].[TableQuery]
-- Where accountID = @SSISAccountID -- need to decide whether the account is relevant to the structure

END
