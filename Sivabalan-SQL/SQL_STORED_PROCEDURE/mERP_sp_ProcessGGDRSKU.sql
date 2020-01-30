Create Procedure mERP_sp_ProcessGGDRSKU(@RecdID Int)
As
Begin
	Declare @OCG int
	Select @OCG=isnull(Flag,0) From Tbl_merp_Configabstract Where ScreenCode = 'OCGDS' And ScreenName ='OperationalCategoryGroup'
	
	--Create Table #ProdDefnIDList (ProdDefnID Int)
	Create Table #TmpExItems (ProdDefnID Int,Product_Code Nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)	
	
	--Insert Into #ProdDefnIDList (ProdDefnID)	 Select Distinct ProdDefnID  From GGDRProduct Where RecDocID = @RecdID 
	--Exec mERP_sp_Update_GGDRErrorStatus @RecdID,'Delete From TmpGGDRSKUDetails'	
	Delete From TmpGGDRSKUDetails Where ProdDefnID In (Select Distinct ProdDefnID From GGDRProduct  Where RecDocID = @RecdID)
	--(Select Distinct ProdDefnID From #ProdDefnIDList)		
	
	If @OCG = 1
	Begin
		--Exec mERP_sp_Update_GGDRErrorStatus @RecdID,'Select IsExcluded(OCG)'	
		Insert Into #TmpExItems(ProdDefnID,Product_Code)		
		Select GGP.ProdDefnID, OCGP.SystemSKU 
		From OCGItemMaster OCGP
		Join GGDRProduct GGP On GGP.Products = (Case 
		When GGP.ProdCatLevel = 2 Then OCGP.Division 
		When GGP.ProdCatLevel = 3 Then OCGP.SubCategory 
		When GGP.ProdCatLevel = 4 Then OCGP.MarketSKU 
		When GGP.ProdCatLevel = 5 Then OCGP.SystemSKU End)  And RecDocID = @RecdID And IsNull(GGP.IsExcluded,0) = 1		
		Where IsNull(OCGP.Exclusion,0) = 0		
		--Exec mERP_sp_Update_GGDRErrorStatus @RecdID,'Insert Into TmpGGDRSKUDetails(OCG)'	
		Insert Into TmpGGDRSKUDetails (ProdDefnID, CategoryGroup, Division, SubCategory, MarketSKU, Product_Code)
		Select GGP.ProdDefnID, OCGP.GroupName, OCGP.Division, OCGP.SubCategory, OCGP.MarketSKU , OCGP.SystemSKU  
		From OCGItemMaster OCGP
		Join GGDRProduct GGP On GGP.Products = (Case When GGP.Products = 'ALL' Then GGP.Products Else (Case 
		When GGP.ProdCatLevel = 2 Then OCGP.Division 
		When GGP.ProdCatLevel = 3 Then OCGP.SubCategory 
		When GGP.ProdCatLevel = 4 Then OCGP.MarketSKU 
		When GGP.ProdCatLevel = 5 Then OCGP.SystemSKU End) End)  And RecDocID = @RecdID  And IsNull(GGP.IsExcluded,0) = 0
		Where IsNull(OCGP.Exclusion,0) = 0
		And OCGP.SystemSKU Not In (Select Product_Code From #TmpExItems Where ProdDefnID = GGP.ProdDefnID)
	End
	Else -- @OCG = 0
	Begin
		--Exec mERP_sp_Update_GGDRErrorStatus @RecdID,'Select IsExcluded'	
		Insert Into #TmpExItems(ProdDefnID,Product_Code)		
		Select GGP.ProdDefnID, SysSKU.Product_Code 
		From Items SysSKU
		Join ItemCategories MSKU On MSKU.CategoryID = SysSKU.CategoryID And MSKU.Level = 4
		Join ItemCategories SubCat On SubCat.CategoryID = MSKU.ParentID  And SubCat.Level = 3
		Join ItemCategories Div On Div.CategoryID = SubCat.ParentID And Div.Level = 2		
		Join GGDRProduct GGP On GGP.Products = (Case 
		When GGP.ProdCatLevel = 2 Then Div.Category_Name 
		When GGP.ProdCatLevel = 3 Then SubCat.Category_Name 
		When GGP.ProdCatLevel = 4 Then MSKU.Category_Name  
		When GGP.ProdCatLevel = 5 Then SysSKU.Product_Code End)  And RecDocID = @RecdID  And IsNull(GGP.IsExcluded,0) = 1
		--Where GGP.ProdDefnID  In (select Distinct ProdDefnID From #ProdDefnIDList)				
		--Exec mERP_sp_Update_GGDRErrorStatus @RecdID,'Insert Into TmpGGDRSKUDetails'	
		Insert Into TmpGGDRSKUDetails (ProdDefnID, CategoryGroup, Division, SubCategory, MarketSKU, Product_Code)
		Select GGP.ProdDefnID, CGDiv.CategoryGroup  ,	Div.Category_Name , SubCat.Category_Name , MSKU.Category_Name ,  SysSKU.Product_Code 
		From Items SysSKU
		Join ItemCategories MSKU On MSKU.CategoryID = SysSKU.CategoryID And MSKU.Level = 4
		Join ItemCategories SubCat On SubCat.CategoryID = MSKU.ParentID  And SubCat.Level = 3
		Join ItemCategories Div On Div.CategoryID = SubCat.ParentID And Div.Level = 2
		Join tblCGDivMapping CGDiv On CGDiv.Division = Div.Category_Name 
		Join GGDRProduct GGP On GGP.Products = (Case When GGP.Products = 'ALL'  Then GGP.Products Else (Case 
		When GGP.ProdCatLevel = 2 Then Div.Category_Name 
		When GGP.ProdCatLevel = 3 Then SubCat.Category_Name 
		When GGP.ProdCatLevel = 4 Then MSKU.Category_Name  
		When GGP.ProdCatLevel = 5 Then SysSKU.Product_Code End)  End)  And RecDocID = @RecdID  And IsNull(GGP.IsExcluded,0) = 0
		Where SysSKU.Product_Code Not In (Select Product_Code From #TmpExItems Where ProdDefnID = GGP.ProdDefnID)		
	End
	
	Update Recd_GGDR Set Status = 1 Where ID = @RecdID 
	
	--Exec mERP_sp_Update_GGDRErrorStatus @RecdID,'mERP_sp_ProcessGGDRSKU End'	
	
End
