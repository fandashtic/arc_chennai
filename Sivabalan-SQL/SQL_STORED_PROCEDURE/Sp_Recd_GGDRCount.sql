Create Procedure Sp_Recd_GGDRCount
As
Begin
	select Count(*) NoOFGGDR From Recd_GGDR Where Isnull(Status,0) = 1
	Update Recd_GGDR Set Status = 32 Where Isnull(Status,0) = 1
End
