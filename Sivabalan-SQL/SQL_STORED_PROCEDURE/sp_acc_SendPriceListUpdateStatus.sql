CREATE Procedure sp_acc_SendPriceListUpdateStatus(@DocumentID As Int)
As
Update SendPriceList Set 
Status = (IsNull(Status, 0) | 32) 
Where DocumentID = @DocumentID

