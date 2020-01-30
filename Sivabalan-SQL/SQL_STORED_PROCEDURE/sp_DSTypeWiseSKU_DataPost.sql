Create Procedure sp_DSTypeWiseSKU_DataPost
As
BEGIN
	Declare @OCG int
	Select @OCG=isnull(Flag,0) From Tbl_merp_Configabstract Where ScreenCode = 'OCGDS' And ScreenName ='OperationalCategoryGroup'
		
	Begin Tran		
	
	Truncate Table DSTypeWiseSKU
	
	If @OCG = 1
	Begin
		Insert Into DSTypeWiseSKU (DSTypeID, DSTypeCode, OCGType, CatMapID, GroupName, Division, Sub_Category, Market_SKU, System_SKU)	
		Select DISTINCT DSTypeID=DSM.DSTypeId, DSM.DSTypeCode, OCG=IsNull(DSM.OCGType,0), DSCat.ID, CGrp=OCGP.OCGCode , 
		Div=Div.Category_Name, SubCat=SubCat.Category_Name, MSKU=MSKU.Category_Name,  Product_Code =I.Product_Code 
		From ItemCategories MSKU
		Join Items I On I.CategoryID = MSKU.CategoryID And  I.Active = 1
		Join ItemCategories SubCat on SubCat.CategoryID  = MSKU.ParentID And SubCat.Level = 3
		Join ItemCategories Div on Div.CategoryID = SubCat.ParentID And Div.Level = 2		
		Join OCG_Product OCGP On OCGP.ProductCategoryName = (Case 		
		When OCGP.Level = 2 Then Div.Category_Name
		When OCGP.Level = 3 Then SubCat.Category_Name
		When OCGP.Level = 4 Then MSKU.Category_Name
		When OCGP.Level = 5 Then I.Product_Code End)	And OCGP.Exclusion = 0 
		Join  ProductCategoryGroupAbstract PCGA On PCGA.GroupName = OCGP.OCGCode  And IsNull(PCGA.OCGType,0) = 1 And PCGA.Active = 1 
		Join tbl_mERP_DSTypeCGMapping Map On Map.GroupID = PCGA.GroupId And Map.Active = 1
		Join DSType_Master DSM On DSM.DSTypeId = Map.DSTypeID  And IsNull(DSM.Flag,0) <> 0 And DSM.Active  = 1 And DSM.DSTypeCtlPos =1 And IsNull(DSM.OCGType ,0) = 1
		Join OCG_DSTypeCategoryMap DSCat On DSCat.CG_Name  =  (Case 
		When DSCat.Level = 2 Then Div.Category_Name
		When DSCat.Level = 3 Then SubCat.Category_Name
		When DSCat.Level = 4 Then MSKU.Category_Name
		When DSCat.Level = 5 Then I.Product_Code End) And DSCat.DSTypeID = DSM.DSTypeID 
		Where MSKU.Level  = 4		
		Order by Div.Category_Name		
	End
	Else -- @OCG = 0
	Begin
		Insert Into DSTypeWiseSKU  (DSTypeID, DSTypeCode, OCGType, CatMapID, GroupName, Division, Sub_Category, Market_SKU, System_SKU)		
		Select DISTINCT DSTypeID=DSM.DSTypeID, DSM.DSTypeCode, OCG=IsNull(DSM.OCGType,0), DSCat.ID, CGrp=DivMap.CategoryGroup , 
		Div=Div.Category_Name, SubCat=SubCat.Category_Name, MSKU=MSKU.Category_Name,  Product_Code =I.Product_Code 
		From ItemCategories MSKU
		Join Items I On I.CategoryID = MSKU.CategoryID And  I.Active = 1
		Join ItemCategories SubCat on SubCat.CategoryID  = MSKU.ParentID And SubCat.Level = 3
		Join ItemCategories Div on Div.CategoryID = SubCat.ParentID And Div.Level = 2		
		Join tblCGDivMapping DivMap on DivMap.Division = Div.Category_Name 
		Join  ProductCategoryGroupAbstract PCGA On PCGA.GroupName = DivMap.CategoryGroup  And PCGA.Active = 1
		Join tbl_mERP_DSTypeCGMapping Map On Map.GroupID = PCGA.GroupId And Map.Active = 1
		Join DSType_Master DSM On DSM.DSTypeId = Map.DSTypeID And IsNull(DSM.Flag,0) <> 0 And DSM.Active  = 1 And DSM.DSTypeCtlPos =1
		Join DSTypeCGCategoryMap DSCat On DSCat.CG_Name  =  (Case 		
		When DSCat.Level = 2 Then Div.Category_Name
		When DSCat.Level = 3 Then SubCat.Category_Name
		When DSCat.Level = 4 Then MSKU.Category_Name
		When DSCat.Level = 5 Then I.Product_Code End) And DSCat.DSTypeID = DSM.DSTypeID
		Where MSKU.Level  = 4	
		Order by Div.Category_Name
	End
				
	Commit Tran
	
End
