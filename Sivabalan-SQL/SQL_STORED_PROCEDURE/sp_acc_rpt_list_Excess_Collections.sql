Create procedure sp_acc_rpt_list_Excess_Collections(@FromDate datetime,  
          @ToDate datetime)  
as  
select DocumentID, "Collection ID" = FullDocID, "Document Ref" = DocReference, "Collection Date" = DocumentDate,  
"Type"= case when Others is not null then dbo.LookupDictionaryItem('Others',Default) else dbo.LookupDictionaryItem('Customer',Default) end,  	 
-- 	"Account Name" = Case when others is null then (Select Company_Name from Customer where CustomerID=Collections.CustomerID) 
-- 	else (Select AccountName from AccountsMaster where AccountID=Collections.Others) end,     
"Collection Type" = case when CustomerID is null then case when (IsNull(Others,0) <> 0) and (IsNull(ExpenseAccount,0) <> 0) then
dbo.LookupDictionaryItem('Collection from Party for Expense',Default) else case when (IsNull(Others,0) = 0)  and (IsNull(ExpenseAccount,0) <> 0)
then dbo.LookupDictionaryItem('Collection for Expense',Default) else dbo.LookupDictionaryItem('Collection from Party',Default) end end else ' ' end,      
"Party" = Case when IsNull(Collections.others,0) = 0 then (Select Company_Name From Customer where CustomerID=Collections.CustomerID) 
else (Select AccountName from AccountsMaster where AccountID= IsNull(Collections.Others,0)) end,
"Expense Account" = (Select AccountName from AccountsMaster where AccountID = Isnull(Collections.ExpenseAccount,0)),
 "Amount" = Value, "Excess" = Balance, Remarks
from Collections  
where --Collections.CustomerID = Customer.CustomerID and  
Collections.DocumentDate between @FromDate and @ToDate 
and (IsNull(Collections.Status, 0) & 64) = 0 
And (IsNull(Collections.Status,0) & 128) = 0 
and Balance > 0 



