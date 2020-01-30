




CREATE procedure sp_acc_fapaymentadjustment(@documentdate datetime,@value decimal(18,6),
					    @balance decimal(18,6),@paymentmode integer,
					    @bankid integer,@chequenumber integer,@chequedate datetime,
					    @chequeid integer,@bankcode nvarchar(10),
					    @branchcode nvarchar(10),@denominations nvarchar(50),@otheraccount integer)
as
DECLARE @paymentprefix nvarchar(10)
DECLARE @paymentid nvarchar(10)
DECLARE @documentid integer
DECLARE @others integer
DECLARE @CASH integer
DECLARE @POSTDATEDCHEQUE integer


SET @CASH = 3
SET @POSTDATEDCHEQUE = 8   

select @paymentprefix = [Prefix] from voucherprefix 
where [TranID]=N'Payments'

 begin tran
  update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 13
  select @documentid = DocumentID - 1 from DocumentNumbers where DocType = 13
 commit tran

set @paymentid = @paymentprefix + cast(@documentid as nvarchar)

if @paymentmode=0
begin
	set @others = @otheraccount
end
else if @Paymentmode = 1 or @paymentmode = 2
begin
	if @documentdate = @chequedate	
	begin
		select @others = ISNULL([AccountID],0) from bank
		where [BankID]=@bankid
	end
 	else if @chequedate > @documentdate
	begin
		set @others = @POSTDATEDCHEQUE
	end
end

insert into payments(DocumentDate,
		Value,
		Balance,
		PaymentMode,
		BankID,
		Cheque_Number,
		Cheque_Date,
		FullDocID,
		Cheque_ID,
		BankCode,
		BranchCode,
		Others,
		Denominations)

values		(@documentdate,
		@value,
		@balance,
		@paymentmode,
		@bankid,
		@chequenumber,
		@chequedate,
		@paymentid,
		@chequeid,
		@bankcode,
		@branchcode,
		@others,
		@denominations)

select @@IDENTITY, @paymentid






