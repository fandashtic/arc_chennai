CREATE Procedure mERP_sp_GetDsTypeCatGroup(@DSTypeCode nVarChar(50))
As
Begin
	If (Select isnull(Flag,0) From Tbl_merp_Configabstract Where ScreenCode = 'OCGDS' and ScreenName ='OperationalCategoryGroup')=0
		Select GroupName from ProductCategoryGroupAbstract  
		where GroupID In (Select GroupID from tbl_mERP_DSTypeCGMapping Where DSTypeID = @DSTypeCode And Active = 1)  

	else
		Select GroupName from ProductCategoryGroupAbstract  
		where GroupID In (Select GroupID from tbl_mERP_DSTypeCGMapping Where DSTypeID = @DSTypeCode And Active = 1)  
		And OCGType=1
		And Active=1
End
