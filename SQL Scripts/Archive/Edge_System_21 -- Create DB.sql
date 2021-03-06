/****** Object:  Database [Edge_System_21]    Script Date: 12/01/2011 13:10:16 ******/
CREATE DATABASE [Edge_System_21] ON  PRIMARY 
( NAME = N'Edge_System', FILENAME = N'F:\SQL_Data\Edge_System_21.mdf' , SIZE = 364992KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'Edge_System_log', FILENAME = N'F:\SQL_Data\Edge_System_21.ldf' , SIZE = 1024KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO

ALTER DATABASE [Edge_System_21] SET COMPATIBILITY_LEVEL = 100
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Edge_System_21].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO

ALTER DATABASE [Edge_System_21] SET ANSI_NULL_DEFAULT OFF 
GO

ALTER DATABASE [Edge_System_21] SET ANSI_NULLS OFF 
GO

ALTER DATABASE [Edge_System_21] SET ANSI_PADDING OFF 
GO

ALTER DATABASE [Edge_System_21] SET ANSI_WARNINGS OFF 
GO

ALTER DATABASE [Edge_System_21] SET ARITHABORT OFF 
GO

ALTER DATABASE [Edge_System_21] SET AUTO_CLOSE OFF 
GO

ALTER DATABASE [Edge_System_21] SET AUTO_CREATE_STATISTICS ON 
GO

ALTER DATABASE [Edge_System_21] SET AUTO_SHRINK OFF 
GO

ALTER DATABASE [Edge_System_21] SET AUTO_UPDATE_STATISTICS ON 
GO

ALTER DATABASE [Edge_System_21] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO

ALTER DATABASE [Edge_System_21] SET CURSOR_DEFAULT  GLOBAL 
GO

ALTER DATABASE [Edge_System_21] SET CONCAT_NULL_YIELDS_NULL OFF 
GO

ALTER DATABASE [Edge_System_21] SET NUMERIC_ROUNDABORT OFF 
GO

ALTER DATABASE [Edge_System_21] SET QUOTED_IDENTIFIER OFF 
GO

ALTER DATABASE [Edge_System_21] SET RECURSIVE_TRIGGERS OFF 
GO

ALTER DATABASE [Edge_System_21] SET  DISABLE_BROKER 
GO

ALTER DATABASE [Edge_System_21] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO

ALTER DATABASE [Edge_System_21] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO

ALTER DATABASE [Edge_System_21] SET TRUSTWORTHY OFF 
GO

ALTER DATABASE [Edge_System_21] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO

ALTER DATABASE [Edge_System_21] SET PARAMETERIZATION SIMPLE 
GO

ALTER DATABASE [Edge_System_21] SET READ_COMMITTED_SNAPSHOT OFF 
GO

ALTER DATABASE [Edge_System_21] SET HONOR_BROKER_PRIORITY OFF 
GO

ALTER DATABASE [Edge_System_21] SET  READ_WRITE 
GO

ALTER DATABASE [Edge_System_21] SET RECOVERY SIMPLE 
GO

ALTER DATABASE [Edge_System_21] SET  MULTI_USER 
GO

ALTER DATABASE [Edge_System_21] SET PAGE_VERIFY CHECKSUM  
GO

ALTER DATABASE [Edge_System_21] SET DB_CHAINING OFF 
GO


USE [Edge_System_21]
GO

/****** Object:  StoredProcedure [dbo].[SP_Core_AvgFileSize]    Script Date: 12/01/2011 13:14:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_Core_AvgFileSize]
(
	@daycode as nvarchar (10),
    @accountid as nvarchar (10) ,
	@Servicetype as nvarchar (300)
)
AS
-- This SP returns the average size file of the last 30 days from the day_code given
-- the 30 days counted from the day_code given & -30 days ago.


DECLARE @result int
Declare @SQL As nvarchar(4000)
Declare @CombinedResource as nvarchar (500)

set @CombinedResource = @daycode+@accountid+@Servicetype
print 'CombinedResource= '+@CombinedResource

BEGIN TRANSACTION;

EXEC @result = sp_getapplock @Resource = @CombinedResource, 
               @LockMode = 'Exclusive';

IF @result < 0
BEGIN
    ROLLBACK TRANSACTION;
	RAISERROR ('Unable to acquire lock', 16, 1 )
END
ELSE
BEGIN
	-- Execute the code
/*
select avg(FileSize) from source.dbo.RetrievedFiles
where accountid = 7--@accountid 
and Servicetype = 'Google.Adwords'--@Servicetype
and daycode between -- last month
		CASE WHEN convert(int,SUBSTRING('20090620', 5, 4)) < 131 
			THEN left('20090620',6)+'01'
            ELSE 
				CASE WHEN convert(int,SUBSTRING('20090620', 5, 2)) < 10 
						THEN left('20090620',4)+'0'+convert(nvarchar(10),convert(int,SUBSTRING('20090620', 5, 2))-1) +right('20090620',2)
						ELSE left('20090620',4)+convert(nvarchar(10),convert(int,SUBSTRING('20090620', 5, 2))-1) +right('20090620',2)
				END		
            END
		and -- current daycode
			'20090620'
		and FileSize > 0
*/

	Set @SQL = 
' select avg(FileSize) from dbo.RetrievedFiles where accountid = '+ @accountid + 
' and Servicetype = '''+@Servicetype+'''
and Daycode between 
		CASE WHEN convert(int,SUBSTRING('''+@daycode+''', 5, 4)) < 131 
			THEN left('''+@daycode+''',6)+''01''
            ELSE 
				CASE WHEN convert(int,SUBSTRING('''+@daycode+''', 5, 2)) < 10 
						THEN left('''+@daycode+''',4)+''0''+convert(nvarchar(10),convert(int,SUBSTRING('''+@daycode+''', 5, 2))-1) +right('''+@daycode+''',2)
						ELSE left('''+@daycode+''',4)+convert(nvarchar(10),convert(int,SUBSTRING('''+@daycode+''', 5, 2))-1) +right('''+@daycode+''',2)
				END		
            END
		and '''+@daycode+'''
	and FileSize > 0'
	print @SQL  -- For debug
	Exec Sp_executesql @SQL
	--WAITFOR DELAY '00:00:20' -- for debugging app locks

    EXEC @result = sp_releaseapplock @Resource = @CombinedResource;
    COMMIT TRANSACTION;
END;
GO
/****** Object:  Table [dbo].[CORE_ServiceInstance]    Script Date: 12/01/2011 13:14:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CORE_ServiceInstance](
	[InstanceID] [bigint] IDENTITY(1000000,1) NOT NULL,
	[AccountID] [int] NOT NULL,
	[ParentInstanceID] [bigint] NULL,
	[ServiceName] [nvarchar](100) NOT NULL,
	[TimeScheduled] [datetime] NULL,
	[TimeStarted] [datetime] NULL,
	[TimeEnded] [datetime] NULL,
	[Priority] [int] NOT NULL,
	[State] [int] NOT NULL,
	[Progress] [float] NOT NULL,
	[Outcome] [int] NOT NULL,
	[ServiceUrl] [nvarchar](100) NULL,
	[Configuration] [xml] NOT NULL,
	[ActiveRule] [xml] NULL,
 CONSTRAINT [PK_CORE_ServiceInstance] PRIMARY KEY CLUSTERED 
(
	[InstanceID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AccountsServicesLog]    Script Date: 12/01/2011 13:14:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AccountsServicesLog](
	[Account_ID] [int] NOT NULL,
	[DayCode] [int] NOT NULL,
	[Status] [int] NULL,
	[Service] [int] NOT NULL,
	[Instance_ID] [int] NULL,
	[LastUpdated] [datetime] NULL,
	[Application] [nvarchar](50) NULL,
	[Service_name] [nvarchar](100) NULL,
	[Account_Name] [nvarchar](50) NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_account_day_service_status_4_SPUpdate] ON [dbo].[AccountsServicesLog] 
(
	[Account_ID] ASC,
	[DayCode] ASC,
	[Service] ASC,
	[Status] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RetrievedFiles]    Script Date: 12/01/2011 13:14:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RetrievedFiles](
	[AccountID] [int] NOT NULL,
	[ServiceType] [nvarchar](50) NOT NULL,
	[RetrieverInstanceID] [int] NOT NULL,
	[ProcessorInstanceID] [int] NULL,
	[RetrieveDate] [datetime] NULL,
	[ProcessDate] [datetime] NULL,
	[daycode] [int] NULL,
	[ParentInstanceID] [int] NULL,
	[Path] [nvarchar](max) NULL,
	[SourceUrl] [nvarchar](max) NULL,
	[Parameters] [nvarchar](max) NULL,
	[FileSize] [bigint] NULL
) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[MaxJobID]    Script Date: 12/01/2011 13:14:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[MaxJobID](@Table_Name As Nvarchar(100))
AS
Declare @SQL As nvarchar(4000)
set @Sql='
SELECT  MAX(Job_ID) AS Expr1
FROM  '+@Table_Name
exec Sp_executesql @SQL
GO
/****** Object:  Table [dbo].[Log]    Script Date: 12/01/2011 13:14:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Log](
	[ID] [bigint] IDENTITY(1000000001,1) NOT NULL,
	[DateRecorded] [datetime] NOT NULL,
	[MachineName] [nvarchar](50) NOT NULL,
	[ProcessID] [int] NOT NULL,
	[Source] [nvarchar](50) NOT NULL,
	[MessageType] [int] NOT NULL,
	[ServiceInstanceID] [bigint] NULL,
	[AccountID] [int] NULL,
	[Message] [nvarchar](max) NULL,
	[IsException] [bit] NOT NULL,
	[ExceptionDetails] [nvarchar](max) NULL
) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[UpdateStatus]    Script Date: 12/01/2011 13:14:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UpdateStatus]
(
	@Status nchar(50),
	@Job_ID int
)
AS
	SET NOCOUNT OFF;
UPDATE  GAnalytics_Retriever
SET       JobStatus = @Status
WHERE  (Job_ID = @Job_ID)
GO
/****** Object:  StoredProcedure [dbo].[SP_ServiceConfigExecutionTimesCalculation]    Script Date: 12/01/2011 13:14:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Amit bluman
-- Create date: 27/4/2011
-- Update date: 10/8/2011
-- =============================================
CREATE PROCEDURE [dbo].[SP_ServiceConfigExecutionTimesCalculation]
	
AS
BEGIN
	
	SET NOCOUNT ON;


DECLARE @ConfigName nvarchar(4000) -- for cursor
DECLARE @ProfileID int				-- for cursor
DECLARE @NumOfRows int				-- in order to use the right function


-- Create the execution time temp table with all the services & accounts
-- not needed in he SP -----   DROP TABLE #tmpExecTime

SELECT  
ServiceName AS [ConfigName] ,AccountID AS [ProfileID],1 AS [TempPercentile],
DATEDIFF(SECOND,TimeStarted,TimeEnded) As [ExecTimeInSec]
into #tmpExecTime
FROM ServiceInstance
WHERE TimeEnded is not null AND 
ParentInstanceID IS NULL
and TimeEnded > DATEADD(Day,-30,timeended)  -- filters the last 30 days data
and DATEDIFF(SECOND,TimeStarted,TimeEnded)  is not null

-- truncate the old data ServiceConfigExecutionTimes
truncate table seperia.dbo.ServiceConfigExecutionTimes

-- create a cluster using the service + account , and each one will create the 100 precentile process
 
DECLARE index_cursor CURSOR FOR 
			select distinct ConfigName, ProfileID
			from #tmpExecTime
OPEN index_cursor

FETCH NEXT FROM index_cursor 
INTO @ConfigName, @ProfileID

WHILE @@FETCH_STATUS = 0
BEGIN

-- deletes the relevant data for each service & account from the statistics table
delete from seperia.dbo.ServiceConfigExecutionTimes
where ConfigName = @ConfigName and ProfileID = @ProfileID 

-- Verify whether the service & account has more than 100 rows, 
-- if there are less than 10 rows it will get the system default of 5 minutes till it will have 10 rows history at least
		set @NumOfRows = 
			(select COUNT(*)
			from #tmpExecTime
			where ConfigName =  @ConfigName
			and ProfileID = @ProfileID )
 -- Select & cluster the data to 100 groups
 
 -- For debug
	-- print @NumOfRows
	--print @ConfigName
	--print @ProfileID 
	
	
		if @NumOfRows between 10 and 49  
			Begin
				insert into seperia.dbo.ServiceConfigExecutionTimes
				select ConfigName, ProfileID, Percentile, Cast(Avg(ExecTimeInSec)as decimal(18,2))+1 As [Value]
				-- the plus 1 purpose is to avoid zeros in the final table
					from (	select ConfigName, ProfileID,
							NTILE(100) OVER(ORDER BY ExecTimeInSec ASC) AS [Percentile],
							ExecTimeInSec
							from (
									select ConfigName, ProfileID,
									ExecTimeInSec
									from #tmpExecTime
									where 
									ConfigName = @ConfigName and
									ProfileID = @ProfileID
								 UNION ALL 
									select ConfigName, ProfileID,
									ExecTimeInSec
									from #tmpExecTime
									where 
									ConfigName = @ConfigName and
									ProfileID = @ProfileID
								UNION ALL 
									select ConfigName, ProfileID,
									ExecTimeInSec
									from #tmpExecTime
									where 
									ConfigName = @ConfigName and
									ProfileID = @ProfileID
								 UNION ALL 	
									select ConfigName, ProfileID,
									ExecTimeInSec
									from #tmpExecTime
									where 
									ConfigName = @ConfigName and
									ProfileID = @ProfileID
								 UNION ALL 
									select ConfigName, ProfileID,
									ExecTimeInSec
									from #tmpExecTime
									where 
									ConfigName = @ConfigName and
									ProfileID = @ProfileID
								UNION ALL 
									select ConfigName, ProfileID,
									ExecTimeInSec
									from #tmpExecTime
									where 
									ConfigName = @ConfigName and
									ProfileID = @ProfileID
									UNION ALL 
									select ConfigName, ProfileID,
									ExecTimeInSec
									from #tmpExecTime
									where 
									ConfigName = @ConfigName and
									ProfileID = @ProfileID
								UNION ALL 
									select ConfigName, ProfileID,
									ExecTimeInSec
									from #tmpExecTime
									where 
									ConfigName = @ConfigName and
									ProfileID = @ProfileID
								 UNION ALL 	
									select ConfigName, ProfileID,
									ExecTimeInSec
									from #tmpExecTime
									where 
									ConfigName = @ConfigName and
									ProfileID = @ProfileID
								 UNION ALL 
									select ConfigName, ProfileID,
									ExecTimeInSec
									from #tmpExecTime
									where 
									ConfigName = @ConfigName and
									ProfileID = @ProfileID
								) Temp10to50
					) ClusteredExecTime
				group by ConfigName, ProfileID, Percentile
			End
		if @NumOfRows between 50 and 99 
		Begin
				insert into seperia.dbo.ServiceConfigExecutionTimes
				select ConfigName, ProfileID, Percentile, Cast(Avg(ExecTimeInSec)as decimal(18,2))+1 As [Value]
					from (	select ConfigName, ProfileID,
							NTILE(100) OVER(ORDER BY ExecTimeInSec ASC) AS [Percentile],
							ExecTimeInSec
							from (
									select ConfigName, ProfileID,
									ExecTimeInSec
									from #tmpExecTime
									where 
									ConfigName = @ConfigName and
									ProfileID = @ProfileID
								 UNION ALL 
									select ConfigName, ProfileID,
									ExecTimeInSec
									from #tmpExecTime
									where 
									ConfigName = @ConfigName and
									ProfileID = @ProfileID
								UNION ALL 
									select ConfigName, ProfileID,
									ExecTimeInSec
									from #tmpExecTime
									where 
									ConfigName = @ConfigName and
									ProfileID = @ProfileID
								) Temp50to99
					) ClusteredExecTime
				group by ConfigName, ProfileID, Percentile
			End
		if @NumOfRows > 99  
			Begin	
				-- ** need to deal with services which has less then 100 rows  
				insert into seperia.dbo.ServiceConfigExecutionTimes
				select ConfigName, ProfileID, Percentile, Cast(Avg(ExecTimeInSec)as decimal(18,2))+1 As [Value]
					from (
						select 
						ConfigName, ProfileID,
						NTILE(100) OVER(ORDER BY ExecTimeInSec ASC) AS [Percentile],
						ExecTimeInSec
						from #tmpExecTime
						where ConfigName = @ConfigName
						and ProfileID = @ProfileID
					) ClusteredExecTime
				group by ConfigName, ProfileID, Percentile
			End


-- Get the next index.
FETCH NEXT FROM index_cursor 
INTO @ConfigName, @ProfileID

END 

CLOSE index_cursor

DEALLOCATE index_cursor


END
GO
/****** Object:  View [dbo].[Instance_End_Time_V]    Script Date: 12/01/2011 13:14:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Instance_End_Time_V]
AS
SELECT     TOP (100) PERCENT INS.InstanceID, L.AccountID, MAX(L.DateRecorded) AS EndTime
FROM         dbo.CORE_ServiceInstance AS INS INNER JOIN
                      dbo.[Log] AS L ON INS.InstanceID = L.ServiceInstanceID
WHERE     (INS.ParentInstanceID IS NULL)
GROUP BY INS.InstanceID, L.AccountID
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[23] 4[24] 2[14] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "INS"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 228
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "L"
            Begin Extent = 
               Top = 6
               Left = 266
               Bottom = 125
               Right = 459
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 2700
         Width = 2415
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'Instance_End_Time_V'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'Instance_End_Time_V'
GO
/****** Object:  StoredProcedure [dbo].[GetAccountsServicesLog]    Script Date: 12/01/2011 13:14:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Shay Bar-Chen
-- Create date: 17/01/2011
-- =============================================
CREATE PROCEDURE [dbo].[GetAccountsServicesLog] 
	@day As Nvarchar(100)= null
	
	 
	
AS
		set @day =	case
			when @day is null then cast(CONVERT(varchar(8),GETDATE() , 112) AS datetime)
			else @day
		end
BEGIN
		
		
		
		
		SELECT TOP 1000 [Account_ID]
			,[DayCode]
			,[Status]
			 ,[Service]
			 ,[Instance_ID]
			 ,[LastUpdated]
			 ,[Application]
			 ,[Service_name]
		FROM [Source].[dbo].[AccountsServicesLog] 
		where [LastUpdated] >=@day
END
GO
/****** Object:  StoredProcedure [dbo].[SP_Check_Get_Delivery_Ticket]    Script Date: 12/01/2011 13:14:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alon Yaari
-- Create date: 23/08/2011
-- Description:	in order to prevent duplicate data every pipeline
-- service will check if their is any  other services with the same signature that is runing right now (DeliveryTicketTable)
-- if one more service already take the tickect and it's not ended yet then service will aborted else it will continue runing this will
-- happend at the initalizer and commit 
-- =============================================
CREATE PROCEDURE [dbo].[SP_Check_Get_Delivery_Ticket] 
	@DeliverySignature nvarchar(400),
	@DeliveryID Nvarchar(50),
	@WorkflowInstanceID int	
AS
BEGIN
	SET NOCOUNT ON;
	Declare @InstanceID as int;
	SET @InstanceID=
		(SELECT WorkflowInstanceID
		FROM dbo.DeliveryTicket
		WHERE DeliverySignature=@DeliverySignature)
	IF  @InstanceID is not null			
			IF @InstanceID<>@WorkflowInstanceID
				BEGIN
					IF (SELECT TimeEnded
						FROM dbo.ServiceInstance
						WHERE InstanceID=@InstanceID) IS NOT NULL
						BEGIN
							RAISERROR('THEIR IS OTHER SERVICE WITH THE SAME SIGNATURE ALREADY RUNING RIGHT NOW!',10,1);
						END
				END
					
	ELSE
		BEGIN
		INSERT INTO dbo.DeliveryTicket VALUES (@DeliverySignature,@DeliveryID,@WorkflowInstanceID)
		END
		
		
		
			
		
			
	

   
END
GO
/****** Object:  StoredProcedure [dbo].[DeliveryTicket_Get]    Script Date: 12/01/2011 13:14:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DeliveryTicket_Get] 
	@deliverySignature nvarchar(400),
	@deliveryID Nvarchar(50),
	@workflowInstanceID bigint	
AS
BEGIN
	SET NOCOUNT ON;

	begin transaction;

	DECLARE @found as int;
	SET @found = 2;
	
	SELECT @found =
		CASE
			WHEN dt.WorkflowInstanceID != @workflowInstanceID THEN 0
			WHEN @found = 2 and dt.WorkflowInstanceID = @workflowInstanceID THEN 1
		END
		
	FROM DeliveryTicket dt WITH(XLOCK)
		INNER JOIN dbo.ServiceInstance si ON
			si.InstanceID = dt.WorkflowInstanceID and
			si.State != 6 and si.State!=7
	WHERE
		dt.DeliverySignature = @deliverySignature;
	;
	
	IF @found = 2
	BEGIN
		INSERT INTO dbo.DeliveryTicket
			(DeliverySignature,WorkflowInstanceID,DeliveryID)
		VALUES
			(@deliverySignature,@workflowInstanceID,@deliveryID);
	END;
	
	select @found;
		
	commit transaction;
		
END
GO
/****** Object:  StoredProcedure [dbo].[Scheduler_Instance_Time_Diff]    Script Date: 12/01/2011 13:14:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[Scheduler_Instance_Time_Diff]
AS


SELECT INS.InstanceID ,INS.ServiceName, EndTimeView.AccountID, INS.TimeStarted, EndTimeView.EndTime, 
		DATEDIFF(minute,INS.TimeStarted, EndTimeView.EndTime) DiffInMinutes,
		DATEDIFF(second,INS.TimeStarted, EndTimeView.EndTime) DiffInSeconds
  FROM [Source].[dbo].[CORE_ServiceInstance] INS
  inner join [Source].[dbo].Instance_End_Time_V EndTimeView
	on INS.InstanceID = EndTimeView.InstanceID
	where INS.ParentInstanceID is null 
	--	and ServiceName = 'AdWordsCreativeAccounts'
		order by 4 desc
GO
/****** Object:  Default [DF_dbo.AccountsServicesLog_Status]    Script Date: 12/01/2011 13:14:34 ******/
ALTER TABLE [dbo].[AccountsServicesLog] ADD  CONSTRAINT [DF_dbo.AccountsServicesLog_Status]  DEFAULT (NULL) FOR [Status]
GO
/****** Object:  Default [DF_Log_DateRecorded]    Script Date: 12/01/2011 13:14:34 ******/
ALTER TABLE [dbo].[Log] ADD  CONSTRAINT [DF_Log_DateRecorded]  DEFAULT (getdate()) FOR [DateRecorded]
GO
/****** Object:  Default [DF_Log_IsException]    Script Date: 12/01/2011 13:14:34 ******/
ALTER TABLE [dbo].[Log] ADD  CONSTRAINT [DF_Log_IsException]  DEFAULT ((0)) FOR [IsException]
GO
