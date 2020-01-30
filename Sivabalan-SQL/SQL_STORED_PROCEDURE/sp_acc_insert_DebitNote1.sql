CREATE procedure sp_acc_insert_DebitNote1(	@PartyType int,
					@PartyID nvarchar(15),
					@Value float,
					@DocDate datetime,
					@Remarks nvarchar(255),					
					@Flag int = 0,
					@DocRef nVarchar(50) = N'',@Multiple INT = 0)
as
declare @DocumentID int
DECLARE @SalesmanID int

select @SalesmanID = ISNULL((select SalesmanID from Beat_Salesman where CustomerID = @PartyID), 0)
begin tran
update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 11
select @DocumentID = DocumentID - 1 from DocumentNumbers where DocType = 11
commit tran
if @PartyType = 0 
	insert into DebitNote (DocumentID,
				CustomerID,
				NoteValue,
				DocumentDate,
				Balance,
				Memo,
				SalesmanID,
				Flag,
				DocRef,AccountMode)
	values
			       (@DocumentID,
				@PartyID,
				@Value,
				@DocDate,
				@Value,
				@Remarks,
				@SalesmanID,
				@Flag,
				@DocRef,@Multiple)	
else if @PartyType = 1
	insert into DebitNote (DocumentID,
				VendorID,
				NoteValue,
				DocumentDate,
				Balance,
				Memo,
				SalesmanID,
				Flag,
				DocRef,AccountMode)
	values
			       (@DocumentID,
				@PartyID,
				@Value,
				@DocDate,
				@Value,
				@Remarks,
				@SalesmanID,
				@Flag,
				@DocRef,@Multiple)	
else if @PartyType = 2
	insert into DebitNote (DocumentID,
				Others,
				NoteValue,
				DocumentDate,
				Balance,
				Memo,
				SalesmanID,
				Flag,
				DocRef,AccountMode)
	values
			       (@DocumentID,
				@PartyID,
				@Value,
				@DocDate,
				@Value,
				@Remarks,
				@SalesmanID,
				@Flag,
				@DocRef,@Multiple)	
select @DocumentID, @@Identity




