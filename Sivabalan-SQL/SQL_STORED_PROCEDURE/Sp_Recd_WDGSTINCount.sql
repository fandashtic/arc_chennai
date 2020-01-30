Create Procedure Sp_Recd_WDGSTINCount
As
Begin
	select Count(*) NoOfWDGSTIN From Recd_WDStateCode  Where Isnull(Status,0) = 1
	Update Recd_WDStateCode Set Status = 32 Where Isnull(Status,0) = 1
End
