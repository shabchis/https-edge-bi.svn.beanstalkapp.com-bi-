USE [Seperia_DWH]
GO
/****** Object:  StoredProcedure [dbo].[AD_Alert_Report]    Script Date: 6/27/2013 3:40:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Kati>
-- Create date: <19.06.13>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[AD_Alert_Report](@Account_ID varchar(20), @DaysNum varchar(2), @CPAThreshold varchar(10), @CPRThreshold varchar(10), @AdgroupSpent varchar(10))
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

declare @fromstr  varchar(1000)
declare @select1 varchar(max)
declare @select2 varchar(max)
declare @Regs  varchar(50)
declare @Actives  varchar(50)
declare @CPR  varchar(50)
declare @CPA  varchar(50)
declare @CubeName varchar(1000)
declare @where varchar(max)

set @Regs = (select MDX_Name from [Seperia].[dbo].[Measure] where AccountID = @Account_ID and BaseMeasureID = 5)
set @Actives = (select MDX_Name from [Seperia].[dbo].[Measure] where AccountID = @Account_ID and BaseMeasureID = 7)
set @CPR = (select MDX_Name from [Seperia].[dbo].[Measure] where AccountID = @Account_ID and BaseMeasureID = 1)
set @CPA = (select MDX_Name from [Seperia].[dbo].[Measure] where AccountID = @Account_ID and BaseMeasureID = 9)
set @CubeName  = (select substring(convert(varchar(50), AnalysisSettings, 0 ),29, (len( convert(varchar(50), AnalysisSettings, 0 )  ) - 31 )) 
		FROM [Seperia].[dbo].[User_GUI_Account] where Account_ID =  @Account_ID  )

IF (@Regs is not NULL AND @Actives is not NULL AND @CPR is not NULL AND @CPA is not NULL AND @CubeName is not NULL)
	BEGIN

	set @select1  = 
	'With 
	SET [Selected Measures] AS { 
								 [Measures].[Weight]
								,[Measures].[AdGroup_Weight] 
								 ,[Measures].['+@Actives+']
								,[Measures].[Cost] AS Cost
								,[Measures].['+@CPA+']
								,[Measures].['+@CPR+']
								,[Measures].['+@Regs+'] 
							   , [Measures].[7% of AdGroup]
				   ,[Measures].[Sum of ADgroup_cost]
								,[Measures].[Sum of ADgroup]
								,[Measures].[0.1% of Account]
								,[Measures].[Sum of Account]
								,[Measures].[Best_CPA] 
								,[Measures].[Best_CPR] 

													} 
	MEMBER [Measures].[0.1% of Account] AS (([Measures].['+@Regs+'],[Paid Creatives Dim].[Creatives].CurrentMember.Parent.Parent.Parent) * 0.001)   --Account Level
	MEMBER [Measures].[7% of AdGroup]   AS (([Measures].[cost],[Paid Creatives Dim].[Creatives].CurrentMember.Parent) * '+@AdgroupSpent+')						--Ad group level
	MEMBER [Measures].[Sum of Account]  AS ([Measures].['+@Regs+'],[Paid Creatives Dim].[Creatives].CurrentMember.Parent.Parent.Parent)				-- Account
	MEMBER [Measures].[Sum of ADgroup]  AS ([Measures].['+@Regs+'],[Paid Creatives Dim].[Creatives].CurrentMember.Parent)                           -- Adgroup
	MEMBER [Measures].[Sum of ADgroup_cost]  AS ([Measures].[cost],[Paid Creatives Dim].[Creatives].CurrentMember.Parent)                           -- Adgroup
 
	MEMBER [Measures].[Weight]          AS  IIF ( ([Measures].['+@CPA+']=null or [Measures].['+@CPA+'] = 0 ) and ([Measures].['+@CPR+']=null or [Measures].['+@CPR+'] = 0 ), [Measures].[Cost]  * 100  ,
												  IIF( ([Measures].['+@CPA+']=null or [Measures].['+@CPA+'] = 0) and ([Measures].['+@CPR+']<>null AND [Measures].['+@CPR+'] <> 0 ),
													  ((1- Measures.[Best_CPR]/[Measures].['+@CPR+']) * 1), 
															 IIF( ([Measures].['+@CPA+']<>null AND [Measures].['+@CPA+'] <> 0 ) and ([Measures].['+@CPR+']=null or [Measures].['+@CPR+'] = 0 ),
																 ((1- Measures.[Best_CPA]/[Measures].['+@CPA+']) * 1  ),										     
													     			((1- Measures.[Best_CPA]/[Measures].['+@CPA+']) * 0.5  ) +  ((1- Measures.[Best_CPR]/[Measures].['+@CPR+']) * 0.5 ) ))) ,  FORMAT_STRING = "#,###.00" 


	MEMBER [Measures].[AdGroup_Weight]          AS MIN( [Paid Creatives Dim].[Creatives].CURRENTMEMBER.parent.children  ,[Measures].[Weight])

	SET [Filtered Creatives_1] AS FILTER( 
														  {[Paid Creatives Dim].[Creatives].[Creative]} , [Measures].[cost] > [Measures].[7% of AdGroup]
														  AND
														  [Sum of ADgroup] >  [Measures].[0.1% of Account]
														  AND 
														  [Measures].[Cost] > 0

														  )  
	MEMBER [Measures].[Best_CPA]  AS  Min([Filtered Creatives_1], [Measures].['+@CPA+'])
	MEMBER [Measures].[Best_CPR]  AS  Min([Filtered Creatives_1], [Measures].['+@CPR+'])
	SET [Filtered Creatives_2] AS FILTER( 
														   {[Filtered Creatives_1]} , [Measures].['+@CPA+'] >= Measures.[Best_CPA] * '+@CPAThreshold+' 
																OR
														  [Measures].['+@CPR+'] >=   Measures.[Best_CPR] * '+@CPAThreshold+'                                                     )
	SELECT ORDER (ORDER([Filtered Creatives_2], [Measures].[Weight] , BDESC) , [Measures].[AdGroup_Weight] , BDESC) ON ROWS,
	[Selected Measures]  ON COLUMNS
	'
	set @fromstr =  'FROM [' + @CubeName  + ']'

	set @where = 
	'WHERE ( ClosingPeriod([Time Dim].[Time Dim].[Day], [Time Dim].[Time Dim].[All Time]).Lag('+@DaysNum+'): ClosingPeriod([Time Dim].[Time Dim].[Day], [Time Dim].[Time Dim].[All Time]) )'

	exec Seperia..SP_ExecuteMDX  @select1,  @fromstr, @where
	
	END -- End of no BO for this client
		ELSE 
			select NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
END