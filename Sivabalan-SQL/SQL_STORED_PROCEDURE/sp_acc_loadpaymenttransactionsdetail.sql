





CREATE procedure sp_acc_loadpaymenttransactionsdetail(@paymentid integer)
as
DECLARE @paymentmode integer
DECLARE @fulldocid nvarchar(10)
DECLARE @documentdate datetime
DECLARE @accountname nvarchar(30)
DECLARE @accountid integer
DECLARE @value decimal(18,6)
DECLARE @bankid integer
DECLARE @chequenumber integer
DECLARE @chequedate datetime 
DECLARE @bankcode integer
DECLARE @branchcode integer
DECLARE @denominations nvarchar(2000)
DECLARE @documentid integer
DECLARE @chequeid integer
DECLARE @chequebookname nvarchar(50) 
DECLARE @accountno nvarchar(64)


select @documentid = DocumentID,@fulldocid= FullDocID,@documentdate= DocumentDate,@accountname = AccountName,@value = Value,@bankid = isnull([Payments].[BankID],0), 
@chequenumber = isnull(Cheque_Number,0),@chequedate = Cheque_Date,@bankcode = isnull([Payments].[BankCode],0),@branchcode = isnull(BranchCode,0),
@denominations = Denominations,@paymentmode=PaymentMode,@chequeid = isnull(Cheque_ID,0),@accountid =[Others]
from payments,AccountsMaster where [DocumentID]= @paymentid and [Payments].[Others]= [AccountsMaster].[AccountID]

create table #temppayments1(DocumentID integer,FullDocID nvarchar(10),PaymentDate datetime,
PaymentMode integer,AccountID integer,AccountName nvarchar(30),AmountPaid decimal(18,6),
AccountNo nvarchar(64),ChequeNo integer,ChequeDate datetime,BankCode integer,BranchCode integer,
Denominations nvarchar(2000),ChequeID integer,ChequeBookName nvarchar(30))


if @paymentmode = 0
begin
	insert into #temppayments1
	select @documentid,@fulldocid,@documentdate,@paymentmode,@accountid,@accountname,
	@value,0,0,null,0,0,@denominations,0,''
end
else if @paymentmode =1 
begin
	
	select @accountno = Account_Number from bank where [BankID]= @bankid 	
	
	select @chequebookname = Cheque_Book_Name from cheques where chequeid =@chequeid

	insert into #temppayments1
	select @documentid,@fulldocid,@documentdate,@paymentmode,@accountid,@accountname,
	@value,@accountno,@chequenumber,@chequedate,@bankcode,@branchcode,'',
	@chequeID,@chequebookname 
end 
else if @paymentmode =2
begin
	insert into #temppayments1
	select @documentid,@fulldocid,@documentdate,@paymentmode,@accountid,@accountname,
	@value,0,@chequenumber,@chequedate,@bankcode,@branchcode,'',
	@chequeID,@chequebookname 
end


insert into #temppayments1
select PaymentID,'',DocumentDate,0,Others,AccountName,AdjustedAmount,0,0,'',0,0,'',0,''
from PaymentDetail,AccountsMaster where [PaymentID]= @paymentid and [PaymentDetail].[Others] = [AccountsMaster].[AccountID] 

select * from #temppayments1
drop table  #temppayments1






