/****** Script for SelectTopNRows command from SSMS  ******/


SELECT distinct account_ID, Channel_ID, Gateway_GK , Campaign_gk, Ad_group_gk, Paid_Creative_GK, Creative_gk, Adwords_type, Ad_type, Advariation, getdate() as LastUpdated
INTO Dwh_Ref_MeasureGroupRef 
-- INTO #GTW_Temp
FROM [Seperia_DWH].[dbo].[Dwh_Fact_PPC_Campaigns]
WHERE -- account_id = 10035 and
	 gateway_gk != -1
	and day_id > 20130101


UP555DATE  [Seperia_DWH].[dbo].[Dwh_Dim_Getways_withBO] 
SET		Paid_Creative_GK = FACT.Paid_Creative_GK 
FROM	 [Seperia_DWH].[dbo].[Dwh_Dim_Getways_withBO]  GTW 
			inner join #GTW_Temp FACT
				ON GTW.Account_ID = FACT.Account_ID and GTW.Gateway_GK = FACT.Gateway_GK
WHERE	 GTW.Account_ID = 10035 AND
		-- FACT.Day_ID > 20130101
		 --> 5937
		 --> 75183 
		 
		 
		 
-- Drop table #FACT_TEMP

	SELECT  distinct [account_ID]
           ,[Channel_ID]
           ,[Gateway_GK]
	INTO	#GTW_Unique
	FROM	[Seperia_DWH].[dbo].[Dwh_Fact_PPC_Campaigns]
	WHERE	gateway_gk != -1
			and day_id > 20130301
			-- 23550

SELECT		fact.[account_ID]
           ,fact.[Channel_ID]
           ,fact.[Gateway_GK]
           ,fact.[Campaign_gk]
           ,fact.[Ad_group_gk]
           ,fact.[Paid_Creative_GK]
           ,fact.[Creative_gk]
           ,fact.[Adwords_type]
           ,fact.[Ad_type]
           ,fact.[Advariation]
		   ,CONVERT(decimal(18,1),Avg(fact.Avg_Position)) as Avg_Pos
		   ,GETDATE() as LastUpdated
	INTO	#FACT_TEMP
	FROM	[Seperia_DWH].[dbo].[Dwh_Fact_PPC_Campaigns] fact
	WHERE	gateway_gk != -1
			and day_id > 20130301
	GROUP BY   fact.[account_ID]
           ,fact.[Channel_ID]
           ,fact.[Gateway_GK]
           ,fact.[Campaign_gk]
           ,fact.[Ad_group_gk]
           ,fact.[Paid_Creative_GK]
           ,fact.[Creative_gk]
           ,fact.[Adwords_type]
           ,fact.[Ad_type]
           ,fact.[Advariation]


INSERT INTO [Seperia_DWH].[dbo].[Dwh_Ref_MeasureGroupRef]
           ([account_ID]
           ,[Channel_ID]
           ,[Gateway_GK]
           ,[Campaign_gk]
           ,[Ad_group_gk]
           ,[Paid_Creative_GK]
           ,[Creative_gk]
           ,[Adwords_type]
           ,[Ad_type]
           ,[Advariation]
           ,[Avg_Pos]
           ,[LastUpdated])
SELECT	distinct 	fact.[account_ID]
           ,fact.[Channel_ID]
           ,fact.[Gateway_GK]
           ,fact.[Campaign_gk]
           ,fact.[Ad_group_gk]
           ,fact.[Paid_Creative_GK]
           ,fact.[Creative_gk]
           ,fact.[Adwords_type]
           ,fact.[Ad_type]
           ,fact.[Advariation]
		   ,fact.[Avg_Pos]
		   ,fact.[LastUpdated]
FROM	#GTW_Unique uni
		inner join #FACT_TEMP fact	
			ON uni.account_id = fact.account_id
				and uni.Channel_ID = fact.Channel_ID
				and uni.Gateway_GK = fact.Gateway_GK






