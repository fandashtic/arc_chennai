CREATE Procedure sp_get_SchemeDetail_rec (@SchemeID INT)    
as    
Select StartValue,EndValue,FreeValue,FreeItem = Case                 
When Not Exists(Select Alias from Items Where Alias = schemeitems_rec.freeItem) Then                
N'' Else (Select Product_Code from Items Where Alias = schemeitems_rec.freeItem) End, FromItem, ToItem     
from SchemeItems_rec where schemeID=@SchemeID order by startvalue asc     
    



