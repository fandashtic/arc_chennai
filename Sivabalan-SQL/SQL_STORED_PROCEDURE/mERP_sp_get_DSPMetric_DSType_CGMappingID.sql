Create procedure mERP_sp_get_DSPMetric_DSType_CGMappingID(@CGGroup nVarchar(15), @DSTypeValue nVarchar(100))
As
Begin
	If (Select isnull(Flag,0) From Tbl_merp_Configabstract Where ScreenCode = 'OCGDS' and ScreenName ='OperationalCategoryGroup')=0
	Begin
		Select CGMap.ID from tbl_mERP_DSTypeCGMapping CGMap, DSTYpe_Master DSM, ProductCategoryGroupAbstract CGMas
		Where CGMas.GroupID = CGMap.GroupID
		And CGMap.Active = 1
		And DSM.DSTypeID = CGMap.DSTypeID
		And CGMas.GroupID = CGMap.GroupID
		And CGMas.GroupName in (Select LTRIM(RTRIM(ItemValue)) from dbo.sp_SplitIn2Rows(@CGGroup,'|'))
		AND DSM.DSTypeValue = @DSTypeValue
	End
	Else
	Begin
		Select CGMap.ID from tbl_mERP_DSTypeCGMapping CGMap, DSTYpe_Master DSM, ProductCategoryGroupAbstract CGMas
		Where CGMas.GroupID = CGMap.GroupID
		And CGMap.Active = 1
		And DSM.DSTypeID = CGMap.DSTypeID
		And CGMas.GroupID = CGMap.GroupID
		/* Condition is not required becoz GR1,GR2,GR3 and GR4 CGs are no longer valid*/
		--And CGMas.GroupName in (Select LTRIM(RTRIM(ItemValue)) from dbo.sp_SplitIn2Rows('GR1|GR3','|'))
		--And DSM.DSTypeValue = 'Convenience Ds CDM-1'	
		And CGMas.OCGtype=1	
		And DSM.OCGType=1
	End
End
