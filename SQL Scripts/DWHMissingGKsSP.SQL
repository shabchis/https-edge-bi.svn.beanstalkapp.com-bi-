
 -- **************************************************
 --				DWH MISSING GKs SCRIPT
 -- **************************************************
 
 -- locate missing ppc_keyword_gks
   select distinct account_id, PPC_Key_Word_GK --, KeyWord_GK, paid_creative_gk
   into #PPC_KW_GK
   from  [Edge_DWH].[dbo].[Dwh_Fact_PPC_Campaigns]
   
  
   select * into #missingPPCKWs 
   from #PPC_KW_GK
   where PPC_Key_Word_GK not in (select distinct PPC_Key_Word_GK from [Edge_DWH].[dbo].Dwh_Dim_PPC_Key_Words)
	
   select account_id, COUNT(*) as missingPPCKWsCount
   from #missingPPCKWs 
   group by account_id
   order by 1
   
    -- locate missing keyword_gks
   select distinct account_id, Keyword_GK --, KeyWord_GK, paid_creative_gk
   into #KW_GK
   from  [Edge_DWH].[dbo].[Dwh_Fact_PPC_Campaigns]
   
  
   select * into #missingKWs 
   from #KW_GK
   where Keyword_GK not in (select distinct Keyword_GK from [Edge_DWH].[dbo].Dwh_Dim_Key_Words)
	
   select account_id, COUNT(*) as missingKWsCount 
   from #missingKWs 
   group by account_id
   order by 1
   
    -- locate missing ppc_creative_gks
   select distinct account_id, Paid_Creative_GK --, KeyWord_GK, paid_creative_gk
   into #PPC_Creative_GKs
   from  [Edge_DWH].[dbo].[Dwh_Fact_PPC_Campaigns]
   
  
   select * into #missingPPCCreatives 
   from #PPC_Creative_GKs
   where Paid_Creative_GK not in (select distinct Paid_Creative_GK from [Edge_DWH].[dbo].Dwh_Dim_PPC_Creatives)
	
   select account_id, COUNT(*) as missingPPCCreativesCount
   from #missingPPCCreatives 
   group by account_id
   order by 1
   
   
    -- locate missing creative_gks
   select distinct account_id, Creative_GK --, KeyWord_GK, paid_creative_gk
   into #Creative_GKs
   from  [Edge_DWH].[dbo].[Dwh_Fact_PPC_Campaigns]
   
  
   select * into #missingCreatives 
   from #Creative_GKs
   where Creative_GK not in (select distinct Creative_GK from [Edge_DWH].[dbo].Dwh_Dim_Creatives)
	
   select account_id, COUNT(*)as missingCreativesCount
   from #missingCreatives 
   group by account_id
   order by 1
   
    -- locate missing gateway_gks
   select distinct account_id, Gateway_GK --, KeyWord_GK, paid_creative_gk
   into #Gateway_GKs
   from  [Edge_DWH].[dbo].[Dwh_Fact_PPC_Campaigns]
   
  
   select * into #missingGateways
   from #Gateway_GKs
   where Gateway_GK not in (select distinct Gateway_GK from [Edge_DWH].[dbo].Dwh_Dim_Getways)
	
   select account_id, COUNT(*) as missingGatewaysCount
   from #missingGateways 
   group by account_id
   order by 1