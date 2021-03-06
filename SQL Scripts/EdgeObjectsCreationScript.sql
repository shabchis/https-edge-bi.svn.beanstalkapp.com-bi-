USE [EdgeObjects]
GO
/****** Object:  Table [dbo].[Account]    Script Date: 12/06/2012 16:31:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Account](
	[ID] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[ParentAccountID] [int] NULL,
 CONSTRAINT [PK_Account] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Ad]    Script Date: 12/06/2012 16:31:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Ad](
	[GK] [bigint] NOT NULL,
	[Name] [nvarchar](50) NULL,
	[OriginalID] [nvarchar](50) NULL,
	[AccountID] [int] NOT NULL,
	[ChannelID] [int] NOT NULL,
	[ObjectStatus] [int] NOT NULL,
	[DestinationUrl] [nvarchar](50) NULL,
 CONSTRAINT [PK_Ad] PRIMARY KEY CLUSTERED 
(
	[GK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AdCreative]    Script Date: 12/06/2012 16:31:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AdCreative](
	[GK] [bigint] NOT NULL,
	[AccountID] [int] NOT NULL,
	[ChannelID] [int] NOT NULL,
	[OriginalID] [nvarchar](50) NULL,
	[Name] [nvarchar](50) NULL,
	[Status] [int] NOT NULL,
	[AdGK] [bigint] NOT NULL,
	[CreativeGK] [bigint] NOT NULL,
 CONSTRAINT [PK_AdCreative] PRIMARY KEY CLUSTERED 
(
	[GK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AdTarget]    Script Date: 12/06/2012 16:31:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AdTarget](
	[GK] [bigint] NOT NULL,
	[AccountID] [int] NOT NULL,
	[ChannelID] [int] NOT NULL,
	[OriginalID] [nvarchar](50) NULL,
	[Name] [nvarchar](50) NULL,
	[Status] [int] NOT NULL,
	[AdGK] [bigint] NOT NULL,
	[TargetGK] [bigint] NOT NULL,
 CONSTRAINT [PK_AdTarget] PRIMARY KEY CLUSTERED 
(
	[GK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AdTargetMatch]    Script Date: 12/06/2012 16:31:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AdTargetMatch](
	[GK] [bigint] NOT NULL,
	[AdGK] [bigint] NOT NULL,
	[AdTargetGK] [bigint] NULL,
	[ObjectType] [nvarchar](50) NOT NULL,
	[AccountID] [int] NOT NULL,
	[OriginalID] [nvarchar](50) NULL,
	[Name] [nvarchar](50) NULL,
	[Status] [int] NOT NULL,
	[DestinationUrl] [nvarchar](50) NULL,
	[int_Field1] [int] NULL,
	[int_Field2] [int] NULL,
	[int_Field3] [int] NULL,
	[int_Field4] [int] NULL,
	[string_Field1] [nvarchar](100) NULL,
	[string_Field2] [nvarchar](100) NULL,
	[string_Field3] [nvarchar](100) NULL,
	[string_Field4] [nvarchar](100) NULL,
 CONSTRAINT [PK_AdTargetMatch] PRIMARY KEY CLUSTERED 
(
	[GK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Channel]    Script Date: 12/06/2012 16:31:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Channel](
	[ID] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[ChannelType] [int] NULL,
 CONSTRAINT [PK_Channel] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Creative]    Script Date: 12/06/2012 16:31:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Creative](
	[GK] [bigint] NOT NULL,
	[ObjectType] [nvarchar](50) NOT NULL,
	[AccountID] [int] NOT NULL,
	[OriginalID] [nvarchar](50) NULL,
	[Name] [nvarchar](50) NULL,
	[Status] [int] NOT NULL,
	[int_Field1] [int] NULL,
	[int_Field2] [int] NULL,
	[int_Field3] [int] NULL,
	[int_Field4] [int] NULL,
	[string_Field1] [nvarchar](100) NULL,
	[string_Field2] [nvarchar](100) NULL,
	[string_Field3] [nvarchar](100) NULL,
	[string_Field4] [nvarchar](100) NULL,
 CONSTRAINT [PK_Creative_1] PRIMARY KEY CLUSTERED 
(
	[GK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[GenericTargetMatch]    Script Date: 12/06/2012 16:31:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GenericTargetMatch](
	[GK] [bigint] NOT NULL,
	[ObjectType] [nvarchar](50) NOT NULL,
	[AccountID] [int] NOT NULL,
	[OriginalID] [nvarchar](50) NULL,
	[Name] [nvarchar](50) NULL,
	[Status] [int] NOT NULL,
	[DestinationUrl] [nvarchar](50) NULL,
	[int_Field1] [int] NULL,
	[int_Field2] [int] NULL,
	[int_Field3] [int] NULL,
	[int_Field4] [int] NULL,
	[string_Field1] [nvarchar](100) NULL,
	[string_Field2] [nvarchar](100) NULL,
	[string_Field3] [nvarchar](100) NULL,
	[string_Field4] [nvarchar](100) NULL,
 CONSTRAINT [PK_GenericTargetMatch] PRIMARY KEY CLUSTERED 
(
	[GK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[MetaData]    Script Date: 12/06/2012 16:31:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MetaData](
	[ParentType] [nvarchar](50) NOT NULL,
	[ParentGK] [bigint] NOT NULL,
	[MetaPropertyID] [int] NOT NULL,
	[MetaValue] [nvarchar](max) NULL,
	[MetaValueType] [nvarchar](50) NOT NULL,
	[MetaValueGK] [bigint] NULL,
 CONSTRAINT [PK_MetaData] PRIMARY KEY CLUSTERED 
(
	[ParentType] ASC,
	[ParentGK] ASC,
	[MetaPropertyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[MetaProperty]    Script Date: 12/06/2012 16:31:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MetaProperty](
	[ID] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[AccountID] [int] NULL,
	[ChannelID] [int] NULL,
	[PropertyType] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_MetaProperty] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[NonChannelObject]    Script Date: 12/06/2012 16:31:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NonChannelObject](
	[GK] [bigint] NOT NULL,
	[ObjectType] [nvarchar](50) NOT NULL,
	[AccountID] [int] NOT NULL,
	[OriginalID] [nvarchar](50) NULL,
	[Name] [nvarchar](50) NULL,
	[Status] [int] NOT NULL,
	[int_Field1] [int] NULL,
	[int_Field2] [int] NULL,
	[int_Field3] [int] NULL,
	[int_Field4] [int] NULL,
	[string_Field1] [nvarchar](100) NULL,
	[string_Field2] [nvarchar](100) NULL,
	[string_Field3] [nvarchar](100) NULL,
	[string_Field4] [nvarchar](100) NULL,
 CONSTRAINT [PK_NonChannelObject] PRIMARY KEY CLUSTERED 
(
	[GK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[SegmentObject]    Script Date: 12/06/2012 16:31:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SegmentObject](
	[GK] [bigint] NOT NULL,
	[ObjectType] [nvarchar](50) NOT NULL,
	[AccountID] [int] NOT NULL,
	[ChannelID] [int] NULL,
	[OriginalID] [nvarchar](50) NULL,
	[Name] [nvarchar](50) NULL,
	[Status] [int] NOT NULL,
	[int_Field1] [int] NULL,
	[int_Field2] [int] NULL,
	[int_Field3] [int] NULL,
	[int_Field4] [int] NULL,
	[string_Field1] [nvarchar](100) NULL,
	[string_Field2] [nvarchar](100) NULL,
	[string_Field3] [nvarchar](100) NULL,
	[string_Field4] [nvarchar](100) NULL,
 CONSTRAINT [PK_ChannelObject_1] PRIMARY KEY CLUSTERED 
(
	[GK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Target]    Script Date: 12/06/2012 16:31:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Target](
	[GK] [bigint] IDENTITY(1,1) NOT NULL,
	[ObjectType] [nvarchar](50) NOT NULL,
	[AccountID] [int] NOT NULL,
	[OriginalID] [nvarchar](50) NULL,
	[Name] [nvarchar](50) NULL,
	[Status] [int] NOT NULL,
	[DestinationUrl] [nvarchar](50) NULL,
	[int_Field1] [int] NULL,
	[int_Field2] [int] NULL,
	[int_Field3] [int] NULL,
	[int_Field4] [int] NULL,
	[string_Field1] [nvarchar](100) NULL,
	[string_Field2] [nvarchar](100) NULL,
	[string_Field3] [nvarchar](100) NULL,
	[string_Field4] [nvarchar](100) NULL,
 CONSTRAINT [PK_Target_1] PRIMARY KEY CLUSTERED 
(
	[GK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[Account]  WITH CHECK ADD  CONSTRAINT [FK_Account_Account] FOREIGN KEY([ParentAccountID])
REFERENCES [dbo].[Account] ([ID])
GO
ALTER TABLE [dbo].[Account] CHECK CONSTRAINT [FK_Account_Account]
GO
ALTER TABLE [dbo].[Ad]  WITH CHECK ADD  CONSTRAINT [FK_Ad_Account] FOREIGN KEY([AccountID])
REFERENCES [dbo].[Account] ([ID])
GO
ALTER TABLE [dbo].[Ad] CHECK CONSTRAINT [FK_Ad_Account]
GO
ALTER TABLE [dbo].[Ad]  WITH NOCHECK ADD  CONSTRAINT [FK_Ad_Channel] FOREIGN KEY([ChannelID])
REFERENCES [dbo].[Channel] ([ID])
GO
ALTER TABLE [dbo].[Ad] NOCHECK CONSTRAINT [FK_Ad_Channel]
GO
ALTER TABLE [dbo].[AdCreative]  WITH CHECK ADD  CONSTRAINT [FK_AdCreative_Account] FOREIGN KEY([AccountID])
REFERENCES [dbo].[Account] ([ID])
GO
ALTER TABLE [dbo].[AdCreative] CHECK CONSTRAINT [FK_AdCreative_Account]
GO
ALTER TABLE [dbo].[AdCreative]  WITH CHECK ADD  CONSTRAINT [FK_AdCreative_Ad] FOREIGN KEY([AdGK])
REFERENCES [dbo].[Ad] ([GK])
GO
ALTER TABLE [dbo].[AdCreative] CHECK CONSTRAINT [FK_AdCreative_Ad]
GO
ALTER TABLE [dbo].[AdCreative]  WITH NOCHECK ADD  CONSTRAINT [FK_AdCreative_Channel] FOREIGN KEY([ChannelID])
REFERENCES [dbo].[Channel] ([ID])
GO
ALTER TABLE [dbo].[AdCreative] NOCHECK CONSTRAINT [FK_AdCreative_Channel]
GO
ALTER TABLE [dbo].[AdCreative]  WITH CHECK ADD  CONSTRAINT [FK_AdCreative_Creative] FOREIGN KEY([CreativeGK])
REFERENCES [dbo].[Creative] ([GK])
GO
ALTER TABLE [dbo].[AdCreative] CHECK CONSTRAINT [FK_AdCreative_Creative]
GO
ALTER TABLE [dbo].[AdTarget]  WITH CHECK ADD  CONSTRAINT [FK_AdTarget_Account] FOREIGN KEY([AccountID])
REFERENCES [dbo].[Account] ([ID])
GO
ALTER TABLE [dbo].[AdTarget] CHECK CONSTRAINT [FK_AdTarget_Account]
GO
ALTER TABLE [dbo].[AdTarget]  WITH CHECK ADD  CONSTRAINT [FK_AdTarget_Ad] FOREIGN KEY([AdGK])
REFERENCES [dbo].[Ad] ([GK])
GO
ALTER TABLE [dbo].[AdTarget] CHECK CONSTRAINT [FK_AdTarget_Ad]
GO
ALTER TABLE [dbo].[AdTarget]  WITH NOCHECK ADD  CONSTRAINT [FK_AdTarget_Channel] FOREIGN KEY([ChannelID])
REFERENCES [dbo].[Channel] ([ID])
GO
ALTER TABLE [dbo].[AdTarget] NOCHECK CONSTRAINT [FK_AdTarget_Channel]
GO
ALTER TABLE [dbo].[AdTarget]  WITH NOCHECK ADD  CONSTRAINT [FK_AdTarget_Target] FOREIGN KEY([TargetGK])
REFERENCES [dbo].[Target] ([GK])
GO
ALTER TABLE [dbo].[AdTarget] NOCHECK CONSTRAINT [FK_AdTarget_Target]
GO
ALTER TABLE [dbo].[AdTargetMatch]  WITH NOCHECK ADD  CONSTRAINT [FK_AdTargetMatch_Ad] FOREIGN KEY([AdGK])
REFERENCES [dbo].[Ad] ([GK])
GO
ALTER TABLE [dbo].[AdTargetMatch] NOCHECK CONSTRAINT [FK_AdTargetMatch_Ad]
GO
ALTER TABLE [dbo].[AdTargetMatch]  WITH NOCHECK ADD  CONSTRAINT [FK_AdTargetMatch_AdTarget] FOREIGN KEY([AdTargetGK])
REFERENCES [dbo].[AdTarget] ([GK])
GO
ALTER TABLE [dbo].[AdTargetMatch] NOCHECK CONSTRAINT [FK_AdTargetMatch_AdTarget]
GO
ALTER TABLE [dbo].[Creative]  WITH NOCHECK ADD  CONSTRAINT [FK_Creative_Account] FOREIGN KEY([AccountID])
REFERENCES [dbo].[Account] ([ID])
GO
ALTER TABLE [dbo].[Creative] NOCHECK CONSTRAINT [FK_Creative_Account]
GO
ALTER TABLE [dbo].[GenericTargetMatch]  WITH NOCHECK ADD  CONSTRAINT [FK_GenericTargetMatch_Account] FOREIGN KEY([AccountID])
REFERENCES [dbo].[Account] ([ID])
GO
ALTER TABLE [dbo].[GenericTargetMatch] NOCHECK CONSTRAINT [FK_GenericTargetMatch_Account]
GO
ALTER TABLE [dbo].[MetaData]  WITH NOCHECK ADD  CONSTRAINT [FK_MetaData_MetaProperty] FOREIGN KEY([MetaPropertyID])
REFERENCES [dbo].[MetaProperty] ([ID])
GO
ALTER TABLE [dbo].[MetaData] NOCHECK CONSTRAINT [FK_MetaData_MetaProperty]
GO
ALTER TABLE [dbo].[MetaProperty]  WITH NOCHECK ADD  CONSTRAINT [FK_MetaProperty_Channel] FOREIGN KEY([ChannelID])
REFERENCES [dbo].[Channel] ([ID])
GO
ALTER TABLE [dbo].[MetaProperty] NOCHECK CONSTRAINT [FK_MetaProperty_Channel]
GO
ALTER TABLE [dbo].[SegmentObject]  WITH NOCHECK ADD  CONSTRAINT [FK_SegmentObject_Channel] FOREIGN KEY([ChannelID])
REFERENCES [dbo].[Channel] ([ID])
GO
ALTER TABLE [dbo].[SegmentObject] NOCHECK CONSTRAINT [FK_SegmentObject_Channel]
GO
ALTER TABLE [dbo].[SegmentObject]  WITH NOCHECK ADD  CONSTRAINT [FK_SegmentObject_Channel1] FOREIGN KEY([ChannelID])
REFERENCES [dbo].[Channel] ([ID])
GO
ALTER TABLE [dbo].[SegmentObject] NOCHECK CONSTRAINT [FK_SegmentObject_Channel1]
GO
ALTER TABLE [dbo].[Target]  WITH CHECK ADD  CONSTRAINT [FK_Target_Account] FOREIGN KEY([AccountID])
REFERENCES [dbo].[Account] ([ID])
GO
ALTER TABLE [dbo].[Target] CHECK CONSTRAINT [FK_Target_Account]
GO
