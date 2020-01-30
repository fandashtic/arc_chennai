CREATE procedure spr_sales_by_itemcategory_details_report
                (@CATID INT,
                 @FROMDATE DATETIME,
                 @TODATE DATETIME)
As
Select InvoiceDetail.Product_Code, "Item Code" = InvoiceDetail.Product_Code,
"Item Name" = Items.ProductName,
"Property1" = dbo.GetProperty(InvoiceDetail.Product_Code, 1),
"Property2" = dbo.GetProperty(InvoiceDetail.Product_Code, 2),
"Property3" = dbo.GetProperty(InvoiceDetail.Product_Code, 3),
"Total Quantity" = Cast(sum(Case IsNull(InvoiceType, 0) When 4 Then -1 Else 1 
          End * IsNull(Quantity, 0)) As nvarchar) + '  ' + 
CAST((SELECT Description FROM UOM WHERE UOM = Items.UOM) AS nvarchar),
"UOM1" = CAST(CAST(sum(Case IsNull(InvoiceType, 0) When 4 Then -1 Else 1 
          End * IsNull(Quantity, 0)) / (CASE Items.UOM1_Conversion WHEN 0 THEN 1 ELSE Items.UOM1_Conversion END) AS Decimal(18,6)) AS nvarchar)
+ ' ' + CAST((SELECT Description FROM UOM WHERE UOM = Items.UOM1) AS nvarchar),
"UOM2" = CAST(CAST(SUM(Case IsNull(InvoiceType, 0) When 4 Then -1 Else 1 
          End * IsNull(Quantity, 0)) / (CASE Items.UOM2_Conversion WHEN 0 THEN 1 ELSE Items.UOM2_Conversion END) AS Decimal(18,6)) AS nvarchar)
+ ' ' + CAST((SELECT Description FROM UOM WHERE UOM = Items.UOM2) AS nvarchar),
"Total Value (Rs)" = sum(Case IsNull(InvoiceType, 0) When 4 Then -1 Else 1 
          End * IsNull(Amount, 0)) 
from invoicedetail, Items, InvoiceAbstract
where invoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID 
And invoicedate between @FROMDATE and @TODATE
And InvoiceAbstract.Status & 192 = 0 
And InvoiceAbstract.InvoiceType in (1, 2, 3, 4)
And Items.Categoryid = @CatID 
And Items.product_Code = invoiceDetail.product_Code
Group by InvoiceDetail.Product_Code, Items.ProductName, Items.UOM, Items.UOM1_Conversion,
Items.UOM1, Items.UOM2_Conversion, Items.UOM2


