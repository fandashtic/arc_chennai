CREATE procedure [dbo].[spr_list_stockmovement_report](@FROMDATE datetime,
						@TODATE datetime,
						@UOM nvarchar(50),
						@Mfr nvarchar(255))
as
declare @NEXT_DATE datetime
DECLARE @CORRECTED_DATE datetime
SET @CORRECTED_DATE = CAST(DATEPART(dd, @TODATE) AS nvarchar) + '/' 
+ CAST(DATEPART(mm, @TODATE) as nvarchar) + '/' 
+ cast(DATEPART(yyyy, @TODATE) AS nvarchar)
SET  @NEXT_DATE = CAST(DATEPART(dd, GETDATE()) AS nvarchar) + '/' 
+ CAST(DATEPART(mm, GETDATE()) as nvarchar) + '/' 
+ cast(DATEPART(yyyy, GETDATE()) AS nvarchar)
if @UOM = 'Sales UOM'
begin
	SELECT  Items.Product_Code, 
	"Item Code" = Items.Product_Code, 
	"Item Name" = ProductName, 

	"Opening Quantity" = CAST(ISNULL(Opening_Quantity, 0) AS nvarchar)
	+ ' ' + CAST(UOM.Description AS nvarchar), 

	"Opening Value" = ISNULL(Opening_Value, 0),

	"Purchase" = CAST(ISNULL((SELECT SUM(QuantityReceived - QuantityRejected + IsNull(FreeQty, 0)) 
	FROM GRNAbstract, GRNDetail 
	WHERE GRNAbstract.GRNID = GRNDetail.GRNID 
	AND GRNDetail.Product_Code = Items.Product_Code 
	AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And (GRNAbstract.GRNStatus & 64) = 0), 0) AS nvarchar)
	+ ' ' + CAST(UOM.Description AS nvarchar), 

	"Sales Return" = CAST(ISNULL((SELECT SUM(Quantity) 
	FROM InvoiceDetail, InvoiceAbstract 
	WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID 
	AND (InvoiceAbstract.InvoiceType = 4) 
	AND (InvoiceAbstract.Status & 128) = 0 
	AND InvoiceDetail.Product_Code = Items.Product_Code 
	AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0) AS nvarchar)
	+ ' ' + CAST(UOM.Description AS nvarchar), 
	
	"Total Issues" = CAST((ISNULL((SELECT SUM(Quantity) 
	FROM InvoiceDetail, InvoiceAbstract 
	WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID 
	AND (InvoiceAbstract.InvoiceType = 2) 
	AND (InvoiceAbstract.Status & 128) = 0 
	AND InvoiceDetail.Product_Code = Items.Product_Code 
	AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0) 
	+ ISNULL((SELECT SUM(Quantity) 
	FROM DispatchDetail, DispatchAbstract 
	WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID 
	AND (DispatchAbstract.Status & 64) = 0 
	AND DispatchDetail.Product_Code = Items.Product_Code 
	AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE), 0)) AS nvarchar)
	+ ' ' + CAST(UOM.Description AS nvarchar), 
	
	"Free Issues" = CAST((ISNULL((SELECT SUM(Quantity) 
	FROM InvoiceDetail, InvoiceAbstract 
	WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID 
	AND (InvoiceAbstract.InvoiceType = 2) 
	AND (InvoiceAbstract.Status & 128) = 0 
	AND InvoiceDetail.Product_Code = Items.Product_Code 
	AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
	And InvoiceDetail.SalePrice = 0), 0) 
	+ ISNULL((SELECT SUM(Quantity) 
	FROM DispatchDetail, DispatchAbstract 
	WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID 
	AND (DispatchAbstract.Status & 64) = 0 
	AND DispatchDetail.Product_Code = Items.Product_Code 
	AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE
	And DispatchDetail.SalePrice = 0), 0)) AS nvarchar)
	+ ' ' + CAST(UOM.Description AS nvarchar), 

	"Purchase Return" = CAST(ISNULL((SELECT SUM(Quantity) 
	FROM AdjustmentReturnDetail, AdjustmentReturnAbstract 
	WHERE AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID 
	AND AdjustmentReturnDetail.Product_Code = Items.Product_Code 
	AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FROMDATE AND @TODATE And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 64) = 0), 0) 
	AS nvarchar)
	+ ' ' + CAST(UOM.Description AS nvarchar), 
	
	"Adjustments" = CAST(ISNULL((SELECT SUM(Quantity - OldQty) 
	FROM StockAdjustment, StockAdjustmentAbstract 
	WHERE ISNULL(AdjustmentType,0) = 1 
	And Product_Code = Items.Product_Code 
	AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID
	AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0) AS nvarchar)
	+ ' ' + CAST(UOM.Description AS nvarchar), 

	"Stock Transfer Out" = Cast(IsNull((Select Sum(Quantity) 
	From StockTransferOutAbstract, StockTransferOutDetail
	Where StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial
	And StockTransferOutAbstract.DocumentDate Between @FromDate And @ToDate 
	And StockTransferOutAbstract.Status & 64 = 0
	And StockTransferOutDetail.Product_Code = Items.Product_Code), 0) As nvarchar)
	+ ' ' + Cast(UOM.Description As nvarchar),

	"Stock Transfer In" = Cast(IsNull((Select Sum(Quantity) 
	From StockTransferInAbstract, StockTransferInDetail 
	Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial
	And StockTransferInAbstract.DocumentDate Between @FromDate And @ToDate 
	And StockTransferInDetail.Product_Code = Items.Product_Code), 0) As nvarchar)
	+ ' ' + Cast(UOM.Description As nvarchar),

	"On Hand Qty" = CAST(CASE 
	when (@TODATE < @NEXT_DATE) THEN 
	ISNULL((Select Opening_Quantity 
	FROM OpeningDetails 
	WHERE OpeningDetails.Product_Code = Items.Product_Code 
	AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)
	ELSE 
	(ISNULL((SELECT SUM(Quantity) 
	FROM Batch_Products 
	WHERE Product_Code = Items.Product_Code), 0) +
	(SELECT ISNULL(SUM(Pending), 0) 
	FROM VanStatementDetail, VanStatementAbstract 
	WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial 
	AND (VanStatementAbstract.Status & 128) = 0 
	And VanStatementDetail.Product_Code = Items.Product_Code))
	end AS nvarchar)
	+ ' ' + CAST(UOM.Description AS nvarchar), 
	
	"On Hand Value" = CASE 
	when (@TODATE < @NEXT_DATE) THEN 
	ISNULL((Select Opening_Value 
	FROM OpeningDetails 
	WHERE OpeningDetails.Product_Code = Items.Product_Code 
	AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)
	ELSE 
	((SELECT ISNULL(SUM(Quantity * PurchasePrice), 0) 
	FROM Batch_Products 
	WHERE Product_Code = Items.Product_Code) + 
	(SELECT ISNULL(SUM(Pending * PurchasePrice), 0) 
	FROM VanStatementDetail, VanStatementAbstract 
	WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial 
	AND (VanStatementAbstract.Status & 128) = 0 
	And VanStatementDetail.Product_Code = Items.Product_Code))
	end

	FROM Items, OpeningDetails, UOM, Manufacturer
	WHERE   Items.Product_Code *= OpeningDetails.Product_Code AND
		OpeningDetails.Opening_Date = @FROMDATE
		AND Items.UOM *= UOM.UOM And IsNull(Items.Active,0) = 1 And
		Items.ManufacturerID = Manufacturer.ManufacturerID And
		Manufacturer.Manufacturer_Name like @Mfr
end
else if @UOM = 'Conversion Factor'
begin
	SELECT  Items.Product_Code, 
	"Item Code" = Items.Product_Code, 
	"Item Name" = ProductName, 
	"Opening Quantity" = CAST(CAST(ISNULL(Opening_Quantity, 0) 
	* ISNULL(Items.ConversionFactor, 0) AS Decimal(18,6)) AS nvarchar)
	+ ' ' + CAST(ConversionTable.ConversionUnit AS nvarchar), 

	"Opening Value" = ISNULL(Opening_Value, 0),

	"Purchase" = CAST((ISNULL((SELECT SUM(QuantityReceived - QuantityRejected + IsNull(FreeQty, 0)) 
	FROM GRNAbstract, GRNDetail 
	WHERE GRNAbstract.GRNID = GRNDetail.GRNID 
	AND GRNDetail.Product_Code = Items.Product_Code 
	AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And (GRNAbstract.GRNStatus & 64) = 0), 0) 
	* ISNULL(Items.ConversionFactor, 0)) AS nvarchar)
	+ ' ' + CAST(ConversionTable.ConversionUnit AS nvarchar), 
	
	"Sales Return" = CAST(CAST((ISNULL((SELECT SUM(Quantity) 
	FROM InvoiceDetail, InvoiceAbstract 
	WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID 
	AND (InvoiceAbstract.InvoiceType = 4) 
	AND (InvoiceAbstract.Status & 128) = 0 
	AND InvoiceDetail.Product_Code = Items.Product_Code 
	AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0) 
	* ISNULL(Items.ConversionFactor, 0)) AS Decimal(18,6)) AS nvarchar)
	+ ' ' + CAST(ConversionTable.ConversionUnit AS nvarchar), 
	
	"Total Issues" = CAST(CAST(((ISNULL((SELECT SUM(Quantity) 
	FROM InvoiceDetail, InvoiceAbstract 
	WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID 
	AND (InvoiceAbstract.InvoiceType = 2) 
	AND (InvoiceAbstract.Status & 128) = 0 
	AND InvoiceDetail.Product_Code = Items.Product_Code 
	AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0) 
	+ ISNULL((SELECT SUM(Quantity) 
	FROM DispatchDetail, DispatchAbstract 
	WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID 
	AND (DispatchAbstract.Status & 64) = 0 
	AND DispatchDetail.Product_Code = Items.Product_Code 
	AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE), 0)) 
	* ISNULL(Items.ConversionFactor, 0)) AS Decimal(18,6)) AS nvarchar)
	+ ' ' + CAST(ConversionTable.ConversionUnit AS nvarchar), 
	
	"Free Issues" = CAST(CAST(((ISNULL((SELECT SUM(Quantity) 
	FROM InvoiceDetail, InvoiceAbstract 
	WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID 
	AND (InvoiceAbstract.InvoiceType = 2) 
	AND (InvoiceAbstract.Status & 128) = 0 
	AND InvoiceDetail.Product_Code = Items.Product_Code 
	AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
	And InvoiceDetail.SalePrice = 0), 0) 
	+ ISNULL((SELECT SUM(Quantity) 
	FROM DispatchDetail, DispatchAbstract 
	WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID 
	AND (DispatchAbstract.Status & 64) = 0 
	AND DispatchDetail.Product_Code = Items.Product_Code 
	AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE
	And DispatchDetail.SalePrice = 0), 0)) 
	* ISNULL(Items.ConversionFactor, 0)) AS Decimal(18,6)) AS nvarchar)
	+ ' ' + CAST(ConversionTable.ConversionUnit AS nvarchar), 

	"Purchase Return" = CAST(CAST((ISNULL((SELECT SUM(Quantity) 
	FROM AdjustmentReturnDetail, AdjustmentReturnAbstract 
	WHERE AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID 
	AND AdjustmentReturnDetail.Product_Code = Items.Product_Code 
	AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FROMDATE AND @TODATE And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 64) = 0), 0) 
	* ISNULL(Items.ConversionFactor, 0)) AS Decimal(18,6)) AS nvarchar)
	+ ' ' + CAST(ConversionTable.ConversionUnit AS nvarchar), 
	
	"Adjustments" = CAST(CAST((ISNULL((SELECT SUM(Quantity - OldQty) 
	FROM StockAdjustment, StockAdjustmentAbstract 
	WHERE ISNULL(AdjustmentType,0) = 1 
	And Product_Code = Items.Product_Code 
	AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID
	AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0) 
	* ISNULL(Items.ConversionFactor, 0)) AS Decimal(18,6)) AS nvarchar)
	+ ' ' + CAST(ConversionTable.ConversionUnit AS nvarchar), 
	
	"Stock Transfer Out" = Cast(Cast((IsNull((Select Sum(Quantity) 
	From StockTransferOutAbstract, StockTransferOutDetail
	Where StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial
	And StockTransferOutAbstract.DocumentDate Between @FromDate And @ToDate
	And StockTransferOutAbstract.Status & 64 = 0
	And StockTransferOutDetail.Product_Code = Items.Product_Code), 0)
	* IsNull(Items.ConversionFactor, 0)) As Decimal(18,6)) As nvarchar)
	+ ' ' + Cast(ConversionTable.ConversionUnit As nvarchar),
	
	"Stock Transfer In" = Cast(Cast((IsNull((Select Sum(Quantity) 
	From StockTransferInAbstract, StockTransferInDetail
	Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial
	And StockTransferInAbstract.DocumentDate Between @FromDate And @ToDate
	And StockTransferInDetail.Product_Code = Items.Product_Code), 0)
	* IsNull(Items.ConversionFactor, 0)) As Decimal(18,6)) As nvarchar)
	+ ' ' + Cast(ConversionTable.ConversionUnit As nvarchar),

	"On Hand Qty" = CAST(CAST((CASE 
	when (@TODATE < @NEXT_DATE) THEN 
	ISNULL((Select Opening_Quantity 
	FROM OpeningDetails 
	WHERE OpeningDetails.Product_Code = Items.Product_Code 
	AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)
	ELSE 
	(ISNULL((SELECT SUM(Quantity) 
	FROM Batch_Products 
	WHERE Product_Code = Items.Product_Code), 0) + 
	(SELECT ISNULL(SUM(Pending), 0) 
	FROM VanStatementDetail, VanStatementAbstract 
	WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial 
	AND (VanStatementAbstract.Status & 128) = 0 
	And VanStatementDetail.Product_Code = Items.Product_Code))
	end 
	* ISNULL(Items.ConversionFactor, 0)) AS Decimal(18,6)) AS nvarchar)
	+ ' ' + CAST(ConversionTable.ConversionUnit AS nvarchar), 
	
	"On Hand Value" = CASE 
	when (@TODATE < @NEXT_DATE) THEN 
	ISNULL((Select Opening_Value 
	FROM OpeningDetails 
	WHERE OpeningDetails.Product_Code = Items.Product_Code 
	AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)
	ELSE 
	((SELECT ISNULL(SUM(Quantity * PurchasePrice), 0) 
	FROM Batch_Products 
	WHERE Product_Code = Items.Product_Code) + 
	(SELECT ISNULL(SUM(Pending * PurchasePrice), 0) 
	FROM VanStatementDetail, VanStatementAbstract 
	WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial 
	AND (VanStatementAbstract.Status & 128) = 0 
	And VanStatementDetail.Product_Code = Items.Product_Code))
	end
	
	FROM Items, OpeningDetails, ConversionTable, Manufacturer
	WHERE   Items.Product_Code *= OpeningDetails.Product_Code AND
		OpeningDetails.Opening_Date = @FROMDATE
		AND Items.ConversionUnit *= ConversionTable.ConversionID And 
		IsNull(Items.Active,0) = 1 And
		Items.ManufacturerID = Manufacturer.ManufacturerID And
		ManUfacturer.Manufacturer_Name like @Mfr
end
else
begin
	SELECT  Items.Product_Code, 
	"Item Code" = Items.Product_Code, 
	"Item Name" = ProductName, 
	"Opening Quantity" = CAST(CAST(ISNULL(Opening_Quantity, 0) 
	/ (CASE ISNULL(Items.ReportingUnit, 0) 
	WHEN 0 THEN 
	1 
	ELSE ISNULL(Items.ReportingUnit, 0) END) 
	AS Decimal(18,6)) AS nvarchar)
	+ ' ' + CAST(UOM.Description AS nvarchar), 
	
	"Opening Value" = ISNULL(Opening_Value, 0),
	
	"Purchase" = CAST(CAST((ISNULL((SELECT SUM(QuantityReceived - QuantityRejected + IsNull(FreeQty, 0)) 
	FROM GRNAbstract, GRNDetail 
	WHERE GRNAbstract.GRNID = GRNDetail.GRNID 
	AND GRNDetail.Product_Code = Items.Product_Code 
	AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And (GRNAbstract.GRNStatus & 64) = 0), 0) 
	/ (CASE ISNULL(Items.ReportingUnit, 0) 
	WHEN 0 THEN 
	1 
	ELSE 
	ISNULL(Items.ReportingUnit, 0) END)) AS Decimal(18,6)) AS nvarchar)
	+ ' ' + CAST(UOM.Description AS nvarchar), 
	
	"Sales Return" = CAST(CAST((ISNULL((SELECT SUM(Quantity) 
	FROM InvoiceDetail, InvoiceAbstract 
	WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID 
	AND (InvoiceAbstract.InvoiceType = 4) 
	AND (InvoiceAbstract.Status & 128) = 0 
	AND InvoiceDetail.Product_Code = Items.Product_Code 
	AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0) 
	/ (CASE ISNULL(Items.ReportingUnit, 0) 
	WHEN 0 THEN 
	1 
	ELSE 
	ISNULL(Items.ReportingUnit, 0) END)) AS Decimal(18,6)) AS nvarchar)
	+ ' ' + CAST(UOM.Description AS nvarchar), 
	
	"Total Issues" = CAST(CAST(((ISNULL((SELECT SUM(Quantity) 
	FROM InvoiceDetail, InvoiceAbstract 
	WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID 
	AND (InvoiceAbstract.InvoiceType = 2) 
	AND (InvoiceAbstract.Status & 128) = 0 
	AND InvoiceDetail.Product_Code = Items.Product_Code 
	AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0) + 
	ISNULL((SELECT SUM(Quantity) 
	FROM DispatchDetail, DispatchAbstract 
	WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID 
	AND (DispatchAbstract.Status & 64) = 0 
	AND DispatchDetail.Product_Code = Items.Product_Code 
	AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE), 0)) 
	/ (CASE ISNULL(Items.ReportingUnit, 0) 
	WHEN 0 THEN 
	1 
	ELSE 
	ISNULL(Items.ReportingUnit, 0) END)) AS Decimal(18,6)) AS nvarchar)
	+ ' ' + CAST(UOM.Description AS nvarchar), 
	
	"Free Issues" = CAST(CAST(((ISNULL((SELECT SUM(Quantity) 
	FROM InvoiceDetail, InvoiceAbstract 
	WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID 
	AND (InvoiceAbstract.InvoiceType = 2) 
	AND (InvoiceAbstract.Status & 128) = 0 
	AND InvoiceDetail.Product_Code = Items.Product_Code 
	AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
	And InvoiceDetail.SalePrice = 0), 0) + 
	ISNULL((SELECT SUM(Quantity) 
	FROM DispatchDetail, DispatchAbstract 
	WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID 
	AND (DispatchAbstract.Status & 64) = 0 
	AND DispatchDetail.Product_Code = Items.Product_Code 
	AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE
	And DispatchDetail.SalePrice = 0), 0)) 
	/ (CASE ISNULL(Items.ReportingUnit, 0) 
	WHEN 0 THEN 
	1 
	ELSE 
	ISNULL(Items.ReportingUnit, 0) END)) AS Decimal(18,6)) AS nvarchar)
	+ ' ' + CAST(UOM.Description AS nvarchar), 

	"Purchase Return" = CAST(CAST((ISNULL((SELECT SUM(Quantity) 
	FROM AdjustmentReturnDetail, AdjustmentReturnAbstract 
	WHERE AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID 
	AND AdjustmentReturnDetail.Product_Code = Items.Product_Code 
	AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FROMDATE AND @TODATE And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 64) = 0), 0) 
	/ (CASE ISNULL(Items.ReportingUnit, 0) 
	WHEN 0 THEN 
	1 
	ELSE 
	ISNULL(Items.ReportingUnit, 0) END)) AS Decimal(18,6)) AS nvarchar)
	+ ' ' + CAST(UOM.Description AS nvarchar), 
	
	"Adjustments" = CAST(CAST((ISNULL((SELECT SUM(Quantity - OldQty) 
	FROM StockAdjustment, StockAdjustmentAbstract 
	WHERE ISNULL(AdjustmentType,0) = 1 
	And Product_Code = Items.Product_Code 
	AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID
	AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0) 
	/ (CASE ISNULL(Items.ReportingUnit, 0) 
	WHEN 0 THEN 
	1 
	ELSE 
	ISNULL(Items.ReportingUnit, 0) END)) AS Decimal(18,6)) AS nvarchar)
	+ ' ' + CAST(UOM.Description AS nvarchar), 
	
	"Stock Transfer Out" = Cast(Cast((IsNull((Select Sum(Quantity) 
	From StockTransferOutAbstract, StockTransferOutDetail
	Where StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial
	And StockTransferOutAbstract.DocumentDate Between @FromDate And @ToDate
	And StockTransferOutAbstract.Status & 64 = 0
	And StockTransferOutDetail.Product_Code = Items.Product_Code), 0)
	/ (Case IsNull(Items.ReportingUnit, 0)
	When 0 Then
	1
	Else
	IsNull(Items.ReportingUnit, 0)
	End)) As Decimal(18,6)) As nvarchar)
	+ ' ' + Cast(UOM.Description As nvarchar),

	"Stock Transfer In" = Cast(Cast((IsNull((Select Sum(Quantity)
	From StockTransferInAbstract, StockTransferInDetail
	Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial
	And StockTransferInAbstract.DocumentDate Between @FromDate And @ToDate
	And StockTransferInDetail.Product_Code = Items.Product_Code), 0)
	/ (Case IsNull(Items.ReportingUnit, 0)
	When 0 Then
	1
	Else
	IsNull(Items.ReportingUnit, 0)
	End)) As Decimal(18,6)) As nvarchar)
	+ ' ' + Cast(UOM.Description as nvarchar),
	
	"On Hand Qty" = CAST(CAST((CASE 
	when (@TODATE < @NEXT_DATE) THEN 
	ISNULL((Select Opening_Quantity 
	FROM OpeningDetails 
	WHERE OpeningDetails.Product_Code = Items.Product_Code 
	AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)
	ELSE 
	(ISNULL((SELECT SUM(Quantity) 
	FROM Batch_Products 
	WHERE Product_Code = Items.Product_Code), 0) + 
	(SELECT ISNULL(SUM(Pending), 0) 
	FROM VanStatementDetail, VanStatementAbstract 
	WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial 
	AND (VanStatementAbstract.Status & 128) = 0 
	And VanStatementDetail.Product_Code = Items.Product_Code))
	end 
	/ (CASE ISNULL(Items.ReportingUnit, 0) 
	WHEN 0 THEN 
	1 
	ELSE 
	ISNULL(Items.ReportingUnit, 0) END)) AS Decimal(18,6)) AS nvarchar)
	+ ' ' + CAST(UOM.Description AS nvarchar), 
	
	"On Hand Value" = CASE 
	when (@TODATE < @NEXT_DATE) THEN 
	ISNULL((Select Opening_Value 
	FROM OpeningDetails 
	WHERE OpeningDetails.Product_Code = Items.Product_Code 
	AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)
	ELSE 
	((SELECT ISNULL(SUM(Quantity * PurchasePrice), 0) 
	FROM Batch_Products 
	WHERE Product_Code = Items.Product_Code) + 
	(SELECT ISNULL(SUM(Pending * PurchasePrice), 0) 
	FROM VanStatementDetail, VanStatementAbstract 
	WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial 
	AND (VanStatementAbstract.Status & 128) = 0 
	And VanStatementDetail.Product_Code = Items.Product_Code))
	end
		
	FROM Items, OpeningDetails, UOM, Manufacturer
	WHERE   Items.Product_Code *= OpeningDetails.Product_Code AND
		OpeningDetails.Opening_Date = @FROMDATE
	AND Items.ReportingUOM *= UOM.UOM And 
	IsNull(Items.Active,0) = 1 And
	Items.ManufacturerID = Manufacturer.ManufacturerID And
	Manufacturer.Manufacturer_Name like @Mfr
end
