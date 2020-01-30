CREATE procedure sp_ser_loadpersonnelnameinfo(@PersonneID nvarchar(50),@PersonnelName nvarchar(200))    
as    
Select Personnel_Item_Category.CategoryID,Category_Name,PersonnelName,PersonnelMaster.PersonnelID 
from Personnel_Item_Category,ItemCategories,PersonnelMaster    
where PersonnelMaster.PersonnelID = @PersonneID     
and personnel_item_category.PersonnelID = @PersonneID  
and ItemCategories.CategoryID = Personnel_Item_Category.CategoryID    


