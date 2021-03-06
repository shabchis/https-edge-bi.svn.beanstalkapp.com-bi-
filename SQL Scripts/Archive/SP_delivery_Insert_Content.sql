USE [Deliveries]
GO
/****** Object:  StoredProcedure [dbo].[SP_Delivery_Insert_Content]    Script Date: 10/04/2012 20:11:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Amit Bluman
-- Create date:	Apr 2nd 2012 
-- update date: Apr 9nd 2012
-- Last update: Add campaign status
-- =============================================

ALTER PROCEDURE [dbo].[SP_Delivery_Insert_Content]
	@DeliveryFileName			Nvarchar(4000),
	@CommitTableName			Nvarchar(4000),
	@MeasuresNamesSQL			Nvarchar(4000) = NULL,
	@MeasuresFieldNamesSQL		Nvarchar(4000) = NULL,
	@Signature					Nvarchar(4000),
	@DeliveryID					Nvarchar(4000),
	@DeliveryIDsPerSignature	Nvarchar(4000) OUTPUT
	
AS
BEGIN

	SET NOCOUNT OFF;
	SET XACT_ABORT ON;
	-- Start Debug
	/*
				declare @DeliveryFileName		as nvarchar(4000)
				declare @CommitTableName		as nvarchar(4000)
				declare @MeasuresNamesSQL		as	Nvarchar(4000)
				declare @MeasuresFieldNamesSQL	as	Nvarchar(4000)
				declare @Signature				as	Nvarchar(4000)
				declare @DeliveryID				as	Nvarchar(4000)
				declare @DeliveryIDsPerSignature as	Nvarchar(4000) 

				set @DeliveryFileName = 'GEN_1006_20120402_134420_02fa88ca7338431ba23ef2b64d68c38f'
				set @CommitTableName = 'Paid_API_Content'
				set @Signature = 'R29vZ2xlQWR3b3Jkc1NlYXJjaC1bMTAwNl0tW3BwYy5lYXN5bmV0QGdtYWlsLmNvbV0tWzMxMy01NTUtNjkyNV0tW3tzdGFydDp7YWxpZ246J1N0YXJ0JyxkYXRlOicyMDEyLTAyLTE0VDAwOjAwOjAwJ30sZW5kOnthbGlnbjonRW5kJyxkYXRlOicyMDEyLTAyLTE0VDIzOjU5OjU5Ljk5OTk5OTknfX1d'
				set @MeasuresNamesSQL = ',Clicks, Cost'
				set @MeasuresFieldNamesSQL = ',Clicks, Cost'
	*/
	-- End Debug
	
		Declare @SQL As nvarchar(4000)
		Declare @SQL1 As nvarchar(4000)
		Declare @OLTPDB as Nvarchar(500)
		Declare @DeliveryDB as Nvarchar(500)
		Declare @EdgeSystemDeliveryTablePath as Nvarchar(500)
		
		set @DeliveryDB = 'Deliveries'
		set @OLTPDB = 'TestDB'
		set @EdgeSystemDeliveryTablePath = '[Edge_System].[dbo].[Delivery]'
				  
	-- Check if the DeliveryID is empty
	if	(@DeliveryFileName is null or @CommitTableName is null)
		return; 		 
	
			-- Check whether there is committed data for this signature in the delivery table  
			set @SQL1 = ' SELECT @DeliveryIDsPerSignature =
						 CASE	WHEN ISNULL(SUM(convert (int,[committed])),0) = 0  THEN	''0''
								WHEN ISNULL(SUM(convert (int,[committed])),0) = 1  THEN	''1''
						  ELSE ''9'' -- Means that there are more then 1 commited delivery 
						  END 
				  FROM ' + @EdgeSystemDeliveryTablePath+' with (paglock,XLOCK)
				  WHERE [Signature] = '''+ @signature +''''
	
			Exec Sp_executesql @SQL1 ,N'@DeliveryIDsPerSignature varchar(4000) OUTPUT',@DeliveryIDsPerSignature = @DeliveryIDsPerSignature  OUTPUT
			  
			-- The lock above should lock the page till the end of the transaction
			
			-- If the @DeliveryIDsPerSignature value is 1 then there is only 1 commited delivery for this signature
			IF (@DeliveryIDsPerSignature) = '1'
			begin
				set @DeliveryIDsPerSignature = ''	
				set @SQL1 = ''	
															
				set @SQL1 = ' SELECT @DeliveryIDsPerSignature = DeliveryID 
							  FROM ' + @EdgeSystemDeliveryTablePath+' 
							  WHERE [committed] !=0 AND [Signature] = '''+ @signature +''''	
				Exec Sp_executesql @SQL1 ,N'@DeliveryIDsPerSignature varchar(4000) OUTPUT',@DeliveryIDsPerSignature = @DeliveryIDsPerSignature  OUTPUT
							  								
			    return 1;
			end
			
			-- If the @DeliveryIDsPerSignature value is 9 then there are more thwn 1 commited delivery for this signature
			-- The statement below group_concats all the delivery ids to 1 string
			IF (@DeliveryIDsPerSignature) = '9'
			begin
				set @DeliveryIDsPerSignature = ''	
				set @SQL1 = ''	

					set @SQL1 = ' SELECT @DeliveryIDsPerSignature = COALESCE(@DeliveryIDsPerSignature+'', '','''')+ISNULL(deliveryid,'''')
							  FROM ' + @EdgeSystemDeliveryTablePath+' 
							  WHERE [committed] != 0 AND [Signature] = '''+ @signature +''''	
							  
				Exec Sp_executesql @SQL1 ,N'@DeliveryIDsPerSignature varchar(4000) OUTPUT',@DeliveryIDsPerSignature = @DeliveryIDsPerSignature  OUTPUT
																							
			    return 9;
			end
	
	-- This section will insert the delivery data stored in the commited_final table to the @CommitTableName
	-- Starts transaction
			 BEGIN TRANSACTION	
			 BEGIN
			 
			Set @SQL = 
			' 	INSERT INTO '+@OLTPDB +'.dbo.'+ @CommitTableName+ '
				  (	[DeliveryID]
				   ,[DeliveryFileName]
				   ,[customerid] -- accountID source
				   ,[Account_ID_SRC]
				   ,[Downloaded_Date]
				   ,[Date]
				   ,[Account_ID]
				   ,[Channel_ID]
				   ,[Day_Code]
			            
				  ,[campaignid]
				  ,[campaign]
				  ,[Campaign_GK]
				  ,[campStatus]
			           
				  ,[adgroupid]
				  ,[adgroup]
				  ,[AdGroup_GK]

				  ,[adwordsType]
			             
				  ,[Site]
				  ,[MatchType]
				  ,[Site_GK]
				  ,[PPC_Site_GK]
			      
				  -- will be delivered from the .NET as a list of OLTP measures names
				  '+@MeasuresFieldNamesSQL+'
				  )
				SELECT     
					DeliveryID,
					DeliveryFileName,
					Account_OriginalID ,
					Account_OriginalID ,
					DownloadedDate as Downloaded_date,
					DownloadedDate as Date,
					Account_ID as AccountID, 
					Channel_ID as ChannelID , 
					Day_Code as Day_code,
					
					CampaignID ,
					Campaign , 
					campaign_GK, 
					CampStatus ,
						
					AdgroupID,
					Adgroup , 
					adgroup_GK , 

					AdwordsType, 					
					Site ,			
					MatchType ,				
					Site_GK ,		
					PPC_Site_GK 	
					 
					'+@MeasuresNamesSQL+'  	

				FROM '+@DeliveryDB+'.dbo.'+ @DeliveryFileName +'_Commit_FinalMetrics
			'
			select @SQL
			Exec (@SQL)
			 
			-- Set this delivery + signature to be UnCommited (Committed = False) in the delivery table 
			set @SQL1= ''
			set @SQL1 = 'UPDATE ' + @EdgeSystemDeliveryTablePath+' with (paglock,XLOCK)
				SET [Committed] = 1
				WHERE DeliveryID = ''' +@DeliveryID + ''''  
				
			Exec Sp_executesql @SQL1

			
			-- Ends transaction
			COMMIT TRANSACTION
			END
			
			END

