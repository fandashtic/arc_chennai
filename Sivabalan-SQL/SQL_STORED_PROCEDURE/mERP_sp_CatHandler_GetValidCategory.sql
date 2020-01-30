Create procedure mERP_sp_CatHandler_GetValidCategory(@Category nVarchar(510), @SubCategory nVarchar(510))  
As  
Begin  
 Select Distinct Case @SubCategory When 'ALL' then 999999 Else ICL2.CategoryID End
 from ItemCategories ICL3, ItemCategories ICL2  
 Where ICL3.CategoryID = ICL2.ParentID   
 And ICL2.Category_Name Like Case @SubCategory When 'ALL' then '%' Else @SubCategory End
 And ICL3.Category_Name Like Case @Category  When 'ALL' then '%' Else @Category End
End
