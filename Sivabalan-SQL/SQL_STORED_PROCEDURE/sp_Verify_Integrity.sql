CREATE Procedure sp_Verify_Integrity   (@ItemCode nVarchar(20),
					@VerifyDate Datetime,
					@Deviation Decimal(18,6))
As
Declare @Msg nvarchar(50)
Declare @StartDate Datetime
Declare @EndDate Datetime
--Variables for Quantity
Declare @Purchase Decimal(18,6)
Declare @Opening Decimal(18,6)
Declare @DOpening Decimal(18,6)
Declare @SalesReturnSaleable Decimal(18,6)
Declare @SalesReturnDamages Decimal(18,6)
Declare @Issues Decimal(18,6)
Declare @RIssues Decimal(18,6)
Declare @PurchaseReturn Decimal(18,6)
Declare @StkTfrIn Decimal(18,6)
Declare @StkTfrOut Decimal(18,6)
Declare @SADamages Decimal(18,6)
Declare @SAOthers Decimal(18,6)
Declare @DSAOthers Decimal(18,6)
Declare @Closing Decimal(18,6)
Declare @DClosing Decimal(18,6)
Declare @VanStock Decimal(18,6)
Declare @BatchStock Decimal(18,6)
Declare @ComputedStock Decimal(18,6)
Declare @DComputedStock Decimal(18,6)
Declare @NextDate Datetime
--Variables for Value
Declare @OpeningValue Decimal(18,6)
Declare @DOpeningValue Decimal(18,6)
Declare @OpeningRate Decimal(18,6)
Declare @DOpeningRate Decimal(18,6)
Declare @ClosingValue Decimal(18,6)
Declare @DClosingValue Decimal(18,6)
Declare @ClosingRate Decimal(18,6)
Declare @DClosingRate Decimal(18,6)
Declare @BatchStockValue Decimal(18,6)
Declare @VanStockValue Decimal(18,6)
Declare @OpeningQty Decimal(18,6)
Declare @DOpeningQty Decimal(18,6)
Declare @ClosingQty Decimal(18,6)
Declare @DClosingQty Decimal(18,6)
Declare @BatchStockQty Decimal(18,6)
Declare @VanStockQty Decimal(18,6)

Set @StartDate = dbo.StripDateFromTime(@VerifyDate)

While dbo.StripDateFromTime(@StartDate) <= dbo.StripDateFromTime(GetDate()) 
Begin
	Set @EndDate = dbo.MakeDayEnd(@StartDate)
	If dbo.StripDateFromTime(@StartDate) <> dbo.StripDateFromTime(GetDate())
	Begin
		Set @NextDate = DateAdd(d, 1, @StartDate)

		Select @Closing = IsNull(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0),
		@ClosingQty = IsNull(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0) - IsNull(Free_Saleable_Quantity, 0), 
		@ClosingValue = IsNull(Opening_Value, 0) - IsNull(Damage_Opening_Value, 0),
		@DClosing = IsNull(Damage_Opening_Quantity, 0),
		@DClosingQty = IsNull(Damage_Opening_Quantity, 0) + IsNull(Free_Saleable_Quantity, 0) - IsNull(Free_Opening_Quantity, 0),
		@DClosingValue = IsNull(Damage_Opening_Value, 0)
		From OpeningDetails
		Where dbo.StripDateFromTime(OpeningDetails.Opening_Date) = dbo.StripDateFromTime(@NextDate) And
		OpeningDetails.Product_Code = @ItemCode	
	End
	Else
	Begin
		Select @BatchStock = IsNull(Sum(Quantity),0),
		@BatchStockQty = IsNull(Sum(Case IsNull(Free, 0) When 0 Then Quantity Else 0 End),0), 
		@BatchStockValue = IsNull(Sum(Quantity * PurchasePrice), 0)
		From Batch_Products
		Where Product_Code = @ItemCode And
		IsNull(Damage, 0) = 0
	
		Select @VanStock = IsNull(Sum(Pending), 0),
		@VanStockQty = IsNull(Sum(Case PurchasePrice When 0 Then 0 Else Pending End), 0), 
		@VanStockValue = IsNull(Sum(Pending * IsNull(PurchasePrice, 0)), 0)
		From VanStatementDetail, VanStatementAbstract
		Where VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial And
		VanStatementAbstract.Status & 128 = 0 And
		VanStatementDetail.Product_Code = @ItemCode
	
		Set @Closing = IsNull(@BatchStock, 0) + IsNull(@VanStock, 0)
		Set @ClosingQty = IsNull(@BatchStockQty, 0) + IsNull(@VanStockQty, 0)
		Set @ClosingValue = IsNull(@BatchStockValue, 0) + IsNull(@VanStockValue, 0)
		
		Select @DClosing = IsNull(Sum(Quantity),0),
		@DClosingQty = IsNull(Sum(Case IsNull(Free, 0) When 0 Then Quantity Else 0 End),0), 
		@DClosingValue = IsNull(Sum(Quantity * PurchasePrice), 0)
		From Batch_Products
		Where Product_Code = @ItemCode And
		IsNull(Damage, 0) > 0
	End		
	Select @Opening = IsNull(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0),
	@OpeningQty = IsNull(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0) - IsNull(Free_Saleable_Quantity, 0), 
	@OpeningValue = IsNull(Opening_Value, 0) - IsNull(Damage_Opening_Value, 0),
	@DOpening = IsNull(Damage_Opening_Quantity, 0),
	@DOpeningQty = IsNull(Damage_Opening_Quantity, 0) + IsNull(Free_Saleable_Quantity, 0) - IsNull(Free_Opening_Quantity, 0),
	@DOpeningValue = IsNull(Damage_Opening_Value, 0)
	From OpeningDetails
	Where OpeningDetails.Opening_Date = @StartDate And
	OpeningDetails.Product_Code = @ItemCode
	
	Select @Purchase = Sum((QuantityReceived - QuantityRejected) + IsNull(FreeQty, 0))
	From GRNAbstract, GRNDetail
	Where GRNAbstract.GRNID = GRNDetail.GRNID And
	GRNDetail.Product_Code = @ItemCode And
	GRNAbstract.GRNDate Between @StartDate And @EndDate And
	IsNull(GRNAbstract.GRNStatus, 0) & 64 = 0
	
	Select @SalesReturnSaleable = Sum(Quantity) 
	From InvoiceDetail, InvoiceAbstract
	Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
	InvoiceAbstract.InvoiceType = 4 And
	InvoiceAbstract.Status & 128 = 0 And
	InvoiceDetail.Product_Code = @ItemCode And
	InvoiceAbstract.Status & 32 = 0 And
	InvoiceAbstract.InvoiceDate Between @StartDate And @EndDate
	
	Select @SalesReturnDamages = Sum(Quantity) 
	From InvoiceDetail, InvoiceAbstract
	Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
	InvoiceAbstract.InvoiceType = 4 And
	InvoiceAbstract.Status & 128 = 0 And
	InvoiceDetail.Product_Code = @ItemCode And
	InvoiceAbstract.Status & 32 <> 0 And
	InvoiceAbstract.InvoiceDate Between @StartDate And @EndDate
	
	Select @RIssues = Sum(Quantity)
	From InvoiceAbstract, InvoiceDetail
	Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
	InvoiceAbstract.InvoiceType = 2 And
	InvoiceAbstract.Status & 128 = 0 And
	InvoiceDetail.Product_Code = @ItemCode And
	InvoiceAbstract.InvoiceDate Between @StartDate And @EndDate
	
	Select @Issues = Sum(Quantity)
	From DispatchAbstract, DispatchDetail
	Where DispatchAbstract.DispatchID = DispatchDetail.DispatchID And
	DispatchAbstract.Status & 64 = 0 And
	DispatchAbstract.DispatchDate Between @StartDate And @EndDate And
	DispatchDetail.Product_Code = @ItemCode 
	
	Select @PurchaseReturn = Sum(Quantity)
	From AdjustmentReturnDetail, AdjustmentReturnAbstract
	Where AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID And
	AdjustmentReturnDetail.Product_Code = @ItemCode And
	AdjustmentReturnAbstract.AdjustmentDate Between @StartDate And @EndDate And
	IsNull(AdjustmentReturnAbstract.Status,0) & 64 = 0
	
	Select @StkTfrIn = Sum(Quantity)
	From StockTransferInAbstract, StockTransferInDetail
	Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial And
	StockTransferInAbstract.DocumentDate Between @StartDate And @EndDate And
	StockTransferInDetail.Product_Code = @ItemCode

	Select @StkTfrOut = Sum(Quantity)
	From StockTransferOutAbstract, StockTransferOutDetail
	Where StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial And
	StockTransferOutAbstract.DocumentDate Between @StartDate And @EndDate And
	StockTransferOutDetail.Product_Code = @ItemCode
	
	Select @SADamages = Sum(Quantity)
	From StockAdjustment, StockAdjustmentAbstract
	Where StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID And
	StockAdjustmentAbstract.AdjustmentDate Between @StartDate And @EndDate And
	StockAdjustment.Product_Code = @ItemCode And
	IsNull(StockAdjustmentAbstract.AdjustmentType, 0) = 0
	
	Select @SAOthers = Sum(StockAdjustment.Quantity - OldQty)
	From StockAdjustment, StockAdjustmentAbstract, Batch_Products
	Where StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID And
	StockAdjustmentAbstract.AdjustmentDate Between @StartDate And @EndDate And
	StockAdjustment.Product_Code = @ItemCode And
	IsNull(StockAdjustmentAbstract.AdjustmentType, 0) = 1 And
	StockAdjustment.Batch_Code = Batch_Products.Batch_Code And
	IsNull(Batch_Products.Damage, 0) = 0
	
	Select @DSAOthers = Sum(StockAdjustment.Quantity - OldQty)
	From StockAdjustment, StockAdjustmentAbstract, Batch_Products
	Where StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID And
	StockAdjustmentAbstract.AdjustmentDate Between @StartDate And @EndDate And
	StockAdjustment.Product_Code = @ItemCode And
	IsNull(StockAdjustmentAbstract.AdjustmentType, 0) = 1 And
	StockAdjustment.Batch_Code = Batch_Products.Batch_Code And
	IsNull(Batch_Products.Damage, 0) > 0
	
	Set @ComputedStock = IsNull(@Opening, 0) + IsNull(@Purchase, 0) + IsNull(@SalesReturnSaleable, 0) 
	- IsNull(@RIssues, 0) - IsNull(@Issues, 0) - IsNull(@PurchaseReturn, 0) 
	+ IsNull(@StkTfrIn, 0) - IsNull(@StkTfrOut, 0) - IsNull(@SADamages, 0) 
	+ IsNull(@SAOthers, 0)

	Set @DComputedStock = IsNull(@DOpening, 0) + IsNull(@SalesReturnDamages, 0)
	+ IsNull(@DSAOthers, 0) + IsNull(@SADamages, 0)

	Set @OpeningRate = @OpeningValue / (Case @OpeningQty When 0 Then 1 Else @OpeningQty End)
	Set @DOpeningRate = @DOpeningValue / (Case @DOpeningQty When 0 Then 1 Else @DOpeningQty End)
	Set @ClosingRate = @ClosingValue / (Case @ClosingQty When 0 Then 1 Else @ClosingQty End)
	Set @DClosingRate = @DClosingValue / (Case @DClosingQty When 0 Then 1 Else @DClosingQty End)

	If @ComputedStock <> @Closing
	Begin
		Select 0, @StartDate, @ComputedStock, @Closing, 1
		Goto OvernOut
	End
	
	If @DComputedStock <> @DClosing
	Begin
		Select 0, @StartDate, @DComputedStock, @DClosing, 0
		Goto OvernOut
	End

-- 	If @OpeningQty <> 0 And @ClosingQty <> 0
-- 	Begin
-- 	If ABS(@ClosingRate - @OpeningRate) > @Deviation 
-- 	Begin
-- 		Select 0, @StartDate, "Opening Rate" = @OpeningRate, "Closing Rate" = @ClosingRate, 3
-- 		Goto OvernOut
-- 	End
-- 	End
-- 
-- 	If @DOpeningQty <> 0 And @DClosingQty <> 0
-- 	Begin
-- 	If ABS(@DClosingRate - @DOpeningRate) > @Deviation 
-- 	Begin
-- 		Select 0, @StartDate, @DOpeningRate, @DClosingRate, 4
-- 		Goto OvernOut
-- 	End
-- 	End

	Set @StartDate = DateAdd(d, 1, @StartDate)
End
Select 1
OvernOut:
