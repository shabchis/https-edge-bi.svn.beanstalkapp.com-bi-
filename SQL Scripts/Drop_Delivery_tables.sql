USE [Deliveries]
GO
/****** Object:  StoredProcedure [dbo].[Drop_Delivery_tables]    Script Date: 09/06/2014 16:22:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER procedure [dbo].[Drop_Delivery_tables]
 @AccountID int,
 @Month int
as
begin
-- This Sp will delete deliveries for specific files initial string OR specific month
-- If the accountID is null than it means per month deletion (all accounts),
-- If the accountID is not null than it delete per the initial string,
-- The month parameter should be YYYYMM.

-- SAMPLE OF DATES ONLY EXECUTION: EXEC [dbo].[Drop_Delivery_tables] NULL, 201404
-- SAMPLE OF ACCOUNT ONLY EXECUTION: EXEC [dbo].[Drop_Delivery_tables] AD_109, NULL


-- Parameters
DECLARE @Flag as nvarchar(100);
DECLARE @DELETE_PARAM AS NVARCHAR(100);

-- Create flags for each action

SET @Flag = CASE 
				WHEN @AccountID is NULL and @Month is NULL THEN 'ERROR: NO PARAMETERS SENT'
				WHEN @AccountID is NOT NULL and @Month is NOT NULL THEN 'ERROR: TOO MANY PARAMETERS'
				WHEN @AccountID is NULL and @Month is NOT NULL THEN 'DATES_ONLY'
				WHEN @AccountID is NOT NULL and @Month is NULL THEN 'ACCOUNT_ONLY'
			END

	SELECT @Flag
-- Error handling	
IF (@Flag = 'ERROR: NO PARAMETERS SENT' OR 
	@Flag = 'ERROR: TOO MANY PARAMETERS') 
	BEGIN 
		SELECT @Flag;
		RAISERROR (@Flag, 16, 1);
	END
 

IF (@Flag = 'DATES_ONLY') 
	BEGIN 
		
		SELECT 'DATES ONLY'
		EXEC  [dbo].[Drop_Delivery_tables_by_month] @Month
	END

IF (@Flag = 'ACCOUNT_ONLY') 
	BEGIN 
		SELECT 'ACCOUNT_ONLY'

		SET @DELETE_PARAM = 'AD_'+convert(nvarchar(10),@AccountID)
		EXEC  [dbo].[Drop_Delivery_tables_by_name] @DELETE_PARAM

		SET @DELETE_PARAM = 'GEN_'+convert(nvarchar(10),@AccountID)
		EXEC  [dbo].[Drop_Delivery_tables_by_name] @DELETE_PARAM

		SET @DELETE_PARAM = 'SEG_'+convert(nvarchar(10),@AccountID)
		EXEC  [dbo].[Drop_Delivery_tables_by_name] @DELETE_PARAM

		
	END

END -- OF SP



