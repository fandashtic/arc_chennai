Create Procedure mERP_SP_CheckCloseDate (@DayClose datetime)  
As  
Begin  
set dateformat dmy  
if exists (select * from daycloselog where dayclose = dbo.striptimefromdate(@DayClose)  
and dbo.striptimefromdate(sysDate) = dbo.striptimefromdate(getdate()))  
 select 1  
else  
 select 0  
End  
