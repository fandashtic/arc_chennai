Create Procedure mERP_Sp_ListDivisionLevelCategory  
as
Begin
 Select I.CategoryId, Category_Name,isnull(M.Percentage,0),isnull(M.EffectiveDate,Getdate()),
 (select count(*) from  ItemCategories where ParentID=I.CategoryID),M.EffectiveDate          
 From ItemCategories I
 Left Outer Join  MarginDetail M  On I.CategoryId = M.CategoryId        
 Where I.Active = 1 And IsNull(Level,0) = 2  and M.ParentID=0 and M.MarginID in (select Max(MarginID) from MarginAbstract)
 order by 2  
End
