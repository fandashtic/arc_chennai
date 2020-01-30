CREATE procedure sp_acc_UpdateTransactionSerial      
(@TranType int,@DocType nVarchar(100),@IsSerial Int=0,@CollectionID Int)      
As        
If (@IsSerial = 1)      
 Begin      
   UPDATE TransactionDocNumber SET LastCount = LastCount + 1 WHERE TransactionType = @Trantype And DocumentType = @DOCTYPE      
 End      

