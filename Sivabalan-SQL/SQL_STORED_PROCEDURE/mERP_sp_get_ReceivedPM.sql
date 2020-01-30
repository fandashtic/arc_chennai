Create Procedure mERP_sp_get_ReceivedPM
As
Begin
	Select REC_PMID From tbl_mERP_Recd_PMMaster Where IsNull(Status,0) = 0
End
