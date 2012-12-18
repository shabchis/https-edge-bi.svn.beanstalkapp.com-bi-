USE [EdgeObjects]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Amit Bluman
-- Create date: 13/12/2012
-- Description:	This SP will query the SSAS using MDX. It will serve the alerts mechanism created by Shay.
-- =============================================
alter PROCEDURE [dbo].[Alerts_CampaignCPA]
	@WithMDX nvarchar(max),
	@SelectMDX nvarchar(max),
	@FromMDX nvarchar(max)
AS
BEGIN
	
	SET NOCOUNT ON;
	
	DECLARE @OPENQUERY nvarchar(max), @TSQL nvarchar(max), @LinkedServer nvarchar(max)
	SET @LinkedServer = 'PROD_OLAP'
	SET @OPENQUERY = 'SELECT * FROM OPENQUERY('+ @LinkedServer + ','''
	SET @TSQL = ''+@WithMDX + ' ' + @SelectMDX + ' ' + @FromMDX + ''')'

	-- print @OPENQUERY+@TSQL;

	EXEC (@OPENQUERY+@TSQL) 



--	Select * from OPENQUERY (PROD_OLAP,	'With 
--Set [Filtered Campaigns] As ''{[Getways Dim].[Gateways].[Campaign].&[4005321],[Getways Dim].[Gateways].[Campaign].&[4004278]}''
-- ''' & @sql &'''
--Select 
--NonEmpty({[Measures].[Cost],
--  [Measures].[Cost/Reg],
--  [Measures].[Regs]}) On Columns ,

--{ NonEmpty (
   
--  {HIERARCHIZE ( Except ( {[Getways Dim].[Gateways].[Campaign].Allmembers}, [Filtered Campaigns] )  ) } 
--  * {HIERARCHIZE ( [Paid Campaigns Dim].[Campaign Gk].CurrentMember.children )} 
--  )} On Rows 

--From BOEasyForexTest2 
--   where ( [Accounts Dim].[Accounts].[Account].&[7], [Channels Dim].[Channels].[Channel].&[1], 
--   [Time Dim].[Time Dim].[Day].&[20120619]:[Time Dim].[Time Dim].[Day].&[20120719])
--')


END



