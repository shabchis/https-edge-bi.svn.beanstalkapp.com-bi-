
-- ======================
-- creatives
select easy.Creative_GK as creative_easy, edge.Creative_GK as creative_edge
into #creatives
from
	[easynet_OLTP].dbo.UserProcess_GUI_Creative easy
	inner join [Edge_OLTP].dbo.UserProcess_GUI_Creative edge on
		edge.Account_ID = easy.Account_ID and
		isnull(edge.Creative_Title, '') = isnull(easy.Creative_Title, '') COLLATE Hebrew_CI_AI and
		isnull(edge.Creative_Desc1, '') = isnull(easy.Creative_Desc1, '') COLLATE Hebrew_CI_AI and
		isnull(edge.Creative_Desc2, '')  = isnull( easy.Creative_Desc2, '') COLLATE Hebrew_CI_AI
	inner join [Edge_OLTP].dbo.User_GUI_Account AC
		on AC.account_id = easy.Account_ID and
		AC.[Status] != 0
where
	edge.Creative_GK != easy.Creative_GK
;

-- ======================
-- keywords
select easy.Keyword_GK as kw_easy, edge.Keyword_GK as kw_edge
into #keywords
from
	[easynet_OLTP].dbo.UserProcess_GUI_Keyword easy
	inner join [Edge_OLTP].dbo.UserProcess_GUI_Keyword edge on
		edge.Account_ID = easy.Account_ID and
		isnull(edge.Keyword, '') = isnull(easy.Keyword, '') COLLATE Hebrew_CI_AI 
	inner join [Edge_OLTP].dbo.User_GUI_Account AC
		on AC.account_id = easy.Account_ID and
		AC.[Status] != 0
where
	edge.Keyword_GK != easy.Keyword_GK
;

-- ======================
-- sites
select easy.Site_GK as site_easy, edge.Site_GK as site_edge
into #sites
from
	[easynet_OLTP].dbo.UserProcess_GUI_Site easy
	inner join [Edge_OLTP].dbo.UserProcess_GUI_Site edge on
		edge.Account_ID = easy.Account_ID and
		isnull(edge.Site, '') = isnull(easy.Site, '') COLLATE Hebrew_CI_AI 
	inner join [Edge_OLTP].dbo.User_GUI_Account AC
		on AC.account_id = easy.Account_ID and
		AC.[Status] != 0
where
	edge.Site_GK != easy.Site_GK
;

-- ======================
-- campaigns

select easy.Campaign_GK as campaign_easy, edge.Campaign_GK as campaign_edge
into #campaigns
from
	[easynet_OLTP].dbo.UserProcess_GUI_PaidCampaign easy
	inner join [Edge_OLTP].dbo.UserProcess_GUI_PaidCampaign edge on
		edge.Account_ID = easy.Account_ID and
		edge.Channel_ID = easy.Channel_ID and
		isnull(edge.campaign,'')  = isnull(easy.campaign,'') COLLATE Hebrew_CI_AI
	inner join [Edge_OLTP].dbo.User_GUI_Account AC
		on AC.account_id = easy.Account_ID and
		AC.[Status] != 0
where
	edge.Campaign_GK != easy.Campaign_GK
;

-- ======================
-- adgroups
select * 
into #adgroups
from
(
	-- get invalid adgroups from VALID campaigns
	select easy.Adgroup_GK as adgroup_easy, edge.Adgroup_GK as adgroup_edge
	from
		[easynet_OLTP].dbo.UserProcess_GUI_PaidAdGroup easy
		inner join [Edge_OLTP].dbo.UserProcess_GUI_PaidAdGroup edge on
			edge.Account_ID = easy.Account_ID and
			edge.Channel_ID = easy.Channel_ID and
			edge.Campaign_GK = easy.Campaign_GK and
			isnull(edge.adgroup,'')  = isnull(easy.adgroup,'') COLLATE Hebrew_CI_AI
		inner join [Edge_OLTP].dbo.User_GUI_Account AC
			on AC.account_id = easy.Account_ID and 
			AC.[Status] != 0
	where
		edge.Adgroup_GK != easy.Adgroup_GK  and
		edge.Campaign_GK not in (select campaign_edge from #campaigns)
		
	union all
	
	-- get invalid adgroups from INVALID campaigns
	select NULL as adgroup_easy, edge.Adgroup_GK as adgroup_edge
	from
		[Edge_OLTP].dbo.UserProcess_GUI_PaidAdGroup edge
	where
		edge.Campaign_GK in (select campaign_edge from #campaigns)
		
	union all
	
	-- add missing adgroups that need copying
	select easy.Adgroup_GK as adgroup_easy, NULL as adgroup_edge
	from
		[easynet_OLTP].dbo.UserProcess_GUI_PaidAdGroup easy
	where
		easy.Campaign_GK in (select campaign_easy from #campaigns)
) as ad;
	
select COUNT(distinct adgroup_easy) as adgroup_easy, COUNT(distinct adgroup_edge) as adgroup_edge from #adgroups;

-- ======================
-- ppc creatives
select * 
into #ppccreatives
from
(
	-- get invalid creatives from VALID campaigns/adgroup/creative matches
	select easy.PPC_Creative_GK as ppccreative_easy, edge.PPC_Creative_GK as ppccreative_edge
	from
		[easynet_OLTP].dbo.UserProcess_GUI_PaidAdgroupCreative easy
		left outer join [Edge_OLTP].dbo.UserProcess_GUI_PaidAdgroupCreative edge on
			edge.Account_ID = easy.Account_ID and
			edge.Channel_ID = easy.Channel_ID and
			edge.Campaign_GK = easy.Campaign_GK and
			edge.AdGroup_GK = easy.AdGroup_GK and
			edge.Creative_GK = easy.Creative_GK and
			isnull(edge.creativeDestUrl,'') = isnull(easy.creativeDestUrl,'') COLLATE Hebrew_CI_AI and
			isnull(edge.creativeVisUrl,'') = isnull(easy.creativeVisUrl,'') COLLATE Hebrew_CI_AI
		inner join [Edge_OLTP].dbo.User_GUI_Account AC
			on AC.account_id = easy.Account_ID and
			AC.[Status] != 0
	where
		(edge.PPC_Creative_GK is null or edge.PPC_Creative_GK != easy.PPC_Creative_GK ) and
		edge.Campaign_GK not in (select campaign_edge from #campaigns) and
		edge.Adgroup_GK not in (select adgroup_edge from #adgroups) and
		edge.Creative_GK not in (select creative_edge from #creatives)
		
	union all
	
	-- get invalid creatives from INVALID campaigns/adgroup/creative matches
	select NULL as ppccreative_easy, edge.PPC_Creative_GK as ppccreative_edge
	from
		[Edge_OLTP].dbo.UserProcess_GUI_PaidAdgroupCreative edge
	where
		edge.Campaign_GK in (select campaign_edge from #campaigns) or
		edge.Adgroup_GK in (select adgroup_edge from #adgroups) or
		edge.Creative_GK in (select creative_edge from #creatives)
		
	union all
	
	-- get missing creatives
	select easy.PPC_Creative_GK as ppccreative_easy, NULL as ppccreative_edge
	from
		[easynet_OLTP].dbo.UserProcess_GUI_PaidAdgroupCreative easy
	where
		easy.Campaign_GK in (select campaign_easy from #campaigns) or
		easy.Adgroup_GK in (select adgroup_easy from #adgroups) or
		easy.Creative_GK in (select creative_easy from #creatives)
) as ad;
	
select COUNT(distinct ppccreative_easy) as ppccreative_easy, COUNT(distinct ppccreative_edge) as ppccreative_edge from #ppccreatives;

-- ======================
-- ppc keywords
select * 
into #ppckeywords
from
(
	-- get invalid creatives from VALID campaigns/adgroup/creative matches
	select easy.PPC_Keyword_GK as ppckw_easy, edge.PPC_Keyword_GK as ppckw_edge
	from
		[easynet_OLTP].dbo.UserProcess_GUI_PaidAdgroupKeyword easy
		left outer join [Edge_OLTP].dbo.UserProcess_GUI_PaidAdgroupKeyword edge on
			edge.Account_ID = easy.Account_ID and
			edge.Channel_ID = easy.Channel_ID and
			edge.Campaign_GK = easy.Campaign_GK and
			edge.AdGroup_GK = easy.AdGroup_GK and
			edge.Keyword_GK = easy.Keyword_GK and
			edge.MatchType = easy.MatchType
		inner join [Edge_OLTP].dbo.User_GUI_Account AC
			on AC.account_id = easy.Account_ID and
			AC.[Status] != 0
	where
		(edge.PPC_Keyword_GK is null or edge.PPC_Keyword_GK != easy.PPC_Keyword_GK ) and
		edge.Campaign_GK not in (select campaign_edge from #campaigns) and
		edge.Adgroup_GK not in (select adgroup_edge from #adgroups) and
		edge.Keyword_GK not in (select kw_edge from #keywords)
		
	union all
	
	-- get invalid creatives from INVALID campaigns/adgroup/creative matches
	select NULL as ppckw_easy, edge.PPC_Keyword_GK as ppckw_edge
	from
		[Edge_OLTP].dbo.UserProcess_GUI_PaidAdgroupKeyword edge
	where
		edge.Campaign_GK in (select campaign_edge from #campaigns) or
		edge.Adgroup_GK in (select adgroup_edge from #adgroups) or
		edge.Keyword_GK in (select kw_edge from #keywords)
		
	union all
	
	-- get missing keywords
	select easy.PPC_Keyword_GK as ppckw_easy, NULL as ppckw_edge
	from
		[easynet_OLTP].dbo.UserProcess_GUI_PaidAdgroupKeyword easy
	where
		easy.Campaign_GK in (select campaign_easy from #campaigns) or
		easy.Adgroup_GK in (select adgroup_easy from #adgroups) or
		easy.Keyword_GK in (select kw_easy from #keywords)
) as ad;
	
select COUNT(distinct ppckw_easy) as ppckw_easy, COUNT(distinct ppckw_edge) as ppckw_edge from #ppckeywords;

-- ======================
-- ppc sites
select * 
into #ppcsites
from
(
	-- get invalid creatives from VALID campaigns/adgroup/creative matches
	select easy.PPC_Site_GK as ppcsite_easy, edge.PPC_Site_GK as ppcsite_edge
	from
		[easynet_OLTP].dbo.UserProcess_GUI_PaidAdgroupSite easy
		left outer join [Edge_OLTP].dbo.UserProcess_GUI_PaidAdgroupSite edge on
			edge.Account_ID = easy.Account_ID and
			edge.Channel_ID = easy.Channel_ID and
			edge.Campaign_GK = easy.Campaign_GK and
			edge.AdGroup_GK = easy.AdGroup_GK and
			edge.Site_GK = easy.Site_GK and
			edge.MatchType = easy.MatchType
		inner join [Edge_OLTP].dbo.User_GUI_Account AC
			on AC.account_id = easy.Account_ID and
			AC.[Status] != 0
	where
		(edge.PPC_Site_GK is null or edge.PPC_Site_GK != easy.PPC_Site_GK ) and
		edge.Campaign_GK not in (select campaign_edge from #campaigns) and
		edge.Adgroup_GK not in (select adgroup_edge from #adgroups) and
		edge.Site_GK not in (select site_edge from #sites)
		
	union all
	
	-- get invalid creatives from INVALID campaigns/adgroup/creative matches
	select NULL as ppcsite_easy, edge.PPC_Site_GK as ppcsite_edge
	from
		[Edge_OLTP].dbo.UserProcess_GUI_PaidAdgroupSite edge
	where
		edge.Campaign_GK in (select campaign_edge from #campaigns) or
		edge.Adgroup_GK in (select adgroup_edge from #adgroups) or
		edge.Site_GK in (select site_edge from #sites)
		
	union all
	
	-- get missing sites
	select easy.PPC_Site_GK as ppckw_easy, NULL as ppckw_edge
	from
		[easynet_OLTP].dbo.UserProcess_GUI_PaidAdgroupSite easy
	where
		easy.Campaign_GK in (select campaign_easy from #campaigns) or
		easy.Adgroup_GK in (select adgroup_easy from #adgroups) or
		easy.Site_GK in (select site_easy from #sites)
) as ad;
	
select COUNT(distinct ppcsite_easy) as ppcsite_easy, COUNT(distinct ppcsite_edge) as ppcsite_edge from #ppcsites;

-- ======================
-- ppc sites
select * 
into #gateways
from
(
	-- get invalid creatives from VALID campaigns/adgroup/creative matches
	select easy.Gateway_GK as gw_easy, edge.Gateway_GK as gw_edge
	from
		[easynet_OLTP].dbo.UserProcess_GUI_Gateway easy
		left outer join [Edge_OLTP].dbo.UserProcess_GUI_Gateway edge on
			edge.Account_ID = easy.Account_ID and
			edge.Gateway_id = easy.Gateway_id
		inner join [Edge_OLTP].dbo.User_GUI_Account AC
			on AC.account_id = easy.Account_ID and
			AC.[Status] != 0
	where
		(edge.Gateway_GK is null or edge.Gateway_GK != easy.Gateway_GK ) and
		edge.Campaign_GK not in (select campaign_edge from #campaigns) and
		edge.Adgroup_GK not in (select adgroup_edge from #adgroups) and
		(
			(edge.Reference_Type is null) or
			(edge.Reference_Type = 0 and edge.Reference_ID not in (select creative_edge from #creatives)) or
			(edge.Reference_Type = 1 and edge.Reference_ID not in (select kw_edge from #keywords))
		)		
	union all
	
	-- get invalid creatives from INVALID campaigns/adgroup/creative matches
	select NULL as gw_easy, edge.Gateway_GK as gw_edge
	from
		[Edge_OLTP].dbo.UserProcess_GUI_Gateway edge
	where
		edge.Campaign_GK in (select campaign_edge from #campaigns) and
		edge.Adgroup_GK in (select adgroup_edge from #adgroups) and
		(
			(edge.Reference_Type is null) or
			(edge.Reference_Type = 0 and edge.Reference_ID in (select creative_edge from #creatives)) or
			(edge.Reference_Type = 1 and edge.Reference_ID in (select kw_edge from #keywords))
		)
	
	union all
	
	-- add missing gateways
	select easy.Gateway_GK as gw_easy, NULL as gw_edge
	from
		[easynet_OLTP].dbo.UserProcess_GUI_Gateway easy
	where
		easy.Campaign_GK in (select campaign_easy from #campaigns) or
		easy.Adgroup_GK in (select adgroup_easy from #adgroups) or
		(
			(easy.Reference_Type is null) or
			(easy.Reference_Type = 0 and easy.Reference_ID in (select creative_easy from #creatives)) or
			(easy.Reference_Type = 1 and easy.Reference_ID in (select kw_easy from #keywords))
		)
) as ad;
	
select COUNT(distinct gw_easy) as gw_easy, COUNT(distinct gw_edge) as gw_edge from #gateways;

-- =====================================================
drop table #campaigns;
drop table #adgroups;
drop table #creatives;
drop table #keywords;
drop table #sites;
drop table #ppccreatives;
drop table #ppckeywords;
drop table #ppcsites;
drop table #gateways;
