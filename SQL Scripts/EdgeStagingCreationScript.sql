USE [EdgeStaging]
GO
/****** Object:  Table [dbo].[AdChannel]    Script Date: 12/06/2012 16:29:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AdChannel](
	[AccountID] [bigint] NULL,
	[ChannelID] [bigint] NULL,
	[AdGK] [bigint] NULL,
	[AdgroupGK] [bigint] NULL,
	[CampaignGK] [bigint] NULL,
	[AdCreative1GK] [bigint] NULL,
	[Creative1GK] [bigint] NULL,
	[AdCreative2GK] [bigint] NULL,
	[Creative2GK] [bigint] NULL,
	[AdCreative3GK] [bigint] NULL,
	[Creative3GK] [bigint] NULL,
	[AdTarget1GK] [bigint] NULL,
	[Target1GK] [bigint] NULL,
	[ADTarget2GK] [bigint] NULL,
	[Target2GK] [bigint] NULL,
	[ADTarget3GK] [bigint] NULL,
	[Target3GK] [bigint] NULL,
	[AdTargetMatch1GK] [bigint] NULL,
	[AdTargetMatch2GK] [bigint] NULL,
	[AdTargetMatch3GK] [bigint] NULL,
	[GenericTargetMatch1GK] [bigint] NULL,
	[GenericTargetMatch2GK] [bigint] NULL,
	[GenericTargetMatch3GK] [bigint] NULL,
	[AdTrackerGK(Unified)] [bigint] NULL,
	[AdTracker1GK] [bigint] NULL,
	[AdTracker2GK] [bigint] NULL,
	[AdTracker3GK] [bigint] NULL,
	[Segment1GK] [bigint] NULL,
	[Segment2GK] [bigint] NULL,
	[Segment3GK] [bigint] NULL,
	[Segment4GK] [bigint] NULL,
	[Segment5GK] [bigint] NULL,
	[Segment6GK] [bigint] NULL,
	[Segment7GK] [bigint] NULL,
	[Segment8GK] [bigint] NULL,
	[Segment9GK] [bigint] NULL,
	[Segment10GK] [bigint] NULL,
	[TargetPeriodStart] [datetime] NULL,
	[TargetPeriodEnd] [datetime] NULL,
	[Currency] [nvarchar](10) NULL,
	[OutputID] [char](32) NULL,
	[AveragePosition] [float] NULL,
	[Cost] [float] NULL,
	[Clicks] [int] NULL,
	[Impressions] [int] NULL,
	[UniqueImpressions] [int] NULL,
	[UniqueClicks] [int] NULL,
	[TotalConversionsOnePerClick] [int] NULL,
	[TotalConversionsManyPerClick] [int] NULL,
	[Signups] [int] NULL,
	[Purchases] [int] NULL,
	[Leads] [int] NULL,
	[PageViews] [int] NULL,
	[Default] [int] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[BackEnd]    Script Date: 12/06/2012 16:29:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BackEnd](
	[AccountID] [bigint] NULL,
	[ChannelID] [bigint] NULL,
	[GenericTarget1GK] [bigint] NULL,
	[Target1GK] [bigint] NULL,
	[GenericTarget2GK] [bigint] NULL,
	[Target2GK] [bigint] NULL,
	[GenericTarget3GK] [bigint] NULL,
	[Target3GK] [bigint] NULL,
	[AdTargetMatch1GK] [bigint] NULL,
	[AdTargetMatch2GK] [bigint] NULL,
	[AdTargetMatch3GK] [bigint] NULL,
	[GenericTargetMatch1GK] [bigint] NULL,
	[GenericTargetMatch2GK] [bigint] NULL,
	[GenericTargetMatch3GK] [bigint] NULL,
	[TrackerGK(Unified)] [bigint] NULL,
	[Tracker1GK] [bigint] NULL,
	[Tracker2GK] [bigint] NULL,
	[Tracker3GK] [bigint] NULL,
	[Segment1GK] [bigint] NULL,
	[Segment2GK] [bigint] NULL,
	[Segment3GK] [bigint] NULL,
	[Segment4GK] [bigint] NULL,
	[Segment5GK] [bigint] NULL,
	[Segment6GK] [bigint] NULL,
	[Segment7GK] [bigint] NULL,
	[Segment8GK] [bigint] NULL,
	[Segment9GK] [bigint] NULL,
	[Segment10GK] [bigint] NULL,
	[TargetPeriodStart] [datetime] NULL,
	[TargetPeriodEnd] [datetime] NULL,
	[Currency] [nvarchar](10) NULL,
	[OutputID] [char](32) NULL,
	[ClientSpecific1] [float] NULL,
	[ClientSpecific2] [float] NULL,
	[ClientSpecific3] [float] NULL,
	[ClientSpecific4] [float] NULL,
	[ClientSpecific5] [float] NULL,
	[ClientSpecific6] [float] NULL,
	[ClientSpecific7] [float] NULL,
	[ClientSpecific8] [float] NULL,
	[ClientSpecific9] [float] NULL,
	[ClientSpecific10] [float] NULL,
	[ClientSpecific11] [float] NULL,
	[ClientSpecific12] [float] NULL,
	[ClientSpecific13] [float] NULL,
	[ClientSpecific14] [float] NULL,
	[ClientSpecific15] [float] NULL,
	[ClientSpecific16] [float] NULL,
	[ClientSpecific17] [float] NULL,
	[ClientSpecific18] [float] NULL,
	[ClientSpecific19] [float] NULL,
	[ClientSpecific20] [float] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SocialChannel]    Script Date: 12/06/2012 16:29:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SocialChannel](
	[AccountID] [bigint] NULL,
	[ChannelID] [bigint] NULL,
	[AdGK] [bigint] NULL,
	[AdgroupGK] [bigint] NULL,
	[CampaignGK] [bigint] NULL,
	[AdCreative1GK] [bigint] NULL,
	[Creative1GK] [bigint] NULL,
	[AdCreative2GK] [bigint] NULL,
	[Creative2GK] [bigint] NULL,
	[AdCreative3GK] [bigint] NULL,
	[Creative3GK] [bigint] NULL,
	[AdTarget1GK] [bigint] NULL,
	[Target1GK] [bigint] NULL,
	[ADTarget2GK] [bigint] NULL,
	[Target2GK] [bigint] NULL,
	[ADTarget3GK] [bigint] NULL,
	[Target3GK] [bigint] NULL,
	[AdTargetMatch1GK] [bigint] NULL,
	[AdTargetMatch2GK] [bigint] NULL,
	[AdTargetMatch3GK] [bigint] NULL,
	[GenericTargetMatch1GK] [bigint] NULL,
	[GenericTargetMatch2GK] [bigint] NULL,
	[GenericTargetMatch3GK] [bigint] NULL,
	[AdTrackerGK(Unified)] [bigint] NULL,
	[AdTracker1GK] [bigint] NULL,
	[AdTracker2GK] [bigint] NULL,
	[AdTracker3GK] [bigint] NULL,
	[Segment1GK] [bigint] NULL,
	[Segment2GK] [bigint] NULL,
	[Segment3GK] [bigint] NULL,
	[Segment4GK] [bigint] NULL,
	[Segment5GK] [bigint] NULL,
	[Segment6GK] [bigint] NULL,
	[Segment7GK] [bigint] NULL,
	[Segment8GK] [bigint] NULL,
	[Segment9GK] [bigint] NULL,
	[Segment10GK] [bigint] NULL,
	[TargetPeriodStart] [datetime] NULL,
	[TargetPeriodEnd] [datetime] NULL,
	[Currency] [nvarchar](10) NULL,
	[OutputID] [char](32) NULL,
	[AveragePosition] [float] NULL,
	[Cost] [float] NULL,
	[Clicks] [int] NULL,
	[Impressions] [int] NULL,
	[SocialImpressions] [int] NULL,
	[SocialClicks] [int] NULL,
	[SocialCost] [float] NULL,
	[Actions] [int] NULL,
	[UniqueImpressions] [int] NULL,
	[SocialUniqueImpressions] [int] NULL,
	[UniqueClicks] [int] NULL,
	[SocialUniqueClicks] [int] NULL,
	[Connections] [int] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
