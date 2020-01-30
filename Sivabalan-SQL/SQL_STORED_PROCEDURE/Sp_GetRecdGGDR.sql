Create Procedure Sp_GetRecdGGDR
As
Begin
	Select ID From Recd_GGDR Where IsNull(Status,0) = 0 Order By ID Asc
End
