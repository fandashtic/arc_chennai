CREATE procedure sp_insert_CreditNote(
	@PartyType int,
	@PartyID nvarchar(15),
	@Value Decimal(18,6),
	@DocDate datetime,
	@Remarks nvarchar(255),
	@DocRef nvarchar(50) = N''
)
as
declare @DocumentID int
DECLARE @SalesmanID int
Declare @DefaultBeat as Int --Specific to ITC  

 Select @DefaultBeat = IsNull(DefaultBeatID,0) From Customer Where CustomerID = @PartyID  
 IF @DefaultBeat > 0  
 	select @SalesmanID = SalesmanID from Beat_Salesman where BeatID = @DefaultBeat And CustomerID = @PartyID 
 Else  
  	select @SalesmanID = ISNULL((select Distinct SalesmanID from Beat_Salesman where CustomerID = @PartyID), 0)      

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
				DocRef)
	values
			       (@DocumentID,
				@PartyID,
				@Value,
				@DocDate,
				@Value,
				@Remarks,
				@SalesmanID,
				@DocRef)	
else
	insert into CreditNote (DocumentID,
				VendorID,
				NoteValue,
				DocumentDate,
				Balance,
				Memo,
				DocRef)
	values
			       (@DocumentID,
				@PartyID,
				@Value,
				@DocDate,
				@Value,
				@Remarks,
				@DocRef)	
select @DocumentID, @@IDENTITY

