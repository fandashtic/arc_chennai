Create Procedure mERP_SP_GetRecdTLTypelist
AS
Begin
	Select ID from tbl_mERP_RecdTLTypeAbstract where IsNull(Status,0) = 0
End
