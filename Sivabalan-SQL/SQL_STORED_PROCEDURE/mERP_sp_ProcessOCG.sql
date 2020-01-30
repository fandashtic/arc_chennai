Create Procedure mERP_sp_ProcessOCG(@REC_OCGID Int)
As
Begin

	Declare @OCGFlag as Int
	Declare @DSTypeAvailable as Int
	Declare @OCGAvailable as Int
	Declare @ProductAvailable as Int
	Declare @OCGDStypeMapAvailable as Int
	Declare @ErrorStatus as Int
	Declare @ErrorMessage as Nvarchar(500)
	Declare @OCGDSTypeCatMapAvailable as int

	Declare @Flag int

	If Exists (	select 'X' from Recd_DSType Where Isnull(RecdID ,0) = @REC_OCGID)
		Begin
			Set @DSTypeAvailable = 1
		End
	If Exists (	select 'X' from Recd_OCGName Where Isnull(RecdID ,0) = @REC_OCGID)
		Begin
			Set @OCGAvailable = 1
		End
	If Exists (	select 'X' from Recd_OCG_Product Where Isnull(RecdID ,0) = @REC_OCGID)
		Begin
			Set @ProductAvailable = 1
		End
	If Exists (	select 'X' from Recd_OCG_DSType Where Isnull(RecdID ,0) = @REC_OCGID)
		Begin
			Set @OCGDStypeMapAvailable = 1
		End
	If Exists (	select 'X' from Recd_OCG_DSTypeCategoryMap Where Isnull(RecdID ,0) = @REC_OCGID)
		Begin
			Set @OCGDSTypeCatMapAvailable = 1
		End

	Set @OCGFlag = (select Top 1 Isnull(Flag,0) Flag from tbl_merp_Configabstract where screenCode = 'OCGDS')

-- ********************************************************************************************************************************************
-- DSType Process:
	If Isnull(@DSTypeAvailable,0) = 1 
		Begin
		
			--Validate DSType Data:
			If (Select Count(*) From Recd_DSType Where  RecdID = @REC_OCGID and Isnull(DSType,'') = '') > 0
				Begin
					Set @ErrorStatus =1
					Set @ErrorMessage = 'Unable To Process Blank DSType'
					Update Recd_DSType Set status = 2 Where RecdID = @REC_OCGID and Isnull(DSType,'') = ''
					Exec mERP_sp_Update_OCGErrorStatus @REC_OCGID,@ErrorMessage
				End

			If Exists(Select 'X' From Recd_DSType Where Isnull(RecdID ,0) = @REC_OCGID And Isnull(Status,0) = 0)
				Begin
					Declare @DSType as Nvarchar(50)
					Declare @DSTypeActive as Int
					Declare @DSTypeCode as Nvarchar(15)
					Declare @ReportFlag as int
					Declare @Cur_DSType Cursor 
					Set @Cur_DSType = Cursor for
					Select DSType,Active,DSTypeCode,ReportFlag,Flag From Recd_DSType Where Isnull(RecdID ,0) = @REC_OCGID And Isnull(Status,0) = 0
					Open @Cur_DSType
					Fetch Next from @Cur_DSType into @DSType,@DSTypeActive,@DSTypeCode,@ReportFlag,@Flag
					While @@fetch_status =0
						Begin							
							 IF Exists(select 'X' From DSType_Master Where DSTypeValue = @DSType)
								Begin
									IF @OCGFlag = 1
									Begin
										Update DSType_Master Set Active = @DSTypeActive,ModifiedDate = Getdate(),OCGType = 1,DSTypeCode=@DSTypeCode,ReportFlag=@ReportFlag,Flag = @Flag Where DSTypeValue = @DSType
										Delete From OCG_DSTypeCategoryMap Where DSTypeID in(Select DSTypeID From DSType_Master Where DSTypeValue = @DSType)
									End
									Else
									Begin
										Update DSType_Master Set Active = @DSTypeActive,ModifiedDate = Getdate(),DSTypeCode=@DSTypeCode,ReportFlag=@ReportFlag,Flag = @Flag Where DSTypeValue = @DSType
										Delete From OCG_DSTypeCategoryMap Where DSTypeID in(Select DSTypeID From DSType_Master Where DSTypeValue = @DSType)
									End
									Goto NextDSType
								End

							Else IF Not Exists(select 'X' From DSType_Master Where DSTypeValue = @DSType)
								Begin
									INSERT INTO DSType_Master(DSTypeName,DSTypeValue,DSTypeCtlPos,Active,DSTypeCode,ReportFlag,OCGType,CreationDate,Flag)							
									Select 'DSType',@DSType,1,@DSTypeActive,@DSTypeCode,@ReportFlag,1,Getdate(),@Flag

									Delete From OCG_DSTypeCategoryMap Where DSTypeID in(Select DSTypeID From DSType_Master Where DSTypeValue = @DSType)
									Goto NextDSType
								End
NextDSType:
						Fetch Next from @Cur_DSType into @DSType,@DSTypeActive,@DSTypeCode,@ReportFlag,@Flag
						End
					Close @Cur_DSType
					Deallocate @Cur_DSType	

					Update Recd_DSType Set status = 1 Where RecdID = @REC_OCGID And Isnull(Status,0) = 0		
				End
			Else
				Begin
					Update Recd_DSType Set status = 2 Where RecdID = @REC_OCGID And Isnull(Status,0) = 0
				End
		End
-- ********************************************************************************************************************************************
-- OCG Process:
	If Isnull(@OCGAvailable,0) = 1 
		Begin
		
			--Validate DSType Data:
			If (Select Count(*) From Recd_OCGName Where  RecdID = @REC_OCGID and Isnull(OCGName,'') = '') > 0
				Begin
					Set @ErrorStatus =1
					Set @ErrorMessage = 'Unable To Process Blank OCGName'
					Update Recd_OCGName Set status = 2 Where RecdID = @REC_OCGID
					Exec mERP_sp_Update_OCGErrorStatus @REC_OCGID,@ErrorMessage
				End
			If Exists(Select 'X' From Recd_OCGName Where Isnull(RecdID ,0) = @REC_OCGID And Isnull(Status,0) = 0)
				Begin
					Declare @OCGName as Nvarchar(50)
					Declare @OCGNameActive as Int
					Declare @OCGCode as Nvarchar(15)
					Declare @GroupCode as Int					
					Declare @Cur_OCGName Cursor 
					Set @Cur_OCGName = Cursor for
					Select OCGCode,OCGName,Active From Recd_OCGName Where Isnull(RecdID ,0) = @REC_OCGID And Isnull(Status,0) = 0
					Open @Cur_OCGName
					Fetch Next from @Cur_OCGName into @OCGCode,@OCGName,@OCGNameActive
					While @@fetch_status =0
						Begin

							 IF Exists(select 'X' From ProductCategoryGroupAbstract Where GroupName = @OCGCode)
								Begin
									Update ProductCategoryGroupAbstract Set Active = @OCGNameActive,ModifiedDate = Getdate(),OCGDescription = @OCGName,OCGType = @OCGFlag Where GroupName = @OCGCode
									Goto NextOCGName
								End

							Else IF Not Exists(select 'X' From ProductCategoryGroupAbstract Where GroupName = @OCGCode)
								Begin
									Set @GroupCode = (select Max(cast(GroupCode as Int)) + 1 From ProductCategoryGroupAbstract)
									INSERT INTO ProductCategoryGroupAbstract(GroupName,CreationDate,Active,GroupCode,OCGType,OCGDescription)
									Select @OCGCode,Getdate(),@OCGNameActive,@GroupCode,1,@OCGName
									Goto NextOCGName
								End
NextOCGName:
						Fetch Next from @Cur_OCGName into @OCGCode,@OCGName,@OCGNameActive
						End
					Close @Cur_OCGName
					Deallocate @Cur_OCGName	

					Update Recd_OCGName Set status = 1 Where RecdID = @REC_OCGID And Isnull(Status,0) = 0
				End
		Else
			Begin
				Update Recd_OCGName Set status = 2 Where RecdID = @REC_OCGID And Isnull(Status,0) = 0
			End		
		End
-- ********************************************************************************************************************************************
-- Product Process:
	If Isnull(@ProductAvailable,0) = 1 
		Begin
			--Validate Product Data:
			Exec mERP_sp_ProcessOCGProduct @REC_OCGID
		End
-- ********************************************************************************************************************************************
-- DSType And CategoryGroup Mapping Process:
If Isnull(@OCGDStypeMapAvailable,0) = 1
	Begin
		Create Table #tmpcgmap (
		DSTypeCode Nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,
		DSTypeID Int,
		GroupCode Nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,
		GroupID Int,
		Active Int)

		Insert Into #tmpcgmap (DSTypeCode,GroupCode,Active)
		Select Distinct DSTypeCode,OCGCode,Active From Recd_OCG_DSType Where RecdID = @REC_OCGID  And Isnull(Status,0) = 0
		
		Update T set T.DSTypeID = DSM.DSTypeID From #tmpcgmap T, DSType_Master DSM
		Where Isnull(DSM.OCGType,0) = 1 
		And Isnull(DSM.Active,0) = 1
		And T.DSTypeCode = DSM.DSTypeCode

		Update T set T.GroupId = PCG.GroupId From #tmpcgmap T, ProductCategoryGroupAbstract PCG
		Where Isnull(PCG.OCGType,0) = 1 
		And Isnull(PCG.Active,0) = 1
		And T.GroupCode = PCG.GroupName
		
		Declare @zDSTypeCode as Nvarchar(15)
		If Exists(Select 'X' From #tmpcgmap Where  Isnull(DSTypeID,0) = 0)
		Begin
			Declare Cur_DSType Cursor for
			Select Distinct DSTypeCode From #tmpcgmap Where  Isnull(DSTypeID,0) = 0
			Open Cur_DSType
			Fetch from Cur_DSType into @zDSTypeCode
			While @@fetch_status =0
				Begin
					If Not Exists(select * From DSType_Master Where DSTypeCode = @zDSTypeCode And Active = 1)
					Begin
						Set @ErrorStatus =1
						Set @ErrorMessage = 'DSTypeCode Not Found / Not Active in DSType_Master DSTypeCode : ['+ @zDSTypeCode +']'
						Exec mERP_sp_Update_OCGErrorStatus @REC_OCGID,@ErrorMessage
						Update Recd_OCG_DSType set Status = 2 Where DSTypeCode = @zDSTypeCode And RecdID = @REC_OCGID  And Isnull(Status,0) = 0
					End
					Fetch Next from Cur_DSType into @zDSTypeCode
				End
			Close Cur_DSType
			Deallocate Cur_DSType
		End

		Declare @zGroupID as Nvarchar(15)
		If Exists(Select 'X' From #tmpcgmap Where  Isnull(GroupID,0) = 0)
		Begin
			Declare Cur_DSType Cursor for
			Select Distinct GroupCode From #tmpcgmap Where  Isnull(GroupID,0) = 0
			Open Cur_DSType
			Fetch from Cur_DSType into @zGroupID
			While @@fetch_status =0
				Begin
					If Not Exists(select * From ProductCategoryGroupAbstract Where GroupName = @zGroupID And Active = 1)
					Begin
						Set @ErrorStatus =1
						Set @ErrorMessage = 'GroupCode / OCGCode Not Found or Not Active in ProductCategoryGroupAbstract GroupCode / OCGCode : ['+ @zGroupID +']'
						Exec mERP_sp_Update_OCGErrorStatus @REC_OCGID,@ErrorMessage
						Update Recd_OCG_DSType set Status = 2 Where OCGCode = @zGroupID And RecdID = @REC_OCGID  And Isnull(Status,0) = 0
					End
					Fetch Next from Cur_DSType into @zGroupID
				End
			Close Cur_DSType
			Deallocate Cur_DSType
		End

		Delete From #tmpcgmap Where  Isnull(DSTypeID,0) = 0
		Delete From #tmpcgmap Where  Isnull(GroupId,0) = 0
		Update tbl_mERP_DSTypeCGMapping Set Active = 0 Where DSTypeID In (Select Distinct DSTypeID From #tmpcgmap)
		
			Declare @DSTypeID as Nvarchar(15)
			Declare @GroupID as Nvarchar(15)
			Declare @MapActive as Int
			Declare @Cur_DSTypeMap Cursor 
			Set @Cur_DSTypeMap = Cursor for
			Select Distinct DSTypeID,GroupId,Active from #tmpcgmap 
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
					Fetch Next from @Cur_DSTypeMap into @DSTypeID,@GroupID,@MapActive
				End
			Close @Cur_DSTypeMap
			Deallocate @Cur_DSTypeMap

		Update Recd_OCG_DSType set Status = 1 Where RecdID = @REC_OCGID  And Isnull(Status,0) = 0
		Drop Table #tmpcgmap
	End
-- ********************************************************************************************************************************************

	-- OCG DSType Category Mapping
	IF isnull(@OCGDSTypeCatMapAvailable,0) = 1
	Begin

--		Delete From OCG_DSTypeCategoryMap Where DSTypeCode in
--			(Select Distinct DSTypeCode From Recd_OCG_DSTypeCategoryMap Where RecdID = @REC_OCGID and IsNull(Status,0) = 0)
--
--		Insert Into OCG_DSTypeCategoryMap(RecdDocID, DSTypeCode, CG_Name, Level, PortFolio)
--		Select @REC_OCGID, DSTypeCode, CG_Name, Level, PortFolio From Recd_OCG_DSTypeCategoryMap Where RecdID = @REC_OCGID and IsNull(Status,0) = 0
--		
--		Update Recd_OCG_DSTypeCategoryMap Set Status = 1  Where RecdID = @REC_OCGID
	
		Exec mERP_sp_ProcessOCGDSTypeMap @REC_OCGID
		
	End

OUT:
	--Update Processed Status		
			Update Recd_OCG Set status = 1 Where ID = @REC_OCGID

Exec Sp_RefereshOCGItemMaster

End
