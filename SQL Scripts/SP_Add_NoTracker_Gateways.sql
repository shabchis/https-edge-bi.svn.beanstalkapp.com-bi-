USE seperia
GO
/****** Object:  StoredProcedure [dbo].[SP_Add_Default_Campaign_Adgroup]    Script Date: 08/10/2013 10:57:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Amit Bluman>
-- Create date: <8/10/2013>
-- Description:	<This SP will add No Tracker gateways to gateway, adgroup and campaign >
-- update date:
-- =============================================
alter PROCEDURE  [dbo].[SP_Add_NoTracker_Gateways] 

AS
BEGIN
	SET NOCOUNT ON;

DECLARE @Account_ID int ;
DECLARE @Channel_ID int ;
Declare @CampaignExists tinyint;
Declare @AdgroupExists tinyint ;
Declare @GatewayExists tinyint ;

-- Create accounts cursor
DECLARE account_cursor CURSOR FOR 
		SELECT  [Account_ID]
		FROM [dbo].[User_GUI_Account]
		where [Status] != 0 
OPEN account_cursor

FETCH NEXT FROM account_cursor 
INTO @Account_ID 

WHILE @@FETCH_STATUS = 0
BEGIN
		-- Create Channel cursor
		DECLARE channel_cursor CURSOR FOR 
		SELECT  [Channel_ID]
		FROM [dbo].[Constant_Channel]
		WHERE [Status] != 0
		OPEN channel_cursor

		FETCH NEXT FROM channel_cursor 
		INTO @Channel_ID 

		WHILE @@FETCH_STATUS = 0
		BEGIN
		
		-- print @Account_ID ;
		Set @CampaignExists = NULL;
		Set @AdgroupExists = NULL;
		Set @GatewayExists = NULL;

		-- Find if there is 'NoTracker' value in the tables
		select @CampaignExists = 1  from [dbo].[UserProcess_GUI_PaidCampaign] where account_id = @Account_ID and Channel_ID = @Channel_ID and  Campaign_Gk = ((-100)*@Account_ID+@Channel_ID);
		select @AdgroupExists = 1 from [dbo].[UserProcess_GUI_PaidAdGroup] where account_id = @Account_ID and Channel_ID = @Channel_ID and AdGroup_GK = ((-100)*@Account_ID+@Channel_ID);
		select @GatewayExists = 1 from [dbo].[UserProcess_GUI_Gateway] where account_id = @Account_ID  and Channel_ID = @Channel_ID and Gateway_id = 'No Tracker Data';

	/* -- Debug	
		print @account_id
		print @channel_id 
		print @CampaignExists
		print @AdgroupExists
		print @GatewayExists
	*/
		If (@CampaignExists is null) 		
			Begin
			SET IDENTITY_INSERT [dbo].[UserProcess_GUI_PaidCampaign] ON

				INSERT INTO [dbo].[UserProcess_GUI_PaidCampaign]
					   ([Campaign_GK]
					   ,[Account_ID]
					   ,[campaignid]
					   ,[campaign]
					   ,[campStatus]
					   ,[campaignStartdate]
					   ,[campaignenddate]
					   ,[Channel_ID]
					   ,[Campaign_Type_ID]
					   ,[Campaign_Type_Name]
					   ,[Segment1]
					   ,[Segment2]
					   ,[Segment3]
					   ,[Segment4]
					   ,[Segment5]
					   ,[LastUpdated]
					   ,[ScheduleEnabled])
				 VALUES
						(((-100)*@Account_ID+@Channel_ID),@Account_ID, NULL, 'No Tracker Data', 1, NULL, NULL, @Channel_ID, NULL, NULL, -1,-1,-1,-1,-1, getdate(), 0)
			
			SET IDENTITY_INSERT [dbo].[UserProcess_GUI_PaidCampaign] OFF
			End	 ;

		If (@AdgroupExists is null)
				
			Begin	         
			   SET IDENTITY_INSERT [dbo].[UserProcess_GUI_PaidAdGroup] ON
	
			   INSERT INTO [dbo].[UserProcess_GUI_PaidAdGroup]
					   ([Adgroup_GK]
						,[Account_ID]
						,[CampaignID]
						,[adgroupID]
						,[adgroup]
						,[agStatus]
						,[Channel_ID]
						,[Campaign_GK]
						,[Segment1]
						,[Segment2]
						,[Segment3]
						,[Segment4]
						,[Segment5]
						,[LastUpdated])
				 VALUES 
					( ((-100)*@Account_ID+@Channel_ID),@Account_ID, NULL, NULL, 'No Tracker Data', 1, @Channel_ID ,  ((-100)*@Account_ID+@Channel_ID) ,-1,-1,-1,-1,-1, getdate()  )
					 
				 SET IDENTITY_INSERT [dbo].[UserProcess_GUI_PaidAdGroup] OFF
			 End	 ;      
		
		 If (@GatewayExists is null)	
		Begin	         
			  SET IDENTITY_INSERT [dbo].[UserProcess_GUI_Gateway] ON
	
			  INSERT INTO [dbo].[UserProcess_GUI_Gateway]
					   ([Gateway_GK]
					  ,[Account_ID]
					  ,[Gateway_id]
					  ,[Gateway]
					  ,[Dest_URL]
					  ,[Adunit_ID]
					  ,[Adunit_Name]
					  ,[Strategic_Keyword_ID]
					  ,[Segment1]
					  ,[Segment2]
					  ,[Segment3]
					  ,[Segment4]
					  ,[Segment5]
					  ,[Campaign_GK]
					  ,[Page_GK]
					  ,[Reference_Type]
					  ,[Reference_ID]
					  ,[Adgroup_GK]
					  ,[Num_Of_Adgroups]
					  ,[Channel_ID]
					  ,[LastUpdated])
		VALUES
			 (((-100)*@Account_ID+@Channel_ID), @Account_ID, 'No Tracker Data' ,'No Tracker Data', NULL, NULL,NULL,NULL,  -1,-1,-1,-1,-1, ((-100)*@Account_ID+@Channel_ID), -1, NULL, NULL, ((-100)*@Account_ID+@Channel_ID), NULL, @Channel_ID, GETDATE())
		
			  SET IDENTITY_INSERT [dbo].[UserProcess_GUI_Gateway] OFF
		End;  

		-- Get the next Channel.
		FETCH NEXT FROM channel_cursor 
		INTO @Channel_ID 
		END 
		CLOSE channel_cursor
		DEALLOCATE channel_cursor

		-- Get the next accout.
		FETCH NEXT FROM account_cursor 
		INTO @Account_ID 
		END 
		CLOSE account_cursor
		DEALLOCATE account_cursor

END
