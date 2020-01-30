Create Procedure Sp_get_ReceivedPMOutletAchieve
As
Begin
	Select ID From RecdDoc_PMOutletAchieve Where IsNull(Status,0) = 0
End
