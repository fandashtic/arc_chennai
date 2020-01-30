CREATE procedure sp_amend_CreditNote(@Credit_no as int,	@PartyType int,
					@PartyID nvarchar(15),
					@Value Decimal(18,6),
					@DocDate datetime,
					@Remarks nvarchar(255),
					@DocRef nvarchar(50) = N'')
as
declare @DocumentID int
DECLARE @SalesmanID int
Declare @PrevID  Int  
  
Set @PrevId = @Credit_no  
/* First Cancel the Credit Note previously Entered basis the Creditid*/  
Update CreditNote  
Set  
Status = Isnull(Status,0) | 128,  
Balance = 0  
Where CreditID = @Credit_no        
  
/*  Get the Document ID for the cancelled document , for it has to be stored in the  
 RefDocId field.This helps to identify easily to which document it refers to  
*/  
  
Select @Documentid = DocumentId from Creditnote where CreditID = @Credit_no  

select @SalesmanID = ISNULL((select SalesmanID from Beat_Salesman where CustomerID = @PartyID), 0)

if @PartyType = 0 
	insert into CreditNote (DocumentID,
				CustomerID,
				NoteValue,
				DocumentDate,
				Balance,
				Memo,
				SalesmanID,
				DocRef,RefDocid)
	values
			       (@DocumentID,
				@PartyID,
				@Value,
				@DocDate,
				@Value,
				@Remarks,
				@SalesmanID,
				@DocRef,@PrevID)	
else
	insert into CreditNote (DocumentID,
				VendorID,
				NoteValue,
				DocumentDate,
				Balance,
				Memo,
				DocRef,RefDocid)
	values
			       (@DocumentID,
				@PartyID,
				@Value,
				@DocDate,
				@Value,
				@Remarks,
				@DocRef,@PrevID)	
select @DocumentID, @@IDENTITY

