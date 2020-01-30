Create Procedure Sp_Recd_PMOLTCount
As
Begin
	select Count(*) NoOFPMOLT From RecdDoc_PMOLT Where Isnull(Status,0) = 1
	Update RecdDoc_PMOLT Set Status = 32 Where Isnull(Status,0) = 1
End
