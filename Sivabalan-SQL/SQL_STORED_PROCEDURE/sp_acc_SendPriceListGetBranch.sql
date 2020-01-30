CREATE Procedure sp_acc_SendPriceListGetBranch(@DocumentID As Int)
AS
DECLARE @PriceListFor Int
Select @PriceListFor = PriceListFor from SendPriceList Where DocumentID = @DocumentID

If @PriceListFor = 0 /*Customer*/
 Begin
  Select AlternateCode from Customer, SendPriceListBranch 
  Where SendPriceListBranch.BranchID = Customer.CustomerID
  And SendPriceListBranch.DocumentID = @DocumentID
 End
Else If @PriceListFor = 1 /*Branch Office*/
 Begin
  Select ForumID from WareHouse, SendPriceListBranch 
  Where SendPriceListBranch.BranchID = WareHouse.WareHouseID
  And SendPriceListBranch.DocumentID = @DocumentID
 End

