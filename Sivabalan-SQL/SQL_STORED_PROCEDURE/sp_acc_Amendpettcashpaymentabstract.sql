CREATE Procedure sp_acc_Amendpettcashpaymentabstract(@documentdate datetime,@value decimal(18,6),
					    @balance decimal(18,6),@otheraccount integer,@remarks nvarchar(4000),
						@expenseaccount integer,@MultipleACImpl Int,@PreviousID Int)
as
DECLARE @paymentprefix nvarchar(10)
DECLARE @paymentid nvarchar(10)
DECLARE @documentid integer
DECLARE @others integer

select @paymentprefix = [Prefix] from voucherprefix 
where [TranID]= N'PETTY CASH'

Set @paymentid = N''
Select @paymentid = Isnull(FullDocID,N'') from Payments where DocumentID = @PreviousID
If @paymentid = N''
Begin
	begin tran
		update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 55
		select @documentid = DocumentID - 1 from DocumentNumbers where DocType = 55
	commit tran
	set @paymentid = @paymentprefix + cast(@documentid as nvarchar)
End
Update Payments Set Status = 128 where documentID = @PreviousID
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
	AccountMode,
	RefDocID)

values(@documentdate,
	@value,
	@balance,
	@paymentid,
	@remarks,
	5,
	@otheraccount,
	@expenseaccount,
	@AccountMode,
	@PreviousID)

select @@IDENTITY, @paymentid



