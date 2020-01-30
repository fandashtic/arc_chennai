CREATE procedure sp_ser_loadpersonnelinfo(@PersonnelID nvarchar(50))
as
Select Personnel_Item_Category.CategoryID,Category_Name from Personnel_Item_Category,ItemCategories
where PersonnelID = @PersonnelID 
and ItemCategories.CategoryID = Personnel_Item_Category.CategoryID
 

