CREATE Procedure sp_acc_InsertDepositsDetail(@DepositID Int,@CollectionID Int)  
As    
Insert Into DepositsDetail(DepositID, CollectionID)    
Values (@DepositID,@CollectionID) 
