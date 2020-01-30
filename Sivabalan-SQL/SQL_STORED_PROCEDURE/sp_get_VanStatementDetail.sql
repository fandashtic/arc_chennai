CREATE procedure [dbo].[sp_get_VanStatementDetail] (@DocSerial int)    
as    
Select Max(VanStatementDetail.Product_Code) As Product_Code,   
Max(Items.ProductName) As ProductName,     
Max(VanStatementDetail.Batch_Number) As Batch_Number,    
Max(Batch_Products.Expiry) As Expiry,   
Max(VanStatementDetail.Pending) As Pending, Max(VanStatementDetail.Quantity) As Quantity,     
Max(VanStatementDetail.SalePrice) As SalePrice, Max(VanStatementDetail.Amount) As Amount   
From VanStatementDetail, Items, Batch_Products    
Where VanStatementDetail.DocSerial = @DocSerial And    
VanStatementDetail.Product_Code *= Batch_Products.Product_Code And    
VanStatementDetail.Product_Code = Items.Product_Code And    
VanStatementDetail.Batch_Code *= Batch_Products.Batch_Code    
Group by VanStatementDetail.TransferItemSerial
