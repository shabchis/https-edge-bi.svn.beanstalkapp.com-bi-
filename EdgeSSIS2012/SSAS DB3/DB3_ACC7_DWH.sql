-----------------FACT CAMPGAINS----------------
DROP Table EdgeDWH.dbo.[7_DWH_FACT_SEARCH]  


SELECT [AccountID]
      ,[ChannelID]
      ,[OutputID]
      ,cast(CONVERT (varchar, [TimePeriodStart] ,112)as int) as TimePeriodStart_id 
      ,DATEPART(HOUR , [TimePeriodStart])TimePeriodStart_hour_id
      ,cast(CONVERT (varchar, [TimePeriodEnd] ,112)as int) as TimePeriodEnd_id 
      ,DATEPART(HOUR , [TimePeriodEnd])TimePeriodEnd_hour_id 
      ,[Currency]
      ,[Ad_gk]
      ,[AdType_gk]
      ,[Campaign_gk]
      ,[AdGroup_gk]
      ,[Tracker_gk]
      ,[MatchDestination_gk]
      ,[Ad_CreativeMatch_gk]
      ,[CompositeCreativeMatch_Creative_gk]
      ,[DisplayUrlMatch_gk]
      ,[ImageCreativeMatch_gk]
      ,[TitleCreativeMatch_gk]
      ,[Desc1CreativeMatch_gk]
      ,[Desc2CreativeMatch_gk]
      ,[DisplayUrlCreative_gk]
      ,[ImageCreative_gk]
      ,[TitleCreative_gk]
      ,[Desc1Creative_gk]
      ,[Desc2Creative_gk]
      ,[DisplayUrlCreative_TextType_gk]
      ,[TitleCreative_TextType_gk]
      ,[Desc1Creative_TextType_gk]
      ,[Desc2Creative_TextType_gk]
      ,[TargetDestination_gk]
      ,[KeywordTargetMatch_gk]
      ,[PlacementTargetMatch_gk]
      ,[KeywordTargetMatch_Target_gk]
      ,[PlacementTargetMatch_Target_gk]
      ,[KeywordMatchType_gk]
      ,[PlacementType_gk]
      ,[Clicks]
      ,[Cost]
      ,[Impressions]
      ,[AveragePosition]
      ,[TotalConversionsOnePerClick]
      ,[TotalConversionsManyPerClick]
      ,[Leads]
      ,[Signups]
      ,[Purchases]
      ,[PageViews]
      ,[Defaults]
      ,[CreatedOn]

 INTO  EdgeDWH.dbo.[7_DWH_FACT_SEARCH]  
  FROM [EdgeStaging].[dbo].[7_Metrics_Search]
-----------Fact B0---------------------------
drop table EdgeDWH.dbo.[7_DWH_FACT_BACKEND] 

SELECT [AccountID]
      ,[ChannelID]
      ,[OutputID]
      ,cast(CONVERT (varchar, [TimePeriodStart] ,112)as int) as TimePeriodStart_id 
      ,DATEPART(HOUR , [TimePeriodStart])TimePeriodStart_hour_id
      ,cast(CONVERT (varchar, [TimePeriodEnd] ,112)as int) as TimePeriodEnd_id 
      ,DATEPART(HOUR , [TimePeriodEnd])TimePeriodEnd_hour_id 
      ,[Tracker_gk]
      ,[Acquisition1]
      ,[Acquisition2]
      ,[BoTotalHits]
      ,[BoNewLeads]
      ,[BoNewNetDepositsUSD]
      ,[BoActivations]
      ,[NewDeposit]
      ,[EV]
      ,[SAT]
      ,[CreatedOn]
  INTO EdgeDWH.dbo.[7_DWH_FACT_BACKEND] 
  FROM [EdgeStaging].[dbo].[7_Metrics_BackEnd]

-----[dbo].[Dwh_Ref_MeasureGroupRef]-----------
drop table edgedwh.dbo.[7_DWH_FACT_SEARCH_BO_REF]

SELECT distinct
		[AccountID]
      ,[ChannelID]
      ,[OutputID]
      ,[Currency]
      ,[Ad_gk]
      ,[AdType_gk]
      ,[Campaign_gk]
      ,[AdGroup_gk]
      ,[Tracker_gk]
      ,[MatchDestination_gk]
      ,[Ad_CreativeMatch_gk]
      ,[CompositeCreativeMatch_Creative_gk]
      ,[DisplayUrlMatch_gk]
      ,[ImageCreativeMatch_gk]
      ,[TitleCreativeMatch_gk]
      ,[Desc1CreativeMatch_gk]
      ,[Desc2CreativeMatch_gk]
      ,[DisplayUrlCreative_gk]
      ,[ImageCreative_gk]
      ,[TitleCreative_gk]
      ,[Desc1Creative_gk]
      ,[Desc2Creative_gk]
      ,[DisplayUrlCreative_TextType_gk]
      ,[TitleCreative_TextType_gk]
      ,[Desc1Creative_TextType_gk]
      ,[Desc2Creative_TextType_gk]
      ,[TargetDestination_gk]
      ,[KeywordTargetMatch_gk]
      ,[PlacementTargetMatch_gk]
      ,[KeywordTargetMatch_Target_gk]
      ,[PlacementTargetMatch_Target_gk]
      ,[KeywordMatchType_gk]
      ,[PlacementType_gk]
INTO edgedwh.dbo.[7_DWH_FACT_SEARCH_BO_REF]	  
from
	EdgeDWH.dbo.[7_DWH_FACT_SEARCH]






      
-------------Dimension tables--------------

declare @Select as varchar(max)
declare @SelectS as varchar(max)
declare @SelectE as varchar(max)
Declare @del as varchar(max)
declare @Table as varchar(50)
Declare @Accuont as varchar(10)=7
declare @Chr_IDX as int

create table #MD_Objects ( TypeID int, name varchar(50), fieldlist varchar(MAX) , [select] varchar(max))

insert into  #MD_Objects ( TypeID , name, fieldlist  , [select] )
exec [EdgeObjects].[dbo].[MD_ObjectsViewer] 7,'7_Metrics_Search'
 
select * from  #MD_Objects



Declare CRSOBJ Cursor for
select  name  , [select] from  #MD_Objects
where fieldlist is not null
open CRSOBJ

Fetch next from CRSOBJ
into @Table , @Select

while @@FETCH_STATUS= 0
BEGIN

PRINT @Table

set @del=UPPER('Drop table '+'EdgeDWH.DBO.['+@Accuont+'_DWH_DIM_'+ @Table+']')

if exists 
(
select 1 from EdgeDWH.INFORMATION_SCHEMA.TABLES
where TABLE_NAME=@Accuont+'_DWH_DIM_'+Upper(@Table)
)
exec(@del)  

		set @Chr_IDX = CHARINDEX('FROM' ,@select   ,0)
		set @SelectS = LEFT (@select,@Chr_IDX-1)
		set @SelectE = RIGHT (@select,len(@select)-@Chr_IDX+1)

		set @Select = @SelectS +' INTO EdgeDWH.DBO.['+@Accuont+'_DWH_DIM_'+Upper(@Table)+'] '+@SelectE

		exec(@Select)

		select @Chr_IDX
		select @SelectS
		select @SelectE
		select @Select

		Fetch next from CRSOBJ
		into @Table , @Select
END

 
close CRSOBJ 
deallocate CRSOBJ

drop table #MD_Objects


----------------------------------UNPIVOT FACT------------------

declare @fld as varchar(100)
declare @flist varchar(1000)
declare @flist1 varchar(1000)
declare @SQLE as varchar(max)
create table #MD_Objects ( TypeID int, name varchar(50), fieldlist varchar(200) , [select] varchar(max))


insert into  #MD_Objects ( TypeID , name ,fieldlist , [select] )
exec [EdgeObjects].[dbo].[MD_ObjectsViewer] 7,'7_Metrics_Search'


set @flist = (select fieldlist from #MD_Objects where name='TextCreative')
set @flist = '['+REPLACE( @flist ,',', '],[')+']'
set @flist1=' '



declare RS cursor  for
select COLUMN_NAME from EdgeDWH.INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = '7_DWH_FACT_SEARCH' 
and CHARINDEX(COLUMN_NAME ,@flist)=0 

open rs
fetch next from rs into @fld

while @@FETCH_STATUS=0
begin
	set @flist1= @flist1+',['+@fld+']'
	fetch next from rs into @fld
	end

close rs



set @SQLE='SELECT [creative_gk], ''TextCreative'' as Type '+@flist1+'  
  Into edgedwh.dbo.[7_DWH_FACT_TEXTCREATIVE]
FROM 
   (SELECT '+ @flist+@flist1+
    
  ' FROM [EdgeDWH].[dbo].[7_DWH_FACT_SEARCH]) p
UNPIVOT
   (creative_gk FOR  type_id IN
      (' 
+@flist+')
)AS unpvt;
'
drop table #MD_Objects


drop table  edgedwh.dbo.[7_DWH_FACT_TEXTCREATIVE]


exec (@SQLE)

---------------------------------DWH SYSTEM DIM-------------------------------------------

---ACCONUNT
select * 
into EDGEDWH.DBO.DWH_DIM_ACCOUNT
from 
EdgeObjects.dbo.ACCOUNT

---CHANNEL
SELECT *
INTO EDGEDWH.DBO.DWH_DIM_CHANNEL
FROM
EdgeObjects.DBO.Channel

---




-----------------------------------Play Ground-----------------------

-------------------[7_DWH_FACT_TEXTCREATIVE_REF]

drop table EdgeDWH.dbo.[7_DWH_FACT_TEXTCREATIVE_REF]

/****** Script for SelectTopNRows command from SSMS  ******/
SELECT distinct
		[creative_gk]
      ,[Type]
      ,[AccountID]
      ,[ChannelID]
      ,[OutputID]
      ,[TimePeriodStart_id]
      ,[TimePeriodStart_hour_id]
      ,[TimePeriodEnd_id]
      ,[TimePeriodEnd_hour_id]
      ,[Currency]
      ,[Ad_gk]
      ,[AdType_gk]
      ,[Campaign_gk]
      ,[AdGroup_gk]
      ,[Tracker_gk]
      ,[MatchDestination_gk]
      ,[Ad_CreativeMatch_gk]
      ,[CompositeCreativeMatch_Creative_gk]
      ,[DisplayUrlMatch_gk]
      ,[ImageCreativeMatch_gk]
      ,[TitleCreativeMatch_gk]
      ,[Desc1CreativeMatch_gk]
      ,[Desc2CreativeMatch_gk]
      ,[ImageCreative_gk]
      ,[DisplayUrlCreative_TextType_gk]
      ,[TitleCreative_TextType_gk]
      ,[Desc1Creative_TextType_gk]
      ,[Desc2Creative_TextType_gk]
      ,[TargetDestination_gk]
      ,[KeywordTargetMatch_gk]
      ,[PlacementTargetMatch_gk]
      ,[KeywordTargetMatch_Target_gk]
      ,[PlacementTargetMatch_Target_gk]
      ,[KeywordMatchType_gk]
      ,[PlacementType_gk]
INTO edgedwh.dbo.[7_DWH_FACT_TEXTCREATIVE_REF]
FROM [EdgeDWH].[dbo].[7_DWH_FACT_TEXTCREATIVE]

