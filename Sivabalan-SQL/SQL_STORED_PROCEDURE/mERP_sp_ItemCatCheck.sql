Create Procedure mERP_sp_ItemCatCheck ( @Catname nVarchar(255))
As
  Declare @CountCatname int
  Select @CountCatname = Count(*) from ItemCategories where category_name= @Catname 
  Select @CountCatname 

