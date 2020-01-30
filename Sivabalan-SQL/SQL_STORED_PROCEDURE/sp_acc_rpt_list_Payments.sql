CREATE Procedure [dbo].[sp_acc_rpt_list_Payments](@Account nVarChar(50),    
       @FromDate DateTime,    
       @ToDate DateTime)    
As   
If @Account=N'%'
Begin 
	Select Payments.DocumentID, "Payment ID" = FullDocID, "Date" = Payments.DocumentDate,    
	"Type" = Case When Payments.Others Is Not NULL Then dbo.LookupDictionaryItem('Others',Default) Else dbo.LookupDictionaryItem('Vendors',Default) End,
	"Payment Type" = 
	Case 
	 When VendorID Is NULL Then 
 		Case
	 	 When IsNULL(Others,0) = 4 Then dbo.LookupDictionaryItem('Payment to Expense',Default) /* Petty Cash Old Impl */
 		 When IsNULL(Others,0) <> 0 And IsNULL(PaymentMode,0) = 5 Then dbo.LookupDictionaryItem('Payment to Party for Expense',Default) /* Petty Cash New Impl */
 		 When (IsNULL(Others,0) <> 0) And (IsNULL(ExpenseAccount,0) <> 0) And IsNULL(PaymentMode,0) <> 5 Then	dbo.LookupDictionaryItem('Payment to Party for Expense',Default) 
  		Else 
  			Case 
  			 When (IsNULL(Others,0) = 0)  And (IsNULL(ExpenseAccount,0) <> 0)	Then dbo.LookupDictionaryItem('Payment to Expense',Default) 
  			 Else dbo.LookupDictionaryItem('Payment to Party',Default) 
  			End 
  	End 
  Else '' 
	End,      
	"Party" = 
	Case 
		When IsNULL(PaymentMode,0) = 0 And IsNULL(Payments.Others,0) = 4 Then ''
		When IsNULL(PaymentMode,0) = 5 Then 
			IsNULL((Select AccountName from AccountsMaster where AccountID= IsNULL(Payments.Others,0)) ,N'')
		When IsNULL(Payments.Others,0) = 0 Then 
			IsNULL((Select Vendor_Name From Vendors where VendorID=Payments.VendorID) ,N'')
		Else 
			IsNULL((Select AccountName from AccountsMaster where AccountID= IsNULL(Payments.Others,0)) ,N'')
	End,
	"Payment Mode" = Case IsNULL(PaymentMode,0)
	When 0 Then    
 	(Case When Payments.Others = 4  Then dbo.LookupDictionaryItem('Petty Cash',Default) Else dbo.LookupDictionaryItem('Cash',Default) End)    	   
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
		Else Cast(Payments.Cheque_Number as nVarChar)
	End,
	"Cheque Date" = 
	Case  
	When PaymentMode in (0,4) Then
	''
	Else
	Cast(Payments.Cheque_Date as nVarChar)
	End,    
	"Bank" = BankName,
	--(Select BankName From BankMaster Where Bank.BankCode *= BankMaster.BankCode), 
	"Branch" = BranchName,
	--(Select BranchName From BranchMaster 
	-- --Inner Join BranchMaster.BankCode = Payments.BankCode		
	-- --Left Join Bank.BranchCode = BranchMaster.BranchCode),
	--	 Where 
	--	 BranchMaster.BankCode = Payments.BankCode
	--	 And 
	--	 BranchCode =* Bank.BranchCode),
	"Status" = Case (IsNULL(Payments.Status,0)& 64)   
	When 0 Then  
	''  
	Else  
	dbo.LookupDictionaryItem('Cancelled',Default)  
	End
	from Payments
	Left Outer Join Bank on Payments.BankID = Bank.BankID
	Left Outer Join BankMaster on Bank.BankCode = BankMaster.BankCode
	--Inner Join BranchMaster on BranchMaster.BankCode = Payments.BankCode		
	Left Join BranchMaster on Bank.BranchCode = BranchMaster.BranchCode and BranchMaster.BankCode = Payments.BankCode

	where 
	--Payments.BankID *= Bank.BankID And
	dbo.StripdatefromTime(Payments.DocumentDate) between @FromDate And @ToDate 
	And (IsNULL(Status,0) & 64) = 0 And (IsNULL(Status,0) <> 192)
	And IsNULL(Status,0) <> 128
End
Else
Begin
	Declare @AccountID Int
	Set @AccountID = (Select AccountID from AccountsMaster where AccountsMaster.AccountName = @Account)

	select Payments.DocumentID, "Payment ID" = FullDocID, "Date" = Payments.DocumentDate,    
	"Type"= Case When Payments.Others Is Not NULL Then dbo.LookupDictionaryItem('Others',Default) Else dbo.LookupDictionaryItem('Vendors',Default) End,  	 
	'Payment Type' = Case When VendorID Is NULL Then
	Case When IsNULL(Others,0) <> 0 And IsNULL(ExpenseAccount,0) <> 0 Then
	dbo.LookupDictionaryItem('Payment to Party for Expense',Default) Else Case When IsNULL(Others,0) = 0  And IsNULL(ExpenseAccount,0) <> 0
	Then dbo.LookupDictionaryItem('Payment to Expense',Default) Else dbo.LookupDictionaryItem('Payment to Party',Default) End End Else ' ' End,      
	"Party" = Case When Payments.Others Is NULL Then (Select Vendor_Name From Vendors where VendorID=Payments.VendorID) 
	Else (Select AccountName from AccountsMaster where AccountID= IsNULL(Payments.Others,0)) End,
	"Payment Mode" = Case PaymentMode    
	When 0 Then    
	(Case When Payments.Others =4 Then dbo.LookupDictionaryItem('Petty Cash',Default) Else dbo.LookupDictionaryItem('Cash',Default) End)    	  
	When 1 Then 
	dbo.LookupDictionaryItem('Cheque',Default)    
	When 2 Then
	dbo.LookupDictionaryItem('DD',Default)
	When 4 Then
	dbo.LookupDictionaryItem('Bank Transfer',Default)
	End,  
	"Amount Paid" = Case When IsNULL(Payments.AccountMode,0)=0 Then IsNULL(Payments.Value,0)
  Else Case When IsNULL(Payments.Others,0)=@AccountID Then IsNULL(Payments.Value,0)
  Else (Select Amount from PaymentExpense PExp Where PExp.PaymentID=Payments.DocumentID
  And PExp.AccountID=@AccountID) End End,"Excess Payment" = Payments.Balance,    
	"Account Number" = Bank.Account_Number,
	"Account Name" = Bank.Account_Name,
	"Cheque Number" = 
	Case PaymentMode
		When 4 Then IsNULL(Payments.Memo,N'')
		Else Cast(Payments.Cheque_Number as nVarChar)
	End,
	"Cheque Date" = 
	Case 
	When PaymentMode in (0,4) Then
	''
	Else
	Cast(Payments.Cheque_Date as nVarChar)
	End,    
	"Bank" = BankName,
	--(Select BankName From BankMaster Where BankCode =* Bank.BankCode), 
	"Branch" = BranchName,
	--(Select BranchName From BranchMaster Where
	--BranchMaster.BankCode = Payments.BankCode And BranchCode =* Bank.BranchCode),
	"Status" = Case (IsNULL(Payments.Status,0)& 64)   
	When 0 Then  
	''  
	Else  
	dbo.LookupDictionaryItem('Cancelled',Default)  
	End
	from Payments
	--Left Join Bank on Payments.BankID = Bank.BankID
	Left Outer Join Bank on Payments.BankID = Bank.BankID
	Left Outer Join BankMaster on Bank.BankCode = BankMaster.BankCode
	--Inner Join BranchMaster on BranchMaster.BankCode = Payments.BankCode		
	Left Join BranchMaster on Bank.BranchCode = BranchMaster.BranchCode and BranchMaster.BankCode = Payments.BankCode

	where 
	(Payments.VendorID = (Select Vendors.VendorID from Vendors where Vendors.Vendor_Name = @Account) 
	Or IsNULL(Others,0) = @AccountID
 Or (IsNULL((Select Count(*) from PaymentExpense PExp Where PExp.AccountID=@AccountID 
 And PExp.PaymentID=Payments.DocumentID),0)<>0 And IsNULL(AccountMode,0)=1)
	Or (IsNULL(ExpenseAccount,0) = @AccountID And IsNULL(AccountMode,0)=0))  
	--And Payments.BankID *= Bank.BankID And
	And dbo.StripdatefromTime(Payments.DocumentDate) between @FromDate And @ToDate 
	And (IsNULL(Status,0) & 64) = 0 And (IsNULL(Status,0) <> 192)
	And IsNULL(Status,0) <> 128
	And (IsNULL(Payments.PaymentMode,0) <> 5 And (Payments.Others) <> 4)
 
	Union

	select Payments.DocumentID, "Payment ID" = FullDocID, "Date" = Payments.DocumentDate,    
	"Type"= dbo.LookupDictionaryItem('Others',Default),
	"Payment Type" = 		
		Case
			When (IsNULL(Others,0) =0 And IsNULL(PaymentMode,0) = 5) or IsNULL(Others,0) = 4 Then dbo.LookupDictionaryItem('Payment to Expense',Default)
			When IsNULL(Others,0) > 0 And IsNULL(PaymentMode,0) = 5 Then dbo.LookupDictionaryItem('Payment to Party for Expense',Default)
		End,
	"Party" = 
		Case 
			When IsNULL(Others,0) > 0 And IsNULL(PaymentMode,0) = 5 Then @Account
			Else ''
		End,
	"Payment Mode" = dbo.LookupDictionaryItem('Petty Cash',Default) ,  
	"Amount Paid" = Payments.Value, 
	"Excess Payment" = 0,
	"Account Number" = '',
	"Account Name" = '',
	"Cheque Number" = '',
	"Cheque Date" = '',
	"Bank" = '',
	"Branch" = '',
	"Status" = Case (IsNULL(Payments.Status,0)& 64)   
	When 0 Then  
	''  
	Else  
	dbo.LookupDictionaryItem('Cancelled',Default)  
	End
	from Payments
	where 
	IsNULL(ExpenseAccount,0) = @AccountID  
	And Others = 4
	And IsNULL(accountmode,0) = 0
	And (IsNULL(Status,0) & 64) = 0 And (IsNULL(Status,0) <> 192)
	And IsNULL(Status,0) <> 128
	And dbo.StripdatefromTime(Payments.DocumentDate) between @FromDate And @ToDate 
	
	Union
	
	select Payments.DocumentID, "Payment ID" = FullDocID, "Date" = Payments.DocumentDate,    
	"Type"= dbo.LookupDictionaryItem('Others',Default),
	"Payment Type" = dbo.LookupDictionaryItem('Payment to Party for an Expense',Default),
	"Party" = @Account,
	"Payment Mode" = dbo.LookupDictionaryItem('Petty Cash',Default) ,  
	"Amount Paid" = Payments.Value, 
	"Excess Payment" = 0,
	"Account Number" = '',
	"Account Name" = '',
	"Cheque Number" = '',
	"Cheque Date" = '',
	"Bank" = '',
	"Branch" = '',
	"Status" = Case (IsNULL(Payments.Status,0)& 64)   
	When 0 Then  
	''  
	Else  
	dbo.LookupDictionaryItem('Cancelled',Default)  
	End
	from Payments
	where 
	Payments.PaymentMode = 5
	And Payments.Others = @AccountID
	And (IsNULL(Status,0) & 64) = 0 And (IsNULL(Status,0) <> 192)
	And IsNULL(Status,0) <> 128
	And dbo.StripdatefromTime(Payments.DocumentDate) between @FromDate And @ToDate 
	
	Union
	
	select Payments.DocumentID, "Payment ID" = FullDocID, "Date" = Payments.DocumentDate,    
	"Type"= dbo.LookupDictionaryItem('Others',Default),
	"Payment Type" = 
		Case
			When (IsNULL(Others,0) =0 And IsNULL(PaymentMode,0) = 5)Then dbo.LookupDictionaryItem('Payment for an Expense',Default)
			When IsNULL(Others,0) > 0 And IsNULL(PaymentMode,0) = 5 Then dbo.LookupDictionaryItem('Payment to Party for an Expense',Default)
		End,
	"Party" = 		
		Case
			When IsNULL(Others,0) > 0 And IsNULL(PaymentMode,0) = 5 Then
				(Select IsNULL(AccountName,N'') from AccountsMaster where 
				AccountsMaster.AccountID = Payments.Others)
			Else ''
		End,
	"Payment Mode" = dbo.LookupDictionaryItem('Petty Cash',Default) ,  
	"Amount Paid" = Payments.Value, 
	"Excess Payment" = 0,
	"Account Number" = '',
	"Account Name" = '',
	"Cheque Number" = '',
	"Cheque Date" = '',
	"Bank" = '',
	"Branch" = '',
	"Status" = Case (IsNULL(Payments.Status,0)& 64)   
	When 0 Then  
	''  
	Else  
	dbo.LookupDictionaryItem('Cancelled',Default)  
	End
	from Payments
	where 
	dbo.StripdatefromTime(Payments.DocumentDate) between @FromDate And @ToDate 
	And IsNULL(ExpenseAccount,0) = @AccountID
	And Payments.PaymentMode = 5
	And IsNULL(AccountMode,0) = 0
	And (IsNULL(Status,0) & 64) = 0 And (IsNULL(Status,0) <> 192)
	And IsNULL(Status,0) <> 128
	
	Union
	
	select Payments.DocumentID, "Payment ID" = FullDocID, "Date" = Payments.DocumentDate,    
	"Type"= dbo.LookupDictionaryItem('Others',Default),
	"Payment Type" = 
		Case
			When (IsNULL(Others,0) =0 And IsNULL(PaymentMode,0) = 5)Then dbo.LookupDictionaryItem('Payment for an Expense',Default)
			When IsNULL(Others,0) > 0 And IsNULL(PaymentMode,0) = 5 Then dbo.LookupDictionaryItem('Payment to Party for an Expense',Default)
		End,
	"Party" = 		
		Case
			When IsNULL(Others,0) > 0 And IsNULL(PaymentMode,0) = 5 Then
				(Select IsNULL(AccountName,N'') from AccountsMaster where 
					AccountsMaster.AccountID = Payments.Others)
			Else ''
		End,
	"Payment Mode" = dbo.LookupDictionaryItem('Petty Cash',Default) ,  
	"Amount Paid" = 
		Case
			When Isnull(Payments.Others,0) = @AccountID then Isnull(Value,0)
			Else
				(Select IsNULL(amount,0) from PaymentExpense where PaymentID = Payments.DocumentID
					And accountID = @AccountID)
		End,
	"Excess Payment" = 0,
	"Account Number" = '',
	"Account Name" = '',
	"Cheque Number" = '',
	"Cheque Date" = '',
	"Bank" = '',
	"Branch" = '',
	"Status" = Case (IsNULL(Payments.Status,0)& 64)   
	When 0 Then  
	''  
	Else  
	dbo.LookupDictionaryItem('Cancelled',Default)  
	End
	from Payments,PaymentExpense
	where 
	dbo.StripdatefromTime(Payments.DocumentDate) between @FromDate And @ToDate 
	And (PaymentExpense.AccountID =@accountID or Payments.Others = @accountID)
	And Payments.PaymentMode = 5
	And IsNULL(AccountMode,0) = 1
	And Payments.documentId = PaymentExpense.PaymentID
End

