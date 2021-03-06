USE [Seperia_DWH]
GO
/****** Object:  StoredProcedure [dbo].[AD_Alert_Report]    Script Date: 6/27/2013 3:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Amit Bluman
-- Create date: 27/6/2013
-- Description:	This is the validation and permission check for all reporting services
-- =============================================
ALTER PROCEDURE [dbo].[Validate_Report]
	(@PermissionName varchar(50),
	 @session varchar(1000),
	 @Account_ID int,
	 @IsValid int OUTPUT )
	
AS
BEGIN

	-- declare @PermissionName varchar(50) = 'alerts/ad'
	declare @IsSessionValid int
	declare @IsPermissionValid int
	declare @MyUserID int
	declare @Session_Decrypted int
	-----------------------------------------------------------------------------------
	-- EXEC @Session_Decrypted = [Seperia].[dbo].[SessionDecryptor] @session = @session
	-- Need to activate the row above this is Shay's SessionDecryptor
	-----------------------------------------------------------------------------------

	-- Validate session
	-------- uncomment it when ready -----------------------------------------------------------------------------
	--CREATE TABLE #MySessionValidation  (valid int null, UserID varchar(100) null);

	--INSERT INTO #MySessionValidation EXEC [seperia].[dbo].[Session_ValidateSession] @SessionID = @Session_Decrypted 

	--SELECT @IsSessionValid = valid, @MyUserID = UserID FROM #MySessionValidation 
	---------------------------------------------------------------------------------------
	set @IsSessionValid = 1 -- remove it when Shay's SessionDecryptor is ready
	------------------------------------------------------------------------------------------
	-- Validate user and account permissions
	 CREATE TABLE #MyPermissions  (AccountID int null, PermissionType varchar(100) null);

	 INSERT INTO #MyPermissions  EXEC  [seperia].[dbo].[User_CalculatePermissions]  @userID =  @MyUserID
  
	 SELECT @IsPermissionValid = 1 FROM #MyPermissions
		WHERE AccountID = @Account_ID and PermissionType = @PermissionName 

--	 select 'UserID: ' + convert(nvarchar(10),@MyUserID)
--	 select 'sessionValid: ' + convert(nvarchar(10),@IsSessionValid)
--	 select 'PermissionValid: ' + convert(nvarchar(10),IsNull(@IsPermissionValid,-1))
 
	IF (IsNull(@IsSessionValid,0) ! = 0 AND IsNull(@IsPermissionValid,-1) = 1)	SET @IsValid = 1	
	Else SET @IsValid = -2	-- No valid session or permission
	
	SELECT @IsValid 
END