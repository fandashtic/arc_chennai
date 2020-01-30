CREATE procedure sp_acc_loadcontradetail(@contraid integer)  
as   
DECLARE @fulldocid nvarchar(10)  
DECLARE @depositdate datetime  
DECLARE @transactiontype integer  
DECLARE @value decimal(18,6)  
DECLARE @accountid integer  
DECLARE @chequedate datetime  
DECLARE @chequenumber integer  
DECLARE @denominations nvarchar(50)  
DECLARE @staffid integer  
DECLARE @bankcode nvarchar(50)  
DECLARE @branchcode nvarchar(50)  
DECLARE @accountnumber nvarchar(128)   
DECLARE @chequeid integer  
DECLARE @chequebookname nvarchar(50)  
Declare @withdrawltype integer  
Declare @bankid integer  
Declare @status integer  
DECLARE @ToAccountId int  
DECLARE @ToBankId Int  
DECLARE @ToAccountNumber nvarchar(128)  
DECLARE @ToBankCode nvarchar(50)  
DECLARE @ToBranchCode nvarchar(50)  
DECLARE @Narration nVarchar(2000)
  
DECLARE @CASH integer  
DECLARE @CASHDEPOSIT integer  
DECLARE @CASHWIDTHDRAWL integer  
DECLARE @TOPETTYCASH integer  
DECLARE @FROMPETTYCASH integer  
DECLARE @ACCOUNT_TRANSFER INT  
  
SET @CASH = 3  
SET @CASHDEPOSIT =1  
SET @CASHWIDTHDRAWL =2  
SET @TOPETTYCASH =3  
SET @FROMPETTYCASH =4  
SET @ACCOUNT_TRANSFER=6  
  
select @fulldocid = FullDocID,@depositdate = DepositDate,@transactiontype = TransactionType,  
@value = Value,@accountid = AccountID,@chequedate =ChequeDate,@chequenumber = ChequeNo,  
@denominations = [Denominations],@staffid = StaffID,@chequeid = ChequeID,@withdrawltype=isnull(WithdrawlType,0),  
@status = isnull(Status,0),@ToAccountId = isnull(ToAccountID,0),@Narration = IsNull(Narration, N'')  
from Deposits where [DepositID]=@contraid  
  
if @transactiontype = @CASHDEPOSIT  
begin  
 select @accountnumber =Account_Number, @bankcode = [BankCode],  
 @branchcode = [BranchCode] from Bank where [AccountID]=@accountid  
    
 select @fulldocid,@depositdate,@transactiontype,@value,  
 @accountid,@accountnumber,@bankcode,@branchcode,null,null,@denominations,  
 @staffid,@chequeid,null,@withdrawltype,0,'Status'= @status,'Narration' = @Narration   
end   
else if @transactiontype = @CASHWIDTHDRAWL  
begin  
 select @bankid= [BankID], @accountnumber =Account_Number, @bankcode = [BankCode],  
 @branchcode = [BranchCode] from Bank where [AccountID]=@accountid  
    
 select @chequebookname = Cheque_Book_Name from Cheques  
 where ChequeID =@chequeid  
   
 select @fulldocid,@depositdate,@transactiontype,@value,  
 @accountid,@accountnumber,@bankcode,@branchcode,@chequedate,  
 @chequenumber,@denominations,@staffid,@chequeid,@chequebookname,  
 @withdrawltype,@bankid,'Status'= @status,'Narration' = @Narration
end  
else if @transactiontype = @TOPETTYCASH  
begin  
 select @fulldocid,@depositdate,@transactiontype,@value,  
 @accountid,null,null,null,null,null,@denominations,  
 @staffid,@chequeid,null,@withdrawltype,0,'Status'= @status,'Narration' = @Narration
end  
else if @transactiontype = @FROMPETTYCASH  
begin  
 select @fulldocid,@depositdate,@transactiontype,@value,  
 @accountid,null,null,null,null,null,@denominations,  
 @staffid,@chequeid,null,@withdrawltype,0,'Status'= @status,'Narration' = @Narration
end  
else if @transactiontype = @ACCOUNT_TRANSFER  
begin  
 select @bankid= [BankID], @accountnumber =Account_Number, @bankcode = [BankCode],  
 @branchcode = [BranchCode] from Bank where [AccountID]=@accountid  
   
 select @ToBankId= [BankID], @ToAccountNumber =Account_Number, @ToBankCode = [BankCode],  
 @ToBranchCode = [BranchCode] from Bank where [AccountID]=@ToAccountId  
    
 select @chequebookname = Cheque_Book_Name from Cheques  
 where ChequeID =@chequeid  
   
 select @fulldocid,@depositdate,@transactiontype-1,@value,  
 @accountid,@accountnumber,@bankcode,@branchcode,@chequedate,  
 @chequenumber,@denominations,@staffid,@chequeid,@chequebookname,  
 @withdrawltype,@bankid,'Status'= @status,@ToAccountId,@ToAccountNumber,@ToBankCode,  
 @ToBranchCode,@ToBankId,'Narration' = @Narration  
end 
