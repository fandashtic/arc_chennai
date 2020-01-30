CREATE Procedure sp_Check_MappedSplCat(@SchemeName nvarchar(250))
as
select [Description]=Special_category.[description], [SchemeName]=(select 
schemes.schemeName from schemes where SchemeID = Special_Category.SchemeID)
from Special_category, Special_Category_Rec
    where Special_Category.[Description] = Special_Category_Rec.[Description]
and Special_Category.schemeID != 0
    and Special_Category_Rec.schemeID = 
    (select schemes_rec.schemeid from schemes_rec where schemename like @SchemeName
and schemes_rec.Flag = 1)

