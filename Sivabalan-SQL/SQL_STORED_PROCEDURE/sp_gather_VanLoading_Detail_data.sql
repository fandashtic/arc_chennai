
create procedure sp_gather_VanLoading_Detail_data (@DocSerial int)
as
Select DocSerial, Product_Code, Batch_Code, Batch_Number, Quantity, Pending, SalePrice,
Amount, PurchasePrice, BFQty From VanStatementDetail
Where DocSerial = @DocSerial

