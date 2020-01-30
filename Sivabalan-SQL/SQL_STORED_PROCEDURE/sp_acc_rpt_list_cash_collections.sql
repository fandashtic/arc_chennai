CREATE procedure sp_acc_rpt_list_cash_collections(@FromDate datetime,  
        @ToDate datetime)  
as  
select DocumentID, "Collection ID" =  Collections.FullDocID,
"Document Ref" = DocReference,  
"Date" = Collections.DocumentDate,
"Type"= case when Others is not null then dbo.LookupDictionaryItem('Others',Default) else dbo.LookupDictionaryItem('Customer',Default) end,  	 
-- "Account Name" = Case when others is null then (Select Company_Name from Customer where CustomerID=Collections.CustomerID) 
-- else (Select AccountName from AccountsMaster where AccountID=Collections.Others) end,     
"Collection Type" = case when CustomerID is null then case when (IsNull(Others,0) <> 0) and (IsNull(ExpenseAccount,0) <> 0) then
dbo.LookupDictionaryItem('Collection from Party for Expense',Default) else case when (IsNull(Others,0) = 0)  and (IsNull(ExpenseAccount,0) <> 0)
then dbo.LookupDictionaryItem('Collection for Expense',Default) else dbo.LookupDictionaryItem('Collection from Party',Default) end end else ' ' end,      
"Party" = Case when IsNull(Collections.others,0) = 0 then (Select Company_Name From Customer where CustomerID=Collections.CustomerID) 
else (Select AccountName from AccountsMaster where AccountID= IsNull(Collections.Others,0)) end,
"Expense Account" = (Select AccountName from AccountsMaster where AccountID = Isnull(Collections.ExpenseAccount,0)),
"Amount" = Value from Collections 
where Collections.PaymentMode = 0 and 
(IsNull(Collections.Status, 0) & 64) = 0 And (IsNull(Collections.Status, 0) & 128) = 0 And
dbo.stripdatefromtime(Collections.DocumentDate) Between @FromDate And @ToDate
Order By Collections.DocumentDate

