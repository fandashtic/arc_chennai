CREATE Procedure sp_acc_SendPriceListAbstract(@DocumentID As Int)
As
Select PriceListDate, PriceList.PriceListName, Description 
From SendPriceList, PriceList Where SendPriceList.DocumentID = @DocumentID
And SendPriceList.PriceListID = PriceList.PriceListID
