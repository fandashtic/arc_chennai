CREATE procedure sp_ser_loaditeminformation (@Product_Code nvarchar(15),
@ItemSpec1 nvarchar(50))
as
Select SerialNo,Product_Code,'ProductName' = dbo.sp_ser_getitemname(Product_Code),
Product_Specification1,Product_Specification2,Product_Specification3,
Product_Specification4,Product_Specification5,DateofSale, SoldBy, 
IsNull(GeneralMaster.[Description],'') 'Description', IsNull(Product_Status,0) 'Status'  
from Item_Information
Left Outer Join GeneralMaster On Item_Information.Color = GeneralMaster.Code
Where Product_Specification1 = @ItemSpec1

/*Item spec1 is unique in Item Information*/

