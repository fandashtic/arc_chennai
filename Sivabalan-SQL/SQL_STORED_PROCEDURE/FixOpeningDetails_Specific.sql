CREATE PROCEDURE FixOpeningDetails_Specific (
@ITEMCODE nvarchar(15), 
@FromDate DateTime = Null
)
AS  
DECLARE @FirstTransactionDate Datetime
DECLARE @ToDate Datetime
DECLARE @ServerDate Datetime
DECLARE @OpeningQuantity Decimal(18,6)
DECLARE @OpeningValue Decimal(18,6)  
DECLARE @FreeOpening Decimal(18,6)  
DECLARE @DamageOpeningQty Decimal(18,6)  
DECLARE @DamageOpeningValue Decimal(18,6)  
DECLARE @FreeSaleable Decimal(18,6)  
DECLARE @NewOpeningQuantity Decimal(18,6)  
DECLARE @NewOpeningValue Decimal(18,6)  
DECLARE @NewFreeOpening Decimal(18,6)  
DECLARE @NewDamageOpeningQty Decimal(18,6)  
DECLARE @NewDamageOpeningValue Decimal(18,6)  
DECLARE @NewFreeSaleable Decimal(18,6)  
DECLARE @Purchases Decimal(18,6)  
DECLARE @FreePurchases Decimal(18,6)  
DECLARE @PurchaseValue Decimal(18,6)  
DECLARE @SalesReturnSaleable Decimal(18,6)  
DECLARE @SalesReturnFreeDamages Decimal(18,6)
DECLARE @SalesReturnDamages Decimal(18,6)  
DECLARE @SalesReturnValue Decimal(18,6)  
DECLARE @SalesReturnDamagesValue Decimal(18,6)  
DECLARE @FreeReturns Decimal(18,6)  
DECLARE @Issues Decimal(18,6)  
DECLARE @FreeIssues Decimal(18,6)  
DECLARE @SalesValue Decimal(18,6)  
DECLARE @StockTransferIn Decimal(18,6)  
DECLARE @FreeStockTransferIn Decimal(18,6)  
DECLARE @StockTransferInValue Decimal(18,6)  
DECLARE @StockTransferOut Decimal(18,6)  
DECLARE @FreeStockTransferOut Decimal(18,6)  
DECLARE @StockTransferOutValue Decimal(18,6)  
DECLARE @AdjustmentOthers Decimal(18,6)  
DECLARE @AdjustmentFreeDamages Decimal(18,6)  
DECLARE @AdjustmentDamages Decimal(18,6)  
DECLARE @AdjustmentDamagesValue Decimal(18,6)  
DECLARE @AdjustmentFree Decimal(18,6)  
DECLARE @AdjustmentFreeSaleable Decimal(18,6)  
DECLARE @AdjustmentValue Decimal(18,6)  
DECLARE @PurchaseReturn Decimal(18,6)  
DECLARE @PurchaseReturnDamages Decimal(18,6)  
DECLARE @PurchaseReturnFree Decimal(18,6)  
DECLARE @PurchaseReturnValue Decimal(18,6)  
DECLARE @PurchaseReturnDamagesValue Decimal(18,6)  
DECLARE @Saleable Decimal(18,6)  
DECLARE @ActualQuantity Decimal(18,6)  
DECLARE @ActualFree Decimal(18,6)  
DECLARE @ActualDamagesSaleable Decimal(18,6)  
DECLARE @DamagesFree Decimal(18,6)  
DECLARE @DamagesSaleable Decimal(18,6)  
DECLARE @AdjustmentDamagesOthers Decimal(18,6)  
DECLARE @AdjustmentDamagesOthersValue Decimal(18,6)  

DECLARE @StockDestructQty Decimal(18,6)
DECLARE @StockDestructValue Decimal(18,6)
DECLARE @FreeStockDestructQty Decimal(18,6)
DECLARE @FreeSaleStockDestructQty Decimal(18,6)
DECLARE @DamageStockDestructQty Decimal(18,6)
DECLARE @DamageStockDestructValue Decimal(18,6)

DECLARE @AdjReconcile Decimal(18,6)
DECLARE @AdjReconcileValue Decimal(18,6)
DECLARE @AdjReconcileFree Decimal(18,6)
DECLARE @AdjReconcileFreeSaleable Decimal(18,6)
DECLARE @AdjReconcileDamages Decimal(18,6)
DECLARE @AdjReconcileDamagesValue Decimal(18,6)

DECLARE @ConversionFreeQty1 Decimal(18,6)
DECLARE @ConversionFreeQty2 Decimal(18,6)
DECLARE @ConversionSaleableValue1 Decimal(18,6)
DECLARE @ConversionSaleableValue2 Decimal(18,6)

DECLARE @Product_Code nvarchar(15)    
DECLARE @TaxSufferedPer Decimal(18,6)    
DECLARE @CSTTaxSuffered Decimal(18,6)    

DECLARE @vanQty Decimal(18,6)
DECLARE @VanFreeQty Decimal(18,6)

-- Batch Product Updation
Declare @BPSaleableDiff Decimal(18,6)
Declare @BPFreeDiff Decimal(18,6)
Declare @BPDamageDiff Decimal(18,6)
Declare @BPFreeDamageDiff Decimal(18,6)

Declare @BatchCode Int
Declare @CurrentStcok Decimal(18,6)

Declare @ImplicitAdjUser nVarchar(50)
Declare @ImplicitBatchCode Int
Declare @ImplicitBatchNum nVarchar(128)
Declare @ImplicitAdjValue Decimal(18,6)
Declare @ImplicitAdjDocID Int

Create Table #temp(
	ItemCode nVarchar(15), OpeningDate DateTime, OpeningQuantity Decimal(18,6), NewOpeningQuantity Decimal(18,6),
	OpeningValue Decimal(18,6), NewOpeningValue Decimal(18,6), FreeOpening Decimal(18,6), NewFreeOpening Decimal(18,6), 
	DamageOpening Decimal(18,6), NewDamageOpening Decimal(18,6), DamageOpeningValue Decimal(18,6), NewDamageOpeningValue Decimal(18,6), 
	FreeSaleable Decimal(18,6),  NewFreeSaleable Decimal(18,6)
	,Purchase Decimal(18,6), FreePurchase Decimal(18,6), SalRtnSaleable Decimal(18,6), SalRtnDamage Decimal(18,6),
	Issue Decimal(18,6), FreeIssue Decimal(18,6), PurRtn Decimal(18,6), Adjusts Decimal(18,6), StkConv Decimal(18,6),
	STO Decimal(18,6), STI Decimal(18,6), Destruct Decimal(18,6)
)

--IF @FirstTransactionDate Is Null
--GOTO DateNullExit

If exists (select * from dbo.sysobjects where id = object_id(N'[OpeningDetailsBackup]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)  
Drop Table [OpeningDetailsBackup]  

If exists (select * from dbo.sysobjects where id = object_id(N'[InvoiceDetailBackup]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)  
Drop Table [InvoiceDetailBackup]  

If exists (select * from dbo.sysobjects where id = object_id(N'[Batch_ProductsBackup]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)  
Drop Table [Batch_ProductsBackup]  

Select * into OpeningDetailsBackup From OpeningDetails
Select * into InvoiceDetailBackup From InvoiceDetail
Select * into Batch_ProductsBackup From Batch_Products

Update Batch_Products 
Set Batch_Products.PurchasePrice = (Case Items.Purchased_At When 1 Then Batch_Products.PTS Else Batch_Products.PTR End)  
From Batch_Products, Items  
Where Items.Product_Code = @ITEMCODE
And Batch_Products.Product_Code = Items.Product_Code 
And IsNull(Batch_Products.PurchasePrice, 0) = 0  

--In order to update Tax Suffered Percentage day by day in OpeningDetails 
--Here we are creating a temp table for Batch_Products
If Exists (Select * From DBO.SysObjects Where Id = Object_ID(N'[Batch_Products_Temp]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)  
Drop Table [Batch_Products_Temp]  
Select * into Batch_Products_Temp From Batch_Products where Product_Code = @ITEMCODE 

Update Batch_Products_Temp Set Quantity=Case When IsNull(Doctype,0) = 6 then IsNull(QuantityReceived,0) Else 0 End

--If Batch_Code = 0 for Sold items  
Update InvoiceDetail 
Set InvoiceDetail.Batch_Code =   
(select Min(Batch_Products.Batch_Code) From Batch_Products   
Where IsNull(Batch_Products.Free,0) = 0 And IsNull(Batch_Products.Damage,0) = 0
And Batch_Products.Product_Code = InvoiceDetail.Product_Code)  
From InvoiceDetail, InvoiceAbstract  
Where (InvoiceDetail.SalePrice <> 0 or (InvoiceDetail.SalePrice = 0 And InvoiceDetail.PurchasePrice <> 0)) 
And IsNull(InvoiceDetail.Batch_Code,0) = 0 And  
(InvoiceAbstract.Status & 32) = 0 And (InvoiceAbstract.Status & 128) = 0  
And InvoiceDetail.Product_Code = @ITEMCODE
And InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
   
--If Batch_Code = 0 for Free items  
Update InvoiceDetail 
Set InvoiceDetail.Batch_Code =
(select Min(Batch_Products.Batch_Code) From Batch_Products
Where IsNull(Batch_Products.Free,0) = 1 And IsNull(Batch_Products.Damage,0) = 0
And Batch_Products.Product_Code = InvoiceDetail.Product_Code)
From InvoiceDetail, InvoiceAbstract
Where InvoiceDetail.SalePrice = 0 
And InvoiceDetail.PurchasePrice = 0 
And IsNull(InvoiceDetail.Batch_Code,0) = 0 
And (InvoiceAbstract.Status & 32) = 0 
And (InvoiceAbstract.Status & 128) = 0  
And InvoiceDetail.Product_Code = @ITEMCODE
And InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID

--If Batch_Code = 0 for Damage items  
Update InvoiceDetail 
Set InvoiceDetail.Batch_Code =   
(select Min(Batch_Products.Batch_Code) From Batch_Products   
Where IsNull(Batch_Products.Free,0) = 0 And IsNull(Batch_Products.Damage,0) > 0
And Batch_Products.Product_Code = InvoiceDetail.Product_Code)
From InvoiceDetail, InvoiceAbstract  
Where InvoiceDetail.SalePrice <> 0 
And IsNull(InvoiceDetail.Batch_Code,0) = 0 
And (InvoiceAbstract.Status & 32) <> 0 
And (InvoiceAbstract.Status & 128) = 0  
And InvoiceDetail.Product_Code = @ITEMCODE
And InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID

Select * Into #InvoiceDetail From InvoiceDetail Where Product_Code = @ITEMCODE
Select * Into #DispatchDetail From DispatchDetail Where Product_Code = @ITEMCODE

Set DateFormat DMY

Select @FirstTransactionDate = Max(dbo.StripDateFromTime(OpeningDate)) From Setup
Set @FromDate = DateAdd(d,-1,dbo.StripDateFromTime(@FromDate))

IF @FromDate Is Null  
	Select @FromDate = Max(OpeningDate) from Setup

IF @FromDate < (Select Top 1 OpeningDate from Setup)
	Select @FromDate = Max(OpeningDate) from Setup

IF @FromDate > @FirstTransactionDate
Begin
	Set @ToDate = DateAdd(s, 0 - 1, @FromDate)

	--Adding Purchase Qty in Batch_Products_Temp
	Update Batch_Products_Temp 
	Set Quantity = IsNull(Quantity, 0) + IsNull(QuantityReceived, 0)
	Where Product_Code = @ITEMCODE And GRN_ID In   
	(Select GRNAbstract.GRNID From GRNAbstract, GRNDetail   
	Where GRNDetail.Product_Code = @ITEMCODE
	And (GRNAbstract.GRNStatus & 96) = 0 
	And GRNDate Between @FirstTransactionDate AND @TODATE 
	And GRNAbstract.GRNID = GRNDetail.GRNID)
   
	--Adding SalesReturnSaleable Qty to Batch_Products_Temp
	Update Batch_Products_Temp 
	Set Batch_Products_Temp.Quantity = IsNull(Batch_Products_Temp.Quantity, 0) + 
	IsNull((Select Sum(#InvoiceDetail.Quantity) 
	From #InvoiceDetail, InvoiceAbstract   
	WHERE (InvoiceAbstract.Status & 128) = 0
	AND (InvoiceAbstract.InvoiceType = 4)
	AND InvoiceAbstract.InvoiceDate BETWEEN @FirstTransactionDate AND @TODATE
	AND #InvoiceDetail.Product_Code = @ITEMCODE  
	AND InvoiceAbstract.InvoiceID = #InvoiceDetail.InvoiceID
	AND #InvoiceDetail.Batch_Code=Batch_Products_Temp.Batch_Code ), 0)
	From Batch_Products_Temp, #InvoiceDetail, InvoiceAbstract   
	WHERE (InvoiceAbstract.Status & 128) = 0   
	AND (InvoiceAbstract.InvoiceType = 4)   
	AND InvoiceAbstract.InvoiceDate BETWEEN @FirstTransactionDate AND @TODATE  
	AND #InvoiceDetail.Product_Code = @ITEMCODE  
	AND InvoiceAbstract.InvoiceID = #InvoiceDetail.InvoiceID   
	AND #InvoiceDetail.Batch_Code=Batch_Products_Temp.Batch_Code	
	
	--Deducting Invoice Qty from Batch_Products_Temp
	Update Batch_Products_Temp 
	Set Batch_Products_Temp.Quantity = IsNull(Batch_Products_Temp.Quantity, 0) - 
	IsNull((Select Sum(#InvoiceDetail.Quantity) 
	From #InvoiceDetail, InvoiceAbstract   	
	WHERE (InvoiceAbstract.Status & 128) = 0
	And (InvoiceAbstract.Status & 16) = 0
	AND (InvoiceAbstract.InvoiceType in (1,2,3))   
	AND InvoiceAbstract.InvoiceDate BETWEEN @FirstTransactionDate AND @TODATE
	AND #InvoiceDetail.Product_Code = @ITEMCODE
	AND InvoiceAbstract.InvoiceID = #InvoiceDetail.InvoiceID
	AND #InvoiceDetail.Batch_Code = Batch_Products_Temp.Batch_Code), 0)
	From Batch_Products_Temp, #InvoiceDetail, InvoiceAbstract
	WHERE (InvoiceAbstract.Status & 128) = 0
	And (InvoiceAbstract.Status & 16) = 0
	AND (InvoiceAbstract.InvoiceType in (1,2,3))	
	And InvoiceAbstract.InvoiceDate BETWEEN @FirstTransactionDate AND @TODATE
	AND #InvoiceDetail.Product_Code = @ITEMCODE
	AND InvoiceAbstract.InvoiceID = #InvoiceDetail.InvoiceID
	AND #InvoiceDetail.Batch_Code = Batch_Products_Temp.Batch_Code
  
	--Deducting Invoice Qty from Batch_Products_Temp
	Update Batch_Products_Temp 
	Set Batch_Products_Temp.Quantity = IsNull(Batch_Products_Temp.Quantity, 0) - 
	IsNull((Select Sum(#InvoiceDetail.Quantity) 
	From #InvoiceDetail, InvoiceAbstract   	
	WHERE (InvoiceAbstract.Status & 128) = 0   
	And (InvoiceAbstract.Status & 16) <> 0
	AND (InvoiceAbstract.InvoiceType in (1,3))   
	AND InvoiceAbstract.InvoiceDate BETWEEN @FirstTransactionDate AND @TODATE
	AND #InvoiceDetail.Product_Code = @ITEMCODE
	AND InvoiceAbstract.InvoiceID = #InvoiceDetail.InvoiceID
	AND #InvoiceDetail.Batch_Code = Batch_Products_Temp.Batch_Code), 0)
	From Batch_Products_Temp, #InvoiceDetail, InvoiceAbstract, VanStatementDetail
	WHERE (InvoiceAbstract.Status & 128) = 0
	And (InvoiceAbstract.Status & 16) <> 0
	AND (InvoiceAbstract.InvoiceType in (1,3))	
	And InvoiceAbstract.InvoiceDate BETWEEN @FirstTransactionDate AND @TODATE
	AND #InvoiceDetail.Product_Code = @ITEMCODE
	AND InvoiceAbstract.InvoiceID = #InvoiceDetail.InvoiceID
	And Batch_Products_Temp.Batch_Code = VanStatementDetail.Batch_Code
	And VanStatementDetail.ID = #InvoiceDetail.Batch_Code

	--Deducting Dispatch Qty from Batch_Products_Temp
	Update Batch_Products_Temp 
	Set Batch_Products_Temp.Quantity = IsNull(Batch_Products_Temp.Quantity, 0) - 
	IsNull((Select Sum(#DispatchDetail.Quantity)
	From DispatchAbstract, #DispatchDetail
	WHERE #DispatchDetail.Batch_Code = Batch_Products_Temp.Batch_Code
	AND DispatchAbstract.DispatchID = #DispatchDetail.DispatchID   
	AND (DispatchAbstract.Status & 128) = 0   
	AND #DispatchDetail.Product_Code = @ITEMCODE  
	AND DispatchAbstract.DispatchDate BETWEEN @FirstTransactionDate AND @TODATE), 0)
	From Batch_Products_Temp, DispatchAbstract, #DispatchDetail
	WHERE (DispatchAbstract.Status & 128) = 0   
	AND DispatchAbstract.DispatchDate BETWEEN @FirstTransactionDate AND @TODATE  
	AND #DispatchDetail.Product_Code = @ITEMCODE
	AND DispatchAbstract.DispatchID = #DispatchDetail.DispatchID
	AND #DispatchDetail.Batch_Code = Batch_Products_Temp.Batch_Code

	--Deducting STO Qty from Batch_Products_Temp
	Update Batch_Products_Temp 
	Set Batch_Products_Temp.Quantity = IsNull(Batch_Products_Temp.Quantity, 0) - 
	IsNull((Select Sum(StockTransferOutDetail.Quantity)
	From StockTransferOutAbstract, StockTransferOutDetail  
	Where (StockTransferOutAbstract.Status & 192) = 0
	And StockTransferOutAbstract.DocumentDate Between @FirstTransactionDate And @ToDate   
	And StockTransferOutDetail.Product_Code = @ITEMCODE
	AND StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial
	And StockTransferOutDetail.Batch_Code = Batch_Products_Temp.Batch_Code), 0)
	From Batch_Products_Temp, StockTransferOutAbstract, StockTransferOutDetail  
	Where (StockTransferOutAbstract.Status & 192) = 0
	And StockTransferOutAbstract.DocumentDate Between @FirstTransactionDate And @ToDate   
	And StockTransferOutDetail.Product_Code = @ITEMCODE
	AND StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial
	AND StockTransferOutDetail.Batch_Code = Batch_Products_Temp.Batch_Code
  
	--Adding STI Qty to Batch_Products_Temp
	Update Batch_Products_Temp 
	Set Batch_Products_Temp.Quantity = IsNull(Batch_Products_Temp.Quantity, 0) + 
	IsNull(StockTransferInDetail.Quantity, 0)
	From Batch_Products_Temp, StockTransferInAbstract, StockTransferInDetail  
	Where (StockTransferInAbstract.Status & 192) = 0 
	And StockTransferInAbstract.DocumentDate Between @FirstTransactionDate And @ToDate   
	And StockTransferInDetail.Product_Code = @ITEMCODE
	AND StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial  
	AND StockTransferInDetail.Batch_Code = Batch_Products_Temp.Batch_Code

	--Adding AdjustmentOthers Qty to Batch_Products_Temp
	Update Batch_Products_Temp 
	Set Quantity = IsNull(Batch_Products_Temp.Quantity, 0) + 
	IsNull((Select Sum(IsNull(StockAdjustment.Quantity,0)) - Sum(IsNull(StockAdjustment.OldQty,0))  
	From StockAdjustmentAbstract, StockAdjustment 
	Where IsNull(StockAdjustmentAbstract.AdjustmentType,0) = 1
	AND StockAdjustmentAbstract.AdjustmentDate BETWEEN @FirstTransactionDate AND @TODATE
	AND StockAdjustment.Product_Code = @ITEMCODE  
	AND StockAdjustment.Batch_Code = Batch_Products_Temp.Batch_Code
	AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID ), 0)
	From Batch_Products_Temp, StockAdjustmentAbstract, StockAdjustment 
	Where IsNull(StockAdjustmentAbstract.AdjustmentType,0) = 1
	AND StockAdjustmentAbstract.AdjustmentDate BETWEEN @FirstTransactionDate AND @TODATE
	AND StockAdjustment.Product_Code = @ITEMCODE  
	AND StockAdjustment.Batch_Code = Batch_Products_Temp.Batch_Code
	AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID

	--Adding AdjReconcile Qty to Batch_Products_Temp
	Update Batch_Products_Temp 
	Set Batch_Products_Temp.Quantity = IsNull(Batch_Products_Temp.Quantity, 0) + 
	IsNull((Select Sum(StockAdjustment.Quantity) - Sum(StockAdjustment.OldQty) 
	from StockAdjustmentAbstract, StockAdjustment 
	Where IsNull(StockAdjustmentAbstract.AdjustmentType,0) = 3
	AND StockAdjustmentAbstract.AdjustmentDate BETWEEN @FirstTransactionDate AND @TODATE  
	AND StockAdjustment.Product_Code = @ITEMCODE  
	AND StockAdjustment.Batch_Code = Batch_Products_Temp.Batch_Code	
	AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID ), 0)
	From Batch_Products_Temp, StockAdjustmentAbstract, StockAdjustment 
	Where IsNull(StockAdjustmentAbstract.AdjustmentType,0) = 3
	AND StockAdjustmentAbstract.AdjustmentDate BETWEEN @FirstTransactionDate AND @TODATE  
	AND StockAdjustment.Product_Code = @ITEMCODE  
	AND StockAdjustment.Batch_Code = Batch_Products_Temp.Batch_Code	
	AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID

	--Deducting PurchaseReturn Qty from Batch_Products_Temp
	Update Batch_Products_Temp 
	Set Batch_Products_Temp.Quantity = IsNull(Batch_Products_Temp.Quantity, 0) - 
	IsNull((Select Sum(IsNull(AdjustmentReturnDetail.Quantity, 0))
	From AdjustmentReturnAbstract, AdjustmentReturnDetail 
	Where (ISNULL(AdjustmentReturnAbstract.Status, 0) & 192) = 0
	AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FirstTransactionDate AND @TODATE
	AND AdjustmentReturnDetail.Product_Code = @ITEMCODE
	And AdjustmentReturnDetail.BatchCode = Batch_Products_Temp.Batch_Code
	AND AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID ), 0)
	From Batch_Products_Temp, AdjustmentReturnAbstract, AdjustmentReturnDetail 
	Where (ISNULL(AdjustmentReturnAbstract.Status, 0) & 192) = 0  
	AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FirstTransactionDate AND @TODATE   
	AND AdjustmentReturnDetail.Product_Code = @ITEMCODE  
	And AdjustmentReturnDetail.BatchCode = Batch_Products_Temp.Batch_Code	
	AND AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID
	
	--Deducting StockDestruction Qty from Batch_Products_Temp
	Update Batch_Products_Temp 
	Set Batch_Products_Temp.Quantity = IsNull(Batch_Products_Temp.Quantity, 0) - 
	IsNull((Select Sum(IsNull(StockDestructionDetail.DestroyQuantity,0))
	From StockDestructionAbstract, StockDestructionDetail
	Where StockDestructionAbstract.DocumentDate BETWEEN @FirstTransactionDate AND @TODATE	
	AND StockDestructionDetail.Product_Code = @ITEMCODE	
	AND StockDestructionDetail.BatchCode = Batch_Products_Temp.Batch_Code	
	AND StockDestructionDetail.DocSerial = StockDestructionAbstract.DocSerial ), 0)
	From Batch_Products_Temp, StockDestructionAbstract, StockDestructionDetail
	Where StockDestructionAbstract.DocumentDate BETWEEN @FirstTransactionDate AND @TODATE	
	AND StockDestructionDetail.Product_Code = @ITEMCODE	
	AND StockDestructionDetail.BatchCode = Batch_Products_Temp.Batch_Code	
	AND StockDestructionDetail.DocSerial = StockDestructionAbstract.DocSerial
		
	--Deducting Qty from Batch_Products_Temp (Applicable for both Free2Sale, Sale2Free)
	Update Batch_Products_Temp 
	Set Batch_Products_Temp.Quantity = IsNull(Batch_Products_Temp.Quantity, 0) - 
	IsNull((Select SUM(IsNull(ConversionDetail.Quantity,0)) 
	From ConversionAbstract, ConversionDetail
	Where ConversionAbstract.DocumentDate BETWEEN @FirstTransactionDate AND @TODATE
	And ConversionDetail.Product_Code = @ITEMCODE 
	AND	ConversionDetail.OldBatchCode = Batch_Products_Temp.Batch_Code 
	AND	ConversionDetail.DocSerial = ConversionAbstract.DocSerial), 0)
	From Batch_Products_Temp, ConversionAbstract, ConversionDetail
	Where ConversionAbstract.DocumentDate BETWEEN @FirstTransactionDate AND @TODATE	
	And ConversionDetail.Product_Code = @ITEMCODE	
	AND ConversionDetail.OldBatchCode = Batch_Products_Temp.Batch_Code	
	AND ConversionDetail.DocSerial = ConversionAbstract.DocSerial	
	AND ConversionAbstract.ConversionType = 1
	
	--Adding Qty to Batch_Products_Temp (Applicable for both Free2Sale, Sale2Free)
	Update Batch_Products_Temp 
	Set Batch_Products_Temp.Quantity = IsNull(Batch_Products_Temp.Quantity, 0) + 
	IsNull((Select SUM(IsNull(ConversionDetail.Quantity,0)) 
	From ConversionAbstract, ConversionDetail
	Where ConversionAbstract.DocumentDate BETWEEN @FirstTransactionDate AND @TODATE 
	And ConversionDetail.Product_Code = @ITEMCODE 
	AND ConversionDetail.NewBatchCode = Batch_Products_Temp.Batch_Code 
	AND	ConversionDetail.DocSerial = ConversionAbstract.DocSerial), 0)
	From Batch_Products_Temp, ConversionAbstract, ConversionDetail
	Where ConversionAbstract.DocumentDate BETWEEN @FirstTransactionDate AND @TODATE	
	AND ConversionDetail.Product_Code = @ITEMCODE	
	And ConversionDetail.NewBatchCode = Batch_Products_Temp.Batch_Code	
	AND ConversionDetail.DocSerial = ConversionAbstract.DocSerial
	AND ConversionAbstract.ConversionType = 1
End

Set @FirstTransactionDate = @FromDate

Select @ServerDate = dbo.StripDateFromTime(Max(Opening_Date)) From OpeningDetails

Insert Into #temp (ItemCode, OpeningDate, OpeningQuantity, NewOpeningQuantity, OpeningValue, NewOpeningValue, FreeOpening, NewFreeOpening,
					DamageOpening, NewDamageOpening, DamageOpeningValue, NewDamageOpeningValue, FreeSaleable, NewFreeSaleable)
Select Product_Code, Opening_Date, "Opening Quantity" = Opening_Quantity, "New Opening Quantity" = @NewOpeningQuantity,   
"Opening Value" = Opening_Value, "New Opening Value" = @NewOpeningValue,   
"Free Opening Quantity" = Free_Opening_Quantity, "New Free Opening Quantity" = @NewFreeOpening,   
"Damage Opening Quantity" = Damage_Opening_Quantity, "New Damage Opening Quantity" = @NewDamageOpeningQty,  
"Damage Opening Value" = Damage_Opening_Value, "New Damage Opening Value" = @NewDamageOpeningValue,  
"Free Saleable Quantity" = Free_Saleable_Quantity, "New Free Saleable Quantity" = @NewFreeSaleable
From OpeningDetails 
Where Product_Code = @ITEMCODE 
And Opening_Date = @FirstTransactionDate

IF @FirstTransactionDate Is Not Null  
BEGIN  
 While @FirstTransactionDate <= @ServerDate  
 BEGIN  
  Set @ToDate = DateAdd(s, 0 - 1, DateAdd(hh, 24, @FirstTransactionDate))  
  DECLARE GetOpeningDetails CURSOR KEYSET FOR  
  Select Opening_Quantity, Opening_Value, IsNull(Free_Opening_Quantity,0),  
  IsNull(Damage_Opening_Quantity,0), IsNull(Damage_Opening_Value,0), IsNull(Free_Saleable_Quantity,0)  
  From OpeningDetails Where Opening_Date = @FirstTransactionDate And Product_Code = @ITEMCODE

  Open GetOpeningDetails  
  Fetch From GetOpeningDetails Into @OpeningQuantity, @OpeningValue,   
  @FreeOpening, @DamageOpeningQty, @DamageOpeningValue, @FreeSaleable  
  While @@Fetch_Status = 0  
  Begin  
	
	--Purchase Qty and Values
	Select 
	@Purchases = Sum(QuantityReceived), 
	@PurchaseValue = Sum(QuantityReceived*PurchasePrice), 
	@FreePurchases = Sum(case IsNull(Free,0) when 1 then QuantityReceived else 0 end)  
	From Batch_Products  
	Where Product_Code = @ITEMCODE 
	And GRN_ID In (Select GRNAbstract.GRNID From GRNAbstract, GRNDetail	
	Where GRNDetail.Product_Code = @ITEMCODE
	And (GRNAbstract.GRNStatus & 96) = 0
	And GRNDate Between @FirstTransactionDate AND @TODATE
	And GRNAbstract.GRNID = GRNDetail.GRNID)
	
	--Adding Purchase Qty in Batch_Products_Temp
	Update Batch_Products_Temp 
	Set Quantity = IsNull(Quantity, 0) + IsNull(QuantityReceived, 0)
	Where Product_Code = @ITEMCODE And GRN_ID In   
	(Select GRNAbstract.GRNID From GRNAbstract, GRNDetail   
	Where GRNDetail.Product_Code = @ITEMCODE
	And (GRNAbstract.GRNStatus & 96) = 0 
	And GRNDate Between @FirstTransactionDate AND @TODATE 
	And GRNAbstract.GRNID = GRNDetail.GRNID)
	
	-- Sales Returns
	SELECT 
	@SalesReturnSaleable = SUM(#InvoiceDetail.Quantity), 
	@SalesReturnValue = Sum(#InvoiceDetail.PurchasePrice),  
	@SalesReturnFreeDamages = Sum(case When IsNull(Batch_Products_Temp.Free,0) = 1 Then Case When (Status & 32) <> 0 Then #InvoiceDetail.Quantity Else 0 End Else 0 End),
	@SalesReturnDamages = Sum(Case When (Status & 32) <> 0 Then #InvoiceDetail.Quantity Else 0 end),   
	@SalesReturnDamagesValue = Sum(Case When (Status & 32) <> 0 Then #InvoiceDetail.PurchasePrice Else 0 end),  
	--@FreeReturns = Sum(case When SalePrice = 0 And PurchasePrice = 0 Then Case When (Status & 32) = 0 Then #InvoiceDetail.Quantity Else 0 End Else 0 End)  
	@FreeReturns = Sum(case When IsNull(Batch_Products_Temp.Free,0) = 1 Then Case When (Status & 32) = 0 Then #InvoiceDetail.Quantity Else 0 End Else 0 End)  
	FROM #InvoiceDetail, InvoiceAbstract, Batch_Products_Temp
	WHERE #InvoiceDetail.Product_Code = @ITEMCODE  
	AND (InvoiceAbstract.Status & 128) = 0
	AND (InvoiceAbstract.InvoiceType = 4)
	AND InvoiceAbstract.InvoiceDate BETWEEN @FirstTransactionDate AND @TODATE
	And InvoiceAbstract.InvoiceID = #InvoiceDetail.InvoiceID
	And #InvoiceDetail.Batch_Code = Batch_Products_Temp.Batch_Code
   
	--Adding SalesReturnSaleable Qty to Batch_Products_Temp
	Update Batch_Products_Temp 
	Set Batch_Products_Temp.Quantity = IsNull(Batch_Products_Temp.Quantity, 0) + 
	IsNull((Select Sum(#InvoiceDetail.Quantity) 
	From #InvoiceDetail, InvoiceAbstract   
	WHERE (InvoiceAbstract.Status & 128) = 0
	AND (InvoiceAbstract.InvoiceType = 4)
	AND InvoiceAbstract.InvoiceDate BETWEEN @FirstTransactionDate AND @TODATE
	AND #InvoiceDetail.Product_Code = @ITEMCODE  
	AND InvoiceAbstract.InvoiceID = #InvoiceDetail.InvoiceID
	AND #InvoiceDetail.Batch_Code=Batch_Products_Temp.Batch_Code ), 0)
	From Batch_Products_Temp, #InvoiceDetail, InvoiceAbstract   
	WHERE (InvoiceAbstract.Status & 128) = 0   
	AND (InvoiceAbstract.InvoiceType = 4)   
	AND InvoiceAbstract.InvoiceDate BETWEEN @FirstTransactionDate AND @TODATE  
	AND #InvoiceDetail.Product_Code = @ITEMCODE  
	AND InvoiceAbstract.InvoiceID = #InvoiceDetail.InvoiceID   
	AND #InvoiceDetail.Batch_Code=Batch_Products_Temp.Batch_Code	
	
	-- Sales Without Van Invoice(Issues)
	SELECT 
	@Issues = SUM(#InvoiceDetail.Quantity), 
	@SalesValue = Sum(#InvoiceDetail.PurchasePrice),   
	--@FreeIssues = Sum(Case When SalePrice = 0 And PurchasePrice = 0 Then Quantity Else 0 End)  
	@FreeIssues = Sum(Case When IsNull(Batch_Products_Temp.Free,0) = 1 Then #InvoiceDetail.Quantity Else 0 End)
	FROM #InvoiceDetail, InvoiceAbstract, Batch_Products_Temp
	WHERE (InvoiceAbstract.Status & 128) = 0   
	And (InvoiceAbstract.Status & 16) = 0
	AND (InvoiceAbstract.InvoiceType in (1,2,3))   
	AND InvoiceAbstract.InvoiceDate BETWEEN @FirstTransactionDate AND @TODATE  
	AND #InvoiceDetail.Product_Code = @ITEMCODE  
	AND InvoiceAbstract.InvoiceID = #InvoiceDetail.InvoiceID
	And Batch_Products_Temp.Batch_code = #InvoiceDetail.Batch_Code

	--Deducting Invoice Qty from Batch_Products_Temp
	Update Batch_Products_Temp 
	Set Batch_Products_Temp.Quantity = IsNull(Batch_Products_Temp.Quantity, 0) - 
	IsNull((Select Sum(#InvoiceDetail.Quantity) 
	From #InvoiceDetail, InvoiceAbstract   	
	WHERE (InvoiceAbstract.Status & 128) = 0
	And (InvoiceAbstract.Status & 16) = 0
	AND (InvoiceAbstract.InvoiceType in (1,2,3))   
	AND InvoiceAbstract.InvoiceDate BETWEEN @FirstTransactionDate AND @TODATE
	AND #InvoiceDetail.Product_Code = @ITEMCODE
	AND InvoiceAbstract.InvoiceID = #InvoiceDetail.InvoiceID
	AND #InvoiceDetail.Batch_Code = Batch_Products_Temp.Batch_Code), 0)
	From Batch_Products_Temp, #InvoiceDetail, InvoiceAbstract
	WHERE (InvoiceAbstract.Status & 128) = 0
	And (InvoiceAbstract.Status & 16) = 0
	AND (InvoiceAbstract.InvoiceType in (1,2,3))	
	And InvoiceAbstract.InvoiceDate BETWEEN @FirstTransactionDate AND @TODATE
	AND #InvoiceDetail.Product_Code = @ITEMCODE
	AND InvoiceAbstract.InvoiceID = #InvoiceDetail.InvoiceID
	AND #InvoiceDetail.Batch_Code = Batch_Products_Temp.Batch_Code
  
	-- Sales for Van Invoice(Van Issues)
	SELECT 
	@Issues = IsNull(@Issues,0) + IsNull(SUM(#InvoiceDetail.Quantity),0), 
	@SalesValue = IsNull(@SalesValue,0) + IsNull(Sum(#InvoiceDetail.PurchasePrice),0),   
	--@FreeIssues = IsNull(@FreeIssues,0) + Sum(Case When SalePrice = 0 And PurchasePrice = 0 Then #InvoiceDetail.Quantity Else 0 End)  
	@FreeIssues = IsNull(@FreeIssues,0) + IsNull(Sum(Case When IsNull(Batch_Products_Temp.Free,0) = 1 Then #InvoiceDetail.Quantity Else 0 End),0)  
	FROM #InvoiceDetail, InvoiceAbstract, Batch_Products_Temp, VanStatementDetail   
	WHERE (InvoiceAbstract.Status & 128) = 0
	And (InvoiceAbstract.Status & 16) <> 0
	AND (InvoiceAbstract.InvoiceType in (1,3))   
	AND InvoiceAbstract.InvoiceDate BETWEEN @FirstTransactionDate AND @TODATE  
	AND #InvoiceDetail.Product_Code = @ITEMCODE  
	AND InvoiceAbstract.InvoiceID = #InvoiceDetail.InvoiceID
	And Batch_Products_Temp.Batch_Code = VanStatementDetail.Batch_Code
	And VanStatementDetail.ID = #InvoiceDetail.Batch_Code

	--Deducting Invoice Qty from Batch_Products_Temp
	Update Batch_Products_Temp 
	Set Batch_Products_Temp.Quantity = IsNull(Batch_Products_Temp.Quantity, 0) - 
	IsNull((Select Sum(#InvoiceDetail.Quantity) 
	From #InvoiceDetail, InvoiceAbstract   	
	WHERE (InvoiceAbstract.Status & 128) = 0   
	And (InvoiceAbstract.Status & 16) <> 0
	AND (InvoiceAbstract.InvoiceType in (1,3))   
	AND InvoiceAbstract.InvoiceDate BETWEEN @FirstTransactionDate AND @TODATE
	AND #InvoiceDetail.Product_Code = @ITEMCODE
	AND InvoiceAbstract.InvoiceID = #InvoiceDetail.InvoiceID
	AND #InvoiceDetail.Batch_Code = Batch_Products_Temp.Batch_Code), 0)
	From Batch_Products_Temp, #InvoiceDetail, InvoiceAbstract, VanStatementDetail
	WHERE (InvoiceAbstract.Status & 128) = 0
	And (InvoiceAbstract.Status & 16) <> 0
	AND (InvoiceAbstract.InvoiceType in (1,3))	
	And InvoiceAbstract.InvoiceDate BETWEEN @FirstTransactionDate AND @TODATE
	AND #InvoiceDetail.Product_Code = @ITEMCODE
	AND InvoiceAbstract.InvoiceID = #InvoiceDetail.InvoiceID
	And Batch_Products_Temp.Batch_Code = VanStatementDetail.Batch_Code
	And VanStatementDetail.ID = #InvoiceDetail.Batch_Code

	-- Dispatch (Issues)
	SELECT 
	@Issues = IsNull(@Issues,0) + IsNull(SUM(#DispatchDetail.Quantity),0), 
	@SalesValue = IsNull(@SalesValue,0) + IsNull(Sum(#DispatchDetail.Quantity*Batch_Products.PurchasePrice),0),   
	--@FreeIssues = IsNull(@FreeIssues, 0) + IsNull(Sum(Case When #DispatchDetail.SalePrice = 0 And Batch_Products.PurchasePrice = 0 Then #DispatchDetail.Quantity Else 0 End),0)  
	@FreeIssues = IsNull(@FreeIssues, 0) + IsNull(Sum(Case When IsNull(Batch_Products.Free,0) = 1 Then #DispatchDetail.Quantity Else 0 End),0)  
	FROM DispatchAbstract, #DispatchDetail, Batch_Products  
	WHERE DispatchAbstract.DispatchID = #DispatchDetail.DispatchID   
	AND (DispatchAbstract.Status & 128) = 0   
	AND #DispatchDetail.Product_Code = @ITEMCODE  
	AND DispatchAbstract.DispatchDate BETWEEN @FirstTransactionDate AND @TODATE  
	And #DispatchDetail.Batch_code = Batch_Products.Batch_Code  

	--Deducting Dispatch Qty from Batch_Products_Temp
	Update Batch_Products_Temp 
	Set Batch_Products_Temp.Quantity = IsNull(Batch_Products_Temp.Quantity, 0) - 
	IsNull((Select Sum(#DispatchDetail.Quantity)
	From DispatchAbstract, #DispatchDetail
	WHERE #DispatchDetail.Batch_Code = Batch_Products_Temp.Batch_Code
	AND DispatchAbstract.DispatchID = #DispatchDetail.DispatchID   
	AND (DispatchAbstract.Status & 128) = 0   
	AND #DispatchDetail.Product_Code = @ITEMCODE  
	AND DispatchAbstract.DispatchDate BETWEEN @FirstTransactionDate AND @TODATE), 0)
	From Batch_Products_Temp, DispatchAbstract, #DispatchDetail
	WHERE (DispatchAbstract.Status & 128) = 0   
	AND DispatchAbstract.DispatchDate BETWEEN @FirstTransactionDate AND @TODATE  
	AND #DispatchDetail.Product_Code = @ITEMCODE
	AND DispatchAbstract.DispatchID = #DispatchDetail.DispatchID
	AND #DispatchDetail.Batch_Code = Batch_Products_Temp.Batch_Code

	Select 
	@StockTransferOut = IsNull(Sum(StockTransferOutDetail.Quantity),0), 
	@StockTransferOutValue = IsNull(Sum(StockTransferOutDetail.Quantity*StockTransferOutDetail.Rate),0),  
	--@FreeStockTransferOut = IsNull(Sum(Case Rate When 0 Then StockTransferOutDetail.Quantity Else 0 End),0)  
	@FreeStockTransferOut = IsNull(Sum(Case When IsNull(Batch_Products_Temp.Free,0) = 1 Then StockTransferOutDetail.Quantity Else 0 End),0)  
	From StockTransferOutAbstract, StockTransferOutDetail, Batch_Products_Temp
	Where (StockTransferOutAbstract.Status & 192) = 0
	And StockTransferOutAbstract.DocumentDate Between @FirstTransactionDate And @ToDate   
	And StockTransferOutDetail.Product_Code = @ITEMCODE  
	And StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial
	AND StockTransferOutDetail.Batch_Code = Batch_Products_Temp.Batch_Code

	--Deducting STO Qty from Batch_Products_Temp
	Update Batch_Products_Temp 
	Set Batch_Products_Temp.Quantity = IsNull(Batch_Products_Temp.Quantity, 0) - 
	IsNull((Select Sum(StockTransferOutDetail.Quantity)
	From StockTransferOutAbstract, StockTransferOutDetail  
	Where (StockTransferOutAbstract.Status & 192) = 0
	And StockTransferOutAbstract.DocumentDate Between @FirstTransactionDate And @ToDate   
	And StockTransferOutDetail.Product_Code = @ITEMCODE
	AND StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial
	And StockTransferOutDetail.Batch_Code = Batch_Products_Temp.Batch_Code), 0)
	From Batch_Products_Temp, StockTransferOutAbstract, StockTransferOutDetail  
	Where (StockTransferOutAbstract.Status & 192) = 0
	And StockTransferOutAbstract.DocumentDate Between @FirstTransactionDate And @ToDate   
	And StockTransferOutDetail.Product_Code = @ITEMCODE
	AND StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial
	AND StockTransferOutDetail.Batch_Code = Batch_Products_Temp.Batch_Code
  
	Select 
	@StockTransferIn = Sum(StockTransferInDetail.Quantity),  
	@StockTransferInValue = Sum(StockTransferInDetail.Quantity*StockTransferInDetail.Rate),  
	--@FreeStockTransferIn = Sum(Case StockTransferInDetail.Rate When 0 Then StockTransferInDetail.Quantity Else 0 End)  
	@FreeStockTransferIn = Sum(Case When IsNull(Batch_Products_Temp.Free,0) = 1 Then StockTransferInDetail.Quantity Else 0 End)  
	From StockTransferInAbstract, StockTransferInDetail, Batch_Products_Temp
	Where (StockTransferInAbstract.Status & 192) = 0 
	And StockTransferInAbstract.DocumentDate Between @FirstTransactionDate And @ToDate   
	And StockTransferInDetail.Product_Code = @ITEMCODE  
	AND StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial
	AND StockTransferInDetail.Batch_Code = Batch_Products_Temp.Batch_Code
  
	--Adding STI Qty to Batch_Products_Temp
	Update Batch_Products_Temp 
	Set Batch_Products_Temp.Quantity = IsNull(Batch_Products_Temp.Quantity, 0) + 
	IsNull(StockTransferInDetail.Quantity, 0)
	From Batch_Products_Temp, StockTransferInAbstract, StockTransferInDetail  
	Where (StockTransferInAbstract.Status & 192) = 0 
	And StockTransferInAbstract.DocumentDate Between @FirstTransactionDate And @ToDate   
	And StockTransferInDetail.Product_Code = @ITEMCODE
	AND StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial  
	AND StockTransferInDetail.Batch_Code = Batch_Products_Temp.Batch_Code

	SELECT 
	@AdjustmentOthers = SUM(Case ISNULL(AdjustmentType,0) When 1 Then StockAdjustment.Quantity - OldQty Else 0 End),   
	@AdjustmentValue = SUM(Case ISNULL(AdjustmentType,0) When 1 Then Rate - OldValue Else 0 End),   
	@AdjustmentFreeDamages = SUM(Case ISNULL(AdjustmentType,0) When 0 Then (Case When IsNull(Batch_Products.Free,0) = 1 Then StockAdjustment.Quantity Else 0 End) Else 0 End),   
	@AdjustmentDamages = SUM(Case ISNULL(AdjustmentType,0) When 0 Then StockAdjustment.Quantity Else 0 End),   
	@AdjustmentDamagesValue = IsNull(Sum(case ISNULL(AdjustmentType,0) When 0 Then Rate Else 0 End),0),  
	@AdjustmentFree = Sum(Case When ISNULL(AdjustmentType,0) = 1 AND IsNull(Free,0)=1 Then StockAdjustment.Quantity - OldQty Else 0 end),  
	@AdjustmentFreeSaleable = Sum(Case When ISNULL(AdjustmentType,0) = 1 AND IsNull(Free,0)=1 And IsNull(Damage,0)=0 Then StockAdjustment.Quantity - OldQty Else 0 end),  
	@AdjustmentDamagesOthers = SUM(Case When ISNULL(AdjustmentType,0) = 1 And IsNull(Batch_Products.Damage,0)>0 Then StockAdjustment.Quantity - OldQty Else 0 End),   
	@AdjustmentDamagesOthersValue = SUM(Case When ISNULL(AdjustmentType,0) = 1 And IsNull(Batch_Products.Damage,0)>0 Then Rate - OldValue Else 0 End)  
	FROM StockAdjustment, StockAdjustmentAbstract, Batch_Products  
	WHERE StockAdjustment.Product_Code = @ITEMCODE  
	AND AdjustmentDate BETWEEN @FirstTransactionDate AND @TODATE  
	AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID  
	And StockAdjustment.Batch_Code = Batch_Products.Batch_Code  

	--Adding AdjustmentOthers Qty to Batch_Products_Temp
	Update Batch_Products_Temp 
	Set Quantity = IsNull(Batch_Products_Temp.Quantity, 0) + 
	IsNull((Select Sum(IsNull(StockAdjustment.Quantity,0)) - Sum(IsNull(StockAdjustment.OldQty,0))  
	From StockAdjustmentAbstract, StockAdjustment 
	Where IsNull(StockAdjustmentAbstract.AdjustmentType,0) = 1
	AND StockAdjustmentAbstract.AdjustmentDate BETWEEN @FirstTransactionDate AND @TODATE
	AND StockAdjustment.Product_Code = @ITEMCODE  
	AND StockAdjustment.Batch_Code = Batch_Products_Temp.Batch_Code
	AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID ), 0)
	From Batch_Products_Temp, StockAdjustmentAbstract, StockAdjustment 
	Where IsNull(StockAdjustmentAbstract.AdjustmentType,0) = 1
	AND StockAdjustmentAbstract.AdjustmentDate BETWEEN @FirstTransactionDate AND @TODATE
	AND StockAdjustment.Product_Code = @ITEMCODE  
	AND StockAdjustment.Batch_Code = Batch_Products_Temp.Batch_Code
	AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID

	--Handling Openings for Physical Stock Reconcilation
	SELECT 
	@AdjReconcile = SUM(StockAdjustment.Quantity - OldQty),
	@AdjReconcileValue = SUM(Rate - OldValue),
	@AdjReconcileFree = Sum(Case When ISNULL(BP.Free,0)=1 Then StockAdjustment.Quantity - OldQty Else 0 end),
	@AdjReconcileFreeSaleable = Sum(Case When IsNull(BP.Free,0)=1 And IsNull(BP.Damage,0)=0 Then StockAdjustment.Quantity - OldQty Else 0 end),
	@AdjReconcileDamages = SUM(Case When IsNull(BP.Damage,0)>0 Then StockAdjustment.Quantity - OldQty Else 0 End),
	@AdjReconcileDamagesValue = SUM(Case When IsNull(BP.Damage,0)>0 Then Rate - OldValue Else 0 End)
	FROM StockAdjustment, StockAdjustmentAbstract, Batch_Products BP
	WHERE IsNull(StockAdjustmentAbstract.AdjustmentType,0) = 3
	AND StockAdjustmentAbstract.AdjustmentDate BETWEEN @FirstTransactionDate AND @TODATE
	And StockAdjustment.Product_Code = @ITEMCODE
	AND BP.Batch_Code = StockAdjustment.Batch_Code
	AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID
   
	--Adding AdjReconcile Qty to Batch_Products_Temp
	Update Batch_Products_Temp 
	Set Batch_Products_Temp.Quantity = IsNull(Batch_Products_Temp.Quantity, 0) + 
	IsNull((Select Sum(StockAdjustment.Quantity) - Sum(StockAdjustment.OldQty) 
	from StockAdjustmentAbstract, StockAdjustment 
	Where IsNull(StockAdjustmentAbstract.AdjustmentType,0) = 3
	AND StockAdjustmentAbstract.AdjustmentDate BETWEEN @FirstTransactionDate AND @TODATE  
	AND StockAdjustment.Product_Code = @ITEMCODE  
	AND StockAdjustment.Batch_Code = Batch_Products_Temp.Batch_Code	
	AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID ), 0)
	From Batch_Products_Temp, StockAdjustmentAbstract, StockAdjustment 
	Where IsNull(StockAdjustmentAbstract.AdjustmentType,0) = 3
	AND StockAdjustmentAbstract.AdjustmentDate BETWEEN @FirstTransactionDate AND @TODATE  
	AND StockAdjustment.Product_Code = @ITEMCODE  
	AND StockAdjustment.Batch_Code = Batch_Products_Temp.Batch_Code	
	AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID

	SELECT 
	@PurchaseReturn = SUM(AdjustmentReturnDetail.Quantity), 
	@PurchaseReturnValue = Sum(AdjustmentReturnDetail.Quantity * AdjustmentReturnDetail.Rate),   
	--@PurchaseReturnFree = Sum(Case AdjustmentReturnDetail.Rate When 0 Then AdjustmentReturnDetail.Quantity Else 0 End),  
	@PurchaseReturnFree = Sum(Case When IsNull(Batch_Products.Free,0) =1 Then AdjustmentReturnDetail.Quantity Else 0 End),  
	@PurchaseReturnDamages = Sum(Case When IsNull(Damage,0) > 0 Then AdjustmentReturnDetail.Quantity Else 0 End),  
	@PurchaseReturnDamagesValue = Sum(Case When IsNull(Damage,0) > 0 Then AdjustmentReturnDetail.Quantity * AdjustmentReturnDetail.Rate Else 0 End)  
	FROM AdjustmentReturnDetail, AdjustmentReturnAbstract, Batch_Products  
	WHERE (IsNull(AdjustmentReturnAbstract.Status, 0) & 192) = 0
	AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FirstTransactionDate AND @TODATE
	AND AdjustmentReturnDetail.Product_Code = @ITEMCODE  
	And AdjustmentReturnDetail.Batchcode = Batch_Products.Batch_Code
	And AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID
   
	--Deducting PurchaseReturn Qty from Batch_Products_Temp
	Update Batch_Products_Temp 
	Set Batch_Products_Temp.Quantity = IsNull(Batch_Products_Temp.Quantity, 0) - 
	IsNull((Select Sum(IsNull(AdjustmentReturnDetail.Quantity, 0))
	From AdjustmentReturnAbstract, AdjustmentReturnDetail 
	Where (ISNULL(AdjustmentReturnAbstract.Status, 0) & 192) = 0
	AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FirstTransactionDate AND @TODATE
	AND AdjustmentReturnDetail.Product_Code = @ITEMCODE
	And AdjustmentReturnDetail.BatchCode = Batch_Products_Temp.Batch_Code
	AND AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID ), 0)
	From Batch_Products_Temp, AdjustmentReturnAbstract, AdjustmentReturnDetail 
	Where (ISNULL(AdjustmentReturnAbstract.Status, 0) & 192) = 0  
	AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FirstTransactionDate AND @TODATE   
	AND AdjustmentReturnDetail.Product_Code = @ITEMCODE  
	And AdjustmentReturnDetail.BatchCode = Batch_Products_Temp.Batch_Code	
	AND AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID
	
	--Handling Openings for Stock Destruction
	Select 
	@StockDestructQty = SUM(IsNull(StockDestructionDetail.DestroyQuantity,0)), 
	@StockDestructValue = Sum(BP.PurchasePrice * IsNull(StockDestructionDetail.DestroyQuantity,0)),
	@FreeStockDestructQty = Sum(Case IsNull(BP.Free,0) When 1 Then IsNull(StockDestructionDetail.DestroyQuantity,0) Else 0 End),
	@FreeSaleStockDestructQty = Sum(Case When IsNull(BP.Free,0) = 1 AND IsNull(BP.Damage,0) = 0 Then IsNull(StockDestructionDetail.DestroyQuantity,0) Else 0 End),
	@DamageStockDestructQty = Sum(Case When IsNull(BP.Damage,0) > 0 Then IsNull(StockDestructionDetail.DestroyQuantity,0) Else 0 End),
	@DamageStockDestructValue = Sum(Case When IsNull(BP.Damage,0) > 0 Then BP.PurchasePrice * IsNull(StockDestructionDetail.DestroyQuantity,0) Else 0 End)
	From Batch_Products BP, StockDestructionAbstract, StockDestructionDetail
	Where StockDestructionAbstract.DocumentDate BETWEEN @FirstTransactionDate AND @TODATE	
	AND	StockDestructionDetail.Product_Code = @ITEMCODE 
	AND	BP.Batch_Code = StockDestructionDetail.BatchCode 
	AND	StockDestructionDetail.DocSerial = StockDestructionAbstract.DocSerial 

	--Deducting StockDestruction Qty from Batch_Products_Temp
	Update Batch_Products_Temp 
	Set Batch_Products_Temp.Quantity = IsNull(Batch_Products_Temp.Quantity, 0) - 
	IsNull((Select Sum(IsNull(StockDestructionDetail.DestroyQuantity,0))
	From StockDestructionAbstract, StockDestructionDetail
	Where StockDestructionAbstract.DocumentDate BETWEEN @FirstTransactionDate AND @TODATE	
	AND StockDestructionDetail.Product_Code = @ITEMCODE	
	AND StockDestructionDetail.BatchCode = Batch_Products_Temp.Batch_Code	
	AND StockDestructionDetail.DocSerial = StockDestructionAbstract.DocSerial ), 0)
	From Batch_Products_Temp, StockDestructionAbstract, StockDestructionDetail
	Where StockDestructionAbstract.DocumentDate BETWEEN @FirstTransactionDate AND @TODATE	
	AND StockDestructionDetail.Product_Code = @ITEMCODE	
	AND StockDestructionDetail.BatchCode = Batch_Products_Temp.Batch_Code	
	AND StockDestructionDetail.DocSerial = StockDestructionAbstract.DocSerial
		
	--Handling Openings for Free2Saleable Conversion
	Select 
	@ConversionSaleableValue1 = SUM((BP.PurchasePrice * IsNull(ConversionDetail.Quantity,0))),
	@ConversionFreeQty1 = - SUM(IsNull(ConversionDetail.Quantity,0))
	From Batch_Products BP, ConversionAbstract, ConversionDetail
	Where ConversionAbstract.ConversionType = 1
	And ConversionAbstract.DocumentDate BETWEEN @FirstTransactionDate AND @TODATE
	And ConversionDetail.Product_Code = @ITEMCODE
	AND	BP.Batch_Code = ConversionDetail.NewBatchCode 
	AND	ConversionDetail.DocSerial = ConversionAbstract.DocSerial	

	--Handling Openings for Saleable2Free Conversion
	Select 
	@ConversionSaleableValue2 = - SUM((BP.PurchasePrice * IsNull(ConversionDetail.Quantity,0))),
	@ConversionFreeQty2 = SUM(IsNull(ConversionDetail.Quantity,0))
	From Batch_Products BP, ConversionAbstract, ConversionDetail
	Where ConversionAbstract.ConversionType = 2
	AND	ConversionAbstract.DocumentDate BETWEEN @FirstTransactionDate AND @TODATE 
	AND	ConversionDetail.Product_Code = @ITEMCODE 
	AND	BP.Batch_Code = ConversionDetail.OldBatchCode 
	AND	ConversionDetail.DocSerial = ConversionAbstract.DocSerial
	
	--Deducting Qty from Batch_Products_Temp (Applicable for both Free2Sale, Sale2Free)
	Update Batch_Products_Temp 
	Set Batch_Products_Temp.Quantity = IsNull(Batch_Products_Temp.Quantity, 0) - 
	IsNull((Select SUM(IsNull(ConversionDetail.Quantity,0)) 
	From ConversionAbstract, ConversionDetail
	Where ConversionAbstract.DocumentDate BETWEEN @FirstTransactionDate AND @TODATE
	And ConversionDetail.Product_Code = @ITEMCODE 
	AND	ConversionDetail.OldBatchCode = Batch_Products_Temp.Batch_Code 
	AND	ConversionDetail.DocSerial = ConversionAbstract.DocSerial), 0)
	From Batch_Products_Temp, ConversionAbstract, ConversionDetail
	Where ConversionAbstract.DocumentDate BETWEEN @FirstTransactionDate AND @TODATE	
	And ConversionDetail.Product_Code = @ITEMCODE	
	AND ConversionDetail.OldBatchCode = Batch_Products_Temp.Batch_Code	
	AND ConversionDetail.DocSerial = ConversionAbstract.DocSerial	
	AND ConversionAbstract.ConversionType = 1
	
	--Adding Qty to Batch_Products_Temp (Applicable for both Free2Sale, Sale2Free)
	Update Batch_Products_Temp 
	Set Batch_Products_Temp.Quantity = IsNull(Batch_Products_Temp.Quantity, 0) + 
	IsNull((Select SUM(IsNull(ConversionDetail.Quantity,0)) 
	From ConversionAbstract, ConversionDetail
	Where ConversionAbstract.DocumentDate BETWEEN @FirstTransactionDate AND @TODATE 
	And ConversionDetail.Product_Code = @ITEMCODE 
	AND ConversionDetail.NewBatchCode = Batch_Products_Temp.Batch_Code 
	AND	ConversionDetail.DocSerial = ConversionAbstract.DocSerial), 0)
	From Batch_Products_Temp, ConversionAbstract, ConversionDetail
	Where ConversionAbstract.DocumentDate BETWEEN @FirstTransactionDate AND @TODATE	
	AND ConversionDetail.Product_Code = @ITEMCODE	
	And ConversionDetail.NewBatchCode = Batch_Products_Temp.Batch_Code	
	AND ConversionDetail.DocSerial = ConversionAbstract.DocSerial
	AND ConversionAbstract.ConversionType = 1

	Set @NewOpeningQuantity=IsNull(@OpeningQuantity,0) 
							+ IsNull(@Purchases,0) 
							+ IsNull(@SalesReturnSaleable,0) 
							+ IsNull(@StockTransferIn,0) 
							+ IsNull(@AdjustmentOthers,0) 
							+ IsNull(@AdjReconcile,0) 
							- IsNull(@PurchaseReturn,0) 
							- IsNull(@StockTransferOut,0) 
							- IsNull(@Issues,0) 
							- IsNull(@StockDestructQty,0) 

	Set @NewOpeningValue =	IsNull(@OpeningValue,0) 
							+ IsNull(@PurchaseValue,0) 
							+ IsNull(@SalesReturnValue,0) 
							+ IsNull(@StockTransferInValue,0) 
							+ IsNull(@AdjustmentValue,0) 
							+ IsNull(@AdjReconcileValue,0) 
							+ IsNull(@ConversionSaleableValue1,0) 
							+ IsNull(@ConversionSaleableValue2,0) 
 							- IsNull(@PurchaseReturnValue,0) 
							- IsNull(@StockTransferOutValue,0) 
							- IsNull(@SalesValue,0) 
							- IsNull(@StockDestructValue,0) 
  
	Set @NewFreeOpening =	IsNull(@FreeOpening,0) 
							+ IsNull(@FreePurchases,0) 
							+ IsNull(@FreeReturns,0)
							+ IsNull(@SalesReturnFreeDamages,0)
							+ IsNull(@FreeStockTransferIn,0) 
							+ IsNull(@AdjustmentFree,0) 
							+ IsNull(@AdjReconcileFree,0) 
							+ IsNull(@ConversionFreeQty1,0) 
							+ IsNull(@ConversionFreeQty2,0) 
							- IsNull(@PurchaseReturnFree,0) 
							- IsNull(@FreeStockTransferOut,0) 
							- IsNull(@FreeIssues,0) 
							- IsNull(@FreeStockDestructQty,0) 
  
	Set @NewDamageOpeningQty =	IsNull(@DamageOpeningQty,0) 
								+ IsNull(@SalesReturnDamages,0) 
								+ IsNull(@AdjustmentDamages,0) 
								+ IsNull(@AdjustmentDamagesOthers,0) 
								+ IsNull(@AdjReconcileDamages,0) 
								- IsNull(@PurchaseReturnDamages,0) 
								- IsNull(@DamageStockDestructQty,0)
	
	Set @NewDamageOpeningValue=	IsNull(@DamageOpeningValue,0)
								+ IsNull(@SalesReturnDamagesValue,0) 
								+ IsNull(@AdjustmentDamagesValue,0) 
								+ IsNull(@AdjustmentDamagesOthersValue,0) 
								+ IsNull(@AdjReconcileDamagesValue,0) 
								- IsNull(@PurchaseReturnDamagesValue,0) 
								- IsNull(@DamageStockDestructValue,0) 
	  
	Set @NewFreeSaleable =	IsNull(@FreeSaleable,0) 
							+ IsNull(@FreePurchases,0) 
							+ IsNull(@FreeReturns,0) 
							+ IsNull(@FreeStockTransferIn,0) 
							+ IsNull(@AdjustmentFreeSaleable,0) 
							+ IsNull(@AdjReconcileFreeSaleable,0) 
							+ IsNull(@ConversionFreeQty1,0) 
							+ IsNull(@ConversionFreeQty2,0) 
							- IsNull(@PurchaseReturnFree,0) 
							- IsNull(@FreeStockTransferOut,0) 
							- IsNull(@FreeIssues,0)
							- IsNull(@FreeSaleStockDestructQty,0) 
							- IsNull(@AdjustmentFreeDamages,0)
   
---------------------------------------------------------------------------------------------------------------------------------------
--	Select	"DATE=" = @FirstTransactionDate, "@NewOpeningQuantity" = @NewOpeningQuantity ,"@OpeningQuantity" = IsNull(@OpeningQuantity,0) ,
--			"@Purchases"  = IsNull(@Purchases,0), "@SalesReturnSaleable" = IsNull(@SalesReturnSaleable,0), "@StockTransferIn" = IsNull(@StockTransferIn,0) ,
--			"@AdjustmentOthers"= IsNull(@AdjustmentOthers,0), "@AdjReconcile"= IsNull(@AdjReconcile,0) ,"@PurchaseReturn"= IsNull(@PurchaseReturn,0),
--			"@StockTransferOut"= IsNull(@StockTransferOut,0), "@Issues"= IsNull(@Issues,0) ,"@StockDestructQty"= IsNull(@StockDestructQty,0), 
--			
--			"@NewOpeningValue" = @NewOpeningValue ,"@OpeningValue"= IsNull(@OpeningValue,0) ,"@PurchaseValue"= IsNull(@PurchaseValue,0),
--			"@SalesReturnValue"= IsNull(@SalesReturnValue,0) ,"@StockTransferInValue"= IsNull(@StockTransferInValue,0) ,"@AdjustmentValue"= IsNull(@AdjustmentValue,0), 
--			"@AdjReconcileValue"= IsNull(@AdjReconcileValue,0) ,"@ConversionSaleableValue1"= IsNull(@ConversionSaleableValue1,0),
--			"@ConversionSaleableValue2"= IsNull(@ConversionSaleableValue2,0),"@PurchaseReturnValue"= IsNull(@PurchaseReturnValue,0) ,
--			"@StockTransferOutValue"= IsNull(@StockTransferOutValue,0) 	,"@SalesValue"= IsNull(@SalesValue,0) ,"@StockDestructValue"= IsNull(@StockDestructValue,0), 
--			
--			"@NewFreeOpening" = @NewFreeOpening ,"@FreeOpening"= IsNull(@FreeOpening,0) ,"@FreePurchases"= IsNull(@FreePurchases,0), 
--			"@FreeReturns"= IsNull(@FreeReturns,0) ,"@FreeStockTransferIn"= IsNull(@FreeStockTransferIn,0) ,"@AdjustmentFree"= IsNull(@AdjustmentFree,0) ,
--			"@AdjReconcileFree"=IsNull(@AdjReconcileFree,0) ,"@ConversionFreeQty1"=IsNull(@ConversionFreeQty1,0) ,"@ConversionFreeQty2"= IsNull(@ConversionFreeQty2,0) ,
--			"@PurchaseReturnFree"= IsNull(@PurchaseReturnFree,0) ,"@FreeStockTransferOut"= IsNull(@FreeStockTransferOut,0) ,
--			"@FreeIssues"= IsNull(@FreeIssues,0) ,"@FreeStockDestructQty"= IsNull(@FreeStockDestructQty,0) ,
--  
--			"@NewDamageOpeningQty"= @NewDamageOpeningQty ,"@DamageOpeningQty"= IsNull(@DamageOpeningQty,0) ,"@SalesReturnDamages"= IsNull(@SalesReturnDamages,0) ,
--			"@AdjustmentDamages"= IsNull(@AdjustmentDamages,0) ,"@AdjustmentDamagesOthers"= IsNull(@AdjustmentDamagesOthers,0) ,
--			"@AdjReconcileDamages"= IsNull(@AdjReconcileDamages,0) ,"@PurchaseReturnDamages"= IsNull(@PurchaseReturnDamages,0) ,
--			"@DamageStockDestructQty"= IsNull(@DamageStockDestructQty,0),
--  
--			"@NewDamageOpeningValue"= @NewDamageOpeningValue ,"@DamageOpeningValue"= IsNull(@DamageOpeningValue,0) ,
--			"@SalesReturnDamagesValue"= IsNull(@SalesReturnDamagesValue,0) ,"@AdjustmentDamagesValue"= IsNull(@AdjustmentDamagesValue,0) ,
--			"@AdjustmentDamagesOthersValue"= IsNull(@AdjustmentDamagesOthersValue,0) ,"@AdjReconcileDamagesValue"= IsNull(@AdjReconcileDamagesValue,0) ,
--			"@PurchaseReturnDamagesValue"= IsNull(@PurchaseReturnDamagesValue,0) ,"@DamageStockDestructValue"= IsNull(@DamageStockDestructValue,0) ,
--  
--			"@NewFreeSaleable"= @NewFreeSaleable ,"@FreeSaleable"= IsNull(@FreeSaleable,0) ,"@FreePurchases"= IsNull(@FreePurchases,0) ,
--			"@FreeReturns"= IsNull(@FreeReturns,0) ,"@FreeStockTransferIn"= IsNull(@FreeStockTransferIn,0) ,"@AdjustmentFreeSaleable"= IsNull(@AdjustmentFreeSaleable,0), 
--			"@AdjReconcileFreeSaleable"= IsNull(@AdjReconcileFreeSaleable,0) ,"@ConversionFreeQty1"= IsNull(@ConversionFreeQty1,0) ,
--			"@ConversionFreeQty2"= IsNull(@ConversionFreeQty2,0),"@PurchaseReturnFree"= IsNull(@PurchaseReturnFree,0) ,
--			"@FreeStockTransferOut"= IsNull(@FreeStockTransferOut,0),"@FreeIssues"= IsNull(@FreeIssues,0)  ,
--			"@FreeSaleStockDestructQty"= IsNull(@FreeSaleStockDestructQty,0), "@AdjustmentFreeDamages" = IsNull(@AdjustmentFreeDamages,0)
---------------------------------------------------------------------------------------------------------------------------------------

	Update #Temp 
	Set Purchase = IsNull(@Purchases,0)  - IsNull(@FreePurchases,0),
	FreePurchase = IsNull(@FreePurchases,0),
	SalRtnSaleable = IsNull(@SalesReturnSaleable,0)-IsNull(@SalesReturnDamages,0),
	SalRtnDamage = IsNull(@SalesReturnDamages,0),
	Issue = IsNull(@Issues,0) - IsNull(@FreeIssues,0),
	FreeIssue = IsNull(@FreeIssues,0),
	PurRtn = IsNull(@PurchaseReturn,0),
	Adjusts = IsNull(@AdjustmentOthers,0) + IsNull(@AdjustmentDamages,0),
	STO = IsNull(@StockTransferOut,0),
	STI = IsNull(@StockTransferIn,0),
	Destruct = IsNull(@StockDestructQty,0)
	Where ItemCode = @ITEMCODE 
	And OpeningDate = @FirstTransactionDate

   IF @FirstTransactionDate < @ServerDate
   BEGIN  
		Insert Into #temp  (ItemCode, OpeningDate, OpeningQuantity, NewOpeningQuantity, OpeningValue, NewOpeningValue, FreeOpening, NewFreeOpening,
							DamageOpening, NewDamageOpening, DamageOpeningValue, NewDamageOpeningValue, FreeSaleable, NewFreeSaleable)
		Select Product_Code, Opening_Date, "Opening Quantity" = Opening_Quantity, "New Opening Quantity" = @NewOpeningQuantity,   
		"Opening Value" = Opening_Value, "New Opening Value" = @NewOpeningValue,   
		"Free Opening Quantity" = Free_Opening_Quantity, "New Free Opening Quantity" = @NewFreeOpening,   
		"Damage Opening Quantity" = Damage_Opening_Quantity, "New Damage Opening Quantity" = @NewDamageOpeningQty,  
		"Damage Opening Value" = Damage_Opening_Value, "New Damage Opening Value" = @NewDamageOpeningValue,  
		"Free Saleable Quantity" = Free_Saleable_Quantity, "New Free Saleable Quantity" = @NewFreeSaleable
		From OpeningDetails 
		Where Product_Code = @ITEMCODE 
		And Opening_Date = DateAdd(d, 1, @FirstTransactionDate) 
--		And (IsNull(Opening_Quantity,0) <> IsNull(@NewOpeningQuantity,0) 
--		Or IsNull(Free_Opening_Quantity,0) <> IsNull(@NewFreeOpening,0)  
--		Or IsNull(Damage_Opening_Quantity,0) <> IsNull(@NewDamageOpeningQty,0) 
--		Or IsNull(Damage_Opening_Value,0) <> IsNull(@NewDamageOpeningValue,0) 
--		Or IsNull(Opening_Value,0) <> IsNull(@NewOpeningValue,0) 
--		Or IsNull(Free_Saleable_Quantity,0) <> IsNull(@NewFreeSaleable,0))  

		Update OpeningDetails Set Opening_Quantity = @NewOpeningQuantity, Opening_Value = @NewOpeningValue,  
		Free_Opening_Quantity = @NewFreeOpening, Damage_Opening_Quantity = @NewDamageOpeningQty,   
		Damage_Opening_Value = @NewDamageOpeningValue, Free_Saleable_Quantity = @NewFreeSaleable
		Where Product_Code = @ITEMCODE And Opening_Date = DateAdd(d, 1, @FirstTransactionDate)  

		--Tax Suffered Percentage Calculation
		DECLARE GetOpeningDetailsTaxPer CURSOR STATIC FOR    
		SELECT Product_Code, 
		--Calculation : TaxPer = (Sum(TaxSufferedAmt)/Sum(Amt)) * 100  
		(Sum(DBO.FN_GetTaxSufferedAmt(Product_Code, IsNull(PurchasePrice,0), IsNull(Quantity, 0), IsNull(TaxSuffered,0), IsNull(ApplicableOn, 0), IsNull(PartOfPercentage, 0), Batch_Code)) /  
		Case When Sum(IsNull(Quantity, 0) *  IsNull(PurchasePrice, 0)) = 0 Then 1     
		Else Sum(IsNull(Quantity, 0) *  IsNull(PurchasePrice, 0)) End)*100,
		--Calculation for CST TaxSuffered Percentage
		Case When (Select IsNull(Vat,0) from Items Where Items.Product_Code=Batch_Products_Temp.Product_Code) = 1
		  	  Then (Sum(Case IsNull(Vat_Locality,0) When 2 Then DBO.FN_GetTaxSufferedAmt(Product_Code, IsNull(PurchasePrice,0), IsNull(Quantity, 0), IsNull(TaxSuffered,0), IsNull(ApplicableOn, 0), IsNull(PartOfPercentage, 0), Batch_Code) Else 0 End) /  
				  	  Case When Sum(IsNull(Quantity, 0) *  IsNull(PurchasePrice, 0)) = 0 Then 1     
				     Else Sum(IsNull(Quantity, 0) *  IsNull(PurchasePrice, 0)) End)*100 
			  Else 0 End  
		FROM Batch_Products_Temp 
		Where Product_Code = @ITEMCODE 
		GROUP BY Product_Code 

		OPEN GetOpeningDetailsTaxPer 
		FETCH FROM GetOpeningDetailsTaxPer INTO @Product_Code, @TaxSufferedPer, @CSTTaxSuffered    
		WHILE @@FETCH_STATUS = 0    
		BEGIN    
			--Updating Tax suffered percentage in Opening Details
			UPDATE OpeningDetails SET TaxSuffered_Value = @TaxSufferedPer, CST_TaxSuffered = @CSTTaxSuffered 
			WHERE Product_Code = @Product_Code and Opening_Date = DateAdd(d, 1, @FirstTransactionDate)
			FETCH NEXT FROM GetOpeningDetailsTaxPer INTO @Product_Code, @TaxSufferedPer, @CSTTaxSuffered    
		END    
		CLOSE GetOpeningDetailsTaxPer    
		DEALLOCATE GetOpeningDetailsTaxPer    
   END  
   ELSE  
   BEGIN  
    Set @Saleable = IsNull(@NewOpeningQuantity,0) - IsNull(@NewDamageOpeningQty,0) - IsNull(@NewFreeSaleable,0)  
    Select 
	@ActualQuantity = IsNull(Sum(case when IsNull(Free,0) = 0 And IsNull(Damage,0) = 0 then Quantity else 0 end),0),  
    @ActualFree = IsNull(Sum(case when IsNull(Free,0) = 1 And IsNull(Damage,0) = 0 then Quantity else 0 end),0),  
    @DamagesSaleable = IsNull(Sum(case when IsNull(Free,0) = 0 And IsNull(Damage,0) > 0 then Quantity else 0 end),0),  
    @DamagesFree = IsNull(Sum(case when IsNull(Free,0) = 1 And IsNull(Damage,0) > 0 then Quantity else 0 end),0)  
    From Batch_Products Where Product_Code = @ITEMCODE  

    SELECT 
	@VanQty = ISNULL(SUM(Pending), 0) FROM VanStatementDetail, VanStatementAbstract,Batch_Products 
    WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial AND (VanStatementAbstract.Status & 128) = 0    
    And VanStatementDetail.Product_Code = @ITEMCODE And VanStatementDetail.Batch_Code=Batch_Products.Batch_code 
    And ISNull(Batch_Products.free,0) = 0 And IsNull(Batch_Products.Damage,0) = 0
			
    SELECT  
	@VanFreeQty = ISNULL(SUM(Pending), 0) FROM VanStatementDetail, VanStatementAbstract,Batch_Products
    WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial AND (VanStatementAbstract.Status & 128) = 0 
    And VanStatementDetail.Product_Code = @ITEMCODE And VanStatementDetail.Batch_Code=Batch_Products.Batch_code 
    And ISNull(Batch_Products.free,0) = 1 And IsNull(Batch_Products.Damage,0) = 0   

-- Saleable Quantity calculation and updation
	Set @BPSaleableDiff = IsNull(@Saleable,0) - (IsNull(@ActualQuantity,0)  + IsNull(@VanQty,0))
	If IsNull(@BPSaleableDiff,0) > 0
	Begin
		Update Batch_Products Set Quantity = Quantity + IsNull(@BPSaleableDiff,0)
		Where Batch_Code = (Select Min(Batch_Code) From Batch_Products   
		Where Product_Code = @ITEMCODE And IsNull(Free,0) = 0 And IsNull(Damage,0) = 0)
	End
	If IsNull(@BPSaleableDiff,0) < 0
	Begin

		Declare BPStock Cursor for Select Batch_Code, Quantity From Batch_Products 
		Where Product_Code = @ITEMCODE 
		And Quantity > 0
		And IsNull(Free,0) = 0 
		And IsNull(Damage,0) = 0
		Order by Batch_Code
		Open BPStock
		Fetch From BPStock InTo @BatchCode, @CurrentStcok 
		While @@Fetch_Status = 0
		Begin
			If Abs(@BPSaleableDiff) > @CurrentStcok
			Begin
				Update Batch_Products Set Quantity = 0 Where Batch_Code = @BatchCode
				Set @BPSaleableDiff = @BPSaleableDiff + @CurrentStcok
			End
			Else
			Begin
				Update Batch_Products Set Quantity = Quantity + @BPSaleableDiff  Where Batch_Code = @BatchCode
				Set @BPSaleableDiff = 0
			End
			If @BPSaleableDiff = 0
				GoTo NextSaleable
			Fetch Next From BPStock InTo @BatchCode, @CurrentStcok 
		End
	NextSaleable:
		Close BPStock
		DeAllocate BPStock
		If IsNull(@BPSaleableDiff,0) < 0
		Begin
			Select @ImplicitBatchCode = Min(Batch_Code) From Batch_Products
			Where Product_Code = @ITEMCODE And IsNull(Free,0) = 0 And IsNull(Damage,0) = 0
			If IsNull(@ImplicitBatchCode,0) > 0
			Begin
				Select @ImplicitBatchNum = Batch_Number From Batch_Products Where Batch_Code = @ImplicitBatchCode
				Select @ImplicitAdjValue = Abs(@BPSaleableDiff) * PurchasePrice From Batch_Products Where Batch_Code = @ImplicitBatchCode
				Select TOP 1 @ImplicitAdjUser = UserName From Users
				UPDATE DocumentNumbers SET DocumentID = DocumentID + 1 WHERE DocType = 8  
				SELECT @ImplicitAdjDocID = DocumentID - 1 FROM DocumentNumbers WHERE DocType = 8  
				INSERT INTO StockAdjustmentAbstract(AdjustmentDate, AdjustmentValue, DocumentID, AdjustmentType, UserName,Remarks)  
				VALUES(@FirstTransactionDate, ABS(@ImplicitAdjValue), @ImplicitAdjDocID, 1, @ImplicitAdjUser,'Implicit Saleable stock Adjustment for FixOpening')  
				SELECT @ImplicitAdjDocID = max(AdjustmentID) FROM StockAdjustmentAbstract
				Insert into StockAdjustment (SerialNo,Product_Code,Batch_Code,Batch_Number,Quantity,Rate,ReasonID,OldQty,OldValue)
                Values(@ImplicitAdjDocID,@ITEMCODE,@ImplicitBatchCode,@ImplicitBatchNum,Abs(@BPSaleableDiff),Abs(@ImplicitAdjValue),0,0,0)
			End
		End
	End

--    If IsNull(@Saleable,0) <> (IsNull(@ActualQuantity,0)  + IsNull(@VanQty,0))
--    BEGIN  
--    Update Batch_Products Set Quantity = Quantity + IsNull(@Saleable,0) - IsNull(@ActualQuantity,0) - IsNull(@VanQty,0)
--    Where Batch_Code = (Select Min(Batch_Code) From Batch_Products   
--    Where Product_Code = @ITEMCODE And IsNull(Free,0) = 0 And IsNull(Damage,0) = 0  
--    And (Quantity + IsNull(@Saleable,0) - IsNull(@ActualQuantity,0) - IsNull(@VanQty,0)) >= 0)  
--    END  
  
-- Free Quantity calculation and updation
	Set @BPFreeDiff = IsNull(@NewFreeSaleable,0) - (IsNull(@ActualFree,0)  + IsNull(@VanFreeQty,0))
	If IsNull(@BPFreeDiff,0) > 0
	Begin
		Update Batch_Products Set Quantity = Quantity + IsNull(@BPFreeDiff,0)
		Where Batch_Code = (Select Min(Batch_Code) From Batch_Products   
		Where Product_Code = @ITEMCODE And IsNull(Free,0) = 1 And IsNull(Damage,0) = 0)
	End
	If IsNull(@BPFreeDiff,0) < 0
	Begin

		Declare BPStock Cursor for Select Batch_Code, Quantity From Batch_Products 
		Where Product_Code = @ITEMCODE 
		And Quantity > 0
		And IsNull(Free,0) = 1 
		And IsNull(Damage,0) = 0
		Order by Batch_Code
		Open BPStock
		Fetch From BPStock InTo @BatchCode, @CurrentStcok 
		While @@Fetch_Status = 0
		Begin
			If Abs(@BPFreeDiff) > @CurrentStcok
			Begin
				Update Batch_Products Set Quantity = 0 Where Batch_Code = @BatchCode
				Set @BPFreeDiff = @BPFreeDiff + @CurrentStcok
			End
			Else
			Begin
				Update Batch_Products Set Quantity = Quantity + @BPFreeDiff  Where Batch_Code = @BatchCode
				Set @BPFreeDiff = 0
			End
			If @BPFreeDiff = 0
				GoTo NextFree
			Fetch Next From BPStock InTo @BatchCode, @CurrentStcok 
		End
	NextFree:
		Close BPStock
		DeAllocate BPStock
		If IsNull(@BPFreeDiff,0) < 0
		Begin
			Select @ImplicitBatchCode = Min(Batch_Code) From Batch_Products
			Where Product_Code = @ITEMCODE And IsNull(Free,0) = 1 And IsNull(Damage,0) = 0
			If IsNull(@ImplicitBatchCode,0) > 0
			Begin
				Select @ImplicitBatchNum = Batch_Number From Batch_Products Where Batch_Code = @ImplicitBatchCode
				Select @ImplicitAdjValue = Abs(@BPFreeDiff) * PurchasePrice From Batch_Products Where Batch_Code = @ImplicitBatchCode
				Select TOP 1 @ImplicitAdjUser = UserName From Users
				UPDATE DocumentNumbers SET DocumentID = DocumentID + 1 WHERE DocType = 8  
				SELECT @ImplicitAdjDocID = DocumentID - 1 FROM DocumentNumbers WHERE DocType = 8  
				INSERT INTO StockAdjustmentAbstract(AdjustmentDate, AdjustmentValue, DocumentID, AdjustmentType, UserName,Remarks)  
				VALUES(@FirstTransactionDate, ABS(@ImplicitAdjValue), @ImplicitAdjDocID, 1, @ImplicitAdjUser,'Implicit Free Stock Adjustment for FixOpening')  
				SELECT @ImplicitAdjDocID = max(AdjustmentID) FROM StockAdjustmentAbstract
				Insert into StockAdjustment (SerialNo,Product_Code,Batch_Code,Batch_Number,Quantity,Rate,ReasonID,OldQty,OldValue)
                Values(@ImplicitAdjDocID,@ITEMCODE,@ImplicitBatchCode,@ImplicitBatchNum,Abs(@BPFreeDiff),Abs(@ImplicitAdjValue),0,0,0)
			End
		End
	End

--    If (IsNull(@ActualFree,0) + IsNull(@VanFreeQty,0)) <> @NewFreeSaleable
--    Update Batch_Products Set Quantity = Quantity + IsNull(@NewFreeSaleable,0) - IsNull(@ActualFree,0)  - IsNull(@VanFreeQty,0)
--    Where Batch_Code = (Select Min(Batch_Code) From Batch_Products   
--    Where Product_Code = @ITEMCODE And IsNull(Free,0) = 1 And IsNull(Damage,0) = 0
--    And (Quantity + IsNull(@NewFreeSaleable,0) - IsNull(@ActualFree,0) - IsNull(@VanFreeQty,0)) >= 0)
  
	-- Free Damage Quantity calculation and updation
	Set @BPFreeDamageDiff = IsNull(@NewFreeOpening,0) - IsNull(@NewFreeSaleable,0) - IsNull(@DamagesFree,0)

	If IsNull(@BPFreeDamageDiff,0) > 0
	Begin
		Update Batch_Products Set Quantity = Quantity + IsNull(@BPFreeDamageDiff,0)
		Where Batch_Code = (Select Min(Batch_Code) From Batch_Products   
		Where Product_Code = @ITEMCODE And IsNull(Free,0) = 1 And IsNull(Damage,0) > 0)
	End
	If IsNull(@BPFreeDamageDiff,0) < 0
	Begin

		Declare BPStock Cursor for Select Batch_Code, Quantity From Batch_Products 
		Where Product_Code = @ITEMCODE 
		And Quantity > 0
		And IsNull(Free,0) = 1 
		And IsNull(Damage,0) > 0
		Order by Batch_Code
		Open BPStock
		Fetch From BPStock InTo @BatchCode, @CurrentStcok 
		While @@Fetch_Status = 0
		Begin
			If Abs(@BPFreeDamageDiff) > @CurrentStcok
			Begin
				Update Batch_Products Set Quantity = 0 Where Batch_Code = @BatchCode
				Set @BPFreeDamageDiff = @BPFreeDamageDiff + @CurrentStcok
			End
			Else
			Begin
				Update Batch_Products Set Quantity = Quantity + @BPFreeDamageDiff  Where Batch_Code = @BatchCode
				Set @BPFreeDamageDiff = 0
			End
			If @BPFreeDamageDiff = 0
				GoTo NextFreeDamage
			Fetch Next From BPStock InTo @BatchCode, @CurrentStcok 
		End
	NextFreeDamage:
		Close BPStock
		DeAllocate BPStock
		If IsNull(@BPFreeDamageDiff,0) < 0
		Begin
			Select @ImplicitBatchCode = Min(Batch_Code) From Batch_Products
			Where Product_Code = @ITEMCODE And IsNull(Free,0) = 1 And IsNull(Damage,0) > 0
			If IsNull(@ImplicitBatchCode,0) > 0
			Begin
				Select @ImplicitBatchNum = Batch_Number From Batch_Products Where Batch_Code = @ImplicitBatchCode
				Select @ImplicitAdjValue = Abs(@BPFreeDamageDiff) * PurchasePrice From Batch_Products Where Batch_Code = @ImplicitBatchCode
				Select TOP 1 @ImplicitAdjUser = UserName From Users
				UPDATE DocumentNumbers SET DocumentID = DocumentID + 1 WHERE DocType = 8  
				SELECT @ImplicitAdjDocID = DocumentID - 1 FROM DocumentNumbers WHERE DocType = 8  
				INSERT INTO StockAdjustmentAbstract(AdjustmentDate, AdjustmentValue, DocumentID, AdjustmentType, UserName,Remarks)  
				VALUES(@FirstTransactionDate, ABS(@ImplicitAdjValue), @ImplicitAdjDocID, 1, @ImplicitAdjUser,'Implicit Free Damage Stock Adjustment for FixOpening')  
				SELECT @ImplicitAdjDocID = max(AdjustmentID) FROM StockAdjustmentAbstract
				Insert into StockAdjustment (SerialNo,Product_Code,Batch_Code,Batch_Number,Quantity,Rate,ReasonID,OldQty,OldValue)
                Values(@ImplicitAdjDocID,@ITEMCODE,@ImplicitBatchCode,@ImplicitBatchNum,Abs(@BPFreeDamageDiff),Abs(@ImplicitAdjValue),0,0,0)
			End
		End
	End

--    If IsNull(@NewFreeOpening,0)-IsNull(@NewFreeSaleable,0) <> @DamagesFree  
--    Update Batch_Products Set Quantity = Quantity + (IsNull(@NewFreeOpening,0)-IsNull(@NewFreeSaleable,0)) - IsNull(@DamagesFree,0)  
--    Where Batch_Code = (Select Min(Batch_Code) From Batch_Products Where   
--    Product_Code = @ITEMCODE And IsNull(Free,0) = 1 And IsNull(Damage,0) > 0
--    And  (Quantity + (IsNull(@NewFreeOpening,0)-IsNull(@NewFreeSaleable,0)) - IsNull(@DamagesFree,0)) >= 0)  
  
-- Damage Quantity calculation and updations
	Set @ActualDamagesSaleable = IsNull(@NewDamageOpeningQty,0) - (IsNull(@NewFreeOpening,0)-IsNull(@NewFreeSaleable,0))
	Set @BPDamageDiff = IsNull(@ActualDamagesSaleable,0) - IsNull(@DamagesSaleable,0) 

	If IsNull(@BPDamageDiff,0) > 0
	Begin
		Update Batch_Products Set Quantity = Quantity + IsNull(@BPDamageDiff,0)
		Where Batch_Code = (Select Min(Batch_Code) From Batch_Products   
		Where Product_Code = @ITEMCODE And IsNull(Free,0) = 0 And IsNull(Damage,0) > 0)
	End
	If IsNull(@BPDamageDiff,0) < 0
	Begin

		Declare BPStock Cursor for Select Batch_Code, Quantity From Batch_Products 
		Where Product_Code = @ITEMCODE 
		And Quantity > 0
		And IsNull(Free,0) = 0 
		And IsNull(Damage,0) > 0
		Order by Batch_Code
		Open BPStock
		Fetch From BPStock InTo @BatchCode, @CurrentStcok 
		While @@Fetch_Status = 0
		Begin
			If Abs(@BPDamageDiff) > @CurrentStcok
			Begin
				Update Batch_Products Set Quantity = 0 Where Batch_Code = @BatchCode
				Set @BPDamageDiff = @BPDamageDiff + @CurrentStcok
			End
			Else
			Begin
				Update Batch_Products Set Quantity = Quantity + @BPDamageDiff  Where Batch_Code = @BatchCode
				Set @BPDamageDiff = 0
			End
			If @BPFreeDamageDiff = 0
				GoTo NextDamage
			Fetch Next From BPStock InTo @BatchCode, @CurrentStcok 
		End
	NextDamage:
		Close BPStock
		DeAllocate BPStock
		If IsNull(@BPDamageDiff,0) < 0
		Begin
			Select @ImplicitBatchCode = Min(Batch_Code) From Batch_Products
			Where Product_Code = @ITEMCODE And IsNull(Free,0) = 0 And IsNull(Damage,0) > 0
			If IsNull(@ImplicitBatchCode,0) > 0
			Begin
				Select @ImplicitBatchNum = Batch_Number From Batch_Products Where Batch_Code = @ImplicitBatchCode
				Select @ImplicitAdjValue = Abs(@BPDamageDiff) * PurchasePrice From Batch_Products Where Batch_Code = @ImplicitBatchCode
				Select TOP 1 @ImplicitAdjUser = UserName From Users
				UPDATE DocumentNumbers SET DocumentID = DocumentID + 1 WHERE DocType = 8  
				SELECT @ImplicitAdjDocID = DocumentID - 1 FROM DocumentNumbers WHERE DocType = 8  
				INSERT INTO StockAdjustmentAbstract(AdjustmentDate, AdjustmentValue, DocumentID, AdjustmentType, UserName,Remarks)  
				VALUES(@FirstTransactionDate, ABS(@ImplicitAdjValue), @ImplicitAdjDocID, 1, @ImplicitAdjUser,'Implicit Damage stock Adjustment for FixOpening')  
				SELECT @ImplicitAdjDocID = max(AdjustmentID) FROM StockAdjustmentAbstract
				Insert into StockAdjustment (SerialNo,Product_Code,Batch_Code,Batch_Number,Quantity,Rate,ReasonID,OldQty,OldValue)
                Values(@ImplicitAdjDocID,@ITEMCODE,@ImplicitBatchCode,@ImplicitBatchNum,Abs(@BPDamageDiff),Abs(@ImplicitAdjValue),0,0,0)
			End
		End
	End

--    Set @ActualDamagesSaleable = @NewDamageOpeningQty - (IsNull(@NewFreeOpening,0)-IsNull(@NewFreeSaleable,0))  
--    If IsNull(@ActualDamagesSaleable,0) <> IsNull(@DamagesSaleable,0)  
--    Update Batch_Products Set Quantity = Quantity + IsNull(@ActualDamagesSaleable,0) - IsNull(@DamagesSaleable,0)  
--    Where Batch_Code = (Select Min(Batch_Code) From Batch_Products Where   
--    Product_Code = @ITEMCODE And IsNull(Free,0) = 0 And IsNull(Damage,0) > 0  
--    And (Quantity + IsNull(@ActualDamagesSaleable,0) - IsNull(@DamagesSaleable,0)) >= 0)  

   END  
   Fetch Next From GetOpeningDetails Into @OpeningQuantity, @OpeningValue,   
   @FreeOpening, @DamageOpeningQty, @DamageOpeningValue, @FreeSaleable  
  End  
  Close GetOpeningDetails  
  DeAllocate GetOpeningDetails  
  Set @FirstTransactionDate = DateAdd(d, 1, @FirstTransactionDate)  
 END  
END  

DateNullExit:

Select * From #temp  
Drop Table #temp  
Drop Table #InvoiceDetail
Drop Table #DispatchDetail
