Create function mERP_fn_Get_GR4CategoriesID()
Returns @tblGR4Category table (Level2_CatID int, Level3_CatID int, Level4_CatID int)
As
Begin
--declare @tmpGR4Category as table(L1_CategoryID int, L2_CategoryID int, L3_CategoryID int)
  Insert into @tblGR4Category
  Select ICatA.CategoryID, ICatB.CategoryID, ICatC.CategoryID 
  From ProductCategoryGroupAbstract PrCGAb, tblcgdivmapping PrCGDt,
     ItemCategories iCatA, ItemCategories iCatB, ItemCategories iCatC 
  Where PrCGAb.GroupName = N'GR4' and 
   PrCGAb.GroupName = PrCGDt.CategoryGroup and
   iCatA.Category_Name = PrCGDt.Division and 
   iCatA.CategoryID = iCatB.ParentID and 
   iCatC.ParentID = iCatB.CategoryID
Return 
End
