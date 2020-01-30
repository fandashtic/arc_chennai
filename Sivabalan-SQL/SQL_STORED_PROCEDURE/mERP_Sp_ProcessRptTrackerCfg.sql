Create Procedure mERP_Sp_ProcessRptTrackerCfg (@AbsID int)
AS
Begin
	Declare @ReportName nVarchar(50)
	Declare @Active int, @ArchiveCnt int
	Declare @RecdID int
	Declare @ID int
	Declare @RptConfigID int

	Declare @KeyValue nVarchar(255)
	Declare @Errmessage nVarchar(4000)
	Declare @ErrStatus int

	Set @ErrStatus = 0

	Declare RTCCursor Cursor for 
	Select  ID, ReportName, ArchiveCount, Active
	from tbl_merp_RecdRptTrackerConfigDet
	where RecdID = @AbsID 
    Order by 1
	Open RTCCursor 
	Fetch From RTCCursor Into @ID, @ReportName, @ArchiveCnt , @Active
	  While @@Fetch_Status = 0  
	  Begin 

	  Set @ErrStatus = 0

	  If ((Isnull(@ReportName,'') = '') Or (Isnull(@ArchiveCnt,'') = '') Or (Isnull(@Active,'') = ''))
	  Begin
		Set @Errmessage = 'Report Config Name/ArchiveCount/Active should not be Null'
		Set @ErrStatus = 1
		Goto last
	  End

	  If ((isNull(@Active, 0) > 1) Or (IsNull(@Active, 0) < 0))
	  Begin
		Set @Errmessage = 'Active Column Value should be 0 or 1'
		Set @ErrStatus = 1
		Goto last
	  End

	  Set @RptConfigID = 0 
	  Select @RptConfigID = ConfigID from tbl_merp_RptTrackerConfig Where ReportName = IsNull(@ReportName,0)
	  /*Insert Report Config Info*/
	  If IsNull(@RptConfigID,0) = 0 
	  Begin
		Insert Into tbl_merp_RptTrackerConfig(ReportName, ArchiveCount, Active)
		Values (@ReportName, @ArchiveCnt , @Active)
	  End
	  Else
	  Begin
		Update	tbl_merp_RptTrackerConfig Set ArchiveCount = @ArchiveCnt, Active = @Active, ModifiedDate = Getdate() 
		Where ConfigID = @RptConfigID
	  End

Last:
		-- Error Log Written and Status Updation of rejected Detail 
		If (@ErrStatus = 1)
		Begin
			Set @KeyValue = ''
			Set @Errmessage = 'RptProcessConfig:- ' +  ' ' + Convert(nVarchar(4000), @Errmessage)
			Set @KeyValue = Convert(nVarchar, @AbsID) + '|' + Convert(nVarchar,@ID)
			Update tbl_merp_RecdRptTrackerConfigAbs Set Status = 2 Where RecdID = @AbsID
			Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)    
			Values('MastersConfig', @Errmessage,  @KeyValue, getdate())  
		End

	Fetch From RTCCursor Into @ID, @ReportName, @ArchiveCnt , @Active
	End
	Close RTCCursor
	DeAllocate RTCCursor	

	/*Update received status*/
	Update tbl_merp_RecdRptTrackerConfigAbs Set Status = 1 Where RecdID = @AbsID
End
