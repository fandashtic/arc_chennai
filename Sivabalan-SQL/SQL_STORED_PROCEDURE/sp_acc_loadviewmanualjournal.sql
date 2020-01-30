
CREATE Procedure sp_acc_loadviewmanualjournal(@dfromdate datetime,@dtodate datetime,@accountid integer,@mode integer)
as
declare @transactionid integer,@all integer,@specific integer
set @all=1
set @specific =2
if @mode= @specific
 begin
  select [GeneralJournal].[TransactionID],[GeneralJournal].[TransactionDate],[GeneralJournal].[AccountID],[GeneralJournal].[Debit],[GeneralJournal].[Credit],[GeneralJournal].[DocumentReference],[GeneralJournal].[DocumentType],
  [GeneralJournal].[Status],[GeneralJournal].[ReferenceNumber],[GeneralJournal].[Remarks],[AccountsMaster].[AccountName],[DocumentNumber],'VoucherNo'=isnull(VoucherNo,0) 
  from [GeneralJournal],[AccountsMaster] where [GeneralJournal].[AccountID]=[AccountsMaster].[AccountID] and [TransactionID] in (Select [TransactionID]from generaljournal where (dbo.stripdatefromtime([TransactionDate])between @dfromdate 
  and @dtodate) and ([AccountID]=@accountid)) and [DocumentType] in (26,37) order by TransactionID
 end
else
if @mode =@all
 begin
  select [GeneralJournal].[TransactionID],[GeneralJournal].[TransactionDate],[GeneralJournal].[AccountID],[GeneralJournal].[Debit],[GeneralJournal].[Credit],[GeneralJournal].[DocumentReference],[GeneralJournal].[DocumentType],
  [GeneralJournal].[Status],[GeneralJournal].[ReferenceNumber],[GeneralJournal].[Remarks],
  [AccountsMaster].[AccountName],[DocumentNumber],'VoucherNo'=isnull(VoucherNo,0)  from [GeneralJournal],[AccountsMaster] where [GeneralJournal].[AccountID]=[AccountsMaster].[AccountID] and dbo.stripdatefromtime([TransactionDate])between @dfromdate
  and @dtodate and [DocumentType]in (26,37) order by TransactionID

   /*  select [GeneralJournal].[TransactionID],[GeneralJournal].[TransactionDate],[GeneralJournal].[AccountID],[GeneralJournal].[Debit],[GeneralJournal].[Credit],[GeneralJournal].[DocumentReference],[GeneralJournal].[DocumentType],
   [GeneralJournal].[Status],[GeneralJournal].[ReferenceNumber],[GeneralJournal].[Remarks],
   [AccountsMaster].[AccountName]from [GeneralJournal],[AccountsMaster] where [GeneralJournal].[AccountID]=[AccountsMaster].[AccountID] and [TransactionID] in (Select [TransactionID]from generaljournal where (dbo.stripdatefromtime([TransactionDate]) >=@df






rom
   date 
   and dbo.stripdatefromtime([TransactionDate])<=@dtodate)
   and ([DocumentType]=26) and (isnull([Status],0)<>128 and isnull([Status],0)<>192)) */
 end
















