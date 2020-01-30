CREATE procedure [dbo].[spr_list_BatchMovement_Detail_MUOM_pidilite] (@ITEMCODE nvarchar(15), 
					    @BATCHNUMBER nvarchar(50),
					    @FROMDATE DATETIME,
					    @TODATE DATETIME,
						@UOMDesc nvarchar(30))
AS
DECLARE @INV AS nvarchar(50)
DECLARE @INVAMND AS nvarchar(50)
Declare @SaleID AS INT
SET @SaleID =  CAST(SUBSTRING(@ITEMCODE,CHARINDEX(N':',@ITEMCODE,1)+1,LEN(@ITEMCODE))AS INT)
SET @ITEMCODE =  SUBSTRING(@ITEMCODE,1,CHARINDEX(N':',@ITEMCODE,1)-1)

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
"Quantity" = Cast((  
   Case When @UOMdesc = N'UOM1' then dbo.sp_Get_ReportingQty(SUM(InvoiceDetail.Quantity), Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 Else Items.UOM1_Conversion End)    
      	When @UOMdesc = N'UOM2' then dbo.sp_Get_ReportingQty(SUM(InvoiceDetail.Quantity), Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 Else Items.UOM2_Conversion End)    
   		Else SUM(InvoiceDetail.Quantity)
   End) as nvarchar)
		+ N' ' + Cast((  
   Case When @UOMdesc = N'UOM1' then (SELECT Description FROM UOM WHERE UOM = Items.UOM1)    
      	When @UOMdesc = N'UOM2' then (SELECT Description FROM UOM WHERE UOM = Items.UOM2)    
   		Else (SELECT Description FROM UOM WHERE UOM = Items.UOM)    
   End) as nvarchar),         

"Conversion Factor" = Sum(InvoiceDetail.Quantity * IsNull(Items.ConversionFactor, 0)),
"Reporting UOM" = Sum(InvoiceDetail.Quantity / Case IsNull(ReportingUnit, 1) When 0 Then 1 Else IsNull(ReportingUnit, 1) End),
"Batch" = Batch_Products.Batch_Number,
"PKD" = Batch_Products.PKD,
"Expiry" = Batch_Products.Expiry,
"Sale Price" = Cast((  
   Case When @UOMdesc = N'UOM1' then ISNULL(InvoiceDetail.SalePrice,0) * (Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 Else Items.UOM1_Conversion End)    
      	When @UOMdesc = N'UOM2' then ISNULL(InvoiceDetail.SalePrice,0) * (Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 Else Items.UOM2_Conversion End)    
   		Else ISNULL(InvoiceDetail.SalePrice,0)    
   End) as nvarchar),
"Net Value (%c)" = ISNULL(SUM(InvoiceDetail.Amount), 0)
FROM InvoiceAbstract, InvoiceDetail, UOM, ConversionTable, Items, Batch_Products, Customer, Cash_Customer
WHERE InvoiceDetail.Product_Code = @ITEMCODE 
AND InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID
AND (InvoiceAbstract.InvoiceType <>4 ) 
AND InvoiceAbstract.Status & 128 = 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE 
AND InvoiceDetail.Product_Code =  Items.Product_Code
AND Items.UOM *= UOM.UOM
AND Items.ConversionUnit *= ConversionTable.ConversionID
AND InvoiceDetail.Batch_Code *= Batch_Products.Batch_Code
And InvoiceAbstract.CustomerID *= Customer.CustomerID
And InvoiceAbstract.CustomerID *= Cast(Cash_Customer.CustomerID As nvarchar)
And InvoiceDetail.Batch_Number like @BATCHNUMBER
And InvoiceDetail.SaleID =  @SaleID
GROUP BY InvoiceDetail.InvoiceID, InvoiceAbstract.DocumentID, InvoiceAbstract.CustomerID, 
InvoiceType, Customer.Company_Name,Cash_Customer.CustomerName,
InvoiceAbstract.InvoiceDate,InvoiceAbstract.DocReference,
InvoiceDetail.SalePrice, ConversionTable.ConversionUnit, Items.ReportingUOM, 
UOM.Description, Batch_Products.Batch_Number, Batch_Products.PKD, Batch_Products.Expiry,
Items.UOM1_Conversion,Items.UOM2_Conversion,Items.UOM1,Items.UOM2,Items.UOM
