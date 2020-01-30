CREATE procedure sp_Insert_CLOCreditNote 
(
	@CLOCrID Int,
	@DocDate DateTime  
)
as

Declare @DocumentID int

Declare @LoyaltyID nVarchar(256) 
Declare @PartyID nvarchar(256)
Declare @Value float
Declare @Remarks nvarchar(256)
Declare @CrNoteID As Int 
Declare @CrAccountID Int 
--Declare @SalesmanID int

begin tran
update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 70
select @DocumentID = DocumentID - 1 from DocumentNumbers where DocType = 70
commit tran

Select @LoyaltyID = ly.LoyaltyID, @PartyID = clocr.CustomerID, @Value = clocr.Amount, 
	@Remarks = clocr.CLOType + '-' + SubString(DateName(mm, clocr.CLODate), 1, 3) + '-' + DateName(YYYY, clocr.CLODate) 
From CLOCrNote clocr, Loyalty ly 
Where clocr.CLOType = ly.Loyaltyname And 
	clocr.ID = @CLOCrID 

--Select Top 1 @SalesmanID= SalesmanID from beat_salesman where customerID=@PartyID and beatID
--in (Select defaultbeatid from customer where CustomerID=@PartyID)

Select @CrAccountID = AccountID From AccountsMaster Where AccountName Like 'Secondary Scheme Expense' 
 

--Select SubString(DateName(mm, GetDate()), 1, 3)

insert into CreditNote (DocumentID,
				LoyaltyID,
				CustomerID,
				NoteValue,
				DocumentDate,
				Balance,
				Memo,
				GVCollectedOn,
				flag)
	values
			    (@DocumentID,
				 @LoyaltyID,
				 @PartyID,
				 @Value,
				 @DocDate,
				 @Value,
				 @Remarks,
				 @DocDate, 
				 1)	

Select @CrNoteID = @@IDENTITY

Update CLOCrNote Set CreditID = @CrNoteID, ActivityCode = @Remarks, IsGenerated = 1 
Where ID = @CLOCrID
 

Select @DocumentID, @CrNoteID, @CrAccountID 

