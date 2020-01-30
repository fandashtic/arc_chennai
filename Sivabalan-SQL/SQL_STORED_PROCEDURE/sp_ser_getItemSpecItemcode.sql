CREATE procedure sp_ser_getItemSpecItemcode (@ItemSpec1 nvarchar(50))
as
Select Product_Code,'ProductName' = dbo.sp_ser_getitemname(Product_Code)
from Item_Information
Where Product_Specification1 = @ItemSpec1

/*Item spec1 is unique in Item Information*/

