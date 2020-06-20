/*=================== README ============================================================================
Running the entire script will start the trace. SysAdmin permission on the SQL Server is required

After step 3: Code is needed to be executed manually. Further information details are on the steps 
              Please select only the specific code lines of the step to avoid running the entire script
=========================================================================================================*/
USE master;
GO
/** 1. Cleanup                                      **/
IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='_MSFTTrace')  
    DROP EVENT SESSION [_MSFTTrace] ON SERVER;  
GO
 
/** 2. Create the Extended Events Trace             **/
CREATE EVENT SESSION [_MSFTTrace] ON SERVER 
ADD EVENT sqlos.wait_info(
    ACTION(sqlserver.database_name,sqlserver.session_id,sqlserver.sql_text)
  WHERE ([opcode]=1 AND [duration]>10000 AND (([wait_type]>31 AND [wait_type]<38) OR ([wait_type]>47 AND [wait_type]<54) OR ([wait_type]>63 AND [wait_type]<70) OR ([wait_type]>96 AND [wait_type]<100) OR ([wait_type]=107) OR ([wait_type]=113) OR ([wait_type]>174 AND [wait_type]<179) OR ([wait_type]=178) OR ([wait_type]=186) OR ([wait_type]=207) OR ([wait_type]=269) OR ([wait_type]=283) OR ([wait_type]=284) OR ([duration]>30000 AND [wait_type]<22)))),
ADD EVENT sqlserver.attention(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.session_id,sqlserver.sql_text,sqlserver.username)
    WHERE ([sqlserver].[is_system]=(0))),
ADD EVENT sqlserver.blocked_process_report(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.session_id,sqlserver.sql_text,sqlserver.username)),
ADD EVENT sqlserver.error_reported(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.session_id,sqlserver.sql_text,sqlserver.username)
    WHERE (([severity]>(10)) AND ([state]>(1)))),
ADD EVENT sqlserver.rpc_completed(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.session_id,sqlserver.sql_text,sqlserver.username)),
ADD EVENT sqlserver.rpc_starting(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.session_id,sqlserver.sql_text,sqlserver.username)),
ADD EVENT sqlserver.sp_statement_completed(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.session_id,sqlserver.username)),
ADD EVENT sqlserver.sql_statement_completed(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.session_id,sqlserver.username))
    ADD TARGET package0.event_file(SET filename=N'_MSFTTrace.xel',max_file_size=(2048),max_rollover_files=(5))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=3 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
 
 
/** 3. Start the xEvent Trace                      **/
ALTER EVENT SESSION [_MSFTTrace] ON SERVER  
STATE = START;
 
/** 4. Stop the xEvent Trace                       **
ALTER EVENT SESSION [_MSFTTrace] ON SERVER  
STATE = STOP;
                                                   **/
/** 5. Export the generated xEvent (.xel) file     **

Two options
1) Inside the SQL Server machine locate the file in the SQL Directory:
   usually: "<SQL Server Installation Path>\Microsoft SQL Server\MSSQLxx.MSSQLSERVER\Log\file.xel"
 
2) Using SSMS, and saving the trace on a client workstation
    a) On the SSMS Object Explorer (our left Panel) expand the folder 'Management' then Extended Events» Sessions» _MSFTrace
    b) Under the name of the trace, double click 'package0.event_file' and it will open the collected events in a table format
    c) Wait a few seconds for them to load, then on the top bar of SSMS (Menu toolbar) select: Extended Events» Export To» XEL File...
    d) Save this file on a directory at your choice 
**/
 
/** 6. With the file saved (.xel) remove the xEvent created from the SQL Server  **
DROP EVENT SESSION [_MSFTTrace] ON SERVER;
                                                                                 **/
/** 7. All done. Share the xEvent file (.xel)                                    **/
