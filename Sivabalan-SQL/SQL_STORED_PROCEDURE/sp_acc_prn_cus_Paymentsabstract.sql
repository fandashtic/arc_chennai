CREATE Procedure [dbo].[sp_acc_prn_cus_Paymentsabstract](@PaymentID INT)
as
Select 
"Payment ID" = Payments.FullDocID,
"Payment Type" = 
Case
	When IsNULL(Payments.Others,0) <> 0 And IsNULL(Payments.ExpenseAccount,0) = 0 then dbo.LookupDictionaryItem('Payment to Party',Default)
	When IsNULL(Payments.Others,0) <> 0 And IsNULL(Payments.ExpenseAccount,0) <> 0 then dbo.LookupDictionaryItem('Payment to Party for Expense',Default)
	When IsNULL(Payments.Others,0) = 0 And IsNULL(Payments.ExpenseAccount,0) <> 0 then dbo.LookupDictionaryItem('Payment for Expense',Default)
End,
"Party" = dbo.getaccountname(Others),
"Account No" = Bank.Account_Number,
"Payment Description" =
Case Payments.PaymentMode
	When 0 Then dbo.LookupDictionaryItem('Cheque No.       :',Default)
	When 1 Then dbo.LookupDictionaryItem('Cheque No.       :',Default)
	When 2 Then 
		Case 
			When Payments.DDmode = 1 And (Payments.Bankid Is not NULL) then dbo.LookupDictionaryItem('Cheque No.       :',Default)
			When Payments.DDmode = 0 And (Payments.Bankid Is not NULL) then dbo.LookupDictionaryItem('DD No.           :',Default)
		End
	When 4 Then dbo.LookupDictionaryItem('Transaction Code :',Default)
End,
"Payment Details" = 
Case Payments.PaymentMode
	When 0 Then NULL
	When 1 Then cast(cheque_number as nchar(255))
	When 2 Then 
		Case
			When Payments.DDmode = 1 then rtrim(cast(cheques.Cheque_Book_Name as nchar(255) )) + N' - ' + rtrim(cast(Payments.ddchequenumber as nvarchar(255)))
			When Payments.DDmode = 0 then Cast(Payments.Cheque_number as nchar(255))
		End
	When 4 Then IsNULL(Memo,N'')
End,
"Cheque No." = 
Case
	When Payments.DDmode = 1 then rtrim(cast(cheques.Cheque_Book_Name as nchar(255) )) + N' - ' + rtrim(cast(Payments.ddchequenumber as nvarchar(255)))
	When Payments.DDmode = 0 then NULL
	When Payments.DDmode Is NULL Then cast(cheque_number as nchar(255))
End,
"Cheque Date" = 
Case
	When Payments.DDmode = 1 then Payments.DDChequedate
	When Payments.DDmode = 0 then NULL
	When Payments.DDMode Is NULL Then
		Case 
			When PaymentMode = 4 Then NULL
			Else cheque_date
		End
End,
"DD Mode" =
Case 
	When Payments.DDmode = 1 And (Payments.Bankid Is not NULL) then dbo.LookupDictionaryItem('Bank Account',Default)
	When Payments.DDmode = 0 And (Payments.Bankid Is not NULL) then dbo.LookupDictionaryItem('Cash',Default)
	When Payments.DDmode = 0 And (Payments.Bankid Is NULL) then ''
End,
"DD Description" =
Case 
	When Payments.PaymentMode = 2 And Payments.DDMode = 1 Then dbo.LookupDictionaryItem('DD No.           :',Default)
	Else ''
End,
"DD No." = 
Case
	When Payments.PaymentMode = 2 And Payments.DDMode = 1 Then
	Case
		When ddchequenumber Is NULL then NULL
		When ddchequenumber Is not NULL then Payments.Cheque_number
	End
	Else ''
End,
"DD Date" = Payments.ddchequedate,
"Bank" = Bankmaster.BankName,
"Branch" = branchmaster.branchname,
"Paid Amount" = Payments.value,
"Adjusted Amount" = Payments.value - Payments.Balance,
"Excess Amount" = Payments.Balance,
"Document Date" = documentdate,
"Paid To" = Payments.payableto,
"Payment Mode" = 
Case
 When Payments.Paymentmode = 0 then dbo.LookupDictionaryItem('Cash',Default)
	When Payments.Paymentmode = 1 then dbo.LookupDictionaryItem('Cheque',Default)
	When Payments.Paymentmode = 2 then dbo.LookupDictionaryItem('DD',Default)
	When Payments.Paymentmode = 4 then dbo.LookupDictionaryItem('Bank Transfer',Default)
End,
"Cancellation Remarks" =
Case 
	When IsNULL(Status,0) & 192 <> 0 then dbo.LookupDictionaryItem('Cancellation Remarks :',Default) 
	Else '' 
End,
"Reason for Cancellation" = 
Case 
	When IsNULL(Status,0) & 192 <> 0 then Remarks
	Else '' 
End,
"Narration" = Narration,
"Document Type" = DocSerialType,
"Document Reference" = Docref,
"Bank Transaction Code" = IsNULL(Payments.Memo,N''),
"Document Type/Expense Account" = 
Case
 When IsNULL(ExpenseAccount,0) = 0 Then dbo.LookupDictionaryItem('Document Type',Default)
 Else dbo.LookupDictionaryItem('Expense Account',Default)
End,
"Document ID" = 
Case
 When IsNULL(ExpenseAccount,0) = 0 Then dbo.LookupDictionaryItem('Document ID',Default)
 Else ''
End,
"Date" = 
Case
 When IsNULL(ExpenseAccount,0) = 0 Then dbo.LookupDictionaryItem('Date',Default)
 Else ''
End,
"Amount Adjusted/Amount" = 
Case
 When IsNULL(ExpenseAccount,0) = 0 Then dbo.LookupDictionaryItem('Amount Adjusted',Default)
 Else dbo.LookupDictionaryItem('Amount',Default)
End,
"Amount" = 
Case
 When IsNULL(ExpenseAccount,0) = 0 Then dbo.LookupDictionaryItem('Amount',Default)
 Else ''
End,
"Extra Collection" = 
Case
 When IsNULL(ExpenseAccount,0) = 0 Then dbo.LookupDictionaryItem('Extra Collection',Default)
 Else ''
End
from Payments
Left Join BankMaster on Payments.Bankcode = BankMaster.Bankcode
Left Join BranchMaster on Payments.Bankcode = BranchMaster.Bankcode and Payments.BranchCode = BranchMaster.BranchCode
Left Join Cheques on Payments.Cheque_Id = Cheques.ChequeId
Left Join Bank on Payments.BankID = Bank.BankID
--Payments,BankMaster,BranchMaster,Bank,Cheques
where Payments.Documentid = @PaymentID
--And Payments.Bankcode *= BankMaster.Bankcode
--And Payments.Bankcode *= BranchMaster.Bankcode    
--And Payments.BranchCode *= BranchMaster.BranchCode
--And Payments.Cheque_Id *= Cheques.ChequeId
--And Payments.BankID *= Bank.BankID
