DECLARE @MyHierarchy JSONHierarchy,@xml XML
Declare @JsonData nvarchar(4000);

set @JsonData = '{"ReduceRecords":"335","Service":"1110","Lens":"Steps:2 Route:2","Org":"154693","ReduceDurationInSec":"0","OrganizationLevelCounters":{"CountStartArray":{"Step-18":"2","Step-19":"3","Step-10":"0","Step-11":"0","Step-12":"0","Step-13":"0","Step-14":"57","Step-0":"21","Step-15":"0","Step-16":"0","Step-17":"0","Step-3":"0","Step-4":"0","Step-1":"13","Step-2":"0","Step-7":"0","Step-8":"0","Step-5":"0","Step-6":"0","Step-9":"0"},"UUsersNumArrayFirst":{"Step-18":"1","Step-19":"1","Step-10":"0","Step-11":"0","Step-12":"0","Step-13":"0","Step-14":"1","Step-0":"1","Step-15":"0","Step-16":"0","Step-17":"0","Step-3":"0","Step-4":"0","Step-1":"1","Step-2":"0","Step-7":"0","Step-8":"0","Step-5":"0","Step-6":"0","Step-9":"0"},"Count":{"previous":{"1":0,"3":0,"7":0,"14":0,"30":0},"current":{"1":0,"3":0,"7":0,"14":0,"30":0}},"CountStart":{"previous":{"1":6,"3":6,"7":13,"14":0,"30":0},"current":{"1":3,"3":12,"7":18,"14":31,"30":31}},"First":{"first":"2012-01-19T01:44:13.223Z"}},"RawKey":"1110:##:154693"}'
INSERT INTO @myHierarchy
select * 
from parseJSON(@JsonData)
where [Object_ID] is not null 

select Case when h2.[Name] = '-' then '' else  h2.[Name] end 
	 +'.'+ h1.[Name], h1.StringValue 
from parseJSON(@JsonData)
 h1 
 full outer join 
	@MyHierarchy H2 
	on h1.parent_ID = h2.[Object_ID]
Order by 1
