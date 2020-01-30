Create Procedure mERP_sp_UpdateProductMargin(@UserName nVarchar(50),
@ItemCode nVarchar(50),@OldMargin Decimal(18,6),@NewMargin Decimal(18,6),
@OldEffectDate Datetime,@NewEffectDate Datetime,@DocumentDate Datetime,@OldMarginID Int)
As
Begin
	Set DateFormat DMY
	Declare @marginAbsID Int
	Declare @MarginDetID Int
	Declare @LastTransactionDate Datetime
	Select @LastTransactionDate = dbo.StripTimeFromDate(TransactionDate) From Setup

	If Exists (Select MarginID From tbl_mERP_MarginAbstract Where ReceiveDocID = 0 And EditMargin = 1 And MarginID =
	(Select MarginID From tbl_mERP_MarginDetail Where ID = @OldMarginID and [level]=5))
	Begin
		IF @OldEffectDate > @LastTransactionDate
		Begin
			/*Any open User record will be cancelled*/
			/*As per ITC request, Revoke date should not be updated  while editing
			Margin from Edit MArgin Screen. So we are commenting below update statement*/
			/*
			Update TDet Set TDet.RevokeDate = TDet.EffectiveDate, [level]=5
			From tbl_mERP_MarginAbstract TAbs ,tbl_mERP_MarginDetail TDet 
			Where  TAbs.ReceiveDocID = 0 And TAbs.EditMargin = 1 And TAbs.MarginID = TDet.MarginID And
			TDet.Code = @ItemCode And dbo.StripTimeFromDate(TDet.EffectiveDate) > @LastTransactionDate
			And [ID] <> @OldMarginID
			*/

			/*Update the record only if the OldEffectiveDate is greater than the LastTransactionDate*/
			Update tbl_mERP_MarginDetail Set Percentage = @NewMargin , EffectiveDate = @NewEffectDate, [level]=5
			Where [ID] = @OldMarginID 
		End
		Else
		Begin
			/*Any open User record will be cancelled*/
			/*As per ITC request, Revoke date should not be updated  while editing
			Margin from Edit MArgin Screen. So we are commenting below update statement*/
			/*
			Update TDet Set TDet.RevokeDate = TDet.EffectiveDate, [level]=5
			From tbl_mERP_MarginAbstract TAbs ,tbl_mERP_MarginDetail TDet 
			Where  TAbs.ReceiveDocID = 0 And TAbs.EditMargin = 1 And TAbs.MarginID = TDet.MarginID And
			TDet.Code = @ItemCode And dbo.StripTimeFromDate(TDet.EffectiveDate) > @LastTransactionDate

			/* Update RevokeDate */
			Update tbl_mERP_MarginDetail Set RevokeDate = Dateadd(day,-1,@NewEffectDate) Where Code = @ItemCode And ID =  @OldMarginID And Level = 5			
			And Dateadd(day,-1,@NewEffectDate) > dbo.StripTimeFromDate(EffectiveDate) 
			*/
			/*Margin % may be applied in any one of the Transactions so dont update 
			it instead insert the same*/
			/* Begin: Process Abstract table Insert */
			Insert Into tbl_mERP_MarginAbstract(DocumentDate, ReceiveDocID,EditMargin)
			Values(@DocumentDate,0,1)
			Set @marginAbsID =  @@identity
			-- end: Process Abstract table Insert

			/* Insert Detail Record */
			Insert Into tbl_mERP_MarginDetail(MarginID,  Level, Percentage, EffectiveDate, Code)
			Select @marginAbsID, 5, @NewMargin,@NewEffectDate, @ItemCode
			Set @MarginDetID =  @@identity 

			/* Insert Channel Margin Detail */
			Insert Into tbl_mERP_ChannelMarginDetail(RecdChannelID, MarginID,  MarginDetID, ChannelTypeCode, RegFlag, 
					CatCode, CatLevel, MarginPerc)
			Select 0, @marginAbsID, @MarginDetID, ChannelTypeCode, RegFlag, CatCode, CatLevel, MarginPerc
			From tbl_mERP_ChannelMarginDetail Where MarginDetID = @OldMarginID

		End
	End
	Else
	Begin
		/*Any open User record will be cancelled*/
		/*As per ITC request, Revoke date should not be updated  while editing
		Margin from Edit MArgin Screen. So we are commenting below update statement*/
		/*
		Update TDet Set TDet.RevokeDate = TDet.EffectiveDate, [level]=5                                                                                                                                                                                                                                                                                                                  
		From tbl_mERP_MarginAbstract TAbs ,tbl_mERP_MarginDetail TDet 
		Where  TAbs.ReceiveDocID = 0 And TAbs.EditMargin = 1 And TAbs.MarginID = TDet.MarginID And
		TDet.Code = @ItemCode And dbo.StripTimeFromDate(TDet.EffectiveDate) > @LastTransactionDate
		*/
		
		/* Begin: Process Abstract table Insert */
		Insert Into tbl_mERP_MarginAbstract(DocumentDate, ReceiveDocID,EditMargin)
		Values(@DocumentDate,0,1)
		Set @marginAbsID =  @@identity
		-- end: Process Abstract table Insert

		/* Insert Detail Record */
		Insert Into tbl_mERP_MarginDetail(MarginID,  Level, Percentage, EffectiveDate, Code)
		Select @marginAbsID, 5, @NewMargin,@NewEffectDate, @ItemCode 
		Set @MarginDetID =  @@identity 

		/* Insert Channel Margin Detail */
		IF isnull(@OldMarginID,0) > 0
		Begin
			Insert Into tbl_mERP_ChannelMarginDetail(RecdChannelID, MarginID,  MarginDetID, ChannelTypeCode, RegFlag, 
					CatCode, CatLevel, MarginPerc)
			Select 0, @marginAbsID, @MarginDetID, ChannelTypeCode, RegFlag, CatCode, CatLevel, MarginPerc
			From tbl_mERP_ChannelMarginDetail Where MarginDetID = @OldMarginID
		End
	End

	--Create Log
	Insert Into tbl_mERP_ProdMargin_AuditLog(UserName,Product_Code,OldMargin,NewMargin,OldEffectiveDate,NewEffectiveDate,CreationTime)
	Values (@UserName,@ItemCode,@OldMargin,@NewMargin,@OldEffectDate,@NewEffectDate,@DocumentDate)

	IF @@error = 0 
		Select 1
	Else
		Select 0

End
