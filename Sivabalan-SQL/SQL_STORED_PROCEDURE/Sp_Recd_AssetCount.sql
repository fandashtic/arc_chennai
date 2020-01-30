Create Procedure Sp_Recd_AssetCount
As
Begin
	Select Count(*) NoOFAssetCnt From RecdDoc_Asset Where Isnull(Status, 0) = 1
	Update RecdDoc_Asset Set Status = 32 Where Isnull(Status,0) = 1
End
