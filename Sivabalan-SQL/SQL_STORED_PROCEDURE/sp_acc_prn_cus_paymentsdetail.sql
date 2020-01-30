CREATE Procedure sp_acc_prn_cus_paymentsdetail (@PaymentID int)    
As    
If (Select IsNULL(ExpenseAccount,0) from Payments Where DocumentID = @PaymentID) <> 0  
 Begin  
  If (Select IsNULL(AccountMode,0) from Payments Where DocumentID = @PaymentID) = 1  
   Begin    
    Select 'Document Type/Expense Account' = AccountName,
    'Document ID' = NULL,'Document Date' = NULL,'Document Value' = NULL,
    'Amount Adjusted/Amount' = Amount,'Extra Collection' = NULL
    from PaymentExpense,AccountsMaster
    Where PaymentExpense.AccountID = AccountsMaster.AccountID      
    And PaymentExpense.PaymentID = @PaymentID      
   End    
  Else    
   Begin    
    Select 'Document Type/Expense Account' = AccountName,
    'Document ID' = NULL,'Document Date' = NULL,'Document Value' = NULL,
    'Amount Adjusted/Amount' = Value,'Extra Collection' = NULL
    from Payments,AccountsMaster    
    Where Payments.ExpenseAccount = AccountsMaster.AccountID    
    And Payments.DocumentID = @PaymentID    
   End    
 End  
Else  
 Begin  
  Select     
  "Document Type/Expense Account" =    
  Case    
   when DocumentType = 1 then dbo.LookupDictionaryItem('Purchase Return',Default)    
   when DocumentType = 2 then dbo.LookupDictionaryItem('Credit Note',Default)    
   when DocumentType = 3 then dbo.LookupDictionaryItem('Payments',Default)    
   when DocumentType = 4 then dbo.LookupDictionaryItem('APV',Default)    
   when DocumentType = 5 then dbo.LookupDictionaryItem('Debit Note',Default)    
   when DocumentType = 6 then dbo.LookupDictionaryItem('ARV',Default)    
   when DocumentType = 7 then dbo.LookupDictionaryItem('Collections',Default)    
   when DocumentType In (8,9) then dbo.LookupDictionaryItem('Manual Journal',Default)    
  End,    
  "Document ID" = OriginalID,    
  "Document Date" = DocumentDate,    
  "Document Value" = DocumentValue,    
  "Amount Adjusted/Amount" = AdjustedAmount,    
  "Extra Collection" = ExtraCol    
  from PaymentDetail Where    
  PaymentDetail.PaymentID = @PaymentID    
 End  
