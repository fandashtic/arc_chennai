CREATE procedure sp_acc_amend_CreditNote_ITC(
					@Credit_no as int,
					@PartyType int,
					@PartyID nvarchar(15),
					@Value float,
					@DocDate datetime,
					@Remarks nvarchar(255),
					@DocRef nVarchar(50) = N'',@Multiple INT = 0,@UserName nVarchar(100) = N'')
as
declare @DocumentID int
DECLARE @SalesmanID int
Declare @PreviousID Int
Declare @PrevID		Int

Set @PrevId = @Credit_no
/* First Cancel the Credit Note previously Entered basis the Creditid*/
Update CreditNote
Set
Status = Isnull(Status,0) | 128,
Balance = 0
Where CreditID = @Credit_no      

/* 	Get the Document ID for the cancelled document , for it has to be stored in the
	RefDocId field.This helps to identify easily to which document it refers to
*/

Select @Documentid = DocumentId from Creditnote where CreditID = @Credit_no

-- select @SalesmanID = ISNULL((select SalesmanID from Beat_Salesman where CustomerID = @PartyID), 0)

select @SalesmanID = ISNULL((select top 1 SalesmanID from Beat_Salesman   
where CustomerID = @PartyID And BeatID In   
(Select top 1 DefaultBeatID From customer Where CustomerID = @PartyID)), 0)    


if @PartyType = 0 
	insert into CreditNote (DocumentID,
				CustomerID,
				NoteValue,
				DocumentDate,
				Balance,
				Memo,
				SalesmanID,
				DocRef,
				RefDocid,AccountMode,UserName)
	values
			    (@DocumentID,
				@PartyID,
				@Value,
				@DocDate,
				@Value,
				@Remarks,
				@SalesmanID,
				@Docref,
				@PrevID,@Multiple,@UserName)	
else if @PartyType=1 
	insert into CreditNote (DocumentID,
				VendorID,
				NoteValue,
				DocumentDate,
				Balance,
				Memo,
				DocRef,
				RefDocid,AccountMode,UserName)
	values
			    (@DocumentID,
				@PartyID,
				@Value,
				@DocDate,
				@Value,
				@Remarks,
				@Docref,
				@PrevID,@Multiple,@UserName)	
else if @PartyType=2 
	insert into CreditNote (DocumentID,
				Others,
				NoteValue,
				DocumentDate,
				Balance,
				Memo,
				DocRef,
				RefDocid,AccountMode,UserName)
	values
			    (@DocumentID,
				@PartyID,
				@Value,
				@DocDate,
				@Value,
				@Remarks,
				@Docref,
				@PrevID,@Multiple,@UserName)	

select @DocumentID, @@IDENTITY
