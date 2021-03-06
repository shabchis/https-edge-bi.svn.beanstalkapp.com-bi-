USE [Seperia_DWH_EdgeBiRND]
GO
/****** Object:  StoredProcedure [dbo].[RI_Segments]    Script Date: 17/04/2013 17:51:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Amit Bluman

-- =============================================
ALTER PROCEDURE [dbo].[RI_Segments]
	@Table_name nvarchar(2000),
	@Segment_prefix nvarchar(200)
AS
BEGIN
	SET NOCOUNT ON;

Declare @SQL nvarchar(4000);

-- SET @table_name = ' [dbo].[Dwh_Dim_PPC_Creatives]';

SET @SQL = 
'INSERT INTO [dbo].[DWH_Segment_Value]
			([AccountID]  ,[SegmentID] ,[ValueID]  ,[Value])
			SELECT  Account_ID= -1,SegmentID= 1 ,ValueID =IsNull(segment,-1) , Value = ''Unknown''
			 FROM (
				SELECT DISTINCT '+@Segment_prefix+'_segment1 AS segment
				FROM  '+ @table_name +'  STG  
				WHERE not exists 
				(	SELECT [AccountID]  ,[SegmentID] ,[ValueID]  ,[Value]
					FROM  [dbo].[DWH_Segment_Value] DW 
					WHERE  DW.segmentID = 1 AND STG.'+@Segment_prefix+'_segment1 = DW.ValueID )
			)DimNewValues

INSERT INTO  [dbo].[DWH_Segment_Value]
			([AccountID]  ,[SegmentID] ,[ValueID]  ,[Value])
			SELECT  Account_ID= -1,SegmentID= 2 ,ValueID =IsNull(segment,-1) , Value = ''Unknown''
			 FROM (
				SELECT DISTINCT '+@Segment_prefix+'_segment2 AS segment
				FROM   '+ @table_name +' STG  
				WHERE not exists 
				(	SELECT [AccountID]  ,[SegmentID] ,[ValueID]  ,[Value]
					FROM  [dbo].[DWH_Segment_Value] DW 
					WHERE  DW.segmentID = 2 AND STG.'+@Segment_prefix+'_segment2 = DW.ValueID )
			)DimNewValues
						
INSERT INTO  [dbo].[DWH_Segment_Value]
			([AccountID]  ,[SegmentID] ,[ValueID]  ,[Value])
			SELECT  Account_ID= -1,SegmentID= 3 ,ValueID =IsNull(segment,-1) , Value = ''Unknown''
			 FROM (
				SELECT DISTINCT '+@Segment_prefix+'_segment3 AS segment
				FROM   '+ @table_name +' STG  
				WHERE not exists 
				(	SELECT [AccountID]  ,[SegmentID] ,[ValueID]  ,[Value]
					FROM  [dbo].[DWH_Segment_Value] DW 
					WHERE  DW.segmentID = 3 AND STG.'+@Segment_prefix+'_segment3 = DW.ValueID )
			)DimNewValues
						
INSERT INTO  [dbo].[DWH_Segment_Value]
			([AccountID]  ,[SegmentID] ,[ValueID]  ,[Value])
			SELECT  Account_ID= -1,SegmentID= 4 ,ValueID =IsNull(segment,-1) , Value = ''Unknown''
			 FROM (
				SELECT DISTINCT '+@Segment_prefix+'_segment4 AS segment
				FROM   '+ @table_name +' STG  
				WHERE not exists 
				(	SELECT [AccountID]  ,[SegmentID] ,[ValueID]  ,[Value]
					FROM  [dbo].[DWH_Segment_Value] DW 
					WHERE  DW.segmentID = 4 AND STG.'+@Segment_prefix+'_segment4 = DW.ValueID )
			)DimNewValues
						
INSERT INTO  [dbo].[DWH_Segment_Value]
			([AccountID]  ,[SegmentID] ,[ValueID]  ,[Value])
			SELECT  Account_ID= -1,SegmentID= 5 ,ValueID =IsNull(segment,-1) , Value = ''Unknown''
			 FROM (
				SELECT DISTINCT '+@Segment_prefix+'_segment5 AS segment
				FROM   '+ @table_name +' STG  
				WHERE not exists 
				(	SELECT [AccountID]  ,[SegmentID] ,[ValueID]  ,[Value]
					FROM  [dbo].[DWH_Segment_Value] DW 
					WHERE  DW.segmentID = 5 AND STG.'+@Segment_prefix+'_segment5 = DW.ValueID )
			)DimNewValues'

-- select @SQL;
exec(@SQL);



END
