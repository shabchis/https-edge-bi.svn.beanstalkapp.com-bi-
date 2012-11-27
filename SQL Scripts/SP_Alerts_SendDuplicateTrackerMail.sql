USE [Seperia]
GO
/****** Object:  StoredProcedure [dbo].[SP_Alerts_SendDuplicateTrackerMail]    Script Date: 27/11/2012 16:35:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_Alerts_SendDuplicateTrackerMail]
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
--Set @FileQuery = 
--	'Select distinct CH.Channel_Name,LG.Account_ID, LG.Campaign_gk, Adgroup_gk, Gateway_ID
--	into #TempTrackerList
--					From [Seperia].[dbo].[Log_GetGatewayGK] LG
--						Inner join [Seperia].[dbo].[Constant_Channel] CH
--							on LG.channel_ID = CH.Channel_ID
--					Where   LG.Account_Id = ' + Cast(@AccountID as varchar(50)) + ' 
--							and [Action] = ''UPDATE''
--							and [Date] > '''+@DuplicateAlertsFromDate+' 00:01:00.000''
--							and (Adgroup_gk != Current_adgroup_gk OR Reference_ID != Current_Reference_ID)
--							and Isnull(TrackerToIgnore,0) != 1 
							
--	Select TMP.Channel_name, CA.campaign, AG.Adgroup, TMP.Gateway_ID  , Sum(FACT.Cost) as Cost
--		From #TempTrackerList TMP
--			Inner join  [Seperia].[dbo].[UserProcess_GUI_PaidCampaign] CA
--				on CA.Account_id = TMP.Account_id and TMP.Campaign_gk = CA.Campaign_gk
--			Inner join  [Seperia].[dbo].[UserProcess_GUI_PaidAdGroup] AG
--				on AG.Account_id = TMP.Account_id and TMP.Adgroup_gk = AG.Adgroup_gk
--			Inner join  [Seperia].[dbo].[Paid_API_AllColumns_v29] FACT
--				on FACT.Account_id = TMP.Account_id and TMP.Campaign_gk = FACT.Campaign_gk 
--					and FACT.Adgroup_gk = AG.Adgroup_gk	and TMP.Gateway_ID Collate SQL_Latin1_General_CP1_CI_AS = FACT.gateway_ID
--		 Where TMP.account_ID = ' + Cast(@AccountID as varchar(50)) + '
--			 and FACT.Day_code >= Convert(int,Replace('''+@DuplicateAlertsFromDate+''',''-'',''''))
--	Group by TMP.Channel_name, CA.campaign, AG.Adgroup, TMP.Gateway_ID
--	Order by TMP.Gateway_ID, Sum(FACT.Cost) '

Set @FileQuery =  N'<H1> Duplicate trackers list </H1>' +
    N'<table border="2">' +
    N'<tr><th>Channel Name</th>
	<th>Campaign</th>' +
    N'<th>Adgroup</th>
	<th>Tracker ID</th>' +
	N'<th>Total Cost</th>
	</tr>' +
    CAST ( ( 
	Select  td =	CH.Channel_Name,'',
			td =    CA.campaign,    '',
			td = 	AG.Adgroup,     '',
			td=		LG.Gateway_ID,	'',
			td = 	Convert(decimal(18,2),Sum(FACT.Cost)  )
	 	From  [Seperia].[dbo].[Log_GetGatewayGK] LG
			Inner join [Seperia].[dbo].[Constant_Channel] CH
				on LG.channel_ID = CH.Channel_ID
			Inner join  [Seperia].[dbo].[UserProcess_GUI_PaidCampaign] CA
				on CA.Account_id = LG.Account_id and LG.Campaign_gk = CA.Campaign_gk
			Inner join  [Seperia].[dbo].[UserProcess_GUI_PaidAdGroup] AG
				on AG.Account_id = LG.Account_id and LG.Adgroup_gk = AG.Adgroup_gk
			Inner join  [Seperia].[dbo].[Paid_API_AllColumns_v29] FACT
				on FACT.Account_id = LG.Account_id and LG.Campaign_gk = FACT.Campaign_gk 
					and FACT.Adgroup_gk = AG.Adgroup_gk	and LG.Gateway_ID Collate SQL_Latin1_General_CP1_CI_AS = FACT.gateway_ID
		 Where LG.account_ID =  Cast(@AccountID as varchar(50))
			 and FACT.Day_code >=  Convert(int,Replace(@DuplicateAlertsFromDate,'-',''))
			 and LG.[Action] = 'UPDATE'
			and LG.[Date] > @DuplicateAlertsFromDate +' 00:01:00.000'
			and (LG.Adgroup_gk != LG.Current_adgroup_gk OR LG.Reference_ID != LG.Current_Reference_ID)
			and Isnull(LG.TrackerToIgnore,0) != 1 
	Group by CH.Channel_name, CA.campaign, AG.Adgroup, LG.Gateway_ID
	Order by LG.Gateway_ID, Sum(FACT.Cost)
              FOR XML PATH('tr'), TYPE 
    ) AS NVARCHAR(MAX) ) +
    N'</table>' ;


Print @UsersEmails2;
Print @AccountName;
Print @EmailSubject;
Print @DuplicateAlertsFromDate;
Print @FileQuery;

-- Sends the mail
--EXEC msdb.dbo.sp_send_dbmail
--    @profile_name = 'edge@alerts@seperia.com' ,
--    @recipients = @UsersEmails2 ,
--    @query = @FileQuery ,
--    @subject = @EmailSubject ,
--    @attach_query_result_as_file = 1,
--    @query_attachment_filename= @FileName,
--	@query_result_no_padding = 1
--	 ;
	 -- Sends the mail
EXEC msdb.dbo.sp_send_dbmail
    @profile_name = 'edge@alerts@seperia.com' ,
    @recipients = @UsersEmails2 ,
    @body = @FileQuery ,
    @subject = @EmailSubject ,
    @query_result_no_padding = 1,
	@body_format = 'HTML'
	;
END

