Create Procedure Sp_CreateAssetFromHandheld @SalesmanID int,@LogID int = 0
AS
BEGIN
	BEGIN TRY

	Declare @AssetHeaderID int
	Declare @CustomerID nvarchar(30)
	Declare @AssetNumber nvarchar(100)
	Declare @AssetType nvarchar(200)
	Declare @AssetStatus nvarchar(200)
	Declare @Source nvarchar(100)
	Declare @Reason nvarchar(200)
	Declare @DownloadedDate Datetime
	Declare @WarningMessage nvarchar(500)
	Declare @Error nvarchar(500)

	Select AssetHeaderID, "CustomerID" = IsNull(CustomerID, ''), "DSID" = IsNull(DSID, 0), "AssetNumber" = IsNull(AssetNumber, ''), 
			"AssetType" = IsNull(AssetType, ''), "AssetStatus" = IsNull(AssetStatus, ''), "Source" = IsNull(Source, ''), 
			"Reason" = IsNull(Reason, ''), DownloadedDate
	Into #tmpAsset From AssetInfoTracking_HH
	Where IsNull(Status, 0) = 0 and DSID = @SalesmanID
	
	Alter Table #tmpAsset Add Rejected Int

	Declare Asset Cursor For Select AssetHeaderID, CustomerID, AssetNumber, AssetType, AssetStatus, Source, Reason, DownloadedDate From #tmpAsset		 
	Open Asset
	Fetch From Asset Into @AssetHeaderID, @CustomerID, @AssetNumber, @AssetType, @AssetStatus, @Source, @Reason, @DownloadedDate
	While @@FETCH_STATUS = 0
	BEGIN	
		
		Declare @ExistAssetType nVarchar(100)
		Declare @ExistCustomerID nVarchar(20)
		Declare @Active int
		
		Set @ExistAssetType = ''
		Set @ExistCustomerID = ''
		Set @Active = 1

		Set @WarningMessage = ''
		Set @Error = ''

		-- To check whether data is empty or not
		IF isnull(@CustomerID, '') = ''
		Begin		
			Set @Error= 'CustomerID is empty.'
			BEGIN TRAN
			Exec sp_Han_Update_Processed_AssetHeader @AssetHeaderID, 2				
			Update #tmpAsset Set Rejected=1 where AssetHeaderID=@AssetHeaderID
			exec sp_han_InsertErrorlog @AssetHeaderID,4,'Information','Aborted',@Error,@SalesmanID
			COMMIT TRAN
			Goto NextAsset			
		End
		Else if isnull(@AssetNumber,'') = ''
		Begin			
			Set @Error= 'Asset Number is empty.'
			BEGIN TRAN
			Exec sp_Han_Update_Processed_AssetHeader @AssetHeaderID, 2				
			Update #tmpAsset Set Rejected=1 where AssetHeaderID=@AssetHeaderID
			exec sp_han_InsertErrorlog @AssetHeaderID,4,'Information','Aborted',@Error,@SalesmanID
			COMMIT TRAN
			Goto NextAsset			
		End
--		Else if @SalesmanID <= 0
--		Begin
--			Set @ErrorMsg = 'SalesmanID is empty.'
--			Goto Out
--		End

		Else if isnull(@AssetStatus,'') = ''
		Begin			
			Set @Error= 'Asset Status is empty.'
			BEGIN TRAN
			Exec sp_Han_Update_Processed_AssetHeader @AssetHeaderID, 2					
			Update #tmpAsset Set Rejected=1 where AssetHeaderID=@AssetHeaderID
			exec sp_han_InsertErrorlog @AssetHeaderID,4,'Information','Aborted',@Error,@SalesmanID
			COMMIT TRAN
			Goto NextAsset			
		End
		Else if isnull(@Source,'') = ''
		Begin			
			Set @Error= 'Source is empty.'
			BEGIN TRAN
			Exec sp_Han_Update_Processed_AssetHeader @AssetHeaderID, 2					
			Update #tmpAsset Set Rejected=1 where AssetHeaderID=@AssetHeaderID
			exec sp_han_InsertErrorlog @AssetHeaderID,4,'Information','Aborted',@Error,@SalesmanID
			COMMIT TRAN
			Goto NextAsset			
		End

		-- To check whether CustomerID Exist in Customer Master
		Select @ExistCustomerID = IsNull(CustomerID, ''), @Active = IsNull(Active, 0) From Customer Where CustomerID = @CustomerID
		If isnull(@ExistCustomerID,'') = ''
		Begin			
			Set @Error= 'Invalid CustomerID [' + @CustomerID + '].'
			BEGIN TRAN
			Exec sp_Han_Update_Processed_AssetHeader @AssetHeaderID, 2					
			Update #tmpAsset Set Rejected=1 where AssetHeaderID=@AssetHeaderID
			exec sp_han_InsertErrorlog @AssetHeaderID,4,'Information','Aborted',@Error,@SalesmanID
			COMMIT TRAN
			Goto NextAsset			
		End

		-- To check whether Salesman Exist in Salesman Master
		If Not Exists(Select SalesmanID From Salesman Where SalesmanID = @SalesmanID)
		Begin			
			Set @Error= 'Invalid SalesmanID [' + Cast(@SalesmanID as nVarchar(20)) + '] for CustomerID [' + @CustomerID + '] and Asset Number [' + @AssetNumber + '].'
			BEGIN TRAN
			Exec sp_Han_Update_Processed_AssetHeader @AssetHeaderID, 2					
			Update #tmpAsset Set Rejected=1 where AssetHeaderID=@AssetHeaderID
			exec sp_han_InsertErrorlog @AssetHeaderID,4,'Information','Aborted',@Error,@SalesmanID
			COMMIT TRAN
			Goto NextAsset			
		End

		-- To check whether SalesmanID is mapped to CustomerID
		If Not Exists(Select SalesmanID From Beat_Salesman Where CustomerID = @CustomerID and SalesmanID = @SalesmanID)
		Begin			
			Set @Error= 'SalesmanID [' + Cast(@SalesmanID as nVarchar(20)) + '] is not mapped to CustomerID [' + @CustomerID + '] .'
			BEGIN TRAN
			Exec sp_Han_Update_Processed_AssetHeader @AssetHeaderID, 2					
			Update #tmpAsset Set Rejected=1 where AssetHeaderID=@AssetHeaderID
			exec sp_han_InsertErrorlog @AssetHeaderID,4,'Information','Aborted',@Error,@SalesmanID
			COMMIT TRAN
			Goto NextAsset			
		End

		-- To Validate Asset Status
		If Not (@AssetStatus = 'New' or @AssetStatus = 'Verified' or @AssetStatus = 'Rejected')
		Begin			
			Set @Error= 'Invalid Asset Status [' + @AssetStatus + '] for CustomerID [' + @CustomerID + '] and Asset Number [' + @AssetNumber + '].'
			BEGIN TRAN
			Exec sp_Han_Update_Processed_AssetHeader @AssetHeaderID, 2					
			Update #tmpAsset Set Rejected=1 where AssetHeaderID=@AssetHeaderID
			exec sp_han_InsertErrorlog @AssetHeaderID,4,'Information','Aborted',@Error,@SalesmanID
			COMMIT TRAN
			Goto NextAsset			
		End

		-- To Validate Source
		If Not (@Source = 'HH')
		Begin			
			Set @Error= 'Invalid Source [' + @Source + '] for CustomerID [' + @CustomerID + '] and Asset Number [' + @AssetNumber + '].'
			BEGIN TRAN
			Exec sp_Han_Update_Processed_AssetHeader @AssetHeaderID, 2					
			Update #tmpAsset Set Rejected=1 where AssetHeaderID=@AssetHeaderID
			exec sp_han_InsertErrorlog @AssetHeaderID,4,'Information','Aborted',@Error,@SalesmanID
			COMMIT TRAN
			Goto NextAsset			
		End

		--To check existing CustomerID is Active or Not
		If isnull(@ExistCustomerID,'') <> '' and @Active = 0
		Begin			
			Set @Error= 'Asset processed but CustomerID [' + @CustomerID + '] is inactive.'
			Set @WarningMessage = @Error
		End

		Begin Tran		
		Exec sp_Insert_Asset_Information @AssetHeaderID, @CustomerID, @SalesmanID, @AssetNumber, @AssetType, @AssetStatus, @Source, @Reason, @DownloadedDate

		Declare @ColStatus int
		Create Table #UpdateAsset(ColStatus int)
		insert into #UpdateAsset(ColStatus)
		Exec sp_Han_Update_Processed_AssetHeader @AssetHeaderID, 1
		Select Top 1 @ColStatus=ColStatus from #UpdateAsset
		Drop Table #UpdateAsset
				
		If @ColStatus <> 1
		BEGIN
			Set @Error='- Unable to save Asset Information.'
			exec sp_han_InsertErrorlog @AssetHeaderID,4,'Information','Aborted',@Error,@SalesmanID
			Exec sp_Han_Update_Processed_AssetHeader @AssetHeaderID, 2						
			GOTO NextAsset								
		END		

		IF isnull(@WarningMessage,'') <> ''
		BEGIN
			Exec sp_han_InsertErrorlog @AssetHeaderID,4,'Information','Processed',@WarningMessage,@SalesmanID
		END		

		Commit Tran

		NextAsset:		
		Fetch From Asset Into @AssetHeaderID, @CustomerID, @AssetNumber, @AssetType, @AssetStatus, @Source, @Reason, @DownloadedDate
	END
	Close Asset
	Deallocate Asset
	
	Drop Table #tmpAsset
	END TRY
	BEGIN CATCH
		Declare @ErrorNo nvarchar(2000)
		Set @ErrorNo=@@Error
		If @@TRANCOUNT >0
		BEGIN
			ROLLBACK TRAN
		END
		--Deadlock Error
		If @ErrorNo='1205'
			Exec sp_han_InsertErrorlog @AssetHeaderID,4,'Information','Aborted','Deadlocked... Application will retry to process',@SalesmanID
		If @ErrorNo<>'1205'
		BEGIN
			Declare @err nvarchar(4000)
			Set @err='Error Executing the procedure: '+cast(@ErrorNo as nvarchar(2000))		
			Update AssetInfoTracking_HH Set Status=2 Where AssetHeaderID=@AssetHeaderID
			Exec sp_han_InsertErrorlog @AssetHeaderID,4,'Information','Aborted',@err,@SalesmanID
		END
	END CATCH	

END
