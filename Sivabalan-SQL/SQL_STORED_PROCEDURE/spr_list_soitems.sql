Create PROCEDURE spr_list_soitems(@SONUMBER int)  
AS  
SELECT SODetail.Product_Code, "Item Code" = SODetail.Product_Code,   
"Item Name" = Items.ProductName, "Batch" = Batch_Number,  
Quantity, Pending, "Sale Price" = SalePrice,   
"Sale Tax" = CAST(ISNULL(SaleTax, 0) AS NVARCHAR) + '+'   
+ CAST(ISNULL(TaxCode2, 0) AS NVARCHAR),   
"Discount%" = Discount,  
"Tax Suffered" = ISNULL(SODetail.TaxSuffered, 0)   
FROM SODetail, Items WHERE SONumber = @SONUMBER   
And SODetail.Product_Code = Items.Product_Code  
order by Sodetail.Serial  
