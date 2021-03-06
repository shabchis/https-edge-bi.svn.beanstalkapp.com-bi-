USE [Deliveries]
GO
/****** Object:  StoredProcedure [dbo].[SP_Delivery_Insert_Facebook]    Script Date: 09/01/2012 17:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_Delivery_Insert_Facebook]
	@DeliveryFileName			Nvarchar(4000),
	@CommitTableName			Nvarchar(4000),
	@MeasuresNamesSQL			Nvarchar(4000) = null,
	@MeasuresFieldNamesSQL		Nvarchar(4000) = null,
	@Signature					Nvarchar(4000),
	@DeliveryID					Nvarchar(4000),
	@DeliveryIDsPerSignature	Nvarchar(4000) OUTPUT
AS
BEGIN 

	SET NOCOUNT ON;	

	-- Start Debug
	/*			declare @DeliveryFileName as nvarchar(4000)
				set @DeliveryFileName = 'D1007_20110629_055826_32e80326a6ab4a2ea841cc9ae95658fc'
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
		
		-- Will be deleted
		/*
		set @MeasuresFieldNamesSQL= 
				' ,[pos]
				 ,[Cost]
				 ,[Clicks] 
				 ,[Imps]
				 ,[SocialImpressions]
				 ,[SocialClicks]
				 ,[SocialCost]
				 ,[Actions]
				 ,[Unique_Impressions]
				 ,[Social_Unique_Impressions]
				 ,[Unique_Clicks]
				 ,[Social_Unique_Clicks]
				 ,[Connections]  
				  '
		 set @MeasuresNamesSQL= 
				' ,[AveragePosition]
				  ,[Cost]
				  ,[Clicks]
				  ,[Impressions]
				  ,[SocialImpressions]
				  ,[SocialClicks]
				  ,[SocialCost]
				  ,[Actions]
				  ,[UniqueImpressions]
				  ,[SocialUniqueImpressions]
				  ,[UniqueClicks]
				  ,[SocialUniqueClicks]
				  ,[Connections]
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
		 
	
			BEGIN TRANSACTION;
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
			       ,[ImgCreativeName]
			             
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
					-- Facebook mapping only 
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
				
					Title as Title ,  
					body as Body ,
					body2 as Body2 , 
					ImageURL as ImageURL ,	--in adwords it will be -> CreativeUnified.DisplayURL as DisplayURL ,  
					destUrl ,
					AdOriginalID ,
					CreativeType , 
					NULL as CreativeStatus ,	-- Ad Status in FB is not downloaded
					NULL as AdwordsType ,		-- Adwords only
					NULL as AdStatus ,			-- Ad Status in FB is not downloaded
					DestUrl ,
					PPCCreativeGK ,
					CreativeGK , 
					NULL as AdVariation ,		-- Adwords only
					ImgCreativeName as ImgCreativeName,
					
					NULL as KeywordID ,			
					NULL as Keyword ,			
					NULL as KeywordStatus ,		
					NULL as MatchType ,			
					NULL as QualityScore ,		
					NULL as KeywordDestURL ,	
					NULL as KeywordGK ,		
					NULL as PPCKeywordGK ,	
					 
					NULL as Gateway ,			
					TrackerName as Gateway_id ,		
					trackerGK as Gateway_GK 			
									
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
			COMMIT TRANSACTION;
			
			
			END
			
END

