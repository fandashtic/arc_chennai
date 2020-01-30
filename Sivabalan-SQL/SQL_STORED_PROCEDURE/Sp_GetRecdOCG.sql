Create Procedure Sp_GetRecdOCG
As
Begin
	Select ID From Recd_OCG Where IsNull(Status,0) = 0 Order By ID Asc
End
