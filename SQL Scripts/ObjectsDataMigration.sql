
--To do: Need to filter the migration data by account as an option


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

-- create Ad table (no creativeGK yet)

  Insert into [EdgeObjects].[dbo].[Ad] ([GK] ,[Name] ,[OriginalID] ,[AccountID] ,[ChannelID] ,[ObjectStatus] ,[DestinationUrl] ,[CreativeGK])
  Select [PPC_Creative_GK] , Headline, [creativeid], [Account_ID], [Channel_ID], [creativeStatus], [creativeDestUrl], NULL
  From [EDGE_OLTP_OLD].[dbo].[UserProcess_GUI_PaidAdgroupCreative]
  Where Account_ID = 10035


