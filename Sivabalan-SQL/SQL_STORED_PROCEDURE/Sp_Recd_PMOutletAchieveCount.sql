Create Procedure Sp_Recd_PMOutletAchieveCount
As
Begin
	select Count(*) NoOFPMTLC From RecdDoc_PMOutletAchieve Where Isnull(Status,0) = 1
	Update RecdDoc_PMOutletAchieve Set Status = 32 Where Isnull(Status,0) = 1
End
