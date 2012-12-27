-- Declartions 
Declare @AccountID int

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
-- Basic assuption is that all text creatives are different (title and desc and DisplayURL)

-- Create title creative
	INSERT INTO [dbo].[Creative] 
				([GK] ,[TypeID], [AccountID]  
				,[int_Field1] ,string_Field1 )
	Select 1000000000 + [Creative_GK], 13 ,[Account_ID] 
				,1,[Creative_Title] 
	From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_Creative] 
	Where Account_ID = @AccountID 
	
-- Create description creative
	INSERT INTO [dbo].[Creative] 
				([GK] ,[TypeID], [AccountID]  
				,[int_Field1] ,string_Field1 )
	Select 2000000000 + [Creative_GK], 13 ,[Account_ID]
				,1, 
				Case when Len(Rtrim(LTrim(IsNull([Creative_Desc1],'') +' '+ IsNull([Creative_Desc2],'')))) =0 
					then NULL
					Else Rtrim(LTrim(IsNull([Creative_Desc1],'') +' '+ IsNull([Creative_Desc2],'')))
				End	 
	From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_Creative] 
	Where Account_ID = @AccountID --> 25423 Rows
		
-- Create display URL creative
	INSERT INTO [dbo].[Creative] 
				([GK] ,[TypeID], [AccountID] 
				,[int_Field1] ,string_Field1)
	Select 1000000000 + [PPC_Creative_GK], 13,[Account_ID] 
				,2, [creativeVisUrl]
	From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdgroupCreative] 
	Where Account_ID = @AccountID and creativeVisUrl <> 'OptionRally.com' -->7330 Rows

	INSERT INTO [dbo].[Creative] 
				([GK] ,[TypeID], [AccountID] 
				,[int_Field1] ,string_Field1)
	Values ( 1000000000 , 13, @AccountID ,2, 'OptionRally.com') --> 1

-- Create composite creative in creative table
	INSERT INTO [dbo].[Creative] 
				([GK] ,[TypeID], [AccountID])
	SELECT [PPC_Creative_GK]  ,16, [Account_ID]  
	FROM [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdgroupCreative]
	where account_id = @AccountID --> 25423 Rows

-- Create composite creative for titles
	INSERT INTO [dbo].[CreativeCompositePart]
				([AccountID], [CompositeCreativeGK] ,[PartTypeID],PartRole, [PartCreativeGK])
	Select distinct CR.[Account_ID], AGCR.[PPC_Creative_GK], 13 , 'Title' ,1000000000 + CR.[Creative_GK] 
	From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_Creative]  CR
		inner join [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdgroupCreative] AGCR
			on cr.Account_ID = AGCR.Account_ID and cr.Creative_GK = AGCR.Creative_GK
	Where CR.Account_ID = @AccountID --> 25423 Rows
	
-- Create composite creative for descriptions
	INSERT INTO [dbo].[CreativeCompositePart]
				([AccountID], [CompositeCreativeGK] ,[PartTypeID],PartRole, [PartCreativeGK])
	Select distinct CR.[Account_ID], AGCR.[PPC_Creative_GK],13 , 'Desc', 2000000000 + CR.[Creative_GK] 
	From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_Creative]  CR
		inner join [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdgroupCreative] AGCR
			on cr.Account_ID = AGCR.Account_ID and cr.Creative_GK = AGCR.Creative_GK
	Where CR.Account_ID = @AccountID --> 25423 Rows

	-- Create composite creative for display URLs
	INSERT INTO [dbo].[CreativeCompositePart]
				([AccountID], [CompositeCreativeGK] ,[PartTypeID],PartRole, [PartCreativeGK])
	Select distinct AGCR.[Account_ID], AGCR.[PPC_Creative_GK], 13 ,'DisplayURL', 1000000000 + [PPC_Creative_GK] 
	From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdgroupCreative] AGCR 
	Where AGCR.Account_ID = @AccountID and creativeVisUrl <> 'OptionRally.com' --> 7033 Rows

	INSERT INTO [dbo].[CreativeCompositePart]
				([AccountID], [CompositeCreativeGK] ,[PartTypeID],PartRole, [PartCreativeGK])
	Select distinct AGCR.[Account_ID], AGCR.[PPC_Creative_GK], 13, 'DisplayURL', 1000000000 
	From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdgroupCreative] AGCR 
	Where AGCR.Account_ID = @AccountID and creativeVisUrl = 'OptionRally.com' --> 18390 Rows

	-- Create Ad table (note creativeGK is the same as Ad gk in the migrated data)
	Insert into	[EdgeObjects].[dbo].[Ad] 
				([GK] ,[Name] ,[OriginalID] ,[AccountID] ,[ChannelID] ,[Status] ,[DestinationUrl] ,[CreativeGK])
	Select	 [PPC_Creative_GK] , Headline, [creativeid], [Account_ID], [Channel_ID], [creativeStatus], [creativeDestUrl], [PPC_Creative_GK]
	From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdgroupCreative]
	Where Account_ID = @AccountID -->25423 Rows
			
	INSERT INTO [dbo].[ObjectTracking] 
	           ([AccountID]  ,[ChannelID] ,[ObjectTable] ,[ObjectGK] ,[DeliveryOutputID])
     Select [Account_ID], [Channel_ID], 'Ad', [Campaign_GK] , 'Migration'
	 From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdgroupCreative] 
	 Where Account_ID = @AccountID 

--****************** Campaigns *****************************
	set IDENTITY_INSERT [dbo].[EdgeObject] on 
	INSERT INTO [dbo].[EdgeObject]
           ([GK], [TypeID] ,[AccountID] ,[ChannelID] ,[OriginalID]  ,[Status] ,[int_Field1] ,[string_Field1])
	Select  [Campaign_GK]  ,1 ,[Account_ID] ,[Channel_ID] ,[campaignid] , [campStatus], [ScheduleEnabled], [campaign]
	From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidCampaign]
	Where Account_ID = @AccountID
	set IDENTITY_INSERT [dbo].[EdgeObject]  off --> 189 Rows

	INSERT INTO [dbo].[ObjectTracking] 
	           ([AccountID]  ,[ChannelID] ,[ObjectTable] ,[ObjectGK] ,[DeliveryOutputID])
     Select [Account_ID], [Channel_ID], 'EdgeObject', [Campaign_GK] , 'Migration'
	 From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidCampaign] 

--****************** Adgroup *****************************
	set IDENTITY_INSERT [dbo].[EdgeObject] on 

	INSERT INTO [dbo].[EdgeObject]
           ([GK], [TypeID] ,[AccountID] ,[ChannelID] ,[OriginalID]  ,[Status] ,[string_Field1])
	Select  [Adgroup_GK], 6, [Account_ID], [Channel_ID], [adgroupID], [agStatus], [adgroup] 
    From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdGroup] AG 
	Where Account_ID = 10035

	set IDENTITY_INSERT [dbo].[EdgeObject]  off

	INSERT INTO [dbo].[ObjectTracking] 
	           ([AccountID]  ,[ChannelID] ,[ObjectTable] ,[ObjectGK] ,[DeliveryOutputID])
     Select [Account_ID], [Channel_ID], 'EdgeObject', [Adgroup_GK] , 'Migration' 
	 FROM [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdGroup]

-- Create Connection definition for adgroup
	 INSERT INTO [dbo].[ConnectionDefinition] ([Name] ,[AccountID] ,[ChannelID] , TypeID )
								select distinct 'Adgroup', [Account_ID], -1, 6
								 FROM [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdGroup]
	
-- Associate connection to each adgroup		
	 INSERT INTO [dbo].[Connection] ([AccountID] ,[FromTypeID] ,[FromGK] ,[ConnectionDefID] ,[ToTypeID] ,[ToGK]	)
								 Select 10035, ET.TypeID , Adgroup_gk , CD.ID, CD.TypeID, Campaign_GK 
								 From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdGroup] AG
									inner join [dbo].[EdgeType] ET
										on (AG.Account_ID = ET.AccountID OR ET.AccountID = -1) 
										and (AG.Channel_ID = ET.ChannelID OR ET.ChannelID = -1)
									inner join [dbo].[ConnectionDefinition] CD
										on (AG.Account_ID = CD.AccountID OR CD.AccountID = -1) 
										and (AG.Channel_ID = CD.ChannelID OR CD.ChannelID = -1)
								 Where  CD.Name = 'Campaign' and ET.Name = 'Adgroup'

-- ****************** Trackers *****************************
	 -- Create Connection definition for tracker
	  INSERT INTO [dbo].[ConnectionDefinition] ([Name] ,[AccountID] ,[ChannelID] , TypeID )
								select distinct 'Tracker', [Account_ID], -1,5
								 FROM [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_Gateway]			
	
	 --Create trackers as EdgeObject 
	set IDENTITY_INSERT [dbo].[EdgeObject] on 

	INSERT INTO [dbo].[EdgeObject]
			([GK], [TypeID] ,[AccountID] ,[ChannelID] ,[OriginalID] ,[string_Field1])
	Select distinct [Gateway_GK]  ,ET.TypeID ,[Account_ID] ,[Channel_ID] ,[Gateway_id] , [Gateway_id]
	from [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_Gateway] GTW 
		inner join [dbo].[EdgeType] ET
			on (GTW.Account_ID = ET.AccountID OR ET.AccountID = -1) 
			and (GTW.Channel_ID = ET.ChannelID OR ET.ChannelID = -1)
	Where ET.Name = 'Tracker'
	
	set IDENTITY_INSERT [dbo].[EdgeObject]  off

	INSERT INTO [dbo].[ObjectTracking] 
	           ([AccountID]  ,[ChannelID] ,[ObjectTable] ,[ObjectGK] ,[DeliveryOutputID])
     Select [Account_ID], [Channel_ID], 'EdgeObject', [Gateway_GK] , 'Migration' 
	 FROM [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_Gateway]

	 
--****************** Keyword target *****************************
		
	set IDENTITY_INSERT [dbo].[Target]  on

		INSERT INTO [dbo].[Target]
					([GK], [TypeID] ,[AccountID] ,[string_Field1])
	Select distinct Keyword_GK  ,ET.TypeID ,[Account_ID] , Keyword
	from [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_Keyword] GTW 
		inner join [dbo].[EdgeType] ET
			on (GTW.Account_ID = ET.AccountID OR ET.AccountID = -1) 
	Where ET.Name = 'Keyword'

	set IDENTITY_INSERT [dbo].[Target]  off
		
	INSERT INTO [dbo].[ObjectTracking] 
	           ([AccountID]  ,[ChannelID] ,[ObjectTable] ,[ObjectGK] ,[DeliveryOutputID])
     Select [Account_ID], NULL, 'Target', [Keyword_GK] , 'Migration' 
	 FROM [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_Keyword]


-- No Content data for @AccountID

	set IDENTITY_INSERT [dbo].[TargetDefinition]  on

	INSERT INTO [dbo].[TargetDefinition]
		([GK] ,[TypeID], [ObjectTypeID] ,[ObjectGK]   ,[TargetTypeID] ,[TargetGK] ,
			[AccountID], [ChannelID] ,[DestinationUrl] ,[int_Field1])
	Select distinct Convert(bigint,Convert(nvarchar(15),kw.PPC_Keyword_GK) + Convert(nvarchar(15),fact.ppc_creative_gk))
		 ,20 , 2 /*ADTypeID*/, fact.ppc_creative_gk , 4 /*KeywordTypeID*/,kw.Keyword_GK,
			kw.Account_ID, kw.Channel_ID, kw.kwDestUrl , kw.MatchType 
	From [EDGE_OLTP_OLD].[dbo].UserProcess_GUI_PaidAdgroupKeyword kw
		inner join [EDGE_OLTP_OLD].[dbo].[Paid_API_AllColumns_v29] fact
			on fact.Account_ID = kw.Account_ID and fact.PPC_Keyword_GK = kw.PPC_Keyword_GK 
	Where kw.Account_ID = 10035

	set IDENTITY_INSERT [dbo].[TargetDefinition]  off
				
	 INSERT INTO [dbo].[ObjectTracking] 
			   ([AccountID]  ,[ObjectTable] ,[ObjectGK] ,[DeliveryOutputID])
		Select [AccountID], 'ADTargetDefinition', [GK] , 'Migration' 
	 From [AdTargetDefinition]
-- **************************************************************************
		
	INSERT INTO [dbo].[AdTargetMatch]
				(GK, ADgk, TargetGK, [AdTargetDefinitionGK], [AccountID] ,[Name] ,[DestinationUrl], [int_Field1] /*PropertyID*/)
	Select distinct kw.PPC_Keyword_GK , fact.ppc_creative_gk , kw.Keyword_GK,  kw.PPC_Keyword_GK , kw.Account_ID, NULL, fact.destUrl ,11 /*PropertyID*/
	From [EDGE_OLTP_OLD].[dbo].UserProcess_GUI_PaidAdgroupKeyword kw
		inner join [EDGE_OLTP_OLD].[dbo].[Paid_API_AllColumns_v29] fact
			on fact.Account_ID = kw.Account_ID and fact.PPC_Keyword_GK = kw.PPC_Keyword_GK 

	set IDENTITY_INSERT [dbo].[TargetMatch]  on

	INSERT INTO [dbo].[TargetMatch]
		([GK] ,[TypeID], [ObjectTypeID] ,[ObjectGK]   ,[TargetTypeID] ,[TargetGK] ,TargetDefinitionTypeID,TargetDefinitionGK,
			[AccountID], [ChannelID] ,[DestinationUrl], [int_Field1] )
	Select distinct Convert(bigint,Convert(nvarchar(15),kw.PPC_Keyword_GK) + Convert(nvarchar(15),fact.ppc_creative_gk))
		 ,21 , 2 /*ADTypeID*/, fact.ppc_creative_gk , 4 /*KeywordTypeID*/,kw.Keyword_GK,
		 20 , Convert(bigint,Convert(nvarchar(15),kw.PPC_Keyword_GK) + Convert(nvarchar(15),fact.ppc_creative_gk)),
			kw.Account_ID, kw.Channel_ID, kw.kwDestUrl , kw.MatchType 
	From [EDGE_OLTP_OLD].[dbo].UserProcess_GUI_PaidAdgroupKeyword kw
		inner join [EDGE_OLTP_OLD].[dbo].[Paid_API_AllColumns_v29] fact
			on fact.Account_ID = kw.Account_ID and fact.PPC_Keyword_GK = kw.PPC_Keyword_GK 
	Where kw.Account_ID = 10035

	set IDENTITY_INSERT [dbo].[TargetMatch]  off

	 INSERT INTO [dbo].[ObjectTracking] 
			   ([AccountID]  ,[ObjectTable] ,[ObjectGK] ,[DeliveryOutputID])
		Select [AccountID], 'ADTargetDefinition', [GK] , 'Migration' 
	 From [AdTargetDefinition]


--****************** Segments *****************************
-- Import Theme data				
-- Create Connection definition for theme segment
	  INSERT INTO [dbo].[ConnectionDefinition] ([Name] ,[AccountID] ,[ChannelID] , TypeID )
								select 'Theme', -1, -1, 7

	set IDENTITY_INSERT [dbo].[EdgeObject] on 

	INSERT INTO [dbo].[EdgeObject]
						([GK], [TypeID] ,[AccountID]  ,[string_Field1])
	Select distinct [ValueID]  ,ET.TypeID ,SEG.[AccountID]  , [Value]
	from [EDGE_OLTP_OLD].[dbo].[SegmentValue] SEG 
		inner join [dbo].[EdgeType] ET
			on (SEG.AccountID = ET.AccountID OR ET.AccountID = -1) 
	Where SEG.AccountID in (10035,-1) AND ET.Name = 'Theme' AND SegmentID = 3 /* theme */

	set IDENTITY_INSERT [dbo].[EdgeObject]  off

-- insertion of all segments
	INSERT INTO [dbo].[ObjectTracking] 
	           ([AccountID]  ,[ChannelID] ,[ObjectTable] ,[ObjectGK] ,[DeliveryOutputID])
     Select [AccountID], NULL, 'EdgeObject', [ValueID] , 'Migration' 
	 FROM [EDGE_OLTP_OLD].[dbo].[SegmentValue]

-- Import Language segment data				
		  INSERT INTO [dbo].[ConnectionDefinition] ([Name] ,[AccountID] ,[ChannelID] , TypeID )
								select 'Language', -1, -1, 8
								
	set IDENTITY_INSERT [dbo].[EdgeObject] on 

	INSERT INTO [dbo].[EdgeObject]
						([GK], [TypeID] ,[AccountID]  ,[string_Field1])
	Select distinct [ValueID]  ,ET.TypeID ,SEG.[AccountID]  , [Value]
	from [EDGE_OLTP_OLD].[dbo].[SegmentValue] SEG 
		inner join [dbo].[EdgeType] ET
			on (SEG.AccountID = ET.AccountID OR ET.AccountID = -1) 
	Where SEG.AccountID in ( 10035, -1) AND ET.Name = 'Language' AND SegmentID = 1 /* Language */

	set IDENTITY_INSERT [dbo].[EdgeObject]  off

-- Import Geographic segment data				
	INSERT INTO [dbo].[ConnectionDefinition] ([Name] ,[AccountID] ,[ChannelID] , TypeID )
								select 'Geographic', -1, -1, 9
								
	set IDENTITY_INSERT [dbo].[EdgeObject] on 

	INSERT INTO [dbo].[EdgeObject]
						([GK], [TypeID] ,[AccountID]  ,[string_Field1])
	Select distinct [ValueID]  ,ET.TypeID ,SEG.[AccountID]  , [Value]
	from [EDGE_OLTP_OLD].[dbo].[SegmentValue] SEG 
		inner join [dbo].[EdgeType] ET
			on (SEG.AccountID = ET.AccountID OR ET.AccountID = -1) 
	Where SEG.AccountID in ( 10035, -1) AND ET.Name = 'Geographic' AND SegmentID = 2 /* Geo */

	set IDENTITY_INSERT [dbo].[EdgeObject]  off
	
-- Import Country segment data				
	INSERT INTO [dbo].[ConnectionDefinition] ([Name] ,[AccountID] ,[ChannelID] , TypeID )
								select 'Country', -1, -1, 10
								
	set IDENTITY_INSERT [dbo].[EdgeObject] on 

	INSERT INTO [dbo].[EdgeObject]
						([GK], [TypeID] ,[AccountID]  ,[string_Field1])
	Select distinct [ValueID]  ,ET.TypeID ,SEG.[AccountID]  , [Value]
	from [EDGE_OLTP_OLD].[dbo].[SegmentValue] SEG 
		inner join [dbo].[EdgeType] ET
			on (SEG.AccountID = ET.AccountID OR ET.AccountID = -1) 
	Where SEG.AccountID in ( 10035, -1) AND ET.Name = 'Country' AND SegmentID = 4 /* Country */

	set IDENTITY_INSERT [dbo].[EdgeObject]  off
		
		
-- Import Country segment data				
	INSERT INTO [dbo].[ConnectionDefinition] ([Name] ,[AccountID] ,[ChannelID] , TypeID )
								select 'USP', -1, -1, 11
								
	set IDENTITY_INSERT [dbo].[EdgeObject] on 

	INSERT INTO [dbo].[EdgeObject]
						([GK], [TypeID] ,[AccountID]  ,[string_Field1])
	Select distinct [ValueID]  ,ET.TypeID ,SEG.[AccountID]  , [Value]
	from [EDGE_OLTP_OLD].[dbo].[SegmentValue] SEG 
		inner join [dbo].[EdgeType] ET
			on (SEG.AccountID = ET.AccountID OR ET.AccountID = -1) 
	Where SEG.AccountID in ( 10035, -1) AND ET.Name = 'USP' AND SegmentID = 5 /* USP */

	set IDENTITY_INSERT [dbo].[EdgeObject]  off

-- Import page segment data				
	INSERT INTO [dbo].[ConnectionDefinition] ([Name] ,[AccountID] ,[ChannelID] , TypeID )
								select 'LandingPage', -1, -1, 18

	set IDENTITY_INSERT [dbo].[EdgeObject] on 

	INSERT INTO [dbo].[EdgeObject] 
			([GK], [TypeID] ,[AccountID]  ,[string_Field1])
	SELECT  100000+ Page_gk, ET.TypeID ,[Account_ID], [Title]
		 FROM [EDGE_OLTP_OLD].[dbo].UserProcess_GUI_Page P
		inner join [dbo].[EdgeType] ET
			on (P.Account_ID = ET.AccountID OR ET.AccountID = -1) 
	Where P.Account_ID in ( 10035, -1) AND ET.Name = 'LandingPage' 

	set IDENTITY_INSERT [dbo].[EdgeObject]  off

-- *************************** Ad Connections ***********************************************
-- Connect ad to campaign	
 INSERT INTO [dbo].[Connection] ([AccountID] ,[FromTypeID] ,[FromGK] ,[ConnectionDefID] ,[ToTypeID] ,[ToGK]	)
								 Select distinct 10035, ET.TypeID , PPC_Creative_GK , CD.ID, CD.TypeID, Campaign_GK 
								 From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdgroupCreative] AG
									inner join [dbo].[EdgeType] ET
										on (AG.Account_ID = ET.AccountID OR ET.AccountID = -1) 
										and (AG.Channel_ID = ET.ChannelID OR ET.ChannelID = -1)
									inner join [dbo].[ConnectionDefinition] CD
										on (AG.Account_ID = CD.AccountID OR CD.AccountID = -1) 
										and (AG.Channel_ID = CD.ChannelID OR CD.ChannelID = -1)
								 Where  CD.Name = 'Campaign' and ET.Name = 'Ad'  and ag.Account_ID = 10035

-- Connect ad to adgroup
 INSERT INTO [dbo].[Connection] ([AccountID] ,[FromTypeID] ,[FromGK] ,[ConnectionDefID] ,[ToTypeID] ,[ToGK]	)
								 Select distinct 10035, ET.TypeID , PPC_Creative_GK , CD.ID, CD.TypeID, AdGroup_GK 
								 From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdgroupCreative] AG
									inner join [dbo].[EdgeType] ET
										on (AG.Account_ID = ET.AccountID OR ET.AccountID = -1) 
										and (AG.Channel_ID = ET.ChannelID OR ET.ChannelID = -1)
									inner join [dbo].[ConnectionDefinition] CD
										on (AG.Account_ID = CD.AccountID OR CD.AccountID = -1) 
										and (AG.Channel_ID = CD.ChannelID OR CD.ChannelID = -1)
								 Where  CD.Name = 'Adgroup' and ET.Name = 'Ad' and ag.Account_ID = 10035
							
								
-- Connect ad to tracker	
 INSERT INTO [dbo].[Connection] ([AccountID] ,[FromTypeID] ,[FromGK] ,[ConnectionDefID] ,[ToTypeID] ,[ToGK]	)
								Select distinct 10035, ET.TypeID , PPC_Creative_GK , CD.ID, CD.TypeID, GTW.Gateway_GK 
								from [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdgroupCreative] AG
									inner join [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_Gateway] GTW
									on substring(creativeDestUrl,charindex('&p=edgetrackerid_',creativeDestUrl) + 17,99) = gtw.Gateway_id collate SQL_Latin1_General_CP1_CI_AS
									and  (AG.Account_ID = GTW.Account_ID ) and (AG.Channel_ID = GTW.Channel_ID )
									inner join [dbo].[EdgeType] ET
										on (AG.Account_ID = ET.AccountID OR ET.AccountID = -1) 
										and (AG.Channel_ID = ET.ChannelID OR ET.ChannelID = -1)
									inner join [dbo].[ConnectionDefinition] CD
										on (AG.Account_ID = CD.AccountID OR CD.AccountID = -1) 
										and (AG.Channel_ID = CD.ChannelID OR CD.ChannelID = -1)
								 Where  CD.Name = 'Tracker'/*To*/ and ET.Name = 'Ad'/*From*/
									and PPC_Creative_GK <> 700402599 -- the double tracker
									and ag.Account_ID = 10035

-- Connect ad to language segment
 INSERT INTO [dbo].[Connection] ([AccountID] ,[FromTypeID] ,[FromGK] ,[ConnectionDefID] ,[ToTypeID] ,[ToGK]	)
								 Select distinct 10035, ET.TypeID , PPC_Creative_GK , CD.ID, CD.TypeID, Segment1 
								 From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdgroupCreative] AG
									inner join [dbo].[EdgeType] ET
										on (AG.Account_ID = ET.AccountID OR ET.AccountID = -1) 
										and (AG.Channel_ID = ET.ChannelID OR ET.ChannelID = -1)
									inner join [dbo].[ConnectionDefinition] CD
										on (AG.Account_ID = CD.AccountID OR CD.AccountID = -1) 
										and (AG.Channel_ID = CD.ChannelID OR CD.ChannelID = -1)
								 Where  CD.Name = 'Language'/*To*/ and ET.Name = 'Ad'/*From*/ and ag.Account_ID = 10035
								 and Segment1 is not null and Segment1 != -1
-- Connect ad to Geographic segment

 INSERT INTO [dbo].[Connection] ([AccountID] ,[FromTypeID] ,[FromGK] ,[ConnectionDefID] ,[ToTypeID] ,[ToGK]	)
								 Select distinct 10035, ET.TypeID , PPC_Creative_GK , CD.ID, CD.TypeID, Segment2 
								 From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdgroupCreative] AG
									inner join [dbo].[EdgeType] ET
										on (AG.Account_ID = ET.AccountID OR ET.AccountID = -1) 
										and (AG.Channel_ID = ET.ChannelID OR ET.ChannelID = -1)
									inner join [dbo].[ConnectionDefinition] CD
										on (AG.Account_ID = CD.AccountID OR CD.AccountID = -1) 
										and (AG.Channel_ID = CD.ChannelID OR CD.ChannelID = -1)
								 Where  CD.Name = 'Geographic'/*To*/ and ET.Name = 'Ad'/*From*/ and ag.Account_ID = 10035
								  and Segment2 is not null and Segment2 != -1

-- Connect ad to theme segment
			 INSERT INTO [dbo].[Connection] ([AccountID] ,[FromTypeID] ,[FromGK] ,[ConnectionDefID] ,[ToTypeID] ,[ToGK]	)
								 Select distinct 10035, ET.TypeID , PPC_Creative_GK , CD.ID, CD.TypeID, Segment3 
								 From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdgroupCreative] AG
									inner join [dbo].[EdgeType] ET
										on (AG.Account_ID = ET.AccountID OR ET.AccountID = -1) 
										and (AG.Channel_ID = ET.ChannelID OR ET.ChannelID = -1)
									inner join [dbo].[ConnectionDefinition] CD
										on (AG.Account_ID = CD.AccountID OR CD.AccountID = -1) 
										and (AG.Channel_ID = CD.ChannelID OR CD.ChannelID = -1)
								 Where  CD.Name = 'Theme'/*To*/ and ET.Name = 'Ad'/*From*/ and ag.Account_ID = 10035
								  and Segment3 is not null and Segment3 != -1

-- Connect ad to country segment 
	INSERT INTO [dbo].[Connection] ([AccountID] ,[FromTypeID] ,[FromGK] ,[ConnectionDefID] ,[ToTypeID] ,[ToGK]	)
								 Select distinct 10035, ET.TypeID , PPC_Creative_GK , CD.ID, CD.TypeID, Segment4 
								 From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdgroupCreative] AG
									inner join [dbo].[EdgeType] ET
										on (AG.Account_ID = ET.AccountID OR ET.AccountID = -1) 
										and (AG.Channel_ID = ET.ChannelID OR ET.ChannelID = -1)
									inner join [dbo].[ConnectionDefinition] CD
										on (AG.Account_ID = CD.AccountID OR CD.AccountID = -1) 
										and (AG.Channel_ID = CD.ChannelID OR CD.ChannelID = -1)
								 Where  CD.Name = 'Country'/*To*/ and ET.Name = 'Ad'/*From*/ and ag.Account_ID = 10035
								  and Segment4 is not null and Segment4 != -1

-- Connect ad to USP segment

			INSERT INTO [dbo].[Connection] ([AccountID] ,[FromTypeID] ,[FromGK] ,[ConnectionDefID] ,[ToTypeID] ,[ToGK]	)
								 Select distinct 10035, ET.TypeID , PPC_Creative_GK , CD.ID, CD.TypeID, Segment5 
								 From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdgroupCreative] AG
									inner join [dbo].[EdgeType] ET
										on (AG.Account_ID = ET.AccountID OR ET.AccountID = -1) 
										and (AG.Channel_ID = ET.ChannelID OR ET.ChannelID = -1)
									inner join [dbo].[ConnectionDefinition] CD
										on (AG.Account_ID = CD.AccountID OR CD.AccountID = -1) 
										and (AG.Channel_ID = CD.ChannelID OR CD.ChannelID = -1)
								 Where  CD.Name = 'USP'/*To*/ and ET.Name = 'Ad'/*From*/ and ag.Account_ID = 10035
								  and Segment5 is not null and Segment5 != -1

-- Connect ad to landing page 
			INSERT INTO [dbo].[Connection] ([AccountID] ,[FromTypeID] ,[FromGK] ,[ConnectionDefID] ,[ToTypeID] ,[ToGK]	)
								 Select distinct 10035, ET.TypeID , PPC_Creative_GK , CD.ID, CD.TypeID,  100000+ Page_gk  
								 From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdgroupCreative] AG
									inner join [dbo].[EdgeType] ET
										on (AG.Account_ID = ET.AccountID OR ET.AccountID = -1) 
										and (AG.Channel_ID = ET.ChannelID OR ET.ChannelID = -1)
									inner join [dbo].[ConnectionDefinition] CD
										on (AG.Account_ID = CD.AccountID OR CD.AccountID = -1) 
										and (AG.Channel_ID = CD.ChannelID OR CD.ChannelID = -1)
								 Where  CD.Name = 'LandingPage'/*To*/ and ET.Name = 'Ad'/*From*/ and ag.Account_ID = 10035
								  and Page_gk is not null and Page_gk != -1
		
-- *************************** Campaign Connections ***********************************************

-- Connect campaign to language segment
			INSERT INTO [dbo].[Connection] ([AccountID] ,[FromTypeID] ,[FromGK] ,[ConnectionDefID] ,[ToTypeID] ,[ToGK]	)
								 Select distinct 10035, ET.TypeID , Campaign_GK , CD.ID, CD.TypeID,  Segment1  
								 From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidCampaign] AG
									inner join [dbo].[EdgeType] ET
										on (AG.Account_ID = ET.AccountID OR ET.AccountID = -1) 
										and (AG.Channel_ID = ET.ChannelID OR ET.ChannelID = -1)
									inner join [dbo].[ConnectionDefinition] CD
										on (AG.Account_ID = CD.AccountID OR CD.AccountID = -1) 
										and (AG.Channel_ID = CD.ChannelID OR CD.ChannelID = -1)
								 Where  CD.Name = 'Language'/*To*/ and ET.Name = 'Campaign'/*From*/ and ag.Account_ID = 10035
								  and Segment1 is not null and Segment1 != -1

-- Connect campaign to geographic segment
	
			INSERT INTO [dbo].[Connection] ([AccountID] ,[FromTypeID] ,[FromGK] ,[ConnectionDefID] ,[ToTypeID] ,[ToGK]	)
								 Select distinct 10035, ET.TypeID , Campaign_GK , CD.ID, CD.TypeID,  Segment2  
								 From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidCampaign] AG
									inner join [dbo].[EdgeType] ET
										on (AG.Account_ID = ET.AccountID OR ET.AccountID = -1) 
										and (AG.Channel_ID = ET.ChannelID OR ET.ChannelID = -1)
									inner join [dbo].[ConnectionDefinition] CD
										on (AG.Account_ID = CD.AccountID OR CD.AccountID = -1) 
										and (AG.Channel_ID = CD.ChannelID OR CD.ChannelID = -1)
								 Where  CD.Name = 'Geographic'/*To*/ and ET.Name = 'Campaign'/*From*/ and ag.Account_ID = 10035
								  and Segment2 is not null and Segment2 != -1 

-- Connect campaign to theme segment
				INSERT INTO [dbo].[Connection] ([AccountID] ,[FromTypeID] ,[FromGK] ,[ConnectionDefID] ,[ToTypeID] ,[ToGK]	)
								 Select distinct 10035, ET.TypeID , Campaign_GK , CD.ID, CD.TypeID,  Segment3  
								 From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidCampaign] AG
									inner join [dbo].[EdgeType] ET
										on (AG.Account_ID = ET.AccountID OR ET.AccountID = -1) 
										and (AG.Channel_ID = ET.ChannelID OR ET.ChannelID = -1)
									inner join [dbo].[ConnectionDefinition] CD
										on (AG.Account_ID = CD.AccountID OR CD.AccountID = -1) 
										and (AG.Channel_ID = CD.ChannelID OR CD.ChannelID = -1)
								 Where  CD.Name = 'Theme'/*To*/ and ET.Name = 'Campaign'/*From*/ and ag.Account_ID = 10035
								  and Segment3 is not null and Segment3 != -1 

-- Connect campaign to country segment
	INSERT INTO [dbo].[Connection] ([AccountID] ,[FromTypeID] ,[FromGK] ,[ConnectionDefID] ,[ToTypeID] ,[ToGK]	)
								 Select distinct 10035, ET.TypeID , Campaign_GK , CD.ID, CD.TypeID,  Segment4  
								 From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidCampaign] AG
									inner join [dbo].[EdgeType] ET
										on (AG.Account_ID = ET.AccountID OR ET.AccountID = -1) 
										and (AG.Channel_ID = ET.ChannelID OR ET.ChannelID = -1)
									inner join [dbo].[ConnectionDefinition] CD
										on (AG.Account_ID = CD.AccountID OR CD.AccountID = -1) 
										and (AG.Channel_ID = CD.ChannelID OR CD.ChannelID = -1)
								 Where  CD.Name = 'Country'/*To*/ and ET.Name = 'Campaign'/*From*/ and ag.Account_ID = 10035
								  and Segment4 is not null and Segment4 != -1 

-- Connect campaign to USP segment
	
			INSERT INTO [dbo].[Connection] ([AccountID] ,[FromTypeID] ,[FromGK] ,[ConnectionDefID] ,[ToTypeID] ,[ToGK]	)
								 Select distinct 10035, ET.TypeID , Campaign_GK , CD.ID, CD.TypeID,  Segment5  
								 From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidCampaign] AG
									inner join [dbo].[EdgeType] ET
										on (AG.Account_ID = ET.AccountID OR ET.AccountID = -1) 
										and (AG.Channel_ID = ET.ChannelID OR ET.ChannelID = -1)
									inner join [dbo].[ConnectionDefinition] CD
										on (AG.Account_ID = CD.AccountID OR CD.AccountID = -1) 
										and (AG.Channel_ID = CD.ChannelID OR CD.ChannelID = -1)
								 Where  CD.Name = 'USP'/*To*/ and ET.Name = 'Campaign'/*From*/ and ag.Account_ID = 10035
								  and Segment5 is not null and Segment5 != -1 


-- *************************** Tracker Connections ***********************************************
-- Connect tracker to language segment
		INSERT INTO [dbo].[Connection] ([AccountID] ,[FromTypeID] ,[FromGK] ,[ConnectionDefID] ,[ToTypeID] ,[ToGK]	)
								 Select distinct 10035, ET.TypeID , Gateway_GK , CD.ID, CD.TypeID,  Segment1 
								 From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_Gateway] AG
									inner join [dbo].[EdgeType] ET
										on (AG.Account_ID = ET.AccountID OR ET.AccountID = -1) 
										and (AG.Channel_ID = ET.ChannelID OR ET.ChannelID = -1)
									inner join [dbo].[ConnectionDefinition] CD
										on (AG.Account_ID = CD.AccountID OR CD.AccountID = -1) 
										and (AG.Channel_ID = CD.ChannelID OR CD.ChannelID = -1)
								 Where  CD.Name = 'Language'/*To*/ and ET.Name = 'Tracker'/*From*/ and ag.Account_ID = 10035
								  and Segment1 is not null and Segment1 != -1 and ag.account_id = 10035

			
-- Connect tracker to geographic segment
			INSERT INTO [dbo].[Connection] ([AccountID] ,[FromTypeID] ,[FromGK] ,[ConnectionDefID] ,[ToTypeID] ,[ToGK]	)
								 Select distinct 10035, ET.TypeID , Gateway_GK , CD.ID, CD.TypeID,  Segment2 
								 From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_Gateway] AG
									inner join [dbo].[EdgeType] ET
										on (AG.Account_ID = ET.AccountID OR ET.AccountID = -1) 
										and (AG.Channel_ID = ET.ChannelID OR ET.ChannelID = -1)
									inner join [dbo].[ConnectionDefinition] CD
										on (AG.Account_ID = CD.AccountID OR CD.AccountID = -1) 
										and (AG.Channel_ID = CD.ChannelID OR CD.ChannelID = -1)
								 Where  CD.Name = 'Geographic'/*To*/ and ET.Name = 'Tracker'/*From*/ and ag.Account_ID = 10035
								  and Segment2 is not null and Segment2 != -1 and ag.account_id = 10035

-- Connect tracker to theme segment
	INSERT INTO [dbo].[Connection] ([FromObjectType] ,[FromObjectGK] ,[ConnectionDefID] ,[ToObjectType] ,[ToObjectGK])					
			Select 'Tracker', Gateway_GK , MP.ID, 'Theme', Segment3 
			From [EDGE_OLTP_OLD].[dbo].UserProcess_GUI_Gateway CA
			inner join [dbo].[ConnectionDefinition] MP
				on (CA.Account_ID = MP.AccountID Or MP.AccountID = -1) and (CA.Channel_ID = MP.ChannelID Or MP.ChannelID = -1)
			Where  MP.Name = 'Theme' and CA.Account_ID = 10035 and CA.Segment3 is not null and CA.Segment3 != -1

				INSERT INTO [dbo].[Connection] ([AccountID] ,[FromTypeID] ,[FromGK] ,[ConnectionDefID] ,[ToTypeID] ,[ToGK]	)
								 Select distinct 10035, ET.TypeID , Gateway_GK , CD.ID, CD.TypeID,  Segment3 
								 From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_Gateway] AG
									inner join [dbo].[EdgeType] ET
										on (AG.Account_ID = ET.AccountID OR ET.AccountID = -1) 
										and (AG.Channel_ID = ET.ChannelID OR ET.ChannelID = -1)
									inner join [dbo].[ConnectionDefinition] CD
										on (AG.Account_ID = CD.AccountID OR CD.AccountID = -1) 
										and (AG.Channel_ID = CD.ChannelID OR CD.ChannelID = -1)
								 Where  CD.Name = 'Theme'/*To*/ and ET.Name = 'Tracker'/*From*/ and ag.Account_ID = 10035
								  and Segment3 is not null and Segment3 != -1 and ag.account_id = 10035
						
-- Connect tracker to country segment		
		INSERT INTO [dbo].[Connection] ([AccountID] ,[FromTypeID] ,[FromGK] ,[ConnectionDefID] ,[ToTypeID] ,[ToGK]	)
								 Select distinct 10035, ET.TypeID , Gateway_GK , CD.ID, CD.TypeID,  Segment4 
								 From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_Gateway] AG
									inner join [dbo].[EdgeType] ET
										on (AG.Account_ID = ET.AccountID OR ET.AccountID = -1) 
										and (AG.Channel_ID = ET.ChannelID OR ET.ChannelID = -1)
									inner join [dbo].[ConnectionDefinition] CD
										on (AG.Account_ID = CD.AccountID OR CD.AccountID = -1) 
										and (AG.Channel_ID = CD.ChannelID OR CD.ChannelID = -1)
								 Where  CD.Name = 'Country'/*To*/ and ET.Name = 'Tracker'/*From*/ and ag.Account_ID = 10035
								  and Segment4 is not null and Segment4 != -1 and ag.account_id = 10035
					

-- Connect tracker to USP segment
	INSERT INTO [dbo].[Connection] ([AccountID] ,[FromTypeID] ,[FromGK] ,[ConnectionDefID] ,[ToTypeID] ,[ToGK]	)
								 Select distinct 10035, ET.TypeID , Gateway_GK , CD.ID, CD.TypeID,  Segment5  
								 From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_Gateway] AG
									inner join [dbo].[EdgeType] ET
										on (AG.Account_ID = ET.AccountID OR ET.AccountID = -1) 
										and (AG.Channel_ID = ET.ChannelID OR ET.ChannelID = -1)
									inner join [dbo].[ConnectionDefinition] CD
										on (AG.Account_ID = CD.AccountID OR CD.AccountID = -1) 
										and (AG.Channel_ID = CD.ChannelID OR CD.ChannelID = -1)
								 Where  CD.Name = 'USP'/*To*/ and ET.Name = 'Tracker'/*From*/ and ag.Account_ID = 10035
								  and Segment5 is not null and Segment5 != -1 

-- Connect tracker to landing page 
				INSERT INTO [dbo].[Connection] ([AccountID] ,[FromTypeID] ,[FromGK] ,[ConnectionDefID] ,[ToTypeID] ,[ToGK]	)
								 Select distinct 10035, ET.TypeID , Gateway_GK , CD.ID, CD.TypeID,   100000+ Page_gk  
								 From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_Gateway] AG
									inner join [dbo].[EdgeType] ET
										on (AG.Account_ID = ET.AccountID OR ET.AccountID = -1) 
										and (AG.Channel_ID = ET.ChannelID OR ET.ChannelID = -1)
									inner join [dbo].[ConnectionDefinition] CD
										on (AG.Account_ID = CD.AccountID OR CD.AccountID = -1) 
										and (AG.Channel_ID = CD.ChannelID OR CD.ChannelID = -1)
								 Where  CD.Name = 'LandingPage'/*To*/ and ET.Name = 'Tracker'/*From*/ and ag.Account_ID = 10035
								  and Page_GK is not null and Page_GK != -1 and ag.account_id = 10035
				

-- ************* Measures and Goals ******************************************

	set IDENTITY_INSERT [dbo].[Measure] on
	INSERT INTO [dbo].[Measure]
	           ([ID], [Name] ,[MeasureDataType] ,[ChannelID] ,[AccountID] ,[DisplayName] ,[StringFormat] 
				,[InheritedByDefault] ,[OptionsOverride] ,[Options])
	SELECT M.[MeasureID], M.[Name] , 1 , BM.[ChannelID], M.[AccountID] , M.[DisplayName], BM.[StringFormat]
				,NULL , NULL, case when BM.[IntegrityCheckRequired] = 1 then 128 end  
	  FROM [EDGE_OLTP_OLD].[dbo].[Measure] M inner join [EDGE_OLTP_OLD].[dbo].[Measure] BM
		on BM.MeasureID = M.BaseMeasureID
	  where M.AccountID != -1 and M.BaseMeasureID is not null and BM.IsBO = 1

	  set IDENTITY_INSERT [dbo].[Measure] off

	  
-- ########################################################
-- Migration till here, the Objecttracking not yet inserted 
-- ########################################################	

	INSERT INTO [dbo].[Goal]
           ([ObjectTypeID] ,AccountID, ChannelID, [ObjectGK] ,[DateStart] ,[DateEnd] ,[MeasureID] ,[Value])
		   SELECT distinct ET.TypeID, AG.AccountID, -1, Campaigngk , '1900-01-01 00:00:00','1900-01-01 00:00:00' ,212, [CPA_new_users]
		  FROM [EDGE_OLTP_OLD].[dbo].[User_GUI_CampaignTargets] AG
		   inner join [dbo].[EdgeType] ET
				on (AG.AccountID = ET.AccountID OR ET.AccountID = -1) 					
		   WHERE [CPA_new_users] is null and AG.accountid = 10035

	INSERT INTO [dbo].[Goal]
			([ObjectTypeID] ,AccountID, ChannelID, [ObjectGK] ,[DateStart] ,[DateEnd] ,[MeasureID] ,[Value])
		   SELECT distinct ET.TypeID, AG.AccountID, -1, Campaigngk , '1900-01-01 00:00:00','1900-01-01 00:00:00' ,213, [CPA_new_activations]
		  FROM [EDGE_OLTP_OLD].[dbo].[User_GUI_CampaignTargets] AG
		   inner join [dbo].[EdgeType] ET
				on (AG.AccountID = ET.AccountID OR ET.AccountID = -1) 					
		 WHERE [CPA_new_activations] is not null and AG.accountid = 10035 

-- all the campaigns has 100 as a goal for measure 212	except for those which has a specific goal 		 
			INSERT INTO [dbo].[Goal]
			([ObjectTypeID] ,AccountID, ChannelID, [ObjectGK] ,[DateStart] ,[DateEnd] ,[MeasureID] ,[Value])
		   SELECT distinct ET.TypeID, AG.AccountID, -1, gk , '1900-01-01 00:00:00','1900-01-01 00:00:00' ,212, 100
		  FROM [EdgeObjects].[dbo].[EdgeObject] AG
		   inner join [dbo].[EdgeType] ET
				on (AG.AccountID = ET.AccountID OR ET.AccountID = -1) 					
		 WHERE AG.TypeID = 1 and AG.accountid = 10035 
			AND AG.GK not in ( select Campaigngk from [EDGE_OLTP_OLD].[dbo].[User_GUI_CampaignTargets]  WHERE [CPA_new_users] is null and AccountID = 10035 )


-- all the campaigns has 500 as a goal for measure 213 except for those which has a specific goal 	
			INSERT INTO [dbo].[Goal]
			([ObjectTypeID] ,AccountID, ChannelID, [ObjectGK] ,[DateStart] ,[DateEnd] ,[MeasureID] ,[Value])
		   SELECT distinct ET.TypeID, AG.AccountID, -1, gk , '1900-01-01 00:00:00','1900-01-01 00:00:00' ,213, 500
		  FROM [EdgeObjects].[dbo].[EdgeObject] AG
		   inner join [dbo].[EdgeType] ET
				on (AG.AccountID = ET.AccountID OR ET.AccountID = -1) 					
		 WHERE AG.TypeID = 1 and AG.accountid = 10035 
			AND AG.GK not in ( select Campaigngk from [EDGE_OLTP_OLD].[dbo].[User_GUI_CampaignTargets]  WHERE [CPA_new_activations] is not null and AG.accountid = 10035 )

		 