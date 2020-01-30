CREATE Procedure sp_ser_rpt_SplCaterogyBrand(@PersonnelId as nvarchar(50))
as
Declare @ParamSep nVarchar(10)
Set @ParamSep = Char(2)
Select 'Personnel' = personnel_item_category.personnelID + @paramsep + Cast(personnel_item_category.CategoryID as nvarchar(10)),
'Specialised in Categories' = Category_Name  
from personnel_item_category,PersonnelMaster,ItemCategories
where personnel_item_category.CategoryID = ItemCategories.CategoryID
and personnel_item_category.personnelID = @PersonnelID
group by personnel_item_category.PersonnelID,Category_Name,personnel_item_category.CategoryID

