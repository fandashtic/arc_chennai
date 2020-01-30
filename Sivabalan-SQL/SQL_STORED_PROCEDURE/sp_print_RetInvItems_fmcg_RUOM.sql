CREATE procedure [dbo].[sp_print_RetInvItems_fmcg_RUOM](@INVNO INT)      
AS      
SELECT "Item Code" = InvoiceDetail.Product_Code, 
	"Item Name" = Items.ProductName,       
	"Batch" = InvoiceDetail.Batch_Number, 
	"Quantity" = sum(InvoiceDetail.UOMQty),      
	"UOM" = UOM.Description, 
	"Sale Price" = Max(InvoiceDetail.SalePrice),       
	"Tax%" = (ISNULL(Max(InvoiceDetail.TaxCode), 0) + ISNULL(Max(InvoiceDetail.TaxCode2), 0)),      
	"Discount%" = Max(InvoiceDetail.DiscountPercentage),       
	"Discount Value" = Max(InvoiceDetail.DiscountValue),       
	"Amount" = case (SELECT TOP 1 Flags FROM InvoiceAbstract WHERE InvoiceID =@INVNO )      
	    WHEN 0 THEN Sum((InvoiceDetail.Quantity * InvoiceDetail.SalePrice)       
    		- (InvoiceDetail.Quantity * InvoiceDetail.SalePrice       
		    * InvoiceDetail.DiscountPercentage / 100) +       
		    (((InvoiceDetail.Quantity * InvoiceDetail.SalePrice)       
		    - (InvoiceDetail.Quantity * InvoiceDetail.SalePrice       
		    * InvoiceDetail.DiscountPercentage / 100))))       
		    * Max(InvoiceDetail.TaxCode) / 100      
	    ELSE Sum((InvoiceDetail.Quantity * InvoiceDetail.SalePrice)       
    		- (InvoiceDetail.Quantity * InvoiceDetail.SalePrice       
		    * InvoiceDetail.DiscountPercentage / 100))
	    END,      
	"Expiry" = Max(CAST(DATEPART(mm, Batch_Products.Expiry) AS nvarchar) + N'\'      
		+ SubString(CAST(DATEPART(yy, Batch_Products.Expiry) AS nvarchar), 3, 2)),      
		"MRP" = Max(InvoiceDetail.MRP),      
	"Type" = CASE       
	 	WHEN Max(InvoiceDetail.SaleID) = 1 THEN N'F'      
	 	WHEN Max(InvoiceDetail.SaleID) = 2 THEN N'S'      
	 	WHEN Max(InvoiceDetail.SaleID) = 0 AND Max(STPAYABLE) <> 0 THEN N'F'      
	 	ELSE N' '      
		END ,      
	"Tax Suffered" = ISNULL(Max(InvoiceDetail.TaxSuffered), 0),      
	"Mfr" = Manufacturer.ManufacturerCode, "Description" = Items.Description,      
	"Category" = ItemCategories.Category_Name,      
	"Item Gross Value" = Case Sum(InvoiceDetail.Quantity) * Max(InvoiceDetail.SalePrice)
		When 0 then      
			N''      
		Else      
			Cast(Sum(InvoiceDetail.Quantity) * Max(InvoiceDetail.SalePrice) as nvarchar)      
		End,      
	"Property1" = dbo.GetProperty(InvoiceDetail.Product_Code, 1),      
	"Property2" = dbo.GetProperty(InvoiceDetail.Product_Code, 2),      
	"Property3" = dbo.GetProperty(InvoiceDetail.Product_Code, 3),      
	"Net Amount" = Max(Amount),      
	"Reporting Unit Qty" = (Sum(InvoiceDetail.Quantity) / Max((Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else Items.ReportingUnit End))),      
	"Conversion Unit Qty" = (Sum(InvoiceDetail.Quantity)) * Max(Items.ConversionFactor),      
	"Rounded Reporting Unit Qty" = Ceiling(Sum(InvoiceDetail.Quantity) / Max((Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else Items.ReportingUnit End))),      
	"Rounded Conversion Unit Qty" = Ceiling(Sum(InvoiceDetail.Quantity) * Max(Items.ConversionFactor)),      
	"Mfr Name" = Manufacturer.Manufacturer_Name,      
	"Divison" = Brand.BrandName,      
	"Tax Applicable Value" = Max(IsNull(InvoiceDetail.STPayable, 0)) + Max(IsNull(InvoiceDetail.CSTPayable, 0)),      
	"Tax Suffered Value" = IsNull((Sum(InvoiceDetail.Quantity * InvoiceDetail.SalePrice) * Max(InvoiceDetail.TaxSuffered) / 100), 0),      
	"PKD" = Max(CAST(DATEPART(mm, Batch_Products.PKD) AS nvarchar) + N'\'      
		+ SubString(CAST(DATEPART(yy, Batch_Products.PKD) AS nvarchar), 3, 2)),      
	"Net Rate" = Cast((Case (SELECT TOP 1 Flags FROM InvoiceAbstract WHERE InvoiceID = @INVNO)      
    	WHEN 0 THEN Sum((InvoiceDetail.Quantity * InvoiceDetail.SalePrice)       
		    - (InvoiceDetail.Quantity * InvoiceDetail.SalePrice       
		    * InvoiceDetail.DiscountPercentage / 100) +       
		    (((InvoiceDetail.Quantity * InvoiceDetail.SalePrice)       
		    - (InvoiceDetail.Quantity * InvoiceDetail.SalePrice       
		    * InvoiceDetail.DiscountPercentage / 100))))       
		    * Max(InvoiceDetail.TaxCode) / 100      
	  ELSE Sum((InvoiceDetail.Quantity * InvoiceDetail.SalePrice)       
		    - (InvoiceDetail.Quantity * InvoiceDetail.SalePrice       
		    * InvoiceDetail.DiscountPercentage / 100))      
		    END) / Case isnull(Sum(InvoiceDetail.UOMQty), 0) When 0 Then 1 Else  Sum(InvoiceDetail.UOMQty) End As Decimal(18,6)),      
	"Net Item Rate" = Cast(Max(InvoiceDetail.Amount) / Case isnull(Sum(InvoiceDetail.UOMQty), 0) When 0 Then 1 Else  Sum(InvoiceDetail.UOMQty) End As Decimal(18,6))     
FROM InvoiceDetail, UOM, Items, Batch_Products, Manufacturer, ItemCategories, Brand      
WHERE InvoiceID = @INVNO   
AND InvoiceDetail.Product_Code = Items.Product_Code      
AND InvoiceDetail.UOM *= UOM.UOM      
AND InvoiceDetail.Batch_Code *= Batch_Products.Batch_Code      
AND Items.ManufacturerID *= Manufacturer.ManufacturerID      
AND Items.CategoryID = ItemCategories.CategoryID      
And Items.BrandID = Brand.BrandID      
GROUP BY InvoiceDetail.Product_code, 
	Items.ProductName,
	InvoiceDetail.Batch_Number, 
	UOM.Description,
	Manufacturer.ManufacturerCode, Items.Description, 
	ItemCategories.Category_Name,
	Manufacturer.Manufacturer_Name,Brand.BrandName
