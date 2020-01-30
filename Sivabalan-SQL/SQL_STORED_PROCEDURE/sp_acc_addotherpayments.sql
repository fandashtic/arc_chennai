CREATE procedure sp_acc_addotherpayments(@documentdate datetime,@value decimal(18,6),    
@balance decimal(18,6),@paymentmode int,@bankid int,@chequenumber int,@chequedate datetime,    
@chequeid int,@bankcode nvarchar(50),@branchcode nvarchar(50),@others int,@expenseaccount int,    
@denominations nvarchar(4000),@Narration nvarchar(4000) = NULL,@DocRef nVarchar(100) = NULL,@DocSerialType nvarchar(100) = NULL,
@DDMode Int = 0,@DDCharges Decimal(18,6) = 0,@DDChequeNumber Int = 0,@DDChequeDate DateTime = NULL,    
@DDDetails nvarchar(128) = N'',@PayableTo nvarchar(255) = N'',@Bank_Txn_code nVarchar(400) = N'')    
as    
Declare @documentid int    
Declare @prefix nvarchar(20)    
    
select @prefix = Prefix from VoucherPrefix     
where TranID = N'FA PAYMENTS'     
    
begin tran    
 update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 56    
 select @documentid = DocumentID - 1 from DocumentNumbers where DocType = 56    
commit tran    
    
set @prefix = @prefix + cast(@documentid as nvarchar(20))    
    
if @PaymentMode = 1 and @ChequeID <> 0    
begin    
 update Cheques set LastIssued = @ChequeNumber,UsedCheques = Isnull(UsedCheques, 0) + 1    
 where ChequeID = @chequeid    
end    
else if @PaymentMode = 2 and @DDMode = 1 and @ChequeID <> 0    
begin    
 update Cheques set LastIssued = @DDChequeNumber,UsedCheques = Isnull(UsedCheques, 0) + 1    
 where ChequeID = @chequeid    
end     
    
insert Payments ( DocumentDate,    
    Value,    
    Balance,    
    PaymentMode,    
    BankID,    
    Cheque_Number,    
    Cheque_Date,    
    Cheque_ID,    
    BankCode,    
    BranchCode,    
    CreationTime,
    Others,    
    ExpenseAccount,    
    Denominations,    
    Narration,    
    FullDocID,    
    DDMode,    
    DDCharges,    
    DDChequeNumber,    
    DDChequeDate,    
    DDDetails,    
    PayableTo,    
    DocRef,    
    DocSerialType,
	Memo)    
  values ( @documentdate,    
    @value,    
    @balance,     
    @paymentmode,    
    @bankid,    
    @chequenumber,    
    @chequedate,    
    @chequeid,    
    @bankcode,    
    @branchcode,    
    dbo.Sp_Acc_GetOperatingDate(getdate()),    
    @others,    
    @expenseaccount,    
    @denominations,    
    @Narration,    
    @prefix,    
    @DDMode,    
    @DDCharges,    
    @DDChequeNumber,    
    @DDChequeDate,    
    @DDDetails,    
    @PayableTo,    
    @DocRef,    
    @DocSerialType,
	@Bank_Txn_code)    
Select @@identity,@prefix 


