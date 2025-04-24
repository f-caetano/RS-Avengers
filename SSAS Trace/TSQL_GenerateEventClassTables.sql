USE [database]
GO
CREATE TABLE [dbo].[ProfilerEventClass](
	[EventClassId] [int] NOT NULL,
	[EventClassName] [nvarchar](50) NULL,
	[EventClassDescription] [nvarchar](500) NULL,
PRIMARY KEY CLUSTERED 
(
	[EventClassId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[ProfilerEventSubClass](
	[EventClassId] [int] NOT NULL,
	[EventSubClassId] [int] NOT NULL,
	[EventSubClassName] [nvarchar](50) NULL,
 CONSTRAINT [PK_ProfilerEventSubClass] PRIMARY KEY CLUSTERED 
(
	[EventClassId] ASC,
	[EventSubClassId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[trc](
	[RowNumber] [int] IDENTITY(0,1) NOT NULL,
	[EventClass] [int] NULL,
	[ActivityID] [nvarchar](128) NULL,
	[ApplicationContext] [nvarchar](128) NULL,
	[ApplicationName] [nvarchar](128) NULL,
	[ClientProcessID] [int] NULL,
	[ConnectionID] [int] NULL,
	[CurrentTime] [datetime] NULL,
	[DatabaseFriendlyName] [nvarchar](128) NULL,
	[DatabaseName] [nvarchar](128) NULL,
	[EventSubclass] [int] NULL,
	[Identity] [nvarchar](128) NULL,
	[NTCanonicalUserName] [nvarchar](128) NULL,
	[NTDomainName] [nvarchar](128) NULL,
	[NTUserName] [nvarchar](128) NULL,
	[RequestID] [nvarchar](128) NULL,
	[RequestParameters] [ntext] NULL,
	[RequestProperties] [ntext] NULL,
	[SPID] [int] NULL,
	[ServerName] [nvarchar](128) NULL,
	[SessionID] [nvarchar](128) NULL,
	[SessionType] [nvarchar](128) NULL,
	[StartTime] [datetime] NULL,
	[TextData] [ntext] NULL,
	[UserObjectID] [nvarchar](128) NULL,
	[CPUTime] [bigint] NULL,
	[Duration] [bigint] NULL,
	[EndTime] [datetime] NULL,
	[Error] [int] NULL,
	[ErrorType] [int] NULL,
	[IntegerData] [bigint] NULL,
	[Severity] [int] NULL,
	[Success] [int] NULL,
	[CalculationExpression] [ntext] NULL,
	[ClientHostName] [nvarchar](128) NULL,
	[JobID] [int] NULL,
	[ObjectID] [nvarchar](128) NULL,
	[ObjectName] [nvarchar](128) NULL,
	[ObjectPath] [nvarchar](128) NULL,
	[ObjectType] [int] NULL,
	[ObjectReference] [nvarchar](128) NULL,
	[ProgressTotal] [bigint] NULL,
	[BinaryData] [image] NULL,
	[FunctionName] [ntext] NULL,
PRIMARY KEY CLUSTERED 
(
	[RowNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE VIEW [dbo].[TRCAnalysis] AS
SELECT 
    subc.EventSubClassName,
    c.EventClassName,
    CASE 
        WHEN main.Duration IS NULL THEN NULL
        WHEN main.Duration >= 86400000 THEN NULL
        ELSE TRY_CONVERT(VARCHAR(8), DATEADD(MILLISECOND, main.Duration, '00:00:00'), 108)
    END AS Duration_HHMMSS,
    main.*
FROM [dbo].trc AS main
LEFT JOIN [dbo].[ProfilerEventSubClass] AS subc
    ON main.EventClass = subc.EventClassId 
    AND main.EventSubclass = subc.EventSubClassId
LEFT JOIN [support].[dbo].[ProfilerEventClass] AS c
    ON main.EventClass = c.EventClassId;
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (1, N'Audit Login', N'Collects all new connection events since the trace was started, such as when a client requests a connection to a server running an instance of SQL Server.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (2, N'Audit Logout', N'Collects all new disconnect events since the trace was started, such as when a client issues a disconnect command.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (4, N'Audit Server Starts And Stops', N'Records service shut down, start, and pause activities.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (5, N'Progress Report Begin', N'Progress report begin.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (6, N'Progress Report End', N'Progress report end.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (7, N'Progress Report Current', N'Progress report current.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (8, N'Progress Report Error', N'Progress report error.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (9, N'Query Begin', N'Query begin.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (10, N'Query End', N'Query end.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (11, N'Query Subcube', N'Query subcube, for Usage Based Optimization.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (12, N'Query Subcube Verbose', N'Query subcube with detailed information. This event may have a negative impact on performance when turned on.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (15, N'Command Begin', N'Command begin.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (16, N'Command End', N'Command end.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (17, N'Error', N'Server error.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (18, N'Audit Object Permission Event', N'Records object permission changes.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (19, N'Audit Admin Operations Event', N'Records server backup/restore/synchronize/attach/detach/imageload/imagesave.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (33, N'Server State Discover Begin', N'Start of Server State Discover.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (34, N'Server State Discover Data', N'Contents of the Server State Discover Response.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (35, N'Server State Discover End', N'End of Server State Discover.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (36, N'Discover Begin', N'Start of Discover Request.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (38, N'Discover End', N'End of Discover Request.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (39, N'Notification', N'Notification event.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (40, N'User Defined', N'User defined Event.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (41, N'Existing Connection', N'Existing user connection.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (42, N'Existing Session', N'Existing session.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (43, N'Session Initialize', N'Session Initialize.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (50, N'Deadlock', N'Metadata locks deadlock.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (51, N'Lock Timeout', N'Metadata lock timeout.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (52, N'Lock Acquired', N'The locks were acquired by the transaction')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (53, N'Lock Released', N'The locks were released by the transaction')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (54, N'Lock Waiting', N'The locks are held by another transaction and therefore this transaction is blocking until the locks are released')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (60, N'Get Data From Aggregation', N'Answer query by getting data from aggregation. This event may have a negative impact on performance when turned on.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (61, N'Get Data From Cache', N'Answer query by getting data from one of the caches. This event may have a negative impact on performance when turned on.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (70, N'Query Cube Begin', N'Query cube begin.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (71, N'Query Cube End', N'Query cube end.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (72, N'Calculate Non Empty Begin', N'Calculate non empty begin.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (73, N'Calculate Non Empty Current', N'Calculate non empty current.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (74, N'Calculate Non Empty End', N'Calculate non empty end.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (75, N'Serialize Results Begin', N'Serialize results begin.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (76, N'Serialize Results Current', N'Serialize results current.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (77, N'Serialize Results End', N'Serialize results end.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (78, N'Execute MDX Script Begin', N'Execute MDX script begin.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (79, N'Execute MDX Script Current', N'Execute MDX script current. Deprecated.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (80, N'Execute MDX Script End', N'Execute MDX script end.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (81, N'Query Dimension', N'Query dimension.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (82, N'VertiPaq SE Query Begin', N'VertiPaq SE Query')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (83, N'VertiPaq SE Query End', N'VertiPaq SE Query')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (84, N'Resource Usage', N'Reports reads, writes, cpu usage after end of commands and queries.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (85, N'VertiPaq SE Query Cache Match', N'VertiPaq SE Query Cache Use')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (86, N'VertiPaq SE Query Cache Miss', N'VertiPaq SE Query Cache Miss')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (90, N'File Load Begin', N'File Load Begin.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (91, N'File Load End', N'File Load End.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (92, N'File Save Begin', N'File Save Begin.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (93, N'File Save End', N'File Save End')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (94, N'PageOut Begin', N'PageOut Begin.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (95, N'PageOut End', N'PageOut End')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (96, N'PageIn Begin', N'PageIn Begin.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (97, N'PageIn End', N'PageIn End')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (98, N'DirectQuery Begin', N'DirectQuery Begin.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (99, N'DirectQuery End', N'DirectQuery End.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (110, N'Calculation Evaluation', N'Information about the evaluation of calculations. This event will have a negative impact on performance when turned on.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (111, N'Calculation Evaluation Detailed Information', N'Detailed information about the evaluation of calculations. This event will have a negative impact on performance when turned on.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (112, N'DAX Query Plan', N'DAX logical/physical plan tree for VertiPaq and DirectQuery modes.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (113, N'WLGroup CPU Throttling', N'Workload Group is throttled on CPU usage')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (114, N'WLGroup Exceeds Memory Limit', N'Workload group exceeds the memory limit')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (115, N'WLGroup Exceeds Processing Limit', N'Workload group exceeds the processing limit')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (120, N'DAX Extension Execution Begin', N'DAX extension function execution begin event.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (121, N'DAX Extension Execution End', N'DAX extension function execution end event.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (122, N'DAX Extension Trace Error', N'DAX extension function error trace event directly traced by extension authors.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (123, N'DAX Extension Trace Info', N'DAX extension function informational/telemetry trace event directly traced by extension authors.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (124, N'DAX Extension Trace Verbose', N'DAX extension function verbose trace event directly traced by extension authors.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (126, N'Execute MDX Script Error', N'An error occurred during MDX script execution.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (130, N'Execute Source Query', N'Collection of all queries that are executed against the data source')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (131, N'Aggregate Table Rewrite Query', N'A query was rewritten according to available aggregate tables.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (132, N'Aggregate Table Rewrite Info', N'Information about aggregation table matching.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (133, N'DAX Query Shape', N'Information about DAX query shape.')
GO
INSERT [dbo].[ProfilerEventClass] ([EventClassId], [EventClassName], [EventClassDescription]) VALUES (134, N'Job Graph', N'Job graph related events')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (4, 1, N'Instance Shutdown')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (4, 2, N'Instance Started')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (4, 3, N'Instance Paused')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (4, 4, N'Instance Continued')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 1, N'Process')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 2, N'Merge')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 3, N'Delete')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 4, N'DeleteOldAggregations')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 5, N'Rebuild')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 6, N'Commit')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 7, N'Rollback')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 8, N'CreateIndexes')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 9, N'CreateTable')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 10, N'InsertInto')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 11, N'Transaction')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 12, N'Initialize')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 13, N'Discretize')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 14, N'Query')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 15, N'CreateView')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 16, N'WriteData')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 17, N'ReadData')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 18, N'GroupData')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 19, N'GroupDataRecord')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 20, N'BuildIndex')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 21, N'Aggregate')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 22, N'BuildDecode')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 23, N'WriteDecode')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 24, N'BuildDMDecode')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 25, N'ExecuteSQL')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 26, N'ExecuteModifiedSQL')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 27, N'Connecting')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 28, N'BuildAggsAndIndexes')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 29, N'MergeAggsOnDisk')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 30, N'BuildIndexForRigidAggs')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 31, N'BuildIndexForFlexibleAggs')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 32, N'WriteAggsAndIndexes')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 33, N'WriteSegment')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 34, N'DataMiningProgress')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 35, N'ReadBufferFullReport')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 36, N'ProactiveCacheConversion')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 37, N'Backup')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 38, N'Restore')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 39, N'Synchronize')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 40, N'Build Processing Schedule')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 41, N'Detach')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 42, N'Attach')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 43, N'Analyze\Encode Data')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 44, N'Compress Segment')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 45, N'Write Table Column')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 46, N'Relationship Build Prepare')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 47, N'Build Relationship Segment')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 48, N'Load')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 49, N'Metadata Load')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 50, N'Data Load')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 51, N'Post Load')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 52, N'Metadata traversal during Backup')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 53, N'VertiPaq')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 54, N'Hierarchy processing')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 55, N'Switching dictionary')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 57, N'Tabular transaction commit')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 58, N'Sequence point')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 59, N'Tabular object processing')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 60, N'Saving database')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 61, N'Tokenization store processing')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 63, N'Check segment indexes')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 64, N'Check tabular data structure')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 65, N'Check column data for duplicates or null values')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (5, 66, N'Analyze refresh policy impact for tabular partitio')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 1, N'Process')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 2, N'Merge')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 3, N'Delete')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 4, N'DeleteOldAggregations')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 5, N'Rebuild')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 6, N'Commit')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 7, N'Rollback')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 8, N'CreateIndexes')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 9, N'CreateTable')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 10, N'InsertInto')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 11, N'Transaction')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 12, N'Initialize')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 13, N'Discretize')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 14, N'Query')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 15, N'CreateView')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 16, N'WriteData')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 17, N'ReadData')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 18, N'GroupData')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 19, N'GroupDataRecord')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 20, N'BuildIndex')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 21, N'Aggregate')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 22, N'BuildDecode')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 23, N'WriteDecode')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 24, N'BuildDMDecode')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 25, N'ExecuteSQL')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 26, N'ExecuteModifiedSQL')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 27, N'Connecting')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 28, N'BuildAggsAndIndexes')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 29, N'MergeAggsOnDisk')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 30, N'BuildIndexForRigidAggs')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 31, N'BuildIndexForFlexibleAggs')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 32, N'WriteAggsAndIndexes')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 33, N'WriteSegment')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 34, N'DataMiningProgress')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 35, N'ReadBufferFullReport')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 36, N'ProactiveCacheConversion')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 37, N'Backup')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 38, N'Restore')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 39, N'Synchronize')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 40, N'Build Processing Schedule')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 41, N'Detach')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 42, N'Attach')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 43, N'Analyze\Encode Data')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 44, N'Compress Segment')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 45, N'Write Table Column')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 46, N'Relationship Build Prepare')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 47, N'Build Relationship Segment')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 48, N'Load')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 49, N'Metadata Load')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 50, N'Data Load')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 51, N'Post Load')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 52, N'Metadata traversal during Backup')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 53, N'VertiPaq')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 54, N'Hierarchy processing')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 55, N'Switching dictionary')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 57, N'Tabular transaction commit')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 58, N'Sequence point')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 59, N'Tabular object processing')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 60, N'Saving database')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 61, N'Tokenization store processing')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 63, N'Check segment indexes')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 64, N'Check tabular data structure')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 65, N'Check column data for duplicates or null values')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (6, 66, N'Analyze refresh policy impact for tabular partitio')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 1, N'Process')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 2, N'Merge')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 3, N'Delete')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 4, N'DeleteOldAggregations')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 5, N'Rebuild')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 6, N'Commit')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 7, N'Rollback')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 8, N'CreateIndexes')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 9, N'CreateTable')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 10, N'InsertInto')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 11, N'Transaction')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 12, N'Initialize')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 13, N'Discretize')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 14, N'Query')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 15, N'CreateView')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 16, N'WriteData')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 17, N'ReadData')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 18, N'GroupData')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 19, N'GroupDataRecord')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 20, N'BuildIndex')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 21, N'Aggregate')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 22, N'BuildDecode')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 23, N'WriteDecode')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 24, N'BuildDMDecode')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 25, N'ExecuteSQL')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 26, N'ExecuteModifiedSQL')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 27, N'Connecting')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 28, N'BuildAggsAndIndexes')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 29, N'MergeAggsOnDisk')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 30, N'BuildIndexForRigidAggs')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 31, N'BuildIndexForFlexibleAggs')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 32, N'WriteAggsAndIndexes')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 33, N'WriteSegment')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 34, N'DataMiningProgress')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 35, N'ReadBufferFullReport')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 36, N'ProactiveCacheConversion')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 37, N'Backup')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 38, N'Restore')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 39, N'Synchronize')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 40, N'Build Processing Schedule')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 41, N'Detach')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 42, N'Attach')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 43, N'Analyze\Encode Data')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 44, N'Compress Segment')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 45, N'Write Table Column')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 46, N'Relationship Build Prepare')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 47, N'Build Relationship Segment')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 48, N'Load')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 49, N'Metadata Load')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 50, N'Data Load')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 51, N'Post Load')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 52, N'Metadata traversal during Backup')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 53, N'VertiPaq')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 54, N'Hierarchy processing')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 55, N'Switching dictionary')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 57, N'Tabular transaction commit')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 58, N'Sequence point')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 59, N'Tabular object processing')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 60, N'Saving database')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 61, N'Tokenization store processing')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 63, N'Check segment indexes')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 64, N'Check tabular data structure')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 65, N'Check column data for duplicates or null values')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (7, 66, N'Analyze refresh policy impact for tabular partitio')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 1, N'Process')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 2, N'Merge')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 3, N'Delete')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 4, N'DeleteOldAggregations')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 5, N'Rebuild')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 6, N'Commit')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 7, N'Rollback')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 8, N'CreateIndexes')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 9, N'CreateTable')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 10, N'InsertInto')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 11, N'Transaction')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 12, N'Initialize')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 13, N'Discretize')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 14, N'Query')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 15, N'CreateView')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 16, N'WriteData')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 17, N'ReadData')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 18, N'GroupData')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 19, N'GroupDataRecord')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 20, N'BuildIndex')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 21, N'Aggregate')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 22, N'BuildDecode')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 23, N'WriteDecode')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 24, N'BuildDMDecode')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 25, N'ExecuteSQL')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 26, N'ExecuteModifiedSQL')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 27, N'Connecting')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 28, N'BuildAggsAndIndexes')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 29, N'MergeAggsOnDisk')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 30, N'BuildIndexForRigidAggs')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 31, N'BuildIndexForFlexibleAggs')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 32, N'WriteAggsAndIndexes')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 33, N'WriteSegment')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 34, N'DataMiningProgress')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 35, N'ReadBufferFullReport')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 36, N'ProactiveCacheConversion')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 37, N'Backup')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 38, N'Restore')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 39, N'Synchronize')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 40, N'Build Processing Schedule')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 41, N'Detach')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 42, N'Attach')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 43, N'Analyze\Encode Data')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 44, N'Compress Segment')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 45, N'Write Table Column')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 46, N'Relationship Build Prepare')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 47, N'Build Relationship Segment')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 48, N'Load')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 49, N'Metadata Load')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 50, N'Data Load')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 51, N'Post Load')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 52, N'Metadata traversal during Backup')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 53, N'VertiPaq')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 54, N'Hierarchy processing')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 55, N'Switching dictionary')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 57, N'Tabular transaction commit')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 58, N'Sequence point')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 59, N'Tabular object processing')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 60, N'Saving database')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 61, N'Tokenization store processing')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 63, N'Check segment indexes')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 64, N'Check tabular data structure')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 65, N'Check column data for duplicates or null values')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (8, 66, N'Analyze refresh policy impact for tabular partitio')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (9, 0, N'MDXQuery')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (9, 1, N'DMXQuery')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (9, 2, N'SQLQuery')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (9, 3, N'DAXQuery')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (9, 4, N'JSON')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (10, 0, N'MDXQuery')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (10, 1, N'DMXQuery')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (10, 2, N'SQLQuery')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (10, 3, N'DAXQuery')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (10, 4, N'JSON')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (11, 1, N'Cache data')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (11, 2, N'Non-cache data')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (11, 3, N'Internal data')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (11, 4, N'SQL data')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (11, 11, N'Measure Group Structural Change')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (11, 12, N'Measure Group Deletion')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (12, 21, N'Cache data')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (12, 22, N'Non-cache data')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (12, 23, N'Internal data')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (12, 24, N'SQL data')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (15, 0, N'Create')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (15, 1, N'Alter')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (15, 2, N'Delete')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (15, 3, N'Process')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (15, 4, N'DesignAggregations')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (15, 5, N'WBInsert')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (15, 6, N'WBUpdate')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (15, 7, N'WBDelete')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (15, 8, N'Backup')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (15, 9, N'Restore')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (15, 10, N'MergePartitions')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (15, 11, N'Subscribe')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (15, 12, N'Batch')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (15, 13, N'BeginTransaction')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (15, 14, N'CommitTransaction')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (15, 15, N'RollbackTransaction')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (15, 16, N'GetTransactionState')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (15, 17, N'Cancel')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (15, 18, N'Synchronize')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (15, 19, N'Import80MiningModels')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (15, 20, N'Attach')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (15, 21, N'Detach')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (15, 22, N'SetAuthContext')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (15, 23, N'ImageLoad')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (15, 24, N'ImageSave')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (15, 25, N'CloneDatabase')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (15, 26, N'CreateTabular')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (15, 27, N'AlterTabular')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (15, 28, N'DeleteTabular')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (15, 29, N'ProcessTabular')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (15, 30, N'Interpret')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (15, 31, N'ExtAuth')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (15, 32, N'DBCC')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (15, 33, N'RenameTabular')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (15, 34, N'SequencePointTabular')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (15, 35, N'UpgradeTabular')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (15, 36, N'MergePartitionsTabular')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (15, 37, N'DisableDatabase')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (15, 38, N'Tabular JSON Command')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (15, 39, N'Evict')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (15, 40, N'CommitImport')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (15, 41, N'RemoveDiscontinuedFeatures')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (15, 10000, N'Other')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (16, 0, N'Create')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (16, 1, N'Alter')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (16, 2, N'Delete')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (16, 3, N'Process')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (16, 4, N'DesignAggregations')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (16, 5, N'WBInsert')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (16, 6, N'WBUpdate')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (16, 7, N'WBDelete')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (16, 8, N'Backup')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (16, 9, N'Restore')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (16, 10, N'MergePartitions')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (16, 11, N'Subscribe')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (16, 12, N'Batch')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (16, 13, N'BeginTransaction')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (16, 14, N'CommitTransaction')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (16, 15, N'RollbackTransaction')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (16, 16, N'GetTransactionState')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (16, 17, N'Cancel')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (16, 18, N'Synchronize')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (16, 19, N'Import80MiningModels')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (16, 20, N'Attach')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (16, 21, N'Detach')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (16, 22, N'SetAuthContext')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (16, 23, N'ImageLoad')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (16, 24, N'ImageSave')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (16, 25, N'CloneDatabase')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (16, 26, N'CreateTabular')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (16, 27, N'AlterTabular')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (16, 28, N'DeleteTabular')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (16, 29, N'ProcessTabular')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (16, 30, N'Interpret')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (16, 31, N'ExtAuth')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (16, 32, N'DBCC')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (16, 33, N'RenameTabular')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (16, 34, N'SequencePointTabular')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (16, 35, N'UpgradeTabular')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (16, 36, N'MergePartitionsTabular')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (16, 37, N'DisableDatabase')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (16, 38, N'Tabular JSON Command')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (16, 39, N'Evict')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (16, 40, N'CommitImport')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (16, 41, N'RemoveDiscontinuedFeatures')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (16, 10000, N'Other')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (19, 1, N'Backup')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (19, 2, N'Restore')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (19, 3, N'Synchronize')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (19, 4, N'Detach')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (19, 5, N'Attach')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (19, 6, N'ImageLoad')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (19, 7, N'ImageSave')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (33, 1, N'DISCOVER_CONNECTIONS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (33, 2, N'DISCOVER_SESSIONS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (33, 3, N'DISCOVER_TRANSACTIONS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (33, 6, N'DISCOVER_DB_CONNECTIONS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (33, 7, N'DISCOVER_JOBS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (33, 8, N'DISCOVER_LOCKS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (33, 12, N'DISCOVER_PERFORMANCE_COUNTERS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (33, 13, N'DISCOVER_MEMORYUSAGE')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (33, 14, N'DISCOVER_JOB_PROGRESS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (33, 15, N'DISCOVER_MEMORYGRANT')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (34, 1, N'DISCOVER_CONNECTIONS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (34, 2, N'DISCOVER_SESSIONS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (34, 3, N'DISCOVER_TRANSACTIONS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (34, 6, N'DISCOVER_DB_CONNECTIONS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (34, 7, N'DISCOVER_JOBS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (34, 8, N'DISCOVER_LOCKS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (34, 12, N'DISCOVER_PERFORMANCE_COUNTERS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (34, 13, N'DISCOVER_MEMORYUSAGE')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (34, 14, N'DISCOVER_JOB_PROGRESS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (34, 15, N'DISCOVER_MEMORYGRANT')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (34, 16, N'DISCOVER_COMMANDS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (34, 17, N'DISCOVER_COMMAND_OBJECTS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (34, 18, N'DISCOVER_OBJECT_ACTIVITY')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (34, 19, N'DISCOVER_OBJECT_MEMORY_USAGE')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (35, 1, N'DISCOVER_CONNECTIONS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (35, 2, N'DISCOVER_SESSIONS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (35, 3, N'DISCOVER_TRANSACTIONS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (35, 6, N'DISCOVER_DB_CONNECTIONS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (35, 7, N'DISCOVER_JOBS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (35, 8, N'DISCOVER_LOCKS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (35, 12, N'DISCOVER_PERFORMANCE_COUNTERS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (35, 13, N'DISCOVER_MEMORYUSAGE')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (35, 14, N'DISCOVER_JOB_PROGRESS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (35, 15, N'DISCOVER_MEMORYGRANT')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (35, 16, N'DISCOVER_COMMANDS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (35, 17, N'DISCOVER_COMMAND_OBJECTS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (35, 18, N'DISCOVER_OBJECT_ACTIVITY')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (35, 19, N'DISCOVER_OBJECT_MEMORY_USAGE')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 0, N'DBSCHEMA_CATALOGS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 1, N'DBSCHEMA_TABLES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 2, N'DBSCHEMA_COLUMNS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 3, N'DBSCHEMA_PROVIDER_TYPES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 4, N'MDSCHEMA_CUBES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 5, N'MDSCHEMA_DIMENSIONS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 6, N'MDSCHEMA_HIERARCHIES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 7, N'MDSCHEMA_LEVELS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 8, N'MDSCHEMA_MEASURES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 9, N'MDSCHEMA_PROPERTIES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 10, N'MDSCHEMA_MEMBERS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 11, N'MDSCHEMA_FUNCTIONS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 12, N'MDSCHEMA_ACTIONS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 13, N'MDSCHEMA_SETS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 14, N'DISCOVER_INSTANCES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 15, N'MDSCHEMA_KPIS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 16, N'MDSCHEMA_MEASUREGROUPS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 17, N'MDSCHEMA_COMMANDS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 18, N'DMSCHEMA_MINING_SERVICES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 19, N'DMSCHEMA_MINING_SERVICE_PARAMETERS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 20, N'DMSCHEMA_MINING_FUNCTIONS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 21, N'DMSCHEMA_MINING_MODEL_CONTENT')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 22, N'DMSCHEMA_MINING_MODEL_XML')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 23, N'DMSCHEMA_MINING_MODELS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 24, N'DMSCHEMA_MINING_COLUMNS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 25, N'DISCOVER_DATASOURCES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 26, N'DISCOVER_PROPERTIES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 27, N'DISCOVER_SCHEMA_ROWSETS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 28, N'DISCOVER_ENUMERATORS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 29, N'DISCOVER_KEYWORDS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 30, N'DISCOVER_LITERALS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 31, N'DISCOVER_XML_METADATA')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 32, N'DISCOVER_TRACES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 33, N'DISCOVER_TRACE_DEFINITION_PROVIDERINFO')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 34, N'DISCOVER_TRACE_COLUMNS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 35, N'DISCOVER_TRACE_EVENT_CATEGORIES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 36, N'DMSCHEMA_MINING_STRUCTURES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 37, N'DMSCHEMA_MINING_STRUCTURE_COLUMNS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 38, N'DISCOVER_MASTER_KEY')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 39, N'MDSCHEMA_INPUT_DATASOURCES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 40, N'DISCOVER_LOCATIONS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 41, N'DISCOVER_PARTITION_DIMENSION_STAT')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 42, N'DISCOVER_PARTITION_STAT')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 43, N'DISCOVER_DIMENSION_STAT')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 44, N'MDSCHEMA_MEASUREGROUP_DIMENSIONS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 45, N'DISCOVER_XEVENT_PACKAGES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 46, N'DISCOVER_XEVENT_OBJECTS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 47, N'DISCOVER_XEVENT_OBJECT_COLUMNS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 48, N'DISCOVER_XEVENT_SESSION_TARGETS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 49, N'DISCOVER_XEVENT_SESSIONS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 50, N'DISCOVER_STORAGE_TABLES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 51, N'DISCOVER_STORAGE_TABLE_COLUMNS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 52, N'DISCOVER_STORAGE_TABLE_COLUMN_SEGMENTS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 53, N'DISCOVER_CALC_DEPENDENCY')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 54, N'DISCOVER_CSDL_METADATA')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 55, N'DISCOVER_RESOURCE_POOLS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 56, N'TMSCHEMA_MODEL')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 57, N'TMSCHEMA_DATA_SOURCES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 58, N'TMSCHEMA_TABLES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 59, N'TMSCHEMA_COLUMNS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 60, N'TMSCHEMA_ATTRIBUTE_HIERARCHIES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 61, N'TMSCHEMA_PARTITIONS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 62, N'TMSCHEMA_RELATIONSHIPS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 63, N'TMSCHEMA_MEASURES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 64, N'TMSCHEMA_HIERARCHIES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 65, N'TMSCHEMA_LEVELS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 67, N'TMSCHEMA_TABLE_STORAGES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 68, N'TMSCHEMA_COLUMN_STORAGES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 69, N'TMSCHEMA_PARTITION_STORAGES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 70, N'TMSCHEMA_SEGMENT_MAP_STORAGES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 71, N'TMSCHEMA_DICTIONARY_STORAGES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 72, N'TMSCHEMA_COLUMN_PARTITION_STORAGES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 73, N'TMSCHEMA_RELATIONSHIP_STORAGES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 74, N'TMSCHEMA_RELATIONSHIP_INDEX_STORAGES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 75, N'TMSCHEMA_ATTRIBUTE_HIERARCHY_STORAGES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 76, N'TMSCHEMA_HIERARCHY_STORAGES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 77, N'DISCOVER_RING_BUFFERS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 78, N'TMSCHEMA_KPIS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 79, N'TMSCHEMA_STORAGE_FOLDERS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 80, N'TMSCHEMA_STORAGE_FILES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 81, N'TMSCHEMA_SEGMENT_STORAGES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 82, N'TMSCHEMA_CULTURES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 83, N'TMSCHEMA_OBJECT_TRANSLATIONS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 84, N'TMSCHEMA_LINGUISTIC_METADATA')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 85, N'TMSCHEMA_ANNOTATIONS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 86, N'TMSCHEMA_PERSPECTIVES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 87, N'TMSCHEMA_PERSPECTIVE_TABLES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 88, N'TMSCHEMA_PERSPECTIVE_COLUMNS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 89, N'TMSCHEMA_PERSPECTIVE_HIERARCHIES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 90, N'TMSCHEMA_PERSPECTIVE_MEASURES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 91, N'TMSCHEMA_ROLES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 92, N'TMSCHEMA_ROLE_MEMBERSHIPS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 93, N'TMSCHEMA_TABLE_PERMISSIONS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 94, N'TMSCHEMA_VARIATIONS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 95, N'TMSCHEMA_SETS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 96, N'TMSCHEMA_PERSPECTIVE_SETS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 97, N'TMSCHEMA_EXTENDED_PROPERTIES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 98, N'TMSCHEMA_EXPRESSIONS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 99, N'TMSCHEMA_COLUMN_PERMISSIONS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 100, N'TMSCHEMA_DETAIL_ROWS_DEFINITIONS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 101, N'TMSCHEMA_RELATED_COLUMN_DETAILS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 102, N'TMSCHEMA_GROUP_BY_COLUMNS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 103, N'TMSCHEMA_CALCULATION_GROUPS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 104, N'TMSCHEMA_CALCULATION_ITEMS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 105, N'TMSCHEMA_ALTERNATE_OF_DEFINITIONS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 106, N'TMSCHEMA_REFRESH_POLICIES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 107, N'DISCOVER_POWERBI_DATASOURCES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 108, N'TMSCHEMA_FORMAT_STRING_DEFINITIONS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 109, N'DISCOVER_M_EXPRESSIONS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 110, N'TMSCHEMA_POWERBI_ROLES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 111, N'TMSCHEMA_QUERY_GROUPS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 112, N'DISCOVER_DB_MEM_STATS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 113, N'DISCOVER_MEM_STATS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 114, N'TMSCHEMA_ANALYTICS_AIMETADATA')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 115, N'DISCOVER_OBJECT_COUNTERS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (36, 116, N'DISCOVER_MODEL_SECURITY')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 0, N'DBSCHEMA_CATALOGS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 1, N'DBSCHEMA_TABLES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 2, N'DBSCHEMA_COLUMNS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 3, N'DBSCHEMA_PROVIDER_TYPES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 4, N'MDSCHEMA_CUBES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 5, N'MDSCHEMA_DIMENSIONS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 6, N'MDSCHEMA_HIERARCHIES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 7, N'MDSCHEMA_LEVELS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 8, N'MDSCHEMA_MEASURES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 9, N'MDSCHEMA_PROPERTIES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 10, N'MDSCHEMA_MEMBERS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 11, N'MDSCHEMA_FUNCTIONS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 12, N'MDSCHEMA_ACTIONS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 13, N'MDSCHEMA_SETS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 14, N'DISCOVER_INSTANCES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 15, N'MDSCHEMA_KPIS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 16, N'MDSCHEMA_MEASUREGROUPS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 17, N'MDSCHEMA_COMMANDS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 18, N'DMSCHEMA_MINING_SERVICES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 19, N'DMSCHEMA_MINING_SERVICE_PARAMETERS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 20, N'DMSCHEMA_MINING_FUNCTIONS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 21, N'DMSCHEMA_MINING_MODEL_CONTENT')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 22, N'DMSCHEMA_MINING_MODEL_XML')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 23, N'DMSCHEMA_MINING_MODELS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 24, N'DMSCHEMA_MINING_COLUMNS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 25, N'DISCOVER_DATASOURCES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 26, N'DISCOVER_PROPERTIES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 27, N'DISCOVER_SCHEMA_ROWSETS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 28, N'DISCOVER_ENUMERATORS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 29, N'DISCOVER_KEYWORDS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 30, N'DISCOVER_LITERALS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 31, N'DISCOVER_XML_METADATA')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 32, N'DISCOVER_TRACES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 33, N'DISCOVER_TRACE_DEFINITION_PROVIDERINFO')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 34, N'DISCOVER_TRACE_COLUMNS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 35, N'DISCOVER_TRACE_EVENT_CATEGORIES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 36, N'DMSCHEMA_MINING_STRUCTURES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 37, N'DMSCHEMA_MINING_STRUCTURE_COLUMNS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 38, N'DISCOVER_MASTER_KEY')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 39, N'MDSCHEMA_INPUT_DATASOURCES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 40, N'DISCOVER_LOCATIONS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 41, N'DISCOVER_PARTITION_DIMENSION_STAT')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 42, N'DISCOVER_PARTITION_STAT')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 43, N'DISCOVER_DIMENSION_STAT')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 44, N'MDSCHEMA_MEASUREGROUP_DIMENSIONS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 45, N'DISCOVER_XEVENT_PACKAGES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 46, N'DISCOVER_XEVENT_OBJECTS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 47, N'DISCOVER_XEVENT_OBJECT_COLUMNS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 48, N'DISCOVER_XEVENT_SESSION_TARGETS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 49, N'DISCOVER_XEVENT_SESSIONS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 50, N'DISCOVER_STORAGE_TABLES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 51, N'DISCOVER_STORAGE_TABLE_COLUMNS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 52, N'DISCOVER_STORAGE_TABLE_COLUMN_SEGMENTS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 53, N'DISCOVER_CALC_DEPENDENCY')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 54, N'DISCOVER_CSDL_METADATA')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 55, N'DISCOVER_RESOURCE_POOLS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 56, N'TMSCHEMA_MODEL')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 57, N'TMSCHEMA_DATA_SOURCES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 58, N'TMSCHEMA_TABLES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 59, N'TMSCHEMA_COLUMNS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 60, N'TMSCHEMA_ATTRIBUTE_HIERARCHIES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 61, N'TMSCHEMA_PARTITIONS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 62, N'TMSCHEMA_RELATIONSHIPS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 63, N'TMSCHEMA_MEASURES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 64, N'TMSCHEMA_HIERARCHIES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 65, N'TMSCHEMA_LEVELS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 67, N'TMSCHEMA_TABLE_STORAGES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 68, N'TMSCHEMA_COLUMN_STORAGES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 69, N'TMSCHEMA_PARTITION_STORAGES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 70, N'TMSCHEMA_SEGMENT_MAP_STORAGES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 71, N'TMSCHEMA_DICTIONARY_STORAGES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 72, N'TMSCHEMA_COLUMN_PARTITION_STORAGES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 73, N'TMSCHEMA_RELATIONSHIP_STORAGES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 74, N'TMSCHEMA_RELATIONSHIP_INDEX_STORAGES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 75, N'TMSCHEMA_ATTRIBUTE_HIERARCHY_STORAGES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 76, N'TMSCHEMA_HIERARCHY_STORAGES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 77, N'DISCOVER_RING_BUFFERS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 78, N'TMSCHEMA_KPIS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 79, N'TMSCHEMA_STORAGE_FOLDERS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 80, N'TMSCHEMA_STORAGE_FILES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 81, N'TMSCHEMA_SEGMENT_STORAGES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 82, N'TMSCHEMA_CULTURES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 83, N'TMSCHEMA_OBJECT_TRANSLATIONS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 84, N'TMSCHEMA_LINGUISTIC_METADATA')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 85, N'TMSCHEMA_ANNOTATIONS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 86, N'TMSCHEMA_PERSPECTIVES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 87, N'TMSCHEMA_PERSPECTIVE_TABLES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 88, N'TMSCHEMA_PERSPECTIVE_COLUMNS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 89, N'TMSCHEMA_PERSPECTIVE_HIERARCHIES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 90, N'TMSCHEMA_PERSPECTIVE_MEASURES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 91, N'TMSCHEMA_ROLES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 92, N'TMSCHEMA_ROLE_MEMBERSHIPS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 93, N'TMSCHEMA_TABLE_PERMISSIONS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 94, N'TMSCHEMA_VARIATIONS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 95, N'TMSCHEMA_SETS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 96, N'TMSCHEMA_PERSPECTIVE_SETS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 97, N'TMSCHEMA_EXTENDED_PROPERTIES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 98, N'TMSCHEMA_EXPRESSIONS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 99, N'TMSCHEMA_COLUMN_PERMISSIONS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 100, N'TMSCHEMA_DETAIL_ROWS_DEFINITIONS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 101, N'TMSCHEMA_RELATED_COLUMN_DETAILS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 102, N'TMSCHEMA_GROUP_BY_COLUMNS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 103, N'TMSCHEMA_CALCULATION_GROUPS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 104, N'TMSCHEMA_CALCULATION_ITEMS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 105, N'TMSCHEMA_ALTERNATE_OF_DEFINITIONS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 106, N'TMSCHEMA_REFRESH_POLICIES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 107, N'DISCOVER_POWERBI_DATASOURCES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 108, N'TMSCHEMA_FORMAT_STRING_DEFINITIONS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 109, N'DISCOVER_M_EXPRESSIONS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 110, N'TMSCHEMA_POWERBI_ROLES')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 111, N'TMSCHEMA_QUERY_GROUPS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 112, N'DISCOVER_DB_MEM_STATS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 113, N'DISCOVER_MEM_STATS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 114, N'TMSCHEMA_ANALYTICS_AIMETADATA')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 115, N'DISCOVER_OBJECT_COUNTERS')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (38, 116, N'DISCOVER_MODEL_SECURITY')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (39, 0, N'Proactive Caching Begin')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (39, 1, N'Proactive Caching End')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (39, 2, N'Flight Recorder Started')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (39, 3, N'Flight Recorder Stopped')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (39, 4, N'Configuration Properties Updated')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (39, 5, N'SQL Trace')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (39, 6, N'Object Created')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (39, 7, N'Object Deleted')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (39, 8, N'Object Altered')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (39, 9, N'Proactive Caching Polling Begin')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (39, 10, N'Proactive Caching Polling End')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (39, 11, N'Flight Recorder Snapshot Begin')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (39, 12, N'Flight Recorder Snapshot End')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (39, 13, N'Proactive Caching: notifiable object updated')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (39, 14, N'Lazy Processing: start processing')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (39, 15, N'Lazy Processing: processing complete')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (39, 16, N'SessionOpened Event Begin')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (39, 17, N'SessionOpened Event End')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (39, 18, N'SessionClosing Event Begin')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (39, 19, N'SessionClosing Event End')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (39, 20, N'CubeOpened Event Begin')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (39, 21, N'CubeOpened Event End')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (39, 22, N'CubeClosing Event Begin')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (39, 23, N'CubeClosing Event End')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (39, 24, N'Transaction abort requested')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (39, 25, N'Opened data source connection')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (61, 1, N'Get data from measure group cache')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (61, 2, N'Get data from flat cache')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (61, 3, N'Get data from calculation cache')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (61, 4, N'Get data from persisted cache')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (73, 1, N'Get Data')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (73, 2, N'Process Calculated Members')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (73, 3, N'Post Order')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (76, 1, N'Serialize Axes')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (76, 2, N'Serialize Cells')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (76, 3, N'Serialize SQL Rowset')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (76, 4, N'Serialize Flattened Rowset')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (78, 1, N'MDX Script')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (78, 2, N'MDX Script Command')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (80, 1, N'MDX Script')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (80, 2, N'MDX Script Command')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (81, 1, N'Cache data')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (81, 2, N'Non-cache data')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (82, 0, N'VertiPaq Scan')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (82, 1, N'Tabular Query')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (82, 2, N'User Hierarchy Processing Query')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (82, 5, N'Batch VertiPaq Scan')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (82, 10, N'Internal VertiPaq Scan')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (82, 11, N'Internal Tabular Query')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (82, 12, N'User Hierarchy Processing Query Internal')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (82, 20, N'Query Plan VertiPaq Scan')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (82, 30, N'Local VertiPaq Scan')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (82, 40, N'Remote VertiPaq Scan')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (82, 50, N'VertiPaq Cache Probe')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (83, 0, N'VertiPaq Scan')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (83, 1, N'Tabular Query')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (83, 2, N'User Hierarchy Processing Query')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (83, 5, N'Batch VertiPaq Scan')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (83, 10, N'Internal VertiPaq Scan')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (83, 11, N'Internal Tabular Query')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (83, 12, N'User Hierarchy Processing Query Internal')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (83, 20, N'Query Plan VertiPaq Scan')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (83, 30, N'Local VertiPaq Scan')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (83, 40, N'Remote VertiPaq Scan')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (83, 50, N'VertiPaq Cache Probe')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (85, 0, N'VertiPaq Cache Exact Match')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (86, 0, N'VertiPaq Cache Not Found')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (110, 1, N'InitEvalNode Start')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (110, 2, N'InitEvalNode End')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (110, 3, N'BuildEvalNode Start')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (110, 4, N'BuildEvalNode End')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (110, 5, N'PrepareEvalNode Start')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (110, 6, N'PrepareEvalNode End')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (110, 7, N'RunEvalNode Start')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (110, 8, N'RunEvalNode End')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (111, 100, N'BuildEvalNode Eliminated Empty Calculations')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (111, 101, N'BuildEvalNode Subtracted Calculation Spaces')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (111, 102, N'BuildEvalNode Applied Visual Totals')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (111, 103, N'BuildEvalNode Detected Cached Evaluation Node')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (111, 104, N'BuildEvalNode Detected Cached Evaluation Results')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (111, 105, N'PrepareEvalNode Begin Prepare Evaluation Item')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (111, 106, N'PrepareEvalNode Finished Prepare Evaluation Item')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (111, 107, N'RunEvalNode Finished Calculating Item')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (112, 1, N'DAX VertiPaq Logical Plan')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (112, 2, N'DAX VertiPaq Physical Plan')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (112, 3, N'DAX DirectQuery Algebrizer Tree')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (112, 4, N'DAX DirectQuery Logical Plan')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (126, 1, N'MDX Script')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (126, 2, N'MDX Script Command')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (131, 1, N'Rewrite Attempted')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (134, 1, N'Graph Created')
GO
INSERT [dbo].[ProfilerEventSubClass] ([EventClassId], [EventSubClassId], [EventSubClassName]) VALUES (134, 2, N'Graph Finished')
GO
