CREATE Procedure sp_acc_GetCollectionBankInfo (@CollectionID INT)  
As   
Select Account_Number,Memo from Collections, Bank  
Where Collections.BankID = Bank.BankID  
And Collections.DocumentID = @CollectionID 
