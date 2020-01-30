





CREATE procedure sp_acc_fapayment(@paymentmode integer, @mode integer,@accountid integer,@value integer,@refnumber integer,@transactdate datetime,@narration nvarchar(255),@altmode integer,@docno integer,@doctype integer)
as
declare @documentid integer,@debit integer,@credit integer
DECLARE @CASH integer
DECLARE @CHEQUE integer
DECLARE @DD integer
DECLARE @CASHACCOUNT integer
DECLARE @POSTDATEDCHEQUEACCOUNT integer
DECLARE @PAYMENTS integer

set @debit =1
set @credit=2

SET @CASH=0
SET @CHEQUE =1
SET @DD =2

SET @CASHACCOUNT =3
SET @POSTDATEDCHEQUEACCOUNT=8

SET @PAYMENTS = 17

--set @doctype=26

if @altmode=1 
 begin 
  begin tran
   update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 24
   select @documentid = DocumentID - 1 from DocumentNumbers where DocType = 24
  commit tran    
 end
else
if @altmode >1
 begin
  set @documentid = @docno  
 end 

if @paymentmode = @CASH 
begin
	if @mode = @debit	
	begin
		insert GeneralJournal([TransactionID],[TransactionDate],[AccountID],[Debit],[Credit],
 		[DocumentReference],[DocumentType],[Remarks])
		values(@documentid,@transactdate,@accountid,@value,0,@refnumber,@PAYMENTS,@narration)
	end
	else if @mode=@credit
	begin
		insert GeneralJournal([TransactionID],[TransactionDate],[AccountID],[Debit],[Credit],
		[DocumentReference],[DocumentType],[Remarks])
		values(@documentid,@transactdate,@CASHACCOUNT,0,@value,@refnumber,@PAYMENTS,@narration)
	end 
end
select @documentid






