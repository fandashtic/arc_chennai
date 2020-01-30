CREATE procedure spr_list_free_saleable 
(@fromdate as datetime,  
 @todate as datetime)  
as  
select DocSerial, 
"Conversion Id"=DocPrefix + Cast(DocumentID as nvarchar), 
"Date"=DocumentDate,UserName  
from conversionabstract where   
DocumentDate between @fromdate and @todate and  
conversiontype=1 

