CREATE PROCEDURE mERP_sp_Get_RecdInvQtyState
(
@RecedInvID Int,
@ItemCode as nVarChar(50),
@ItemOrder as Int)
As
Declare @UOM Int
Declare @Batch nVarChar(100)
Declare @PKD DateTime
Declare @PTS Decimal(18,6)
Declare @TaxCode Decimal(18,6)
Declare @TaxApplicableOn Int
Declare @TaxPartOff Int

Declare @Forum_Code nvarchar(20)
Select @Forum_Code = Alias From Items Where Product_Code = @ItemCode


Select @UOM = UOM, @Batch = Batch_Number, @PKD = PKD, @PTS = SalePrice,
@TaxCode = TaxCode, @TaxApplicableOn = TaxApplicableOn, @TaxPartOff = TaxPartOff
From InvoiceDetailReceived
Where InvoiceID = @RecedInvID And ItemOrder = @ItemOrder And Product_Code = @ItemCode

Select 
"InvoiceQty" = Sum(Case When IRDet.SalePrice = 0 Then 0 Else IRDet.Quantity End),
"InvoiceFree" = Sum(Case When IRDet.SalePrice = 0 Then IRDet.Quantity Else 0 End),
"PendingQty" = Sum(Case When IRDet.SalePrice = 0 Then 0 Else IRDet.Pending End),
"PendingFree" = Sum(Case When IRDet.SalePrice = 0 Then IRDet.Pending Else 0 End)
From InvoiceDetailReceived IRDet
Where IRDet.InvoiceID = @RecedInvID
And IRDet.ForumCode = @Forum_Code
And IRDet.UOM = @UOM
And IRDet.Batch_Number = @Batch
And IRDet.SalePrice = @PTS
And IRDet.ItemOrder >= @ItemOrder
And IsNull(Month(IRDet.PKD),0) = IsNull(Month(@PKD),0) and IsNull(Year(IRDet.PKD),0) = IsNull(Year(@PKD),0)
And IRDet.TaxCode = @TaxCode
And IRDet.TaxApplicableOn = @TaxApplicableOn
And IRDet.TaxPartOff = @TaxPartOff
Group By IRDet.Product_Code, IRDet.Batch_Number, IRDet.PKD, 
IRDet.SalePrice, IRDet.UOM, IRDet.TaxCode, IRDet.TaxApplicableOn, IRDet.TaxPartOff
