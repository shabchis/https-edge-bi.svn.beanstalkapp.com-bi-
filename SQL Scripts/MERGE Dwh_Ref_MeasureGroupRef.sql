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
 else 0 end Ad_type, 
Advariation, 
getdate() as LastUpdated,
'Channel' as SourceData
FROM [stg_Fact_PPC_Campaigns] with (nolock)
) AS SRC
ON 
isnull(SRC.account_ID,-1)=TRG.account_ID and 
isnull(SRC.Channel_ID,-1)=TRG.Channel_ID and 
isnull(SRC.Gateway_GK,-1)=TRG.Gateway_GK and 
isnull(SRC.Campaign_gk,-1)=TRG.Campaign_gk and 
isnull(SRC.Ad_group_gk,-1)=TRG.Ad_group_gk and 
isnull(SRC.Paid_Creative_GK,-1)=TRG.Paid_Creative_GK and 
isnull(SRC.Creative_gk,-1)=TRG.Creative_gk and 
isnull(SRC.Ad_type,0)=TRG.Adwords_type_code and 
isnull(SRC.Advariation,0)=TRG.Advariation

WHEN NOT MATCHED THEN

INSERT(account_ID ,Channel_ID , Gateway_GK , Campaign_gk , Ad_group_gk , Paid_Creative_GK ,  Adwords_type_code , Advariation ,LastUpdated,Creative_gk ,SourceData )
VALUES(isnull(SRC.account_ID,-1) ,isnull(SRC.Channel_ID,-1) , isnull(SRC.Gateway_GK,-1) , isnull(SRC.Campaign_gk,-1) , isnull(SRC.Ad_group_gk,-1) , isnull(SRC.Paid_Creative_GK ,-1) ,   isnull(SRC.Ad_type,0) ,isnull( SRC.Advariation,0) ,SRC.LastUpdated,isnull(src.Creative_gk ,-1) , SRC.SourceData);
GO 
