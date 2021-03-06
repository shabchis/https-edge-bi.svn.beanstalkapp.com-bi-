USE [Seperia]
GO
/****** Object:  StoredProcedure [dbo].[SP_No_Tracker_History]    Script Date: 20/11/2013 13:06:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Amit Bluman
-- Create date: 8 Nov 2013
-- Description:	
  -- 1. Add "no tracker" hierarchy - add the ((-100)*@Account_ID+@Channel_ID) formula
  -- 2. update the no tracker data and no creative id
  -- 3. find the gateway_gk for each no tracker for ad <creative_id> - not yet implemented
  -- 4. update the no tracker data where we have creative id - not yet implemented
-- =============================================
ALTER PROCEDURE [dbo].[SP_No_Tracker_History] (@AccountID int,@FromDate int , @EndDate int )
AS
BEGIN
	SET NOCOUNT ON;


	Declare @ChannelID int ;
	Declare @CampaignGK		nvarchar(500);
	Declare @AdgroupGK		nvarchar(500);
	Declare @creativeID		nvarchar(500); -- gateway_id
	Declare @CreativeGK		nvarchar(500); -- referenceID
	Declare @ReferenceType	int;
	Declare @destURL		nvarchar(4000);
	Declare @TrackerGK		nvarchar(500);

	/*
	-- Debug
	SET @FromDate = 20131001 ;
	SET @EndDate = 20131002 ;
	SET @AccountID = 61 ;
	*/

	-- 1. add the ((-100)*@Account_ID+@Channel_ID) formula
	DECLARE index_cursor CURSOR FOR 
	
		SELECT DISTINCT [Channel_ID]
		FROM [dbo].[Paid_API_AllColumns_v29] f
		WHERE gateway_id is null
			AND account_id = @AccountID
			AND day_code between @FromDate and @EndDate

	OPEN index_cursor

	FETCH NEXT FROM index_cursor 
	INTO @ChannelID

	WHILE @@FETCH_STATUS = 0
		BEGIN

			EXECUTE [Seperia].[dbo].[SP_Add_NoTracker_Gateways] @AccountID ,@ChannelID
					
		-- Get the next index.
		FETCH NEXT FROM index_cursor 
		INTO @ChannelID 

		END 
	CLOSE index_cursor
	DEALLOCATE index_cursor

	-- 2. update the no tracker data and no creative id in OLTP and DWH
  UPDATE [dbo].[Paid_API_AllColumns_v29]
  SET	 GATEWAY_GK = ((-100)*Account_ID+Channel_ID),
		 GATEWAY_ID = 'No Tracker Data',
		 GATEWAY = 'No Tracker Data'
  WHERE	account_id =  @AccountID
		AND day_code between  @FromDate and @EndDate
		AND	GATEWAY_ID IS NULL
		-- AND creativeid is null
 
 UPDATE dbo.Dwh_Fact_PPC_Campaigns
  SET	 GATEWAY_GK = ((-100)*Account_ID+Channel_ID),
		 Dwh_Update_Date = GETDATE()
  WHERE	account_id =  @AccountID
		AND day_code between  @FromDate and @EndDate
		AND Gateway_GK in 
			(select Gateway_GK
				from seperia_dwh.dbo.Dwh_Dim_Getways
				where account_id = @AccountID and (getway_id is null OR getway_id in ('0', '-1')))	
				
	/* Script to fix the partial download_date issue occur while QA
	
update [dbo].[Paid_API_AllColumns_v29]
set Downloaded_Date= 
		case when Downloaded_Date > (GETDATE()-3) then GETDATE()-6
		else Downloaded_Date
		end 
where Account_ID = 1239 

*/			
				
  	
  
END
