CREATE procedure sp_acc_amendjournal(@ntransactionid integer,@mode integer,@accountid integer,
@value decimal(18,6),@refnumber integer,@transactdate datetime,@narration nvarchar(255),
@altmode integer,@docno integer,@altid integer,@voucherno nvarchar(255)=N'')
as
declare @documentid integer,@debit integer,@credit integer,@doctype integer 
declare @uniqueid integer
declare @currentdate datetime 

set @currentdate = dbo.stripdatefromtime(dbo.Sp_Acc_GetOperatingDate(getdate()))

update [GeneralJournal] set [Status]= 128 where [TransactionID]=@ntransactionid

set @debit =1
set @credit=2
set @doctype=26

if @altmode=1 
 begin 
  begin tran
   update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 24
   select @documentid = DocumentID - 1 from DocumentNumbers where DocType = 24
  commit tran    

  begin tran
   update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 52
   select @uniqueid = DocumentID - 1 from DocumentNumbers where DocType = 52
  commit tran    
 end
else
if @altmode >1
 begin
  set @documentid = @docno  
  set @uniqueid =@altid
 end 

 if @mode = @debit	
  begin
    insert GeneralJournal([TransactionID],[TransactionDate],[AccountID],[Debit],[Credit],
 		       [DocumentReference],[DocumentType],[Remarks],[ReferenceNumber],[DocumentNumber],VoucherNo)
    values(@documentid,@transactdate,@accountid,@value,0,@refnumber,@doctype,@narration,@ntransactionid,@uniqueid,@voucherno)
  end
 else
 if @mode=@credit
  begin
   insert GeneralJournal([TransactionID],[TransactionDate],[AccountID],[Debit],[Credit],
		       [DocumentReference],[DocumentType],[Remarks],[ReferenceNumber],[DocumentNumber],VoucherNo)
   values(@documentid,@transactdate,@accountid,0,@value,@refnumber,@doctype,@narration,@ntransactionid,@uniqueid,@voucherno)
  end 
 
  if dbo.stripdatefromtime(@transactdate) < @currentdate
  begin
  	Exec sp_acc_backdatedaccountopeningbalance @transactdate,@accountid
  end  
  select @documentid,@uniqueid

