CREATE Procedure Sp_Get_NextItem_OrderForms @DocSerial int, @Product_Code nvarchar(30) As  
Select Top 1 Items.Product_Code 'Product_Code', Items.ProductName 'Product_Name'   
from OrderDetail OD, OrderAbstract OA, Items  
Where Items.Product_Code = OD.Product_Code and   
  OD.DocSerial = OA.DocSerial and OA.Active = 1 and
  Serial > Isnull((Select Serial From OrderDetail   
     Where DocSerial = @DocSerial and   
     Product_Code = @Product_Code),0) and   
  OA.DocSerial = @DocSerial  and Items.Active = 1
Order By Serial

