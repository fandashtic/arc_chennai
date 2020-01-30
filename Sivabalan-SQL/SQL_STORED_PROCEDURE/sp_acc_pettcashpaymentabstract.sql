CREATE Procedure sp_acc_pettcashpaymentabstract(@documentdate datetime,@value decimal(18,6),
					    @balance decimal(18,6),@otheraccount integer,@remarks nvarchar(4000),
						@expenseaccount integer,@MultipleACImpl Integer = 0)
as
DECLARE @paymentprefix nvarchar(10)
DECLARE @paymentid nvarchar(10)
DECLARE @documentid integer
DECLARE @others integer

select @paymentprefix = [Prefix] from voucherprefix 
where [TranID]=N'PETTY CASH'

begin tran
 update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 55
 select @documentid = DocumentID - 1 from DocumentNumbers where DocType = 55
commit tran

set @paymentid = @paymentprefix + cast(@documentid as nvarchar)

If @MultipleACImpl = 0 /* Old Implementation */
Begin
	insert into payments(DocumentDate,
		Value,
		Balance,
		FullDocID,
		Others,
		Narration,
		ExpenseAccount)

	values(@documentdate,
		@value,
		@balance,
		@paymentid,
		@otheraccount,
		@remarks,
		@expenseaccount)
End
Else
Begin
	/*
	@MultipleACImpl = 1 - multiple exp a/c impl with one expense a/c 
	@MultipleACImpl > 1 - multiple exp a/c impl with one/more expense a/c's 
	*/
	Declare @AccountMode Int
	If @MultipleACImpl > 1
	Begin
		Set @AccountMode = 1
	End
	Else
	Begin
		Set @AccountMode = 0
	End

	insert into payments(DocumentDate,
		Value,
		Balance,
		FullDocID,
		Narration,
		PaymentMode,
		Others,
		ExpenseAccount,
		AccountMode)

	values(@documentdate,
		@value,
		@balance,
		@paymentid,
		@remarks,
		5,
		@otheraccount,
		@expenseaccount,
		@AccountMode)
End

select @@IDENTITY, @paymentid


