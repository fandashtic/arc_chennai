CREATE Procedure sp_acc_Insert_ReceivedPriceListAbstract(@PriceListDate DateTime, @SendDocID Int, 
@PriceListName nVarChar(255), @PriceListDesc nVarChar(255), @SentBy nVarChar(50), @Status Int)
As
Insert Into ReceivePriceListAbstract (PriceListDate, SendDocID, PriceListName, PriceListDesc, SentBy, Status, CreationDate)
Values (@PriceListDate, @SendDocID, @PriceListName, @PriceListDesc, @SentBy, @Status, GetDate())
Select @@Identity

