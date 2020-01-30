CREATE procedure sp_ser_loaditems(@PersonnelID nvarchar(50),@CategoryID Int)  
as  
Select Personnel_Item_Category.Product_Code,ProductName from Personnel_Item_Category,Items  
where PersonnelID = @PersonnelID   
and Personnel_Item_Category.CategoryID = @CategoryID  
and Items.Product_Code = Personnel_Item_Category.Product_Code  
  

