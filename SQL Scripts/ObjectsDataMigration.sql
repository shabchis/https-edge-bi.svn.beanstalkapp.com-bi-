
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
	Select Channel_id, Display_Name,2
	From EDGE_OLTP_OLD.dbo.Constant_Channel 

-- Create Ad table (note creativeGK is the same as Ad gk in the migrated data)
	Insert into	[EdgeObjects].[dbo].[Ad] 
				([GK] ,[Name] ,[OriginalID] ,[AccountID] ,[ChannelID] ,[ObjectStatus] ,[DestinationUrl] ,[CreativeGK])
	Select	 [PPC_Creative_GK] , Headline, [creativeid], [Account_ID], [Channel_ID], [creativeStatus], [creativeDestUrl], [PPC_Creative_GK]
	From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdgroupCreative]
	Where Account_ID = 10035

-- ***************************************************************************************************************

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

	--Create campaigns table as EdgeObject