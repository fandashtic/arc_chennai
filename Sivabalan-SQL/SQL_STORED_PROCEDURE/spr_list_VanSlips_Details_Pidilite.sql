CREATE procedure [dbo].[spr_list_VanSlips_Details_Pidilite] (@doccount int)    
as    
select  VanStatementDetail.Product_Code,     
 "Item Name" = Items.ProductName,     
 "Batch Number" = VanStatementDetail.Batch_Number,    
 "Expiry" = Batch_Products.Expiry,    
 "PKD" = Batch_Products.PKD,    
 "Sale Price" = VanStatementDetail.SalePrice,     
 "Total Quantity" = sum(VanStatementDetail.Quantity),     
 "Amount" = sum(VanStatementDetail.Amount),    
 "Sold Quantity" = Sum(VanStatementDetail.Quantity-VanStatementDetail.Pending),    
 "Unsold Quantity" = sum(VanStatementDetail.Pending)    
from  VanStatementDetail, Items, Batch_Products    
where  VanStatementDetail.Product_Code = Items.Product_Code and    
 VanStatementDetail.Batch_Code *= Batch_Products.Batch_Code and    
 VanStatementDetail.DocSerial = @doccount     
group by    
 VanStatementDetail.Product_Code,    
 Items.ProductName,    
 VanStatementDetail.Batch_Number,    
 Batch_Products.Expiry,Batch_Products.PKD,    
 VanStatementDetail.SalePrice
