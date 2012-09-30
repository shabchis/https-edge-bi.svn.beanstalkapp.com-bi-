  
  -- rememeber delete the test organizations AND to fix the comma issue
  -- AND the Clarizen Data updates (in a seperate file)
  --  Delete FROM [Barometer_Hebrew].[dbo].[JSONData]  where data like '%OrganL%' or  data like '%asdasd%'
  --  Update [Barometer_Hebrew].[dbo].[JSONData] set data = Replace(convert(nvarchar(4000),[data]),'¸','')  where [data] like '%¸%
 
  
  Declare @JsonData as varchar(8000);
  Declare @NumOfRows int;
  Declare @MyHierarchy JSONHierarchy;

  Declare @OrgName as nvarchar(4000);
  Declare @firstUsage as  nvarchar(4000);
  Declare @ActivityWeek1 nvarchar(4000);
  Declare @ActivityWeek2 nvarchar(4000);
  Declare @ActivityWeek3 nvarchar(4000);
  Declare @ActivityWeek4 nvarchar(4000);
  Declare @UUsersWeek1 nvarchar(4000);
  Declare @UUsersWeek2 nvarchar(4000);
  Declare @UUsersWeek3 nvarchar(4000);
  Declare @UUsersWeek4 nvarchar(4000);

  Drop table #JsonTemp
  Create table #JsonTemp (JParam nvarchar(500) null, JValue nvarchar(500) null);
  
  set @NumOfRows = 0 

  DECLARE index_cursor CURSOR FOR 
					SELECT [data]
					FROM [Barometer_Hebrew].[dbo].JSONData
					
  OPEN index_cursor

  FETCH NEXT FROM index_cursor 
			INTO @JsonData 

  WHILE @@FETCH_STATUS = 0
			BEGIN
				 -- create a temp hierarchy for the join  
				INSERT INTO @myHierarchy
				select * 
				from parseJSON(@JsonData)
				where [Object_ID] is not null ;
				
				-- create the final json parsing select
				Insert into #JsonTemp 
				select Case when h2.[Name] = '-' then '' else  h2.[Name] end 
					 +'.'+ h1.[Name], h1.StringValue 
				from  parseJSON(@JsonData) h1 
				 full outer join 
					@MyHierarchy H2 
					on h1.parent_ID = h2.[Object_ID]
				Order by 1	;		

				select @OrgName = JValue from #JsonTemp where JParam = '.Org';
				select @firstUsage = JValue from #JsonTemp where JParam = 'First.first';
				select @ActivityWeek1 = JValue from #JsonTemp where JParam = 'CountStartArray.Step-0';
				select @ActivityWeek2 = JValue from #JsonTemp where JParam = 'CountStartArray.Step-1';
				select @ActivityWeek3 = JValue from #JsonTemp where JParam = 'CountStartArray.Step-2';
				select @ActivityWeek4 = JValue from #JsonTemp where JParam = 'CountStartArray.Step-3';
				select @UUsersWeek1 = JValue from #JsonTemp where JParam = 'UUsersNumArrayFirst.Step-0';
				select @UUsersWeek2 = JValue from #JsonTemp where JParam = 'UUsersNumArrayFirst.Step-1';
				select @UUsersWeek3 = JValue from #JsonTemp where JParam = 'UUsersNumArrayFirst.Step-2';
				select @UUsersWeek4 = JValue from #JsonTemp where JParam = 'UUsersNumArrayFirst.Step-3';


				-- print @OrgName +' '+ @firstUsage+' '+@ActivityWeek1 +' '+@ActivityWeek2 +' '+@ActivityWeek3 +' '+@ActivityWeek4 +' '+@UUsersWeek1 +' '+ @UUsersWeek2+' '+ @UUsersWeek3 +' '+ @UUsersWeek4
				-- insert the data into ClarizenData table

					INSERT INTO [dbo].[ClarizenData2] 
						   ([OrgName] ,[firstUsage] ,[ActivityWeek1] ,[ActivityWeek2] ,[ActivityWeek3] ,[ActivityWeek4]
						   ,[UUsersWeek1] ,[UUsersWeek2] ,[UUsersWeek3] ,[UUsersWeek4])
					 VALUES
						 (@OrgName ,@firstUsage ,@ActivityWeek1 ,@ActivityWeek2 ,@ActivityWeek3 ,@ActivityWeek4
						   ,@UUsersWeek1 ,@UUsersWeek2 ,@UUsersWeek3 ,@UUsersWeek4)
				
				-- number of rows index
					set @NumOfRows = @NumOfRows + 1
				

-- Get the next index.
			FETCH NEXT FROM index_cursor 
			INTO @JsonData
-- clean the parameters			
			truncate table #JsonTemp;
			Delete from @MyHierarchy;
			set @OrgName = NULL;
			set @firstUsage = NULL;
			set @ActivityWeek1 = NULL;
			set @ActivityWeek2 = NULL;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
			set @ActivityWeek3 = NULL;
			set @ActivityWeek4 = NULL;
			set @UUsersWeek1 = NULL;
			set @UUsersWeek2 = NULL;
			set @UUsersWeek3 = NULL;
			set @UUsersWeek4 = NULL;

  END -- ends while

  print convert(varchar(10),@NumOfRows) + ' rows inserted into Clarizen data table'

  CLOSE index_cursor
  DEALLOCATE index_cursor
	
