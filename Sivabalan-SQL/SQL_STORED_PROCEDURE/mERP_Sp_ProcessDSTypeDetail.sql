Create Procedure mERP_Sp_ProcessDSTypeDetail (@ID int)
AS
Begin
	Declare @DSTypeCode nVarchar(15)
	Declare @DSTypeDesc nVarchar(255)
	Declare @CGCode nVarchar(255)
	Declare @Active int
	Declare @SlNo int

	Declare @Errmessage nVarchar(4000)
	Declare @ErrStatus int
	Declare @DSTypeDescID int
	Declare @CAtGrpID int
	Declare @tblDshandle Table ( SalesmanId Int) 

	Declare @SCatGrp nVarchar(15)
	Declare @KeyValue nVarchar(255)
	Declare @ReportFlag as int
	Set @ErrStatus = 0

	Declare @Flag as int

-- Error Log Written and Status Updation of Rejected Detail:

	Declare DSCursor Cursor for 
	Select DSType_Code,DSType_Desc,CG_Code,Active,ReportFlag,ID From tbl_mERP_RecdDSTypeCGDetail
	where RecdID = @ID and IsNull(Status,0) = 0
	Open DSCursor
	Fetch From DSCursor  Into @DSTypeCode, @DSTypeDesc, @CGCode, @Active, @ReportFlag, @SlNo
	While @@Fetch_Status = 0  
	Begin 
		Set @ErrStatus = 0
		If (Isnull(@DSTypeCode,'') = '') 
		Begin
			Set @Errmessage = 'DSCode should not be Null'
			Set @ErrStatus = 1
			Goto last
		End
		If (Isnull(@DSTypeDesc,'') = '') 
		Begin
			Set @Errmessage = 'DSType Description should not be Null'
			Set @ErrStatus = 1
			Goto last
		End
		If (Isnull(@CGCode,'') = '') 
		Begin
			Set @Errmessage = 'Categroy Group Code should not be Null'
			Set @ErrStatus = 1
			Goto last
		End
		If (IsNull(@Active, 0) > 1)
		Begin
			Set @Errmessage = 'Active Column Value should be 0 or 1'
			Set @ErrStatus = 1
			Goto last
		End
		If (IsNull(@ReportFlag, 0) > 1)
		Begin
			Set @Errmessage = 'Report Flag Value should be 0 or 1'
			Set @ErrStatus = 1
			Goto last
		End
		If (Len(@DSTypeCode) > 25)
		Begin
			Set @Errmessage = 'Code should be lesser than or Equal to  15 characters'
			Set @ErrStatus = 1
			Goto last
		End 
		If (Len(@CGCode) > 25)
		Begin
			Set @Errmessage = 'Category Code should be lesser than or Equal to  15  characters'
			Set @ErrStatus = 1
			Goto last
		End 
		If ( Select Count(*) from ProductCategoryGroupAbstract where Groupname = @CGCode) = 0
		Begin
			Set @Errmessage = 'Category Group Doesnot exists in master table'
			Set @ErrStatus = 1
			Goto last
		End

	Last:
		If (@ErrStatus = 1)
		Begin
			Set @KeyValue = ''
			Set @Errmessage = 'DSTypeCG:- ' +  ' ' + Convert(nVarchar(4000), @Errmessage) 
			Set @KeyValue = Convert(nVarchar, @ID) + '|' + Convert(nVarchar,@SlNo)
			Update tbl_mERP_RecdDSTypeCGDetail Set Status = 2  Where ID = @SlNo  and RecdID = @ID
			Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)    
			Values('MastersConfig', @Errmessage,  @KeyValue, getdate())  
		End
		Fetch Next From DSCursor  Into @DSTypeCode, @DSTypeDesc, @CGCode, @Active, @ReportFlag, @SlNo
	End
	Close DSCursor
	DeAllocate DSCursor

-- DSType Master Process:

	Declare @TmpDSType as Table (ID int,DSTypeCode nVarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,DSTypeDesc nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,CGCode nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,Active int,ReportFlag Int,DSTypeID Int,GroupId Int, Flag int)

	Insert Into @TmpDSType
	Select ID,DSType_Code,DSType_Desc,CG_Code,Isnull(Active,0),Isnull(ReportFlag,0),0,0,Flag from tbl_mERP_RecdDSTypeCGDetail
	where RecdID = @ID and IsNull(Status,0) = 0

	Declare Cur_DSType Cursor for 
	Select DSTypeCode,DSTypeDesc,ReportFlag,Flag from @TmpDSType
	Open Cur_DSType
	Fetch From Cur_DSType Into @DSTypeCode,@DSTypeDesc,@ReportFlag,@Flag
	While @@Fetch_Status = 0  
	Begin 
		IF Exists(select 'X' From DSType_Master Where DSTypeValue = @DSTypeDesc)
		Begin
			Update DSType_Master Set ModifiedDate = Getdate(),DSTypeCode=@DSTypeCode,ReportFlag=@ReportFlag,Flag = @Flag Where DSTypeValue = @DSTypeDesc
			Update tbl_mERP_DSTypeCGMapping Set Active = 0 Where DSTypeID in (select DSTypeID from DSType_Master Where DSTypeValue = @DSTypeDesc)
		
			Delete From DSTypeCGCategoryMap Where DSTypeID in (Select DSTypeID From DSType_Master Where DSTypeValue = @DSTypeDesc)
		End

		Else IF Not Exists(select 'X' From DSType_Master Where DSTypeValue = @DSTypeDesc)
		Begin
			INSERT INTO DSType_Master(DSTypeName,DSTypeValue,DSTypeCtlPos,Active,DSTypeCode,ReportFlag,CreationDate,Flag)							
			Select 'DSType',@DSTypeDesc,1,1,@DSTypeCode,@ReportFlag,Getdate(),@Flag
			Update tbl_mERP_DSTypeCGMapping Set Active = 0 Where DSTypeID in (select DSTypeID from DSType_Master Where DSTypeValue = @DSTypeDesc)

			Delete From DSTypeCGCategoryMap Where DSTypeID in (Select DSTypeID From DSType_Master Where DSTypeValue = @DSTypeDesc)
		End
		Fetch Next From Cur_DSType  Into @DSTypeCode,@DSTypeDesc,@ReportFlag,@Flag
	End
	Close Cur_DSType
	DeAllocate Cur_DSType

	Update T set T.DSTypeID = DSM.DSTypeID From @TmpDSType T, DSType_Master DSM
	Where Isnull(DSM.Active,0) = 1
	And T.DSTypeDesc = DSM.DSTypeValue

	Update T set T.GroupId = PCG.GroupId From @TmpDSType T, ProductCategoryGroupAbstract PCG
	Where Isnull(PCG.Active,0) = 1
	And T.CGCode = PCG.GroupName

	Delete From @TmpDSType Where  Isnull(DSTypeID,0) = 0
	Delete From @TmpDSType Where  Isnull(GroupId,0) = 0

	Update tbl_mERP_DSTypeCGMapping Set Active = 0 Where DSTypeID In (Select Distinct DSTypeID From @TmpDSType)
	
		Declare @DSTypeID as Nvarchar(15)
		Declare @GroupID as Nvarchar(15)
		Declare @MapActive as Int
		Declare @Cur_DSTypeMap Cursor 
		Set @Cur_DSTypeMap = Cursor for
		Select Distinct DSTypeID,GroupId,Active from @TmpDSType 
		Open @Cur_DSTypeMap
		Fetch Next from @Cur_DSTypeMap into @DSTypeID,@GroupID,@MapActive
		While @@fetch_status =0
			Begin
				If Not Exists(select 'X' From tbl_mERP_DSTypeCGMapping where DSTypeID = @DSTypeID And GroupId = @GroupId)
					Begin
						INSERT INTO tbl_mERP_DSTypeCGMapping(DSTypeID,GroupID,Active,CreationDate)
						select Distinct @DSTypeID,@GroupId,1,Getdate()
					End
				Else If Exists(select 'X' From tbl_mERP_DSTypeCGMapping where DSTypeID = @DSTypeID And GroupId = @GroupId)
					Begin
						Update tbl_mERP_DSTypeCGMapping Set Active = @MapActive, ModifiedDate =Getdate() Where DSTypeID = @DSTypeID And GroupId = @GroupId
					End
--For DC Purpose:
				If (Select Count(*) from tbl_mERP_DSTypeCGMapping Where DStypeId = @DSTypeID and GroupID = @GroupID And Active = 1) > 1
				Begin
					Update tbl_mERP_DSTypeCGMapping Set Active = 0 Where Id Not in (
					Select Top 1 ID from tbl_mERP_DSTypeCGMapping Where DStypeId = @DSTypeID and GroupID = @GroupID And Active = 1)
					And DStypeId = @DSTypeID and GroupID = @GroupID And Active = 1
				End

				Fetch Next from @Cur_DSTypeMap into @DSTypeID,@GroupID,@MapActive
			End
		Close @Cur_DSTypeMap
		Deallocate @Cur_DSTypeMap

	Update tbl_mERP_RecdDSTypeCGAbstract Set Status = 1 Where ID = @ID
	Update tbl_mERP_RecdDSTypeCGDetail Set Status = 1  Where ID in(select Distinct Id From @TmpDSType) and RecdID = @ID
	Update tbl_mERP_RecdDSTypeCGDetail Set Status = 2  Where Status <> 1 and RecdID = @ID

-- Modify Dshandle table for all salesman who are linked to the particular DstypeId ( @DstypeId)

	Declare @@tblDshandle As table (SalesmanId Int,DSTypeID Int,GroupID Int)
	Insert Into @@tblDshandle
	Select distinct DS.SalesmanId,DS.DSTypeID,M.GroupID from DStype_Details DS, tbl_mERP_DSTypeCGMapping M
	Where DS.DSTypeID = M.DSTypeID And M.Active = 1

	Delete From Dshandle Where Salesmanid in (Select Distinct Salesmanid From @@tblDshandle)
	Insert Into Dshandle
	Select Distinct SalesmanId,GroupID,1 From @@tblDshandle

End
