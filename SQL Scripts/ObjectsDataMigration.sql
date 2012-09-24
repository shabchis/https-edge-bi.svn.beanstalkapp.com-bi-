
-- Need to filter the migration data by account as an option
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
