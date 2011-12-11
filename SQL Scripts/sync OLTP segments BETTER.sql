-- =====================================================
-- GET IDENTITIES
-- =====================================================

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
;
create nonclustered index temp_creatives_easy on #creatives ( creative_easy asc );
create nonclustered index temp_creatives_edge on #creatives ( creative_edge asc );

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
;
create nonclustered index temp_keywords_easy on #keywords ( kw_easy asc );
create nonclustered index temp_keywords_edge on #keywords ( kw_edge asc );

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
;
create nonclustered index temp_sites_easy on #sites ( site_easy asc );
create nonclustered index temp_sites_edge on #sites ( site_edge asc );

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
;
create nonclustered index temp_campaigns_easy on #campaigns ( campaign_easy asc );
create nonclustered index temp_campaigns_edge on #campaigns ( campaign_edge asc );

-- ======================
-- adgroups

select easy.Adgroup_GK as adgroup_easy, edge.Adgroup_GK as adgroup_edge
into #adgroups
from
	[easynet_OLTP].dbo.UserProcess_GUI_PaidAdGroup easy
	inner join #campaigns on
		#campaigns.campaign_easy = easy.Campaign_GK
	inner join [Edge_OLTP].dbo.UserProcess_GUI_PaidAdGroup edge on
		edge.Account_ID = easy.Account_ID and
		edge.Channel_ID = easy.Channel_ID and
		edge.Campaign_GK = #campaigns.campaign_edge and
		isnull(edge.adgroup,'')  = isnull(easy.adgroup,'') COLLATE Hebrew_CI_AI
	inner join [Edge_OLTP].dbo.User_GUI_Account AC
		on AC.account_id = easy.Account_ID and 
		AC.[Status] != 0

create nonclustered index temp_adgroups_easy on #adgroups ( adgroup_easy asc );
create nonclustered index temp_adgroups_edge on #adgroups ( adgroup_edge asc );

-- ======================
-- ppc creatives
select easy.PPC_Creative_GK as ppccreative_easy, edge.PPC_Creative_GK as ppccreative_edge
into #ppccreatives
from
	[easynet_OLTP].dbo.UserProcess_GUI_PaidAdgroupCreative easy
	inner join #campaigns on
		easy.Campaign_GK = #campaigns.campaign_easy
	inner join #adgroups on
		easy.AdGroup_GK = #adgroups.adgroup_easy
	inner join #creatives on 
		easy.Creative_GK = #creatives.creative_easy
	inner join [Edge_OLTP].dbo.UserProcess_GUI_PaidAdgroupCreative edge on
		edge.Account_ID = easy.Account_ID and
		edge.Channel_ID = easy.Channel_ID and
		edge.Campaign_GK = #campaigns.campaign_edge and
		edge.AdGroup_GK = #adgroups.adgroup_edge and
		edge.Creative_GK = #creatives.creative_edge and
		isnull(edge.creativeDestUrl,'') = isnull(easy.creativeDestUrl,'') COLLATE Hebrew_CI_AI and
		isnull(edge.creativeVisUrl,'') = isnull(easy.creativeVisUrl,'') COLLATE Hebrew_CI_AI
	inner join [Edge_OLTP].dbo.User_GUI_Account AC
		on AC.account_id = easy.Account_ID and
		AC.[Status] != 0
;
create nonclustered index temp_ppccreative_easy on #ppccreatives ( ppccreative_easy asc );
create nonclustered index temp_ppccreative_edge on #ppccreatives ( ppccreative_edge asc );

-- ======================
-- ppc keywords

select easy.PPC_Keyword_GK as ppckw_easy, edge.PPC_Keyword_GK as ppckw_edge
into #ppckeywords
from
	[easynet_OLTP].dbo.UserProcess_GUI_PaidAdgroupKeyword easy
	inner join #campaigns on
		easy.Campaign_GK = #campaigns.campaign_easy
	inner join #adgroups on
		easy.AdGroup_GK = #adgroups.adgroup_easy
	inner join #keywords on
		easy.Keyword_GK = #keywords.kw_easy
	inner join [Edge_OLTP].dbo.UserProcess_GUI_PaidAdgroupKeyword edge on
		edge.Account_ID = easy.Account_ID and
		edge.Channel_ID = easy.Channel_ID and
		edge.Campaign_GK = #campaigns.campaign_edge and
		edge.AdGroup_GK = #adgroups.adgroup_edge and
		edge.Keyword_GK = #keywords.kw_edge and
		edge.MatchType = easy.MatchType
	inner join [Edge_OLTP].dbo.User_GUI_Account AC
		on AC.account_id = easy.Account_ID and
		AC.[Status] != 0
;
create nonclustered index temp_ppckeywords_easy on #ppckeywords ( ppckw_easy asc );
create nonclustered index temp_ppckeywords_edge on #ppckeywords ( ppckw_edge asc );

-- ======================
-- ppc sites

select easy.PPC_Site_GK as ppcsite_easy, edge.PPC_Site_GK as ppcsite_edge
into #ppcsites
from
	[easynet_OLTP].dbo.UserProcess_GUI_PaidAdgroupSite easy
	inner join #campaigns on
		easy.Campaign_GK = #campaigns.campaign_easy
	inner join #adgroups on
		easy.AdGroup_GK = #adgroups.adgroup_easy
	inner join #sites on
		easy.Site_GK = #sites.site_easy
	inner join [Edge_OLTP].dbo.UserProcess_GUI_PaidAdgroupSite edge on
		edge.Account_ID = easy.Account_ID and
		edge.Channel_ID = easy.Channel_ID and
		edge.Campaign_GK = #campaigns.campaign_edge and
		edge.AdGroup_GK = #adgroups.adgroup_edge and
		edge.Site_GK = #sites.site_edge and
		edge.MatchType = easy.MatchType
	inner join [Edge_OLTP].dbo.User_GUI_Account AC
		on AC.account_id = easy.Account_ID and
		AC.[Status] != 0
;
create nonclustered index temp_ppcsites_easy on #ppcsites ( ppcsite_easy asc );
create nonclustered index temp_ppcsites_edge on #ppcsites ( ppcsite_edge asc );

-- ======================
-- gateways
select easy.Gateway_GK as gw_easy, edge.Gateway_GK as gw_edge
into #gateways
from
	[easynet_OLTP].dbo.UserProcess_GUI_Gateway easy
	inner join [Edge_OLTP].dbo.UserProcess_GUI_Gateway edge on
		edge.Account_ID = easy.Account_ID and
		edge.Gateway_id = CAST(easy.Gateway_id AS nvarchar(MAX))
	inner join [Edge_OLTP].dbo.User_GUI_Account AC
		on AC.account_id = easy.Account_ID and
		AC.[Status] != 0
;
create nonclustered index temp_gateways_easy on #gateways ( gw_easy asc );
create nonclustered index temp_gateways_edge on #gateways ( gw_edge asc );

-- =====================================================
-- UPDATE SEGMENTS
-- =====================================================


-- campaigns
update [Edge_OLTP].dbo.UserProcess_GUI_PaidCampaign
set
	Segment1 = easy.Segment1,
	Segment2 = easy.Segment2,
	Segment3 = easy.Segment3,
	Segment4 = easy.Segment4,
	Segment5 = easy.Segment5
from
	[Edge_OLTP].dbo.UserProcess_GUI_PaidCampaign edge
	inner join #campaigns on
		edge.Campaign_GK = #campaigns.campaign_edge
	inner join [easynet_OLTP].dbo.UserProcess_GUI_PaidCampaign easy on
		easy.Campaign_GK = #campaigns.campaign_easy
;

-- adgroups
update [Edge_OLTP].dbo.UserProcess_GUI_PaidAdGroup
set
	Segment1 = easy.Segment1,
	Segment2 = easy.Segment2,
	Segment3 = easy.Segment3,
	Segment4 = easy.Segment4,
	Segment5 = easy.Segment5
from
	[Edge_OLTP].dbo.UserProcess_GUI_PaidAdGroup edge
	inner join #adgroups on
		edge.Adgroup_GK = #adgroups.adgroup_edge
	inner join [easynet_OLTP].dbo.UserProcess_GUI_PaidAdGroup easy on
		easy.Adgroup_GK = #adgroups.adgroup_easy
;

-- ppc creatives
update [Edge_OLTP].dbo.UserProcess_GUI_PaidAdgroupCreative
set
	Segment1 = easy.Segment1,
	Segment2 = easy.Segment2,
	Segment3 = easy.Segment3,
	Segment4 = easy.Segment4,
	Segment5 = easy.Segment5
from
	[Edge_OLTP].dbo.UserProcess_GUI_PaidAdgroupCreative edge
	inner join #ppccreatives on
		edge.PPC_Creative_GK = #ppccreatives.ppccreative_edge
	inner join [easynet_OLTP].dbo.UserProcess_GUI_PaidAdgroupCreative easy on
		easy.PPC_Creative_GK = #ppccreatives.ppccreative_easy
;

-- ppc keywords
update [Edge_OLTP].dbo.UserProcess_GUI_PaidAdgroupKeyword
set
	Segment1 = easy.Segment1,
	Segment2 = easy.Segment2,
	Segment3 = easy.Segment3,
	Segment4 = easy.Segment4,
	Segment5 = easy.Segment5
from
	[Edge_OLTP].dbo.UserProcess_GUI_PaidAdgroupKeyword edge
	inner join #ppckeywords on
		edge.PPC_Keyword_GK = #ppckeywords.ppckw_edge
	inner join [easynet_OLTP].dbo.UserProcess_GUI_PaidAdgroupKeyword easy on
		easy.PPC_Keyword_GK = #ppckeywords.ppckw_easy
;

-- ppc sites
update [Edge_OLTP].dbo.UserProcess_GUI_PaidAdgroupSite
set
	Segment1 = easy.Segment1,
	Segment2 = easy.Segment2,
	Segment3 = easy.Segment3,
	Segment4 = easy.Segment4,
	Segment5 = easy.Segment5
from
	[Edge_OLTP].dbo.UserProcess_GUI_PaidAdgroupSite edge
	inner join #ppcsites on
		edge.PPC_Site_GK = #ppcsites.ppcsite_edge
	inner join [easynet_OLTP].dbo.UserProcess_GUI_PaidAdgroupSite easy on
		easy.PPC_Site_GK = #ppcsites.ppcsite_easy
;

-- gateways
update [Edge_OLTP].dbo.UserProcess_GUI_Gateway
set
	Segment1 = easy.Segment1,
	Segment2 = easy.Segment2,
	Segment3 = easy.Segment3,
	Segment4 = easy.Segment4,
	Segment5 = easy.Segment5,
	Page_GK = easy.Page_GK
from
	[Edge_OLTP].dbo.UserProcess_GUI_Gateway edge
	inner join #gateways on
		edge.Gateway_GK = #gateways.gw_edge
	inner join [easynet_OLTP].dbo.UserProcess_GUI_Gateway easy on
		easy.Gateway_GK = #gateways.gw_easy
;

-- =====================================================
-- CLEANUP
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
