Create Procedure mERP_sp_UpdateChannelMargin_Category(@UserName nVarchar(50),
		@OldMargin Decimal(18,6),@NewMargin Decimal(18,6),
		@OldEffectDate Datetime,@NewEffectDate Datetime,@DocumentDate Datetime,@OldMarginID Int,@CatName nvarchar(30),
		@OldChannelID int, @ChannelCode nvarchar(15), @RegFlag int, @OldProdMargin Decimal(18,6))
As
Begin
	Set DateFormat DMY
	
	Declare @MarginAbsID Int
	Declare @CatID int
	Declare @LastTransactionDate Datetime
	Declare @Level int
	Select @Level=Level From ItemCategories Where Category_Name=@CatName
	Select @CatID = CategoryID From ItemCategories Where Category_Name=@CatName

	Declare @MarginDetID Int
	Declare @ChannelDetID int

	Select @LastTransactionDate = dbo.StripTimeFromDate(TransactionDate) From Setup
	--Select @LockID =ID from EditMarginLock where categoryName=@CatName
	If Exists (Select MarginID From tbl_mERP_MarginAbstract Where ReceiveDocID = 0 And EditMargin = 1 And MarginID =
	(Select MarginID From tbl_mERP_MarginDetail Where ID = @OldMarginID and level <>5))
	Begin
		If @OldEffectDate > @LastTransactionDate
		Begin
			/*Update the record only if the OldEffectiveDate is greater than the LastTransactionDate*/
			Update tbl_mERP_MarginDetail Set EffectiveDate = @NewEffectDate
			Where [ID] = @OldMarginID 

			/* Insert Channel Detail Record */			
			IF isnull(@OldChannelID,0) > 0
				Update tbl_mERP_ChannelMarginDetail Set MarginPerc = @NewMargin
				Where MarginDetID = @OldMarginID  and ID = @OldChannelID  -- and ChannelTypeCode = @ChannelCode and RegFlag = @RegFlag
			Else		

				IF Exists (Select MarginID From tbl_mERP_MarginAbstract Where ReceiveDocID = 0 And EditMargin = 1 And MarginID =
							(Select MarginID From tbl_mERP_MarginDetail Where ID = @OldMarginID and [Level]=5))

				Insert Into tbl_mERP_ChannelMarginDetail(RecdChannelID, MarginID,  MarginDetID, ChannelTypeCode, RegFlag, 
						CatCode, CatLevel, MarginPerc)
				Select 0, @MarginAbsID, @OldMarginID, @ChannelCode, @RegFlag, cast(@CatID as nvarchar), @Level, @NewMargin
				Set @ChannelDetID = @@identity

		End
		Else
		Begin
			/* Begin: Process Abstract table Insert */
			Insert Into tbl_mERP_MarginAbstract(DocumentDate, ReceiveDocID,EditMargin)
			Values(@DocumentDate,0,1)
			Set @MarginAbsID =  @@identity
			-- end: Process Abstract table Insert

			/* Insert Detail Record */
			Insert Into tbl_mERP_MarginDetail(MarginID,  Level, Percentage, EffectiveDate, Code)
			Select @marginAbsID, @Level, @OldProdMargin, @NewEffectDate, cast(@CatID as nvarchar)
			Set @MarginDetID =  @@identity			

			/* Insert Channel Detail Record */
			Insert Into tbl_mERP_ChannelMarginDetail(RecdChannelID, MarginID,  MarginDetID, ChannelTypeCode, RegFlag, 
					CatCode, CatLevel, MarginPerc)
			Select 0, @MarginAbsID,  @MarginDetID, ChannelTypeCode, RegFlag, CatCode, CatLevel, MarginPerc 
			From tbl_mERP_ChannelMarginDetail Where MarginDetID = @OldMarginID and ID Not in(isnull(@OldChannelID,0))

			Insert Into tbl_mERP_ChannelMarginDetail(RecdChannelID, MarginID,  MarginDetID, ChannelTypeCode, RegFlag, 
					CatCode, CatLevel, MarginPerc)
			Select 0, @MarginAbsID, @MarginDetID, @ChannelCode, @RegFlag, cast(@CatID as nvarchar), @Level, @NewMargin
			Set @ChannelDetID = @@identity
		End
	End
	Else
	Begin
		/* Begin: Process Abstract table Insert */
		Insert Into tbl_mERP_MarginAbstract(DocumentDate, ReceiveDocID,EditMargin)
		Values(@DocumentDate,0,1)
		Set @MarginAbsID =  @@identity
		-- end: Process Abstract table Insert

		/* Insert Detail Record */
		Insert Into tbl_mERP_MarginDetail(MarginID,  Level, Percentage, EffectiveDate, Code)
		Select @marginAbsID, @Level, @OldProdMargin,@NewEffectDate, cast (@CatID as nvarchar)
		Set @MarginDetID =  @@identity

		/* Insert Channel Detail Record */
		Insert Into tbl_mERP_ChannelMarginDetail(RecdChannelID, MarginID,  MarginDetID, ChannelTypeCode, RegFlag, 
				CatCode, CatLevel, MarginPerc)
		Select 0, @MarginAbsID,  @MarginDetID, ChannelTypeCode, RegFlag, CatCode, CatLevel, MarginPerc 
		From tbl_mERP_ChannelMarginDetail Where MarginDetID = @OldMarginID and ID Not in(isnull(@OldChannelID,0))

		Insert Into tbl_mERP_ChannelMarginDetail(RecdChannelID, MarginID,  MarginDetID, ChannelTypeCode, RegFlag, 
				CatCode, CatLevel, MarginPerc)
		Select 0, @MarginAbsID, @MarginDetID, @ChannelCode, @RegFlag, cast(@CatID as nvarchar), @Level, @NewMargin
		Set @ChannelDetID = @@identity
	End

	--Create Product Margin Log
	Insert Into tbl_mERP_ProdMargin_AuditLog(UserName,Product_Code,OldMargin,NewMargin,OldEffectiveDate,NewEffectiveDate,CreationTime)
	Values (@UserName,@CatID,@OldProdMargin,@OldProdMargin,@OldEffectDate,@NewEffectDate,@DocumentDate)

	--Create Channel Margin Log
	Insert Into tbl_mERP_ChannelMargin_AuditLog(OldMarginDetID,NewMarginDetID,OldChannelDetID,NewChannelDetID,UserName,
			CatLevel,Product_Code,ChannelTypeCode,RegFlag,OldMargin,NewMargin,OldEffectiveDate,NewEffectiveDate,CreationTime)
	Values (@OldMarginID, @MarginDetID, @OldChannelID, @ChannelDetID, @UserName, 
			@Level, @CatID,	@ChannelCode, @RegFlag, @OldMargin, @NewMargin, @OldEffectDate, @NewEffectDate, @DocumentDate)
	
	IF @@Error = 0 
		Select 1
	Else
		Select 0	
End
