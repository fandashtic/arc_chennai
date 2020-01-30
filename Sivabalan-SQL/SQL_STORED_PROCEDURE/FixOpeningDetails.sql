CREATE PROCEDURE FixOpeningDetails  
AS  
DECLARE @FirstTransactionDate datetime  
DECLARE @ToDate datetime  
DECLARE @ServerDate datetime  
DECLARE @ITEMCODE nvarchar(15)  
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
DECLARE @OnceOnly int  
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

if exists (select * from dbo.sysobjects where id = object_id(N'[OpeningDetailsBackup]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)  
drop table [OpeningDetailsBackup]  
  
if exists (select * from dbo.sysobjects where id = object_id(N'[InvoiceDetailBackup]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)  
drop table [InvoiceDetailBackup]  
  
if exists (select * from dbo.sysobjects where id = object_id(N'[Batch_ProductsBackup]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)  
drop table [Batch_ProductsBackup]  
  
Select * into OpeningDetailsBackup From OpeningDetails  
Select * into InvoiceDetailBackup From InvoiceDetail  
Select * into Batch_ProductsBackup From Batch_Products  

SET @OnceOnly = 0  
Create table #temp(ItemCode nvarchar(15), OpeningDate datetime, OpeningQuantity Decimal(18,6), NewOpeningQuantity Decimal(18,6),   
  OpeningValue Decimal(18,6), NewOpeningValue Decimal(18,6), FreeOpening Decimal(18,6),   
  NewFreeOpening Decimal(18,6), DamageOpening Decimal(18,6), NewDamageOpening Decimal(18,6),   
  DamageOpeningValue Decimal(18,6), NewDamageOpeningValue Decimal(18,6), FreeSaleable Decimal(18,6),   
  NewFreeSaleable Decimal(18,6))  
  
Update Batch_Products Set Batch_Products.PurchasePrice = (Case Items.Purchased_At When 1 Then Batch_Products.PTS Else Batch_Products.PTR End)  
From Batch_Products, Items  
Where Batch_Products.Product_Code = Items.Product_Code And IsNull(Batch_Products.PurchasePrice, 0) = 0  

--In order to update Tax Suffered Percentage day by day in OpeningDetails 
--Here we are creating a temp table for Batch_Products
If Exists (Select * From DBO.SysObjects Where Id = Object_ID(N'[Batch_Products_Temp]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)  
Drop Table [Batch_Products_Temp]  
Select * into Batch_Products_Temp From Batch_Products  
Update Batch_Products_Temp Set Quantity=Case When IsNull(Doctype,0) = 6 then IsNull(QuantityReceived,0) Else 0 End

--If Batch_Code = 0 for Sold items  
Update InvoiceDetail Set InvoiceDetail.Batch_Code =   
 (select Min(Batch_Products.Batch_Code) From Batch_Products   
 Where Batch_Products.Product_Code = InvoiceDetail.Product_Code   
 And IsNull(Batch_Products.Free,0) = 0 And IsNull(Batch_Products.Damage,0) = 0)  
From InvoiceDetail, InvoiceAbstract  
Where  InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And   
 (InvoiceDetail.SalePrice <> 0 or (InvoiceDetail.SalePrice = 0 And InvoiceDetail.PurchasePrice <> 0)) And IsNull(InvoiceDetail.Batch_Code,0) = 0 And  
 (InvoiceAbstract.Status & 32) = 0 And (InvoiceAbstract.Status & 128) = 0  
   
--If Batch_Code = 0 for Free items  
Update InvoiceDetail Set InvoiceDetail.Batch_Code =   
 (select Min(Batch_Products.Batch_Code) From Batch_Products   
 Where Batch_Products.Product_Code = InvoiceDetail.Product_Code   
 And IsNull(Batch_Products.Free,0) = 1 And IsNull(Batch_Products.Damage,0) = 0)  
From InvoiceDetail, InvoiceAbstract  
Where  InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And   
 InvoiceDetail.SalePrice = 0 And InvoiceDetail.PurchasePrice = 0 And IsNull(InvoiceDetail.Batch_Code,0) = 0 And   
 (InvoiceAbstract.Status & 32) = 0 And (InvoiceAbstract.Status & 128) = 0  
  
--If Batch_Code = 0 for Damage items  
Update InvoiceDetail Set InvoiceDetail.Batch_Code =   
 (select Min(Batch_Products.Batch_Code) From Batch_Products   
 Where Batch_Products.Product_Code = InvoiceDetail.Product_Code   
 And IsNull(Batch_Products.Free,0) = 0 And IsNull(Batch_Products.Damage,0) = 1)  
From InvoiceDetail, InvoiceAbstract  
Where  InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And   
 InvoiceDetail.SalePrice <> 0 And IsNull(InvoiceDetail.Batch_Code,0) = 0 And  
 (InvoiceAbstract.Status & 32) <> 0 And (InvoiceAbstract.Status & 128) = 0  

Set DateFormat dmy  
Select @ServerDate = dbo.StripDateFromTime(IsNull(Operating_Date, GetDate())) From Setup  
Select @FirstTransactionDate = Min(Opening_Date) From OpeningDetails  
IF @FirstTransactionDate Is Not Null  
BEGIN  
 While @FirstTransactionDate <= @ServerDate  
 BEGIN  
  Set @ToDate = DateAdd(s, 0 - 1, DateAdd(hh, 24, @FirstTransactionDate))  
  DECLARE GetOpeningDetails CURSOR KEYSET FOR  
  Select  Product_Code, Opening_Quantity, Opening_Value, IsNull(Free_Opening_Quantity,0),  
  IsNull(Damage_Opening_Quantity,0), IsNull(Damage_Opening_Value,0), IsNull(Free_Saleable_Quantity,0)  
  From OpeningDetails Where Opening_Date = @FirstTransactionDate  

  SET @OnceOnly = 1  
  Open GetOpeningDetails  
  Fetch From GetOpeningDetails Into @ITEMCODE, @OpeningQuantity, @OpeningValue,   
  @FreeOpening, @DamageOpeningQty, @DamageOpeningValue, @FreeSaleable  
  While @@Fetch_Status = 0  
  begin  
   Select @Purchases = Sum(QuantityReceived), @PurchaseValue = Sum(QuantityReceived*PurchasePrice), @FreePurchases = Sum(case IsNull(Free,0) when 1 then QuantityReceived else 0 end)  
   From Batch_Products  
   Where Product_Code = @ITEMCODE And GRN_ID In   
   (Select GRNAbstract.GRNID From GRNAbstract, GRNDetail   
   Where GRNDate Between @FirstTransactionDate AND @TODATE And   
   GRNAbstract.GRNID = GRNDetail.GRNID And GRNDetail.Product_Code = @ITEMCODE And  
   (GRNAbstract.GRNStatus & 64) = 0 And (GRNAbstract.GRNStatus & 32) = 0)  
  
	--Adding Purchase Qty in Batch_Products_Temp
	Update Batch_Products_Temp Set Quantity = Quantity + QuantityReceived 
	Where Product_Code = @ITEMCODE And GRN_ID In   
   (Select GRNAbstract.GRNID From GRNAbstract, GRNDetail   
   Where GRNDate Between @FirstTransactionDate AND @TODATE And   
   GRNAbstract.GRNID = GRNDetail.GRNID And GRNDetail.Product_Code = @ITEMCODE And  
   (GRNAbstract.GRNStatus & 64) = 0 And (GRNAbstract.GRNStatus & 32) = 0)  

   SELECT @SalesReturnSaleable = SUM(Quantity), @SalesReturnValue = Sum(PurchasePrice),  
   @SalesReturnDamages = Sum(Case When (Status & 32) <> 0 Then Quantity Else 0 end),   
   @SalesReturnDamagesValue = Sum(Case When (Status & 32) <> 0 Then PurchasePrice Else 0 end),  
   @FreeReturns = Sum(case SalePrice When 0 Then Quantity Else 0 End)  
   FROM InvoiceDetail, InvoiceAbstract   
   WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID   
   AND (InvoiceAbstract.InvoiceType = 4)   
   AND (InvoiceAbstract.Status & 128) = 0   
   AND InvoiceDetail.Product_Code = @ITEMCODE  
   AND InvoiceAbstract.InvoiceDate BETWEEN @FirstTransactionDate AND @TODATE  
   
	--Adding SalesReturnSaleable Qty to Batch_Products_Temp
	Update Batch_Products_Temp 
	Set Batch_Products_Temp.Quantity = Batch_Products_Temp.Quantity + 
		(Select Sum(InvoiceDetail.Quantity) 
		From InvoiceDetail, InvoiceAbstract   
		WHERE InvoiceDetail.Batch_Code=Batch_Products_Temp.Batch_Code
		AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID   
	   AND (InvoiceAbstract.InvoiceType = 4)   
	   AND (InvoiceAbstract.Status & 128) = 0   
	   AND InvoiceDetail.Product_Code = @ITEMCODE  
	   AND InvoiceAbstract.InvoiceDate BETWEEN @FirstTransactionDate AND @TODATE)
	From Batch_Products_Temp, InvoiceDetail, InvoiceAbstract   
	WHERE InvoiceDetail.Batch_Code=Batch_Products_Temp.Batch_Code
	AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID   
   AND (InvoiceAbstract.InvoiceType = 4)   
   AND (InvoiceAbstract.Status & 128) = 0   
   AND InvoiceDetail.Product_Code = @ITEMCODE  
   AND InvoiceAbstract.InvoiceDate BETWEEN @FirstTransactionDate AND @TODATE  
	
	SELECT @Issues = SUM(Quantity), @SalesValue = Sum(PurchasePrice),   
   @FreeIssues = Sum(Case When SalePrice = 0 And PurchasePrice = 0 Then Quantity Else 0 End)  
   FROM InvoiceDetail, InvoiceAbstract   
   WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID   
   AND (InvoiceAbstract.InvoiceType in (1,2,3))   
   AND (InvoiceAbstract.Status & 128) = 0   
   AND InvoiceDetail.Product_Code = @ITEMCODE  
   AND InvoiceAbstract.InvoiceDate BETWEEN @FirstTransactionDate AND @TODATE  

	--Deducting Invoice Qty from Batch_Products_Temp
	Update Batch_Products_Temp 
	Set Batch_Products_Temp.Quantity = Batch_Products_Temp.Quantity - 
			(Select Sum(InvoiceDetail.Quantity) 
			From InvoiceDetail, InvoiceAbstract   	
			WHERE InvoiceDetail.Batch_Code = Batch_Products_Temp.Batch_Code
			AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID   
		   AND (InvoiceAbstract.InvoiceType in (1,2,3))   
		   AND (InvoiceAbstract.Status & 128) = 0   
		   AND InvoiceDetail.Product_Code = @ITEMCODE  
		   AND InvoiceAbstract.InvoiceDate BETWEEN @FirstTransactionDate AND @TODATE)
	From Batch_Products_Temp, InvoiceDetail, InvoiceAbstract   	
	WHERE InvoiceDetail.Batch_Code = Batch_Products_Temp.Batch_Code
	AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID   
   AND (InvoiceAbstract.InvoiceType in (1,2,3))   
   AND (InvoiceAbstract.Status & 128) = 0   
   AND InvoiceDetail.Product_Code = @ITEMCODE  
   AND InvoiceAbstract.InvoiceDate BETWEEN @FirstTransactionDate AND @TODATE  	
  
   SELECT @Issues = IsNull(@Issues,0) + IsNull(SUM(DispatchDetail.Quantity),0), @SalesValue = IsNull(@SalesValue,0) + IsNull(Sum(DispatchDetail.Quantity*Batch_Products.PurchasePrice),0),   
   @FreeIssues = IsNull(@FreeIssues, 0) + IsNull(Sum(Case When DispatchDetail.SalePrice = 0 And Batch_Products.PurchasePrice = 0 Then DispatchDetail.Quantity Else 0 End),0)  
   FROM DispatchAbstract, DispatchDetail, Batch_Products  
   WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID   
   AND (DispatchAbstract.Status & 128) = 0   
   AND DispatchDetail.Product_Code = @ITEMCODE  
   AND DispatchAbstract.DispatchDate BETWEEN @FirstTransactionDate AND @TODATE  
   And DispatchDetail.Batch_code = Batch_Products.Batch_Code  

	--Deducting Dispatch Qty from Batch_Products_Temp
	Update Batch_Products_Temp 
	Set Batch_Products_Temp.Quantity = Batch_Products_Temp.Quantity - 
			(Select Sum(DispatchDetail.Quantity)
			From DispatchAbstract, DispatchDetail
		   WHERE DispatchDetail.Batch_Code = Batch_Products_Temp.Batch_Code
			AND DispatchAbstract.DispatchID = DispatchDetail.DispatchID   
		   AND (DispatchAbstract.Status & 128) = 0   
		   AND DispatchDetail.Product_Code = @ITEMCODE  
		   AND DispatchAbstract.DispatchDate BETWEEN @FirstTransactionDate AND @TODATE)
	From Batch_Products_Temp, DispatchAbstract, DispatchDetail
   WHERE DispatchDetail.Batch_Code = Batch_Products_Temp.Batch_Code
	AND DispatchAbstract.DispatchID = DispatchDetail.DispatchID   
   AND (DispatchAbstract.Status & 128) = 0   
   AND DispatchDetail.Product_Code = @ITEMCODE  
   AND DispatchAbstract.DispatchDate BETWEEN @FirstTransactionDate AND @TODATE  

   Select @StockTransferOut = Sum(Quantity), @StockTransferOutValue = Sum(Quantity*Rate),  
   @FreeStockTransferOut = Sum(Case Rate When 0 Then Quantity Else 0 End)  
   From StockTransferOutAbstract, StockTransferOutDetail  
   Where StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial  
	AND (StockTransferOutAbstract.Status & 128) = 0 AND (StockTransferOutAbstract.Status & 64) = 0   
	And StockTransferOutAbstract.DocumentDate Between @FirstTransactionDate And @ToDate   
   And StockTransferOutDetail.Product_Code = @ITEMCODE  

	--Deducting STO Qty from Batch_Products_Temp
	Update Batch_Products_Temp 
	Set Batch_Products_Temp.Quantity = Batch_Products_Temp.Quantity - 
		(Select Sum(StockTransferOutDetail.Quantity)
		From StockTransferOutAbstract, StockTransferOutDetail  
		Where StockTransferOutDetail.Batch_Code = Batch_Products_Temp.Batch_Code
		AND StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial  
		AND (StockTransferOutAbstract.Status & 128) = 0 AND (StockTransferOutAbstract.Status & 64) = 0
	   And StockTransferOutAbstract.DocumentDate Between @FirstTransactionDate And @ToDate   
	   And StockTransferOutDetail.Product_Code = @ITEMCODE )
	From Batch_Products_Temp, StockTransferOutAbstract, StockTransferOutDetail  
	Where StockTransferOutDetail.Batch_Code = Batch_Products_Temp.Batch_Code
	AND StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial  
	AND (StockTransferOutAbstract.Status & 128) = 0 AND (StockTransferOutAbstract.Status & 64) = 0
   And StockTransferOutAbstract.DocumentDate Between @FirstTransactionDate And @ToDate   
   And StockTransferOutDetail.Product_Code = @ITEMCODE  	
  
   Select @StockTransferIn = Sum(Quantity),  @StockTransferInValue = Sum(Quantity*Rate),  
   @FreeStockTransferIn = Sum(Case Rate When 0 Then Quantity Else 0 End)  
   From StockTransferInAbstract, StockTransferInDetail   
   Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial  
	AND (StockTransferInAbstract.Status & 128) = 0 AND (StockTransferInAbstract.Status & 64) = 0
   And StockTransferInAbstract.DocumentDate Between @FirstTransactionDate And @ToDate   
   And StockTransferInDetail.Product_Code = @ITEMCODE  
  
	--Adding STI Qty to Batch_Products_Temp
	Update Batch_Products_Temp 
	Set Batch_Products_Temp.Quantity = Batch_Products_Temp.Quantity + StockTransferInDetail.Quantity
	From Batch_Products_Temp, StockTransferInAbstract, StockTransferInDetail  
   Where StockTransferInDetail.Batch_Code = Batch_Products_Temp.Batch_Code
	AND StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial  
	AND (StockTransferInAbstract.Status & 128) = 0 AND (StockTransferInAbstract.Status & 64) = 0
   And StockTransferInAbstract.DocumentDate Between @FirstTransactionDate And @ToDate   
   And StockTransferInDetail.Product_Code = @ITEMCODE  

   SELECT @AdjustmentOthers = SUM(Case ISNULL(AdjustmentType,0) When 1 Then StockAdjustment.Quantity - OldQty Else 0 End),   
   @AdjustmentValue = SUM(Case ISNULL(AdjustmentType,0) When 1 Then Rate - OldValue Else 0 End),   
   @AdjustmentDamages = SUM(Case ISNULL(AdjustmentType,0) When 0 Then StockAdjustment.Quantity Else 0 End),   
   @AdjustmentDamagesValue = IsNull(Sum(case ISNULL(AdjustmentType,0) When 0 Then Rate Else 0 End),0),  
   @AdjustmentFree = Sum(Case When ISNULL(AdjustmentType,0) = 1 AND IsNull(Free,0)=1 Then StockAdjustment.Quantity - OldQty Else 0 end),  
   @AdjustmentFreeSaleable = Sum(Case When ISNULL(AdjustmentType,0) = 1 AND IsNull(Free,0)=1 And IsNull(Damage,0)=0 Then StockAdjustment.Quantity - OldQty Else 0 end),  
   @AdjustmentDamagesOthers = SUM(Case When ISNULL(AdjustmentType,0) = 1 And IsNull(Batch_Products.Damage,0)>0 Then StockAdjustment.Quantity - OldQty Else 0 End),   
   @AdjustmentDamagesOthersValue = SUM(Case When ISNULL(AdjustmentType,0) = 1 And IsNull(Batch_Products.Damage,0)>0 Then Rate - OldValue Else 0 End)  
   FROM StockAdjustment, StockAdjustmentAbstract, Batch_Products  
   WHERE StockAdjustment.Product_Code = @ITEMCODE  
   And StockAdjustment.Batch_Code = Batch_Products.Batch_Code  
   AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID  
   AND AdjustmentDate BETWEEN @FirstTransactionDate AND @TODATE  

	--Adding AdjustmentOthers Qty to Batch_Products_Temp
	Update Batch_Products_Temp 
	Set Quantity = Batch_Products_Temp.Quantity + 
		(Select Sum(IsNull(StockAdjustment.Quantity,0)) - Sum(IsNull(StockAdjustment.OldQty,0))  
		From StockAdjustmentAbstract, StockAdjustment 
	   Where StockAdjustment.Batch_Code = Batch_Products_Temp.Batch_Code
		AND StockAdjustment.Product_Code = @ITEMCODE  
	   AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID 
		AND IsNull(StockAdjustmentAbstract.AdjustmentType,0) = 1
	   AND StockAdjustmentAbstract.AdjustmentDate BETWEEN @FirstTransactionDate AND @TODATE)  
	From Batch_Products_Temp, StockAdjustmentAbstract, StockAdjustment 
   Where StockAdjustment.Batch_Code = Batch_Products_Temp.Batch_Code
	AND StockAdjustment.Product_Code = @ITEMCODE  
   AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID 
	AND IsNull(StockAdjustmentAbstract.AdjustmentType,0) = 1
   AND StockAdjustmentAbstract.AdjustmentDate BETWEEN @FirstTransactionDate AND @TODATE

	--Handling Openings for Physical Stock Reconcilation
   SELECT @AdjReconcile = SUM(StockAdjustment.Quantity - OldQty),   
   @AdjReconcileValue = SUM(Rate - OldValue),   
   @AdjReconcileFree = Sum(Case When ISNULL(BP.Free,0)=1 Then StockAdjustment.Quantity - OldQty Else 0 end),  
   @AdjReconcileFreeSaleable = Sum(Case When IsNull(BP.Free,0)=1 And IsNull(BP.Damage,0)=0 Then StockAdjustment.Quantity - OldQty Else 0 end),  
   @AdjReconcileDamages = SUM(Case When IsNull(BP.Damage,0)>0 Then StockAdjustment.Quantity - OldQty Else 0 End),   
   @AdjReconcileDamagesValue = SUM(Case When IsNull(BP.Damage,0)>0 Then Rate - OldValue Else 0 End)  
   FROM StockAdjustment, StockAdjustmentAbstract, Batch_Products BP  
   WHERE BP.Batch_Code = StockAdjustment.Batch_Code 
   And StockAdjustment.Product_Code = @ITEMCODE  
   AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID 
   AND StockAdjustmentAbstract.AdjustmentDate BETWEEN @FirstTransactionDate AND @TODATE  
	AND IsNull(StockAdjustmentAbstract.AdjustmentType,0) = 3
   
	--Adding AdjReconcile Qty to Batch_Products_Temp
	Update Batch_Products_Temp 
	Set Batch_Products_Temp.Quantity = Batch_Products_Temp.Quantity + 
		(Select Sum(StockAdjustment.Quantity) - Sum(StockAdjustment.OldQty) 
		from StockAdjustmentAbstract, StockAdjustment 
	   Where StockAdjustment.Batch_Code = Batch_Products_Temp.Batch_Code	
		AND StockAdjustment.Product_Code = @ITEMCODE  
	   AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID  
	   AND StockAdjustmentAbstract.AdjustmentDate BETWEEN @FirstTransactionDate AND @TODATE  
		AND IsNull(StockAdjustmentAbstract.AdjustmentType,0) = 3)
	From Batch_Products_Temp, StockAdjustmentAbstract, StockAdjustment 
   Where StockAdjustment.Batch_Code = Batch_Products_Temp.Batch_Code	
	AND StockAdjustment.Product_Code = @ITEMCODE  
   AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID  
   AND StockAdjustmentAbstract.AdjustmentDate BETWEEN @FirstTransactionDate AND @TODATE  
	AND IsNull(StockAdjustmentAbstract.AdjustmentType,0) = 3

   SELECT @PurchaseReturn = SUM(AdjustmentReturnDetail.Quantity), @PurchaseReturnValue = Sum(AdjustmentReturnDetail.Quantity * AdjustmentReturnDetail.Rate),   
   @PurchaseReturnFree = Sum(Case AdjustmentReturnDetail.Rate When 0 Then AdjustmentReturnDetail.Quantity Else 0 End),  
   @PurchaseReturnDamages = Sum(Case When IsNull(Damage,0) > 0 Then AdjustmentReturnDetail.Quantity Else 0 End),  
   @PurchaseReturnDamagesValue = Sum(Case When IsNull(Damage,0) > 0 Then AdjustmentReturnDetail.Quantity * AdjustmentReturnDetail.Rate Else 0 End)  
   FROM AdjustmentReturnDetail, AdjustmentReturnAbstract, Batch_Products  
   WHERE AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID   
   And AdjustmentReturnDetail.Batchcode = Batch_Products.Batch_Code   
   AND AdjustmentReturnDetail.Product_Code = @ITEMCODE  
   AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FirstTransactionDate AND @TODATE   
   And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 64) = 0  
   
	--Deducting PurchaseReturn Qty from Batch_Products_Temp
	Update Batch_Products_Temp 
	Set Batch_Products_Temp.Quantity = Batch_Products_Temp.Quantity - 
		(Select Sum(AdjustmentReturnDetail.Quantity)
		From AdjustmentReturnAbstract, AdjustmentReturnDetail 
	   Where AdjustmentReturnDetail.BatchCode = Batch_Products_Temp.Batch_Code	
	   AND AdjustmentReturnDetail.Product_Code = @ITEMCODE  
		AND AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID   
	   AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FirstTransactionDate AND @TODATE   
	   And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 64) = 0)
	From Batch_Products_Temp, AdjustmentReturnAbstract, AdjustmentReturnDetail 
   Where AdjustmentReturnDetail.BatchCode = Batch_Products_Temp.Batch_Code	
   AND AdjustmentReturnDetail.Product_Code = @ITEMCODE  
	AND AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID   
   AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FirstTransactionDate AND @TODATE   
   And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 64) = 0  

	--Handling Openings for Stock Destruction
	Select @StockDestructQty = SUM(IsNull(StockDestructionDetail.DestroyQuantity,0)), 
	@StockDestructValue = Sum(BP.PurchasePrice * IsNull(StockDestructionDetail.DestroyQuantity,0)),
	@FreeStockDestructQty = Sum(Case IsNull(BP.Free,0) When 1 Then IsNull(StockDestructionDetail.DestroyQuantity,0) Else 0 End),
	@FreeSaleStockDestructQty = Sum(Case When IsNull(BP.Free,0) = 1 AND IsNull(BP.Damage,0) = 0 Then IsNull(StockDestructionDetail.DestroyQuantity,0) Else 0 End),
	@DamageStockDestructQty = Sum(Case IsNull(BP.Damage,0) When 1 Then IsNull(StockDestructionDetail.DestroyQuantity,0) Else 0 End),
	@DamageStockDestructValue = Sum(Case IsNull(BP.Damage,0) When 1 Then BP.PurchasePrice * IsNull(StockDestructionDetail.DestroyQuantity,0) Else 0 End)
	From Batch_Products BP, StockDestructionAbstract, StockDestructionDetail
	Where BP.Batch_Code = StockDestructionDetail.BatchCode AND
	StockDestructionDetail.Product_Code = @ITEMCODE AND
	StockDestructionDetail.DocSerial = StockDestructionAbstract.DocSerial AND
	StockDestructionAbstract.DocumentDate BETWEEN @FirstTransactionDate AND @TODATE	

	--Deducting StockDestruction Qty from Batch_Products_Temp
	Update Batch_Products_Temp 
	Set Batch_Products_Temp.Quantity = Batch_Products_Temp.Quantity - 
		(Select Sum(IsNull(StockDestructionDetail.DestroyQuantity,0))
		From StockDestructionAbstract, StockDestructionDetail
	   Where StockDestructionDetail.BatchCode = Batch_Products_Temp.Batch_Code	
		AND StockDestructionDetail.Product_Code = @ITEMCODE	
		AND StockDestructionDetail.DocSerial = StockDestructionAbstract.DocSerial	
		AND StockDestructionAbstract.DocumentDate BETWEEN @FirstTransactionDate AND @TODATE	)
	From Batch_Products_Temp, StockDestructionAbstract, StockDestructionDetail
   Where StockDestructionDetail.BatchCode = Batch_Products_Temp.Batch_Code	
	AND StockDestructionDetail.Product_Code = @ITEMCODE	
	AND StockDestructionDetail.DocSerial = StockDestructionAbstract.DocSerial	
	AND StockDestructionAbstract.DocumentDate BETWEEN @FirstTransactionDate AND @TODATE	

	--Handling Openings for Free2Saleable Conversion
	Select @ConversionSaleableValue1 = SUM((BP.PurchasePrice * IsNull(ConversionDetail.Quantity,0))),
	@ConversionFreeQty1 = - SUM(IsNull(ConversionDetail.Quantity,0))
	From Batch_Products BP, ConversionAbstract, ConversionDetail
	Where ConversionDetail.Product_Code = @ITEMCODE AND
	BP.Batch_Code = ConversionDetail.NewBatchCode AND
	ConversionDetail.DocSerial = ConversionAbstract.DocSerial AND
	ConversionAbstract.DocumentDate BETWEEN @FirstTransactionDate AND @TODATE AND
	ConversionAbstract.ConversionType = 1

	--Handling Openings for Saleable2Free Conversion
	Select @ConversionSaleableValue2 = - SUM((BP.PurchasePrice * IsNull(ConversionDetail.Quantity,0))),
	@ConversionFreeQty2 = SUM(IsNull(ConversionDetail.Quantity,0))
	From Batch_Products BP, ConversionAbstract, ConversionDetail
	Where ConversionDetail.Product_Code = @ITEMCODE AND
	BP.Batch_Code = ConversionDetail.OldBatchCode AND
	ConversionDetail.DocSerial = ConversionAbstract.DocSerial AND
	ConversionAbstract.DocumentDate BETWEEN @FirstTransactionDate AND @TODATE AND
	ConversionAbstract.ConversionType = 2

	--Deducting Qty from Batch_Products_Temp (Applicable for both Free2Sale, Sale2Free)
	Update Batch_Products_Temp 
	Set Batch_Products_Temp.Quantity = Batch_Products_Temp.Quantity - 
		(Select SUM(IsNull(ConversionDetail.Quantity,0)) 
		From ConversionAbstract, ConversionDetail
		Where ConversionDetail.OldBatchCode = Batch_Products_Temp.Batch_Code AND
		ConversionDetail.Product_Code = @ITEMCODE AND
		ConversionDetail.DocSerial = ConversionAbstract.DocSerial AND
		ConversionAbstract.DocumentDate BETWEEN @FirstTransactionDate AND @TODATE)
	From Batch_Products_Temp, ConversionAbstract, ConversionDetail
   Where ConversionDetail.OldBatchCode = Batch_Products_Temp.Batch_Code	
	AND ConversionDetail.Product_Code = @ITEMCODE	
	AND ConversionDetail.DocSerial = ConversionAbstract.DocSerial	
	AND ConversionAbstract.DocumentDate BETWEEN @FirstTransactionDate AND @TODATE	
	AND ConversionAbstract.ConversionType = 1

	--Adding Qty to Batch_Products_Temp (Applicable for both Free2Sale, Sale2Free)
	Update Batch_Products_Temp 
	Set Batch_Products_Temp.Quantity = Batch_Products_Temp.Quantity + 
		(Select SUM(IsNull(ConversionDetail.Quantity,0)) 
		From ConversionAbstract, ConversionDetail
		Where ConversionDetail.NewBatchCode = Batch_Products_Temp.Batch_Code AND
		ConversionDetail.Product_Code = @ITEMCODE AND
		ConversionDetail.DocSerial = ConversionAbstract.DocSerial AND
		ConversionAbstract.DocumentDate BETWEEN @FirstTransactionDate AND @TODATE)
	From Batch_Products_Temp, ConversionAbstract, ConversionDetail
   Where ConversionDetail.NewBatchCode = Batch_Products_Temp.Batch_Code	
	AND ConversionDetail.Product_Code = @ITEMCODE	
	AND ConversionDetail.DocSerial = ConversionAbstract.DocSerial	
	AND ConversionAbstract.DocumentDate BETWEEN @FirstTransactionDate AND @TODATE	
	AND ConversionAbstract.ConversionType = 1

   Set @NewOpeningQuantity = IsNull(@OpeningQuantity,0) + IsNull(@Purchases,0) 
	+ IsNull(@SalesReturnSaleable,0) + IsNull(@StockTransferIn,0) + IsNull(@AdjustmentOthers,0) 
	+ IsNull(@AdjReconcile,0) - IsNull(@PurchaseReturn,0) - IsNull(@StockTransferOut,0) 
	- IsNull(@Issues,0) - IsNull(@StockDestructQty,0) 
     
   Set @NewOpeningValue = IsNull(@OpeningValue,0) + IsNull(@PurchaseValue,0) 
	+ IsNull(@SalesReturnValue,0) + IsNull(@StockTransferInValue,0) + IsNull(@AdjustmentValue,0) 
	+ IsNull(@AdjReconcileValue,0) + IsNull(@ConversionSaleableValue1,0) + IsNull(@ConversionSaleableValue2,0) 
 	- IsNull(@PurchaseReturnValue,0) - IsNull(@StockTransferOutValue,0) 
	- IsNull(@SalesValue,0) - IsNull(@StockDestructValue,0) 
  
   Set @NewFreeOpening = IsNull(@FreeOpening,0) + IsNull(@FreePurchases,0) 
	+ IsNull(@FreeReturns,0) + IsNull(@FreeStockTransferIn,0) + IsNull(@AdjustmentFree,0) 
	+ IsNull(@AdjReconcileFree,0) + IsNull(@ConversionFreeQty1,0) + IsNull(@ConversionFreeQty2,0) 
	- IsNull(@PurchaseReturnFree,0) - IsNull(@FreeStockTransferOut,0) 
	- IsNull(@FreeIssues,0) - IsNull(@FreeStockDestructQty,0) 
  
   Set @NewDamageOpeningQty = IsNull(@DamageOpeningQty,0) + IsNull(@SalesReturnDamages,0) 
	+ IsNull(@AdjustmentDamages,0) + IsNull(@AdjustmentDamagesOthers,0) 
	+ IsNull(@AdjReconcileDamages,0) - IsNull(@PurchaseReturnDamages,0) - IsNull(@DamageStockDestructQty,0)
  
   Set @NewDamageOpeningValue = IsNull(@DamageOpeningValue,0) + IsNull(@SalesReturnDamagesValue,0) 
	+ IsNull(@AdjustmentDamagesValue,0) + IsNull(@AdjustmentDamagesOthersValue,0) 
	+ IsNull(@AdjReconcileDamagesValue,0) - IsNull(@PurchaseReturnDamagesValue,0) - IsNull(@DamageStockDestructValue,0) 
  
   Set @NewFreeSaleable = IsNull(@FreeSaleable,0) + IsNull(@FreePurchases,0) 
	+ IsNull(@FreeReturns,0) + IsNull(@FreeStockTransferIn,0) + IsNull(@AdjustmentFreeSaleable,0) 
	+ IsNull(@AdjReconcileFreeSaleable,0) + IsNull(@ConversionFreeQty1,0) + IsNull(@ConversionFreeQty2,0) 
	- IsNull(@PurchaseReturnFree,0) - IsNull(@FreeStockTransferOut,0) 
	- IsNull(@FreeIssues,0)  - IsNull(@FreeSaleStockDestructQty,0)
   
   IF @FirstTransactionDate < @ServerDate  
   BEGIN  
		Insert Into #temp  
		Select Product_Code, Opening_Date, "Opening Quantity" = Opening_Quantity, "New Opening Quantity" = @NewOpeningQuantity,   
		"Opening Value" = Opening_Value, "New Opening Value" = @NewOpeningValue,   
		"Free Opening Quantity" = Free_Opening_Quantity, "New Free Opening Quantity" = @NewFreeOpening,   
		"Damage Opening Quantity" = Damage_Opening_Quantity, "New Damage Opening Quantity" = @NewDamageOpeningQty,  
		"Damage Opening Value" = Damage_Opening_Value, "New Damage Opening Value" = @NewDamageOpeningValue,  
		"Free Saleable Quantity" = Free_Saleable_Quantity, "New Free Saleable Quantity" = @NewFreeSaleable  
		From OpeningDetails  
		Where Product_Code = @ITEMCODE And Opening_Date = DateAdd(d, 1, @FirstTransactionDate) And  
		(IsNull(Opening_Quantity,0) <> IsNull(@NewOpeningQuantity,0) or   
		IsNull(Free_Opening_Quantity,0) <> IsNull(@NewFreeOpening,0) or   
		IsNull(Damage_Opening_Quantity,0) <> IsNull(@NewDamageOpeningQty,0) or   
		IsNull(Damage_Opening_Value,0) <> IsNull(@NewDamageOpeningValue,0) or   
		IsNull(Opening_Value,0) <> IsNull(@NewOpeningValue,0) or   
		IsNull(Free_Saleable_Quantity,0) <> IsNull(@NewFreeSaleable,0))  
		
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
    Select @ActualQuantity = IsNull(Sum(case when IsNull(Free,0) = 0 And IsNull(Damage,0) = 0 then Quantity else 0 end),0),  
    @ActualFree = IsNull(Sum(case when IsNull(Free,0) = 1 And IsNull(Damage,0) = 0 then Quantity else 0 end),0),  
    @DamagesSaleable = IsNull(Sum(case when IsNull(Free,0) = 0 And IsNull(Damage,0) > 0 then Quantity else 0 end),0),  
    @DamagesFree = IsNull(Sum(case when IsNull(Free,0) = 1 And IsNull(Damage,0) > 0 then Quantity else 0 end),0)  
    From Batch_Products   
    Where Product_Code = @ITEMCODE  
   
    If IsNull(@Saleable,0) <> IsNull(@ActualQuantity,0)  
    BEGIN  
    Update Batch_Products Set Quantity = Quantity + @Saleable - IsNull(@ActualQuantity,0)  
    Where Batch_Code = (Select Min(Batch_Code) From Batch_Products   
    Where Product_Code = @ITEMCODE And IsNull(Free,0) = 0 And IsNull(Damage,0) = 0  
    And (Quantity + @Saleable - IsNull(@ActualQuantity,0)) > 0)  
    END  
  
    If IsNull(@ActualFree,0) <> @NewFreeSaleable  
    Update Batch_Products Set Quantity = Quantity + @NewFreeSaleable - IsNull(@ActualFree,0)  
    Where Batch_Code = (Select Min(Batch_Code) From Batch_Products   
    Where Product_Code = @ITEMCODE And IsNull(Free,0) = 1 And IsNull(Damage,0) = 0  
    And (Quantity + @NewFreeSaleable - IsNull(@ActualFree,0)) > 0)  
  
    If IsNull(@NewFreeOpening,0)-IsNull(@NewFreeSaleable,0) <> @DamagesFree  
    Update Batch_Products Set Quantity = Quantity + (IsNull(@NewFreeOpening,0)-IsNull(@NewFreeSaleable,0)) - IsNull(@DamagesFree,0)  
    Where Batch_Code = (Select Min(Batch_Code) From Batch_Products Where   
    Product_Code = @ITEMCODE And IsNull(Free,0) = 1 And IsNull(Damage,0) > 0 And  
    (Quantity + (IsNull(@NewFreeOpening,0)-IsNull(@NewFreeSaleable,0)) - IsNull(@DamagesFree,0)) > 0)  
  
    Set @ActualDamagesSaleable = @NewDamageOpeningQty - (IsNull(@NewFreeOpening,0)-IsNull(@NewFreeSaleable,0))  
    If IsNull(@ActualDamagesSaleable,0) <> IsNull(@DamagesSaleable,0)  
    Update Batch_Products Set Quantity = Quantity + IsNull(@ActualDamagesSaleable,0) - IsNull(@DamagesSaleable,0)  
    Where Batch_Code = (Select Min(Batch_Code) From Batch_Products Where   
    Product_Code = @ITEMCODE And IsNull(Free,0) = 0 And IsNull(Damage,0) > 0  
    And (Quantity + IsNull(@ActualDamagesSaleable,0) - IsNull(@DamagesSaleable,0)) > 0)  
   END  
   Fetch Next From GetOpeningDetails Into @ITEMCODE, @OpeningQuantity, @OpeningValue,   
   @FreeOpening, @DamageOpeningQty, @DamageOpeningValue, @FreeSaleable  
  end  
  Close GetOpeningDetails  
  DeAllocate GetOpeningDetails  
  Set @FirstTransactionDate = DateAdd(d, 1, @FirstTransactionDate)  
 END  
END  
select * from #temp  
drop table #temp  


