




Create procedure sp_acc_rpt_list_cheque_depositedDetail(@DepositID INT)
As
select Collections.DocumentID, "Collection ID" = Collections.FullDocID,
"Collection Date" = Collections.DocumentDate, 
"Type"= case when Others is not null then dbo.LookupDictionaryItem('Others',Default) else dbo.LookupDictionaryItem('Customer',Default) end,  	 
"Account Name" = Case when others is null then (Select Company_Name from Customer where CustomerID=Collections.CustomerID) 
else (Select AccountName from AccountsMaster where AccountID=Collections.Others) end,     
"Cheque Date" = Collections.ChequeDate, "Cheque Number" = Collections.ChequeNumber,
"Amount" = Collections.Value
from Collections where Collections.DepositID = @DepositID order by DocumentID 






