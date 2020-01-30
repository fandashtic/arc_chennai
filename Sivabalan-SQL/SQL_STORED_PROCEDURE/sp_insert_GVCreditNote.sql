CREATE procedure sp_insert_GVCreditNote
(
@LoyaltyID nVarchar(255),
@PartyID nvarchar(50),
@GVNo nVarchar(255),
@Value float,
@DocDate datetime,
@Remarks nvarchar(255),
@SalesmanID int,
@GVCollectedOn datetime,
@Flag INT = 2
)
as

Declare @DocumentID int
begin tran
update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 70
select @DocumentID = DocumentID - 1 from DocumentNumbers where DocType = 70
commit tran

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
				flag )
	values
			    (@DocumentID,
				 @LoyaltyID,
				@PartyID,
				@GVNo, 
				@Value,
				@DocDate,
				@Value,
				@Remarks,
				@SalesmanID,
				@GVCollectedOn, @Flag)	
select @DocumentID, @@IDENTITY
