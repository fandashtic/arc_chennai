CREATE procedure sp_ser_itemoptions(@ProductCode nvarchar(15), @CustomerID nVarchar(15) = '')
as
Declare @CustomerType Int  
Declare @SalePrice Decimal(18,6)
If  @CustomerID <> '' 
Begin 
	Select @CustomerType = CustomerCategory  from Customer Where CustomerID = @CustomerID   
	Set @SalePrice = IsNull(dbo.sp_ser_getspareprice(@CustomerType,@ProductCode),0)
end

Select i.Track_Batches 'Batch', i.TrackPKD 'PKD', c.Track_Inventory 'INVENTORY', 
c.Price_Option 'CSP', @SalePrice 'Sale Price'
from Items i 
Inner Join ItemCategories c on i.categoryID = c.categoryID
Where Product_Code = @ProductCode





