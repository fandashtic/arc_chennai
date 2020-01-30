CREATE Procedure sp_acc_rpt_list_Paymentdetail(@PaymentID integer)  
As  
If (Select IsNULL(ExpenseAccount,0) from Payments Where DocumentID = @PaymentID) <> 0      
Begin  
 If (Select IsNULL(AccountMode,0) from Payments Where DocumentID = @PaymentID) = 0      
 Begin  
  Select @PaymentID,AccountsMaster.AccountName As "Account Name", Value As "Amount"  
  from Payments,AccountsMaster  
  Where Payments.DocumentID = @PaymentID  
  And Payments.ExpenseAccount = AccountsMaster.AccountID  
 End  
 Else  
 Begin  
  Select @PaymentID,AccountsMaster.AccountName As "Account Name" , Amount as "Amount"  
  from PaymentExpense,AccountsMaster  
  Where PaymentExpense.PaymentID = @PaymentID  
  And PaymentExpense.AccountID = AccountsMaster.AccountID  
 End  
End  
Else  
Begin   
 select "Document ID" = PaymentDetail.OriginalID,  
 "Document ID" = PaymentDetail.OriginalID,  
 "Date" = PaymentDetail.DocumentDate,  
 "Type" =   
 Case When VendorID Is Not NULL Then  
  Case DocumentType  
   When 1 Then  
    dbo.LookupDictionaryItem('Purchase Return Stock Adjustment',Default)  
   When 2 Then  
    dbo.LookupDictionaryItem('Debit Note',Default)  
   When 3 Then  
    dbo.LookupDictionaryItem('Payments',Default)  
   When 4 Then  
    dbo.LookupDictionaryItem('Purchase',Default)  
   When 5 Then  
    dbo.LookupDictionaryItem('Credit Note',Default)  
  End  
 Else  
  Case DocumentType  
   When 2 Then  
    dbo.LookupDictionaryItem('Credit Note',Default)  
   When 3 Then  
    dbo.LookupDictionaryItem('Payments',Default)  
   When 4 Then  
    dbo.LookupDictionaryItem('APV',Default)  
   When 5 Then  
    dbo.LookupDictionaryItem('Debit Note',Default)  
   When 6 Then  
    dbo.LookupDictionaryItem('ARV',Default)  
   When 7 Then  
    dbo.LookupDictionaryItem('Collections',Default)  
   When 8 Then  
    dbo.LookupDictionaryItem('Manual Journal',Default)  
  End  
 End,  
 "Doc Ref" = PaymentDetail.DocumentReference,  
 "Document Value" = PaymentDetail.DocumentValue,  
 "Adj Amount" =  
 Case When VendorID Is Not NULL Then  
  Case DocumentType  
   When 1 Then  
    '-'  
   When 2 Then  
    '-'  
   When 3 Then  
    '-'  
   When 4 Then  
    '+'  
   When 5 Then  
    '+'  
  End  
 Else  
  Case DocumentType  
   When 2 Then  
    '+'  
   When 3 Then  
    '-'  
   When 4 Then  
    '+'  
   When 5 Then  
    '-'  
   When 6 Then  
    '-'  
   When 7 Then  
    '+'  
   When 8 Then  
    '-'  
  End  
 End  
 + CAST(PaymentDetail.AdjustedAmount as nvarchar)  
 from PaymentDetail,Payments  
 where PaymentID = @PaymentID   
 And PaymentDetail.PaymentID = Payments.DocumentID  
 And PaymentDetail.Others Is NULL  
End  


