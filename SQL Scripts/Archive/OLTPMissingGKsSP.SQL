 -- **************************************************
 --		OLTP MISSING GKs SCRIPT
 -- **************************************************
  
 -- locate missing ppc_keyword_gks
   select distinct account_id, PPC_KeyWord_GK 
   into #PPC_KW_GK
   from  [Edge_OLTP].[dbo].[Paid_API_AllColumns]
  
   select * into #missingPPCKWs 
   from #PPC_KW_GK
   where PPC_KeyWord_GK not in (select distinct PPC_KeyWord_GK from [Edge_OLTP].[dbo].UserProcess_GUI_PaidAdgroupKeyword)
	
   select account_id, COUNT(*) as missingPPCKWsCount
   from #missingPPCKWs 
   group by account_id
   order by 1
   
    -- locate missing keyword_gks
   select distinct account_id, Keyword_GK 
   into #KW_GK
   from  [Edge_OLTP].[dbo].[Paid_API_AllColumns]
   
  
   select * into #missingKWs 
   from #KW_GK
   where Keyword_GK not in (select distinct Keyword_GK from [Edge_OLTP].[dbo].UserProcess_GUI_Keyword)
	
   select account_id, COUNT(*) as missingKWsCount 
   from #missingKWs 
   group by account_id
   order by 1
   
    -- locate missing ppc_creative_gks
   select distinct account_id, PPC_Creative_GK
   into #PPC_Creative_GKs
   from  [Edge_OLTP].[dbo].[Paid_API_AllColumns]
   
   select * into #missingPPCCreatives 
   from #PPC_Creative_GKs
   where PPC_Creative_GK not in (select distinct PPC_Creative_GK from [Edge_OLTP].[dbo].UserProcess_GUI_PaidAdgroupCreative)
	
   select account_id, COUNT(*) as missingPPCCreativesCount
   from #missingPPCCreatives 
   group by account_id
   order by 1
   
   
    -- locate missing creative_gks
   select distinct account_id, Creative_GK
   into #Creative_GKs
   from  [Edge_OLTP].[dbo].[Paid_API_AllColumns]
   
   select * into #missingCreatives 
   from #Creative_GKs
   where Creative_GK not in (select distinct Creative_GK from [Edge_OLTP].[dbo].UserProcess_GUI_Creative)
	
   select account_id, COUNT(*)as missingCreativesCount
   from #missingCreatives 
   group by account_id
   order by 1
   
    -- locate missing gateway_gks
   select distinct account_id, Gateway_GK
   into #Gateway_GKs
   from  [Edge_OLTP].[dbo].[Paid_API_AllColumns]
   
  
   select * into #missingGateways
   from #Gateway_GKs
   where Gateway_GK not in (select distinct Gateway_GK from [Edge_OLTP].[dbo].UserProcess_GUI_Gateway)
	
   select account_id, COUNT(*) as missingGatewaysCount
   from #missingGateways 
   group by account_id
   order by 1