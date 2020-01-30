
CREATE PROCEDURE mERP_sp_update_RecdInvoice_Stock(@RecedInvID Int,@ItemOrder Int,@ItemCode nVarChar(30),@REQUIRED_QUANTITY Decimal(18,6))
AS
Declare @UOM Int
Declare @Batch nVarChar(100)
Declare @PKD DateTime
Declare @PTS Decimal(18,6)
Declare @TaxCode Decimal(18,6)
Declare @TaxApplicableOn Int
Declare @TaxPartOff Int

Declare @Result Int
Declare @TOTAL_QUANTITY Decimal(18,6)
Declare @PendingQty Decimal(18,6)
Declare @ListItemOrder Int

Declare @Forum_Code nvarchar(20)
Select @Forum_Code = Alias From Items Where Product_Code = @ItemCode

Select @UOM = UOM, @Batch = Batch_Number, @PKD = PKD, @PTS = SalePrice,
@TaxCode = TaxCode, @TaxApplicableOn = TaxApplicableOn, @TaxPartOff = TaxPartOff
From InvoiceDetailReceived
Where InvoiceID = @RecedInvID And ItemOrder = @ItemOrder And Product_Code = @ItemCode

Select @TOTAL_QUANTITY = Sum(Pending) From InvoiceDetailReceived IRDet, Items I
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
And IRDet.Product_Code = I.Product_Code
Group By IRDet.Product_Code, IRDet.Batch_Number, IRDet.PKD, 
IRDet.SalePrice, IRDet.UOM, IRDet.TaxCode, IRDet.TaxApplicableOn, IRDet.TaxPartOff

Declare LessPending Cursor For Select ItemOrder, Pending From InvoiceDetailReceived IRDet, Items I
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
And IRDet.Product_Code = I.Product_Code
Group By IRDet.Product_Code, IRDet.Batch_Number, IRDet.PKD, 
IRDet.SalePrice, IRDet.UOM, IRDet.TaxCode, IRDet.TaxApplicableOn, IRDet.TaxPartOff,ItemOrder,Pending

If IsNull(@TOTAL_QUANTITY,0) < IsNull(@REQUIRED_QUANTITY,0)
Begin
Set @Result = 0
GOTO Result
End

Open LessPending
Fetch From LessPending Into @ListItemOrder , @PendingQty

While @@Fetch_Status = 0
Begin
	If @PendingQty >=  @REQUIRED_QUANTITY
	Begin
		Update InvoiceDetailReceived Set Pending = Pending - @REQUIRED_QUANTITY Where ItemOrder = @ListItemOrder
		Set @Result = 1
		GoTo Result
	End
	Else
	Begin
		Update InvoiceDetailReceived Set Pending = 0 Where ItemOrder = @ListItemOrder
		Set @REQUIRED_QUANTITY = @REQUIRED_QUANTITY - @PendingQty
	End
	Fetch Next From LessPending Into @ListItemOrder , @PendingQty
End

If IsNull(@REQUIRED_QUANTITY,0) > 0
	Set @Result = 0
Else
	Set @Result = 1

Result:


Close LessPending
Deallocate LessPending

Select @Result

