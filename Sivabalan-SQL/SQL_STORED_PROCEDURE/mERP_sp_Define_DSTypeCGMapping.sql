Create Procedure mERP_sp_Define_DSTypeCGMapping
As
Begin
	Create Table #tmpDSTypeCGMapping(
		DS_TYPE_CODE nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS, 
		DS_TYPE_DESC nVarchar(510) Collate SQL_Latin1_General_CP1_CI_AS, 	
		CG_CODE	nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS, 
		ACTIVE Int)

	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('01','Grocery 1 Ds','GR1',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('02','Grocery 2 Ds','GR2',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('03','Grocery 3 Ds','GR1',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('03','Grocery 3 Ds','GR3',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('04','Grocery 1 Ds FCF','GR1',0)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('05','Grocery 2 Ds PG&C','GR2',0)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('06','Common Ds','GR1',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('06','Common Ds','GR2',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('06','Common Ds','GR3',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('07','First Club Ds','GR1',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('07','First Club Ds','GR2',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('07','First Club Ds','GR3',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('08','Town Wholesale FMCG Ds','GR1',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('08','Town Wholesale FMCG Ds','GR2',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('08','Town Wholesale FMCG Ds','GR3',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('09','Town Wholesale Tobacco Ds','GR4',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('10','FMCG Van Ds','GR1',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('10','FMCG Van Ds','GR2',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('10','FMCG Van Ds','GR3',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('10','FMCG Van Ds','GR4',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('11','Shubh Labh Ds','GR1',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('11','Shubh Labh Ds','GR2',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('11','Shubh Labh Ds','GR3',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('12','ISS Ds','GR1',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('12','ISS Ds','GR2',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('12','ISS Ds','GR3',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('12','ISS Ds','GR4',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('13','Chemist/Cosmetic Ds','GR1',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('13','Chemist/Cosmetic Ds','GR2',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('14','Consumption Centre Ds','GR1',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('14','Consumption Centre Ds','GR3',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('15','Key Accounts Ds','GR1',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('15','Key Accounts Ds','GR2',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('15','Key Accounts Ds','GR3',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('15','Key Accounts Ds','GR4',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('16','Convenience Ds CDM','GR1',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('16','Convenience Ds CDM','GR2',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('16','Convenience Ds CDM','GR3',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('16','Convenience Ds CDM','GR4',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('17','Convenience Ds Non-CDM','GR1',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('17','Convenience Ds Non-CDM','GR2',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('17','Convenience Ds Non-CDM','GR3',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('17','Convenience Ds Non-CDM','GR4',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('18','Village Convenience Ds','GR1',0)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('18','Village Convenience Ds','GR2',0)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('18','Village Convenience Ds','GR3',0)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('18','Village Convenience Ds','GR4',0)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('19','HoReCa Ds','GR1',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('19','HoReCa Ds','GR2',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('19','HoReCa Ds','GR3',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('19','HoReCa Ds','GR4',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('20','Pilot Sales Representative','GR1',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('20','Pilot Sales Representative','GR2',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('20','Pilot Sales Representative','GR3',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('20','Pilot Sales Representative','GR4',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('21','Choupal Ds','GR1',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('21','Choupal Ds','GR2',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('21','Choupal Ds','GR3',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('21','Choupal Ds','GR4',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('22','Grocery 1 Ds including Snacks','GR1',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('22','Grocery 1 Ds including Snacks','GR3',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('23','Rural Moped Ds','GR1',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('23','Rural Moped Ds','GR2',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('23','Rural Moped Ds','GR3',1)
	Insert into #tmpDSTypeCGMapping (DS_TYPE_CODE, DS_TYPE_DESC, CG_CODE, ACTIVE) Values ('23','Rural Moped Ds','GR4',1)

	/*Insert the DSType which not exists in DSType_Master*/
	If Exists(Select DS_TYPE_DESC From #tmpDSTypeCGMapping Where DS_TYPE_DESC Not in (Select DSTypeValue From DSType_Master Where DSTypeName ='DSTYpe'))
	Begin
	  Insert into DSType_Master(DSTypeCode, DSTypeValue,DSTypeName, DSTypeCtlPos)
	  Select Distinct DS_TYPE_CODE, DS_TYPE_DESC, 'DSType' as DSTypeName, 1 as DSTypeCtlPos  From #tmpDSTypeCGMapping Where DS_TYPE_DESC Not in (Select DSTypeValue From DSType_Master Where DSTypeName ='DSTYpe')
	End

	/*To Compare Existing and New settings and Update or Insert the values w.r.t new settings*/
	Declare @DSTypeID Int, @GroupID Int, @Active Int
	Declare @ValType nVarchar(50)
	Declare @DSTypeValue nVarchar(100), @DSTypeCode nVarchar(100)
	Declare @GroupName nVarchar(100)
	Declare Cur_UpdateCG Cursor For
	Select Min(ValType) ValType, DSTypeCode,DSTypeValue, GroupName, Active, DSTypeID, CatGroupID
	From
	(
	Select 'NewValue' ValType, tmpDSCGMap.DS_TYPE_CODE as DSTypeCode, tmpDSCGMap.DS_TYPE_DESC as DSTypeValue, tmpDSCGMap.CG_CODE as GroupName, tmpDSCGMap.ACTIVE, DSM.DSTypeID as DSTypeID, PCGAbs.GroupID as CatGroupID
	From DSType_Master DSM, tbl_mERP_DSTypeCGMapping DSCGMap, ProductCategoryGroupAbstract PCGAbs, #tmpDSTypeCGMapping tmpDSCGMap
	Where DSM.DsTypeID = DSCGMap.DSTypeID
	  And PCGAbs.GroupID = DSCGMap.GroupID
	  And PCGAbs.GroupName = tmpDSCGMap.CG_CODE
	  And DSM.DSTypeValue = tmpDSCGMap.DS_TYPE_DESC
	  And DSCGMap.Active = tmpDSCGMap.Active
	Union ALL
	Select 'ExistingValue' ValType, DSM.DSTypeCode,DSM.DSTypeValue, PCGAbs.GroupName, DSCGMap.Active, DSM.DSTypeID as DSTypeID, PCGAbs.GroupID as CatGroupID
	From DSType_Master DSM, tbl_mERP_DSTypeCGMapping DSCGMap, ProductCategoryGroupAbstract PCGAbs
	Where DSM.DsTypeID = DSCGMap.DSTypeID
	  And PCGAbs.GroupID = DSCGMap.GroupID
	)tmp
	Group By DSTypeCode,DSTypeValue, GroupName, Active, DSTypeID, CatGroupID
	Having Count(*) = 1 
	Open Cur_UpdateCG
	Fetch Next From Cur_UpdateCG Into @ValType, @DSTypeCode, @DSTypeValue, @GroupName, @Active, @DSTypeID, @GroupID
	While @@Fetch_status = 0 
	Begin
		/*To Set the Active Flag 0 Mapping exists in tbl_mERP_DSTypeCGMapping*/
		If @ValType = 'ExistingValue' 
			Update DSCGMap
			Set DSCGMap.Active = tmpDSCGMap.Active, ModifiedDate = GetDate()
			From DSType_Master DSM, tbl_mERP_DSTypeCGMapping DSCGMap, ProductCategoryGroupAbstract PCGAbs, #tmpDSTypeCGMapping tmpDSCGMap
			Where DSM.DsTypeID = DSCGMap.DSTypeID
			And PCGAbs.GroupID = DSCGMap.GroupID
			And PCGAbs.GroupName = tmpDSCGMap.CG_CODE
			And DSM.DSTypeValue = tmpDSCGMap.DS_TYPE_DESC
			And DSM.DSTypeValue = @DSTypeValue
			And PCGAbs.GroupName = @GroupName
		Else If @ValType = 'NewValue' 
		Begin
		   If Exists(Select * from tbl_mERP_DSTypeCGMapping Where DSTypeId = @DSTypeID And GroupID = @GroupID)
		   Begin
			 Update tbl_mERP_DSTypeCGMapping Set Active = @Active, ModifiedDate = GetDate() Where DSTypeId = @DSTypeID and GroupID = @GroupID
		   End
		   Else
		   Begin
			 Insert into tbl_mERP_DSTypeCGMapping(DSTypeId,GroupID,Active,CreationDate)
			 Values (@DSTypeID, @GroupID, @Active, Getdate())
		   End 
		End
		Fetch Next From Cur_UpdateCG Into @ValType, @DSTypeCode, @DSTypeValue, @GroupName, @Active, @DSTypeID, @GroupID
	End
	Close Cur_UpdateCG
	Deallocate Cur_UpdateCG

	Drop table #tmpDSTypeCGMapping
End
