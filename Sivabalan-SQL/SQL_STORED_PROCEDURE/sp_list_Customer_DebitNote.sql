CREATE Procedure sp_list_Customer_DebitNote(@CustomerID nvarchar(15),        
         @FromDate datetime,        
         @ToDate datetime)        
as       
declare @Remark as nvarchar(255)    

select DocumentID, DocumentDate, Customer.CustomerID, Customer.Company_Name, NoteValue,        
DebitID,    
dbo.LookupDictionaryItem(case     
When Status & 64 <> 0 Then N'Cancelled'      
When isnull(status,0) = 0  and  isnull(RefDocid,0) = 0  Then N''
when isnull(status & 128,0 ) = 128 and isnull(RefDocid,0) <> 0 then N'Amended'    
when isnull(status & 128,0 ) = 128 and Balance = 0  then N'Amended'    
when isnull(status & 128,0 ) = 0 and isnull(RefDocid,0) <> 0  then N'Amendment'    
Else N''      
end, Default), DocumentReference              
from DebitNote, Customer        
where Customer.CustomerID like @CustomerID and        
DocumentDate between @FromDate and @ToDate and        
Customer.CustomerID = DebitNote.CustomerID        
order by Customer.Company_Name, DocumentDate  




