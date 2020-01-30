Create Procedure Sp_Recd_OCGCount
As
Begin
	select Count(*) NoOFOCG From Recd_OCG Where Isnull(Status,0) = 1
	Update Recd_OCG Set Status = 32 Where Isnull(Status,0) = 1
End
