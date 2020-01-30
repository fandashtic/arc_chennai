Create function getDivisionName(@Product_Code nvarchar(15))      
returns nvarchar(255)    
as      
Begin
Declare @BrandName nvarchar(255)    
select @BrandName = BrandName 
from Items , Brand
Where Items.BrandID = Brand.BrandID
And Items.Product_Code = @Product_Code
return  @BrandName 
End
    
  


