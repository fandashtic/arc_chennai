Create Procedure mERP_SP_ProcessLaunchItems
AS

BEGIN

	/* Get the received Records from Portal*/

	SET Dateformat DMY
	Create Table #tmpRecDoc(RecDocID int)

	/* Records to be processed */
	Insert into #tmpRecDoc(RecDocID)
	Select ID from RecdDoc_LaunchItems where isnull(status,0)=0

	Declare @ErrorMsg as nvarchar(400)	
	Declare @ID int
	Declare @RecDocId int
	Declare @LaunchDocID int
	Declare @ItemCode nvarchar(15)
	Declare @OutletCode nvarchar(15)
	Declare @LaunchQuantity Decimal(18,6)
	Declare @UOM nvarchar(10)
	Declare @LaunchStartDate DateTime
	Declare @LaunchEndDate DateTime
	Declare @Sequence Int
	Declare @Active	 Int
	Declare @DownloadedDate	DateTime

	Declare AllDocs cursor For Select RecDocID from #tmpRecDoc
	Open AllDocs
	Fetch from AllDocs into @RecDocId
	While @@fetch_status=0
	BEGIN		
		Declare LaunchRecd Cursor for Select ID,RecdDocID,ItemCode,OutletCode,LaunchQuantity,UOM,LaunchStartDate,LaunchEndDate,Sequence,Active From Recd_LaunchItems
		where IsNull(Status, 0) = 0 And RecdDocId = @RecDocId 
		Open LaunchRecd
		Fetch from LaunchRecd into @ID,@LaunchDocID,@ItemCode,@OutletCode,@LaunchQuantity,@UOM,@LaunchStartDate,@LaunchEndDate,@Sequence,@Active	
		While @@fetch_status=0
		BEGIN
			-- To check whether OutletCode exists in the Forum Masters
			IF Not Exists (select 'x'from Customer where customerID = @OutletCode)
			BEGIN
				Set @ErrorMsg = ''
				Set @ErrorMsg = 'Customer ID : ' + @OutletCode + ' is not exists in Forum Customer Master'

				Exec mERP_sp_Update_LaunchErrorStatus @RecDocId, @ErrorMsg
				Update R Set Status = 2, ModifiedDate = GetDate() From Recd_LaunchItems R
				Where R.ID = @ID And IsNull(Status, 0) = 0					
				GOTO NextDoc	
			End			

			-- To check duplicate records
			IF Exists (select 'x'from LaunchItems where ItemCode = @ItemCode And OutletCode = @OutletCode And LaunchQuantity = @LaunchQuantity and UOM=@UOM And LaunchStartDate=@LaunchStartDate 
			And LaunchEndDate = @LaunchEndDate And Sequence = @Sequence And Active=@Active)
			BEGIN
				Set @ErrorMsg = ''
				Set @ErrorMsg = 'Record already exists and received data is rejected '

				Exec mERP_sp_Update_LaunchErrorStatus @RecDocId, @ErrorMsg
				Update R Set Status = 2, ModifiedDate = GetDate() From Recd_LaunchItems R
				Where R.ID = @ID And IsNull(Status, 0) = 0					
				GOTO NextDoc	
			End		

			-- To Update the Active Status of Launch Items
			IF Exists (select 'x'from LaunchItems where ItemCode = @ItemCode And OutletCode = @OutletCode and LaunchStartDate=@LaunchStartDate 
			And LaunchEndDate = @LaunchEndDate)
			BEGIN
				Update LaunchItems Set Active = @Active, Sequence = @Sequence, UOM=@UOM, ModifiedDate=getdate(), LaunchQuantity = @LaunchQuantity 
				where ItemCode = @ItemCode And OutletCode = @OutletCode and LaunchStartDate=@LaunchStartDate And LaunchEndDate = @LaunchEndDate
			END
			ELSE
			BEGIN
				/* Insert new record in LaunchItems table */
				insert into LaunchItems(RecdDocID,ItemCode,OutletCode,LaunchQuantity,UOM,LaunchStartDate,LaunchEndDate,Sequence,Active)
				Select @LaunchDocID,@ItemCode,@OutletCode,@LaunchQuantity,@UOM,@LaunchStartDate,@LaunchEndDate,@Sequence,@Active	
			END
			Update Recd_LaunchItems Set Status = 1 Where ID = @ID						
			NextDoc:
			Fetch Next from LaunchRecd into @ID,@LaunchDocID,@ItemCode,@OutletCode,@LaunchQuantity,@UOM,@LaunchStartDate,@LaunchEndDate,@Sequence,@Active	
		END
		Close LaunchRecd
		Deallocate LaunchRecd
		Update RecdDoc_LaunchItems Set Status = 1 Where ID = @RecDocId
		Fetch Next from AllDocs into @RecDocId
	END
	Close AllDocs
	Deallocate AllDocs
	Drop Table #tmpRecDoc
END
