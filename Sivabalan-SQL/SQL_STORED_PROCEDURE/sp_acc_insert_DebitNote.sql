




Create procedure sp_acc_insert_DebitNote(@PartyType int,
					@PartyID nvarchar(15),
					@Value float,
					@DocDate datetime,
					@Remarks nvarchar(255),
					@Flag int = 0)
as
declare @DocumentID int
DECLARE @SalesmanID int

Declare @CUSTOMERACCOUNT Int,@OTHERACCOUNT Int,@EXPENSEACCOUNT Int
Set @CUSTOMERACCOUNT=0
Set @OTHERACCOUNT=1
Set @EXPENSEACCOUNT =9 --Bank Charges


begin tran
update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 11
select @DocumentID = DocumentID - 1 from DocumentNumbers where DocType = 11
commit tran
If @PartyType = 0
Begin
	select @SalesmanID = ISNULL((select SalesmanID from Beat_Salesman where CustomerID = @PartyID), 0)
	insert into DebitNote (DocumentID,
				CustomerID,
				NoteValue,
				DocumentDate,
				Balance,
				Memo,
				SalesmanID,
				AccountID,
				Flag)
	values
			       (@DocumentID,
				@PartyID,
				@Value,
				@DocDate,
				@Value,
				@Remarks,
				@SalesmanID,
				@EXPENSEACCOUNT,
				@Flag)	
End
Else If @PartyType=@OTHERACCOUNT
Begin
	insert into DebitNote (DocumentID,
				Others,
				NoteValue,
				DocumentDate,
				Balance,
				Memo,
				AccountID,
				Flag)
	values
			       (@DocumentID,
				@PartyID,
				@Value,
				@DocDate,
				@Value,
				@Remarks,
				@EXPENSEACCOUNT,
				@Flag)
End
select @DocumentID, @@Identity
SET QUOTED_IDENTIFIER OFF 














