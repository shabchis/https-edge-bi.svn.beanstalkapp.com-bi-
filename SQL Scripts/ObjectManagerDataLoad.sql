
USE [EdgeDWH]
GO 

Create  procedure [dbo].[ObjectManager_ObjectDataLoad]

as
BEGIN

-- After definition sync (previous SP), the data will be loaded to a specific table based on CLR3 ([GetDataByVirtualTableName])
-- This section can be performed by calling SSIS process with parameters
print 'ggg'
END






