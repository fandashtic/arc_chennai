Create Procedure Sp_Recd_CLOCRNOTECount
As
Begin
	select Count(*) NoOFCLOCRNOTE From RecdDoc_CLOCrNote Where Isnull(Status,0) = 1
	Update RecdDoc_CLOCrNote Set Status = 32 Where Isnull(Status,0) = 1
End
