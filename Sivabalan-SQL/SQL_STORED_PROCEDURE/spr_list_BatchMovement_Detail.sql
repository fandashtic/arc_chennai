CREATE procedure [dbo].[spr_list_BatchMovement_Detail](@ITEMCODE nvarchar(255), 
					    @BATCHNUMBER nvarchar(50),
					    @FROMDATE DATETIME,
					    @TODATE DATETIME)
AS
Declare @RETAILINVOICE NVarchar(50)
Declare @TRADEINVOICE NVarchar(50)

Set @RETAILINVOICE = dbo.LookupDictionaryItem(N'Retail Invoice', Default)
Set @TRADEINVOICE = dbo.LookupDictionaryItem(N'Trade Invoice', Default)

DECLARE @INV AS nvarchar(50)
DECLARE @INVAMND AS nvarchar(50)
Declare @SaleID AS INT
SET @SaleID =  CAST(SUBSTRING(@ITEMCODE,CHARINDEX(':',@ITEMCODE,1)+1,LEN(@ITEMCODE))AS INT)
SET @ITEMCODE =  SUBSTRING(@ITEMCODE,1,CHARINDEX(':',@ITEMCODE,1)-1)

SELECT @INV = Prefix FROM VoucherPrefix WHERE TranID = 'INVOICE'
SELECT @INVAMND = Prefix FROM VoucherPrefix WHERE TranID = 'INVOICE AMENDMENT'
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
WHEN 2 THEN @RETAILINVOICE
ELSE @TRADEINVOICE
END, 

"Invoice Date" = InvoiceAbstract.InvoiceDate, 
"CustomerID" = InvoiceAbstract.CustomerID,
"Customer Name" =Customer.Company_Name,
"Quantity" = CAST(Sum(InvoiceDetail.Quantity) AS nvarchar)
+ ' ' + CAST(UOM.Description AS nvarchar), 
"Conversion Factor" = CAST(CAST(Sum(InvoiceDetail.Quantity * Items.ConversionFactor) AS 

Decimal(18,6)) AS nvarchar)
+ ' ' + CAST(ConversionTable.ConversionUnit AS nvarchar),
"Reporting UOM" = Cast(Sum(dbo.sp_Get_ReportingQty(IsNull(InvoiceDetail.Quantity, 0), Items.ReportingUnit)) As nvarchar)
+ ' ' + CAST((SELECT Description FROM UOM WHERE UOM = Items.ReportingUOM) AS nvarchar),
-- "Reporting UOM" = CAST(CAST(SUM(InvoiceDetail.Quantity / (case Items.ReportingUnit WHEN 0 THEN 1 
-- 
-- ELSE Items.ReportingUnit END)) AS Decimal(18,6)) AS nvarchar)
-- + ' ' + CAST((SELECT Description FROM UOM WHERE UOM = Items.ReportingUOM) AS nvarchar),
"Batch" = Batch_Products.Batch_Number,
"PKD" = Batch_Products.PKD,
"Expiry" = Batch_Products.Expiry,
"Sale Price" = ISNULL(InvoiceDetail.SalePrice,0),
"Net Value (%c)" = ISNULL(SUM(InvoiceDetail.Amount), 0)
FROM InvoiceAbstract, InvoiceDetail, UOM, ConversionTable, Items, Batch_Products, Customer
WHERE InvoiceDetail.Product_Code = @ITEMCODE 
AND InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID
AND (InvoiceAbstract.InvoiceType not in(4,5,6)) 
AND InvoiceAbstract.Status & 128 = 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE 
AND InvoiceDetail.Product_Code =  Items.Product_Code
AND Items.UOM *= UOM.UOM
AND Items.ConversionUnit *= ConversionTable.ConversionID
AND InvoiceDetail.Batch_Code *= Batch_Products.Batch_Code
And InvoiceAbstract.CustomerID *= Customer.CustomerID
And InvoiceDetail.Batch_Number like @BATCHNUMBER
And InvoiceDetail.SaleID =  @SaleID
GROUP BY InvoiceDetail.InvoiceID, InvoiceAbstract.DocumentID, InvoiceAbstract.CustomerID, 
InvoiceType, Customer.Company_Name,
InvoiceAbstract.InvoiceDate,InvoiceAbstract.DocReference,
InvoiceDetail.SalePrice, ConversionTable.ConversionUnit, Items.ReportingUOM, 
UOM.Description, Batch_Products.Batch_Number, Batch_Products.PKD, Batch_Products.Expiry
