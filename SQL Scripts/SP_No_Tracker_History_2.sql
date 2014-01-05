USE [Seperia]
GO
/****** Object:  StoredProcedure [dbo].[SP_No_Tracker_History_2]    Script Date: 01/05/2014 10:55:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Amit Bluman
-- Create date: 29 Dec 2013
-- Description:	
  -- 1. Add "no tracker" hierarchy - add the ((-100)*@Account_ID+@Channel_ID) formula
  -- 2. Update no tracker data with adID as tracker to OLTP and DWH
  -- 3. Update no tracker data without adID to OLTP and DWH
-- =============================================
ALTER PROCEDURE [dbo].[SP_No_Tracker_History_2] (@AccountID int,@FromDate int , @EndDate int )
AS
BEGIN
	SET NOCOUNT ON;
	
DECLARE @ChannelID int;
DECLARE @CampaignGK nvarchar(500);
DECLARE @AdgroupGK nvarchar(500);
DECLARE @CreativeGK nvarchar(500); -- referenceID
DECLARE @creativeDestURL nvarchar(4000);
DECLARE @CreativeID as nvarchar(255);
DECLARE @TrackerGK as nvarchar(500);

	/*
	-- Debug
	DECLARE @FromDate int,  @EndDate int , @AccountID int;
	SET @FromDate = 20121204 ;
	SET @EndDate = 20121204;
	SET @AccountID = 7 ;
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

	-- 2. Update no tracker data with adID as tracker to OLTP and DWH
	-- I will use CASE in the main update

	
-- First populate the creativeID in OLTP and DWH dim tables

-- Update creative table with the creative ids OLTP
UPDATE  [Seperia].[dbo].[UserProcess_GUI_PaidAdgroupCreative]
SET creativeid = FACT.creativeid 
FROM [Seperia].[dbo].[Paid_API_AllColumns_v29] FACT
WHERE FACT.account_id =  [Seperia].[dbo].[UserProcess_GUI_PaidAdgroupCreative].account_id and
	  FACT.ppc_creative_gk =  [Seperia].[dbo].[UserProcess_GUI_PaidAdgroupCreative].ppc_creative_gk and
	  FACT.account_id = @AccountID and
	  day_code between @FromDate and @EndDate and 
	   [Seperia].[dbo].[UserProcess_GUI_PaidAdgroupCreative].creativeid is null


-- Update creative table with the creative ids DWH
UPDATE  [Seperia_dwh].[dbo].[Dwh_Dim_PPC_Creatives]
SET		[Paid_Creative_ID] = CR.creativeid
FROM [Seperia].[dbo].[UserProcess_GUI_PaidAdgroupCreative] CR
WHERE 
	 CR.ppc_creative_gk = [Seperia_dwh].[dbo].[Dwh_Dim_PPC_Creatives].[Paid_Creative_GK] and
	 CR.account_id = @AccountID and 
	 [Seperia_dwh].[dbo].[Dwh_Dim_PPC_Creatives].[Paid_Creative_ID] is null

-- Create a temp table with all the no tracker data
SELECT distinct FACT.[Account_ID] ,FACT.[Channel_ID], FACT.[Campaign_GK], FACT.[Ad_group_GK], 
		FACT.[Creative_GK], CR.[creativeDestURL] , 
		CASE WHEN CR.[CreativeID] = NULL THEN 'No Tracker Data' ELSE 'No Tracker For Ad ' + CR.[CreativeID] END as [CreativeID],
		CASE WHEN CR.[CreativeID] = NULL THEN ((-100)*FACT.[Account_ID] +FACT.[Channel_ID]) ELSE NULL END as Tracker_GK
INTO #tmp_adids
FROM seperia_dwh.dbo.Dwh_Fact_PPC_Campaigns FACT
	INNER JOIN  [Seperia].[dbo].[UserProcess_GUI_PaidAdgroupCreative] CR
			ON	FACT.account_id = CR.account_id  and 
				FACT.paid_creative_gk = CR.[Ppc_Creative_GK] 
WHERE	FACT.account_id =  @AccountID
		AND FACT.day_id between @FromDate and @EndDate
		AND (FACT.Gateway_GK in 
			(select Gateway_GK
				from seperia_dwh.dbo.Dwh_Dim_Getways
				where account_id = @AccountID 
				and (getway_id is null OR getway_id in ('0', '-1'))   )
			OR 
			FACT.Gateway_gk in (0,-1, NULL) 
			OR  
			FACT.Gateway_gk is NULL )

-- update all the tracker with creative id	(from the temp table)
-- the cursor filters all the records with creative id  (the tracker is null)
	DECLARE index_cursor CURSOR FOR 
					SELECT  [Account_ID]
							,[Channel_ID]
							,[Campaign_GK]
							,[Ad_group_GK]
							,[Creative_GK]
							,[creativeDestURL]
							,[CreativeID]
					FROM #tmp_adids
					WHERE Tracker_GK is null 
			OPEN index_cursor


			FETCH NEXT FROM index_cursor 
			INTO @AccountID , @ChannelID , @CampaignGK ,@AdgroupGK , @CreativeGK ,@creativeDestURL ,@CreativeID
			WHILE @@FETCH_STATUS = 0
			BEGIN
	 				
			execute @TrackerGK =  seperia.dbo.GkManager_GetGatewayGK_WithReturn			
					@Account_ID	 = @AccountID ,		
					@Channel_ID	 = @ChannelID ,		
					@Campaign_GK = @CampaignGK ,
					@AdGroup_GK	 = @AdgroupGK ,
					@Gateway_ID  = @CreativeID , --creative_id id the tracker id when no tracker is found
					@Reference_ID = @CreativeGK , 	
					@Reference_Type = 0 , --creative
					@Dest_URL	= @creativeDestURL

		print @trackerGK

-- Update the new tracker found in the DWH fact table
		UPDATE #tmp_adids		
		SET Tracker_GK = @TrackerGK
		WHERE	[Account_ID] =  @AccountID
				AND [Channel_ID]	 = @ChannelID 
				AND [Campaign_GK] = @CampaignGK 
				AND [Ad_group_GK]	 = @AdgroupGK 
				AND [Creative_GK] = @CreativeGK
				AND [creativeDestURL] = @creativeDestURL
				AND [CreativeID] = @CreativeID
							

		FETCH NEXT FROM index_cursor 
			INTO @AccountID , @ChannelID , @CampaignGK ,@AdgroupGK , @CreativeGK ,@creativeDestURL ,@CreativeID
		END 

		CLOSE index_cursor

		DEALLOCATE index_cursor

		-- Update the trackers from the temp table to fact table
		
	 UPDATE seperia_dwh.dbo.Dwh_Fact_PPC_Campaigns
	  SET	 GATEWAY_GK = Tracker_GK,
			 Dwh_Update_Date = GETDATE()
	  FROM #tmp_adids tmp
	  WHERE	tmp.account_id =  seperia_dwh.dbo.Dwh_Fact_PPC_Campaigns.Account_ID
			AND tmp.Channel_ID	 = seperia_dwh.dbo.Dwh_Fact_PPC_Campaigns.Channel_ID 
			AND seperia_dwh.dbo.Dwh_Fact_PPC_Campaigns.day_id  between @FromDate and @EndDate
			AND tmp.Campaign_GK = seperia_dwh.dbo.Dwh_Fact_PPC_Campaigns.Campaign_GK 
			AND tmp.Ad_Group_GK	 = seperia_dwh.dbo.Dwh_Fact_PPC_Campaigns.Ad_group_GK 
			AND tmp.Creative_GK = seperia_dwh.dbo.Dwh_Fact_PPC_Campaigns.Creative_GK 


	/* Script to fix the partial download_date issue occur while QA
	
update [dbo].[Paid_API_AllColumns_v29]
set Downloaded_Date= 
		case when Downloaded_Date > (GETDATE()-3) then GETDATE()-6
		else Downloaded_Date
		end 
where Account_ID = 1239 

-- select * from #tmp_adids
-- drop table #tmp_adids
*/			
				
  	
  
END

