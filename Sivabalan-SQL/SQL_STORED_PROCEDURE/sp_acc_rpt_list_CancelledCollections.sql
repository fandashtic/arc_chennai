CREATE procedure [dbo].[sp_acc_rpt_list_CancelledCollections] (   
     @FromDate datetime,      
     @ToDate datetime)      
as      

select DocumentID, "Collection ID" = FullDocID, "Date" = DocumentDate,  
"Type"= case when Others is not null then dbo.LookupDictionaryItem('Others',Default) else dbo.LookupDictionaryItem('Customer',Default) end,      
"Account Name" = Case when others is null then (Select Company_Name from Customer where CustomerID=Collections.CustomerID)   
else (Select AccountName from AccountsMaster where AccountID=Collections.Others) end,       
"Payment Mode" = case PaymentMode      
when 0 then dbo.LookupDictionaryItem('Cash',Default)      
when 1 then dbo.LookupDictionaryItem('Cheque',Default)      
when 2 then dbo.LookupDictionaryItem('DD',Default)      
when 3 then dbo.LookupDictionaryItem('Credit Card',Default)      
when 4 then dbo.LookupDictionaryItem('Bank Transfer',Default)
when 5 then dbo.LookupDictionaryItem('Coupon',Default)  
when 6 then dbo.LookupDictionaryItem('Credit Note',Default)  
when 7 then dbo.LookupDictionaryItem('Gift Voucher',Default)  
end,      
"Amount Recd" = Collections.Value, "Current Balance" = Collections.Balance,      
"Cheque Number" = 
Case PaymentMode
When 4 then Collections.Memo
Else Cast(Collections.ChequeNumber as nVarchar)
End,
"Cheque Date" = Case PaymentMode  
When 1 then Cast(Collections.ChequeDate as nVarchar)  
Else ''  
End,      
"Account Number" = 
Isnull((Select Bank.Account_Number from Bank where Bank.BankId = Isnull(Collections.BankId,0)),N''),
"Bank" = Case PaymentMode
When 3 Then
	IsNull((Select BankMaster.BankName From BankMaster, Bank
	Where Bank.BankID = Collections.BankID
	And Bank.BankCode = BankMaster.BankCode), N'')
Else
	IsNull(BankMaster.BankName, N'')
End,
"Branch" = Case PaymentMode
When 3 Then
	IsNull((Select BranchMaster.BranchName From BranchMaster, Bank
	Where Bank.BankID = Collections.BankID 
	And Bank.BranchCode = BranchMaster.BranchCode
	And Bank.BankCode = BranchMaster.BankCode), N'')
Else
	IsNull(BranchMaster.BranchName,N'') 
End
from Collections
Left Join BankMaster on Collections.BankCode = BankMaster.BankCode
Left Join BranchMaster on Collections.BranchCode = BranchMaster.BranchCode
WHERE  
dbo.StripdateFromTime(Collections.DocumentDate) between @FromDate and @ToDate 
And (Status & 64) <> 0
--And Collections.BankCode *= BankMaster.BankCode
--And Collections.BranchCode *= BranchMaster.BranchCode
