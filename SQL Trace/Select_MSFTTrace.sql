    /** 1. Path/Folder containing the .XEL file. End with forward slash '\'  **/        
DECLARE 
@DIR NVARCHAR(255) = 'C:\ms\'
;
    /** 2. Create or clean previous temporary table  **/
DROP TABLE IF EXISTS #XEvent_MSFTTrace
;
    /** 3. Parse XML Data from .XEL to temporary table  **/
SELECT
/* == General Columns 
== */
    xe.value('(./@name)', 'varchar(255)') AS EventName,
    xe.value('(@timestamp)[1]', 'datetime2') AS [TimeStamp],
    xe.value('(data[@name="duration"]/value)[1]', 'int') as Duration,
    xe.value('(data[@name="row_count"]/value)[1]', 'bigint') as [RowCount],
    COALESCE(xe.value('(action[@name="database_name"]/value)[1]', 'nvarchar(128)'),xe.value('(data[@name="database_name"]/value)[1]', 'nvarchar(128)') ) as [Database],
    xe.value('(data[@name="statement"]/value)[1]', 'nvarchar(max)') as [Statment],
    xe.value('(action[@name="sql_text"]/value)[1]', 'nvarchar(max)') as [SQLText],
    xe.value('(action[@name="username"]/value)[1]', 'nvarchar(255)') as [UserName],
    xe.value('(action[@name="client_hostname"]/value)[1]', 'nvarchar(255)') as [ClientHostname],
    xe.value('(action[@name="client_app_name"]/value)[1]', 'nvarchar(1000)') as [ClientAPPName],
    xe.value('(action[@name="session_id"]/value)[1]', 'int') as [SessionID],

/* == SQL Performance
    xe.value('(data[@name="physical_reads"]/value)[1]', 'int') as PhysicalReads,
    xe.value('(data[@name="writes"]/value)[1]', 'int') as Writes,
    xe.value('(data[@name="spills"]/value)[1]', 'int') as Spills,
    xe.value('(data[@name="last_row_count"]/value)[1]', 'int') as LastRowCount,
    xe.value('(data[@name="line_number"]/value)[1]', 'int') as LineNumber,
    xe.value('(data[@name="offset"]/value)[1]', 'int') as Offset,
    xe.value('(data[@name="offset_end"]/value)[1]', 'int') as OffsetEnd,
== */
    xe.value('(data[@name="cpu_time"]/value)[1]', 'int') as CPU,

/* == Error_Reported
    xe.value('(/event/data[@name="category"]/text)[1]', 'nvarchar(max)') AS ErrorCategory,
    xe.value('(/event/data[@name="destination"]/text)[1]', 'nvarchar(max)') AS ErrorDestination,
    xe.value('(/event/data[@name="error_number"]/value)[1]', 'bigint') AS ErrorNumber,
    xe.value('(/event/data[@name="state"]/value)[1]', 'int') AS [State],
== */
    xe.value('(/event/data[@name="severity"]/value)[1]', 'bigint') AS ErrorSeverity,
    xe.value('(/event/data[@name="message"]/value)[1]', 'nvarchar(max)') AS ErrorMessage,

/* == Wait_Info
    xe.value('(/event/data[@name="opcode"]/text)[1]', 'varchar(50)') AS Opcode,
    xe.value('(/event/data[@name="wait_type"]/value)[1]', 'int') AS WaitTypeID,
    xe.value('(/event/data[@name="signal_duration"]/value)[1]', 'int') AS SignalDuration,
== */
xe.value('(/event/data[@name="wait_type"]/text)[1]', 'char(50)') AS WaitType,

/*== Blocked_Process
    xe.value('(/event/data[@name="blocked_process"]/value/blocked-process-report/blocked-process/process/@clientapp)[1]', 'varchar(max)') AS BlockedClient,
    xe.value('(/event/data[@name="blocked_process"]/value/blocked-process-report/blocked-process/process/@loginname)[1]', 'varchar(255)') AS BlockedLogin,
    xe.value('(/event/data[@name="blocked_process"]/value/blocked-process-report/blocked-process/process/inputbuf)[1]', 'varchar(max)') AS BlockedStatment,
    xe.value('(/event/data[@name="blocked_process"]/value/blocked-process-report/blocking-process/process/@clientapp)[1]', 'varchar(max)') AS BlockingClient,
    xe.value('(/event/data[@name="blocked_process"]/value/blocked-process-report/blocking-process/process/@loginname)[1]', 'varchar(255)') AS BlockingLogin,
    xe.value('(/event/data[@name="blocked_process"]/value/blocked-process-report/blocking-process/process/inputbuf)[1]', 'varchar(max)') AS BlockingStatment,
    xe.value('(/event/data[@name="resource_owner_type"]/text)[1]', 'varchar(10)') AS ResourceOwnerType,
    xe.value('(/event/data[@name="transaction_id"]/value)[1]', 'bigint') AS TransactionID,
== */
    xe.value('(/event/data[@name="lock_mode"]/text)[1]', 'sysname') AS LockMode,
    xe.value('(/event/data[@name="blocked_process"]/value/blocked-process-report/blocking-process/process/@spid)[1]', 'int') AS BlockingSID,
    xe.value('(/event/data[@name="blocked_process"]/value/blocked-process-report/blocked-process/process/@spid)[1]', 'int') AS BlockedSID,

/* == Attention (client disconnects/interrupts/timeouts)
== */
    xe.value('(data[@name="request_id"]/value)[1]', 'int') AS RequestID,

/* == Other Columns
    xe.value('(data[@name="result"]/text)[1]', 'varchar(256)') AS Result,
    xe.value('(data[@name="object_id"]/value)[1]', 'int') AS ObjectID,
    xe.value('(data[@name="object_type"]/value)[1]', 'varchar(256)') AS ObjectType,
== */
    xe.value('(data[@name="object_name"]/value)[1]', 'varchar(256)') AS ObjectName
INTO #XEvent_MSFTTrace
FROM (SELECT CAST(event_data AS XML) AS XMLData FROM sys.fn_xe_file_target_read_file(@DIR+'_MSFTTrace*.xel', NULL, NULL, NULL)) AS EventFile
CROSS APPLY XMLData.nodes('//event') n (xe)
/* == Filter By Event Name
WHERE xe.value('(./@name)', 'varchar(255)') = 'blocked_process_report'
   == Filter By Session ID
WHERE xe.value('(action[@name="session_id"]/value)[1]', 'int') = 64
*/

;
    /** 4. Select or Group whatever data  **/
SELECT EventName,COUNT(*) AS CountRows,
FORMAT(MIN([TimeStamp]),'MM/dd HH:mm:ss') AS FirstOccurance,
FORMAT(MAX([TimeStamp]),'MM/dd HH:mm:ss') AS LastOccurance
FROM #XEvent_MSFTTrace
GROUP BY EventName