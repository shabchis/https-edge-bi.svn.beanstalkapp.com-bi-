-- campaigns
select *
from
	[easynet_OLTP].dbo.UserProcess_GUI_PaidCampaign easy inner join
	[Edge_OLTP].dbo.UserProcess_GUI_PaidCampaign edge on
		edge.Campaign_GK = easy.Campaign_GK and
		edge.Account_ID = easy.Account_ID and
		(
			isnull(edge.Segment1, -1) <> isnull(easy.Segment1, -1) OR
			isnull(edge.Segment2, -1) <> isnull(easy.Segment2, -1) OR
			isnull(edge.Segment3, -1) <> isnull(easy.Segment3, -1) OR
			isnull(edge.Segment4, -1) <> isnull(easy.Segment4, -1) OR
			isnull(edge.Segment5, -1) <> isnull(easy.Segment5, -1)
		)

-- adgroups
select *
from
	[easynet_OLTP].dbo.UserProcess_GUI_PaidAdGroup easy inner join
	[Edge_OLTP].dbo.UserProcess_GUI_PaidAdGroup edge on
		edge.Adgroup_GK = easy.Adgroup_GK and
		edge.Account_ID = easy.Account_ID and
		(
			isnull(edge.Segment1, -1) <> isnull(easy.Segment1, -1) OR
			isnull(edge.Segment2, -1) <> isnull(easy.Segment2, -1) OR
			isnull(edge.Segment3, -1) <> isnull(easy.Segment3, -1) OR
			isnull(edge.Segment4, -1) <> isnull(easy.Segment4, -1) OR
			isnull(edge.Segment5, -1) <> isnull(easy.Segment5, -1)
		)

-- creatives
select *
from
	[easynet_OLTP].dbo.UserProcess_GUI_PaidAdgroupCreative easy inner join
	[Edge_OLTP].dbo.UserProcess_GUI_PaidAdgroupCreative edge on
		edge.PPC_Creative_GK = easy.PPC_Creative_GK and
		edge.Account_ID = easy.Account_ID and
		(
			isnull(edge.Segment1, -1) <> isnull(easy.Segment1, -1) OR
			isnull(edge.Segment2, -1) <> isnull(easy.Segment2, -1) OR
			isnull(edge.Segment3, -1) <> isnull(easy.Segment3, -1) OR
			isnull(edge.Segment4, -1) <> isnull(easy.Segment4, -1) OR
			isnull(edge.Segment5, -1) <> isnull(easy.Segment5, -1) OR
			isnull(edge.Page_GK, -1) <> isnull(easy.Page_GK, -1)
		)

-- keywords
select *
from
	[easynet_OLTP].dbo.UserProcess_GUI_PaidAdgroupKeyword easy inner join
	[Edge_OLTP].dbo.UserProcess_GUI_PaidAdgroupKeyword edge on
		edge.PPC_Keyword_GK = easy.PPC_Keyword_GK and
		edge.Account_ID = easy.Account_ID and
		(
			isnull(edge.Segment1, -1) <> isnull(easy.Segment1, -1) OR
			isnull(edge.Segment2, -1) <> isnull(easy.Segment2, -1) OR
			isnull(edge.Segment3, -1) <> isnull(easy.Segment3, -1) OR
			isnull(edge.Segment4, -1) <> isnull(easy.Segment4, -1) OR
			isnull(edge.Segment5, -1) <> isnull(easy.Segment5, -1)
		)

-- sites
select *
from
	[easynet_OLTP].dbo.UserProcess_GUI_PaidAdgroupSite easy inner join
	[Edge_OLTP].dbo.UserProcess_GUI_PaidAdgroupSite edge on
		edge.PPC_Site_GK = easy.PPC_Site_GK and
		edge.Account_ID = easy.Account_ID and
		(
			isnull(edge.Segment1, -1) <> isnull(easy.Segment1, -1) OR
			isnull(edge.Segment2, -1) <> isnull(easy.Segment2, -1) OR
			isnull(edge.Segment3, -1) <> isnull(easy.Segment3, -1) OR
			isnull(edge.Segment4, -1) <> isnull(easy.Segment4, -1) OR
			isnull(edge.Segment5, -1) <> isnull(easy.Segment5, -1)
		)

-- gateways
select *
from
	[easynet_OLTP].dbo.UserProcess_GUI_Gateway easy inner join
	[Edge_OLTP].dbo.UserProcess_GUI_Gateway edge on
		edge.Gateway_GK = easy.Gateway_GK and
		edge.Account_ID = easy.Account_ID and
		(
			isnull(edge.Segment1, -1) <> isnull(easy.Segment1, -1) OR
			isnull(edge.Segment2, -1) <> isnull(easy.Segment2, -1) OR
			isnull(edge.Segment3, -1) <> isnull(easy.Segment3, -1) OR
			isnull(edge.Segment4, -1) <> isnull(easy.Segment4, -1) OR
			isnull(edge.Segment5, -1) <> isnull(easy.Segment5, -1)
		)