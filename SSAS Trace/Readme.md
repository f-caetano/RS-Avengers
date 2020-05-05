1. Open SQL Management Studio (SSMS.exe) as an Administrator
	- *You  might recieve an permission error on the nexts steps if the SSMS is not run as administrator*
	
2. On SSMS: Connect to Server> Select "Server Type"> "Analysis Services”
		
    `Server Name: localhost:5132` 
    
3. Open and edit the script XMLA file:
		
    `Start_Trace.XMLA`
		
4. Change the “LogFileName” line to a available driver and folder on your machine

    `example: "C:\Temp"`

5. Run all the code by Pressing F5
	- *if it prompts for a server, make sure to follow the step 2*
	
6. Dont close the SSMS yet. Make sure that the issue is reproduced

7. After the issue is reproduced, run the following file to stop the trace
		
    `Delete_Trace.XMLA`
		
8. Send the .TRC file generated and the latest logs *(compress whole directory)*
	
    `Generally located on: <PBI Installation Folder>\PIBRS\LogFiles\`
   
		
9. Please provide the aproximated timestamp when the issue occured
