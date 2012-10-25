
--To do: Need to filter the migration data by account as an option
6666
 --****************** Account and channel hirerchy *****************************
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

--****************** Ad and creative hirerchy *****************************
-- Create Ad table (note creativeGK is the same as Ad gk in the migrated data)
	Insert into	[EdgeObjects].[dbo].[Ad] 
				([GK] ,[Name] ,[OriginalID] ,[AccountID] ,[ChannelID] ,[ObjectStatus] ,[DestinationUrl] ,[CreativeGK])
	Select	 [PPC_Creative_GK] , Headline, [creativeid], [Account_ID], [Channel_ID], [creativeStatus], [creativeDestUrl], [PPC_Creative_GK]
	From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdgroupCreative]
	Where Account_ID = 10035
			
-- Create title creative
	INSERT INTO [dbo].[Creative] 
				([GK] ,[ObjectType], [AccountID] , [Name] 
				,[int_Field1] ,string_Field1 )
	Select 1000000000 + [Creative_GK], 'TextCreative',[Account_ID] ,'Title'
				,1,[Creative_Title] 
	From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_Creative] 
	Where Account_ID = 10035 
	
-- Create description creative
	INSERT INTO [dbo].[Creative] 
				([GK] ,[ObjectType], [AccountID] , [Name] 
				,[int_Field1] ,string_Field1 )
	Select 2000000000 + [Creative_GK], 'TextCreative',[Account_ID] ,'Desc'
				,1, 
				Case when Len(Rtrim(LTrim(IsNull([Creative_Desc1],'') +' '+ IsNull([Creative_Desc2],'')))) =0 
					then NULL
					Else Rtrim(LTrim(IsNull([Creative_Desc1],'') +' '+ IsNull([Creative_Desc2],'')))
				End	 
				
	From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_Creative] 
	Where Account_ID = 10035
		
-- Create display URL creative
	INSERT INTO [dbo].[Creative] 
				([GK] ,[ObjectType], [AccountID] , [Name] 
				,[int_Field1] ,string_Field1 )
	Select 1000000000 + [PPC_Creative_GK], 'TextCreative',[Account_ID] ,'DisplayURL'
				,2, [creativeVisUrl]
	From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdgroupCreative] 
	Where Account_ID = 10035 and creativeVisUrl <> 'OptionRally.com'

-- Create composite creative in creative table
	INSERT INTO [dbo].[Creative] 
				([GK] ,[ObjectType], [AccountID] , [Name]  )
	SELECT [PPC_Creative_GK]  ,'CompositeCreative', [Account_ID] ,NULL 
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

--****************** Campaigns *****************************
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

	
--****************** Adgroup *****************************
	set IDENTITY_INSERT [dbo].[EdgeObject] on 

	INSERT INTO [dbo].[EdgeObject]
           ([GK], [ObjectType] ,[AccountID] ,[ChannelID] ,[OriginalID] ,[int_Field1] ,[Status] ,[string_Field1])
	Select  [Adgroup_GK]  ,'Segment',[Account_ID] ,[Channel_ID] ,[adgroupID] , MP.ID, [agStatus], [adgroup] 
    From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdGroup] AG inner join [dbo].[ConnectionDefinition] MP
		on AG.Channel_ID = MP.ChannelID and AG.Account_ID = MP.AccountID
	Where MP.Name = 'Adgroup'

	set IDENTITY_INSERT [dbo].[EdgeObject]  off

	INSERT INTO [dbo].[ObjectTracking] 
	           ([AccountID]  ,[ChannelID] ,[ObjectTable] ,[ObjectGK] ,[DeliveryOutputID])
     Select [Account_ID], [Channel_ID], 'EdgeObject', [Adgroup_GK] , 'Migration' 
	 FROM [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdGroup]

-- Create Connection definition for adgroup
	 INSERT INTO [dbo].[ConnectionDefinition] ([Name] ,[AccountID] ,[ChannelID] ,[BaseValueType])
								select distinct 'Adgroup', [Account_ID], [Channel_ID], 'Segment'
								 FROM [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdGroup]
	
-- Associate connection to each adgroup		
	 INSERT INTO [dbo].[Connection] ([FromObjectType] ,[FromObjectGK] ,[ConnectionDefID] ,[ToObjectType] ,[ToObjectGK])					
								 Select 'Segment', Adgroup_gk , MP.ID, 'Campaign', Campaign_GK 
								 From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdGroup] AG
									inner join [dbo].[ConnectionDefinition] MP
										on (AG.Account_ID = MP.AccountID OR MP.AccountID = -1) and (AG.Channel_ID = MP.ChannelID OR MP.ChannelID = -1)
								 Where  MP.Name = 'Campaign'

--****************** Trackers *****************************
	 -- Create Connection definition for tracker
	 INSERT INTO [dbo].[ConnectionDefinition] ([Name] ,[AccountID] ,[ChannelID] ,[BaseValueType])
								select distinct 'Tracker', [Account_ID], [Channel_ID],'Segment'
								 FROM [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_Gateway]
	
	 --Create trackers as EdgeObject 
	set IDENTITY_INSERT [dbo].[EdgeObject] on 

	INSERT INTO [dbo].[EdgeObject]
           ([GK], [ObjectType] ,[AccountID] ,[ChannelID] ,[OriginalID] ,[int_field1],[string_Field1])
	Select  [Gateway_GK]  ,'Segment',[Account_ID] ,[Channel_ID] ,[Gateway_id] , MP.ID, [Gateway_id]
	FROM [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_Gateway] GTW inner join [dbo].[ConnectionDefinition] MP
		on GTW.Channel_ID = MP.ChannelID and GTW.Account_ID = MP.AccountID
	Where MP.Name = 'Tracker'
	
	set IDENTITY_INSERT [dbo].[EdgeObject]  off

	INSERT INTO [dbo].[ObjectTracking] 
	           ([AccountID]  ,[ChannelID] ,[ObjectTable] ,[ObjectGK] ,[DeliveryOutputID])
     Select [Account_ID], [Channel_ID], 'EdgeObject', [Gateway_GK] , 'Migration' 
	 FROM [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_Gateway]

	 
--****************** Keyword target *****************************
 -- Create Connection definition for Target Keyword
	 INSERT INTO [dbo].[ConnectionDefinition] ([Name] ,[AccountID] ,[ChannelID] ,[BaseValueType])
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

 -- Create Connection definition for Target definition - ppc Keyword
	 INSERT INTO [dbo].[ConnectionDefinition] ([Name] ,[AccountID] ,[ChannelID] ,[BaseValueType])
								select distinct 'PPCKeyword', [Account_ID], -1,'TargetDefinition'
								 FROM [EDGE_OLTP_OLD].[dbo].UserProcess_GUI_PaidAdgroupKeyword
	
	
	INSERT INTO [dbo].[AdTargetDefinition]
				(GK, ADgk, TargetGK, [AccountID] ,[Name] ,[DestinationUrl], [int_Field1] /*PropertyID*/, [int_Field2] )
	Select distinct kw.PPC_Keyword_GK , fact.ppc_creative_gk , kw.Keyword_GK, kw.Account_ID, NULL, kw.kwDestUrl ,10 /*PropertyID*/ , kw.MatchType 
	From [EDGE_OLTP_OLD].[dbo].UserProcess_GUI_PaidAdgroupKeyword kw
		inner join [EDGE_OLTP_OLD].[dbo].[Paid_API_AllColumns_v29] fact
			on fact.Account_ID = kw.Account_ID and fact.PPC_Keyword_GK = kw.PPC_Keyword_GK 
				
	 INSERT INTO [dbo].[ObjectTracking] 
			   ([AccountID]  ,[ObjectTable] ,[ObjectGK] ,[DeliveryOutputID])
		Select [AccountID], 'ADTargetDefinition', [GK] , 'Migration' 
	 From [AdTargetDefinition]


 -- Create Connection definition for Target match - ppc Keyword
	 INSERT INTO [dbo].[ConnectionDefinition] ([Name] ,[AccountID] ,[ChannelID] ,[BaseValueType])
								select distinct 'PPCKeyword', [Account_ID], -1,'TargetMatch'
								 FROM [EDGE_OLTP_OLD].[dbo].UserProcess_GUI_PaidAdgroupKeyword
	
	
	INSERT INTO [dbo].[AdTargetMatch]
				(GK, ADgk, TargetGK, [AdTargetDefinitionGK], [AccountID] ,[Name] ,[DestinationUrl], [int_Field1] /*PropertyID*/)
	Select distinct kw.PPC_Keyword_GK , fact.ppc_creative_gk , kw.Keyword_GK,  kw.PPC_Keyword_GK , kw.Account_ID, NULL, fact.destUrl ,11 /*PropertyID*/
	From [EDGE_OLTP_OLD].[dbo].UserProcess_GUI_PaidAdgroupKeyword kw
		inner join [EDGE_OLTP_OLD].[dbo].[Paid_API_AllColumns_v29] fact
			on fact.Account_ID = kw.Account_ID and fact.PPC_Keyword_GK = kw.PPC_Keyword_GK 
	
	 INSERT INTO [dbo].[ObjectTracking] 
			   ([AccountID]  ,[ObjectTable] ,[ObjectGK] ,[DeliveryOutputID])
		Select [AccountID], 'ADTargetDefinition', [GK] , 'Migration' 
	 From [AdTargetDefinition]


--****************** Segments *****************************
-- Import Theme data				
-- Create Connection definition for theme segment
	 INSERT INTO [dbo].[ConnectionDefinition] ([Name] ,[AccountID] ,[ChannelID] ,[BaseValueType])
								values ( 'Theme', -1, -1,'Segment')
								

	set IDENTITY_INSERT [dbo].[EdgeObject] on 

	INSERT INTO [dbo].[EdgeObject]
           ([GK], [ObjectType] ,[AccountID] ,[ChannelID] ,[OriginalID] ,[int_field1],[string_Field1])
		SELECT  [ValueID],'Segment',[AccountID], NULL, NULL ,14, [Value]
		FROM [EDGE_OLTP_OLD].[dbo].[SegmentValue]
		Where SegmentID = 3 /* theme */
	
	set IDENTITY_INSERT [dbo].[EdgeObject]  off

-- insertion of all segments
	INSERT INTO [dbo].[ObjectTracking] 
	           ([AccountID]  ,[ChannelID] ,[ObjectTable] ,[ObjectGK] ,[DeliveryOutputID])
     Select [AccountID], NULL, 'EdgeObject', [ValueID] , 'Migration' 
	 FROM [EDGE_OLTP_OLD].[dbo].[SegmentValue]

-- Import Language segment data				
	 INSERT INTO [dbo].[ConnectionDefinition] ([Name] ,[AccountID] ,[ChannelID] ,[BaseValueType])
								values ( 'Language', -1, -1,'Segment')
								
	set IDENTITY_INSERT [dbo].[EdgeObject] on 

	INSERT INTO [dbo].[EdgeObject]
           ([GK], [ObjectType] ,[AccountID] ,[ChannelID] ,[OriginalID] ,[int_field1],[string_Field1])
		SELECT  [ValueID],'Segment',[AccountID], NULL, NULL ,15, [Value]
		FROM [EDGE_OLTP_OLD].[dbo].[SegmentValue]
		Where SegmentID = 1 /* Language */

	set IDENTITY_INSERT [dbo].[EdgeObject]  off

-- Import Geographic segment data				
	 INSERT INTO [dbo].[ConnectionDefinition] ([Name] ,[AccountID] ,[ChannelID] ,[BaseValueType])
								values ( 'Geographic', -1, -1,'Segment')
								
	set IDENTITY_INSERT [dbo].[EdgeObject] on 

	INSERT INTO [dbo].[EdgeObject]
           ([GK], [ObjectType] ,[AccountID] ,[ChannelID] ,[OriginalID] ,[int_field1],[string_Field1])
		SELECT  [ValueID],'Segment',[AccountID], NULL, NULL ,16, [Value]
		FROM [EDGE_OLTP_OLD].[dbo].[SegmentValue]
		Where SegmentID = 2 /* Geographic */

	set IDENTITY_INSERT [dbo].[EdgeObject]  off
	
-- Import Country segment data				
	 INSERT INTO [dbo].[ConnectionDefinition] ([Name] ,[AccountID] ,[ChannelID] ,[BaseValueType])
								values ( 'Country', -1, -1,'Segment')
								
	set IDENTITY_INSERT [dbo].[EdgeObject] on 

	INSERT INTO [dbo].[EdgeObject]
           ([GK], [ObjectType] ,[AccountID] ,[ChannelID] ,[OriginalID] ,[int_field1],[string_Field1])
		SELECT  [ValueID],'Segment',[AccountID], NULL, NULL ,17, [Value]
		FROM [EDGE_OLTP_OLD].[dbo].[SegmentValue]
		Where SegmentID = 4 /* Country */

	set IDENTITY_INSERT [dbo].[EdgeObject]  off
		
		
-- Import Country segment data				
	 INSERT INTO [dbo].[ConnectionDefinition] ([Name] ,[AccountID] ,[ChannelID] ,[BaseValueType])
								values ( 'USP', -1, -1,'Segment')
								
	set IDENTITY_INSERT [dbo].[EdgeObject] on 

	INSERT INTO [dbo].[EdgeObject]
           ([GK], [ObjectType] ,[AccountID] ,[ChannelID] ,[OriginalID] ,[int_field1],[string_Field1])
		SELECT  [ValueID],'Segment',[AccountID], NULL, NULL ,18, [Value]
		FROM [EDGE_OLTP_OLD].[dbo].[SegmentValue]
		Where SegmentID = 5 /* USP */

	set IDENTITY_INSERT [dbo].[EdgeObject]  off

-- Import page segment data				
	 INSERT INTO [dbo].[ConnectionDefinition] ([Name] ,[AccountID] ,[ChannelID] ,[BaseValueType])
								values ( 'LandingPage', -1, -1,'Segment')
								
	set IDENTITY_INSERT [dbo].[EdgeObject] on 

	INSERT INTO [dbo].[EdgeObject]
           ([GK], [ObjectType] ,[AccountID] ,[ChannelID] ,[OriginalID] ,[int_field1],[string_Field1])
		SELECT  100000+ Page_gk,'Segment',[Account_ID], NULL, NULL ,19, [Title]
		FROM [EDGE_OLTP_OLD].[dbo].UserProcess_GUI_Page
		Where Account_ID =10035

	set IDENTITY_INSERT [dbo].[EdgeObject]  off
		

-- *************************** Ad Connections ***********************************************
-- Connect ad to campaign	
	INSERT INTO [dbo].[Connection] ([FromObjectType] ,[FromObjectGK] ,[ConnectionDefID] ,[ToObjectType] ,[ToObjectGK])					
			Select 'Ad', PPC_Creative_GK , MP.ID, 'Campaign', Campaign_GK 
			From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdgroupCreative] CR
			inner join [dbo].[ConnectionDefinition] MP
				on (CR.Account_ID = MP.AccountID OR MP.AccountID = -1) and (CR.Channel_ID = MP.ChannelID OR MP.ChannelID = -1)
			Where  MP.Name = 'Campaign' and cr.Account_ID = 10035

-- Connect ad to adgroup	
	INSERT INTO [dbo].[Connection] ([FromObjectType] ,[FromObjectGK] ,[ConnectionDefID] ,[ToObjectType] ,[ToObjectGK])					
			Select 'Ad', PPC_Creative_GK , MP.ID, 'Adgroup', AdGroup_GK 
			From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdgroupCreative] CR
			inner join [dbo].[ConnectionDefinition] MP
				on (CR.Account_ID = MP.AccountID ) and (CR.Channel_ID = MP.ChannelID )
			Where  MP.Name = 'Adgroup' and cr.Account_ID = 10035
			
-- Connect ad to tracker	
	INSERT INTO [dbo].[Connection] ([FromObjectType] ,[FromObjectGK] ,[ConnectionDefID] ,[ToObjectType] ,[ToObjectGK])					
			Select distinct 'Ad' [ObjectType] , PPC_Creative_GK [ObjectGK], MP.ID [PropertyID],  'Tracker' [Value], gtw.gateway_gk [ValueGK] 
			from [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdgroupCreative] PCR
				inner join [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_Gateway] GTW
				on substring(creativeDestUrl,charindex('&p=edgetrackerid_',creativeDestUrl) + 17,99) = gtw.Gateway_id collate SQL_Latin1_General_CP1_CI_AS
				and  (PCR.Account_ID = GTW.Account_ID ) and (PCR.Channel_ID = GTW.Channel_ID )
			inner join [dbo].[ConnectionDefinition] MP
				on (PCR.Account_ID = MP.AccountID ) and (PCR.Channel_ID = MP.ChannelID )
			Where  MP.Name = 'Tracker' and pcr.Account_ID = 10035
			and PPC_Creative_GK <> 700402599 -- the double tracker

-- Connect ad to language segment
	INSERT INTO [dbo].[Connection] ([FromObjectType] ,[FromObjectGK] ,[ConnectionDefID] ,[ToObjectType] ,[ToObjectGK])					
			Select 'Ad', PPC_Creative_GK , MP.ID, 'Language', Segment1 
			From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdgroupCreative] CR
			inner join [dbo].[ConnectionDefinition] MP
				on (CR.Account_ID = MP.AccountID Or MP.AccountID = -1) and (CR.Channel_ID = MP.ChannelID Or MP.ChannelID = -1)
			Where  MP.Name = 'Language' and cr.Account_ID = 10035 and CR.Segment1 is not null and CR.Segment1 != -1

-- Connect ad to Geographic segment
	INSERT INTO [dbo].[Connection] ([FromObjectType] ,[FromObjectGK] ,[ConnectionDefID] ,[ToObjectType] ,[ToObjectGK])					
			Select 'Ad', PPC_Creative_GK , MP.ID, 'Geographic', Segment2 
			From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdgroupCreative] CR
			inner join [dbo].[ConnectionDefinition] MP
				on (CR.Account_ID = MP.AccountID Or MP.AccountID = -1) and (CR.Channel_ID = MP.ChannelID Or MP.ChannelID = -1)
			Where  MP.Name = 'Geographic' and cr.Account_ID = 10035 and CR.Segment2 is not null and CR.Segment2 != -1

-- Connect ad to theme segment
	INSERT INTO [dbo].[Connection] ([FromObjectType] ,[FromObjectGK] ,[ConnectionDefID] ,[ToObjectType] ,[ToObjectGK])					
			Select 'Ad', PPC_Creative_GK , MP.ID, 'Theme', Segment3 
			From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdgroupCreative] CR
			inner join [dbo].[ConnectionDefinition] MP
				on (CR.Account_ID = MP.AccountID Or MP.AccountID = -1) and (CR.Channel_ID = MP.ChannelID Or MP.ChannelID = -1)
			Where  MP.Name = 'Theme' and cr.Account_ID = 10035 and CR.Segment3 is not null and CR.Segment3 != -1

-- Connect ad to country segment
	INSERT INTO [dbo].[Connection] ([FromObjectType] ,[FromObjectGK] ,[ConnectionDefID] ,[ToObjectType] ,[ToObjectGK])					
			Select 'Ad', PPC_Creative_GK , MP.ID, 'Country', Segment4 
			From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdgroupCreative] CR
			inner join [dbo].[ConnectionDefinition] MP
				on (CR.Account_ID = MP.AccountID Or MP.AccountID = -1) and (CR.Channel_ID = MP.ChannelID Or MP.ChannelID = -1)
			Where  MP.Name = 'Country' and cr.Account_ID = 10035 and CR.Segment4 is not null and CR.Segment4 != -1

-- Connect ad to USP segment
	INSERT INTO [dbo].[Connection] ([FromObjectType] ,[FromObjectGK] ,[ConnectionDefID] ,[ToObjectType] ,[ToObjectGK])					
			Select 'Ad', PPC_Creative_GK , MP.ID, 'USP', Segment5 
			From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdgroupCreative] CR
			inner join [dbo].[ConnectionDefinition] MP
				on (CR.Account_ID = MP.AccountID Or MP.AccountID = -1) and (CR.Channel_ID = MP.ChannelID Or MP.ChannelID = -1)
			Where  MP.Name = 'USP' and cr.Account_ID = 10035 and CR.Segment5 is not null and CR.Segment5 != -1

-- Connect ad to landing page 
	INSERT INTO [dbo].[Connection] ([FromObjectType] ,[FromObjectGK] ,[ConnectionDefID] ,[ToObjectType] ,[ToObjectGK])					
			Select 'Ad', PPC_Creative_GK , MP.ID, 'LandingPage',  100000+ Page_gk 
			From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdgroupCreative] CR
			inner join [dbo].[ConnectionDefinition] MP
				on (CR.Account_ID = MP.AccountID Or MP.AccountID = -1) and (CR.Channel_ID = MP.ChannelID Or MP.ChannelID = -1)
			Where  MP.Name = 'LandingPage' and cr.Account_ID = 10035 and CR.Page_GK is not null and CR.Page_gk != -1
		
-- *************************** Campaign Connections ***********************************************
-- Connect campaign to language segment
	INSERT INTO [dbo].[Connection] ([FromObjectType] ,[FromObjectGK] ,[ConnectionDefID] ,[ToObjectType] ,[ToObjectGK])					
			Select 'Campaign', Campaign_GK , MP.ID, 'Language', Segment1 
			From [EDGE_OLTP_OLD].[dbo].UserProcess_GUI_PaidCampaign CA
			inner join [dbo].[ConnectionDefinition] MP
				on (CA.Account_ID = MP.AccountID Or MP.AccountID = -1) and (CA.Channel_ID = MP.ChannelID Or MP.ChannelID = -1)
			Where  MP.Name = 'Language' and CA.Account_ID = 10035 and CA.Segment1 is not null and CA.Segment1 != -1

-- Connect campaign to geographic segment
	INSERT INTO [dbo].[Connection] ([FromObjectType] ,[FromObjectGK] ,[ConnectionDefID] ,[ToObjectType] ,[ToObjectGK])					
			Select 'Campaign', Campaign_GK , MP.ID, 'Geographic', Segment2 
			From [EDGE_OLTP_OLD].[dbo].UserProcess_GUI_PaidCampaign CA
			inner join [dbo].[ConnectionDefinition] MP
				on (CA.Account_ID = MP.AccountID Or MP.AccountID = -1) and (CA.Channel_ID = MP.ChannelID Or MP.ChannelID = -1)
			Where  MP.Name = 'Geographic' and CA.Account_ID = 10035 and CA.Segment2 is not null and CA.Segment2 != -1

-- Connect campaign to theme segment
	INSERT INTO [dbo].[Connection] ([FromObjectType] ,[FromObjectGK] ,[ConnectionDefID] ,[ToObjectType] ,[ToObjectGK])					
			Select 'Campaign', Campaign_GK , MP.ID, 'Theme', Segment3 
			From [EDGE_OLTP_OLD].[dbo].UserProcess_GUI_PaidCampaign CA
			inner join [dbo].[ConnectionDefinition] MP
				on (CA.Account_ID = MP.AccountID Or MP.AccountID = -1) and (CA.Channel_ID = MP.ChannelID Or MP.ChannelID = -1)
			Where  MP.Name = 'Theme' and CA.Account_ID = 10035 and CA.Segment3 is not null and CA.Segment3 != -1

-- Connect campaign to country segment
	INSERT INTO [dbo].[Connection] ([FromObjectType] ,[FromObjectGK] ,[ConnectionDefID] ,[ToObjectType] ,[ToObjectGK])					
			Select 'Campaign', Campaign_GK , MP.ID, 'Country', Segment4 
			From [EDGE_OLTP_OLD].[dbo].UserProcess_GUI_PaidCampaign CA
			inner join [dbo].[ConnectionDefinition] MP
				on (CA.Account_ID = MP.AccountID Or MP.AccountID = -1) and (CA.Channel_ID = MP.ChannelID Or MP.ChannelID = -1)
			Where  MP.Name = 'Country' and CA.Account_ID = 10035 and CA.Segment4 is not null and CA.Segment4 != -1

-- Connect campaign to USP segment
	INSERT INTO [dbo].[Connection] ([FromObjectType] ,[FromObjectGK] ,[ConnectionDefID] ,[ToObjectType] ,[ToObjectGK])					
			Select 'Campaign', Campaign_GK , MP.ID, 'USP', Segment5 
			From [EDGE_OLTP_OLD].[dbo].UserProcess_GUI_PaidCampaign CA
			inner join [dbo].[ConnectionDefinition] MP
				on (CA.Account_ID = MP.AccountID Or MP.AccountID = -1) and (CA.Channel_ID = MP.ChannelID Or MP.ChannelID = -1)
			Where  MP.Name = 'USP' and CA.Account_ID = 10035 and CA.Segment5 is not null and CA.Segment5 != -1

-- *************************** Tracker Connections ***********************************************
-- Connect tracker to language segment
	INSERT INTO [dbo].[Connection] ([FromObjectType] ,[FromObjectGK] ,[ConnectionDefID] ,[ToObjectType] ,[ToObjectGK])					
			Select 'Tracker', Gateway_GK , MP.ID, 'Language', Segment1 
			From [EDGE_OLTP_OLD].[dbo].UserProcess_GUI_Gateway CA
			inner join [dbo].[ConnectionDefinition] MP
				on (CA.Account_ID = MP.AccountID Or MP.AccountID = -1) and (CA.Channel_ID = MP.ChannelID Or MP.ChannelID = -1)
			Where  MP.Name = 'Language' and CA.Account_ID = 10035 and CA.Segment1 is not null and CA.Segment1 != -1
			
-- Connect tracker to geographic segment
	INSERT INTO [dbo].[Connection] ([FromObjectType] ,[FromObjectGK] ,[ConnectionDefID] ,[ToObjectType] ,[ToObjectGK])					
			Select 'Tracker', Gateway_GK , MP.ID, 'Geographic', Segment2 
			From [EDGE_OLTP_OLD].[dbo].UserProcess_GUI_Gateway CA
			inner join [dbo].[ConnectionDefinition] MP
				on (CA.Account_ID = MP.AccountID Or MP.AccountID = -1) and (CA.Channel_ID = MP.ChannelID Or MP.ChannelID = -1)
			Where  MP.Name = 'Geographic' and CA.Account_ID = 10035 and CA.Segment2 is not null and CA.Segment2 != -1

-- Connect tracker to theme segment
	INSERT INTO [dbo].[Connection] ([FromObjectType] ,[FromObjectGK] ,[ConnectionDefID] ,[ToObjectType] ,[ToObjectGK])					
			Select 'Tracker', Gateway_GK , MP.ID, 'Theme', Segment3 
			From [EDGE_OLTP_OLD].[dbo].UserProcess_GUI_Gateway CA
			inner join [dbo].[ConnectionDefinition] MP
				on (CA.Account_ID = MP.AccountID Or MP.AccountID = -1) and (CA.Channel_ID = MP.ChannelID Or MP.ChannelID = -1)
			Where  MP.Name = 'Theme' and CA.Account_ID = 10035 and CA.Segment3 is not null and CA.Segment3 != -1
						
-- Connect tracker to country segment
	INSERT INTO [dbo].[Connection] ([FromObjectType] ,[FromObjectGK] ,[ConnectionDefID] ,[ToObjectType] ,[ToObjectGK])					
			Select 'Tracker', Gateway_GK , MP.ID, 'Country', Segment4
			From [EDGE_OLTP_OLD].[dbo].UserProcess_GUI_Gateway CA
			inner join [dbo].[ConnectionDefinition] MP
				on (CA.Account_ID = MP.AccountID Or MP.AccountID = -1) and (CA.Channel_ID = MP.ChannelID Or MP.ChannelID = -1)
			Where  MP.Name = 'Country' and CA.Account_ID = 10035 and CA.Segment4 is not null and CA.Segment4 != -1

-- Connect tracker to USP segment
	INSERT INTO [dbo].[Connection] ([FromObjectType] ,[FromObjectGK] ,[ConnectionDefID] ,[ToObjectType] ,[ToObjectGK])					
			Select 'Tracker', Gateway_GK , MP.ID, 'USP', Segment5
			From [EDGE_OLTP_OLD].[dbo].UserProcess_GUI_Gateway CA
			inner join [dbo].[ConnectionDefinition] MP
				on (CA.Account_ID = MP.AccountID Or MP.AccountID = -1) and (CA.Channel_ID = MP.ChannelID Or MP.ChannelID = -1)
			Where  MP.Name = 'USP' and CA.Account_ID = 10035 and CA.Segment5 is not null and CA.Segment5 != -1

-- Connect tracker to landing page 
	INSERT INTO [dbo].[Connection] ([FromObjectType] ,[FromObjectGK] ,[ConnectionDefID] ,[ToObjectType] ,[ToObjectGK])								
			Select 'Tracker', Gateway_GK , MP.ID,'LandingPage',  100000+ Page_gk 
			From [EDGE_OLTP_OLD].[dbo].UserProcess_GUI_Gateway CA
			inner join [dbo].[ConnectionDefinition] MP
				on (CA.Account_ID = MP.AccountID Or MP.AccountID = -1) and (CA.Channel_ID = MP.ChannelID Or MP.ChannelID = -1)
			Where  MP.Name = 'LandingPage' and CA.Account_ID = 10035 and CA.Page_GK is not null and CA.Page_gk != -1

-- ************* Measures and Goals ******************************************

	--set IDENTITY_INSERT [dbo].[Measure] on
	--INSERT INTO [dbo].[Measure]
	--           ([ID], [Name] ,[MeasureDataType] ,[ChannelID] ,[AccountID] ,[DisplayName] ,[StringFormat] 
	--			,[InheritedByDefault] ,[OptionsOverride] ,[Options])
	--SELECT [MeasureID], [Name] , 1, [ChannelID], [AccountID] , [DisplayName], [StringFormat]
	--			,NULL , NULL, case when [IntegrityCheckRequired] = 1 then 128 end  
	--  FROM [EDGE_OLTP_OLD].[dbo].[Measure]

	--  set IDENTITY_INSERT [dbo].[Measure] off

--	INSERT INTO [dbo].[Goal]
--           ([ObjectType] ,[ObjectGK] ,[DateStart] ,[DateEnd] ,[MeasureID] ,[Value])
--		   -- 'Campaign', Campaign_gk , 01-01-1900, 01-01-1900, To fill, value

--SELECT  [AccountID]
--      ,[CampaignGK]
--      ,[AdgroupGK]
--      ,[SegmentID]
--      ,[Cost]
--      ,[CPA_new_users]
--      ,[CPA_new_activations]
--      ,[Conv]
--      ,[Activations]
--      ,[signups]
--      ,[New_Users]
--  FROM [EDGE_OLTP_OLD].[dbo].[User_GUI_CampaignTargets]

