USE [Seperia]
GO
/****** Object:  StoredProcedure [dbo].[SP_Add_Refund_per_Account]    Script Date: 09/06/2014 12:04:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Amit Bluman
-- Create date: 18/11/2010
-- Description:	This SP inserts the refund to Dwh_Fact_PPC_Campaigns table, it splits the refund data to all the days of the months
--				The date format for the parameter @Month should be mm/dd/yyyy 
-- Update date: 28/5/2013 
-- Description: added adwords_type_code, ad_type, advariation fields to the insert
-- Update date: 9/6/2014
-- Description:	Added customer_id to the dwh_fact insert 
-- =============================================
ALTER PROCEDURE [dbo].[SP_Add_Refund_per_Account]( @AccountID int ,@ChannelID int =1 ,@Month datetime, @RefundAmount decimal(18,2))

AS
BEGIN
	
	SET NOCOUNT ON;

    
 -- Debug Mode
 /*
declare @Month datetime = '5/1/2013' -- the format is mm/dd/yyyy
declare @AccountID int = 7
declare @RefundAmount decimal(18,2) = 30
declare @ChannelID int =1 --Google only
*/

declare @MonthInDayIDFormat int		-- Stores the Month parameter in an integer format YYYYMM
declare @DayIDToInsert int			-- Stores the day_Id to be inserted to the table
declare @NumOfDaysInMonth int		-- Stores the number of days in the month
declare @RefundCampaignGK int		-- Stores the refund campaign gk from the GK Manager SP
declare @RefundAdgroupGK int		-- Stores the refund adgroup gk from the GK Manager SP
declare @RefundGatewayGK int		-- Stores the refund gateway gk from the GK Manager SP
declare @RefundCreativeGK int		-- Stores the refund creative gk from the GK Manager SP
declare @RefundPPCCreativeGK int	-- Stores the refund paid creative gk from the GK Manager SP
declare @RefundKeywordGK int		-- Stores the refund Keyword gk from the GK Manager SP
declare @RefundPPCKeywordGK int	-- Stores the refund paid Keyword gk from the GK Manager SP

declare @DayCounter int				-- Uses as an index in the inserting rows up to the last day of the month 

-- Converts the @RefundAmount to negative value
set @RefundAmount =			case	when @RefundAmount > 0 then @RefundAmount*(-1)
							end
									
set @MonthInDayIDFormat =	case	when month(@Month) <10  then  cast(year(@Month)as NCHAR(4)) +'0'+ convert(char(2),month(@Month))
									when month(@Month) >9 then cast(year(@Month)as NCHAR(4)) + Convert(char(2),month(@Month))
							end
							
set @NumOfDaysInMonth = datepart(dd,dateadd(dd,-1,dateadd(mm,1,cast(cast(year(@Month) as varchar)+'-'+cast(month(@Month) as varchar)+'-01' as datetime))))

set @DayCounter = 1

-- If there is a future refund throw exception 

		execute @RefundCampaignGK =  seperia.dbo.GkManager_GetCampaignGK_WithReturn
				@account_id = @AccountID,
				@Channel_id = @ChannelID,
				@Campaign = 'Refund',
				@Campaignid = NULL
		
		execute @RefundAdgroupGK =  seperia.dbo.GkManager_GetAdgroupGK_WithReturn
				@account_id = @AccountID,
				@Channel_id = @ChannelID,
				@Campaign_GK = @RefundCampaignGK,
				@adgroup = 'Refund',
				@adgroupid = NULL
		
		execute @RefundCreativeGK =  seperia.dbo.GkManager_GetCreativeGK_WithReturn
				@account_id = @AccountID,
				@Creative_Title = 'Refund',
				@Creative_Desc1 = 'Refund' ,
				@Creative_Desc2 = 'Refund'
	
		execute @RefundKeywordGK =  seperia.dbo.GkManager_GetKeywordGK_WithReturn
				@account_id = @AccountID,
				@Keyword = 'Refund'		
												
		execute @RefundPPCCreativeGK =  seperia.dbo.GkManager_GetAdgroupCreativeGK_WithReturn
				@account_id = @AccountID,
				@Channel_id = @ChannelID,
				@Campaign_GK = @RefundCampaignGK,
				@adgroup_GK = @RefundAdgroupGK,
				@Creative_GK = @RefundCreativeGK,
				@creativeDestUrl = 'Refund'	,	
				@creativeVisUrl = 'Refund',
				@Gateway_GK = @RefundGatewayGK
								
		execute @RefundPPCKeywordGK =  seperia.dbo.GkManager_GetAdgroupKeywordGK_WithReturn
				@account_id = @AccountID,
				@Channel_id = @ChannelID,
				@Campaign_GK = @RefundCampaignGK,
				@adgroup_GK = @RefundAdgroupGK,
				@Keyword_GK = @RefundKeywordGK,
				@MatchType = 1,	
				@kwDestUrl =  'Refund',
				@Gateway_GK = @RefundGatewayGK

		execute @RefundGatewayGK =  seperia.dbo.GkManager_GetGatewayGK_WithReturn
				@account_id = @AccountID,
				@gateway_id = '99999999',
				@Channel_id = @ChannelID,
				@Campaign_GK = @RefundCampaignGK,
				@adgroup_GK = @RefundAdgroupGK,
				@gateway = 'Refund',
				@Reference_Type = 0,
				@Reference_ID = @RefundCreativeGK,
				@Dest_URL = NULL	
			
		While @DayCounter <= @NumOfDaysInMonth
			BEGIN
				set @DayIDToInsert =	case	when @DayCounter <10  then  CAST(@MonthInDayIDFormat as CHAR(6)) + '0' + CAST(@DayCounter as CHAR(2))
												when @DayCounter >9	  then  CAST(@MonthInDayIDFormat as CHAR(6)) + CAST(@DayCounter as CHAR(2))
										end
				 print @DayIDToInsert -- Debug
		
					INSERT INTO Seperia_DWH.dbo.Dwh_Fact_PPC_Campaigns 
								(Day_ID, Channel_ID, Account_ID, Campaign_Gk ,Ad_Group_GK, Gateway_GK,Position_ID, 
								Paid_Creative_GK, Creative_GK ,PPC_Key_Word_GK, Keyword_GK,Cost ,Dwh_Creation_Date ,Dwh_Update_Date,adwords_type, adwords_type_code, ad_type, advariation, customer_id )
					VALUES		(@DayIDToInsert , @ChannelID , @AccountID , @RefundCampaignGK , @RefundAdgroupGK, @RefundGatewayGK ,0, 
								@RefundPPCCreativeGK , @RefundCreativeGK,@RefundPPCKeywordGK , @RefundKeywordGK ,(@RefundAmount/@NumOfDaysInMonth),GETDATE(),GETDATE(),'Google Refund', 6, 6, 13, @AccountID )
	

				Set @DayCounter = @DayCounter+1	
			END	
	
			
			
			-- log the action in the log table
			INSERT INTO [Seperia_System_291].[dbo].[Log] 
						([DateRecorded] ,[MachineName],[ProcessID] ,[Source] ,[MessageType] ,[ServiceInstanceID]
						 ,[AccountID] ,[Message] ,[IsException] ,[ExceptionDetails])
			 VALUES
				   (getdate() ,'EDGE1' ,99999 ,'GoogleRefund' ,3 ,-1 ,@AccountID ,'Google refund was added successfully for account:' + convert(nvarchar(10), @AccountID) + ' ,date:' + convert(nvarchar(30),@Month, 103) 
							+ ', amount: ' + convert(nvarchar(30),@RefundAmount) ,0 ,NULL)
	
/*   -------Debug
	select * 
	--delete 
	From Seperia_DWH.dbo.Dwh_Fact_PPC_Campaigns
	where Account_ID = 7 and Channel_ID = 1  and  Campaign_Gk = 4002682 
	and Dwh_Update_Date > GETDATE()-1
	order by 1
	*/
    
    
    
    
END
