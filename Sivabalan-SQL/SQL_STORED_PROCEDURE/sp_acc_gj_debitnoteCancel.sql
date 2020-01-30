CREATE Procedure sp_acc_gj_debitnoteCancel(@debitid integer,@BackDate DATETIME=Null)
as
declare @ndebitid integer,@ddocumentdate datetime,@nnotevalue decimal(18,6)
declare @accountid integer,@expensesid integer,@vendorid nvarchar(15)
declare @documentid integer,@ncustomerid nvarchar(15),@ndoctype integer,@nmode integer
declare @uniqueid integer
declare @Others Int
Declare @Gift_Voucher Int
/* @nmode - Indicates whether the Debit Note Cancellation For a Vendor or Customer
1= Debit Note for a Customer
2= Debit Note for a Vendor
3= Debit Note for Others*/

set @ndoctype=64         /* Constant to store the Document Type*/	
set @accountid=0        /* variable to store the Vendor or Customer AccountID*/	           
set @expensesid=0	/* variable to store the Expenses AccountID*/
Set @Gift_Voucher = 114 /* Gift Voucher Customer */

Create Table #TempBackdateddebitnotecancel(AccountID Int) --for backdated operation

select @vendorid=[VendorID],@ncustomerid=[CustomerID],@Others=Others from DebitNote
where [DebitID]=@debitid

if @ncustomerid is not null
begin
	set @nmode = 1
end
Else if @vendorid is not null
begin
	set @nmode = 2
end
else if @Others is not null
begin
	set @nmode = 3
end

if @nmode =1 
begin                                   
	select @ndebitid = [DebitID],@ddocumentdate = [DocumentDate],@nnotevalue = ISNULL(NoteValue,0),@ncustomerid=ISNULL([CustomerID],0),@expensesid=[AccountID] from DebitNote
	where [DebitID]=@debitid

	If @ncustomerid = N'GIFT VOUCHER'
	Begin
		Set @accountid = @Gift_Voucher
	End
	Else
	Begin
		select @accountid=ISNULL([AccountID],0)
		from [Customer]
		where [CustomerID]=@ncustomerid  
	End
	if @accountid <> 0
	begin
  		begin tran
   			update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 24
   			select @documentid = DocumentID - 1 from DocumentNumbers where DocType = 24
  		commit tran

  		begin tran
   			update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 51
   			select @uniqueid = DocumentID - 1 from DocumentNumbers where DocType = 51
  		commit tran

		if @nnotevalue <> 0
		begin
   			insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
   			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
   			Values(@documentid,@expensesid,@ddocumentdate,@nnotevalue,0,@ndebitid,@ndoctype,'Debit Note For A Customer-Cancellation',@uniqueid)  
			Insert Into #TempBackdateddebitnotecancel(AccountID) Values(@expensesid) 
		end
		if @nnotevalue <> 0
		begin
   			insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
   			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
   			Values(@documentid,@accountid,@ddocumentdate,0,@nnotevalue,@ndebitid,@ndoctype,'Debit Note For A Customer-Cancellation',@uniqueid)  
			Insert Into #TempBackdateddebitnotecancel(AccountID) Values(@accountid)
		end
	end 
end
else if @nmode =2
begin                                   
	select @ndebitid = [DebitID],@ddocumentdate = [DocumentDate],@nnotevalue = ISNULL(NoteValue,0),@vendorid=ISNULL([VendorID],0),@expensesid=[AccountID] from DebitNote
	where [DebitID]=@debitid

	select @accountid=ISNULL([AccountID],0)
	from [Vendors]
	where [VendorID]=@vendorid

	if @accountid <> 0
	begin
		begin tran
   			update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 24
   			select @documentid = DocumentID - 1 from DocumentNumbers where DocType = 24
  		commit tran
	  	begin tran
	   		update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 51
	   		select @uniqueid = DocumentID - 1 from DocumentNumbers where DocType = 51
	  	commit tran
	
		if @nnotevalue <> 0
		begin
	   		insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
	   		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
	   		Values(@documentid,@expensesid,@ddocumentdate,@nnotevalue,0,@ndebitid,@ndoctype,'Debit Note For A Vendor-Cancellation',@uniqueid)  
			Insert Into #TempBackdateddebitnotecancel(AccountID) Values(@expensesid)
		end
		if @nnotevalue <> 0
		begin
	   		insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
	   		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
	   		Values(@documentid,@accountid,@ddocumentdate,0,@nnotevalue,@ndebitid,@ndoctype,'Debit Note For A Vendor-Cancellation',@uniqueid)  
			Insert Into #TempBackdateddebitnotecancel(AccountID) Values(@accountid)
		end
	end 
end
else if @nmode =3
begin                                   
	select @ndebitid = [DebitID],@ddocumentdate = [DocumentDate],@nnotevalue = ISNULL(NoteValue,0),@Others=ISNULL([Others],0),@expensesid=[AccountID] from DebitNote
	where [DebitID]=@debitid

	set @accountid=ISNULL(@Others,0)

	if @accountid <> 0
	begin
		begin tran
   			update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 24
   			select @documentid = DocumentID - 1 from DocumentNumbers where DocType = 24
  		commit tran
	  	begin tran
	   		update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 51
	   		select @uniqueid = DocumentID - 1 from DocumentNumbers where DocType = 51
	  	commit tran
	
		if @nnotevalue <> 0
		begin
	   		insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
	   		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
	   		Values(@documentid,@expensesid,@ddocumentdate,@nnotevalue,0,@ndebitid,@ndoctype,'Debit Note For Others-Cancellation',@uniqueid)  
			Insert Into #TempBackdateddebitnotecancel(AccountID) Values(@expensesid)
		end
		if @nnotevalue <> 0
		begin
	   		insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
	   		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
	   		Values(@documentid,@accountid,@ddocumentdate,0,@nnotevalue,@ndebitid,@ndoctype,'Debit Note For Others-Cancellation',@uniqueid)  
			Insert Into #TempBackdateddebitnotecancel(AccountID) Values(@accountid)
		end
	end 
end

If @BackDate Is Not Null  
Begin
	Declare @TempAccountID Int
	DECLARE scantempbackdatedaccounts CURSOR KEYSET FOR
	Select AccountID From #TempBackdateddebitnotecancel
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
Drop Table #TempBackdateddebitnotecancel
