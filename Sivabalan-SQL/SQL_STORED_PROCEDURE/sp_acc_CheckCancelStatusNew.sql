CREATE Procedure sp_acc_CheckCancelStatusNew(@ContraID Int)          
As          
Select IsNULL(Collections.DepositID,0) from ContraDetail,Collections,Deposits          
Where ContraDetail.ContraID = @ContraID          
And ContraDetail.DocumentReference = Collections.DocumentID          
And Collections.DepositID=Deposits.DepositID And (IsNULL(Deposits.Status,0) & 192)= 0   
And (IsNULL(Collections.Status,0) & 192)= 0 And DocumentType = 2 /*Collections Table*/
