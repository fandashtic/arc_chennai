Create Procedure Sp_get_ReceivedCLOCRNOTE
As
Begin
	Select ID From RecdDoc_CLOCrNote Where IsNull(Status,0) = 0
End
