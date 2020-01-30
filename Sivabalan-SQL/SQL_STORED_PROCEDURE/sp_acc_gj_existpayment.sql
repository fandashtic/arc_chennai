CREATE procedure sp_acc_gj_existpayment(@paymentid integer,@BackDate DATETIME=Null)
as
declare @npaymentid integer,@dpaymentdate datetime,@nvalue decimal(18,6),@dapaymentdates datetime
declare @accountid integer,@npaymentmode integer,@cash integer
declare @documentid integer,@nvendorid nvarchar(15),@ndoctype integer,@postdatedcheque integer
declare @chequedate datetime,@bankid integer,@bankaccount integer,@extracol decimal(18,6),@adjamt decimal(18,6) 
declare @discount integer,@othercharges integer
declare @others integer
declare @uniqueid integer
declare @expenseid integer
declare @currentdate datetime 
declare @ddmode int
declare @narration nvarchar(255)
declare @ddcharges decimal(18,6)
Declare @BANKCHARGES INT

set @cash =3		 /* Constant to store the Cash AccountID*/	
set @ndoctype=17          /* Constant to store the Document Type*/	
set @accountid=0         /* variable to store the Vendor's AccountID*/	
set @postdatedcheque =8  /* Constant to store the Post Dated Cheque AccountID*/	          
set @discount =13	 /* Constant to store the Discount AccountID*/
set @othercharges=14  	 /* Constanat to store the OtherCharges AccountID*/
set @bankaccount =0	 /* variable to store the BankAccounts AccountID*/ 
set @BANKCHARGES = 9 
                                  
select @npaymentid = [DocumentID],@dpaymentdate = [DocumentDate],@nvalue = ISNULL(Value,0),
@nvendorid=ISNULL([VendorID],0),@npaymentmode = [PaymentMode],@bankid = [BankID],
@chequeDate = [Cheque_Date],@others = ISNULL([Others],0),
@expenseid = isnull(ExpenseAccount,0),@ddmode = IsNull(DDMode,0),
@ddcharges = IsNull(DDCharges,0) from Payments where [DocumentID]=@Paymentid

if @others <> 0 or @expenseid <> 0
begin
--	select 1
--	execute  sp_acc_updatefapayment @paymentid
	execute  sp_acc_gj_otherpayments @paymentid,@BackDate
end
else 
begin
	Create Table #TempBackdatedpayments(AccountID Int) --for backdated operation

	select @accountid=ISNULL([AccountID],0)
	from [Vendors]
	where [VendorID]=@nvendorid  
	
	/* if paymentmode is 0 then CASH payment*/
	/* if paymentmode is 1 then CHEQUE payment*/
	if @accountid <> 0 and @npaymentmode = 0
	begin
	 begin tran
	  update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 24
	  select @documentid = DocumentID - 1 from DocumentNumbers where DocType = 24
	 commit tran

	 begin tran
	  update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 51
	  select @uniqueid = DocumentID - 1 from DocumentNumbers where DocType = 51
	 commit tran
	
	if @nvalue <> 0
	begin
	 insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
	 [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
	 Values(@documentid,@accountid,@dpaymentdate,@nvalue,0,@npaymentid,@ndoctype,'Cash Payment',@uniqueid)  
	 Insert Into #TempBackdatedpayments(AccountID) Values(@accountid)
	end
	
	if @nvalue <> 0
	begin
	 insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
	 [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
	 Values(@documentid,@cash,@dpaymentdate,0,@nvalue,@npaymentid,@ndoctype,'Cash Payment',@uniqueid)  
	 Insert Into #TempBackdatedpayments(AccountID) Values(@cash)
	end
	end  
	else if @accountid <> 0 and @npaymentmode =1 
	begin
	  begin tran
	   update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 24
	   select @documentid = DocumentID - 1 from DocumentNumbers where DocType = 24
	  commit tran

	 begin tran
	  update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 51
	  select @uniqueid = DocumentID - 1 from DocumentNumbers where DocType = 51
	 commit tran
	
 	 select @bankaccount = ISNULL([AccountID],0) from bank
  	 where [BankID]=@bankid
	 
	  set dateformat dmy 
	  --set @dpaymentdate = dbo.StripDateFromTime(@dpaymentDate)  
	  set @chequedate =   dbo.stripDateFromTime(@chequeDate)  
-- --   	  set @currentdate = dbo.stripdatefromtime(getdate())
  	  set @currentdate = dbo.stripdatefromtime(dbo.Sp_Acc_GetOperatingDate(getdate()))
	  
	/*to check whether the cheque is a current date cheque or postdated cheque*/ 
  	  if (dbo.StripDateFromTime(@dpaymentDate) < @currentdate) and (dbo.StripDateFromTime(@dpaymentDate) < @chequedate) and  (@chequedate <= @currentdate)
	  begin
 	  	if @nvalue <> 0
		begin
	     		insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
	     		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
	     		Values(@documentid,@accountid,@dpaymentdate,@nvalue,0,@npaymentid,@ndoctype,'Post Dated Cheque Payment',@uniqueid)
			Insert Into #TempBackdatedpayments(AccountID) Values(@accountid)
		end
	   
		if @nvalue <> 0
		begin 
	     		insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
	     		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
	     		Values(@documentid,@postdatedcheque,@dpaymentdate,0,@nvalue,@npaymentid,@ndoctype,'Post Dated Cheque Payment',@uniqueid)
			Insert Into #TempBackdatedpayments(AccountID) Values(@postdatedcheque)
		end
		
-- 		begin tran
-- 	  		update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 24
-- 	  		select @documentid = DocumentID - 1 from DocumentNumbers where DocType = 24
-- 	 	commit tran
-- 
-- 	 	begin tran
-- 	  		update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 51
-- 	  		select @uniqueid = DocumentID - 1 from DocumentNumbers where DocType = 51
-- 	 	commit tran
-- 		
--  	  	if @nvalue <> 0
-- 		begin
-- 	     		insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
-- 	     		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
-- 	     		Values(@documentid,@postdatedcheque,@chequedate,@nvalue,0,@npaymentid,@ndoctype,'Post Dated Cheque Payment',@uniqueid)
-- 			Insert Into #TempBackdatedpayments(AccountID) Values(@postdatedcheque)
-- 		end
-- 
-- 	   	if @nvalue <> 0
-- 		begin 
-- 	     		insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
-- 	     		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
-- 	     		Values(@documentid,@bankaccount,@chequedate,0,@nvalue,@npaymentid,@ndoctype,'Post Dated Cheque Payment',@uniqueid)
-- 			Insert Into #TempBackdatedpayments(AccountID) Values(@bankaccount)
-- 		end

	  end	  
	  else if @currentdate = @chequedate or @chequedate < @currentdate
	  begin
		if @nvalue <> 0
		begin
			insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
	    		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
		        Values(@documentid,@accountid,@dpaymentdate,@nvalue,0,@npaymentid,@ndoctype,'Current Date Cheque Payment',@uniqueid)
			Insert Into #TempBackdatedpayments(AccountID) Values(@accountid)
		end
	   
		if @nvalue <> 0
		begin 
			insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
	    		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
	    		Values(@documentid,@bankaccount,@dpaymentdate,0,@nvalue,@npaymentid,@ndoctype,'Current Date Cheque Payment',@uniqueid)
			Insert Into #TempBackdatedpayments(AccountID) Values(@bankaccount)
		end
	  end
	  else if @chequedate > @currentdate
	  begin
		if @nvalue <> 0
		begin
	     		insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
	     		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
	     		Values(@documentid,@accountid,@dpaymentdate,@nvalue,0,@npaymentid,@ndoctype,'Post Dated Cheque Payment',@uniqueid)
			Insert Into #TempBackdatedpayments(AccountID) Values(@accountid)
		end
	   
		if @nvalue <> 0
		begin 
	     		insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
	     		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
	     		Values(@documentid,@postdatedcheque,@dpaymentdate,0,@nvalue,@npaymentid,@ndoctype,'Post Dated Cheque Payment',@uniqueid)
			Insert Into #TempBackdatedpayments(AccountID) Values(@postdatedcheque)
		end
	  end
	end
	else if @accountid <> 0 and @npaymentmode = 2 
	begin
		begin tran
	   		update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 24
	   		select @documentid = DocumentID - 1 from DocumentNumbers where DocType = 24
	  	commit tran

	 	begin tran
	  		update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 51
	  		select @uniqueid = DocumentID - 1 from DocumentNumbers where DocType = 51
	 	commit tran
	
		if @ddmode = 0
		begin
			set @bankaccount = @cash
			set @narration = 'DD Payment - Cash'
		end 
		else if @ddmode = 1
		begin
			select @bankaccount = ISNULL([AccountID],0) from bank
	  		where [BankID]=@bankid			
			set @narration = 'DD Payment - BankAccount'
		end
		
  		if @nvalue <> 0
	 	begin
			insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
		        Values(@documentid,@accountid,@dpaymentdate,@nvalue,0,@npaymentid,@ndoctype,@narration,@uniqueid)
			Insert Into #TempBackdatedpayments(AccountID) Values(@accountid)
		end
		   
		if @nvalue <> 0
		begin 
			insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
	    		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
	    		Values(@documentid,@bankaccount,@dpaymentdate,0,@nvalue,@npaymentid,@ndoctype,@narration,@uniqueid)
			Insert Into #TempBackdatedpayments(AccountID) Values(@bankaccount)
		end
		
		begin tran
	   		update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 24
	   		select @documentid = DocumentID - 1 from DocumentNumbers where DocType = 24
	  	commit tran

	 	begin tran
	  		update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 51
	  		select @uniqueid = DocumentID - 1 from DocumentNumbers where DocType = 51
	 	commit tran

		if @ddcharges <> 0
	 	begin
			insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
		        Values(@documentid,@BANKCHARGES,@dpaymentdate,@ddcharges,0,@npaymentid,@ndoctype,'DD Payment - DD Charges',@uniqueid)
			Insert Into #TempBackdatedpayments(AccountID) Values(@BANKCHARGES)
		end
		   
		if @ddcharges <> 0
		begin 
			insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
	    		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
	    		Values(@documentid,@bankaccount,@dpaymentdate,0,@ddcharges,@npaymentid,@ndoctype,'DD Payment - DD Charges',@uniqueid)
			Insert Into #TempBackdatedpayments(AccountID) Values(@bankaccount)
		end
	end

	select @extracol= sum(isnull(ExtraCol,0)),@adjamt = sum(isnull(Adjustment,0)) from paymentdetail 
	where [PaymentID]=@Paymentid 
	
	If (@extracol > 0) or (@adjamt > 0)
	Begin
		begin tran
   			update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 24
	   		select @documentid = DocumentID - 1 from DocumentNumbers where DocType = 24
		commit tran  

		begin tran
			update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 51
			select @uniqueid = DocumentID - 1 from DocumentNumbers where DocType = 51
		commit tran
	End
	
	  if @extracol > 0 
	   begin
	    insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
	    [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
	    Values(@documentid,@othercharges,@dpaymentdate,@extracol,0,@npaymentid,@ndoctype,'Extra Amount Collected',@uniqueid)
	    Insert Into #TempBackdatedpayments(AccountID) Values(@othercharges)
	
	    insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
	    [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
	    Values(@documentid,@accountid,@dpaymentdate,0,@extracol,@npaymentid,@ndoctype,'Extra Amount Collected',@uniqueid)   
	    Insert Into #TempBackdatedpayments(AccountID) Values(@accountid)
	
	   end
	  
	  if @adjamt > 0 
	   begin
	    insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
	    [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
	    Values(@documentid,@accountid,@dpaymentdate,@adjamt,0,@npaymentid,@ndoctype,'Adjusted with Shortage Collected',@uniqueid)   
	    Insert Into #TempBackdatedpayments(AccountID) Values(@accountid)	
	    
	    insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
	    [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
	    Values(@documentid,@discount,@dpaymentdate,0,@adjamt,@npaymentid,@ndoctype,'Adjusted with Shortage Collected',@uniqueid)
            Insert Into #TempBackdatedpayments(AccountID) Values(@discount)
	   end
	If @BackDate Is Not Null  
	Begin
		Declare @TempAccountID Int
		DECLARE scantempbackdatedaccounts CURSOR KEYSET FOR
		Select AccountID From #TempBackdatedpayments
		OPEN scantempbackdatedaccounts
		FETCH FROM scantempbackdatedaccounts INTO @TempAccountID
		WHILE @@FETCH_STATUS =0
		Begin
			Exec sp_acc_backdatedaccountopeningbalance @BackDate,@TempAccountID
			FETCH NEXT FROM scantempbackdatedaccounts INTO @TempAccountID
		End
		CLOSE scantempbackdatedaccounts
		DEALLOCATE scantempbackdatedaccounts
	End
	Drop Table #TempBackdatedpayments
end

