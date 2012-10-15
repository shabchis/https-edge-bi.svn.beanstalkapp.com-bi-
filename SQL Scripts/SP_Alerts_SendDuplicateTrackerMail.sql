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
create PROCEDURE [dbo].[SP_Alerts_SendDuplicateTrackerMail]
		@AccountID int
AS
BEGIN
	SET NOCOUNT ON;

DECLARE @UsersEmails2 as varchar(8000) ;
DECLARE @EmailSubject as varchar(100) ;
DECLARE @AccountName as varchar(100) ;
DECLARE @FileQuery as varchar(8000) ;

-- Set users emails
EXEC [dbo].[SP_Alerts_GetUserByAccountID] @AccountID = 7, @UsersEmails =@UsersEmails2  OUTPUT;
-- Set Account Name
Select @AccountName = Account_Name from User_GUI_Account where account_ID = @AccountID; 
-- Set email subject
Set @EmailSubject = 'Duplicate trackers list for ' + @AccountName

-- Set duplicate tracker query from gatewayGK log
Set @FileQuery = '	Select distinct CH.Channel_Name, Gateway_ID 
					From [Seperia].[dbo].[Log_GetGatewayGK] LG
						Inner join [Seperia].[dbo].[Constant_Channel] CH
							on LG.channel_ID = CH.Channel_ID
					Where   account_Id = ' + Cast(@AccountID as varchar(50)) + '  
							and [Action] = ''UPDATE''
							and [Date] > ''2012-10-13 00:01:00.000''
							and (Adgroup_gk != Current_adgroup_gk OR Reference_ID != Current_Reference_ID)'

Print @UsersEmails2;
Print @AccountName;
Print @EmailSubject;
Print @FileQuery;

EXEC msdb.dbo.sp_send_dbmail
    @profile_name = 'edge@alerts@seperia.com' ,
    @recipients = 'doron@edge.bi; amit@edge.bi; assayas.doron@gmail.com' , --@UsersEmails2 ,
    @query = @FileQuery ,
    @subject = @EmailSubject ,
    @attach_query_result_as_file = 1,
    @query_attachment_filename= @EmailSubject   ;

END

