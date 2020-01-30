Create Procedure sp_mERP_InsertSalesPortal(@SalesPortalIP nvarchar(255))
As
Begin
	If Not exists (select IsNull(SalesPortalIP,'') as SalesPortalIP from tbl_merp_SalesportalIP where SalesportalIP = @SalesPortalIP)
	Begin
		Insert into tbl_merp_SalesPortalIP (SalesportalIP) values(@SalesPortalIP)
	End
	Else
	Begin
		update tbl_merp_SalesPortalIP  set active  = 1 where SalesportalIP = @SalesPortalIP
	End
	if ((select top 1 salesportalip from Setup) <> @SalesPortalIP)
	Begin
		update setup set salesportalip = @SalesPortalIP
	End
End
