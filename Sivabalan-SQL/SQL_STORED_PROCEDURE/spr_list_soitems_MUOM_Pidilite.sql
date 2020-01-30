CREATE PROCEDURE spr_list_soitems_MUOM_Pidilite(@SONUMBER int , @UOMDesc nvarchar(50))
AS
SELECT SODetail.Product_Code, "Item Code" = SODetail.Product_Code, 
"Item Name" = Items.ProductName, "Batch" = Batch_Number,
"Quantity" = 
Case When @UOMDesc = 'UOM1' Then dbo.sp_Get_ReportingQty(Quantity , Items.UOM1_COnversion)
When @UOMDesc = 'UOM2' Then dbo.sp_Get_ReportingQty(Quantity , Items.UOM2_Conversion)
Else Quantity 
End, 
"Reporting UOM" = Quantity / Case IsNull(ReportingUnit, 1) When 0 Then 1 Else IsNull(ReportingUnit, 0) End,  
"Conversion Factor" = Quantity * IsNull(ConversionFactor, 0),  
"Pending" = 
Case When @UOMDesc = 'UOM1' Then dbo.sp_Get_ReportingQty(Pending, Items.UOM1_Conversion)
When @UOMDesc = 'UOM2' Then dbo.sp_Get_ReportingQty(Pending, Items.UOM2_Conversion)
Else Pending
End, 
"Sale Price" = 
Case When @UOMDesc = 'UOM1' Then (SalePrice * Items.UOM1_Conversion)
When @UOMDesc = 'UOM2' Then (SalePrice * Items.UOM2_Conversion)
Else SalePrice
End, 
"Sale Tax" = CAST(ISNULL(SaleTax, 0) AS nvarchar) + '+' 
+ CAST(ISNULL(TaxCode2, 0) AS nvarchar), 
Discount,
"Tax Suffered" = ISNULL(SODetail.TaxSuffered, 0) 
FROM SODetail, Items WHERE SONumber = @SONUMBER 
And SODetail.Product_Code = Items.Product_Code

