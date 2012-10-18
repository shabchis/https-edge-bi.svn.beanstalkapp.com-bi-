USE [Seperia]
GO
/**
This SP find the duplicate trackers for a specific account and sends mail with the duplicate trackers to the account owners
The account owners are define by account permission name "RecieveAlerts"
Creation date : 15.10.2012 by Amit Bluman
**/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter PROCEDURE [dbo].[SP_Alerts_SendDuplicateTrackerMail]
		@AccountID int
AS
BEGIN
	SET NOCOUNT ON;

DECLARE @UsersEmails2 as varchar(8000) ;
DECLARE @EmailSubject as varchar(100) ;
DECLARE @FileName as varchar(100);
DECLARE @AccountName as varchar(100) ;
DECLARE @FileQuery as varchar(8000) ;
DECLARE @DuplicateAlertsFromDate as varchar(100);

-- Set users emails
EXEC [dbo].[SP_Alerts_GetUserByAccountID] @AccountID = @AccountID, @UsersEmails =@UsersEmails2  OUTPUT;
-- Set Account Name
Select @AccountName = Account_Name from User_GUI_Account where account_ID = @AccountID; 
-- Set email subject
Set @EmailSubject = 'Duplicate trackers list for ' + @AccountName
Set @FileName = 'Duplicate trackers list for ' + @AccountName + '.txt'

-- Set duplicate alert from date, this is the date to start the duplicate search in the log
Select @DuplicateAlertsFromDate =   Case when charindex(';',AccountSettings,charindex('DuplicateAlertsFromDate:',AccountSettings)) = 0
												then Substring(AccountSettings,charindex('DuplicateAlertsFromDate:',AccountSettings) + 24 ,9999)
										 Else Substring(AccountSettings,charindex('DuplicateAlertsFromDate:',AccountSettings) + 24,
														charindex(';',AccountSettings,charindex('DuplicateAlertsFromDate:',AccountSettings)) - charindex('DuplicateAlertsFromDate:',AccountSettings) - 24)
										 End
									From [dbo].[User_GUI_Account]
									Where AccountSettings like '%DuplicateAlertsFromDate%'
										and Account_id = @AccountID 
	 
-- Set duplicate tracker query from gatewayGK log
Set @FileQuery = '	Select distinct CH.Channel_Name, Gateway_ID 
					From [Seperia].[dbo].[Log_GetGatewayGK] LG
						Inner join [Seperia].[dbo].[Constant_Channel] CH
							on LG.channel_ID = CH.Channel_ID
					Where   account_Id = ' + Cast(@AccountID as varchar(50)) + '  
							and [Action] = ''UPDATE''
							and [Date] > '''+@DuplicateAlertsFromDate+' 00:01:00.000''
							and (Adgroup_gk != Current_adgroup_gk OR Reference_ID != Current_Reference_ID)'

Print @UsersEmails2;
Print @AccountName;
Print @EmailSubject;
Print @DuplicateAlertsFromDate;
Print @FileQuery;

-- Sends the mail
EXEC msdb.dbo.sp_send_dbmail
    @profile_name = 'edge@alerts@seperia.com' ,
    @recipients = @UsersEmails2 ,
    @query = @FileQuery ,
    @subject = @EmailSubject ,
    @attach_query_result_as_file = 1,
    @query_attachment_filename= @FileName,
	@query_result_no_padding = 1
	 ;

END

