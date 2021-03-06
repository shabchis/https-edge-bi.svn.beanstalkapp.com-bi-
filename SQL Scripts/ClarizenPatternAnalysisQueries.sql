-- Customer Pattern Analysis – Utilization Level 
SELECT Tier , Avg(UtilizationPercent1) as Week1, Avg(UtilizationPercent2) as Week2, Avg(UtilizationPercent3)  as Week3, Avg(UtilizationPercent4)  as Week4
  FROM [Barometer_Hebrew].[dbo].[ClarizenData2]
  where NumOfLicenses is not null and [StatusGroup]= 'Paying' and NumOfLicenses != '0.0'  and UtilizationPercent1 <= 1
  group by Tier 
  UNION ALL 
  SELECT 'All Tiers', Avg(UtilizationPercent1) as Week1, Avg(UtilizationPercent2) as Week2, Avg(UtilizationPercent3)  as Week3, Avg(UtilizationPercent4)  as Week4
  FROM [Barometer_Hebrew].[dbo].[ClarizenData2]
  where NumOfLicenses is not null and [StatusGroup]= 'Paying' and NumOfLicenses != '0.0'  and UtilizationPercent1 <= 1
  
-- Customer Pattern Analysis – Users Engagement Level 
  SELECT Tier ,  Avg(UserEngagement1) as Week1, Avg(UserEngagement2) as Week2, Avg(UserEngagement3)  as Week3, Avg(UserEngagement4)  as Week4
  FROM [Barometer_Hebrew].[dbo].[ClarizenData2]
  Where NumOfLicenses is not null and [StatusGroup]= 'Paying' and NumOfLicenses != '0.0' 
  Group by Tier 
  UNION ALL 
  SELECT 'All Tiers' , Avg(UserEngagement1) as Week1, Avg(UserEngagement2) as Week2, Avg(UserEngagement3)  as Week3, Avg(UserEngagement4)  as Week4
  FROM [Barometer_Hebrew].[dbo].[ClarizenData2]
  Where NumOfLicenses is not null and [StatusGroup]= 'Paying' and NumOfLicenses != '0.0' 
  
  
---- Customer Pattern Analysis – Users Engagement Level Stddev
--  SELECT Tier ,  Stdev(UserEngagement1) as Week1, Stdev(UserEngagement2) as Week2, Stdev(UserEngagement3)  as Week3, Stdev(UserEngagement4)  as Week4
--  FROM [Barometer_Hebrew].[dbo].[ClarizenData2]
--  Where NumOfLicenses is not null and [StatusGroup]= 'Paying' and NumOfLicenses != '0.0' 
--  and (Isnull(UserEngagement1,0) + Isnull(UserEngagement2,0)  + Isnull(UserEngagement3,0)  + Isnull(UserEngagement4,0)   > 40)
--  Group by Tier 
--  UNION ALL 
--  SELECT 'All Tiers' , Stdev(UserEngagement1) as Week1, Stdev(UserEngagement2) as Week2, Stdev(UserEngagement3)  as Week3, Stdev(UserEngagement4)  as Week4
--  FROM [Barometer_Hebrew].[dbo].[ClarizenData2]
--  Where NumOfLicenses is not null and [StatusGroup]= 'Paying' and NumOfLicenses != '0.0' 
  

-- No license accounts (מונה)
SELECT Count(*)
  FROM [Barometer_Hebrew].[dbo].[ClarizenData2]
  where NumOfLicenses is  not null and  [StatusGroup]= 'Paying' and NumOfLicenses = '0.0'

-- All paying with license (מכנה)
SELECT Count(*)
  FROM [Barometer_Hebrew].[dbo].[ClarizenData2]
  where NumOfLicenses is  not null and  [StatusGroup]= 'Paying'

-- Over utilization accounts (מונה)
SELECT Count(*)
  FROM [Barometer_Hebrew].[dbo].[ClarizenData2]
  where NumOfLicenses is  not null and  [StatusGroup]= 'Paying' and NumOfLicenses != '0.0'
  and  UtilizationPercent1 > 1

  -- All paying with license and license > 0 (מכנה)
  SELECT Count(*)
  FROM [Barometer_Hebrew].[dbo].[ClarizenData2]
  where NumOfLicenses is  not null and  [StatusGroup]= 'Paying' and NumOfLicenses != '0.0'



	  