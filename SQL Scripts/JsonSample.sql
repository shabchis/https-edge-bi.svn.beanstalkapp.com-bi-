  
  -- rememeber delete the test organizations AND to fix the comma issue
  --  Delete FROM [Barometer_Hebrew].[dbo].[JSONData]  where data like '%OrganL%' or  data like '%asdasd%'
  --  Update [Barometer_Hebrew].[dbo].[JSONData] set data = Replace(convert(nvarchar(4000),[data]),'¸','')  where [data] like '%¸%
  -- AND after running this script run the Clarizen Data updates (in a seperate file) 
  
  Declare @JsonData as varchar(8000);
  Declare @NumOfRows int;
  Declare @MyHierarchy JSONHierarchy;

  Declare @OrgName as nvarchar(4000);
  Declare @firstUsage as  nvarchar(4000);
  Declare @ActivityWeek1 nvarchar(4000);
  Declare @ActivityWeek2 nvarchar(4000);
  Declare @ActivityWeek3 nvarchar(4000);
  Declare @ActivityWeek4 nvarchar(4000);
  Declare @ActivityWeek5 nvarchar(4000);
  Declare @ActivityWeek6 nvarchar(4000);
  Declare @ActivityWeek7 nvarchar(4000);
  Declare @ActivityWeek8 nvarchar(4000);
  Declare @ActivityWeek9 nvarchar(4000);
  Declare @ActivityWeek10 nvarchar(4000);
  Declare @ActivityWeek11 nvarchar(4000);
  Declare @ActivityWeek12 nvarchar(4000);
  Declare @ActivityWeek13 nvarchar(4000);
  Declare @ActivityWeek14 nvarchar(4000);
  Declare @ActivityWeek15 nvarchar(4000);
  Declare @ActivityWeek16 nvarchar(4000);
  Declare @ActivityWeek17 nvarchar(4000);
  Declare @ActivityWeek18 nvarchar(4000);
  Declare @ActivityWeek19 nvarchar(4000);
  Declare @ActivityWeek20 nvarchar(4000);

  Declare @UUsersWeek1 nvarchar(4000);
  Declare @UUsersWeek2 nvarchar(4000);
  Declare @UUsersWeek3 nvarchar(4000);
  Declare @UUsersWeek4 nvarchar(4000);
  Declare @UUsersWeek5 nvarchar(4000);
  Declare @UUsersWeek6 nvarchar(4000);
  Declare @UUsersWeek7 nvarchar(4000);
  Declare @UUsersWeek8 nvarchar(4000);
  Declare @UUsersWeek9 nvarchar(4000);
  Declare @UUsersWeek10 nvarchar(4000);
  Declare @UUsersWeek11 nvarchar(4000);
  Declare @UUsersWeek12 nvarchar(4000);
  Declare @UUsersWeek13 nvarchar(4000);
  Declare @UUsersWeek14 nvarchar(4000);
  Declare @UUsersWeek15 nvarchar(4000);
  Declare @UUsersWeek16 nvarchar(4000);
  Declare @UUsersWeek17 nvarchar(4000);
  Declare @UUsersWeek18 nvarchar(4000);
  Declare @UUsersWeek19 nvarchar(4000);
  Declare @UUsersWeek20 nvarchar(4000);

  Drop table #JsonTemp
  Create table #JsonTemp (JParam nvarchar(500) null, JValue nvarchar(500) null);
  
  set @NumOfRows = 0 

  DECLARE index_cursor CURSOR FOR 
					SELECT [data]
					FROM [Barometer_Hebrew].[dbo].JSONData2
					
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
				select @ActivityWeek5 = JValue from #JsonTemp where JParam = 'CountStartArray.Step-4';
				select @ActivityWeek6 = JValue from #JsonTemp where JParam = 'CountStartArray.Step-5';
				select @ActivityWeek7 = JValue from #JsonTemp where JParam = 'CountStartArray.Step-6';
				select @ActivityWeek8 = JValue from #JsonTemp where JParam = 'CountStartArray.Step-7';
				select @ActivityWeek9 = JValue from #JsonTemp where JParam = 'CountStartArray.Step-8';
				select @ActivityWeek10 = JValue from #JsonTemp where JParam = 'CountStartArray.Step-9';
				select @ActivityWeek11 = JValue from #JsonTemp where JParam = 'CountStartArray.Step-10';
				select @ActivityWeek12 = JValue from #JsonTemp where JParam = 'CountStartArray.Step-11';
				select @ActivityWeek13 = JValue from #JsonTemp where JParam = 'CountStartArray.Step-12';
				select @ActivityWeek14 = JValue from #JsonTemp where JParam = 'CountStartArray.Step-13';
				select @ActivityWeek15 = JValue from #JsonTemp where JParam = 'CountStartArray.Step-14';
				select @ActivityWeek16 = JValue from #JsonTemp where JParam = 'CountStartArray.Step-15';
				select @ActivityWeek17 = JValue from #JsonTemp where JParam = 'CountStartArray.Step-16';
				select @ActivityWeek18 = JValue from #JsonTemp where JParam = 'CountStartArray.Step-17';
				select @ActivityWeek19 = JValue from #JsonTemp where JParam = 'CountStartArray.Step-18';
				select @ActivityWeek20 = JValue from #JsonTemp where JParam = 'CountStartArray.Step-19';
				
				select @UUsersWeek1 = JValue from #JsonTemp where JParam = 'UUsersNumArrayFirst.Step-0';
				select @UUsersWeek2 = JValue from #JsonTemp where JParam = 'UUsersNumArrayFirst.Step-1';
				select @UUsersWeek3 = JValue from #JsonTemp where JParam = 'UUsersNumArrayFirst.Step-2';
				select @UUsersWeek4 = JValue from #JsonTemp where JParam = 'UUsersNumArrayFirst.Step-3';
				select @UUsersWeek5 = JValue from #JsonTemp where JParam = 'UUsersNumArrayFirst.Step-4';
				select @UUsersWeek6 = JValue from #JsonTemp where JParam = 'UUsersNumArrayFirst.Step-5';
				select @UUsersWeek7 = JValue from #JsonTemp where JParam = 'UUsersNumArrayFirst.Step-6';
				select @UUsersWeek8 = JValue from #JsonTemp where JParam = 'UUsersNumArrayFirst.Step-7';
				select @UUsersWeek9 = JValue from #JsonTemp where JParam = 'UUsersNumArrayFirst.Step-8';
				select @UUsersWeek10 = JValue from #JsonTemp where JParam = 'UUsersNumArrayFirst.Step-9';
				select @UUsersWeek11 = JValue from #JsonTemp where JParam = 'UUsersNumArrayFirst.Step-10';
				select @UUsersWeek12 = JValue from #JsonTemp where JParam = 'UUsersNumArrayFirst.Step-11';
				select @UUsersWeek13 = JValue from #JsonTemp where JParam = 'UUsersNumArrayFirst.Step-12';
				select @UUsersWeek14 = JValue from #JsonTemp where JParam = 'UUsersNumArrayFirst.Step-13';
				select @UUsersWeek15 = JValue from #JsonTemp where JParam = 'UUsersNumArrayFirst.Step-14';
				select @UUsersWeek16 = JValue from #JsonTemp where JParam = 'UUsersNumArrayFirst.Step-15';
				select @UUsersWeek17 = JValue from #JsonTemp where JParam = 'UUsersNumArrayFirst.Step-16';
				select @UUsersWeek18 = JValue from #JsonTemp where JParam = 'UUsersNumArrayFirst.Step-17';
				select @UUsersWeek19 = JValue from #JsonTemp where JParam = 'UUsersNumArrayFirst.Step-18';
				select @UUsersWeek20 = JValue from #JsonTemp where JParam = 'UUsersNumArrayFirst.Step-19';


				-- print @OrgName +' '+ @firstUsage+' '+@ActivityWeek1 +' '+@ActivityWeek2 +' '+@ActivityWeek3 +' '+@ActivityWeek4 +' '+@UUsersWeek1 +' '+ @UUsersWeek2+' '+ @UUsersWeek3 +' '+ @UUsersWeek4
				-- insert the data into ClarizenData table

					INSERT INTO [dbo].[ClarizenData3] 
						   ([OrgName] ,[firstUsage] ,[ActivityWeek1] ,[ActivityWeek2] ,[ActivityWeek3] ,[ActivityWeek4]
						    ,[ActivityWeek5] ,[ActivityWeek6] ,[ActivityWeek7] ,[ActivityWeek8]
							,[ActivityWeek9] ,[ActivityWeek10] ,[ActivityWeek11] ,[ActivityWeek12]
							,[ActivityWeek13] ,[ActivityWeek14] ,[ActivityWeek15] ,[ActivityWeek16]
							,[ActivityWeek17] ,[ActivityWeek18] ,[ActivityWeek19] ,[ActivityWeek20]
						   ,[UUsersWeek1] ,[UUsersWeek2] ,[UUsersWeek3] ,[UUsersWeek4]
						   ,[UUsersWeek5] ,[UUsersWeek6] ,[UUsersWeek7] ,[UUsersWeek8]
						   ,[UUsersWeek9] ,[UUsersWeek10] ,[UUsersWeek11] ,[UUsersWeek12]
						   ,[UUsersWeek13] ,[UUsersWeek14] ,[UUsersWeek15] ,[UUsersWeek16]
						   ,[UUsersWeek17] ,[UUsersWeek18] ,[UUsersWeek19] ,[UUsersWeek20])
					 VALUES
						(@OrgName ,@firstUsage ,@ActivityWeek1 ,@ActivityWeek2 ,@ActivityWeek3 ,@ActivityWeek4
						    ,@ActivityWeek5 ,@ActivityWeek6 ,@ActivityWeek7 ,@ActivityWeek8
							,@ActivityWeek9  ,@ActivityWeek10  ,@ActivityWeek11  ,@ActivityWeek12 
							,@ActivityWeek13  ,@ActivityWeek14  ,@ActivityWeek15  ,@ActivityWeek16 
							,@ActivityWeek17  ,@ActivityWeek18  ,@ActivityWeek19  ,@ActivityWeek20 
						   ,@UUsersWeek1  ,@UUsersWeek2  ,@UUsersWeek3  ,@UUsersWeek4 
						   ,@UUsersWeek5  ,@UUsersWeek6  ,@UUsersWeek7  ,@UUsersWeek8 
						   ,@UUsersWeek9  ,@UUsersWeek10  ,@UUsersWeek11  ,@UUsersWeek12 
						   ,@UUsersWeek13  ,@UUsersWeek14  ,@UUsersWeek15  ,@UUsersWeek16 
						   ,@UUsersWeek17  ,@UUsersWeek18  ,@UUsersWeek19  ,@UUsersWeek20 )
				
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
	
