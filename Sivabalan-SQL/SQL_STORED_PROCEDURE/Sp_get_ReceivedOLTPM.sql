Create Procedure Sp_get_ReceivedOLTPM
As
Begin
	Select ID From RecdDoc_PMOLT Where IsNull(Status,0) = 0
End
