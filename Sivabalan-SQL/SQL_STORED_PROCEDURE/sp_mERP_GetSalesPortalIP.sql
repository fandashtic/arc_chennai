Create Procedure sp_mERP_GetSalesPortalIP
As
Begin
	Select IsNull(SalesPortalIP,'') as SalesPortalIP from tbl_merp_SalesPortalIP where Active = 1
End
