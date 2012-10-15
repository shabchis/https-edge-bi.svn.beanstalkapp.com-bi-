USE [Seperia]
GO
/****** Object:  StoredProcedure [dbo].[SP_Alerts_GetUserByAccountID]    Script Date: 10/15/2012 15:46:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_Alerts_GetUserByAccountID]
		@AccountID int,
		@UsersEmails as varchar(8000) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;


Select @UsersEmails = COALESCE(@UsersEmails+'', '','''')+ISNULL(Email +' ; ','''')
From  (
			-- For user groups only
		SELECT  U.Email as Email-- ,U.Name
		  FROM [User_GUI_AccountPermission] AP
			inner join [User_GUI_UserGroup] UG
				on AP.TargetID = UG.GroupID
			inner join [User_GUI_UserGroupUser] UGU
				on UG.GroupID = UGU.GroupID
			inner join [User_GUI_User] U
				on UGU.UserID = U.UserID
		  where AccountID = @AccountID
			and TargetIsGroup = 1
			and PermissionType = 'RecieveAlerts'

		UNION ALL

		-- For user only
		SELECT U.Email as Email-- ,U.Name
		  FROM [User_GUI_AccountPermission] AP	
			inner join [User_GUI_User] U
				on AP.TargetID = U.UserID
			  where AccountID = @AccountID
			and TargetIsGroup = 0
			and PermissionType = 'RecieveAlerts'
		)	 A
		
		set @UsersEmails = Left(@UsersEmails, LEN(@UsersEmails)-1) ;
END

