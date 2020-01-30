CREATE procedure spr_list_saleable_free  
(@fromdate as datetime,  
 @todate as datetime)  
as  
select DocSerial,
"Conversion Id"= DocPrefix +Cast(DocumentID as nvarchar),
"Date"=DocumentDate,
"User Name" = UserName  
from conversionabstract 
where   
DocumentDate between @fromdate and @todate and  
conversiontype=2 
