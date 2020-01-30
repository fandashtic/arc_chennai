CREATE procedure sp_acc_gj_creditnoteamendment (@creditid integer,@BackDate DATETIME=Null)
as
declare @ncreditid integer,@ddocumentdate datetime,@nnotevalue decimal(18,6)
declare @accountid integer,@expensesid integer,@vendorid nvarchar(15)
declare @documentid integer,@ncustomerid nvarchar(15),@ndoctype integer,@nmode integer
declare @uniqueid integer
declare @Others Int

/* @nmode - Indicates whether the Credit Note For a Vendor or Customer
1= Credit Note for a Customer
2= Credit Note for a Vendor
3= Credit Note for Others */

set @ndoctype=90        /* Constant to store the Document Type*/
set @accountid=0        /* variable to store the Vendor or Customer AccountID*/	           
set @expensesid=0	/* variable to store the Expenses AccountID*/


Declare @Cancel_ID int

select @Cancel_ID = RefDocId from  creditnote where creditid = @creditid


Create Table #TempBackdatedcreditnote(AccountID Int) --for backdated operation

select @ncustomerid=[CustomerID],@vendorid=[VendorID],@Others=Others from CreditNote
where [CreditID]=@Cancel_ID
 
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
	select @ncreditid = [CreditID],@ddocumentdate = [DocumentDate],
	@nnotevalue = ISNULL(NoteValue,0),@ncustomerid=ISNULL([CustomerID],0),
	@expensesid=[AccountID] from CreditNote
	where [CreditID]=@Cancel_ID
	
	select @accountid=ISNULL([AccountID],0)
	from [Customer]
	where [CustomerID]=@ncustomerid  

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
			Values(@documentid,@accountid,@ddocumentdate,@nnotevalue,0,@ncreditid,@ndoctype,
			'Credit Note For Customer-Amended',@uniqueid)  
			Insert Into #TempBackdatedcreditnote(AccountID) Values(@accountid) 
		end
		
		if @nnotevalue <> 0
		begin
			insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
			Values(@documentid,@expensesid,@ddocumentdate,0,@nnotevalue,@ncreditid,@ndoctype,
			'Credit Note For Customer-Amended',@uniqueid)  
			Insert Into #TempBackdatedcreditnote(AccountID) Values(@expensesid) 
		end
	end
end
else if @nmode =2
begin                                   
	select @ncreditid = [CreditID],@ddocumentdate = [DocumentDate],
	@nnotevalue = ISNULL(NoteValue,0),@vendorid=ISNULL([VendorID],0),
	@expensesid=[AccountID] from CreditNote
	where [CreditID]=@Cancel_ID
	
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
			Values(@documentid,@accountid,@ddocumentdate,@nnotevalue,0,@ncreditid,@ndoctype,
			'Credit Note For Vendor-Amended',@uniqueid)  
			Insert Into #TempBackdatedcreditnote(AccountID) Values(@accountid) 
		end
		if @nnotevalue <> 0
		begin
			insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
			Values(@documentid,@expensesid,@ddocumentdate,0,@nnotevalue,@ncreditid,@ndoctype,
			'Credit Note For Vendor-Amended',@uniqueid)  
			Insert Into #TempBackdatedcreditnote(AccountID) Values(@expensesid) 
		end
	end
end
else if @nmode =3
begin                                   
	select @ncreditid = [CreditID],@ddocumentdate = [DocumentDate],
	@nnotevalue = ISNULL(NoteValue,0),@Others=ISNULL([Others],0),
	@expensesid=[AccountID] from CreditNote
	where [CreditID]=@Cancel_ID
	
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
			Values(@documentid,@accountid,@ddocumentdate,@nnotevalue,0,@ncreditid,@ndoctype,
			'Credit Note For Others-Amended',@uniqueid)  
			Insert Into #TempBackdatedcreditnote(AccountID) Values(@accountid) 
		end
		if @nnotevalue <> 0
		begin
			insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
			Values(@documentid,@expensesid,@ddocumentdate,0,@nnotevalue,@ncreditid,@ndoctype,
			'Credit Note For Others-Amended',@uniqueid)  
			Insert Into #TempBackdatedcreditnote(AccountID) Values(@expensesid) 
		end
	end
end

-- Enteries for reversing the document end here
-- ============================================================================================
-- enteries for the Amended Document Starts here
if @nmode =1 
begin                                   
	select @ncreditid = [CreditID],@ddocumentdate = [DocumentDate],
	@nnotevalue = ISNULL(NoteValue,0),@ncustomerid=ISNULL([CustomerID],0),
	@expensesid=[AccountID] from CreditNote
	where [CreditID]=@creditid
	
	select @accountid=ISNULL([AccountID],0)
	from [Customer]
	where [CustomerID]=@ncustomerid  

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

		If @nnotevalue <> 0
		begin
			insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
		   	[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
		   	Values(@documentid,@expensesid,@ddocumentdate,@nnotevalue,0,@ncreditid,@ndoctype,
			'Credit Note For Customer-Amendment',@uniqueid)  
			Insert Into #TempBackdatedcreditnote(AccountID) Values(@expensesid) 
		end
		if @nnotevalue <> 0
		begin
			insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
		   	[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
		   	Values(@documentid,@accountid,@ddocumentdate,0,@nnotevalue,@ncreditid,@ndoctype,
			'Credit Note For Customer-Amendment',@uniqueid)  
			Insert Into #TempBackdatedcreditnote(AccountID) Values(@accountid) 
		end
	
	end
end
else if @nmode =2
begin                                   
	select @ncreditid = [CreditID],@ddocumentdate = [DocumentDate],@nnotevalue = ISNULL(NoteValue,0),@vendorid=ISNULL([VendorID],0),@expensesid=[AccountID] from CreditNote
	where [CreditID]=@creditid
	
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
			Values(@documentid,@expensesid,@ddocumentdate,@nnotevalue,0,@ncreditid,@ndoctype,
			'Credit Note For Vendor-Amendment',@uniqueid)  
			Insert Into #TempBackdatedcreditnote(AccountID) Values(@expensesid)
		end
		
		if @nnotevalue <> 0
		begin
			insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
			Values(@documentid,@accountid,@ddocumentdate,0,@nnotevalue,@ncreditid,@ndoctype,
			'Credit Note For Vendor-Amendment',@uniqueid)  
			Insert Into #TempBackdatedcreditnote(AccountID) Values(@accountid) 
		end
	end
end
else if @nmode =3
begin                                   
	select @ncreditid = [CreditID],@ddocumentdate = [DocumentDate],@nnotevalue = ISNULL(NoteValue,0),@Others=ISNULL([Others],0),@expensesid=[AccountID] from CreditNote
	where [CreditID]=@creditid

	Set @accountid=@Others

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
   			Values(@documentid,@expensesid,@ddocumentdate,@nnotevalue,0,@ncreditid,@ndoctype,
			'Credit Note For Others-Amendment',@uniqueid)  
			Insert Into #TempBackdatedcreditnote(AccountID) Values(@expensesid)
		end

		if @nnotevalue <> 0
		begin
   			insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
   			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
   			Values(@documentid,@accountid,@ddocumentdate,0,@nnotevalue,@ncreditid,@ndoctype,
			'Credit Note For Others-Amendment',@uniqueid)  
			Insert Into #TempBackdatedcreditnote(AccountID) Values(@accountid)
		end
 	end
end

If @BackDate Is Not Null  
Begin
	Declare @TempAccountID Int
	DECLARE scantempbackdatedaccounts CURSOR KEYSET FOR
	Select AccountID From #TempBackdatedcreditnote
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
Drop Table #TempBackdatedcreditnote






