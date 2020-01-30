Create Procedure Sp_Recd_StateMasterCount
As
Begin
	select Count(*) NoOfStateMaster From Recd_StateMasterAbs Where Isnull(Status,0) = 1
	Update Recd_StateMasterAbs Set Status = 32 Where Isnull(Status,0) = 1
End
