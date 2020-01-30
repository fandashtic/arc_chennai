CREATE procedure sp_acc_updatedeposits(@transactiontype integer,@depositdate datetime,    
           @creationdate datetime,@FullDocID nvarchar(10),    
           @accountid integer,@chequeno integer,@chequedate datetime,    
           @value decimal(18,6),@denominations nvarchar(50),    
           @staffid integer,@chequeid integer,@withdrawlmode integer,  
           @Narration nvarchar(2000) = NULL,@ToAccountId Int=0)     
as    
DECLARE @fulldocid1 nvarchar(50)    
DECLARE @Prefix nvarchar(30)    
DECLARE @documentid integer    
DECLARE @account integer    
DECLARE @PETTYCASH integer    
    
DECLARE @TOPETTYCASH integer    
DECLARE @FROMPETTYCASH integer    
DECLARE @ACCOUNT_TRANSFER INT    
    
SET @TOPETTYCASH = 3    
SET @FROMPETTYCASH = 4    
SET @ACCOUNT_TRANSFER = 6    
SET @PETTYCASH =4    
    
---if @accountid = @PETTYCASH    
if @transactiontype = @TOPETTYCASH or @transactiontype= @FROMPETTYCASH     
begin    
 set @account = @PETTYCASH    
end    
else     
begin    
 select @account = isnull([AccountID],0) from Bank     
 where [BankID]= @accountid    
end    
    
if @transactiontype = @ACCOUNT_TRANSFER    
begin    
 select @ToAccountId = isnull([AccountID],0) from Bank     
 where [BankID]= @ToAccountId    
end    
    
If (@transactiontype = 2 Or @transactiontype = @ACCOUNT_TRANSFER) and @withdrawlmode = 1     
Begin    
 update Cheques set LastIssued = @chequeno,UsedCheques = Isnull(UsedCheques, 0) + 1    
 where ChequeID = @chequeid    
End    
    
select @prefix = [Prefix] from voucherprefix where [TranID]=N'DEPOSITS'      
    
begin tran    
 update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 25    
commit tran    
select @documentid =[DocumentID]-1 from DocumentNumbers    
where [DocType]=25    
    
set @Fulldocid1 = @prefix + cast(@documentid as nvarchar)  
    
insert into Deposits(TransactionType,    
             DepositDate,    
      CreationDate,    
      FullDocID,    
      AccountID,    
      ChequeNo,    
      ChequeDate,    
      [Value],    
      Denominations,    
      StaffID,    
      ChequeID,    
      WithdrawlType,    
      ToAccountID,  
      Narration)    
     values(@transactiontype,    
     @depositdate,    
     @creationdate,    
--     @fulldocid,    
     @Fulldocid1,
     @account,    
     @chequeno,    
     @chequedate,    
     @value,    
     @denominations,    
     @staffid,    
     @chequeid,    
     @withdrawlmode,    
     @ToAccountId,  
     @Narration)    
        
select @@identity,@fulldocid1   


