CREATE procedure sp_acc_amendjournalnew(@ntransactionid integer,@mode integer,@accountid integer,
@value decimal(18,6),@refnumber integer,@transactdate datetime,@narration nvarchar(255),@altmode integer,@docno integer,@doctype integer,@altid integer,
@voucherno nvarchar(50)=N'')
as
declare @documentid integer,@debit integer,@credit integer
declare @uniqueid integer
declare @currentdate datetime 
declare @BackDatedDate datetime
declare @PrevAccountID Integer
-- -- set @currentdate = dbo.stripdatefromtime(getdate())
set @currentdate = dbo.stripdatefromtime(dbo.Sp_Acc_GetOperatingDate(getdate()))

update [GeneralJournal] set [Status]= 128 where [TransactionID]=@ntransactionid

Select Top 1 @BackDatedDate =  dbo.stripdatefromtime(TransactionDate) from GeneralJournal Where TransactionID = @ntransactionid

set @debit =1
set @credit=2

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
  set @uniqueid = @altid
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

  If dbo.stripdatefromtime(@TransactDate) < @BackDatedDate
   Begin
    Set @BackDatedDate = @TransactDate
   End

  if dbo.stripdatefromtime(@BackDatedDate) < @currentdate
  begin
		Declare ScanManualJournal Cursor keyset for
		Select AccountID from GeneralJournal where
		TransactionID = @ntransactionid
		Open ScanManualJournal
		Fetch From ScanManualJournal Into @PrevAccountID
		While @@FETCH_STATUS = 0 
		Begin
			Exec sp_acc_backdatedaccountopeningbalance @BackDatedDate,@PrevAccountID
			Fetch Next From ScanManualJournal Into @PrevAccountID
		End
		Close ScanManualJournal
		Deallocate ScanManualJournal 
		Exec sp_acc_backdatedaccountopeningbalance @BackDatedDate,@AccountID
  end
  select @documentid,@uniqueid

