CREATE procedure sp_list_Customer_CreditNote(@CustomerID nvarchar(15),              
          @FromDate datetime,              
          @ToDate datetime, @option int=0)              
as             
If (@option = 0)
Begin
select DocumentID, DocumentDate, Customer.CustomerID, Company_Name, NoteValue, CreditID,            
dbo.LookupDictionaryItem(case           
When Status & 64 <> 0 Then N'Cancelled'            
When isnull(status,0) = 0  and  isnull(RefDocid,0) = 0  Then N''
when isnull(status & 128,0 ) = 128 and isnull(RefDocid,0) <> 0 then N'Amended'    
when isnull(status & 128,0 ) = 128 and Balance = 0  then N'Amended'    
when isnull(status & 128,0 ) = 0 and isnull(RefDocid,0) <> 0  then N'Amendment'    
Else N''            
end, Default),
DocumentReference        
from CreditNote, Customer              
where Customer.CustomerID like @CustomerID  and              
DocumentDate between @FromDate  and @ToDate and              
CreditNote.Flag = 0 and 
Customer.CustomerID = CreditNote.CustomerID              
order by Customer.Company_Name, DocumentDate
End
Else
Begin
select DocumentID, DocumentDate, Customer.CustomerID, Company_Name, NoteValue, CreditID,            
dbo.LookupDictionaryItem(case           
When Status & 64 <> 0 Then N'Cancelled'            
When isnull(status,0) = 0  and  isnull(RefDocid,0) = 0  Then N''
when isnull(status & 128,0 ) = 128 and isnull(RefDocid,0) <> 0 then N'Amended'    
when isnull(status & 128,0 ) = 128 and Balance = 0  then N'Amended'    
when isnull(status & 128,0 ) = 0 and isnull(RefDocid,0) <> 0  then N'Amendment'    
Else N''            
end, Default),
DocumentReference        
from CreditNote, Customer              
where Customer.CustomerID like @CustomerID  and              
DocumentDate between @FromDate  and @ToDate and              
CreditNote.Flag = 0 and 
Customer.CustomerID = CreditNote.CustomerID              
order by Customer.Company_Name, DocumentDate
End
