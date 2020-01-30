CREATE PRocedure sp_acc_UpdateCollectionBankInfo (@CollectionID INT,   
                         @ToBankID INT, @BankReference nVarChar(400))  
As  
Update Collections Set   
BankID = @ToBankID,  
Memo = @BankReference  
Where DocumentID = @CollectionID
