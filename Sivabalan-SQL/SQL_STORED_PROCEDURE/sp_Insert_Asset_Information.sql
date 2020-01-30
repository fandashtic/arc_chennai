CREATE Procedure sp_Insert_Asset_Information(@AssetHeaderID int, @CustomerID nVarchar(20), @SalesmanID int,
					@AssetNumber nVarchar(50), @AssetType nVarchar(100), @AssetStatus nVarchar(20),
					@Source nVarchar(20), @Reason nVarchar(100), @DownloadedDate DateTime)
As  
Declare @AssetTypeID int
Declare @AssetID int
Declare @UpdateDownloadDate DateTime
Declare @CreationDate DateTime

Select @AssetTypeID = IsNull(AssetTypeID, 0) From AssetMaster Where AssetType = @AssetType Group By AssetTypeID

Select @UpdateDownloadDate = DownloadedDate, @CreationDate = CreationDate From AssetInfoTracking_HH Where AssetHeaderID = @AssetHeaderID 

If Not Exists(Select AssetID From AssetAbstract Where CustomerID = @CustomerID and AssetNumber = @AssetNumber)
Begin

	Insert Into AssetAbstract(AssetHeaderID, CustomerID, AssetNumber, AssetStatus)
			Values (@AssetHeaderID, @CustomerID, @AssetNumber, @AssetStatus)
End
Else
Begin
	Update AssetAbstract Set AssetStatus = @AssetStatus, ModifiedDate = GetDate()
	Where CustomerID = @CustomerID and AssetNumber = @AssetNumber
End

Select @AssetID = Max(AssetID) From AssetAbstract Where CustomerID = @CustomerID and AssetNumber = @AssetNumber

Insert Into AssetDetail(AssetID, DSID, AssetType, Source, Reason, AssetStatus, DownloadedDate, CreationDate)
	Values(@AssetID, @SalesmanID, @AssetType, @Source, @Reason, @AssetStatus, @UpdateDownloadDate, @CreationDate)

Select @AssetID
  
