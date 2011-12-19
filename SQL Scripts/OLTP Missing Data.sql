 
/* select distinct cast(account_id as varchar(100)) +' | '+ cast(Day_Code as varchar(100)) 
 from easynet_OLTP.dbo.Paid_API_AllColumns
 where Day_Code > 20111028 
 order by 1
 */
 
 SELECT Account_ID, Day_Code
 into #With_data
  FROM [Edge_OLTP].[dbo].[Paid_API_AllColumns_v29]  
  where Channel_ID = 1
 -- where Account_ID = 10000 -- and Channel_ID = 1  and Day_Code = 20111214
  group by Account_ID, Day_Code
  having SUM(imps) > 0
  order by 1,2
  
  select  alldates.unified
  from  ( select distinct cast(account_id as varchar(100)) +' | '+ cast(Day_Code as varchar(100)) as unified
			 from easynet_OLTP.dbo.Paid_API_AllColumns
			 where Day_Code > 20111028 and Account_ID not in ( 95 , 10045) and Channel_ID = 1 
			) alldates
   where  alldates.unified not in
		(select cast( #With_data.account_id as varchar(100)) +' | '+ cast( #With_data.Day_Code as varchar(100))
		from #With_data  ) 
		order by 1 
		
		-- debug
		select Account_ID,Day_Code,Channel_ID,SUM(clicks) as sumclicks
		from edge_OLTP.dbo.Paid_API_AllColumns_v29
		where  Channel_ID=1 and Day_Code=20111213 --and Account_ID= 10000
		group by Account_ID,Day_Code,Channel_ID
		
   