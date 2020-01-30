Create Procedure Sp_InsertRecd_AssetTracker(@RecdDocID Int,@CustomerID nvarchar(20),@AssetNumber nvarchar(50),
							@AssetType nvarchar(100),@AssetTypeID int,@AssetStatus int,@Reason nvarchar(100))
As
Begin
	Set DateFormat DMY
	Insert Into AssetDetailReceived(RecdDocID,CustomerID,AssetNumber,AssetTypeID,AssetType,AssetStatus,Reason)
	Select @RecdDocID,@CustomerID,@AssetNumber,@AssetTypeID,@AssetType,@AssetStatus,@Reason
End
