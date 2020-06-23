SELECT
j.[Name] AS JobName
,cat.[Name] AS ReportName
,cat.[Path] AS ReportPath
,sub.[Description] AS SubscriptioName
,CASE j.[enabled] WHEN 1 THEN 'Enabled' ELSE 'Disabled' END AS JobStatus
,CASE sub.InactiveFlags When 0 THEN 'Enabled' ELSE 'Disabled' End AS SubscriptionStatus
,sub.LastStatus 
,sub.EventType
,sub.LastRunTime
,u.UserName AS ReportSubscriptionModifiedBy
,sub.ModifiedDate AS ReportSubscriptionModified
,cat.CreationDate AS ReportCreatedDate
,sl.[name] JobOwner
,j.[date_modified] AS JobModifed
FROM dbo.ReportSchedule rs WITH (NOLOCK)
INNER JOIN msdb.dbo.sysjobs j WITH (NOLOCK) ON CONVERT(SYSNAME,rs.ScheduleID) = j.[name] AND j.category_id = 100 --Category_id = Report Server
INNER JOIN dbo.ReportSchedule c WITH (NOLOCK) ON j.name = c.ScheduleID
INNER JOIN dbo.Subscriptions sub  WITH (NOLOCK) ON c.SubscriptionID = sub.SubscriptionID
INNER JOIN dbo.[Catalog] cat WITH (NOLOCK) ON sub.Report_OID = cat.ItemID
INNER JOIN dbo.Users u WITH(NOLOCK) ON sub.ModifiedByID = u.UserID
LEFT JOIN sys.server_principals sl WITH (NOLOCK) ON j.owner_sid = sl.[sid]

--WHERE cat.Name like '%Report Name%'