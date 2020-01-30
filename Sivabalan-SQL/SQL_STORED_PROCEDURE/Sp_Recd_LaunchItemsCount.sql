Create Procedure Sp_Recd_LaunchItemsCount
As
Begin
	Select Count(*) NoOFCnt From RecdDoc_LaunchItems Where Isnull(Status, 0) = 1
	Update RecdDoc_LaunchItems Set Status = 32 Where Isnull(Status,0) = 1
End
