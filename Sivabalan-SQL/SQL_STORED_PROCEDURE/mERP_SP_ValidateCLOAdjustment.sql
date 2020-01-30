Create Procedure mERP_SP_ValidateCLOAdjustment (@TransactionType int,@DocumentID int)
AS
BEGIN
	set dateformat dmy
	/*If FA Day close is not enabled*/
	if (Select isnull(Flag,0) from tbl_merp_configdetail where screencode='CLSDAY01' and controlname='FinancialLock') = 0
	BEGIN
		/*Collections*/
		if @TransactionType=1
		BEGIN
			/*If CLO Credit Note is adjusted in a Collection and 
			RFA is submitted then Dont allow collection to Amend or Cancel*/
			If exists(Select * From CollectionDetail Where CollectionID=@DocumentID And DocumentType=2 and 
			DocumentID in (Select CLO.CreditID from clocrnote CLO where isnull(CLO.IsRFAClaimed,0)=1))
			BEGIN
				/*Dont Allow*/
				Select 0
			END
			ELSE
			BEGIN
				/*Allow*/
				Select 1
			END
		END
		/*DSWISE COLLECTION*/
		ELSE IF @TransactionType=2
		BEGIN
			/*If CLO Credit Note is adjusted in a INVOICEWISE Collection and 
			RFA is submitted then Dont allow INVOICEWISE collection to Amend or Cancel*/
			If exists(Select * From InvoiceWiseCollectionDetail Where CollectionID = @DocumentID AND DocumentID in
			(Select CollectionID from CollectionDetail Where DocumentType=2 and 
			DocumentID in (Select CLO.CreditID from clocrnote CLO where isnull(CLO.IsRFAClaimed,0)=1)))
			BEGIN
				/*Dont Allow*/
				Select 0
			END
			ELSE
			BEGIN
				/*Allow*/
				Select 1
			END
		END
		/*MANUAL JOURNAL*/
		ELSE IF @TransactionType=3
		BEGIN
			/*If CLO Credit Note is adjusted in a MANUAL JOURNAL and 
			RFA is submitted then Dont allow MANUAL JOURNAL to Amend or Cancel*/
			if exists(Select * from Generaljournal GJ  
			where GJ.DocumentReference in(Select CLO.CreditID from clocrnote CLO where isnull(CLO.IsRFAClaimed,0)=1)
			And GJ.TransactionID= @DocumentID
			And GJ.DocumentType=35 and isnull(status,0) <> 128             
			and isnull(status,0) <> 192)
			BEGIN
				/*Dont Allow*/
				Select 0
			END
			ELSE
			BEGIN
				/*Allow*/
				Select 1
			END
		END
	END
	ELSE
	BEGIN
		/*Always Allow*/
		Select 1
	END
END
