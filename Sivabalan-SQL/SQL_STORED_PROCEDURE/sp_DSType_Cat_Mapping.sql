Create Procedure sp_DSType_Cat_Mapping(@DsTypeID Int)
AS
Begin
	Declare @OCG int
	Select @OCG=isnull(Flag,0) From Tbl_merp_Configabstract Where ScreenCode = 'OCGDS' And ScreenName ='OperationalCategoryGroup'

	If @OCG = 1
	  Begin		
		Select Category=Case When MapLevel = 2 Then AllCatMap.Category Else '' End, 
		Sub_Category=Case When MapLevel = 2 Then 'All' When MapLevel = 3 Then AllCatMap.Sub_Category Else '' End, 		
		AllCatMap.Sub_Cat_Desc , 
		MarketSKU=Case When MapLevel = 2 Or MapLevel = 3 Then 'All' When MapLevel = 4 Then AllCatMap.MarketSKU Else '' End, 		
		SystemSKU=Case When MapLevel = 2 Or MapLevel = 3 Or MapLevel = 4 Then 'All' When MapLevel = 5 Then AllCatMap.SystemSKU Else '' End,		
		PortFolio=AllCatMap.PortFolio 		
		From 
		(Select MapLevel=Map.Level,
		Category=IsNull((Case When  Map.Level = 2 Then isnull((Select Category_Name From ItemCategories Where Category_Name=Map.CG_Name And [Level] = 2),Map.CG_Name) Else '' End),''),
		Sub_Category=IsNull((Case When  Map.Level = 3 Then isnull((Select Category_Name From ItemCategories Where Category_Name=Map.CG_Name And [Level] = 3),Map.CG_Name) Else '' End),''),		
		Sub_Cat_Desc=IsNull((Case When  Map.Level = 3 Then (Select [Description] From ItemCategories Where Category_Name=Map.CG_Name And [Level] = 3) Else '' End),''),
		MarketSKU=IsNull((Case When  Map.Level = 4 Then isnull((Select Category_Name From ItemCategories Where Category_Name=Map.CG_Name And [Level] = 4),Map.CG_Name) Else '' End),''),		
		SystemSKU=IsNull((Case When  Map.Level = 5 Then isnull((Select Product_Code From Items Where Product_Code=Map.CG_Name),Map.CG_Name) Else '' End),''),
		PortFolio=IsNull(Map.PortFolio ,'')
		From  OCG_DSTypeCategoryMap Map
		Join DSType_Master DSM On DSM.DSTypeCode = Map.DSTypeCode And DSM.DSTypeId = @DsTypeID and isnull(DSM.Flag,0) <> 0
		) AllCatMap Where AllCatMap.Category <> '' Or AllCatMap.Sub_Category <> '' Or AllCatMap.MarketSKU <> '' Or AllCatMap.SystemSKU <> ''	
		Order By Cast(MapLevel As nVarChar)+AllCatMap.Category+AllCatMap.Sub_Category+AllCatMap.MarketSKU+AllCatMap.SystemSKU
	  End
	Else
	  Begin
		Select Category=Case When MapLevel = 2 Then AllCatMap.Category Else '' End, 
		Sub_Category=Case When MapLevel = 2 Then 'All' When MapLevel = 3 Then AllCatMap.Sub_Category Else '' End, 		
		AllCatMap.Sub_Cat_Desc , 
		MarketSKU=Case When MapLevel = 2 Or MapLevel = 3 Then 'All' When MapLevel = 4 Then AllCatMap.MarketSKU Else '' End, 		
		SystemSKU=Case When MapLevel = 2 Or MapLevel = 3 Or MapLevel = 4 Then 'All' When MapLevel = 5 Then AllCatMap.SystemSKU Else '' End,		
		PortFolio=AllCatMap.PortFolio 		
		From 
		(Select MapLevel=Map.Level,
		Category=IsNull((Case When  Map.Level = 2 Then isnull((Select Category_Name From ItemCategories Where Category_Name=Map.CG_Name And [Level] = 2),Map.CG_Name) Else '' End),''),
		Sub_Category=IsNull((Case When  Map.Level = 3 Then isnull((Select Category_Name From ItemCategories Where Category_Name=Map.CG_Name And [Level] = 3),Map.CG_Name) Else '' End),''),		
		Sub_Cat_Desc=IsNull((Case When  Map.Level = 3 Then (Select [Description] From ItemCategories Where Category_Name=Map.CG_Name And [Level] = 3) Else '' End),''),
		MarketSKU=IsNull((Case When  Map.Level = 4 Then isnull((Select Category_Name From ItemCategories Where Category_Name=Map.CG_Name And [Level] = 4),Map.CG_Name) Else '' End),''),		
		SystemSKU=IsNull((Case When  Map.Level = 5 Then isnull((Select Product_Code From Items Where Product_Code=Map.CG_Name),Map.CG_Name) Else '' End),''),
		PortFolio=IsNull(Map.PortFolio ,'')
		From  DSTypeCGCategoryMap Map
		Join DSType_Master DSM On DSM.DSTypeCode = Map.DSTypeCode And DSM.DSTypeId = @DsTypeID and isnull(DSM.Flag,0) <> 0
		) AllCatMap Where AllCatMap.Category <> '' Or AllCatMap.Sub_Category <> '' Or AllCatMap.MarketSKU <> '' Or AllCatMap.SystemSKU <> ''		
		Order By Cast(MapLevel As nVarChar)+AllCatMap.Category+AllCatMap.Sub_Category+AllCatMap.MarketSKU+AllCatMap.SystemSKU
	  End
End 
