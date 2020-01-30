CREATE function fn_han_Get_SchemesItemsPR(@ItemGroup Int)
Returns @Items Table  
( 
SchemeID int,
ProductScopeID int,
Product_code NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
CategoryID int,UOM int,UOM1 int,UOM2 int  
) 
As 
Begin
	Insert Into @Items 
	Select ScPrdMap.SchemeId, ScPrdMap.ProductScopeId, 
		ItmCtg.Product_Code, Itm_CategoryId, ItmCtg.Uom, ItmCtg.Uom1, ItmCtg.Uom2 
	from ( 
			Select ItcDiv.CategoryId DivId, ItcDiv.Category_Name DivName,
			ItcSubC.CategoryId SubCId, ItcSubC.Category_Name SubCName,
			ItcMkt.CategoryId MktId, ItcMkt.Category_Name MktName,
			Itm.CategoryId Itm_CategoryId, Itm.Product_Code, Itm.Uom, Itm.Uom1, Itm.Uom2 
			From ItemCategories ItcDiv 
			Join ItemCategories ItcSubC on ItcDiv.CategoryId = ItcSubC.ParentId 
			Join ItemCategories ItcMkt on ItcSubC.CategoryId = ItcMkt.ParentId  
			Join Items Itm on ItcMkt.CategoryId = Itm.CategoryId 
			where Itm.Active = 1
		) ItmCtg 
	Join (
			Select SchAbs.SchemeId SchemeId, SchPrdScMap.ProductScopeId ProductScopeId, 
			SchDiv.Category SchDiv_Category, SchSubC.SubCategory SchSubC_Category,
			SchMkt.MarketSku SchMkt_Category, SchItm.SkuCode SchItm_Category
			From tbl_mERP_SchemeAbstract SchAbs 
			Join tbl_mERP_SchemeProductScopeMap SchPrdScMap on SchAbs.SchemeId = SchPrdScMap.SchemeId
			Join tbl_mERP_SchCategoryScope SchDiv on SchPrdScMap.ProductScopeId = SchDiv.ProductScopeId
			Join tbl_mERP_SchSubCategoryScope SchSubC on SchPrdScMap.ProductScopeId = SchSubC.ProductScopeId
			Join tbl_mERP_SchMarketSKUScope SchMkt on SchPrdScMap.ProductScopeId = SchMkt.ProductScopeId  
			Join tbl_mERP_SchSKUCodeScope SchItm on SchPrdScMap.ProductScopeId = SchItm.ProductScopeId
			where SchAbs.ItemGroup = @ItemGroup and SchAbs.SchemeType In (5) and SchAbs.Active = 1  
			and convert(datetime, convert(varchar(10), getdate(), 103 ), 103) between SchAbs.activefrom and SchAbs.activeto
			and IsNull(SchAbs.schemestatus, 0) In ( 0, 1 )

			Union 

			Select SchAbs.SchemeId SchemeId, SchPrdScMap.ProductScopeId ProductScopeId, 
			SchDiv.Category SchDiv_Category, SchSubC.SubCategory SchSubC_Category,
			SchMkt.MarketSku SchMkt_Category, SchItm.SkuCode SchItm_Category
			From tbl_mERP_SchemeAbstract SchAbs 
			Join tbl_mERP_SchemeProductScopeMap SchPrdScMap on SchAbs.SchemeId = SchPrdScMap.SchemeId
			Join tbl_mERP_SchCategoryScope SchDiv on SchPrdScMap.ProductScopeId = SchDiv.ProductScopeId
			Join tbl_mERP_SchSubCategoryScope SchSubC on SchPrdScMap.ProductScopeId = SchSubC.ProductScopeId
			Join tbl_mERP_SchMarketSKUScope SchMkt on SchPrdScMap.ProductScopeId = SchMkt.ProductScopeId  
			Join tbl_mERP_SchSKUCodeScope SchItm on SchPrdScMap.ProductScopeId = SchItm.ProductScopeId
			where SchAbs.ItemGroup = @ItemGroup and SchAbs.SchemeType In (5) and SchAbs.Active = 1  
			and convert(datetime, convert(varchar(10), getdate(), 103 ), 103) between SchAbs.activefrom and SchAbs.activeto
			and IsNull(SchAbs.schemestatus, 0) In ( 2 )
		) ScPrdMap
	on ScPrdMap.SchDiv_Category = 
		( Case when ScPrdMap.SchDiv_Category = 'ALL' then 'ALL' 
			Else ItmCtg.DivName
		 End )
	and ScPrdMap.SchSubC_Category = 
		( Case when ScPrdMap.SchSubC_Category = 'ALL' then 'ALL' 
			Else ItmCtg.SubCName
		 End )
	and ScPrdMap.SchMkt_Category = 
		( Case when ScPrdMap.SchMkt_Category = 'ALL' then 'ALL' 
			Else ItmCtg.MktName
		 End )
	and ScPrdMap.SchItm_Category = 
		( Case when ScPrdMap.SchItm_Category = 'ALL' then 'ALL' 
			Else ItmCtg.Product_Code
		 End )

RETURN
End
