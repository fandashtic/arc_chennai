Create Procedure mERP_sp_RefereshGGDRSKUList
As
Begin
Set dateformat dmy

/*Referesh GGDR productList*/

--	Declare @ProdDefnIDListDetails As Nvarchar(max)
--	Declare @Tmp_ProdDefnID as Int

--	Declare Cur_List Cursor for
--	Select Distinct ProdDefnID From GGDRProduct
--	Open Cur_List
--	Fetch from Cur_List into @Tmp_ProdDefnID
--	While @@fetch_status =0
--		Begin
----			If isnull(@ProdDefnIDListDetails,'') <> ''
----			Begin
----				Set @ProdDefnIDListDetails = @ProdDefnIDListDetails + ',' + Cast(@Tmp_ProdDefnID as Nvarchar)
----			End
----			Else
----			Begin
----				Set @ProdDefnIDListDetails = Cast(@Tmp_ProdDefnID as Nvarchar)
----			End
--			Exec Sp_GetGGDRProductList @Tmp_ProdDefnID

--			Fetch Next from Cur_List into @Tmp_ProdDefnID
--		End
--	Close Cur_List
--	Deallocate Cur_List

----	Exec Sp_GetGGDRProductList @ProdDefnIDListDetails

Declare @RecdID Int

Declare @OCG int
Select @OCG=isnull(Flag,0) From Tbl_merp_Configabstract Where ScreenCode = 'OCGDS' And ScreenName ='OperationalCategoryGroup'

Create Table #TmpExItems (ProdDefnID Int,Product_Code Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)

Declare Cur_List Cursor for Select Distinct RecDocID From GGDRProduct

Open Cur_List
Fetch from Cur_List into @RecdID

While @@fetch_status =0
Begin

Truncate Table #TmpExItems
Delete From TmpGGDRSKUDetails Where ProdDefnID In (Select Distinct ProdDefnID From GGDRProduct  Where RecDocID = @RecdID)

If @OCG = 1
Begin
Insert Into #TmpExItems(ProdDefnID,Product_Code)
Select GGP.ProdDefnID, OCGP.SystemSKU
From OCGItemMaster OCGP
Join GGDRProduct GGP On GGP.Products = (Case
When GGP.ProdCatLevel = 2 Then OCGP.Division
When GGP.ProdCatLevel = 3 Then OCGP.SubCategory
When GGP.ProdCatLevel = 4 Then OCGP.MarketSKU
When GGP.ProdCatLevel = 5 Then OCGP.SystemSKU End)  And GGP.RecDocID = @RecdID And IsNull(GGP.IsExcluded,0) = 1
Where IsNull(OCGP.Exclusion,0) = 0

Insert Into TmpGGDRSKUDetails (ProdDefnID, CategoryGroup, Division, SubCategory, MarketSKU, Product_Code)
Select GGP.ProdDefnID, OCGP.GroupName, OCGP.Division, OCGP.SubCategory, OCGP.MarketSKU , OCGP.SystemSKU
From OCGItemMaster OCGP
Join GGDRProduct GGP On GGP.Products = (Case When GGP.Products = 'ALL' Then GGP.Products Else (Case
When GGP.ProdCatLevel = 2 Then OCGP.Division
When GGP.ProdCatLevel = 3 Then OCGP.SubCategory
When GGP.ProdCatLevel = 4 Then OCGP.MarketSKU
When GGP.ProdCatLevel = 5 Then OCGP.SystemSKU End) End)  And GGP.RecDocID = @RecdID  And IsNull(GGP.IsExcluded,0) = 0
Where IsNull(OCGP.Exclusion,0) = 0
And OCGP.SystemSKU Not In (Select Product_Code From #TmpExItems Where ProdDefnID = GGP.ProdDefnID)
End
Else -- @OCG = 0
Begin
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
When GGP.ProdCatLevel = 5 Then SysSKU.Product_Code End)  And GGP.RecDocID = @RecdID  And IsNull(GGP.IsExcluded,0) = 1

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
When GGP.ProdCatLevel = 5 Then SysSKU.Product_Code End)  End)  And GGP.RecDocID = @RecdID  And IsNull(GGP.IsExcluded,0) = 0
Where SysSKU.Product_Code Not In (Select Product_Code From #TmpExItems Where ProdDefnID = GGP.ProdDefnID)
End

Fetch Next from Cur_List into @RecdID
End
Close Cur_List
Deallocate Cur_List

Drop Table #TmpExItems

Exec mERP_sp_UpdateCategory_GGDRData

End
