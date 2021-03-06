USE [Seperia_DWH_EdgeBiRND]
GO
/****** Object:  StoredProcedure [dbo].[Run_All_Segment_RIs]    Script Date: 17/04/2013 17:50:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Amit Bluman
-- =============================================
ALTER PROCEDURE [dbo].[Run_All_Segment_RIs]
	
AS
BEGIN
	
	SET NOCOUNT ON;

	exec RI_Segments '[dbo].[Dwh_Dim_PPC_Creatives]', 'creative'
	exec RI_Segments '[dbo].[Dwh_Dim_PPC_Key_Words]', 'keyword'
	exec RI_Segments '[dbo].[Dwh_Dim_Getways]', 'gateway'
	exec RI_Segments '[dbo].[Dwh_Dim_Campaigns]', 'campaign'

END
