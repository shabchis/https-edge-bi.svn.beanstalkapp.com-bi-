-- load 1 month data to new fact tables
/*
drop table [Seperia_TempDB].[dbo].[UserProcess_GUI_Gateway_BCK]
drop table [Seperia_TempDB].[dbo].[User_GUI_AccountPermission_bck]
drop table [Seperia_TempDB].[dbo].[User_GUI_CampaignTargets_BCK]
drop table [Seperia_TempDB].[dbo].[UserProcess_GUI_Gateway_BCK]
drop table [Seperia_TempDB].[dbo].[UserProcess_GUI_Gateway_TEMP]
drop table [Seperia_TempDB].[dbo].[UserProcess_GUI_Keyword_BCK]
drop table [Seperia_TempDB].[dbo].[UserProcess_GUI_Keyword_TRANSFER]
drop table [Seperia_TempDB].[dbo].[UserProcess_GUI_PaidAdGroup_BCK]
drop table [Seperia_TempDB].[dbo].[UserProcess_GUI_PaidAdgroupCreative_BCK]
drop table [Seperia_TempDB].[dbo].[UserProcess_GUI_PaidAdgroupKeyword_BCK]
drop table [Seperia_TempDB].[dbo].[UserProcess_GUI_PaidAdgroupSite_BCK]
drop table [Seperia_TempDB].[dbo].[UserProcess_GUI_PaidCampaign_BCK]
drop table [Seperia_TempDB].[dbo].[UserProcess_GUI_PaidCampaign_OLD]
drop table [Seperia_TempDB].[dbo].[UserProcess_GUI_PaidAdgroupSite_old]
drop table [Seperia_TempDB].[dbo].[User_GUI_UserGroupUser1]
drop table [Seperia_TempDB].[dbo].[User_GUI_UserGroup1]
drop table [Seperia_TempDB].[dbo].[User_GUI_User1]
drop table [Seperia_TempDB].[dbo].[User_GUI_CampaignTargets1]
*/
----------------------- OLTP
truncate table [Seperia_TempDB].[dbo].Log_GetGatewayGK
truncate table [Seperia_TempDB].[dbo].Paid_API_AllColumns
truncate table [Seperia_TempDB].[dbo].BackOffice_Client_Gateway
truncate table [Seperia_TempDB].[dbo].Paid_API_Content

SELECT *
INTO [Seperia_TempDB].[dbo].Paid_API_AllColumns_v29_1month
FROM [Seperia_TempDB].[dbo].[Paid_API_AllColumns_v29]
WHERE day_code > 20131000
GO

SELECT *
INTO [Seperia_TempDB].[dbo].[BackOffice_Client_Gateway_v29_1month]
FROM [Seperia_TempDB].[dbo].[BackOffice_Client_Gateway_v29]
WHERE day_code > 20131000
GO

SELECT *
INTO [Seperia_TempDB].[dbo].Paid_API_Content_v29_1month
FROM [Seperia_TempDB].[dbo].[Paid_API_Content_v29]
WHERE day_code> 20130915
GO

SELECT *
INTO [Seperia_TempDB].[dbo].[UserProcess_GUI_PaidAdgroupSite_1month]
FROM [Seperia_TempDB].[dbo].UserProcess_GUI_PaidAdgroupSite
WHERE account_id in (7,61,109,113,1006,1239,1249,1240235,1240239,1240244,1240250,1240255,1240257,1240259,1240261,1240262,1240271,1240272 )
GO

SELECT *
INTO [Seperia_TempDB].[dbo].[UserProcess_GUI_Site_1month]
FROM [Seperia_TempDB].[dbo].[UserProcess_GUI_Site]
WHERE account_id in (7,61,109,113,1006,1239,1249,1240235,1240239,1240244,1240250,1240255,1240257,1240259,1240261,1240262,1240271,1240272 )
GO

------------------------------ DWH
-- execute [dbo].[truncate_tables_by_name] 'Stg_' 

SELECT *
INTO [Seperia_DWH_TempDB].[dbo].[Dwh_Fact_BackOffice_Gateways_1month]
FROM [Seperia_DWH_TempDB].[dbo].[Dwh_Fact_BackOffice_Gateways]
WHERE day_id > 20131000
GO

SELECT *
INTO [Seperia_DWH_TempDB].[dbo].[Dwh_Fact_PPC_Campaigns_1month]
FROM [Seperia_DWH_TempDB].[dbo].[Dwh_Fact_PPC_Campaigns]
WHERE day_id > 20131000
GO

SELECT *
INTO [Seperia_DWH_TempDB].[dbo].[Dwh_Fact_PPC_Content_1month]
FROM [Seperia_DWH_TempDB].[dbo].[Dwh_Fact_PPC_Content]
WHERE day_id > 20130915
GO

SELECT *
INTO [Seperia_DWH_TempDB].[dbo].[Dwh_Dim_PPC_Sites_1month]
FROM [Seperia_DWH_TempDB].[dbo].[Dwh_Dim_PPC_Sites]
WHERE account_id in (7,61,109,113,1006,1239,1249,1240235,1240239,1240244,1240250,1240255,1240257,1240259,1240261,1240262,1240271,1240272 )
GO






--------------------------- TESTS

SELECT count(*) as [BackOffice_Client_Gateway_v29_1month]
FROM [Seperia_TempDB].[dbo].[BackOffice_Client_Gateway_v29_1month]
GO

SELECT count(*) as Paid_API_AllColumns_v29_1month
FROM [Seperia_TempDB].[dbo].Paid_API_AllColumns_v29_1month
GO

SELECT count(*) Paid_API_Content_v29_1month
FROM [Seperia_TempDB].[dbo].Paid_API_Content_v29_1month
GO

SELECT count(*) [UserProcess_GUI_PaidAdgroupSite_1month]
FROM [Seperia_TempDB].[dbo].[UserProcess_GUI_PaidAdgroupSite_1month]
GO

SELECT count(*) [UserProcess_GUI_Site_1month]
FROM [Seperia_TempDB].[dbo].[UserProcess_GUI_Site_1month]
GO


SELECT count(*) [Dwh_Fact_BackOffice_Gateways_1month]
FROM [Seperia_DWH_TempDB].[dbo].[Dwh_Fact_BackOffice_Gateways_1month]
GO

SELECT count(*) [Dwh_Fact_PPC_Campaigns_1month]
FROM [Seperia_DWH_TempDB].[dbo].[Dwh_Fact_PPC_Campaigns_1month]

GO

SELECT count(*) [Dwh_Fact_PPC_Content_1month]
FROM [Seperia_DWH_TempDB].[dbo].[Dwh_Fact_PPC_Content_1month]
GO

SELECT count(*) [Dwh_Dim_PPC_Sites_1month]
FROM [Seperia_DWH_TempDB].[dbo].[Dwh_Dim_PPC_Sites_1month]
GO

------------- drop tables 


drop table [Seperia_TempDB].[dbo].[BackOffice_Client_Gateway_v29]
GO

 drop table  [Seperia_TempDB].[dbo].Paid_API_AllColumns_v29
GO

drop table  [Seperia_TempDB].[dbo].Paid_API_Content_v29
GO

drop table  [Seperia_TempDB].[dbo].[UserProcess_GUI_PaidAdgroupSite]
GO

drop table  [Seperia_TempDB].[dbo].[UserProcess_GUI_Site]
GO


drop table [Seperia_DWH_TempDB].[dbo].[Dwh_Fact_BackOffice_Gateways]
GO

drop table [Seperia_DWH_TempDB].[dbo].[Dwh_Fact_PPC_Campaigns]
GO

drop table  [Seperia_DWH_TempDB].[dbo].[Dwh_Fact_PPC_Content]
GO

drop table [Seperia_DWH_TempDB].[dbo].[Dwh_Dim_PPC_Sites]
GO









