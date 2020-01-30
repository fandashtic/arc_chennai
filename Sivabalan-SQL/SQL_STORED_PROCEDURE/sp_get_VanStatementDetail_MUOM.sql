CREATE procedure [dbo].[sp_get_VanStatementDetail_MUOM] (@DocSerial int)        
as    
Select  Max(VanStatementDetail.Product_Code) As Product_Code,       
 Max(Items.ProductName) As ProductName,       
 "Batch" = Max(VanStatementDetail.Batch_Number),        
 "Expiry" = Max(Batch_Products.Expiry),       
 "Pending" = dbo.GetQtyAsMultiple (Max(VanStatementDetail.Product_Code), sum(VanStatementDetail.Pending)),      
-- "Pending" = sum(VanStatementDetail.Pending),       
 "Total Qty" = dbo.GetQtyAsMultiple (Max(VanStatementDetail.Product_Code), Sum(VanStatementDetail.Quantity)),      
-- VanStatementDetail.Quantity,         
 "SalePrice" = Max(VanStatementDetail.SalePrice),       
-- "Amount" = sum(VanStatementDetail.Amount)  ,      
 "Amount" = sum(Pending) * Max(VanStatementDetail.SalePrice),
 "UOM" = Case when IsNull(Max(Items.UOM1), 0) = 0 and IsNull(Max(Items.UOM2), 0) = 0       
  then IsNull(Max(UOM.Description), N'')       
  else N'Multiple' end,           
 "UOM QTY" = SUM(VanStatementDetail.UOMQTY),           
 "UOM Price" = sum(VanStatementDetail.UOMPrice)          
      
From  VanStatementDetail, Items, Batch_Products, UOM      
Where VanStatementDetail.DocSerial = @DocSerial And        
 VanStatementDetail.Product_Code *= Batch_Products.Product_Code And        
 VanStatementDetail.Product_Code = Items.Product_Code And        
 VanStatementDetail.Batch_Code *= Batch_Products.Batch_Code and      
 Items.UOM *= UOM.UOM      
Group by VanStatementDetail.TransferItemSerial
