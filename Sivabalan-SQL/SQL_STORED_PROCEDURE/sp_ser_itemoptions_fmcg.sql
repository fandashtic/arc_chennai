CREATE procedure sp_ser_itemoptions_fmcg(@ProductCode nvarchar(15))
as
Select i.Track_Batches 'Batch', i.TrackPKD 'PKD', c.Track_Inventory 'INVENTORY', 
c.Price_Option 'CSP', Sale_Price 'Sale Price'
from Items i 
Inner Join ItemCategories c on i.categoryID = c.categoryID
Where Product_Code = @ProductCode


