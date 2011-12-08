
-- ======================
-- creatives
select easy.Creative_GK as creative_tocopy, edge.Creative_GK as creative_todelete
into #creatives
from
	[easynet_OLTP].dbo.UserProcess_GUI_Creative easy
	left outer join [Edge_OLTP].dbo.UserProcess_GUI_Creative edge on
		edge.Account_ID = easy.Account_ID and
		isnull(edge.Creative_Title, '') = isnull(easy.Creative_Title, '') COLLATE Hebrew_CI_AI and
		isnull(edge.Creative_Desc1, '') = isnull(easy.Creative_Desc1, '') COLLATE Hebrew_CI_AI and
		isnull(edge.Creative_Desc2, '')  = isnull( easy.Creative_Desc2, '') COLLATE Hebrew_CI_AI
	inner join [Edge_OLTP].dbo.User_GUI_Account AC
		on AC.account_id = easy.Account_ID and
		AC.[Status] != 0
where
	(edge.Creative_GK is null or edge.Creative_GK != easy.Creative_GK )
	;
select COUNT(distinct creative_tocopy) as creative_tocopy, COUNT(distinct creative_todelete) as creative_todelete  from #creatives;

-- ======================
-- keywords
select easy.Keyword_GK as kw_tocopy, edge.Keyword_GK as kw_todelete
into #keywords
from
	[easynet_OLTP].dbo.UserProcess_GUI_Keyword easy
	left outer join [Edge_OLTP].dbo.UserProcess_GUI_Keyword edge on
		edge.Account_ID = easy.Account_ID and
		isnull(edge.Keyword, '') = isnull(easy.Keyword, '') COLLATE Hebrew_CI_AI 
	inner join [Edge_OLTP].dbo.User_GUI_Account AC
		on AC.account_id = easy.Account_ID and
		AC.[Status] != 0
where
	(edge.Keyword_GK is null or edge.Keyword_GK != easy.Keyword_GK );
select COUNT(distinct kw_tocopy) as kw_tocopy, COUNT(distinct kw_todelete) as kw_todelete from #keywords;

-- ======================
-- sites
select easy.Site_GK as site_tocopy, edge.Site_GK as site_todelete
into #sites
from
	[easynet_OLTP].dbo.UserProcess_GUI_Site easy
	left outer join [Edge_OLTP].dbo.UserProcess_GUI_Site edge on
		edge.Account_ID = easy.Account_ID and
		isnull(edge.Site, '') = isnull(easy.Site, '') COLLATE Hebrew_CI_AI 
	inner join [Edge_OLTP].dbo.User_GUI_Account AC
		on AC.account_id = easy.Account_ID and
		AC.[Status] != 0
where
	(edge.Site_GK is null or edge.Site_GK != easy.Site_GK )
select COUNT(distinct site_tocopy) as site_tocopy, COUNT(distinct site_todelete) as site_todelete from #sites;

-- ======================
-- campaigns

select easy.Campaign_GK as campaign_tocopy, edge.Campaign_GK as campaign_todelete
into #campaigns
from
	[easynet_OLTP].dbo.UserProcess_GUI_PaidCampaign easy
	left outer join [Edge_OLTP].dbo.UserProcess_GUI_PaidCampaign edge on
		edge.Account_ID = easy.Account_ID and
		edge.Channel_ID = easy.Channel_ID and
		edge.campaign  = easy.campaign COLLATE Hebrew_CI_AI
	inner join [Edge_OLTP].dbo.User_GUI_Account AC
		on AC.account_id = easy.Account_ID and
		AC.[Status] != 0
where
	(edge.Campaign_GK is null or edge.Campaign_GK != easy.Campaign_GK )
;
select COUNT(distinct campaign_tocopy) as campaign_tocopy, COUNT(distinct campaign_todelete) as campaign_todelete from #campaigns;

-- ======================
-- adgroups
select * 
into #adgroups
from
(
	-- get invalid adgroups from VALID campaigns
	select easy.Adgroup_GK as adgroup_tocopy, edge.Adgroup_GK as adgroup_todelete
	from
		[easynet_OLTP].dbo.UserProcess_GUI_PaidAdGroup easy
		left outer join [Edge_OLTP].dbo.UserProcess_GUI_PaidAdGroup edge on
			edge.Account_ID = easy.Account_ID and
			edge.Channel_ID = easy.Channel_ID and
			edge.Campaign_GK = easy.Campaign_GK and
			isnull(edge.adgroup,'')  = isnull(easy.adgroup,'') COLLATE Hebrew_CI_AI
		inner join [Edge_OLTP].dbo.User_GUI_Account AC
			on AC.account_id = easy.Account_ID and 
			AC.[Status] != 0
	where
		(edge.Adgroup_GK is null or edge.Adgroup_GK != easy.Adgroup_GK ) and
		edge.Campaign_GK not in (select campaign_todelete from #campaigns)
		
	union all
	
	-- get invalid adgroups from INVALID campaigns
	select NULL as adgroup_tocopy, edge.Adgroup_GK as adgroup_todelete
	from
		[Edge_OLTP].dbo.UserProcess_GUI_PaidAdGroup edge
	where
		edge.Campaign_GK in (select campaign_todelete from #campaigns)
		
	union all
	
	-- add missing adgroups that need copying
	select easy.Adgroup_GK as adgroup_tocopy, NULL as adgroup_todelete
	from
		[easynet_OLTP].dbo.UserProcess_GUI_PaidAdGroup easy
	where
		easy.Campaign_GK in (select campaign_tocopy from #campaigns)
) as ad;
	
select COUNT(distinct adgroup_tocopy) as adgroup_tocopy, COUNT(distinct adgroup_todelete) as adgroup_todelete from #adgroups;

-- ======================
-- ppc creatives
select * 
into #ppccreatives
from
(
	-- get invalid creatives from VALID campaigns/adgroup/creative matches
	select easy.PPC_Creative_GK as ppccreative_tocopy, edge.PPC_Creative_GK as ppccreative_todelete
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
		edge.Campaign_GK not in (select campaign_todelete from #campaigns) and
		edge.Adgroup_GK not in (select adgroup_todelete from #adgroups) and
		edge.Creative_GK not in (select creative_todelete from #creatives)
		
	union all
	
	-- get invalid creatives from INVALID campaigns/adgroup/creative matches
	select NULL as ppccreative_tocopy, edge.PPC_Creative_GK as ppccreative_todelete
	from
		[Edge_OLTP].dbo.UserProcess_GUI_PaidAdgroupCreative edge
	where
		edge.Campaign_GK in (select campaign_todelete from #campaigns) or
		edge.Adgroup_GK in (select adgroup_todelete from #adgroups) or
		edge.Creative_GK in (select creative_todelete from #creatives)
		
	union all
	
	-- get missing creatives
	select easy.PPC_Creative_GK as ppccreative_tocopy, NULL as ppccreative_todelete
	from
		[easynet_OLTP].dbo.UserProcess_GUI_PaidAdgroupCreative easy
	where
		easy.Campaign_GK in (select campaign_tocopy from #campaigns) or
		easy.Adgroup_GK in (select adgroup_tocopy from #adgroups) or
		easy.Creative_GK in (select creative_tocopy from #creatives)
) as ad;
	
select COUNT(distinct ppccreative_tocopy) as ppccreative_tocopy, COUNT(distinct ppccreative_todelete) as ppccreative_todelete from #ppccreatives;

-- ======================
-- ppc keywords
select * 
into #ppckeywords
from
(
	-- get invalid creatives from VALID campaigns/adgroup/creative matches
	select easy.PPC_Keyword_GK as ppckw_tocopy, edge.PPC_Keyword_GK as ppckw_todelete
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
		edge.Campaign_GK not in (select campaign_todelete from #campaigns) and
		edge.Adgroup_GK not in (select adgroup_todelete from #adgroups) and
		edge.Keyword_GK not in (select kw_todelete from #keywords)
		
	union all
	
	-- get invalid creatives from INVALID campaigns/adgroup/creative matches
	select NULL as ppckw_tocopy, edge.PPC_Keyword_GK as ppckw_todelete
	from
		[Edge_OLTP].dbo.UserProcess_GUI_PaidAdgroupKeyword edge
	where
		edge.Campaign_GK in (select campaign_todelete from #campaigns) or
		edge.Adgroup_GK in (select adgroup_todelete from #adgroups) or
		edge.Keyword_GK in (select kw_todelete from #keywords)
		
	union all
	
	-- get missing keywords
	select easy.PPC_Keyword_GK as ppckw_tocopy, NULL as ppckw_todelete
	from
		[easynet_OLTP].dbo.UserProcess_GUI_PaidAdgroupKeyword easy
	where
		easy.Campaign_GK in (select campaign_tocopy from #campaigns) or
		easy.Adgroup_GK in (select adgroup_tocopy from #adgroups) or
		easy.Keyword_GK in (select kw_tocopy from #keywords)
) as ad;
	
select COUNT(distinct ppckw_tocopy) as ppckw_tocopy, COUNT(distinct ppckw_todelete) as ppckw_todelete from #ppckeywords;

-- ======================
-- ppc sites
select * 
into #ppcsites
from
(
	-- get invalid creatives from VALID campaigns/adgroup/creative matches
	select easy.PPC_Site_GK as ppcsite_tocopy, edge.PPC_Site_GK as ppcsite_todelete
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
		edge.Campaign_GK not in (select campaign_todelete from #campaigns) and
		edge.Adgroup_GK not in (select adgroup_todelete from #adgroups) and
		edge.Site_GK not in (select site_todelete from #sites)
		
	union all
	
	-- get invalid creatives from INVALID campaigns/adgroup/creative matches
	select NULL as ppcsite_tocopy, edge.PPC_Site_GK as ppcsite_todelete
	from
		[Edge_OLTP].dbo.UserProcess_GUI_PaidAdgroupSite edge
	where
		edge.Campaign_GK in (select campaign_todelete from #campaigns) or
		edge.Adgroup_GK in (select adgroup_todelete from #adgroups) or
		edge.Site_GK in (select site_todelete from #sites)
		
	union all
	
	-- get missing sites
	select easy.PPC_Site_GK as ppckw_tocopy, NULL as ppckw_todelete
	from
		[easynet_OLTP].dbo.UserProcess_GUI_PaidAdgroupSite easy
	where
		easy.Campaign_GK in (select campaign_tocopy from #campaigns) or
		easy.Adgroup_GK in (select adgroup_tocopy from #adgroups) or
		easy.Site_GK in (select site_tocopy from #sites)
) as ad;
	
select COUNT(distinct ppcsite_tocopy) as ppcsite_tocopy, COUNT(distinct ppcsite_todelete) as ppcsite_todelete from #ppcsites;

-- ======================
-- ppc sites
select * 
into #gateways
from
(
	-- get invalid creatives from VALID campaigns/adgroup/creative matches
	select easy.Gateway_GK as gw_tocopy, edge.Gateway_GK as gw_todelete
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
		edge.Campaign_GK not in (select campaign_todelete from #campaigns) and
		edge.Adgroup_GK not in (select adgroup_todelete from #adgroups) and
		(
			(edge.Reference_Type is null) or
			(edge.Reference_Type = 0 and edge.Reference_ID not in (select creative_todelete from #creatives)) or
			(edge.Reference_Type = 1 and edge.Reference_ID not in (select kw_todelete from #keywords))
		)		
	union all
	
	-- get invalid creatives from INVALID campaigns/adgroup/creative matches
	select NULL as gw_tocopy, edge.Gateway_GK as gw_todelete
	from
		[Edge_OLTP].dbo.UserProcess_GUI_Gateway edge
	where
		edge.Campaign_GK in (select campaign_todelete from #campaigns) and
		edge.Adgroup_GK in (select adgroup_todelete from #adgroups) and
		(
			(edge.Reference_Type is null) or
			(edge.Reference_Type = 0 and edge.Reference_ID in (select creative_todelete from #creatives)) or
			(edge.Reference_Type = 1 and edge.Reference_ID in (select kw_todelete from #keywords))
		)
	
	union all
	
	-- add missing gateways
	select easy.Gateway_GK as gw_tocopy, NULL as gw_todelete
	from
		[easynet_OLTP].dbo.UserProcess_GUI_Gateway easy
	where
		easy.Campaign_GK in (select campaign_tocopy from #campaigns) or
		easy.Adgroup_GK in (select adgroup_tocopy from #adgroups) or
		(
			(easy.Reference_Type is null) or
			(easy.Reference_Type = 0 and easy.Reference_ID in (select creative_tocopy from #creatives)) or
			(easy.Reference_Type = 1 and easy.Reference_ID in (select kw_tocopy from #keywords))
		)
) as ad;
	
select COUNT(distinct gw_tocopy) as gw_tocopy, COUNT(distinct gw_todelete) as gw_todelete from #gateways;

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
