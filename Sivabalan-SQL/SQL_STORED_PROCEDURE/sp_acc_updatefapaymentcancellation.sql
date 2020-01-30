CREATE procedure sp_acc_updatefapaymentcancellation(@paymentid integer)
as
declare @npaymentid integer,@dpaymentdate datetime,@nvalue decimal(18,6),@dapaymentdates datetime
declare @accountid integer,@npaymentmode integer,@cash integer
declare @documentid integer,@nvendorid nvarchar(15),@ndoctype integer,@postdatedcheque integer
declare @chequedate datetime,@bankid integer,@bankaccount integer,@extracol decimal(18,6),@adjamt decimal(18,6) 
declare @discount integer,@othercharges integer
declare @others integer
declare @ddocumentdate datetime
declare @adjustedamount decimal(18,6)
declare @currentdate datetime 

declare @paymentdate datetime  
declare @narration nvarchar(256)
declare @otheraccount integer
declare @value decimal(18,6)
declare @uniqueid integer

set @cash =3		 /* Constant to store the Cash AccountID*/	
set @ndoctype=18          /* Constant to store the Document Type*/	
set @accountid=0         /* variable to store the Vendor's AccountID*/	
set @postdatedcheque =8  /* Constant to store the Post Dated Cheque AccountID*/	          
set @discount =13	 /* Constant to store the Discount AccountID*/
set @othercharges=14  	 /* Constanat to store the OtherCharges AccountID*/
set @bankaccount =0	 /* variable to store the BankAccounts AccountID*/ 

set @currentdate = dbo.stripdatefromtime(dbo.Sp_Acc_GetOperatingDate(getdate()))

select @npaymentmode =[PaymentMode],@chequedate =[Cheque_Date],@paymentdate =[DocumentDate],
@value = ISNULL([Value],0),@otheraccount = ISNULL([Others],0) from payments where [DocumentID]=@paymentid

	set dateformat dmy 
	set @paymentdate = dbo.StripDateFromTime(@paymentDate)  
	set @chequedate =   dbo.stripDateFromTime(@chequeDate)  
	
	if @npaymentmode = 0
	begin
		set @narration = 'Cash Payment'
	end	    
	else if @npaymentmode =1 or @npaymentmode =2
	begin 
		if @paymentdate = @chequedate
		begin
			set @narration = 'Current Date Cheque Payment'	
		end
		else if @chequedate > @paymentdate  
		begin
			set @narration = 'Post Dated Cheque Payment'	
		end
	end                           
	
	begin tran
		update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 24
  		select @documentid = DocumentID - 1 from DocumentNumbers where DocType = 24
	commit tran

	begin tran
		update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 51
  		select @uniqueid = DocumentID - 1 from DocumentNumbers where DocType = 51
	commit tran

	if @npaymentmode = 0
	begin
		insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
		Values(@documentid,@cash,@paymentdate,@value,0,@paymentid,@ndoctype,@narration,@uniqueid)
	end
	else
	begin
		if @chequedate > @paymentdate and @chequedate < @currentdate
		begin
			insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
			Values(@documentid,@otheraccount,@paymentdate,@value,0,@paymentid,@ndoctype,@narration,@uniqueid)
			
			insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
         Values(@documentid,@postdatedcheque,@paymentdate,0,@value,@paymentid,@ndoctype,@narration,@uniqueid)		
			
			insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
	      Values(@documentid,@postdatedcheque,@paymentdate,@value,0,@paymentid,@ndoctype,@narration,@uniqueid)		
		end
		else if @currentdate < @chequedate and @currentdate > @paymentdate
		begin
			insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
	      Values(@documentid,@postdatedcheque,@paymentdate,@value,0,@paymentid,@ndoctype,@narration,@uniqueid)			
		end
		else if @chequedate <= @paymentdate and @chequedate = @currentdate
		begin
			insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
			Values(@documentid,@otheraccount,@paymentdate,@value,0,@paymentid,@ndoctype,@narration,@uniqueid)
		end	 
	end	

	DECLARE scanpaymentdetail1 cursor KEYSET FOR 
	select [DocumentID],[DocumentDate],[PaymentDate],ISNULL(AdjustedAmount,0),ISNULL([Others],0)
	from paymentdetail where [PaymentID]=@Paymentid
	
	OPEN scanpaymentdetail1
	
	FETCH FROM scanpaymentdetail1 into @npaymentid,@ddocumentdate,@dpaymentdate,@adjustedamount,@others
	WHILE @@Fetch_Status =0
	BEGIN
		insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
		Values(@documentid,@others,@paymentdate,0,@adjustedamount,@paymentid,@ndoctype,@narration,@uniqueid)
	
	FETCH NEXT FROM scanpaymentdetail1 into @npaymentid,@ddocumentdate,@dpaymentdate,@adjustedamount,@others
	END
	CLOSE scanpaymentdetail1
	DEALLOCATE scanpaymentdetail1	

