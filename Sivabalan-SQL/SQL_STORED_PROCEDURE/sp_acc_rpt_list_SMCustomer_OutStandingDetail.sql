CREATE Procedure sp_acc_rpt_list_SMCustomer_OutStandingDetail(@SalesmanBeatID nVarchar(50),  
       @FromDate datetime,  
       @ToDate datetime)  
as  
Declare @SalesmanID int  
Declare @BeatID int  
Declare @Pos int  
  
Set @Pos = CharIndex(N';', @SalesmanBeatID)  
Set @SalesmanID = Cast(SubString(@SalesmanBeatID, 1, @Pos - 1) As Int)  
Set @BeatID = Cast(SubString(@SalesmanBeatID, @Pos + 1, 50) As Int)  
create table #temp  
(  
 SalesmanID int not null,  
 BeatID int not null,  
 Balance Decimal(18,6) not null,  
 CustomerID nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS not null,  
 DocumentID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS not null,  
 DocReference nvarchar(150) COLLATE SQL_Latin1_General_CP1_CI_AS,  
 DocumentDate datetime,  
 Amount  Decimal(18,6),  
 Discount Decimal(18, 6),  
 DiscountPercentage Decimal(18, 6),  
 DueDays INT  
)  
insert into #temp  
select  ISNULL(InvoiceAbstract.SalesmanID, 0),   
 IsNull(InvoiceAbstract.BeatID, 0),  
 ISNULL(InvoiceAbstract.Balance, 0),  
 CustomerID,   
 case ISNULL(InvoiceAbstract.GSTFlag,0) When 0 then 
 case InvoiceType 
  when 1 then  
 IsNull((Select IsNull(Prefix, N'') From VoucherPrefix Where VoucherPrefix.TranID Like N'INVOICE'), N'')  
-- IPrefix.Prefix   
 when 2 then  
 IsNull((Select IsNull(Prefix, N'') From VoucherPrefix Where VoucherPrefix.TranID Like N'RETAIL INVOICE'), N'')  
-- IPrefix.Prefix   
 when 3 then  
 IsNull((Select IsNull(Prefix, N'') From VoucherPrefix Where VoucherPrefix.TranID Like N'INVOICE AMENDMENT'), N'')  
-- IAPrefix.Prefix  
 end  
 + cast(InvoiceAbstract.DocumentID as nvarchar) 
Else ISNULL(InvoiceAbstract.GSTFullDocID,'') End,  
 InvoiceAbstract.DocReference,  
 InvoiceAbstract.InvoiceDate, InvoiceAbstract.NetValue,  
 (dbo.GetInvoiceGoodsValue(InvoiceID) * InvoiceAbstract.DiscountPercentage / 100) +  
 (dbo.GetInvoiceGoodsValue(InvoiceID) * InvoiceAbstract.AdditionalDiscount / 100),  
 InvoiceAbstract.DiscountPercentage + InvoiceAbstract.AdditionalDiscount,  
 datediff(day,InvoiceAbstract.InvoiceDate,dbo.Sp_Acc_GetOperatingDate(getdate()))  
from InvoiceAbstract -- VoucherPrefix as IPrefix, VoucherPrefix as IAPrefix  
where InvoiceAbstract.Status & 128 = 0 and  
 InvoiceAbstract.Balance > 0 and  
 InvoiceAbstract.InvoiceType in (1, 2, 3) and  
 InvoiceAbstract.InvoiceDate between @FromDate and @ToDate and  
-- IPrefix.TranID = (Case InvoiceAbstract.InvoiceType When 1 Then 'INVOICE'   
--  When 2 Then 'RETAIL INVOICE' End) And  
-- IAPrefix.TranID = 'INVOICE AMENDMENT' and  
 isnull(InvoiceAbstract.SalesmanID, 0) = @SalesmanID And  
 IsNull(InvoiceAbstract.BeatID, 0) = @BeatID  
  
insert into #temp  
select  ISNULL(InvoiceAbstract.SalesmanID, 0),   
 IsNull(InvoiceAbstract.BeatID, 0),  
 0 - ISNULL(InvoiceAbstract.Balance, 0), CustomerID,  
 Case ISNULL(InvoiceAbstract.GSTFlag,0) When 0 then  VoucherPrefix.Prefix + cast(InvoiceAbstract.DocumentID as nvarchar) Else ISNULL(InvoiceAbstract.GSTFullDocID,'') End,  
 InvoiceAbstract.DocReference,  
 InvoiceAbstract.InvoiceDate, InvoiceAbstract.NetValue,  
 (dbo.GetInvoiceGoodsValue(InvoiceID) * InvoiceAbstract.DiscountPercentage / 100) +  
 (dbo.GetInvoiceGoodsValue(InvoiceID) * InvoiceAbstract.AdditionalDiscount / 100),  
 InvoiceAbstract.DiscountPercentage + InvoiceAbstract.AdditionalDiscount,  
 NULL  
FROM InvoiceAbstract, VoucherPrefix  
WHERE  ISNULL(Balance, 0) > 0 and InvoiceType In (4, 5, 6) AND  
 (Status & 128) = 0 AND  
 InvoiceDate Between @FromDate AND @ToDate and  
 VoucherPrefix.TranID = N'SALES RETURN' and  
 isnull(InvoiceAbstract.SalesmanID, 0) = @SalesmanID And  
 IsNull(InvoiceAbstract.BeatID, 0) = @BeatID  
  
insert into #temp   
SELECT ISNULL(Collections.SalesmanID, 0), IsNull(Collections.BeatID, 0),    
 0 - ISNULL(Balance, 0), Collections.CustomerID,  
 Isnull(FullDocID, N''), Null, DocumentDate, Value, 0, 0,NULL  
FROM Collections  
WHERE  ISNULL(Balance, 0) > 0 AND DocumentDate Between @FromDate AND @ToDate and  
 isnull(Collections.SalesmanID, 0) = @SalesmanID And  
 IsNull(Collections.BeatID, 0) = @BeatID  
 and Collections.CustomerID is not null  
  
insert into #temp   
SELECT  ISNULL(CreditNote.SalesmanID, 0), IsNull(Beat_Salesman.BeatID, 0),  
 0 - ISNULL(Balance, 0), CreditNote.CustomerID,  
 VoucherPrefix.Prefix + cast(DocumentID as nvarchar), DocRef,   
 DocumentDate, NoteValue, 0, 0,NULL  
FROM CreditNote, VoucherPrefix, Beat_Salesman  
WHERE   ISNULL(Balance, 0) > 0 AND DocumentDate Between @FromDate AND @ToDate AND  
 CreditNote.CustomerID IS NOT NULL and  
 VoucherPrefix.TranID = N'CREDIT NOTE' and  
 isnull(CreditNote.SalesmanID, 0)= @SalesmanID And  
 Beat_Salesman.CustomerID = CreditNote.CustomerID And  
 Beat_Salesman.SalesmanID = CreditNote.SalesmanID And  
 Beat_Salesman.BeatID = @BeatID And   
 CreditNote.CustomerID Is Not Null  
  
insert into #temp   
SELECT  ISNULL(DebitNote.SalesmanID, 0), IsNull(Beat_Salesman.BeatID, 0),  
 ISNULL(Balance, 0), DebitNote.CustomerID,  
 VoucherPrefix.Prefix + cast(DocumentID as nvarchar), DocRef,   
 DocumentDate, NoteValue, 0, 0,NULL  
FROM DebitNote, VoucherPrefix, Beat_Salesman  
WHERE  ISNULL(Balance, 0) > 0 AND DocumentDate Between @FromDate AND @ToDate AND  
 DebitNote.CustomerID IS NOT NULL and  IsNull(DebitNote.Status, 0) & 192 = 0  And 
 VoucherPrefix.TranID = N'DEBIT NOTE' and  
 isnull(DebitNote.SalesmanID, 0)= @SalesmanID And  
 Beat_Salesman.CustomerID = DebitNote.CustomerID And  
 Beat_Salesman.SalesmanID = DebitNote.SalesmanID And  
 Beat_Salesman.BeatID = @BeatID And  
 DebitNote.CustomerID Is Not Null  
 And Isnull(DebitNote.status , 0) <> 192
  
select distinct #temp.CustomerID,   
"CustomerID" = #temp.CustomerID,  
"Customer Name" = Customer.Company_Name,  
"Document ID" = DocumentID, "Doc Reference" = DocReference,   
"Document Date" = DocumentDate, "Discount" = #temp.Discount,  
"Discount %" = #temp.DiscountPercentage, "Amount" = Amount, "OutStanding" = Balance,  
"Due Days" = DueDays  
from #temp, Customer  
WHERE #temp.SalesmanID = @SalesmanID and #temp.BeatID = @BeatID And  
#temp.CustomerID collate SQL_Latin1_General_Cp1_CI_AS = Customer.CustomerID  
order By #temp.CustomerID, DocumentDate  
drop table #temp    

