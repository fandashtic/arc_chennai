CREATE procedure sp_ser_invoicespareinfo_fmcg 
(@CustomerID nvarchar(50), @ProductCode nvarchar(50)) as  
Declare @Locality Int
Select @Locality = IsNull(Locality,1) from Customer Where CustomerID = @CustomerID   
  
Select 'SpareCode' = i.Product_Code,'SpareName' = i.ProductName,  
'UOMDescription' = u.[Description],'UOMCode' = i.UOM, 'SalePrice'= IsNull(i.sale_price,0),  
'TaxSufferedPercentage' = IsNUll(dbo.sp_ser_taxpercenatge(1,IsNull(i.TaxSuffered,0),0),0),  
'SalesTaxPercentage'=IsNull(dbo.sp_ser_taxpercenatge(@Locality,i.Sale_Tax,0),0),  
'UOMPrice' = IsNull(dbo.sp_ser_getuomprice_fmcg(i.Product_Code, i.UOM),0),  
i.Track_Batches 'Batch', i.TrackPKD 'PKD', c.Track_Inventory 'INVENTORY',   
c.Price_Option 'CSP', 'UOMConverstion' = 1, i.Sale_Tax 'SaleTaxCode', 
IsNull(i.Vat, 0) 'vat', IsNull(i.CollectTaxSuffered, 0) 'CollectTaxSuffered'
from Items i   
Inner Join ItemCategories c on i.categoryID = c.categoryID  
Inner Join UOM u on i.UOM = u.UOM   
where i.Product_Code = @ProductCode 



