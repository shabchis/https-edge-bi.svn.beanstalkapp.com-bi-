

declare @Sdate int=20090101
declare @Edate int=20130510 


IF EXISTS
(
SELECT *
FROM tempdb.dbo.sysobjects
WHERE ID = OBJECT_ID(N'tempdb..#TmpACCTGTW')
)
BEGIN
DROP TABLE #TmpACCTGTW
END


create table #TmpACCTGTW
(
account_ID int,
Gateway_GK int
)

insert into #TmpACCTGTW ( account_ID , Gateway_GK)
select distinct account_ID , Gateway_GK from Dwh_Ref_MeasureGroupRef
order by 1,2


while @Sdate <=@Edate


BEGIN


MERGE Dwh_Ref_MeasureGroupRef AS TRG
USING (
SELECT distinct
account_ID, 
-1 Channel_ID, 
Gateway_GK , 
account_ID *-1 as  Campaign_gk, 
account_ID *-1 as Ad_group_gk, 
account_ID *-1 as Paid_Creative_GK, 
account_ID *-1 as Creative_gk, 
0 as Ad_type, 
0 as Advariation, 
getdate() as LastUpdated,
'BO' as SourceData
FROM [DWH_Fact_BackOffice_Gateways] F with (nolock)
where Day_ID= @Sdate
and not exists
( select 1 from #TmpACCTGTW t where t.account_ID =f.account_ID and t.Gateway_GK = F.Gateway_GK)
) AS SRC
ON 
isnull(SRC.account_ID,-1)=TRG.account_ID and 
SRC.Channel_ID=TRG.Channel_ID and 
isnull(SRC.Gateway_GK,-1)=TRG.Gateway_GK and 
SRC.Campaign_gk=TRG.Campaign_gk and 
SRC.Ad_group_gk=TRG.Ad_group_gk and 
SRC.Paid_Creative_GK=TRG.Paid_Creative_GK and 
SRC.Creative_gk=TRG.Creative_gk and 
SRC.Ad_type=TRG.Adwords_type_code and 
SRC.Advariation=TRG.Advariation
WHEN NOT MATCHED THEN
INSERT(account_ID ,Channel_ID , Gateway_GK , Campaign_gk , Ad_group_gk , Paid_Creative_GK ,  Adwords_type_code , Advariation ,LastUpdated,Creative_gk , SourceData)
VALUES(isnull(SRC.account_ID,-1) ,SRC.Channel_ID , isnull(SRC.Gateway_GK,-1) , SRC.Campaign_gk , SRC.Ad_group_gk , SRC.Paid_Creative_GK  ,   SRC.Ad_type ,SRC.Advariation ,SRC.LastUpdated,src.Creative_gk  ,SRC.SourceData );


Set @Sdate=cast (CONVERT( varchar, dateadd(d,1,cast (cast (@Sdate as varchar) as DATE)),112)as int)


Print @Sdate


END