Create Procedure sp_MarginInsertByFSU
AS
Begin

IF Not Exists(Select FycpStatus From Setup Where isnull(FycpStatus,0)=0)
	Goto PTRLast

If Not Exists(Select 'x' From sysobjects Where Name Like 'MarginInsertByFSU' And xType = 'U')
	Goto Last

If (select Flag from tbl_mERP_ConfigAbstract Where ScreenCode = 'MarginInsertByFSU' and ScreenName ='MarginInsertByFSU') = 0
	Goto Last

Declare @InsMarginID Int
Declare @Code nVarChar(255) 
Declare @Level Int
Declare @NewLevel Int
Declare @GenMargin Decimal(18,6)
Declare @SWDUnRegMargin Decimal(18,6)
Declare @SWDRegMargin Decimal(18,6)
Declare @marginAbsID Int
Declare @MarDetID Int
Declare @SWDChannelMapID Int
Declare @EffDate DateTime
Select @EffDate = LastInventoryUpload + 1 From Setup 

Set @marginAbsID = 0
If Exists (Select 'x' From MarginInsertByFSU Where Status = 0 )
Begin
	Insert Into tbl_mERP_MarginAbstract(DocumentDate,ReceiveDocID,EditMargin) Values(GETDATE(),0,101)
	Set @marginAbsID =  @@identity
End

Declare InsMargin Cursor For Select InsMarginID, Code, Level  ,GenMargin, SWDUnRegMargin, SWDRegMargin, SWDChannelMapID From MarginInsertByFSU Where Status = 0 
Open InsMargin
Fetch From InsMargin Into @InsMarginID, @Code, @Level, @GenMargin, @SWDUnRegMargin, @SWDRegMargin, @SWDChannelMapID
While @@FETCH_STATUS = 0
Begin
	--If @Level = 0
	--Begin
	--	If Exists (Select 'x' From ItemCategories Where Category_Name = @Code)
	--		Begin
	--			Select @Code = Convert(nVarChar,CategoryID) From ItemCategories Where Category_Name = @Code
	--			Set @Level  = 4
	--		End
	--	Else
	--		Set @Level  = 5			
	--End
	--Else If @Level = -1
	--Begin
	--	If Exists (Select 'x' From ItemCategories Where Category_Name = @Code)
	--		Begin
	--			Select @Code = Convert(nVarChar,CategoryID) From ItemCategories Where Category_Name = @Code
	--			Set @Level  = 3
	--		End
	--	Else
	--		Set @Level  = 5			
	--End
	--Else If @Level = -2
	--Begin
	--	If Exists (Select 'x' From ItemCategories Where Category_Name = @Code)
	--		Begin
	--			Select @Code = Convert(nVarChar,CategoryID) From ItemCategories Where Category_Name = @Code
	--			Set @Level  = 2
	--		End
	--	Else
	--		Set @Level  = 5
	--End
	--Else
	--	If Exists (Select 'x' From ItemCategories Where Category_Name = @Code)
	--		Begin				
	--			If @Level <> 5
	--				Select @Code = Convert(nVarChar,CategoryID) From ItemCategories Where Category_Name = @Code
	--		End	
	
	If @Level Not In (2, 3 , 4, 5)
	Begin
		Update MarginInsertByFSU Set Status = 32 Where InsMarginID = @InsMarginID 
	End
	Else
	Begin			
	  If (@Level <> 5 And Exists (Select 'x' From ItemCategories Where Category_Name = @Code)) Or (@Level = 5 And Exists (Select 'x' From Items Where Product_Code = @Code))		
	  Begin	
		
		If @Level <> 5
			Select @Code = Convert(nVarChar,CategoryID) From ItemCategories Where Category_Name = @Code
					
		Set @MarDetID = 0
		
		Insert Into tbl_mERP_MarginDetail(MarginID, Code, Level, Percentage, EffectiveDate)
		Values (@marginAbsID, @Code , @Level, @GenMargin , @EffDate)

		Set @MarDetID = 	@@IDENTITY
		
		Insert Into tbl_mERP_ChannelMarginDetail(RecdChannelID,MarginID, MarginDetID, ChannelTypeCode, RegFlag, CatCode, CatLevel ,MarginPerc)
		Select Distinct 0,@marginAbsID,@MarDetID,Channel_Type_Code,1,@Code , @Level ,@SWDUnRegMargin From tbl_mERP_OLClass 
		Where Channel_Type_Desc  In (Select ChannelName From SWDChannelMap Where SWDChannelMapID = @SWDChannelMapID)

		Insert Into tbl_mERP_ChannelMarginDetail(RecdChannelID,MarginID, MarginDetID, ChannelTypeCode, RegFlag, CatCode, CatLevel ,MarginPerc)
		Select Distinct 0,@marginAbsID,@MarDetID,Channel_Type_Code,2,@Code , @Level ,@SWDRegMargin From tbl_mERP_OLClass 
		Where Channel_Type_Desc  In (Select ChannelName From SWDChannelMap Where SWDChannelMapID = @SWDChannelMapID)
		
		Update MarginInsertByFSU Set Status = 1 Where InsMarginID = @InsMarginID 
	  End
	  Else
	  Begin
	  	Update MarginInsertByFSU Set Status = 64 Where InsMarginID = @InsMarginID 
	  End
	End
	
	Fetch Next From InsMargin Into @InsMarginID, @Code, @Level, @GenMargin, @SWDUnRegMargin, @SWDRegMargin, @SWDChannelMapID
End
Close InsMargin
DeAllocate InsMargin
Last:
 Update tbl_mERP_ConfigAbstract Set Flag = 0 Where ScreenCode = 'MarginInsertByFSU' and ScreenName ='MarginInsertByFSU'

If Not Exists(Select 'x' From sysobjects Where Name Like 'BPChannelPTRByFSU' And xType = 'U')
	Goto PTRLast

If (select Flag from tbl_mERP_ConfigAbstract Where ScreenCode = 'BPChannelPTRByFSU' and ScreenName ='BPChannelPTRByFSU') = 0
	Goto PTRLast

IF OBJECT_ID('tempdb..#tmpExistBatch') IS NOT NULL
		Drop Table #tmpExistBatch

Select Distinct Batch_Code Into #tmpExistBatch From BatchWiseChannelPTR

Declare @ID Int
Declare @ItemCode nVarChar(255)
Declare @SWDUnRegPTR  Decimal(18,6)
Declare @SWDRegPTR Decimal(18,6)

Declare BPChannelPTRUpdate Cursor For Select ID,Item_Code, SWDUnRegPTR, SWDRegPTR, SWDChannelMapID From BPChannelPTRByFSU Where Status = 0 
Open BPChannelPTRUpdate
Fetch From BPChannelPTRUpdate Into @ID, @ItemCode, @SWDUnRegPTR, @SWDRegPTR, @SWDChannelMapID
While @@FETCH_STATUS = 0
Begin

	Insert Into BatchWiseChannelPTR (Batch_Code, ChannelMarginID, ChannelTypeCode, RegisterStatus, ChannelPTR)
	Select BP.Batch_Code, 0, CH.Channel_Type_Code,1, @SWDUnRegPTR From Batch_Products BP, 
	(Select Distinct Channel_Type_Code From tbl_mERP_OLClass Where Channel_Type_Desc  In (Select ChannelName From SWDChannelMap Where SWDChannelMapID = @SWDChannelMapID)) CH
	Where BP.Product_Code = @ItemCode  And IsNull(BP.Free,0) = 0 And ISNULL(BP.Damage,0) = 0 
	And BP.Batch_Code Not in (Select Distinct Batch_Code  From #tmpExistBatch)
	
	Insert Into BatchWiseChannelPTR (Batch_Code, ChannelMarginID, ChannelTypeCode, RegisterStatus, ChannelPTR)
	Select BP.Batch_Code, 0, CH.Channel_Type_Code,2, @SWDRegPTR From Batch_Products BP, 
	(Select Distinct Channel_Type_Code From tbl_mERP_OLClass Where Channel_Type_Desc  In (Select ChannelName From SWDChannelMap Where SWDChannelMapID = @SWDChannelMapID)) CH
	Where BP.Product_Code = @ItemCode  And IsNull(BP.Free,0) = 0 And ISNULL(BP.Damage,0) = 0 
	And BP.Batch_Code Not in (Select Distinct Batch_Code  From #tmpExistBatch)
	
	Update BPChannelPTRByFSU Set Status = 1 Where ID = @ID 
	
	Fetch Next From BPChannelPTRUpdate Into @ID, @ItemCode, @SWDUnRegPTR, @SWDRegPTR, @SWDChannelMapID
End
Close BPChannelPTRUpdate
DeAllocate BPChannelPTRUpdate

  Update tbl_mERP_ConfigAbstract Set Flag = 0 Where ScreenCode = 'BPChannelPTRByFSU' and ScreenName ='BPChannelPTRByFSU'

	IF OBJECT_ID('tempdb..#tmpExistBatch') IS NOT NULL
			Drop Table #tmpExistBatch

PTRLast:  

End
