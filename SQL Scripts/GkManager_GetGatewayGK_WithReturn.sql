USE [Seperia]
GO
/****** Object:  StoredProcedure [dbo].[GkManager_GetGatewayGK_WithReturn]    Script Date: 08/10/2013 15:13:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[GkManager_GetGatewayGK_WithReturn]
	-- Identity columns
	@Account_ID		Int,					-- 1
	@Gateway_id		Nvarchar(4000),			-- 2

	-- Additional columns
	@Channel_ID		Int				= NULL,	-- 3
	@Campaign_GK	BigInt			= NULL,	-- 4
	@Adgroup_GK		BigInt			= NULL,	-- 5
	@Gateway		NVarChar(MAX)   = NULL,	-- 6
	@Dest_URL		NVarChar(MAX)   = NULL,	-- 7
	@Reference_Type	Int				= NULL,	-- 8
	@Reference_ID	BigInt			= NULL	-- 9
AS
BEGIN
	SET NOCOUNT ON;

	-- Comparison values
	declare @current_Channel_ID		Int;			-- 3
	declare @current_Campaign_GK	BigInt;			-- 4
	declare @current_Adgroup_GK		BigInt;			-- 5
	declare @current_Gateway		NVarChar(MAX);	-- 6
	declare @current_Dest_URL		NVarChar(MAX);	-- 7
	declare @current_Reference_Type	BigInt;			-- 8
	declare @current_Reference_ID	BigInt;			-- 9

	-- Return value
	declare @returnValue BigInt;

	-- Log action
	declare @action nvarchar(6);
	set @action = NULL;

	/*******************************************/
	begin transaction

	-- Lookup
	select top 1
		@returnValue			= Gateway_GK,
		@current_Channel_ID		= Channel_ID,
		@current_Campaign_GK	= Campaign_GK,
		@current_Adgroup_GK		= Adgroup_GK,
		@current_Gateway		= Gateway,
		@current_Dest_URL		= Dest_URL,
		@current_Reference_Type	= Reference_Type,
		@current_Reference_ID	= Reference_ID
	from
		UserProcess_GUI_Gateway with(SERIALIZABLE, XLOCK)
	where
		Account_ID = @Account_ID and
		Gateway_id = IsNULL(@Gateway_id,'No Tracker Data');

	-- insert
	if @returnValue is null
	begin
		insert into UserProcess_GUI_Gateway
		(
			Account_ID,
			Gateway_id,
			Channel_ID,
			Campaign_GK,
			Adgroup_GK,
			Gateway,
			Dest_URL,
			Reference_Type,
			Reference_ID,
			LastUpdated,
			Segment1,
			Segment2,
			Segment3,
			Segment4,
			Segment5
		)
		select
			@Account_ID,
			@Gateway_id,
			isnull(@Channel_ID,-1),
			@Campaign_GK,
			@Adgroup_GK,
			NULL, -- @Gateway, the null value is overrides by the SSIS process
			@Dest_URL,
			@Reference_Type,
			@Reference_ID,
			getdate(),
			(select Segment1 from UserProcess_GUI_PaidAdgroup where Adgroup_GK = @Adgroup_GK),
			(select Segment2 from UserProcess_GUI_PaidAdgroup where Adgroup_GK = @Adgroup_GK),
			(select Segment3 from UserProcess_GUI_PaidAdgroup where Adgroup_GK = @Adgroup_GK),
			(select Segment4 from UserProcess_GUI_PaidAdgroup where Adgroup_GK = @Adgroup_GK),
			(select Segment5 from UserProcess_GUI_PaidAdgroup where Adgroup_GK = @Adgroup_GK);

		set @returnValue = scope_identity();
		set @action = 'INSERT';
	end

	-- update
	else
	begin
		if
			(@Channel_ID is not null and isnull(@current_Channel_ID,-1)			!= isnull(@Channel_ID,-1)) or
			(@Campaign_GK is not null and isnull(@current_Campaign_GK,-1)		!= isnull(@Campaign_GK,-1)) or
			(@Adgroup_GK is not null and isnull(@current_Adgroup_GK,-1)			!= isnull(@Adgroup_GK,-1)) or
		--	(@Gateway is not null and isnull(@current_Gateway,-1)				!= isnull(@Gateway,'')) or
			(@Dest_URL is not null and isnull(@current_Dest_URL,-1)				!= isnull(@Dest_URL,'')) or
			(@Reference_Type is not null and isnull(@current_Reference_Type,-1)	!= isnull(@Reference_Type,-1)) or
			(@Reference_ID is not null and isnull(@current_Reference_ID,-1)		!= isnull(@Reference_ID,-1))
		begin
			update UserProcess_GUI_Gateway
			set
				Channel_ID		= isnull(@Channel_ID, Channel_ID),
				Campaign_GK		= isnull(@Campaign_GK, Campaign_GK),
				Adgroup_GK		= isnull(@Adgroup_GK, Adgroup_GK),
			--	Gateway			= isnull(@Gateway, Gateway),
				Dest_URL		= isnull(@Dest_URL, Dest_URL),
				Reference_Type	= isnull(@Reference_Type, Reference_Type),
				Reference_ID	= isnull(@Reference_ID, Reference_ID),
				LastUpdated		= getdate(),
				Segment1		= ISNULL(Segment1, (select Segment1 from UserProcess_GUI_PaidAdgroup where Adgroup_GK = @Adgroup_GK)),
				Segment2		= ISNULL(Segment2, (select Segment2 from UserProcess_GUI_PaidAdgroup where Adgroup_GK = @Adgroup_GK)),
				Segment3		= ISNULL(Segment3, (select Segment3 from UserProcess_GUI_PaidAdgroup where Adgroup_GK = @Adgroup_GK)),
				Segment4		= ISNULL(Segment4, (select Segment4 from UserProcess_GUI_PaidAdgroup where Adgroup_GK = @Adgroup_GK)),
				Segment5		= ISNULL(Segment5, (select Segment5 from UserProcess_GUI_PaidAdgroup where Adgroup_GK = @Adgroup_GK))
			where
				Account_ID = @Account_ID and
				Gateway_id = @Gateway_id;

				--Gateway_GK = @returnValue;
			set @action = 'UPDATE';
		end
	end

	commit

	if @action is not null
	begin
		insert into Log_GetGatewayGK 
		 ([Date]
           ,[GatewayGK]
           ,[ACTION]
           ,[Account_ID]
           ,[Gateway_id]
           ,[Channel_ID]
           ,[Campaign_GK]
           ,[Adgroup_GK]
           ,[Gateway]
           ,[Dest_URL]
           ,[Reference_Type]
           ,[Reference_ID]
           ,[current_Channel_ID]
           ,[current_Campaign_GK]
           ,[current_Adgroup_GK]
           ,[current_Gateway]
           ,[current_Dest_URL]
           ,[current_Reference_Type]
           ,[current_Reference_ID])
           values
		(
			getdate(),
			@returnValue,
			@action,
			@Account_ID,
			@Gateway_id,
			@Channel_ID,
			@Campaign_GK,
			@Adgroup_GK,
			@Gateway,
			@Dest_URL,
			@Reference_Type,
			@Reference_ID,
			@current_Channel_ID,
			@current_Campaign_GK,
			@current_Adgroup_GK,
			@current_Gateway,
			@current_Dest_URL,
			@current_Reference_Type,
			@current_Reference_ID
		);
	end;

	return @returnValue;

END
