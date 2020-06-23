USE ReportServer  -- CHANGE THIS LINE FOR REPORT SERVER DATABASE NAME
GO
SELECT rs.ReportID
,rs.SubscriptionID
,ROUND(TRY_CAST(cat.ContentSize AS FLOAT)/1048576,3) ContentSizeMB -- !Important! This only works on Power BI Report Server
,SUBSTRING(cat.[Path],1,LEN(cat.[Path])-LEN(cat.[Name])) AS ReportFolder
,cat.[Name] AS ReportName
,sub.[Description] AS SubscriptionDescription
,sub.LastStatus
,sub.LastRunTime
,sub.EventType
,s.ScheduleID AS JobName
,'EXEC msdb.dbo.sp_start_job @job_name = ''' + CAST(s.ScheduleID AS VARCHAR(50)) + '''' AS RunSubscriptionManually
,s.StartDate
,s.EndDate
,CASE   WHEN s.RecurrenceType=1 THEN 'Once'  
	WHEN s.RecurrenceType=2 THEN 'Hourly'  
	WHEN s.RecurrenceType=3 THEN 'Daily'  
	WHEN s.RecurrenceType=4 AND s.WeeksInterval <= 1 THEN 'Daily'  
	WHEN s.RecurrenceType=4 AND s.WeeksInterval > 1 THEN 'Weekly'
        WHEN s.RecurrenceType=5 THEN 'Monthly (days)'  
        WHEN s.RecurrenceType=6 THEN 'Monthly (weeks)'  
END AS Recurrence
,s.MinutesInterval
,s.DaysInterval
,s.WeeksInterval
,s.DaysOfWeek
,s.DaysOfMonth
,s.[Month]
,s.MonthlyWeek
,ISNULL(Convert(XML,sub.[ExtensionSettings]).value('(//ParameterValue/Value[../Name="RenderFormat"])[1]','nvarchar(50)'),Convert(XML,sub.[ExtensionSettings]).value('(//ParameterValue/Value[../Name="RENDER_FORMAT"])[1]','nvarchar(50)')
) AS RenderFormat
,Convert(XML,sub.[ExtensionSettings]).value('(//ParameterValue/Value[../Name="Subject"])[1]','nvarchar(150)') AS [Subject]
,sub.[Parameters]
,cat.[Path]
,cat.CreationDate  AS ReportCreateDate
,cat.ModifiedDate AS ReportSettingsModified
,u.UserName
,sub.DataSettings AS DataDrivenSettings
,sub.ExtensionSettings
,sub.OwnerID AS SubscriptionOwnerID
FROM dbo.ReportSchedule rs WITH (NOLOCK)
INNER JOIN dbo.Schedule s WITH (NOLOCK) ON rs.ScheduleID = s.ScheduleID
INNER JOIN dbo.[Catalog] cat WITH (NOLOCK) ON rs.ReportID = cat.ItemID
INNER JOIN dbo.Subscriptions sub WITH (NOLOCK) ON rs.SubscriptionID = sub.SubscriptionID
INNER JOIN dbo.Users u WITH (NOLOCK) ON sub.OwnerID = u.UserID

--WHERE cat.Name like '%Report Name%'