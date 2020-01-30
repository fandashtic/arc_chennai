Create Procedure mERP_Sp_LisSubcategoryLevel
As
Begin
     Select I.CategoryId,Category_Name,Description,
     isnull(M.Percentage,0),isnull(M.EffectiveDate,Getdate()),I.ParentID,
     M.Percentage   
     From ItemCategories I
	 Left Outer Join MarginDetail M  On I.CategoryId = M.CategoryId and I.ParentID=M.ParentID
     Where Active = 1 And IsNull(Level,0) = 3 and M.MarginID in (select Max(MarginID) from MarginAbstract)       
     order by I.ParentID,Category_Name     
End
