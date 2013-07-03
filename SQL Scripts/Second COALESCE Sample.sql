
DECLARE @mySELECTs as nvarchar(max);
DECLARE @myFROMs as nvarchar(max);

DROP TABLE MD_STAGE_QUERY;

 CREATE TABLE MD_STAGE_QUERY 
 ( mySELECT nvarchar(4000) NULL,
 myFROM nvarchar(4000) NULL,
 myON nvarchar(4000) NULL,
 myWHERE nvarchar(4000) NULL
) ON [PRIMARY]
 
 INSERT INTO MD_STAGE_QUERY
 VALUES ('SELECT',  'FROM [EdgeDeliveries].[dbo].[3__20130410_142127_5f368d7f48490b6484bcc9482b730dba_Metrics] as Metrics', NULL, NULL);

INSERT INTO MD_STAGE_QUERY
 SELECT [EdgeFieldName] + '.GK AS '+ [EdgeFieldName] AS mySELECT 
   ,' INNER JOIN [EdgeDeliveries].' + left(MD.[TableName], len(MD.[TableName])-9) + '_' + EdgeType.TableName + '] AS '+ [EdgeFieldName]
   +  '   ON Metrics.' + REPLACE([EdgeFieldName],'gk','tk') + ' = ' + EdgeType.TableName + '.tk' AS myFROM
   -- ,'ON Metrics.ad_tk  =  AD.tk
   ,NULL
   ,NULL
     -- ,[EdgeFieldName]
   --, EdgeType.TableName
 FROM [EdgeDeliveries].[dbo].[MD_MetricsMetadata] MD , [EdgeObjects].[dbo].MD_EdgeType EdgeType 
 WHERE MD.EdgeTypeID is not null and MD.EdgeTypeID = EdgeType.TypeID
UNION ALL
 SELECT  [MeasureName] + ' AS ' + [MeasureName] AS mySELECT ,NULL, NULL, NULL
 FROM [EdgeDeliveries].[dbo].[MD_MetricsMetadata] MD
 WHERE [MeasureName] is not null
 
 -- CONCATENATE THE SELECTS AND THE FROM TO PARAMS

 SELECT @mySELECTs = COALESCE(@mySELECTs+'', '','''')+ISNULL(mySELECT+', ','''')
 FROM MD_STAGE_QUERY;

SELECT @myFROMs = COALESCE(@myFROMs+'', '','''')+ISNULL(myFROM+', ','''')
 FROM MD_STAGE_QUERY;
 
 
SELECT @mySELECTs +  @myFROMs;
PRINT @mySELECTs +  @myFROMs;
