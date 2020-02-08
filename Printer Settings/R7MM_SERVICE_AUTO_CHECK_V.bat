@echo off
set service_name = DataBridge_R7MM


rem date/t>>log.txt
rem time/t>>log.txt 
rem SC query DataBridge_R7MM | FIND "STATE"  >> log.txt
set dbserver= localhost
set dmsdbname= ITC_SALES_V8
set dbuser= sa
set dbpassword= athena


SET SQL="SELECT REMOTEDBNAME FROM M_DBDETAILS" 


mkdir .\SYSDBLOG

sqlcmd -S %dbserver% -d %dmsdbname% -Q %SQL% -h -1 -o sifyname.txt

SET /p dbname= <sifyname.txt
DEL sifyname.txt

REM sqlcmd -S %dbserver% -d %dbname% -Q "UPDATE SET_REF SET REF_VALUE = '%dist_cd%' WHERE REF_TYPE = 'S_DIVISION' AND REF_PARAM = 'DIST_CD'" -o .\logs\Decentralize\s_division.log

echo:>>servicelog.txt
date/t>>servicelog.txt
time/t>>servicelog.txt

sc query type= service state= all | find "DataBridge_R7MM"
if %ERRORLEVEL% == 1 goto installservice
if %ERRORLEVEL% == 0 goto checkstatus1
goto end


:installservice
sqlcmd -S %dbserver% -d %dmsdbname% -U %dbuser% -P %dbpassword% -Q  "INSERT INTO SYS_DE_LOG(DIST_CD,DE_NAME,DE_DESC,START_DT,REMARK) VALUES((SELECT TOP 1 DIST_cD FROM MST_DIST),'DataBridge_R7MM','NOT_INSTALL',GETDATE(),'DataBridge_R7MM IS NOT INSTALLED  NEXT ACTION -SYSTEM IS TRYING TO INSTALL SERVICE')" -o .\SYSDBLOG\SYSDBLOG.log

sqlcmd -S %dbserver% -d %dbname% -U %dbuser% -P %dbpassword% -Q  "INSERT INTO SYS_DE_LOG(SERIAL_NO,DIST_CD,DE_NAME,DE_DESC,START_DT,REMARK) VALUES((SELECT max(SERIAL_NO) FROM ITC_SALES_V8..SYS_DE_LOG),(SELECT TOP 1 DIST_cD FROM ITC_SALES_V8..MST_DIST),'DataBridge_R7MM','NOT_INSTALL',GETDATE(),'DataBridge_R7MM IS NOT INSTALLED  NEXT ACTION -SYSTEM IS TRYING TO INSTALL SERVICE')" -o .\SYSDBLOG\SYSDBLOG.log


echo 'installing service'>>servicelog.txt

@echo | call InstallService.bat /t>>servicelog.txt
Net start DataBridge_R7MM
rem goto end
goto checkstatus1

:checkstatus1

SC query DataBridge_R7MM | FIND "STATE" | FIND "STOPPED" 
if %ERRORLEVEL% ==0 goto start_service1
if %ERRORLEVEL% ==1 goto workingfine
goto end 


:checkstatus2

SC query DataBridge_R7MM | FIND "STATE" | FIND "STOPPED" 
if %ERRORLEVEL% ==0 goto start_service2
if %ERRORLEVEL% ==1 goto workingfine
goto end 


:checkstatus3

SC query DataBridge_R7MM | FIND "STATE" | FIND "STOPPED" 
if %ERRORLEVEL% ==0 goto secondattemptfailed
if %ERRORLEVEL% ==1 goto workingfine
goto end 


:start_service1

sqlcmd -S %dbserver% -d %dmsdbname% -U %dbuser% -P %dbpassword% -Q  "INSERT INTO SYS_DE_LOG(DIST_CD,DE_NAME,DE_DESC,START_DT,REMARK) VALUES((SELECT TOP 1 DIST_cD FROM MST_DIST),'DataBridge_R7MM','STOPPED',GETDATE(),'DataBridge_R7MM IS STOPPED NEXT ACTION -SYSTEM IS TRYING - First Time TO RE-START SERVICE')" -o .\SYSDBLOG\SYSDBLOG.log

sqlcmd -S %dbserver% -d %dbname% -U %dbuser% -P %dbpassword% -Q  "INSERT INTO SYS_DE_LOG(SERIAL_NO,DIST_CD,DE_NAME,DE_DESC,START_DT,REMARK) VALUES((SELECT max(SERIAL_NO) FROM ITC_SALES_V8..SYS_DE_LOG),(SELECT TOP 1 DIST_cD FROM ITC_SALES_V8..MST_DIST),'DataBridge_R7MM','STOPPED',GETDATE(),'DataBridge_R7MM IS STOPPED NEXT ACTION -SYSTEM IS TRYING - First Time TO RE-START SERVICE')" -o .\SYSDBLOG\SYSDBLOG.log

Net start DataBridge_R7MM >>servicelog.txt
timeout 20
goto checkstatus2



:start_service2

sqlcmd -S %dbserver% -d %dmsdbname% -U %dbuser% -P %dbpassword% -Q  "INSERT INTO SYS_DE_LOG(DIST_CD,DE_NAME,DE_DESC,START_DT,REMARK) VALUES((SELECT TOP 1 DIST_cD FROM MST_DIST),'DataBridge_R7MM','TRYING-RESTART',GETDATE(),'DataBridge_R7MM IS STOPPED NEXT ACTION -SYSTEM IS RE-TRYING - 2nd Time TO RE-START SERVICE')" -o .\SYSDBLOG\SYSDBLOG.log

sqlcmd -S %dbserver% -d %dbname% -U %dbuser% -P %dbpassword% -Q  "INSERT INTO SYS_DE_LOG(SERIAL_NO,DIST_CD,DE_NAME,DE_DESC,START_DT,REMARK) VALUES((SELECT max(SERIAL_NO) FROM ITC_SALES_V8..SYS_DE_LOG),(SELECT TOP 1 DIST_cD FROM ITC_SALES_V8..MST_DIST),'DataBridge_R7MM','TRYING-RESTART',GETDATE(),'DataBridge_R7MM IS STOPPED NEXT ACTION -SYSTEM IS RE-TRYING - 2nd Time TO RE-START SERVICE')" -o .\SYSDBLOG\SYSDBLOG.log

Net start DataBridge_R7MM >>servicelog.txt

timeout 20
goto checkstatus3




:workingfine
sqlcmd -S %dbserver% -d %dmsdbname% -U %dbuser% -P %dbpassword% -Q  "INSERT INTO SYS_DE_LOG(DIST_CD,DE_NAME,DE_DESC,START_DT,REMARK) VALUES((SELECT TOP 1 DIST_cD FROM MST_DIST),'DataBridge_R7MM','RUNNING',GETDATE(),'DataBridge_R7MM IS RUNNING FINE ')" -o .\SYSDBLOG\SYSDBLOG.log

sqlcmd -S %dbserver% -d %dbname% -U %dbuser% -P %dbpassword% -Q  "INSERT INTO SYS_DE_LOG(SERIAL_NO,DIST_CD,DE_NAME,DE_DESC,START_DT,REMARK) VALUES((SELECT max(SERIAL_NO) FROM ITC_SALES_V8..SYS_DE_LOG),(SELECT TOP 1 DIST_cD FROM ITC_SALES_V8..MST_DIST),'DataBridge_R7MM','RUNNING',GETDATE(),'DataBridge_R7MM IS RUNNING FINE ')" -o .\SYSDBLOG\SYSDBLOG.log

echo "DMS Service working fine">>servicelog.txt
goto end

:secondattemptfailed
sqlcmd -S %dbserver% -d %dmsdbname% -U %dbuser% -P %dbpassword% -Q  "INSERT INTO SYS_DE_LOG(DIST_CD,DE_NAME,DE_DESC,START_DT,REMARK) VALUES((SELECT TOP 1 DIST_cD FROM MST_DIST),'DataBridge_R7MM','STOPPED',GETDATE(),'DataBridge_R7MM Re-Start 2nd Attempt Failed ')" -o .\SYSDBLOG\SYSDBLOG.log

sqlcmd -S %dbserver% -d %dbname% -U %dbuser% -P %dbpassword% -Q  "INSERT INTO SYS_DE_LOG(SERIAL_NO,DIST_CD,DE_NAME,DE_DESC,START_DT,REMARK) VALUES((SELECT max(SERIAL_NO) FROM ITC_SALES_V8..SYS_DE_LOG),(SELECT TOP 1 DIST_cD FROM ITC_SALES_V8..MST_DIST),'DataBridge_R7MM','STOPPED',GETDATE(),'DataBridge_R7MM Re-Start 2nd Attempt Failed ')" -o .\SYSDBLOG\SYSDBLOG.log

goto end 

:end




