Create Procedure mERP_SP_LoadQuoCategories(@Level int, @GR4Specific int = 0)  
As  
Begin
    If @GR4Specific = 0 
    Begin  
      select Category_Name,Description,CategoryID from ItemCategories where Level =@Level  
      and Active=1 order by Category_name   
    End
    Else
    Begin
      select Distinct IC.Category_Name,IC.Description,IC.CategoryID from ItemCategories IC,  
            (Select ICatA.CategoryID 'Level_2', ICatB.CategoryID 'Level_3', ICatC.CategoryID 'Level_4'
			from ProductCategoryGroupAbstract PrCGAb, tblcgdivmapping PrCGDt, 
				 ItemCategories iCatA, ItemCategories iCatB, ItemCategories iCatC
			Where PrCGAb.GroupName = N'GR4' and 
			PrCGAb.GroupName = PrCGDt.CategoryGroup and 
			iCatA.Category_Name = PrCGDt.Division and 
			iCatA.CategoryID = iCatB.ParentID and 
			iCatC.ParentID = iCatB.CategoryID) GR4_Cat
      Where IC.Active=1 And IC.CategoryID = Case @Level When 2 Then GR4_Cat.Level_2 When 3 Then GR4_Cat.Level_3 When 4 Then GR4_Cat.Level_4 End
      order by IC.Category_name   
    End
End
