Create function mERP_FN_insertMJDifference_AmendmentDocs(@FD datetime,@TD datetime)    
Returns @temptable TABLE (TransactionID int,Voucher nvarchar(2000),VDate datetime,Ledgerfrom nvarchar(2000),DrAmount Decimal(18,4),CrAmount Decimal(18,4),Narration nvarchar(4000),Modify nvarchar(100),    
AdjRefNo nvarchar(4000),AdjReftype nvarchar(250),AdjAmount decimal(18,6))      
AS    
    
BEGIN    
Declare @FromDate datetime    
Declare @ToDate Datetime    
Set @FromDate=CAST(CONVERT(CHAR(10),@FD,102) as DateTime)    
set @ToDate =CAST(CONVERT(CHAR(10),@TD,102) as DateTime)    
    
Declare @TransactionID int    
Declare @OldRefValue decimal(18,6)    
Declare @NonOldRefValue decimal(18,6)    
Declare @Diff decimal(18,6)    
Declare @Accountid int    
declare @temp table (TransactionID int,AccountID int)    
    
    
Declare AllGJ Cursor For     
Select TransactionID from  GeneralJournal gj  where  (gj.DocumentType=26 or gj.DocumentType=37 or     
gj.DocumentType=34 or gj.DocumentType=32 or gj.DocumentType=28 or gj.DocumentType=81 or gj.DocumentType=35 or gj.DocumentType=29) and not (gj.DocumentReference = 2 and gj.DocumentType=37) and gj.status     
not in (128,192)  and  dbo.striptimefromdate(gj.TransactionDate)  >= @FromDate and  dbo.striptimefromdate(gj.TransactionDate)  <= @ToDate    
Open AllGJ    
 Fetch from AllGJ into @TransactionID    
 While @@fetch_status=0    
 BEGIN    
  /* Proceed further only if particular journal has Old Reference adjustment*/    
  If exists(select * from Generaljournal Where TransactionID = @TransactionID And DocumentReference=2)    
  BEGIN    
   insert into @temp Select @TransactionID,accountid from Generaljournal Where TransactionID = @TransactionID And DocumentReference=2    
  END     
  Fetch next from AllGJ into @TransactionID    
 END    
Close AllGJ    
DeAllocate ALLGJ    
    
    
/* Proceed further only if particular journal has Old Reference adjustment*/    
--If exists(select * from Generaljournal Where TransactionID = @TransactionID And DocumentReference=2)    
--BEGIN    
-- insert into @temp Select @TransactionID,accountid from Generaljournal Where TransactionID = @TransactionID And DocumentReference=2    
--END     
    
Declare AllAcc Cursor For    
Select distinct accountid,TransactionID from @temp    
open AllAcc    
 Fetch from AllAcc into @Accountid,@TransactionID    
 While @@fetch_status=0    
 BEGIN    
  /* If there is a difference between Debit and credit for old reference GJ then proceed further*/    
  if (select (sum(isnull(Debit,0))-sum(isnull(credit,0))) from  Generaljournal Where TransactionID = @TransactionID) <> 0    
  BEGIN    
   /* For Debit */    
   if (select sum(isnull(Debit,0)) from  Generaljournal Where TransactionID = @TransactionID and accountid=@Accountid and documentreference<>0)<> 0    
   BEGIN    
    /* Getting Old Ref. Value */    
    Select @OldRefValue=sum(isnull(debit,0)) from Generaljournal Where TransactionID = @TransactionID and accountid=@Accountid and DocumentReference=2    
    Select @NonOldRefValue=sum(isnull(debit,0)) from Generaljournal Where TransactionID = @TransactionID and accountid=@Accountid and DocumentReference<>2 and DocumentReference<>0    
    set @Diff = @OldRefValue - @NonOldRefValue    
    if @Diff <> 0    
    BEGIN    
     insert into @temptable     
     Select distinct @TransactionID,(Select Prefix From VoucherPrefix where TranID='MANUAL JOURNAL')+Rtrim(gj.DocumentNumber) +'-'+cast(gj.TransactionID as varchar(10)),    
     gj.TransactionDate,am.accountName,@Diff,0,Ltrim(Rtrim(gj.VoucherNo))+' '+Cast(gj.Remarks as Varchar(255)),case when (isnull(gj.Status,0) & 128 ) = 128 then 'yes' else '' end as 'Modify','','New Ref',0    
     from Generaljournal gj,AccountsMaster am  where  am.AccountID=gj.AccountID  and TransactionID = @TransactionID and gj.accountid=@Accountid    
    END    
   END    
   ELSE if (select sum(isnull(credit,0)) from  Generaljournal Where TransactionID = @TransactionID and accountid=@Accountid and documentreference<>0)<> 0    
   /* For Credit*/     
   BEGIN    
    Select @OldRefValue=sum(isnull(Credit,0)) from Generaljournal Where TransactionID = @TransactionID and accountid=@Accountid and DocumentReference=2    
    Select @NonOldRefValue=sum(isnull(Credit,0)) from Generaljournal Where TransactionID = @TransactionID and accountid=@Accountid and DocumentReference<>2 and DocumentReference<>0    
    set @Diff = @OldRefValue - @NonOldRefValue     
    if @Diff <> 0    
    BEGIN    
     insert into @temptable    
     Select distinct @TransactionID,(Select Prefix From VoucherPrefix where TranID='MANUAL JOURNAL')+Rtrim(gj.DocumentNumber) +'-'+cast(gj.TransactionID as varchar(10)),    
     gj.TransactionDate,am.accountName,0,@Diff,Ltrim(Rtrim(gj.VoucherNo))+' '+Cast(gj.Remarks as Varchar(255)),case when (isnull(gj.Status,0) & 128 ) = 128 then 'yes' else '' end as 'Modify','','New Ref',0    
     from Generaljournal gj,AccountsMaster am  where  am.AccountID=gj.AccountID  and TransactionID = @TransactionID and gj.accountid=@Accountid    
    END    
   END    
  END    
  Fetch next from AllAcc into @Accountid,@TransactionID    
 END    
 Close AllAcc    
 Deallocate AllAcc    
Return    
END    
