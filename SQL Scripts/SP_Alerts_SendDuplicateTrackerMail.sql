USE [Seperia]
GO
/****** Object:  StoredProcedure [dbo].[SP_Alerts_SendDuplicateTrackerMail]    Script Date: 10/01/2013 17:08:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_Alerts_SendDuplicateTrackerMail]
		@AccountID int
AS
BEGIN
	SET NOCOUNT ON;

DECLARE @UsersEmails2 as varchar(max) ;
DECLARE @EmailSubject as varchar(100) ;
DECLARE @FileName as varchar(100);
DECLARE @AccountName as varchar(100) ;
DECLARE @FileQuery as varchar(max) ;
DECLARE @HTMLQuery as varchar(max) ;
DECLARE @DuplicateAlertsFromDate as varchar(100);
DECLARE @NumOfDuplicatesTrackers int;

-- Insert into Alerts_TrackersToIgnore table all the trackers to ignore

	Select distinct Account_id, Gateway_id, TrackerToIgnore
	Into #TempTTI
	From  [Seperia].[dbo].[Log_GetGatewayGK] LG
	Where account_id = @AccountID and TrackerToIgnore = 'True'
	
	 Insert into [Alerts_TrackersToIgnore]
	Select Temp.Account_ID, Temp.Gateway_id, Temp.TrackerToIgnore
	from #TempTTI Temp left outer join [Alerts_TrackersToIgnore] TTI
	on Temp.account_id = TTI.account_id and Temp.gateway_id = TTI.gateway_id
	where Temp.account_id = @AccountID and TTI.gateway_id is null

-- Set users emails
EXEC [dbo].[SP_Alerts_GetUserByAccountID] @AccountID = @AccountID, @UsersEmails =@UsersEmails2  OUTPUT;
-- Set Account Name
Select @AccountName = Account_Name from User_GUI_Account where account_ID = @AccountID; 

-- Set duplicate alert from date, this is the date to start the duplicate search in the log
Select @DuplicateAlertsFromDate =   Case when charindex(';',AccountSettings,charindex('DuplicateAlertsFromDate:',AccountSettings)) = 0
												then Substring(AccountSettings,charindex('DuplicateAlertsFromDate:',AccountSettings) + 24 ,9999)
										 Else Substring(AccountSettings,charindex('DuplicateAlertsFromDate:',AccountSettings) + 24,
														charindex(';',AccountSettings,charindex('DuplicateAlertsFromDate:',AccountSettings)) - charindex('DuplicateAlertsFromDate:',AccountSettings) - 24)
										 End
									From [dbo].[User_GUI_Account]
									Where AccountSettings like '%DuplicateAlertsFromDate%'
										and Account_id = @AccountID 
	 
-- Set email subject
Set @EmailSubject = 'Duplicate trackers list from ' + @DuplicateAlertsFromDate +' for ' + @AccountName
Set @FileName = 'Duplicate trackers list for ' + @AccountName + '.txt'


-- Find duplicates tracker amount from gatewayGK log, in order to know if there are any.
Select @NumOfDuplicatesTrackers = count(*)
From (
				Select  distinct  CH.Channel_Name,
						CH.Channel_ID,
						LG.Account_ID,
						CA.Campaign_gk,
						CA.campaign, 
						AG.Adgroup_gk,  
			 			AG.Adgroup,    
						LG.Gateway_ID
	 			From  [Seperia].[dbo].[Log_GetGatewayGK] LG
					Inner join [Seperia].[dbo].[Constant_Channel] CH
						on LG.channel_ID = CH.Channel_ID
					Inner join  [Seperia].[dbo].[UserProcess_GUI_PaidCampaign] CA
						on CA.Account_id = LG.Account_id and LG.Campaign_gk = CA.Campaign_gk
					Inner join  [Seperia].[dbo].[UserProcess_GUI_PaidAdGroup] AG
						on AG.Account_id = LG.Account_id and LG.Adgroup_gk = AG.Adgroup_gk
				Where LG.account_ID =  Cast(@AccountID as varchar(50))
						and LG.[Action] = 'UPDATE'
						and LG.[Date] >= @DuplicateAlertsFromDate +' 00:01:00.000'
						and (LG.Adgroup_gk != LG.Current_adgroup_gk OR LG.Reference_ID != LG.Current_Reference_ID)
						and LG.Gateway_id not in (Select Gateway_id From Alerts_TrackersToIgnore
													Where Account_id = @AccountID)
						) Log_Gateway 
Inner join  [Seperia].[dbo].[Paid_API_AllColumns_v29] FACT
			on FACT.Account_id = Log_Gateway.Account_id 
				and Log_Gateway.Campaign_gk = FACT.Campaign_gk 
				and FACT.Adgroup_gk = Log_Gateway.Adgroup_gk	
				and Log_Gateway.Gateway_ID Collate SQL_Latin1_General_CP1_CI_AS = FACT.gateway_ID
WHERE FACT.Day_code >=  Convert(int,Replace(@DuplicateAlertsFromDate,'-',''))
GROUP BY  Log_Gateway.Channel_Name, Log_Gateway.Campaign, Log_Gateway.Adgroup, Log_Gateway.Gateway_ID

---- In use for Attache file to a mail format only
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
							
--	Select TMP.Channel_name,  '','' ,CA.campaign, '','' , AG.Adgroup, '','' , TMP.Gateway_ID, '',''  , Sum(FACT.Cost) as Cost
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

Print convert(nvarchar(10), @NumOfDuplicatesTrackers) +' duplicate tracker found' ;

If (@NumOfDuplicatesTrackers != 0)
BEGIN
		Set @HTMLQuery =  N'<H1> Duplicate trackers list </H1>' +
			N'<table border="2">' +
			N'<tr><th>Channel Name</th>
			<th>Campaign</th>' +
			N'<th>Adgroup</th>
			<th>Tracker ID</th>' +
			N'<th>Total Cost</th>
			</tr>' +
			CAST ( ( 
			Select  td =	Log_Gateway.Channel_Name,'',
					td =    Log_Gateway.campaign,    '',
					td = 	Log_Gateway.Adgroup,     '',
					td=		Log_Gateway.Gateway_ID,	'',
					td = 	Convert(decimal(18,2),Sum(FACT.Cost))
			From (
						Select  distinct  CH.Channel_Name,
								CH.Channel_ID,
								LG.Account_ID,
								CA.Campaign_gk,
								CA.campaign, 
								AG.Adgroup_gk,  
			 					AG.Adgroup,    
								LG.Gateway_ID
	 					From  [Seperia].[dbo].[Log_GetGatewayGK] LG
							Inner join [Seperia].[dbo].[Constant_Channel] CH
								on LG.channel_ID = CH.Channel_ID
							Inner join  [Seperia].[dbo].[UserProcess_GUI_PaidCampaign] CA
								on CA.Account_id = LG.Account_id and LG.Campaign_gk = CA.Campaign_gk
							Inner join  [Seperia].[dbo].[UserProcess_GUI_PaidAdGroup] AG
								on AG.Account_id = LG.Account_id and LG.Adgroup_gk = AG.Adgroup_gk
							Where LG.account_ID =  Cast(@AccountID as varchar(50))
								and LG.[Action] = 'UPDATE'
								and LG.[Date] >= @DuplicateAlertsFromDate +' 00:01:00.000'
								and (LG.Adgroup_gk != LG.Current_adgroup_gk OR LG.Reference_ID != LG.Current_Reference_ID)
								and LG.Gateway_id not in (Select Gateway_id From Alerts_TrackersToIgnore
															Where Account_id = @AccountID)
							) Log_Gateway 
			Inner join  [Seperia].[dbo].[Paid_API_AllColumns_v29] FACT
						on FACT.Account_id = Log_Gateway.Account_id 
							and Log_Gateway.Campaign_gk = FACT.Campaign_gk 
							and FACT.Adgroup_gk = Log_Gateway.Adgroup_gk	
							and Log_Gateway.Gateway_ID Collate SQL_Latin1_General_CP1_CI_AS = FACT.gateway_ID
			WHERE FACT.Day_code >=  Convert(int,Replace(@DuplicateAlertsFromDate,'-',''))
				-- AND FACT.Cost > 0
			GROUP BY  Log_Gateway.Channel_Name, Log_Gateway.Campaign, Log_Gateway.Adgroup, Log_Gateway.Gateway_ID
			ORDER BY  Log_Gateway.Gateway_ID, Log_Gateway.Adgroup, Log_Gateway.Campaign, Log_Gateway.Channel_Name
					  FOR XML PATH('tr'), TYPE 
			) AS NVARCHAR(MAX) ) +
			N'</table>' ;

		-- Debug printing
			Print @UsersEmails2;
			Print @AccountName;
			Print @EmailSubject;
			Print @DuplicateAlertsFromDate;

		-- Sends the mail as attached file
			--EXEC msdb.dbo.sp_send_dbmail
			--    @profile_name = 'edge@alerts@seperia.com' ,
			--    @recipients = @UsersEmails2 ,
			--    @query = @FileQuery ,
			--    @subject = @EmailSubject ,
			--    @attach_query_result_as_file = 1,
			--    @query_attachment_filename= @FileName,
			--	@query_result_no_padding = 1
		--	 ;

			 -- Sends the mail as HTML
		EXEC msdb.dbo.sp_send_dbmail
			@profile_name = 'edge@alerts@seperia.com' ,
			@recipients = 'amitblu@gmail.com',--  @UsersEmails2 ,
			@body = @HTMLQuery ,
			@subject = @EmailSubject ,
			 @query_result_no_padding = 1,
			 @body_format = 'HTML'
			-- @query = @FileQuery,
			-- @attach_query_result_as_file = 1,
			-- @query_attachment_filename= @FileName
			;
END -- Ends the If (@NumOfDuplicatesTrackers != 0) clause

END

