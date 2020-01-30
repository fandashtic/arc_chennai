Create Procedure mERP_SP_ProcessAsset
AS
BEGIN
	SET Dateformat DMY
	BEGIN Tran
	Create Table #tmpRecDoc(RecDocID int)

	/* Records to be processed */
	Insert into #tmpRecDoc(RecDocID)
	Select RecdDocID from RecdDoc_Asset where isnull(status,0)=0

	
	Declare @ErrorMsg as nvarchar(400)	
	Declare @ID int
	Declare @RecDocId int
	Declare @AssetDocID int
	Declare @CustomerID nVarchar(20)
	Declare @AssetNumber nVarchar(50)
	Declare @AssetTypeID int
	Declare @AssetType nVarchar(100)
	Declare @AssetStatus int
	Declare @Reason nVarchar(100)
	Declare @ExistAssetTypeID int
	Declare @Active int	
	Declare @AssetID int
	Declare @Source  nVarchar(20)
	Declare @UptAssetStatus nVarchar(20)
	Declare @DownloadedDate	DateTime

	Set @Source = 'Central'

	Declare AllDocs cursor For Select RecDocID from #tmpRecDoc
	Open AllDocs
	Fetch from AllDocs into @RecDocId
	While @@fetch_status=0
	BEGIN		
		Declare AssetRecd Cursor for Select AssetReceivedID,RecdDocID,CustomerID,AssetNumber,AssetTypeID,AssetType,AssetStatus,Reason From AssetDetailReceived
		where IsNull(Status, 0) = 0 And RecdDocId = @RecDocId 
		Open AssetRecd
		Fetch from AssetRecd into @ID,@AssetDocID,@CustomerID,@AssetNumber,@AssetTypeID,@AssetType,@AssetStatus,@Reason
		While @@fetch_status=0
		BEGIN
			
			IF @AssetStatus = 1
				Set @UptAssetStatus = 'New'
			Else IF @AssetStatus = 2
				Set @UptAssetStatus = 'Verified'
			Else IF @AssetStatus = 3
				Set @UptAssetStatus = 'Rejected'

--			-- To check whether Asset Type is empty
--			IF @UptAssetStatus <> 'Rejected'
--			Begin
--				IF @AssetType = '' or @AssetType is Null
--				Begin
--					Set @ErrorMsg = ''
--					Set @ErrorMsg = 'Asset Type should not be empty for ' + @UptAssetStatus + ' Status'
--					
--					Exec mERP_sp_Update_AssetErrorStatus @RecDocId, @ErrorMsg
--					Update R Set Status = 2, ModifiedDate = GetDate() From AssetDetailReceived R
--					Where R.AssetReceivedID = @ID And IsNull(Status, 0) = 0					
--					GOTO NextDoc	
--				End
--			End

			-- To check whether Asset type Exist in Asset type Master, if AssetType is not null		
			IF @AssetType <> ''	
			Begin				
				IF Not Exists(Select 'x' From AssetMaster Where AssetType = @AssetType)
				Begin
					Set @ErrorMsg = ''
					Set @ErrorMsg = 'Asset Type not available in Asset Master'
					
					Exec mERP_sp_Update_AssetErrorStatus @RecDocId, @ErrorMsg
					Update R Set Status = 2, ModifiedDate = GetDate() From AssetDetailReceived R
					Where R.AssetReceivedID = @ID And IsNull(Status, 0) = 0					
					GOTO NextDoc	
				End
			End			

			/* Validating CustomerID */
			If not exists (Select 'x' From Customer Where CustomerID = @CustomerID)
			BEGIN
				Set @ErrorMsg = ''
				Set @ErrorMsg = 'Invalid CustomerID ['+cast(@CustomerID as nVarchar(20))+ ']'
				Exec mERP_sp_Update_AssetErrorStatus @RecDocId, @ErrorMsg
				Update R Set Status = 2, ModifiedDate = getdate() From AssetDetailReceived R
				Where R.AssetReceivedID = @ID And IsNull(Status, 0) = 0
				GOTO NextDoc	
			END
			If exists (Select 'x' From Customer Where CustomerID =@CustomerID and IsNull(Active, 0) = 0)
			BEGIN
				Set @ErrorMsg = ''
				Set @ErrorMsg = 'Warning: Customer ('+cast(@CustomerID as nVarchar(20))+ ') is not active but Asset will be processed'
				Exec mERP_sp_Update_AssetErrorStatus @RecDocId, @ErrorMsg
			END

--			-- Validating whether CustomerID and Asset Number already exist
--			IF Not Exists (Select 'x' From AssetAbstract Where CustomerID = @CustomerID and AssetNumber = @AssetNumber)
--			BEGIN
--				Set @ErrorMsg = ''
--				Set @ErrorMsg = 'Asset Informaton not exists for CustomerID ['+cast(@CustomerID as nVarchar(20))+ '] and Asset Number ['+cast(@AssetNumber as nVarchar(50))+ ']'
--				Exec mERP_sp_Update_AssetErrorStatus @RecDocId, @ErrorMsg
--				Update R Set Status = 2, ModifiedDate = getdate() From AssetDetailReceived R
--				Where R.AssetReceivedID = @ID And IsNull(Status, 0) = 0
--				GOTO NextDoc	
--			END

			IF Not (@AssetStatus = 1 or @AssetStatus = 2 or @AssetStatus = 3)
			BEGIN
				Set @ErrorMsg = ''
				Set @ErrorMsg = 'Invalid Asset Status'
				Exec mERP_sp_Update_AssetErrorStatus @RecDocId, @ErrorMsg
				Update R Set Status = 2, ModifiedDate = getdate() From AssetDetailReceived R
				Where R.AssetReceivedID = @ID And IsNull(Status, 0) = 0
				GOTO NextDoc	
			END
			

			Set @ExistAssetTypeID = NULL
			/* Processing the valid data */	
			Select @ExistAssetTypeID = IsNull(AssetTypeID, 0) From AssetMaster Where AssetType = @AssetType Group By AssetTypeID			

			IF Exists (Select 'x' From AssetAbstract Where CustomerID = @CustomerID and AssetNumber = @AssetNumber)
			Begin

				IF @AssetStatus = 1 or @AssetStatus = 2
				Begin
					Update AssetAbstract Set AssetTypeID = @ExistAssetTypeID, AssetType = @AssetType, ModifiedDate = GetDate()
						Where CustomerID = @CustomerID and AssetNumber = @AssetNumber			
					
				End
				Else IF @AssetStatus = 3
				Begin
					Update AssetAbstract Set AssetTypeID = @ExistAssetTypeID, AssetType = @AssetType, AssetStatus =  @UptAssetStatus, ModifiedDate = GetDate()
						Where CustomerID = @CustomerID and AssetNumber = @AssetNumber
		
				End
			End
			Else
			Begin
				Insert Into AssetAbstract(CustomerID, AssetNumber, AssetTypeID, AssetType, AssetStatus)
								Values (@CustomerID, @AssetNumber, @ExistAssetTypeID, @AssetType, @UptAssetStatus)	
			End

			Select @AssetID = AssetID From AssetAbstract Where CustomerID = @CustomerID and AssetNumber = @AssetNumber			

			Insert Into AssetDetail(AssetID, AssetType, Source, Reason, AssetStatus, DownloadedDate)
			Values(@AssetID, @AssetType, @Source, @Reason, @UptAssetStatus, GetDate())

			-- Updating Received status
			Update AssetDetailReceived Set Status = 1 Where AssetReceivedID = @ID

NextDoc:
			Fetch Next From AssetRecd into @ID,@AssetDocID,@CustomerID,@AssetNumber,@AssetTypeID,@AssetType,@AssetStatus,@Reason
		END
		Close AssetRecd
		Deallocate AssetRecd
		Update RecdDoc_Asset Set Status = 1 Where RecdDocID = @RecDocId
		Fetch Next from AllDocs into @RecDocId
	END
	Close AllDocs
	Deallocate AllDocs

	Drop Table #tmpRecDoc
	Commit Tran
END
