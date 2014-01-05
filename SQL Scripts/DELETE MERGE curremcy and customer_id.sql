MERGE Dwh_Ref_MeasureGroupRef AS TRG
USING (
SELECT distinct
account_ID, 
Channel_ID, 
Gateway_GK , 
Campaign_gk, 
Ad_group_gk, 
Paid_Creative_GK, 
Creative_gk, 
 case Adwords_Type 
 when 'Unknown' then 0
 when NULL then 0 
 when  'Search Only' then 1 
 when 'Content Only' then 4 
 when 'Display - Managed' then  5 
 when 'Google Refund' then  6
 when 'Social' then  7
 else 0 end Ad_type, 
Advariation, 
getdate() as LastUpdated,
'Channel' as SourceData,
Customer_ID,
CurrCode
FROM [stg_Fact_PPC_Campaigns] with (nolock)
) AS SRC
ON 
isnull(SRC.account_ID,-1)= TRG.account_ID and 
isnull(SRC.Channel_ID,-1)= TRG.Channel_ID and 
isnull(SRC.Gateway_GK,-1)= TRG.Gateway_GK and 
isnull(SRC.Campaign_gk,-1)= TRG.Campaign_gk and 
isnull(SRC.Ad_group_gk,-1)= TRG.Ad_group_gk and 
isnull(SRC.Paid_Creative_GK,-1)= TRG.Paid_Creative_GK and 
isnull(SRC.Creative_gk,-1)= TRG.Creative_gk  and 
isnull(SRC.Customer_ID,-1) <> TRG.Customer_ID and 
	   cast(TRG.account_ID as nvarchar(255)) = TRG.Customer_ID
-- If the customer id = account_id then it is an ld customer id
-- it should be deleted when a new data (with real customer_id is in the STG table)
-- the new data will be loaded in the channel daily merge command
WHEN MATCHED THEN DELETE ; -- 20735

GO 

MERGE Dwh_Ref_MeasureGroupRef AS TRG
USING (
SELECT distinct
account_ID, 
Channel_ID, 
Gateway_GK , 
Campaign_gk, 
Ad_group_gk, 
Paid_Creative_GK, 
Creative_gk, 
 case Adwords_Type 
 when 'Unknown' then 0
 when NULL then 0 
 when  'Search Only' then 1 
 when 'Content Only' then 4 
 when 'Display - Managed' then  5 
 when 'Google Refund' then  6
 when 'Social' then  7
 else 0 end Ad_type, 
Advariation, 
getdate() as LastUpdated,
'Channel' as SourceData,
Customer_ID,
CurrCode
FROM [stg_Fact_PPC_Campaigns] with (nolock)
) AS SRC
ON 
isnull(SRC.account_ID,-1)=TRG.account_ID and 
isnull(SRC.Channel_ID,-1)=TRG.Channel_ID and 
isnull(SRC.Gateway_GK,-1)=TRG.Gateway_GK and 
isnull(SRC.Campaign_gk,-1)=TRG.Campaign_gk and 
isnull(SRC.Ad_group_gk,-1)=TRG.Ad_group_gk and 
isnull(SRC.Paid_Creative_GK,-1)=TRG.Paid_Creative_GK and 
isnull(SRC.Creative_gk,-1)=TRG.Creative_gk  and 
isnull(SRC.CurrCode,-1) <> TRG.Curr_Code and
	TRG.Curr_Code = 'USD'
-- If the currency = 'USD' and in the STG there is a different currency then it is a new currency
-- it should be deleted when a new data (with updated currency)
-- the new data will be loaded in the channel daily merge command
WHEN MATCHED THEN DELETE ;

GO 