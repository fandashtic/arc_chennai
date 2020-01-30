CREATE procedure [dbo].[spr_list_invoice_sales_muom_ARU_Chevron](@ITEMCODE nvarchar(15), 
											 @UOM nvarchar(100),
                            				 @FROMDATE DATETIME,
						                     @TODATE DATETIME)
AS
DECLARE @INV AS nvarchar(50)
DECLARE @INVAMND AS nvarchar(50)

SELECT @INV = Prefix FROM VoucherPrefix WHERE TranID = N'INVOICE'
SELECT @INVAMND = Prefix FROM VoucherPrefix WHERE TranID = N'INVOICE AMENDMENT'
SELECT InvoiceDetail.InvoiceID, 
"InvoiceID" = 
CASE InvoiceAbstract.InvoiceType
WHEN 1 THEN
@INV
ELSE
@INVAMND
END
 + CAST(InvoiceAbstract.DocumentID AS nvarchar),
"Doc Reference"=DocReference,
"Invoice Type" = case InvoiceAbstract.InvoiceType
WHEN 2 THEN N'Retail Invoice'
ELSE N'Trade Invoice' 
END, 

"Invoice Date" = InvoiceAbstract.InvoiceDate, 
"CustomerID" = Case InvoiceType When 2 Then IsNull(Cash_Customer.CustomerName,N'') Else InvoiceAbstract.CustomerID End,
"Customer Name" = Case InvoiceType When 2 Then IsNull(Cash_Customer.CustomerName,N'') Else Customer.Company_Name End,
"Quantity" = CAST(Sum(Case @UOM When N'Sales UOM' Then InvoiceDetail.Quantity
                                When N'UOM1' Then dbo.sp_Get_ReportingQty(InvoiceDetail.Quantity, UOM1_Conversion)
                                When N'UOM2' Then dbo.sp_Get_ReportingQty(InvoiceDetail.Quantity, UOM1_Conversion) End) AS nvarchar)
+ N' ' + CAST(UOM.Description AS nvarchar), 
"Conversion Factor" = CAST(CAST(Sum(InvoiceDetail.Quantity * Items.ConversionFactor) AS 

Decimal(18,6)) AS nvarchar)
+ N' ' + CAST(ConversionTable.ConversionUnit AS nvarchar),
 "Reporting UOM" = Cast(Sum(dbo.sp_Get_ReportingQty(ISNULL(InvoiceDetail.Quantity, 0), Items.ReportingUnit)) As nvarchar) 
--   SubString(
--    CAST(CAST(SUM(ISNULL(InvoiceDetail.Quantity, 0) / (CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END)) AS Decimal(18,6)) AS nvarchar), 1, 
--    CharIndex('.', CAST(CAST(SUM(ISNULL(InvoiceDetail.Quantity, 0) / (CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END)) AS Decimal(18,6)) AS nvarchar)) -1)
--   + '.' + 
--   CAST(Sum(Cast(ISNULL(InvoiceDetail.Quantity, 0) As Int)) % Avg(Cast((CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END) As Int)) AS nvarchar)
  + N' ' + CAST((SELECT Description FROM UOM WHERE UOM = Items.ReportingUOM) AS nvarchar),

-- "Reporting UOM" = CAST(CAST(SUM(InvoiceDetail.Quantity / (case Items.ReportingUnit WHEN 0 THEN 1 

-- ELSE Items.ReportingUnit END)) AS Decimal(18,6)) AS nvarchar)
-- + ' ' + CAST((SELECT Description FROM UOM WHERE UOM = Items.ReportingUOM) AS nvarchar),
"Batch" = Batch_Products.Batch_Number,
"PKD" = Batch_Products.PKD,
"Expiry" = Batch_Products.Expiry,
"Sale Price" = ISNULL(InvoiceDetail.SalePrice,0),
"Net Value (%c)" = ISNULL(SUM(InvoiceDetail.Amount), 0)
FROM InvoiceAbstract, InvoiceDetail, UOM, ConversionTable, Items, Batch_Products, Customer, Cash_Customer
WHERE InvoiceDetail.Product_Code = @ITEMCODE 
AND InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID
AND (InvoiceAbstract.InvoiceType <>4 ) 
AND InvoiceAbstract.Status & 128 = 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE 
AND InvoiceDetail.Product_Code =  Items.Product_Code
AND (Case @UOM When N'Sales UOM' Then Items.UOM When N'UOM1' Then Items.UOM1 
               When N'UOM2' Then Items.UOM2 End) *= UOM.UOM
AND Items.ConversionUnit *= ConversionTable.ConversionID
AND InvoiceDetail.Batch_Code *= Batch_Products.Batch_Code
And InvoiceAbstract.CustomerID *= Customer.CustomerID
And InvoiceAbstract.CustomerID *= Cast(Cash_Customer.CustomerID As nvarchar)
GROUP BY InvoiceDetail.InvoiceID, InvoiceAbstract.DocumentID, InvoiceAbstract.CustomerID, 
InvoiceType, Customer.Company_Name, Cash_Customer.CustomerName,
InvoiceAbstract.InvoiceDate,InvoiceAbstract.DocReference,
InvoiceDetail.SalePrice, ConversionTable.ConversionUnit, Items.ReportingUOM, 
UOM.Description, Batch_Products.Batch_Number, Batch_Products.PKD, Batch_Products.Expiry
