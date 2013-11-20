
  -- 1. Add "no tracker" hierarchy - add the ((-100)*@Account_ID+@Channel_ID) formula
  -- 2. update the no tracker data and no creative id
  -- 3. find the gateway_gk for each no tracker for ad <creative_id>
  -- 4. update the no tracker data where we have creative id

  USE [SEPERIA]
  GO

	Declare @AccountID int ;
	Declare @ChannelID int ;
	Declare @FromDate int ;
	Declare @EndDate int ;
	Declare @CampaignGK		nvarchar(500);
	Declare @AdgroupGK		nvarchar(500);
	Declare @creativeID		nvarchar(500); -- gateway_id
	Declare @CreativeGK		nvarchar(500); -- referenceID
	Declare @ReferenceType	int;
	Declare @destURL		nvarchar(4000);
	Declare @TrackerGK		nvarchar(500);

	SET @FromDate = 20131001 ;
	SET @EndDate = 20131002 ;
	SET @AccountID = 61 ;

	-- 1. add the ((-100)*@Account_ID+@Channel_ID) formula
	DECLARE index_cursor CURSOR FOR 
	
		SELECT  DISTINCT [ChannelID]
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

	-- 2. update the no tracker data and no creative id 
  UPDATE [dbo].[Paid_API_AllColumns_v29]
  SET	 GATEWAY_GK = ((-100)*Account_ID+Channel_ID),
		 GATEWAY = 'No Tracker Data',
		 DOWNLOADED_DATE = GETDATE()
  WHERE	account_id =  @AccountID
		AND day_code between  @FromDate and @EndDate
		AND	GATEWAY_ID IS NULL
		-- AND creativeid is null
  
  -- 3. find the gateway_gk for each no tracker for ad <creative_id>
  -- 4. update the no tracker data where we have creative id
			SET		@ChannelID		= NULL;
			
			DECLARE index_cursor CURSOR FOR 
					SELECT distinct [Channel_ID]
							,[Campaign_GK]
							,[Adgroup_GK]
							,[creativeID]
							,[Creative_GK]
					FROM [dbo].[Paid_API_AllColumns_v29] f
					WHERE gateway_id is null
						AND account_id = @AccountID
						AND day_code between @FromDate and @EndDate
			OPEN index_cursor


			FETCH NEXT FROM index_cursor 
			INTO  @ChannelID , @CampaignGK ,@AdgroupGK ,@creativeID , @CreativeGK 
			WHILE @@FETCH_STATUS = 0
			BEGIN
	 				
			execute @TrackerGK =  dbo.GkManager_GetGatewayGK_WithReturn			
					@Account_ID	 = @AccountID ,		
					@Channel_ID	 = @ChannelID ,		
					@Campaign_GK = @CampaignGK ,
					@AdGroup_GK	 = @AdgroupGK ,
					@Gateway_ID  = 'No Tracker For Ad ' + cast(@creativeID as nvarchar(50)) ,
					@Reference_ID = @CreativeGK 
				
				-- print ''GetTrackerGK '' + convert(nvarchar(400),CONVERT (time, GETDATE()))
				
				Update [dbo].[Paid_API_AllColumns_v29]
				SET	 GATEWAY_GK = ((-100)*Account_ID+Channel_ID),
					 GATEWAY = 'No Tracker For Ad ' + cast(@creativeID as nvarchar(50)),
					 DOWNLOADED_DATE = GETDATE() 
				WHERE	Account_ID = @AccountID and
						Channel_ID = @ChannelID and
						Campaign_GK = @CampaignGK and
						Adgroup_GK = @AdgroupGK and		
						GATEWAY_ID IS NULL and
						GATEWAY_GK IS NULL and
						IsNull(Creative_GK,0) = IsNull(@CreativeGK,0)
		 
		 
		 		-- Get the next index.
			FETCH NEXT FROM index_cursor 
				INTO @ChannelID , @CampaignGK ,@AdgroupGK ,@creativeID , @CreativeGK 
			END 

			CLOSE index_cursor

			DEALLOCATE index_cursor
					
/*
  SELECT adgroup, desturl, gateway_id, headline, desc1, desc2, creativeid, f.channel_id, f.ppc_creative_gk
		,CASE	-- WHEN creativeid is not null THEN 'No Tracker For Ad '+ cast(creativeid as nvarchar(50))
				WHEN creativeid is null THEN 'No Tracker Data'
		 END as gateway_id,
		 CASE	-- WHEN creativeid is not null THEN 'No Tracker For Ad '+ cast(creativeid as nvarchar(50))
				WHEN creativeid is null THEN  (-1 *account_id *100 - channel)
		 END as gateway_gk
  FROM [Seperia].[dbo].[Paid_API_AllColumns_v29] f
  WHERE account_id=61 
	AND gateway_id is null
	AND  day_code = 20131002 
 */