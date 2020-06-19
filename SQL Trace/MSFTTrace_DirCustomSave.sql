/*=================== README ======================================================================
Running the entire script will start the trace. SysAdmin permission on the SQL Server is required
Adjust the step 2 to an existing directory on the client/SSMS where code is executed
STEP 5:  Code is comment with "--" and the T-SQL needs to be executed manually to end the trace
===================================================================================================*/

USE master;
GO
/** 1. Cleanup **/ 
IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='_MSFTTrace')  
    DROP EVENT SESSION [_MSFTTrace] ON SERVER;  
GO
/** 2. Directory needs to exists and ending with backslash '\' **/
DECLARE 
@DIR NVARCHAR(255) = 'C:\ms\',
@sql NVARCHAR(MAX);
 
/** 3. Create the Extended Events Trace **/
SET @sql = '
CREATE EVENT SESSION [_MSFTTrace] ON SERVER 
ADD EVENT sqlos.wait_info(
    ACTION(sqlserver.database_name,sqlserver.session_id,sqlserver.sql_text)
    WHERE ([opcode]=(1) AND [duration]>(1000))),
ADD EVENT sqlserver.attention(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.session_id,sqlserver.sql_text,sqlserver.username)
    WHERE ([sqlserver].[is_system]=(0))),
ADD EVENT sqlserver.blocked_process_report(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.session_id,sqlserver.sql_text,sqlserver.username)),
ADD EVENT sqlserver.error_reported(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.session_id,sqlserver.sql_text,sqlserver.username)),
ADD EVENT sqlserver.rpc_completed(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.session_id,sqlserver.sql_text,sqlserver.username)),
ADD EVENT sqlserver.rpc_starting(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.session_id,sqlserver.sql_text,sqlserver.username)),
ADD EVENT sqlserver.sp_statement_completed(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.session_id,sqlserver.sql_text,sqlserver.username)),
ADD EVENT sqlserver.sql_statement_completed(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.session_id,sqlserver.username))
ADD TARGET package0.event_file(SET filename=N'''+ @DIR + '_MSFTTrace.xel'',max_file_size=(2048),max_rollover_files=(5))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=3 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)'
EXECUTE (@sql)
GO
 
/** 4. Start the xEvent Trace **/
ALTER EVENT SESSION [_MSFTTrace] ON SERVER  
STATE = START;
 
/** 5. UNCOMMENT AND RUN THE SINGLE LINE BELLOW TO FINISH THE TRACE  **/
--DROP EVENT SESSION [_MSFTTrace] ON SERVER;


/** 6. Share the created trace file (.xel) with Microsoft  **/
