CREATE TABLE [dbo].[event] (
	[id] [int] IDENTITY (1, 1) NOT NULL ,
	[name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[description] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[date_started] [smalldatetime] NOT NULL ,
	[date_ended] [smalldatetime] NULL ,
	[time_started] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[time_ended] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[is_all_day] [tinyint] NOT NULL ,
	[repeat_type] [tinyint] NOT NULL ,
	[color] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[date_updated] [smalldatetime] NOT NULL ,
	[date_created] [smalldatetime] NOT NULL 
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

CREATE TABLE [dbo].[event_exception] (
	[date] [smalldatetime] NOT NULL ,
	[event_id] [int] NOT NULL 
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[event] WITH NOCHECK ADD 
	CONSTRAINT [PK_event] PRIMARY KEY  CLUSTERED 
	(
		[id]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[event] WITH NOCHECK ADD 
	CONSTRAINT [DF_event_name] DEFAULT ('') FOR [name],
	CONSTRAINT [DF_event_description] DEFAULT ('') FOR [description],
	CONSTRAINT [DF_event_date_started] DEFAULT (getdate()) FOR [date_started],
	CONSTRAINT [DF_event_date_ended] DEFAULT (null) FOR [date_ended],
	CONSTRAINT [DF_event_time_started] DEFAULT ('00:00') FOR [time_started],
	CONSTRAINT [DF_event_time_ended] DEFAULT ('00:00') FOR [time_ended],
	CONSTRAINT [DF_event_is_all_day] DEFAULT (0) FOR [is_all_day],
	CONSTRAINT [DF_event_repeat_type] DEFAULT (0) FOR [repeat_type],
	CONSTRAINT [DF_event_color] DEFAULT ('') FOR [color],
	CONSTRAINT [DF_event_date_updated] DEFAULT (getdate()) FOR [date_updated],
	CONSTRAINT [DF_event_date_created] DEFAULT (getdate()) FOR [date_created]
GO

ALTER TABLE [dbo].[event_exception] WITH NOCHECK ADD 
	CONSTRAINT [DF_event_exception_date] DEFAULT (getdate()) FOR [date],
	CONSTRAINT [DF_event_exception_event_id] DEFAULT (0) FOR [event_id]
GO

 CREATE  INDEX [IX_event_date_started] ON [dbo].[event]([date_started]) WITH  FILLFACTOR = 80 ON [PRIMARY]
GO

 CREATE  INDEX [IX_event_date_ended] ON [dbo].[event]([date_ended]) WITH  FILLFACTOR = 80 ON [PRIMARY]
GO

 CREATE  INDEX [IX_event_exception_date] ON [dbo].[event_exception]([date]) WITH  FILLFACTOR = 80 ON [PRIMARY]
GO

 CREATE  INDEX [IX_event_exception_event_id] ON [dbo].[event_exception]([event_id]) WITH  FILLFACTOR = 80 ON [PRIMARY]
GO

