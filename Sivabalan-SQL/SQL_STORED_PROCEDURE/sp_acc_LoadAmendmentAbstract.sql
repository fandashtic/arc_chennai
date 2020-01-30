CREATE procedure sp_acc_LoadAmendmentAbstract(@DocumentID Integer)    
as    
Declare @AccountNo nVarchar(64)    
Declare @BankID Int    
Declare @ChequeBookName nVarchar(50)    
Declare @ChequeID Int    
    
Select @BankID = BankID, @ChequeID = Cheque_ID from Payments Where DocumentID = @DocumentID    
Select @AccountNo = Account_Number from Bank where [BankID]= @BankID    
Select @ChequeBookName = Cheque_Book_Name from Cheques where ChequeID =@ChequeID    
    
Select 'Party' = dbo.getaccountname(isnull(payments.Others,0)),'PartyID' = isnull(Payments.Others,0),    
Payments.DocumentID,Payments.DocumentDate,Payments.FullDocID,Payments.PaymentMode,    
'ExpenseAccount' = dbo.getaccountname(isnull(Payments.expenseaccount,0)),    
'Expenseid' = Expenseaccount,Payments.Value,'BankID' = isnull([Payments].[BankID],0),    
'AccountNo' = @AccountNo,'ChequeNo' = isnull(Cheque_Number,0),'ChequeDate' = Cheque_Date,    
'BankCode' = isnull([Payments].[BankCode],0),'BranchCode' = isnull(BranchCode,0),    
Denominations,'ChequeID' = isnull(Cheque_ID,0),'ChequeBookName' = @ChequeBookName,    
'Status' = isnull(Payments.Status,0),DDMode,'DDPayableAt' = DDDetails,    
DDCharges,DDChequeDate,'DDChequeNo' = DDChequeNumber,PayableTo,DocSerialType,DocRef,Narration,
'Bank_Txn_code' = Isnull(Memo,N'')
from Payments where Payments.DocumentID = @DocumentID 

