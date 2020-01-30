CREATE procedure sp_acc_rpt_DebitNote(@FromDate datetime,
				    @ToDate datetime)
as
Declare @DOCTYPE INT,@LASTLEVEL INT
SET @DOCTYPE=20 --CreditNote Type
SET @LASTLEVEL=1 --No NextLevel
Create table #Temp(DocumentID nvarchar(15),DocumentDate datetime,Type nvarchar(15),AccountCredited nvarchar(50),Value decimal(18,6),AccountDebited nvarchar(50),Remarks nvarchar(50),Status nVarchar(15),DebitID Int,DocType Int,NextLevel Int)
Insert #Temp
select VoucherPrefix.Prefix + cast(DocumentID as nvarchar), dbo.StripDateFromTime(DocumentDate),
dbo.LookupDictionaryItem('Customer',Default), Customer.Company_Name, NoteValue, Accountsmaster.AccountName, Memo, case when Balance > 0 then dbo.LookupDictionaryItem('Open',Default) else dbo.LookupDictionaryItem('Closed',Default) end, DebitID, @DocType,@LASTLEVEL
from DebitNote, VoucherPrefix, Customer, Accountsmaster
where DebitNote.CustomerID is not null and DebitNote.CustomerID = Customer.CustomerID and
dbo.Stripdatefromtime(DebitNote.DocumentDate) between @FromDate and @ToDate and VoucherPrefix.TranID = N'DEBIT NOTE' and 
AccountsMaster.AccountID=DebitNote.AccountID order by DocumentDate
Insert #Temp
Select '',@Todate,'','Total Value:',sum(Value),'','','','','',@LASTLEVEL from #Temp where Type=dbo.LookupDictionaryItem('Customer',Default)
Insert #Temp
Select '','','','',Null,'','','','','','' 
Insert #Temp
select VoucherPrefix.Prefix + cast(DocumentID as nvarchar), dbo.StripDateFromTime(DocumentDate),
dbo.LookupDictionaryItem('Vendor',Default), Vendors.Vendor_Name, NoteValue, Accountsmaster.AccountName, Memo, case when Balance > 0 then dbo.LookupDictionaryItem('Open',Default) else dbo.LookupDictionaryItem('Closed',Default) end, DebitID, @DocType,@LASTLEVEL
from DebitNote, VoucherPrefix, Vendors, Accountsmaster
where DebitNote.VendorID is not null and DebitNote.VendorID = Vendors.vendorID and
dbo.Stripdatefromtime(DebitNote.DocumentDate) between @FromDate and @ToDate and VoucherPrefix.TranID = N'DEBIT NOTE' and 
AccountsMaster.AccountID=DebitNote.AccountID order by DocumentDate
Insert #Temp
Select '',@Todate,'','Total Value:',sum(Value),'','','','','',@LASTLEVEL from #Temp where Type=dbo.LookupDictionaryItem('Vendor',Default)
Insert #Temp
Select '','','','',Null,'','','','','',@LASTLEVEL
Insert #Temp
select VoucherPrefix.Prefix + cast(DocumentID as nvarchar), dbo.StripDateFromTime(DocumentDate),
dbo.LookupDictionaryItem('Others',Default), A.AccountName, NoteValue, B.AccountName, Memo, case when Balance > 0 then dbo.LookupDictionaryItem('Open',Default) else dbo.LookupDictionaryItem('Closed',Default) end, DebitID, @DocType,@LASTLEVEL
from DebitNote, VoucherPrefix, AccountsMaster A,AccountsMaster B
where DebitNote.Others is not null and DebitNote.others =  A.AccountID and
dbo.Stripdatefromtime(DebitNote.DocumentDate) between @FromDate and @ToDate and VoucherPrefix.TranID = N'DEBIT NOTE' and 
B.AccountID=DebitNote.AccountID order by DocumentDate
Insert #Temp
Select '',@Todate,'','Total Value:',sum(Value),'','','','','',@LASTLEVEL from #Temp where Type=dbo.LookupDictionaryItem('Customer',Default)
Insert #Temp
Select '','','','',Null,'','','','','','' 
Insert #Temp
Select '',@Todate,'','Net Value:',sum(Value),'','','','','',@LASTLEVEL from #Temp where DocumentID =N''
Select * from #temp
Drop table #temp

