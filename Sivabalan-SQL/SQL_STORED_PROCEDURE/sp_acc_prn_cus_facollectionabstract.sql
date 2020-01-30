CREATE Procedure [dbo].[sp_acc_prn_cus_facollectionabstract](@CollectionID Int)      
As      
Select         
"Collection ID" = FullDocID,        
"Date" = DocumentDate,        
"Collection Mode" =
Case PaymentMode
	When 0 Then dbo.LookupDictionaryItem('Cash',Default)
	When 1 Then dbo.LookupDictionaryItem('Cheque',Default)
	When 2 Then dbo.LookupDictionaryItem('DD',Default)
 When 3 Then dbo.LookupDictionaryItem('Credit Card',Default)
	When 4 Then dbo.LookupDictionaryItem('Bank Transfer',Default)
 When 5 Then dbo.LookupDictionaryItem('Coupon',Default)
End,
"Collection Type" =     
 Case     
  When CAST(Others as Numeric) <> 0 And CAST(ExpenseAccount as Numeric) = 0 Then dbo.LookupDictionaryItem('Collection from a Party',Default)    
  When CAST(Others as Numeric) <> 0 And CAST(ExpenseAccount as Numeric) <> 0 Then dbo.LookupDictionaryItem('Collection from a Party for Expense',Default)    
  When CAST(Others as Numeric) = 0 And CAST(ExpenseAccount as Numeric) <> 0 Then dbo.LookupDictionaryItem('Collection for an Expense',Default)    
 End,    
"Party A/C" = isNULL(dbo.getaccountname(Collections.Others),N''),    
"Expense A/C" = isNULL(dbo.getaccountname(Collections.ExpenseAccount),N''),    
"Payment Mode" = PaymentMode,        
"Collection Description" =     
 Case    
  When PaymentMode In (1) Then dbo.LookupDictionaryItem('Cheque No :',Default)    
  When PaymentMode In (2) Then dbo.LookupDictionaryItem('DD No :',Default)    
  When PaymentMode In (3) Then dbo.LookupDictionaryItem('CreditCard No :',Default)
  When PaymentMode In (4) Then dbo.LookupDictionaryItem('Transaction Code:',Default)
 End,    
"Collection Date" =     
 Case    
  When PaymentMode In (1)  Then dbo.LookupDictionaryItem('Cheque Date :',Default)    
  When PaymentMode In (2) Then dbo.LookupDictionaryItem('DD Date :',Default)    
 End,    
"Collection Details" =   
 Case    
  When PaymentMode In (1,2) Then CAST (ChequeNumber as nVarchar)
  When PaymentMode In (3) Then CreditCardNumber
  When PaymentMode In (4) Then Memo
  When PaymentMode Not In (1,2,3,4) Then NULL  
 End,  
"Cheque/DD Number" = 
 Case    
  When PaymentMode In (1,2) Then CAST (ChequeNumber as nVarchar)
  Else NULL
 End,
"Cheque/DD Date" =   
 Case    
  When PaymentMode In (1,2) Then ChequeDate  
  When PaymentMode Not In (1,2) Then NULL  
 End,  
"Bank Name" = BankMaster.BankName,        
"Branch Name" = BranchMaster.BranchName,        
"Amount Paid" = Collections.Value,        
"Adjusted Amount" = Collections.Value-Balance,    
"Excess Amount" = Balance,        
"Bank Code" = BankMaster.BankCode,        
"Branch Code" = BranchMaster.BranchCode,        
"Others" = Others ,        
"Expense Account" = ExpenseAccount,        
"DenomInation" = DenomInation,        
"Status" = Status,  
"Narration" = Narration,
"Cancellation Remarks" = 
Case 
	When isNULL(status,0) & 64 <> 0 Then dbo.LookupDictionaryItem('Cancellation Remarks :',Default) else ''
End,
"Reason for Cancellation" = Remarks,
"Document Reference ID" = Docreference,
"Document Type" = DocSerialType,
"Account Number" = (Select Account_Number from Bank where Bank.BankID = Collections.BankID),
"Transaction Code" = Memo,
"Holder Name" = CardHolder,
"CreditCard No" = CreditCardNumber,
"Expiry Date" = (Case PaymentMode When 3 Then SubString(CONVERT(nVarChar(10),ChequeDate,103),4,10) Else '' End),
"Credit Card" = (Case PaymentMode When 3 Then IsNULL(PaymentMode.Value,N'') End),
"Bank Account" = (Case PaymentMode When 3 Then IsNULL((Select IsNULL(Bank.Account_Number + N' - ' + ccAccBankMaster.BankName,N'') BankAccount 
 from Bank,BankMaster ccAccBankMaster Where Bank.BankCode = ccAccBankMaster.BankCode And Bank.BankID = Collections.BankID),N'') End),
"Issuing Bank" = IsNULL(ccIssuedBank.BankName,N''),
"Service Charge%" = (Case When PaymentMode In (3,5) Then (Case IsNULL(Collections.Value,0) 
 When 0 Then 0 Else ((IsNULL(CustomerServiceCharge,0) * 100) / Collections.Value) End) End),
"Service Charge" = (Case When PaymentMode In (3,5) Then IsNULL(CustomerServiceCharge,0) End),
"Total Charge" = (Case When PaymentMode In (3,5) Then Collections.Value + IsNULL(CustomerServiceCharge,0) End),
"Coupon" = (Case PaymentMode When 5 Then IsNULL(PaymentMode.Value,N'') End)
from 
Collections
Left Join BankMaster on Collections.BankCode = BankMaster.BankCode
Left Join BranchMaster on Collections.BranchCode = BranchMaster.BranchCode
Left Join AccountsMaster on Collections.Others = AccountsMaster.Accountid 
Left Join BankMaster ccIssuedBank on IsNULL(Collections.ChequeDetails,N'') = ccIssuedBank.BankCode
Left Join PaymentMode on Collections.PaymentModeID = PaymentMode.Mode

--Collections,BankMaster,BranchMaster,AccountsMaster,
--PaymentMode,BankMaster ccIssuedBank 
Where Collections.DocumentID = @CollectionID 
--And        
--Collections.BankCode *= BankMaster.BankCode And        
--Collections.BranchCode *= BranchMaster.BranchCode        
--And Collections.Others *= AccountsMaster.Accountid    
--And IsNULL(Collections.ChequeDetails,N'') *= ccIssuedBank.BankCode
--And Collections.PaymentModeID *= PaymentMode.Mode
