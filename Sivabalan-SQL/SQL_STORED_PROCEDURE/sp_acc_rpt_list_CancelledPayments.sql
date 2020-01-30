CREATE Procedure [dbo].[sp_acc_rpt_list_CancelledPayments](@FromDate DateTime,@ToDate DateTime)    
As   
Select Payments.DocumentID, "Payment ID" = FullDocID, "Date" = Payments.DocumentDate,    
"Type"= Case When Payments.Others Is Not NULL Then dbo.LookupDictionaryItem('Others',Default) Else dbo.LookupDictionaryItem('Vendors',Default) End, 
"Payment Type" = 
Case 
When VendorID Is NULL Then 
	Case
	When IsNULL(Others,0) = 4 Then dbo.LookupDictionaryItem('Payment to Expense',Default) /* Petty Cash Old Impl*/
	When IsNULL(Others,0) <> 0 And IsNULL(PaymentMode,0) = 5 Then dbo.LookupDictionaryItem('Payment to Party for Expense',Default) /* Petty Cash New Impl */
	When (IsNULL(Others,0) <> 0) And (IsNULL(ExpenseAccount,0) <> 0) And IsNULL(PaymentMode,0) <> 5 Then dbo.LookupDictionaryItem('Payment to Party for Expense',Default) 
	Else 
		Case 
		When (IsNULL(Others,0) = 0)  And (IsNULL(ExpenseAccount,0) <> 0) Then dbo.LookupDictionaryItem('Payment to Expense',Default) 
		Else dbo.LookupDictionaryItem('Payment to Party',Default) 
		End 
	End 
Else ' ' 
End,      
"Party" = 
Case 
	When IsNULL(PaymentMode,0) = 0 And IsNULL(Payments.others,0) = 4 Then ''
	When IsNULL(PaymentMode,0) = 5 Then 
		IsNULL((Select AccountName from AccountsMaster where AccountID= IsNULL(Payments.Others,0)),N'')
	When IsNULL(Payments.others,0) = 0 Then 
		IsNULL((Select Vendor_Name From Vendors where VendorID=Payments.VendorID),N'')
	Else 
		IsNULL((Select AccountName from AccountsMaster where AccountID= IsNULL(Payments.Others,0)),N'')
End,
"Payment Mode" = Case PaymentMode    
When 0 Then    
(Case When Payments.Others =4 Then dbo.LookupDictionaryItem('Petty Cash',Default) Else dbo.LookupDictionaryItem('Cash',Default) End)    	   
When 1 Then    
dbo.LookupDictionaryItem('Cheque',Default)    
When 2 Then
dbo.LookupDictionaryItem('DD',Default)
When 4 Then
dbo.LookupDictionaryItem('Bank Transfer',Default)
When 5 Then
dbo.LookupDictionaryItem('Petty Cash',Default)
End,  
"Amount Paid" = Payments.Value, "Excess Payment" = Payments.Balance,    
"Account Number" = Bank.Account_Number,
"Account Name" = Bank.Account_Name,
"Cheque Number" = 
Case PaymentMode
	When 4 Then IsNULL(Payments.Memo,N'')
	Else Cast(Payments.Cheque_Number as nVarchar)
End,
"Cheque Date" = 
Case  
When PaymentMode in (0,4) Then
''
Else
Cast(Payments.Cheque_Date as nvarchar)
End,    
"Bank" = (Select BankName From BankMaster Right Join Bank on Bank.BankCode = BankMaster.BankCode),
"Branch" = (Select BranchName From BranchMaster Inner Join Payments on BranchMaster.BankCode = Payments.BankCode 
			Right Join Bank on BranchMaster.BranchCode = Bank.BranchCode
			)
from Payments
Left Join Bank on Payments.bankid = bank.bankid
where 
--Payments.bankid *= bank.bankid 
--And 
(IsNULL(Status,0) & 64) <> 0  
And dbo.StripdatefromTime(Payments.DocumentDate) between @FromDate And @ToDate 
And (IsNULL(Status,0) = 192)
