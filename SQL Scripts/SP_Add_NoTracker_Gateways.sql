USE [Seperia]
GO
/****** Object:  StoredProcedure [dbo].[SP_Add_NoTracker_Gateways]    Script Date: 24/02/2014 15:09:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Amit Bluman>
-- Create date: <8/10/2013>
-- Description:	This SP will add No Tracker gateways to gateway, adgroup and campaign 
-- update date: 21/10/2013
-- Description: remove all the cursors and get the account_id and channel_id from the calling SP.
-- =============================================
ALTER PROCEDURE   [dbo].[SP_Add_NoTracker_Gateways] ( @SPAccountID int ,@SPChannelID int )

AS
BEGIN
	SET NOCOUNT ON;

DECLARE @Account_ID int ;
DECLARE @Channel_ID int ;
Declare @CampaignExists tinyint;
Declare @AdgroupExists tinyint ;
Declare @GatewayExists tinyint ;
Declare @KeywordExists tinyint ;

		
		-- print @Account_ID ;
		set @Account_ID = @SPAccountID;
		set @Channel_ID = @SPChannelID ;
		Set @CampaignExists = NULL;
		Set @AdgroupExists = NULL;
		Set @GatewayExists = NULL;
		Set @KeywordExists = NULL;

		-- Find if there is 'NoTracker' value in the tables
		select @CampaignExists = 1  from [dbo].[UserProcess_GUI_PaidCampaign] WITH (NOLOCK) where account_id = @Account_ID and Channel_ID = @Channel_ID and  Campaign_Gk = ((-100)*@Account_ID+@Channel_ID);
		select @AdgroupExists = 1 from [dbo].[UserProcess_GUI_PaidAdGroup] WITH (NOLOCK) where account_id = @Account_ID and Channel_ID = @Channel_ID and AdGroup_GK = ((-100)*@Account_ID+@Channel_ID);
		select @GatewayExists = 1 from [dbo].[UserProcess_GUI_Gateway] WITH (NOLOCK) where account_id = @Account_ID  and Channel_ID = @Channel_ID and Gateway_id = 'No Tracker Data';
		select @KeywordExists = 1 from [dbo].[UserProcess_GUI_PaidAdgroupKeyword] WITH (NOLOCK) where account_id = @Account_ID  and Channel_ID = @Channel_ID and PPC_Keyword_gk = ((-100)*@Account_ID+@Channel_ID);


		-- select  @Account_ID ,@Channel_ID, @GatewayExists as GatewayExists
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

		If (@KeywordExists is null)
				
			Begin	         
			   SET IDENTITY_INSERT [dbo].[UserProcess_GUI_PaidAdGroupKeyword] ON
			  
				INSERT INTO [dbo].[UserProcess_GUI_PaidAdgroupKeyword]
						   ([PPC_Keyword_GK]
						   ,[Account_ID]
						   ,[kwSite]
						   ,[Channel_ID]
						   ,[Keyword_GK]
						   ,[Gateway_GK]
						   ,[AdGroup_GK]
						   ,[Campaign_GK]
						   ,[LastUpdated]
						   ,[MatchType])
				 VALUES 
					(((-100)*@Account_ID+@Channel_ID), @Account_ID, 'No Keyword Data', @Channel_ID, ((-100)*@Account_ID+@Channel_ID), ((-100)*@Account_ID+@Channel_ID), ((-100)*@Account_ID+@Channel_ID), ((-100)*@Account_ID+@Channel_ID),GETDATE(), 0   )
					 
				SET IDENTITY_INSERT [dbo].[UserProcess_GUI_PaidAdgroupKeyword] OFF

				SET IDENTITY_INSERT [dbo].[UserProcess_GUI_Keyword] ON
				-- Keyword is not channel related, so there is no channel in the keyword_gk calculation
				INSERT INTO [dbo].[UserProcess_GUI_Keyword]
							([Keyword_GK]
							,[Account_ID]
							,[Keyword]
							,[Profile_ID]
							,[LastUpdated])
				 VALUES 
					(((-100)*@Account_ID), @Account_ID, 'No Keyword Data',-1 ,GETDATE())
				
				 SET IDENTITY_INSERT [dbo].[UserProcess_GUI_Keyword] OFF

			 End	 ;      
		

END
