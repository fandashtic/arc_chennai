CREATE procedure sp_ser_invoicetaskinfo_fmcg 
(@CustomerID nvarchar(50), @TaskID nvarchar(50), @ProductCode nvarchar(50)) as
Declare @Locality Int 
Select @Locality = IsNull(Locality,1) from Customer Where CustomerID = @CustomerID 

Select 'SpareCode' = i.Product_Code, 'SpareName' = i.ProductName,
'UOMDescription' = u.[Description], 'UOMCode' = t.UOM, 'SalePrice'= IsNull(i.sale_price,0),
'TaxSufferedPercentage' = IsNUll(dbo.sp_ser_taxpercenatge(1,IsNull(i.TaxSuffered,0),0),0),
'SalesTaxPercentage'=IsNull(dbo.sp_ser_taxpercenatge(@Locality,i.Sale_Tax,0),0),
'UOMPrice' = IsNull(dbo.sp_ser_getuomprice_fmcg(i.Product_Code, i.UOM),0),
i.Track_Batches 'Batch', i.TrackPKD 'PKD', c.Track_Inventory 'INVENTORY', 
c.Price_Option 'CSP', 'UOMQty' = t.UOMQty, 
'UOMConverstion' = (Case t.UOM when i.UOM then 1 when i.UOM1 then UOM1_Conversion 
when i.UOM2 then UOM2_Conversion end), 
IsNull(i.Vat, 0) 'vat', IsNull(i.CollectTaxSuffered, 0) 'CollectTaxSuffered'
from Task_Items_Spares t 
Inner Join Items i on i.Product_Code = t.SpareCode 
Inner Join ItemCategories c on i.categoryID = c.categoryID 
Inner Join UOM u on t.UOM = u.UOM 
where t.Product_Code = @ProductCode and t.TaskId = @TaskId 



