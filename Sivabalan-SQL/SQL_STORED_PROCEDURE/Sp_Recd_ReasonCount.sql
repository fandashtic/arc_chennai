Create Procedure Sp_Recd_ReasonCount
As
Begin
	select Count(*) NoOfReason From RecdReasonAbstract Where Isnull(Status,0) = 1
	Update RecdReasonAbstract Set Status = 32 Where Isnull(Status,0) = 1
End
