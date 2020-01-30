CREATE procedure sp_acc_amend_GVCreditNote_ITC(
@Credit_no as int,
@LoyaltyID nVarchar(255),
@PartyID nvarchar(50),
@GVNo nVarchar(255),
@Value float,
@DocDate datetime,
@Remarks nvarchar(255),
@SalesmanID int,
@GVCollectedOn datetime,
@Flag INT = 2)
as
declare @DocumentID int
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

insert into CreditNote (DocumentID,
				LoyaltyID,
				CustomerID,
				GiftVoucherNo, 
				NoteValue,
				DocumentDate,
				Balance,
				Memo,
				SalesmanID,
				GVCollectedOn,
				Flag, RefDocid)
	values
			    (@DocumentID,
				 @LoyaltyID,
				@PartyID,
				@GVNo, 
				@Value,
				@DocDate,
				@Value,
				@Remarks,
				@SalesmanID, @GVCollectedOn,
				@Flag, @PrevId)	
select @DocumentID, @@IDENTITY
