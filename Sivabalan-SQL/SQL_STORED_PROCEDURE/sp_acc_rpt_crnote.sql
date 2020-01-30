CREATE Procedure sp_acc_rpt_crnote(@FromDate DateTime,@Todate DateTime)    
As    
Declare @DOCTYPE INT,@NEXTLEVEL INT,@LASTLEVEL INT, @ROWCOUNT INT    
Declare @AccountCredited Int,@CreditID Int     
Declare @GroupID Int    
DECLARE @OLDIMPL INT

If Not Exists (Select * from FAReportData Where ParentID = 21)/*(ParentID)21 = CreditNote Report*/
 Begin
  /*@OLDIMPL=1 implies there is no detail record for the CreditNote Report, So Drilldown has to be disabled.*/
  Set @OLDIMPL = 1
 End

Declare @ToDatePair datetime  
Set @ToDatePair = DateAdd(s, 0-1, DateAdd(dd, 1, @todate))  
    
SET @DOCTYPE=21 --CreditNote Type    
SET @LASTLEVEL=1 --No NextLevel    
If @OLDIMPL = 1 
 Set @NEXTLEVEL=0
Else
 SET @NEXTLEVEL=26    

Create table #Temp(DocumentID nvarchar(25),DocumentDate datetime,Type nvarchar(25),    
AccountCredited nvarchar(255),Value decimal(18,6),AccountDebited nvarchar(255),    
Remarks nvarchar(2500),Status nVarchar(25),CreditID Int,DocType Int,    
AccountCreditedID Int,AccountDebitedID Int, NextLevel Int)    
    
Insert #Temp    
select "Document ID" = VoucherPrefix.Prefix + cast(DocumentID as nvarchar),    
"Date" = dbo.StripDateFromTime(DocumentDate), "Type"= dbo.LookupDictionaryItem('Customer',Default),    
"Account Credited" = Customer.Company_Name , "Value" = NoteValue,    
"Account Debited"=Case When IsNull(CreditNote.AccountID,0)= 0 Then dbo.LookupDictionaryItem('Opening Balance Entry',Default) Else    
dbo.getaccountname(IsNull(CreditNote.AccountID,0)) End,"Remarks" = Memo,    
"Status" = 
Case
	when IsNull(Status,0) & 64 <> 0 then dbo.LookupDictionaryItem('Cancelled',Default) 
 	when isnull(status & 128,0 ) = 128 and isnull(RefDocid,0) <> 0 then dbo.LookupDictionaryItem('Amended',Default)    
 	when isnull(status & 128,0 ) = 128 and isnull(RefDocid,0) = 0  then dbo.LookupDictionaryItem('Amended',Default)    
 	when isnull(status & 128,0 ) = 0 and isnull(RefDocid,0) <> 0  then dbo.LookupDictionaryItem('Open',Default)    
	When isnull(status,0) = 0 and Balance = 0 and isnull(RefDocid,0) = 0 then dbo.LookupDictionaryItem('Closed',Default)
	When isnull(status,0) = 0 and Balance > 0 and isnull(RefDocid,0) = 0 then dbo.LookupDictionaryItem('Open',Default)
End,
CreditID, "DocType" = @DocType,0,0,"Next Level" = @NEXTLEVEL    
from CreditNote, VoucherPrefix, Customer    
where CreditNote.CustomerID is not null and CreditNote.CustomerID = Customer.CustomerID and    
CreditNote.DocumentDate between @FromDate and @ToDatePair and    
VoucherPrefix.TranID = N'CREDIT NOTE' order by DocumentDate    

Set @ROWCOUNT=(Select count(*) from #Temp where Type=dbo.LookupDictionaryItem('Customer',Default))    
If @ROWCOUNT >0    
Begin    
 	Insert #Temp    
 	Select '',@Todate,'','Total Value:',sum(Value),'','','','','',0,0,@LASTLEVEL from #Temp where Type=dbo.LookupDictionaryItem('Customer',Default)    
 	Insert #Temp    
 	Select '','','','',Null,'','','','','',0,0,''     
End    
    
Insert #Temp    
select "Document ID" = VoucherPrefix.Prefix + cast(DocumentID as nvarchar),    
"Date" = dbo.StripDateFromTime(DocumentDate), "Type"= dbo.LookupDictionaryItem('Vendor',Default),    
"Account Credited" = Vendors.Vendor_Name , "Value" = NoteValue,    
"Account Debited"= Case When IsNull(CreditNote.AccountID,0) = 0 Then dbo.LookupDictionaryItem('Opening Balance Entry',Default) Else    
dbo.getaccountname(IsNull(CreditNote.AccountID,0)) End,"Remarks" = Memo,    
"Status" = 
case 
	when (IsNull(Status,0) & 64)<> 0 then dbo.LookupDictionaryItem('Cancelled',Default)     
 	when isnull(status & 128,0 ) = 128 and isnull(RefDocid,0) <> 0 then dbo.LookupDictionaryItem('Amended',Default)    
 	when isnull(status & 128,0 ) = 128 and isnull(RefDocid,0) = 0  then dbo.LookupDictionaryItem('Amended',Default)    
 	when isnull(status & 128,0 ) = 0 and isnull(RefDocid,0) <> 0  then dbo.LookupDictionaryItem('Open',Default)    
	When isnull(status,0) = 0 and Balance = 0 and isnull(RefDocid,0) = 0 then dbo.LookupDictionaryItem('Closed',Default)
	When isnull(status,0) = 0 and Balance > 0 and isnull(RefDocid,0) = 0 then dbo.LookupDictionaryItem('Open',Default)
end,     
CreditID, "DocType" = @DocType,0,0, "Next Level" = @NEXTLEVEL    
from CreditNote, VoucherPrefix, Vendors    
where CreditNote.VendorID is not null and CreditNote.VendorID = Vendors.VendorID and    
CreditNote.DocumentDate between @FromDate and @ToDatePair and    
VoucherPrefix.TranID = N'CREDIT NOTE' order by DocumentDate    
    
Set @ROWCOUNT=(Select count(*) from #Temp where Type=dbo.LookupDictionaryItem('Vendor',Default))    
If @ROWCOUNT >0    
Begin    
 	Insert #Temp    
 	Select '',@Todate,'','Total Value:',sum(Value),'','','','','',0,0,@LASTLEVEL from #Temp where Type=dbo.LookupDictionaryItem('Vendor',Default)    
 	Insert #Temp    
 	Select '','','','',Null,'','','','','',0,0,@LASTLEVEL    
End    
    
Insert #Temp    
select "Document ID" = VoucherPrefix.Prefix + cast(DocumentID as nvarchar),    
"Date" = dbo.StripDateFromTime(DocumentDate), "Type"= dbo.LookupDictionaryItem('Others',Default),    
"Account Credited" = dbo.getaccountname(IsNull(Others,0)), "Value" = NoteValue,    
"Account Debited"=dbo.getaccountname(IsNull(AccountID,0)), "Remarks" = Memo,    
"Status" = 
case 
	when (IsNull(Status,0) & 64)<> 0 then dbo.LookupDictionaryItem('Cancelled',Default)     
 	when isnull(status & 128,0 ) = 128 and isnull(RefDocid,0) <> 0 then dbo.LookupDictionaryItem('Amended',Default)    
 	when isnull(status & 128,0 ) = 128 and isnull(RefDocid,0) = 0  then dbo.LookupDictionaryItem('Amended',Default)    
 	when isnull(status & 128,0 ) = 0 and isnull(RefDocid,0) <> 0  then dbo.LookupDictionaryItem('Open',Default)    
	When isnull(status,0) = 0 and Balance = 0 and isnull(RefDocid,0) = 0 then dbo.LookupDictionaryItem('Closed',Default)
	When isnull(status,0) = 0 and Balance > 0 and isnull(RefDocid,0) = 0 then dbo.LookupDictionaryItem('Open',Default)
end,     
CreditID,     
"DocType" = @DocType,IsNull(Others,0),IsNull(AccountID,0),"Next Level" = @NEXTLEVEL    
from CreditNote, VoucherPrefix     
where IsNull(CreditNote.Others,0) <> 0 and --CreditNote.others =  A.AccountID and    
CreditNote.DocumentDate between @FromDate and @ToDatePair and    
VoucherPrefix.TranID = N'CREDIT NOTE'     
-- and B.AccountID=CreditNote.AccountID and A.Active=1    
order by DocumentDate    
    
Declare scancreditnote Cursor KeySet For    
Select AccountCreditedID,CreditID from #Temp    
where Type = dbo.LookupDictionaryItem('Others',Default) and IsNull(AccountDebitedID,0) = 0     
    
Open scancreditnote    
Fetch From scancreditnote into @AccountCredited,@CreditID    
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
  		Where CreditID = @CreditID        
 	End     
 	Drop table #tempgroup     
 	Fetch Next From scancreditnote into @AccountCredited,@CreditID    
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
  Select "Document ID"=DocumentID,"Document Date"=DocumentDate,Type,"Account Credited" =AccountCredited,"Value" =Value ,"Account Debited"=AccountDebited ,"Remarks"=Remarks,Status,CreditID,DocType,NextLevel from #Temp
 End
Else
 Begin
  Select "Document ID"=#Temp.DocumentID,"Document Date"=#Temp.DocumentDate,#Temp.Type,
 	"Account Credited" =#Temp.AccountCredited,"Value" =#Temp.Value ,CreditNote.DocumentReference as "Document Reference",
  "Remarks"=#Temp.Remarks,#Temp.Status,#Temp.CreditID,#Temp.DocType,NextLevel
  from #Temp Left Outer Join CreditNote
  on #Temp.CreditID = CreditNote.CreditID
 End
Drop table #Temp
