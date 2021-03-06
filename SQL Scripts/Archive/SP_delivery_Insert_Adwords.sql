USE [Deliveries]
GO
/****** Object:  StoredProcedure [dbo].[SP_Delivery_Insert_Adwords]    Script Date: 09/01/2012 17:06:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_Delivery_Insert_Adwords]
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
	/*			declare @DeliveryFileName	as nvarchar(4000)
				declare @CommitTableName	as nvarchar(4000)
				declare @MeasuresNamesSQL	as		Nvarchar(4000)
				declare @MeasuresFieldNamesSQL	as	Nvarchar(4000)
				set @DeliveryFileName = 'D7_20110629_042543_ba41021b17454cac8bad88dc379c9c91'
				
	*/
	-- End Debug
	
		Declare @SQL As nvarchar(4000)
		Declare @SQL1 As nvarchar(4000)
		Declare @OLTPDB as Nvarchar(500)
		Declare @DeliveryDB as Nvarchar(500)
		Declare @EdgeSystemDeliveryTablePath as Nvarchar(500)
		
		set @DeliveryDB = 'Deliveries'
		set @OLTPDB = 'Seperia'
		set @EdgeSystemDeliveryTablePath = '[Seperia_System_29].[dbo].[Delivery]'
		
		
		-- WILL BE DELETED, the fields will be delivered by the .net
		/*
		set @MeasuresFieldNamesSQL= 
				'   ,[Leads]
					,[PageViews]
					,[defaultConv]
					,[Purchases]
					,[Clicks]
					,[Imps]
					,[Cost]
					,[Signups]
					,[pos]
					,[conv]	
				  '
		-- WILL BE DELETED
		set @MeasuresNamesSQL= 
				'   ,[Leads]
					,[PageViews]
					,[Default]
					,[Purchases]
					,[Clicks]
					,[Impressions]
					,[Cost]
					,[Signups]
					,[AveragePosition]
					,[TotalConversionsOnePerClick]		
				  '
		*/		  
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
				   ,[timezone] -- Time zone 
				   ,[currCode]
				   ,[Downloaded_Date]
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

				  ,[headline]
				  ,[desc1]
				  ,[desc2]
				  ,[creativeVisUrl]
				  ,[destUrl]
				  ,[creativeid]
				  ,[creativeType]
				  ,[creativeStatus]
				  ,[adwordsType]
				  ,[adStatus]
				  ,[creativeDestUrl]
				  ,[PPC_Creative_GK]
				  ,[Creative_gk]
				  ,[AdVariation]
				  ,[imgCreativeName]
			             
				  ,[keywordid]
				  ,[kwSite]
				  ,[siteKwStatus] -- kw status
				  ,[MatchType]
				  ,[QualityScore]
				  ,[kwDestUrl]
				  ,[Keyword_GK]
				  ,[PPC_Keyword_GK]
			      
				  ,[Gateway]
				  ,[Gateway_id]
				  ,[Gateway_gk]
			     
				  -- will be delivered from the .NET as a list of OLTP measures names
				  '+@MeasuresFieldNamesSQL+'
				  )
				SELECT     
					DeliveryID,
					DeliveryFileName,
					AccountOriginalID ,
					AccountOriginalID ,
					NULL as TimeZone ,
					Currency as CurrCode,
					DownloadedDate as Downloaded_date,
					AccountID as AccountID, 
					ChannelID as ChannelID , 
					Day_Code as Day_code,
					
					CampaignID ,
					Campaign , 
					campaign_GK, 
					CampStatus ,
						
					AdgroupID,
					Adgroup , 
					adgroup_GK , 
				
					Title  ,  
					body  ,
					body2  , 
					DisplayURL ,  
					destUrl ,
					AdOriginalID ,
					CreativeType , 
					NULL as CreativeStatus ,	-- No Ad Status 
					NetworkType ,				-- Adwords only
					NULL as AdStatus ,			-- Ad Status in FB is not downloaded
					DestUrl ,
					PPCCreativeGK ,
					CreativeGK , 
					AdVariation ,		
					ImgCreativeName as imgCreativeName,
					
					KeywordID ,		
					Keyword ,			
					Null as KeywordStatus ,		
					MatchType ,			
					QualityScore ,		
					keywordDestUrl ,	
					KeywordGK ,		
					PPCKeywordGK ,	
					 
					NULL as Gateway ,			
					Trackername as Gateway_id ,		
					TrackerGK as Gateway_GK 	
					
					'+@MeasuresNamesSQL+'  	

				FROM '+@DeliveryDB+'.dbo.'+ @DeliveryFileName +'_Commit_FinalMetrics
			'
		
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

