Create Procedure mERP_sp_GetCGInfo
As
Begin
	Select GroupId, GroupName From ProductCategoryGroupAbstract
End
