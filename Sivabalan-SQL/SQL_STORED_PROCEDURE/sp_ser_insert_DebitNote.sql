CREATE procedure sp_ser_insert_DebitNote (@PartyType int,
					@PartyID nvarchar(15),
					@Value Decimal(18,6),
					@DocDate datetime,
					@Remarks nvarchar(255),					
					@Flag int = 0,
					@DocRef Varchar(50) = '', @UserName varchar(255), @TranType int = 10)
as
/* @TranType for Debit Note fixed as 10 */
declare @DocumentID int
declare @SalesmanID int

select @SalesmanID = ISNULL((select SalesmanID from Beat_Salesman where CustomerID = @PartyID), 0)
begin tran
	update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 11
	select @DocumentID = DocumentID - 1 from DocumentNumbers where DocType = 11
commit tran
declare @DocumentType varchar(30)
declare @Prefix varchar(30)
declare @DocReference varchar(30)
declare @LastCount int
	select top 1 @DocumentType = Documenttype from TransactionDocNumber 
	Inner Join DocumentUsers On TransactionDocNumber.serialno = Documentusers.serialno  
	where TransactionType = @TranType and TransactionDocNumber.Active = 1 
	and Documentusers.username = @UserName
	If isnull(@DocumentType, '') = '' 
	begin 
		select top 1 @DocumentType = Documenttype
		from TransactionDocNumber 
		where TransactionType = @TranType and TransactionDocNumber.Active = 1 
	end 
	if isnull(@DocumentType, '') <> '' 
	begin  	
		BEGIN TRAN    
			UPDATE TransactionDocNumber SET LastCount = LastCount + 1   
			WHERE TransactionType = @TranType And DocumentType = @DocumentType    
			SELECT @LastCount = LastCount - 1 FROM TransactionDocNumber 
			WHERE TransactionType = @TranType And DocumentType = @DocumentType 
		COMMIT TRAN
		set @DocReference = dbo.fn_ser_GetTransactionSerial(@TranType, @DocumentType, @LastCount)	
	end 

	if isnull(@DocReference, '') = ''
	begin 
		select @Prefix = Prefix from VoucherPrefix where [TranID]= 'DEBIT NOTE'
		Set @DocReference = isnull(@Prefix, 'DR') + Cast(@DocumentID as nvarchar(20))
	end

if @PartyType = 0 
	insert into DebitNote (DocumentID,
				CustomerID,
				NoteValue,
				DocumentDate,
				Balance,
				Memo,
				SalesmanID,
				Flag,
				DocRef, DocumentReference, DocSerialType)
	values
			       (@DocumentID,
				@PartyID,
				@Value,
				@DocDate,
				@Value,
				@Remarks,
				@SalesmanID,
				@Flag,
				@DocRef, @DocReference, @DocumentType)	
else
	insert into DebitNote (DocumentID,
				VendorID,
				NoteValue,
				DocumentDate,
				Balance,
				Memo,
				SalesmanID,
				Flag,
				DocRef, DocumentReference, DocSerialType)
	values
			       (@DocumentID,
				@PartyID,
				@Value,
				@DocDate,
				@Value,
				@Remarks,
				@SalesmanID,
				@Flag,
				@DocRef, @DocReference, @DocumentType)	
select @DocumentID, @@Identity, @DocReference 'docref'

