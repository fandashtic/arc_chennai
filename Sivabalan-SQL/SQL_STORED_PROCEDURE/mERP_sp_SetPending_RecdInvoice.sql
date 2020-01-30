CREATE PROCEDURE mERP_sp_SetPending_RecdInvoice(@GRNID Int , @RecdInvID Int)
AS
Declare @UOM Int
Declare @Batch nVarChar(100)
Declare @PKD DateTime
Declare @PTS Decimal(18,6)
Declare @TaxCode Decimal(18,6)
Declare @TaxApplicableOn Int
Declare @TaxPartOff Int

Declare @ItemOrder Int
Declare @RecQty Decimal(18,6)
Declare @ItemCode nVarChar(30)
Declare @Forum_Code nvarchar(20)

Declare @InvItemOrder Int
Declare @InvQty Decimal(18,6)

Declare PendingUpdate Cursor For Select Product_Code, QuantityReceived , ReceInvItemOrder from Batch_Products 
Where GRN_ID = @GRNID And IsNull(QuantityReceived,0) > 0

Open PendingUpdate
Fetch From PendingUpdate Into @ItemCode, @RecQty, @ItemOrder

While @@Fetch_Status = 0
Begin

	Select @Forum_Code = Alias From Items Where Product_Code = @ItemCode

	Select @UOM = UOM, @Batch = Batch_Number, @PKD = PKD, @PTS = SalePrice,
	@TaxCode = TaxCode, @TaxApplicableOn = TaxApplicableOn, @TaxPartOff = TaxPartOff
	From InvoiceDetailReceived
	Where InvoiceID = @RecdInvID And ItemOrder = @ItemOrder And Product_Code = @ItemCode


	Declare PendingQty Cursor For Select ItemOrder, Quantity From InvoiceDetailReceived IRDet, Items I
	Where IRDet.InvoiceID = @RecdInvID
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
	IRDet.SalePrice, IRDet.UOM, IRDet.TaxCode, IRDet.TaxApplicableOn, IRDet.TaxPartOff,ItemOrder,Quantity

	Open PendingQty
	Fetch From PendingQty Into @InvItemOrder , @InvQty

	While @@Fetch_Status = 0
	Begin
		If @InvQty >=  @RecQty
		Begin
			Update InvoiceDetailReceived Set Pending = Pending + @RecQty Where ItemOrder = @InvItemOrder
			GoTo NextRow
		End
		Else
		Begin
			Update InvoiceDetailReceived Set Pending = @InvQty Where ItemOrder = @InvItemOrder
			Set @RecQty = @RecQty - @InvQty
		End
		Fetch Next From PendingQty Into @InvItemOrder , @InvQty
	End

NextRow:

	Close PendingQty
	Deallocate PendingQty



	Fetch Next From PendingUpdate Into @ItemCode, @RecQty, @ItemOrder
End
Close PendingUpdate
DeAllocate PendingUpdate

Update InvoiceAbstractReceived Set Status = 32 where InvoiceID = @RecdInvID

