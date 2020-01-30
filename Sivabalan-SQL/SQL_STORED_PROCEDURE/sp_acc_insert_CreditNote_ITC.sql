CREATE procedure sp_acc_insert_CreditNote_ITC(@PartyType int,
					@PartyID nvarchar(15),
					@Value float,
					@DocDate datetime,
					@Remarks nvarchar(255),
					@DocRef nVarchar(50) = N'',
     @Multiple INT = 0,
     @Flag INT = 0,
     @UserName nVarchar(100) = N'')
as
declare @DocumentID int
DECLARE @SalesmanID int
select @SalesmanID = ISNULL((select Top 1 SalesmanID From Beat_Salesman 
where CustomerID = @PartyID And BeatID In 
(Select top 1 DefaultBeatID From customer Where CustomerID = @PartyID)), 0)
begin tran
update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 10
select @DocumentID = DocumentID - 1 from DocumentNumbers where DocType = 10
commit tran
if @PartyType = 0 
	insert into CreditNote (DocumentID,
				CustomerID,
				NoteValue,
				DocumentDate,
				Balance,
				Memo,
				SalesmanID,
				DocRef,AccountMode,Flag,UserName)
	values
			       (@DocumentID,
				@PartyID,
				@Value,
				@DocDate,
				@Value,
				@Remarks,
				@SalesmanID,
				@DocRef,@Multiple,@Flag,@UserName)	
else if @PartyType=1 
	insert into CreditNote (DocumentID,
				VendorID,
				NoteValue,
				DocumentDate,
				Balance,
				Memo,
				DocRef,AccountMode,Flag,UserName)
	values
			       (@DocumentID,
				@PartyID,
				@Value,
				@DocDate,
				@Value,
				@Remarks,
				@DocRef,@Multiple,@Flag,@UserName)	
else if @PartyType=2 
	insert into CreditNote (DocumentID,
				Others,
				NoteValue,
				DocumentDate,
				Balance,
				Memo,
				DocRef,AccountMode,Flag,UserName)
	values
			       (@DocumentID,
				@PartyID,
				@Value,
				@DocDate,
				@Value,
				@Remarks,
				@DocRef,@Multiple,@Flag,@UserName)	
select @DocumentID, @@IDENTITY
