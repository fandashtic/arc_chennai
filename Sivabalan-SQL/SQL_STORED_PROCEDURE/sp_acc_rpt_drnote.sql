CREATE procedure sp_acc_rpt_drnote(@FromDate datetime, @ToDate datetime)    
as    
Declare @DOCTYPE INT,@NEXTLEVEL INT,@LASTLEVEL INT,@ROWCOUNT Int    
DECLARE @OLDIMPL INT

If Not Exists (Select * from FAReportData Where ParentID = 22)/*(ParentID)22 = DebitNote Report*/
 Begin
  /*@OLDIMPL=1 implies there is no detail record for the DebitNote Report, So Drilldown has to be disabled.*/
  Set @OLDIMPL = 1
 End

SET @DOCTYPE=20 --DebitNote Type    
SET @LASTLEVEL=1 --No NextLevel    

If @OLDIMPL = 1 
 Set @NEXTLEVEL=0
Else
 SET @NEXTLEVEL=26    

Declare @AccountCredited Int,@DebitID Int     
Declare @GroupID Int    
  
Declare @ToDatePair datetime  
Set @ToDatePair = DateAdd(s, 0-1, DateAdd(dd, 1, @todate))  
    
Create table #Temp(DocumentID nvarchar(25),DocumentDate datetime,Type nvarchar(25),    
AccountDebited nvarchar(255),Value decimal(18,6),AccountCredited nvarchar(255),    
Remarks nvarchar(2500),Status nVarchar(25),DebitID Int,DocType Int,    
AccountCreditedID Int,AccountDebitedID Int,NextLevel Int)    
Insert #Temp    
    
select "Document ID"=VoucherPrefix.Prefix + cast(DebitNote.DocumentID as nvarchar),    
"Document Date" = dbo.StripDateFromTime(DocumentDate),dbo.LookupDictionaryItem('Customer',Default),    
"Account Debited"=Customer.Company_Name, NoteValue,    
"Account Credited"=Case When IsNull(DebitNote.AccountID,0) = 0 Then dbo.LookupDictionaryItem('Opening Balance Entry',Default) Else    
dbo.getaccountname(IsNull(DebitNote.AccountID,0)) End,Memo,    
case 
	when IsNull(Status,0) & 64 <> 0 then dbo.LookupDictionaryItem('Cancelled',Default) 
 	when isnull(status & 128,0 ) = 128 and isnull(RefDocid,0) <> 0 then dbo.LookupDictionaryItem('Amended',Default)    
 	when isnull(status & 128,0 ) = 128 and isnull(RefDocid,0) = 0  then dbo.LookupDictionaryItem('Amended',Default)    
 	when isnull(status & 128,0 ) = 0 and isnull(RefDocid,0) <> 0  then dbo.LookupDictionaryItem('Open',Default)    
	When isnull(status,0) = 0 and Balance = 0 and isnull(RefDocid,0) = 0 then dbo.LookupDictionaryItem('Closed',Default)
	When isnull(status,0) = 0 and Balance > 0 and isnull(RefDocid,0) = 0 then dbo.LookupDictionaryItem('Open',Default)
end, 
DebitID, @DocType,    
0,0,@NEXTLEVEL    
from DebitNote, VoucherPrefix, Customer    
where DebitNote.CustomerID is not null and DebitNote.CustomerID = Customer.CustomerID and    
DebitNote.DocumentDate between @FromDate and @ToDatePair    
and VoucherPrefix.TranID = N'DEBIT NOTE' order by DocumentDate    
-- -- -- case 
-- -- -- 	when (IsNull(Status,0) & 64) <> 0 then 'Cancelled' 
-- -- -- 	else    
-- -- -- 		case 
-- -- -- 			when Balance > 0 then 'Open' 
-- -- -- 			else 'Closed' 
-- -- -- 	end 
-- -- -- end, 
    
Set @ROWCOUNT=(Select count(*) from #Temp where Type=dbo.LookupDictionaryItem('Customer',Default))    
If @ROWCOUNT >0    
Begin    
 Insert #Temp    
 Select '',@Todate,'','Total Value:',sum(Value),'','','','','',0,0,@LASTLEVEL from #Temp where Type=dbo.LookupDictionaryItem('Customer',Default)    
 Insert #Temp    
 Select '','','','',Null,'','','','','',0,0,''     
End    
    
Insert #Temp    
select VoucherPrefix.Prefix + cast(DebitNote.DocumentID as nvarchar),    
dbo.StripDateFromTime(DocumentDate),dbo.LookupDictionaryItem('Vendor',Default), Vendors.Vendor_Name, NoteValue,     
"Account Debited" = Case When IsNull(DebitNote.AccountID,0) = 0 Then dbo.LookupDictionaryItem('Opening Balance Entry',Default)    
Else dbo.getaccountname(IsNull(DebitNote.AccountID,0)) End,    
Memo, 
case 
	when IsNull(Status,0) & 64 <> 0 then dbo.LookupDictionaryItem('Cancelled',Default) 
 	when isnull(status & 128,0 ) = 128 and isnull(RefDocid,0) <> 0 then dbo.LookupDictionaryItem('Amended',Default)    
 	when isnull(status & 128,0 ) = 128 and isnull(RefDocid,0) = 0  then dbo.LookupDictionaryItem('Amended',Default)    
 	when isnull(status & 128,0 ) = 0 and isnull(RefDocid,0) <> 0  then dbo.LookupDictionaryItem('Open',Default)    
	When isnull(status,0) = 0 and Balance = 0 and isnull(RefDocid,0) = 0 then dbo.LookupDictionaryItem('Closed',Default)
	When isnull(status,0) = 0 and Balance > 0 and isnull(RefDocid,0) = 0 then dbo.LookupDictionaryItem('Open',Default)
end,    
DebitID, @DocType,0,0,@NEXTLEVEL    
from DebitNote, VoucherPrefix, Vendors    
where DebitNote.VendorID is not null and DebitNote.VendorID = Vendors.VendorID and    
DebitNote.DocumentDate between @FromDate and @ToDatePair    
and VoucherPrefix.TranID = N'DEBIT NOTE' order by DocumentDate    
-- -- -- case 
-- -- -- 	when (IsNull(Status,0) & 64) <> 0 then 'Cancelled' 
-- -- -- 	else    
-- -- -- 		case 
-- -- -- 			when Balance > 0 then 'Open' 
-- -- -- 			else 'Closed' 
-- -- -- 		end 
-- -- -- end,    
    
Set @ROWCOUNT=(Select count(*) from #Temp where Type=dbo.LookupDictionaryItem('Vendor',Default))    
If @ROWCOUNT >0    
Begin    
 Insert #Temp    
 Select '',@Todate,'','Total Value:',sum(Value),'','','','','',0,0,@LASTLEVEL from #Temp where Type=dbo.LookupDictionaryItem('Vendor',Default)    
 Insert #Temp    
 Select '','','','',Null,'','','','','',0,0,@LASTLEVEL    
--  Insert #Temp    
--  Select '',@Todate,'','Net Value:',sum(Value),'','','','','',@LASTLEVEL from #Temp where DocumentID =''    
End    
    
Insert #Temp    
select VoucherPrefix.Prefix + cast(DebitNote.DocumentID as nvarchar), dbo.StripDateFromTime(DocumentDate),    
dbo.LookupDictionaryItem('Others',Default),dbo.getaccountname(IsNull(Others,0)), NoteValue, dbo.getaccountname(IsNull(AccountID,0)), Memo,    
case 
	when IsNull(Status,0) & 64 <> 0 then dbo.LookupDictionaryItem('Cancelled',Default) 
 	when isnull(status & 128,0 ) = 128 and isnull(RefDocid,0) <> 0 then dbo.LookupDictionaryItem('Amended',Default)    
 	when isnull(status & 128,0 ) = 128 and isnull(RefDocid,0) = 0  then dbo.LookupDictionaryItem('Amended',Default)    
 	when isnull(status & 128,0 ) = 0 and isnull(RefDocid,0) <> 0  then dbo.LookupDictionaryItem('Open',Default)    
	When isnull(status,0) = 0 and Balance = 0 and isnull(RefDocid,0) = 0 then dbo.LookupDictionaryItem('Closed',Default)
	When isnull(status,0) = 0 and Balance > 0 and isnull(RefDocid,0) = 0 then dbo.LookupDictionaryItem('Open',Default)
end, 
DebitID, @DocType,    
IsNull(Others,0),IsNull(AccountID,0),@NEXTLEVEL    
from DebitNote, VoucherPrefix    
where IsNull(DebitNote.Others,0)<> 0 and  -- DebitNote.others =  A.AccountID and    
DebitNote.DocumentDate between @FromDate and @ToDatePair     
and VoucherPrefix.TranID = N'DEBIT NOTE'     
--and B.AccountID=DebitNote.AccountID and A.Active=1    
order by DocumentDate    
-- -- -- case 
-- -- -- 	when (IsNull(Status,0) & 64) <> 0 then 'Cancelled' 
-- -- -- 	else    
-- -- -- 		case 
-- -- -- 			when Balance > 0 then 'Open' 
-- -- -- 			else 'Closed' 
-- -- -- 		end 
-- -- -- end, 
    
Declare scancreditnote Cursor KeySet For    
Select AccountCreditedID,DebitID from #Temp 
where Type = dbo.LookupDictionaryItem('Others',Default) and IsNull(AccountDebitedID,0) = 0     
    
Open scancreditnote    
Fetch From scancreditnote into @AccountCredited,@DebitID    
While @@Fetch_Status = 0    
Begin    
 Select @GroupID = GroupID from AccountsMaster Where AccountID = @AccountCredited    
     
 Declare @GroupID1 int    
 Declare @GroupName1 nvarchar(255)    
 Create Table #tempgroup(GroupID int,GroupName nvarchar(255))    
     
 Insert into #tempgroup select GroupID,GroupName From AccountGroup    
 Where ParentGroup in (48,49)    
    
 Declare Parent Cursor Static For    
 Select GroupID,GroupName From #tempgroup     
 Open Parent    
 Fetch From Parent Into @GroupID1,@GroupName1    
 While @@Fetch_Status = 0    
 Begin    
  Insert into #tempgroup     
  Select GroupID,GroupName From AccountGroup    
  Where ParentGroup = @GroupID    
  Fetch Next From Parent Into @GroupID1,@GroupName1     
 End    
 Close Parent    
 DeAllocate Parent    
 Insert into #tempgroup    
 select GroupID,GroupName From AccountGroup    
 Where GroupID in (48,49)    
     
 if exists(Select GroupID from #tempgroup where GroupID = @GroupID)    
 Begin    
  Update #temp    
  Set AccountDebited = dbo.LookupDictionaryItem('Opening Balance Entry',Default)    
  Where DebitID = @DebitID    
 End     
 Drop table #tempgroup     
    
 Fetch Next From scancreditnote into @AccountCredited,@DebitID    
End    
Close scancreditnote    
Deallocate scancreditnote    
    
Set @ROWCOUNT=(Select count(*) from #Temp where Type=dbo.LookupDictionaryItem('Others',Default))    
If @ROWCOUNT >0    
Begin    
 Insert #Temp    
 Select '',@Todate,'','Total Value:',sum(Value),'','','','','',0,0,@LASTLEVEL from #Temp where Type=dbo.LookupDictionaryItem('Others',Default)    
 Insert #Temp    
 Select '','','','',Null,'','','','','',0,0,@LASTLEVEL    
End    
Set @ROWCOUNT=(Select count(*) from #Temp where DocumentID =N'')    
If @ROWCOUNT >0    
Begin    
 Insert #Temp    
 Select '',@Todate,'','Net Value:',sum(Value),'','','','','',0,0,@LASTLEVEL from #Temp where DocumentID =N''    
End    
    
If @OLDIMPL=1
 Begin
  Select "Document ID" = DocumentID,"Document Date" = DocumentDate,Type,"Account Debited" = AccountDebited,Value,"Account Credited" = AccountCredited,Remarks,Status,DebitID,DocType,NextLevel from #Temp
 End
Else
 Begin
  Select "Document ID" = #temp.DocumentID,"Document Date" = #temp.DocumentDate,#temp.Type,
  "Account Debited" = #temp.AccountDebited,#temp.Value,DebitNote.DocumentReference as "Document Reference",
  #temp.Remarks,#temp.Status,#temp.DebitID,#temp.DocType,NextLevel 
  from #Temp Left Outer Join DebitNote
  On #Temp.DebitID = DebitNote.DebitID
 End
Drop table #temp 
