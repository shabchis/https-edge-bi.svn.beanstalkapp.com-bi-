﻿
--To do: Need to filter the migration data by account as an option
6666
-- Create Client hirerchy
	Insert into EdgeObjects.dbo.Account
	Select distinct Client_ID as ID, Client_Name as Name, 
		NULL, NULL as ParentAccountID
	From EDGE_OLTP_OLD.dbo.User_GUI_Account

-- Create Account hirerchy
	Insert into EdgeObjects.dbo.Account
	Select Account_id as ID, Account_Name as Name, 
		 Client_ID as ParentAccountID,
		Case when [Status] = 0 then 0
			Else 1
		End as [Status]
	From EDGE_OLTP_OLD.dbo.User_GUI_Account

-- Create Channel table
	INSERT INTO [dbo].[Channel]
           ([ID], [Name] ,[ChannelType])
	Select Channel_id, Display_Name, 2
	From EDGE_OLTP_OLD.dbo.Constant_Channel 

-- Create Ad table (note creativeGK is the same as Ad gk in the migrated data)
	Insert into	[EdgeObjects].[dbo].[Ad] 
				([GK] ,[Name] ,[OriginalID] ,[AccountID] ,[ChannelID] ,[ObjectStatus] ,[DestinationUrl] ,[CreativeGK])
	Select	 [PPC_Creative_GK] , Headline, [creativeid], [Account_ID], [Channel_ID], [creativeStatus], [creativeDestUrl], [PPC_Creative_GK]
	From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdgroupCreative]
	Where Account_ID = 10035

-- **** Ad Relations ****
-- Relate ad to campaign	
	INSERT INTO [dbo].[MetaValue] ([ObjectType] ,[ObjectGK] ,[PropertyID] ,[Value] ,[ValueGK])					
			Select 'Ad', PPC_Creative_GK , MP.ID, NULL, Campaign_GK 
			From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdgroupCreative] CR
			inner join [dbo].[MetaProperty] MP
				on (CR.Account_ID = MP.AccountID OR MP.AccountID = -1) and (CR.Channel_ID = MP.ChannelID OR MP.ChannelID = -1)
			Where  MP.Name = 'Campaign' and cr.Account_ID = 10035

-- Relate ad to adgroup	
	INSERT INTO [dbo].[MetaValue] ([ObjectType] ,[ObjectGK] ,[PropertyID] ,[Value] ,[ValueGK])					
			Select 'Ad', PPC_Creative_GK , MP.ID, NULL, AdGroup_GK 
			From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdgroupCreative] CR
			inner join [dbo].[MetaProperty] MP
				on (CR.Account_ID = MP.AccountID ) and (CR.Channel_ID = MP.ChannelID )
			Where  MP.Name = 'Adgroup' and cr.Account_ID = 10035
			
-- Relate ad to tracker	
	INSERT INTO [dbo].[MetaValue] ([ObjectType] ,[ObjectGK] ,[PropertyID] ,[Value] ,[ValueGK])					
			Select distinct 'Ad' [ObjectType] , PPC_Creative_GK [ObjectGK], MP.ID [PropertyID],  NULL [Value], gtw.gateway_gk [ValueGK] 
			from [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdgroupCreative] PCR
				inner join [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_Gateway] GTW
				on substring(creativeDestUrl,charindex('&p=edgetrackerid_',creativeDestUrl) + 17,99) = gtw.Gateway_id collate SQL_Latin1_General_CP1_CI_AS
				and  (PCR.Account_ID = GTW.Account_ID ) and (PCR.Channel_ID = GTW.Channel_ID )
			inner join [dbo].[MetaProperty] MP
				on (PCR.Account_ID = MP.AccountID ) and (PCR.Channel_ID = MP.ChannelID )
			Where  MP.Name = 'Tracker' and pcr.Account_ID = 10035
			and PPC_Creative_GK <> 700402599 -- the double tracker

-- Create title creative
	INSERT INTO [dbo].[Creative] 
				([GK] ,[ObjectType], [AccountID] , [Name] 
				,[int_Field1] ,string_Field1, [DateCreated] )
	Select 1000000000 + [Creative_GK], 'TextCreative',[Account_ID] ,'Title'
				,1,[Creative_Title] , [LastUpdated]
	From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_Creative] 
	Where Account_ID = 10035 
	
-- Create description creative
	INSERT INTO [dbo].[Creative] 
				([GK] ,[ObjectType], [AccountID] , [Name] 
				,[int_Field1] ,string_Field1, [DateCreated] )
	Select 2000000000 + [Creative_GK], 'TextCreative',[Account_ID] ,'Desc'
				,1, 
				Case when Len(Rtrim(LTrim(IsNull([Creative_Desc1],'') +' '+ IsNull([Creative_Desc2],'')))) =0 
					then NULL
					Else Rtrim(LTrim(IsNull([Creative_Desc1],'') +' '+ IsNull([Creative_Desc2],'')))
				End	 
				, [LastUpdated]
	From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_Creative] 
	Where Account_ID = 10035
		
-- Create display URL creative
	INSERT INTO [dbo].[Creative] 
				([GK] ,[ObjectType], [AccountID] , [Name] 
				,[int_Field1] ,string_Field1, [DateCreated] )
	Select 1000000000 + [PPC_Creative_GK], 'TextCreative',[Account_ID] ,'DisplayURL'
				,2, [creativeVisUrl] , [LastUpdated]
	From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdgroupCreative] 
	Where Account_ID = 10035 and creativeVisUrl <> 'OptionRally.com'

-- Create composite creative in creative table
	INSERT INTO [dbo].[Creative] 
				([GK] ,[ObjectType], [AccountID] , [Name] , [DateCreated] )
	SELECT [PPC_Creative_GK]  ,'CompositeCreative', [Account_ID] ,NULL , [LastUpdated]
	FROM [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdgroupCreative]
	where account_id = 10035 --> 25423 Rows

-- Create composite creative for titles
	INSERT INTO [dbo].[CreativeComposite]
				([AccountID], [CompositeCreativeGK] ,[ChildName], [SingleCreativeGK])
	Select distinct CR.[Account_ID], AGCR.[PPC_Creative_GK], 'Title', 1000000000 + CR.[Creative_GK] 
	From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_Creative]  CR
		inner join [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdgroupCreative] AGCR
			on cr.Account_ID = AGCR.Account_ID and cr.Creative_GK = AGCR.Creative_GK
	Where CR.Account_ID = 10035 --> 25423 Rows
	
-- Create composite creative for descriptions
	INSERT INTO [dbo].[CreativeComposite]
				([AccountID], [CompositeCreativeGK] ,[ChildName], [SingleCreativeGK])
	Select distinct CR.[Account_ID], AGCR.[PPC_Creative_GK], 'Desc', 2000000000 + CR.[Creative_GK] 
	From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_Creative]  CR
		inner join [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdgroupCreative] AGCR
			on cr.Account_ID = AGCR.Account_ID and cr.Creative_GK = AGCR.Creative_GK
	Where CR.Account_ID = 10035 --> 25423 Rows

	-- Create composite creative for display URLs
	INSERT INTO [dbo].[CreativeComposite]
				([AccountID], [CompositeCreativeGK] ,[ChildName], [SingleCreativeGK])
	Select distinct AGCR.[Account_ID], AGCR.[PPC_Creative_GK], 'DisplayURL', 1000000000 + [PPC_Creative_GK] 
	From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdgroupCreative] AGCR 
	Where AGCR.Account_ID = 10035 and creativeVisUrl <> 'OptionRally.com' --> 7033 Rows

	INSERT INTO [dbo].[CreativeComposite]
				([AccountID], [CompositeCreativeGK] ,[ChildName], [SingleCreativeGK])
	Select distinct AGCR.[Account_ID], AGCR.[PPC_Creative_GK], 'DisplayURL', 1000000000 
	From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdgroupCreative] AGCR 
	Where AGCR.Account_ID = 10035 and creativeVisUrl = 'OptionRally.com' --> 18390 Rows

-- ***************************************************************************************************************
	--Create campaigns table as EdgeObject without property
	set IDENTITY_INSERT [dbo].[EdgeObject] on 
	INSERT INTO [dbo].[EdgeObject]
           ([GK], [ObjectType] ,[AccountID] ,[ChannelID] ,[OriginalID] ,[Name] ,[Status] ,[int_Field1] ,[string_Field1])
	Select  [Campaign_GK]  ,'Campaign',[Account_ID] ,[Channel_ID] ,[campaignid] , NULL, [campStatus], [ScheduleEnabled], [campaign]
	From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidCampaign]
	set IDENTITY_INSERT [dbo].[EdgeObject]  off

	INSERT INTO [dbo].[ObjectTracking] 
	           ([AccountID]  ,[ChannelID] ,[ObjectTable] ,[ObjectGK] ,[DeliveryOutputID])
     Select [Account_ID], [Channel_ID], 'EdgeObject', [Campaign_GK] , 'Migration'
	 From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidCampaign] 

	
-- ***************************************************************************************************************
	 --Create adgroups table as EdgeObject without property
	set IDENTITY_INSERT [dbo].[EdgeObject] on 

	INSERT INTO [dbo].[EdgeObject]
           ([GK], [ObjectType] ,[AccountID] ,[ChannelID] ,[OriginalID] ,[int_Field1] ,[Status] ,[string_Field1])
	Select  [Adgroup_GK]  ,'Segment',[Account_ID] ,[Channel_ID] ,[adgroupID] , MP.ID, [agStatus], [adgroup] 
    From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdGroup] AG inner join [dbo].[MetaProperty] MP
		on AG.Channel_ID = MP.ChannelID and AG.Account_ID = MP.AccountID
	Where MP.Name = 'Adgroup'

	set IDENTITY_INSERT [dbo].[EdgeObject]  off

	INSERT INTO [dbo].[ObjectTracking] 
	           ([AccountID]  ,[ChannelID] ,[ObjectTable] ,[ObjectGK] ,[DeliveryOutputID])
     Select [Account_ID], [Channel_ID], 'EdgeObject', [Adgroup_GK] , 'Migration' 
	 FROM [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdGroup]

	 -- Create meta property for adgroup
	 INSERT INTO [dbo].[MetaProperty] ([Name] ,[AccountID] ,[ChannelID] ,[BaseValueType])
								select distinct 'Adgroup', [Account_ID], [Channel_ID], 'Segment'
								 FROM [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdGroup]
	
	-- Associate meta value to each adgroup		
	 INSERT INTO [dbo].[MetaValue] ([ObjectType] ,[ObjectGK] ,[PropertyID] ,[Value] ,[ValueGK])					
								 Select 'Segment', Adgroup_gk , MP.ID, NULL, Campaign_GK 
								 From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdGroup] AG
									inner join [dbo].[MetaProperty] MP
										on (AG.Account_ID = MP.AccountID OR MP.AccountID = -1) and (AG.Channel_ID = MP.ChannelID OR MP.ChannelID = -1)
								 Where  MP.Name = 'Campaign'

-- ***************************************************************************************************************
	 -- Create meta property for tracker
	 INSERT INTO [dbo].[MetaProperty] ([Name] ,[AccountID] ,[ChannelID] ,[BaseValueType])
								select distinct 'Tracker', [Account_ID], [Channel_ID],'Segment'
								 FROM [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_Gateway]
	
	 --Create trackers as EdgeObject 
	set IDENTITY_INSERT [dbo].[EdgeObject] on 

	INSERT INTO [dbo].[EdgeObject]
           ([GK], [ObjectType] ,[AccountID] ,[ChannelID] ,[OriginalID] ,[int_field1],[string_Field1])
	Select  [Gateway_GK]  ,'Segment',[Account_ID] ,[Channel_ID] ,[Gateway_id] , MP.ID, [Gateway_id]
	FROM [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_Gateway] GTW inner join [dbo].[MetaProperty] MP
		on GTW.Channel_ID = MP.ChannelID and GTW.Account_ID = MP.AccountID
	Where MP.Name = 'Tracker'
	
	set IDENTITY_INSERT [dbo].[EdgeObject]  off

	INSERT INTO [dbo].[ObjectTracking] 
	           ([AccountID]  ,[ChannelID] ,[ObjectTable] ,[ObjectGK] ,[DeliveryOutputID])
     Select [Account_ID], [Channel_ID], 'EdgeObject', [Gateway_GK] , 'Migration' 
	 FROM [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_Gateway]

		
	 --INSERT INTO [dbo].[MetaValue] ([ObjectType] ,[ObjectGK] ,[PropertyID] ,[Value] ,[ValueGK])					
		--						 Select  EO.ObjectType , EO.GK , MP.ID, EO.ObjectType, NULL, EO.GK 
		--						 From [dbo].[EdgeObject] EO
		--							inner join [dbo].[MetaProperty] MP
		--								on EO.AccountID = MP.AccountID and EO.ChannelID = MP.ChannelID
		--									and EO.Name = MP.Name and EO.ObjectType = MP.BaseValueType
		--						 Where EO.ObjectType = 'Segment' and EO.Name = 'Tracker'

 -- Create meta property for Target Keyword
	 INSERT INTO [dbo].[MetaProperty] ([Name] ,[AccountID] ,[ChannelID] ,[BaseValueType])
								select distinct 'TargetKeyword', [Account_ID], NULL,'Target'
								 FROM [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_Keyword]
	
	set IDENTITY_INSERT [dbo].[Target]  on

	INSERT INTO [dbo].[Target]
				   (GK, [ObjectType] ,[AccountID] ,[Name] ,[int_Field1] /*PropertyID*/ ,[string_Field1])
		Select Keyword_GK , 'Target', Account_ID, NULL, 9 /*PropertyID*/ , Keyword
		From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_Keyword]

	set IDENTITY_INSERT [dbo].[Target]  off
		
	INSERT INTO [dbo].[ObjectTracking] 
	           ([AccountID]  ,[ChannelID] ,[ObjectTable] ,[ObjectGK] ,[DeliveryOutputID])
     Select [Account_ID], NULL, 'Target', [Keyword_GK] , 'Migration' 
	 FROM [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_Keyword]


-- No Content data for 10035

 -- Create meta property for Target definition - ppc Keyword
	 INSERT INTO [dbo].[MetaProperty] ([Name] ,[AccountID] ,[ChannelID] ,[BaseValueType])
								select distinct 'PPCKeyword', [Account_ID], -1,'TargetDefinition'
								 FROM [EDGE_OLTP_OLD].[dbo].UserProcess_GUI_PaidAdgroupKeyword
	
	
	INSERT INTO [dbo].[AdTargetDefinition]
				(GK, ADgk, TargetGK, [ObjectType] ,[AccountID] ,[Name] ,[DestinationUrl], [int_Field1] /*PropertyID*/, [int_Field2] )
	Select distinct kw.PPC_Keyword_GK , fact.ppc_creative_gk , kw.Keyword_GK, 'TargetDefinition', kw.Account_ID, NULL, kw.kwDestUrl ,10 /*PropertyID*/ , kw.MatchType 
	From [EDGE_OLTP_OLD].[dbo].UserProcess_GUI_PaidAdgroupKeyword kw
		inner join [EDGE_OLTP_OLD].[dbo].[Paid_API_AllColumns_v29] fact
			on fact.Account_ID = kw.Account_ID and fact.PPC_Keyword_GK = kw.PPC_Keyword_GK 
				
-- Did not run cause of the PK includes 2 fields (adGK + GK)

-- INSERT INTO [dbo].[ObjectTracking] 
--           ([AccountID]  ,[ObjectTable] ,[ObjectGK] ,[DeliveryOutputID])
--    Select [AccountID], 'ADTargetDefinition', [GK] , 'Migration' 
-- From [AdTargetDefinition]


 -- Create meta property for Target match - ppc Keyword
	 INSERT INTO [dbo].[MetaProperty] ([Name] ,[AccountID] ,[ChannelID] ,[BaseValueType])
								select distinct 'PPCKeyword', [Account_ID], -1,'TargetMatch'
								 FROM [EDGE_OLTP_OLD].[dbo].UserProcess_GUI_PaidAdgroupKeyword
	
	
	INSERT INTO [dbo].[AdTargetMatch]
				(GK, ADgk, TargetGK, [AdTargetDefinitionGK], [ObjectType] ,[AccountID] ,[Name] ,[DestinationUrl], [int_Field1] /*PropertyID*/)
	Select distinct kw.PPC_Keyword_GK , fact.ppc_creative_gk , kw.Keyword_GK,  kw.PPC_Keyword_GK ,'TargetMatch', kw.Account_ID, NULL, fact.destUrl ,11 /*PropertyID*/
	From [EDGE_OLTP_OLD].[dbo].UserProcess_GUI_PaidAdgroupKeyword kw
		inner join [EDGE_OLTP_OLD].[dbo].[Paid_API_AllColumns_v29] fact
			on fact.Account_ID = kw.Account_ID and fact.PPC_Keyword_GK = kw.PPC_Keyword_GK 
				
-- Did not run cause of the PK includes 2 fields (adGK + GK)

-- INSERT INTO [dbo].[ObjectTracking] 
--           ([AccountID]  ,[ObjectTable] ,[ObjectGK] ,[DeliveryOutputID])
--    Select [AccountID], 'ADTargetDefinition', [GK] , 'Migration' 
-- From [AdTargetDefinition]


-- ***************************************************************************************************************

				



