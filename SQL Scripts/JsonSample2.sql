DECLARE @MyHierarchy JSONHierarchy,@xml XML
INSERT INTO @myHierarchy
select * 
from parseJSON('{"Service":"1110","Lens":"Steps:2 Route:2","Org":" simplex construction company","OrganizationLevelCounters":{"CountStartArray":{"Step-3":"0","Step-1":"0","Step-2":"0","Step-0":"1"},"First":{"first":"2011-08-12T12:02:54.117Z"},"UUsersNumArrayFirst":{"Step-3":"0","Step-1":"0","Step-2":"0","Step-0":"1"}},"RawKey":"1110:##: simplex construction company"}')
where [Object_ID] is not null 

select Case when h2.[Name] = '-' then '' else  h2.[Name] end 
	 +'.'+ h1.[Name], h1.StringValue 
from parseJSON('{"Service":"1110","Lens":"Steps:2 Route:2","Org":" simplex construction company","OrganizationLevelCounters":{"CountStartArray":{"Step-3":"0","Step-1":"0","Step-2":"0","Step-0":"1"},"First":{"first":"2011-08-12T12:02:54.117Z"},"UUsersNumArrayFirst":{"Step-3":"0","Step-1":"0","Step-2":"0","Step-0":"1"}},"RawKey":"1110:##: simplex construction company"}')
 h1 
 full outer join 
	@MyHierarchy H2 
	on h1.parent_ID = h2.[Object_ID]
Order by 1
