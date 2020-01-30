
CREATE Procedure sprc_Stock_by_ItemCategory_Details 
                (@CATID INT,
                 @FROMDATE DATETIME,
                 @TODATE DATETIME)
as

Select 	

"Item Code" = Batch_Products.Product_Code,
"Item Name" = Items.ProductName,
"StockValue"  = cast(ISNULL(SUM(Batch_Products.quantity * Batch_Products.Purchaseprice),0) as decimal(18,2)), 
"StockQty (UOM)" = cast(cast(ISNULL(SUM(Batch_Products.Quantity), 0) as decimal(18,2)) as nvarchar)
		+ ' ' + (SELECT Description From UOM WHERE UOM = Items.UOM) ,
"StockQty (CF)" = cast(cast(ISNULL(SUM(Batch_Products.Quantity * Items.ConversionFactor),0) as decimal (18,2) ) as nvarchar)
		+ ' ' + (SELECT ConversionUnit From ConversionTable WHERE ConversionID = Items.ConversionUnit) ,
"StockQty (RU)" = cast(cast(SUM(Batch_Products.Quantity / (case ISNULL(Items.ReportingUnit, 0) 	
		when 0 then 1 else ISNULL(Items.ReportingUnit, 0) end)) as decimal(18,2) ) as nvarchar)  + ' ' 
		+ (SELECT Description From UOM WHERE UOM = Items.ReportingUOM)

from Batch_Products,Items
where 
	Batch_Products.product_code = items.product_code And Items.Categoryid=@CatID
Group by
	Batch_Products.Product_Code,
	Items.ProductName , 
	Items.UOM, 
	Items.ReportingUOM,  
	Items.ConversionUnit 

