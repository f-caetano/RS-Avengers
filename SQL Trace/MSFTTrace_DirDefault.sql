/*=================== README ======================================================================
Running the entire script will start the trace. SysAdmin permission on the SQL Server is required

After step 3: Code is comment with "--" and the T-SQL needs to be executed manually
Please follow the information and select only the specific lines to avoid running the entire script

===================================================================================================*/
USE master;
GO
/** 1. Cleanup **/
IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='_MSFTTrace')  
    DROP EVENT SESSION [_MSFTTrace] ON SERVER;  
GO
 
/** 2. Create the Extended Events Trace **/
CREATE EVENT SESSION [_MSFTTrace] ON SERVER 
ADD EVENT sqlos.wait_info(
    ACTION(sqlserver.session_id)),
ADD EVENT sqlserver.attention(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.session_id,sqlserver.sql_text)),
ADD EVENT sqlserver.blocked_process_report(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.session_id,sqlserver.sql_text)),
ADD EVENT sqlserver.error_reported(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.session_id,sqlserver.sql_text)),
ADD EVENT sqlserver.sp_statement_completed(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.session_id,sqlserver.sql_text)),
ADD EVENT sqlserver.sp_statement_starting(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.session_id,sqlserver.sql_text)),
ADD EVENT sqlserver.sql_statement_completed(SET collect_statement=(1)
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.session_id)),
ADD EVENT sqlserver.sql_statement_starting(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.session_id))
    ADD TARGET package0.event_file(SET filename=N'_MSFTTrace.xel',max_file_size=(2048),max_rollover_files=(5))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=3 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
 
 
/** 3. Start the xEvent Trace **/
ALTER EVENT SESSION [_MSFTTrace] ON SERVER  
STATE = START;
 
/** 4. Stop the xEvent Trace  **/
--ALTER EVENT SESSION [_MSFTTrace] ON SERVER  
--STATE = STOP;
 
/** 5. SSMS: Export the xEvent to a file on your local disk 
 
ON SSMS Object Explorer (left Panel) Expand folders: Management» Extended Events» Sessions» _MSFTrace
Double click 'package0.event_file' will open the collected events in a table format
On the Menu toolbar for SSMS go to: Extended Events» Export To» XEL File...
Save this file on a directory at your choice 
 
**/
 
/** 6. With the file saved (.xel) remove the xEvent from your SQL Server  **/
--DROP EVENT SESSION [_MSFTTrace] ON SERVER;
