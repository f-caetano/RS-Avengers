SQL Servers 2012 and above. Requires SysAdmin role on the SQL Server

1. Preferable use the **"MSFTTrace_DirCustomSave"** script
	- In case of permissions error of saving the .XEL in a directory use the alternative **MSFTTrace_DirDefault**.sql
\	
\
\
\
\
\
\
\
\
\

------------


       (wait_type > 0 AND wait_type < 22)    -- LCK_ waits\
    OR (wait_type > 31 AND wait_type < 38)   -- LATCH_ waits\
    OR (wait_type > 47 AND wait_type < 54)   -- PAGELATCH_ waits\
    OR (wait_type > 63 AND wait_type < 70)	 -- PAGEIOLATCH_ waits\
    OR (wait_type > 96 AND wait_type < 100)  -- IO (Disk/Network) waits\
    OR (wait_type = 107) 			 -- RESOURCE_SEMAPHORE waits\
    OR (wait_type = 113)			 -- SOS_WORKER waits\
    OR (wait_type = 120) 			 -- SOS_SCHEDULER_YIELD waits\
    OR (wait_type = 178)			 -- WRITELOG waits\
    OR (wait_type > 174 AND wait_type < 177) -- FCB_REPLICA_ waits\
    OR (wait_type = 186) 			 -- CMEMTHREAD waits\
    OR (wait_type = 187) 			 -- CXPACKET waits\
    OR (wait_type = 207) 			 -- TRACEWRITE waits\
    OR (wait_type = 269) 			 -- RESOURCE_SEMAPHORE_MUTEX waits\
    OR (wait_type = 283) 			 -- RESOURCE_SEMAPHORE_QUERY_COMPILE waits\
    OR (wait_type = 284) 			 -- RESOURCE_SEMAPHORE_SMALL_QUERY waits\
