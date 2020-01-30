Create Procedure mERP_Sp_ProcessTLTypeDetail (@ID int)
AS
Begin
  Declare @TLTypeDesc nVarchar(255)
  Declare @Active int
  Declare @SlNo int
  Declare @Errmessage nVarchar(4000)
  Declare @ErrStatus int
  Declare @TLTypeID int
  Declare @KeyValue nVarchar(255)
  Declare @RptFlag int	
  Set @ErrStatus = 0

  Declare TLCursor Cursor for 
  Select  TLType_Desc, Active, ID, ReportFlag
  from tbl_mERP_RecdTLTypeDetail
  where RecdID = @ID and IsNull(Status,0) = 0
  Open TLCursor
  Fetch From TLCursor  Into @TLTypeDesc, @Active, @SlNo, @RptFlag
  While @@Fetch_Status = 0  
  Begin 

	Set @KeyValue = N''
	Set @ErrStatus = 0

	If (Isnull(@TLTypeDesc,N'') = N'') 
	Begin
		Set @Errmessage = N'TLType Description should not be Null'
		Set @ErrStatus = 1
		Goto last
	End

	If (IsNull(@Active, 0) > 1)
	Begin
		Set @Errmessage = N'Active Column Value should be 0 or 1'
		Set @ErrStatus = 1
		Goto last
	End

	If (IsNull(@RptFlag, 0) > 1)
	Begin
		Set @Errmessage = N'Report Flag Column Value should be 0 or 1'
		Set @ErrStatus = 1
		Goto last
	End
	
	Declare @CreationDate DateTime
	Select @CreationDate = Getdate()
	If ( Select Count(*) from tbl_mERP_SupervisorType Where TypeDesc = @TLTypeDesc) >=1
	Begin
		Set @TLTypeID = 0
		Update tbl_mERP_SupervisorType Set Active = @Active, ReportFlag = @RptFlag , ModifiedDate = @CreationDate Where TypeDesc = @TLTypeDesc
	End
	Else
	Begin
		If ( Select Count(*) from tbl_mERP_SupervisorType Where TypeDesc = @TLTypeDesc) = 0
		Begin
			Insert Into tbl_mERP_SupervisorType(TypeDesc, Active, CreationDate, ReportFlag)
			Values (@TLTypeDesc, @Active, @CreationDate, @RptFlag)
		End
		Else
		Begin
			Set @Errmessage = N'TLType Value Already Exist in Master table'
			Set @ErrStatus = 1
			Goto last
		End
	End

	-- Status Updation
	Update tbl_mERP_RecdTLTypeAbstract Set Status = 1 Where ID = @ID
	Update tbl_mERP_RecdTLTypeDetail Set Status = 1  Where ID = @SlNo  and RecdID = @ID

Last:
	-- Error Log Written and Status Updation of rejected Detail 
	If (@ErrStatus = 1)
	Begin
		Set @KeyValue = N''
		Set @Errmessage = N'TLTypeDesc:- ' +  ' ' + Convert(nVarchar(4000), @Errmessage) 
		Set @KeyValue = Convert(nVarchar, @ID) + N'|' + Convert(nVarchar,@SlNo)
		Update tbl_mERP_RecdTLTypeAbstract Set Status = 2
		Update tbl_mERP_RecdTLTypeDetail Set Status = 2  Where ID = @SlNo  and RecdID = @ID
		Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)    
		Values('MastersConfig', @Errmessage,  @KeyValue, getdate())  
	End

  Fetch Next From TLCursor  Into @TLTypeDesc, @Active, @SlNo, @RptFlag
  End

  Close TLCursor
  DeAllocate TLCursor	
End
