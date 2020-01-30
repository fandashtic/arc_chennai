
Create Procedure dbo.sp_get_InvoicewiseCollection (@BtID nvarchar(255),@FromDate datetime,@ToDate datetime,@Criteria2 nvarchar(255),@Criteria3 nvarchar(255),@Mode integer,@BtFlag int=0)
As
Begin
-- parameter @BtFlag is added in ITC rework for beat criteria. @BtFlag is set to 1 for ITC
Declare @qry as nvarchar(4000)
Declare @Delimeter as Char(1)
Create table #tmpBt(BeatID varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS )
--Create table #tmpInvoiceDebit(InvID int,DocID nvarchar(255),DocRef nvarchar(255),DocType nvarchar(10),DocDate datetime,DocValue float,DocBalance float,Discount float,DisVal float,CompName nvarchar(255),CreditLimit float,PaymentDate datetime,CustomerID nvarchar(15),FullDocID nvarchar(10),FullDocRef nvarchar(355), ChqCollDebitFlag Int, Flag Int, ChqCollDocID Int, ChqCollDocType Int)
Create table #tmpInvoiceDebit(InvID int, DocID nvarchar(255), DocRef nvarchar(255), DocType nvarchar(20),
DocDate datetime, DocValue float, DocBalance float, Discount float, DisVal float, CompName nvarchar(255),
CreditLimit float, PaymentDate datetime, CustomerID nvarchar(15), FullDocID nvarchar(255),
FullDocRef nvarchar(1000), ChqCollDebitFlag Int, Flag Int, ChqCollDocID Int, ChqCollDocType Int)
Create table #Results(InvID int,DocID nvarchar(255),DocRef nvarchar(255),DocType nvarchar(20),
DocDate datetime,DocValue float,DocBalance float,Discount float,DisVal float,CompName nvarchar(255),
CreditLimit float,PaymentDate datetime,CustomerID nvarchar(15),FullDocID nvarchar(255),
FullDocRef nvarchar(1000), ChqCollDebitFlag Int, Flag Int, ChqCollDocID Int, ChqCollDocType Int, ChqAmt Decimal(18,6))
Set @Delimeter=N','

if @BtID<>N'0'
Begin
If @BtID=N'%'
Begin
Insert into #tmpBt select BeatID from Beat
If @BtFlag=0
Insert into #tmpBt (BeatID) Values (N'0')
End
Else
Insert into #tmpBt select * from dbo.sp_SplitIn2Rows(@BtID,@Delimeter)
End

Set @qry=N'Select InvoiceID,DocumentID,DocReference,''Invoice'',InvoiceDate,NetValue,Balance,AdditionalDiscount,AddlDiscountValue,Company_Name,CreditLimit,PaymentDate,'
Set @qry=@qry+N'Customer.CustomerID,Case IsNULL(GSTFlag ,0) When 0 then VoucherPrefix.Prefix + cast(DocumentID as nvarchar) Else IsNULL(GSTFullDocID,'''') End DocumentID ,case IsNull(DocSerialType,'''') when '''' then VoucherPrefix.Prefix+''-''+DocReference else DocSerialType+''-''+DocReference end, '
Set @qry=@qry+N'0, 0 as Flag, 0 as ChqCollDocID, 0 as ChqCollDocType '
Set @qry=@qry+N'From InvoiceAbstract, Customer, VoucherPrefix, VoucherPrefix as InvPrefix '
Set @qry=@qry+N'Where InvoiceAbstract.InvoiceDate Between '''+ convert(Nvarchar,@FromDate) +''' And '''+ convert(Nvarchar,@ToDate) +''''
print @qry

if @BtID <> '0'
Set @qry=@qry+N' And InvoiceAbstract.BeatID in (select BeatID COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBt)'
else	--This else part is done for ITC
Begin
if @BtFlag=1 And @BtID = '0'
Set @qry=@qry+N' And InvoiceAbstract.BeatID = 0'
End

Set @qry=@qry+ @Criteria2 +N' And InvoiceAbstract.CustomerID=Customer.Customerid '
Set @qry=@qry+N'And (IsNull(InvoiceAbstract.Status,0) & 128) = 0 And InvoiceAbstract.Balance >= 0 '
Set @qry= @qry+N'And (IsNull(InvoiceAbstract.DocumentID,0)) NOT IN (Select InvoiceDocumentID from tbl_merp_DSOSTransfer)  And '
Set @qry=@qry+N'VoucherPrefix.TranID = ''INVOICE'' And InvPrefix.TranID = ''INVOICE AMENDMENT'' And InvoiceType in (1,3) '


if @Mode=5
Set @qry=@qry+N' And InvoiceAbstract.PaymentMode = 0 '

Set @qry=@qry+N' Union '

Set @qry=@qry+ N'Select InvoiceAbstract.InvoiceID,DocumentID,DocReference,''Invoice'',InvoiceDate,NetValue,Balance,AdditionalDiscount,AddlDiscountValue,Company_Name,CreditLimit,PaymentDate,'
Set @qry=@qry+N'Customer.CustomerID,Case IsNULL(GSTFlag ,0) When 0 then VoucherPrefix.Prefix + cast(DocumentID as nvarchar) Else IsNULL(GSTFullDocID,'''') End DocumentID,case IsNull(DocSerialType,'''') when '''' then VoucherPrefix.Prefix+''-''+DocReference else DocSerialType+''-''+DocReference end, '
Set @qry=@qry+N'0, 0 as Flag, 0 as ChqCollDocID, 0 as ChqCollDocType '
Set @qry=@qry+N'From InvoiceAbstract, Customer, VoucherPrefix, VoucherPrefix as InvPrefix , tbl_merp_DSOSTransfer as DSOSTR'
Set @qry=@qry+N' Where InvoiceAbstract.InvoiceDate Between '''+ convert(Nvarchar,@FromDate) +''' And '''+ convert(Nvarchar,@ToDate) +''''
Set @qry=@qry+N'And InvoiceAbstract.DocumentID = DSOSTR.InvoiceDocumentID'

if @BtID <> '0'
Set @qry=@qry+N' And DSOSTR.mappedBeatID in (select BeatID COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBt)'
else	--This else part is done for ITC
Begin
if @BtFlag=1 And @BtID = '0'
Set @qry=@qry+N' And InvoiceAbstract.BeatID = 0'
End

Set @qry=@qry+ @Criteria2 +N' And InvoiceAbstract.CustomerID=Customer.Customerid '
Set @qry=@qry+N'And (IsNull(InvoiceAbstract.Status,0) & 128) = 0 And InvoiceAbstract.Balance >= 0 And '
Set @qry=@qry+N'VoucherPrefix.TranID = ''INVOICE'' And InvPrefix.TranID = ''INVOICE AMENDMENT'' And InvoiceType in (1,3) '

if @Mode=5
Set @qry=@qry+N' And InvoiceAbstract.PaymentMode = 0 '
Else
Begin




Set @qry=@qry+N' Union '
Set @qry=@qry+N'Select DebitNote.DebitID,DebitNote.DocumentID,DocumentReference,''Debit Note'',DocumentDate,NoteValue,Balance,0,0,Company_Name,'
Set @qry=@qry+N'CreditLimit,DocumentDate,Customer.CustomerID,VoucherPrefix.Prefix + cast(DebitNote.DocumentID as nvarchar),'
Set @qry=@qry+N'case IsNull(DocSerialType,'''') when '''' then DocumentReference else DocSerialType+''-''+DocumentReference end, '
Set @qry=@qry+N'0, Flag, ChequeCollDetails.DocumentID, ChequeCollDetails.DocumentType '
Set @qry=@qry+N'From DebitNote
inner join Customer on DebitNote.CustomerID=Customer.CustomerID
inner join VoucherPrefix on  VoucherPrefix.TranID = ''DEBIT NOTE''
left outer join ChequeCollDetails on DebitNote.DebitID = ChequeCollDetails.DebitID '
Set @qry=@qry+N'where (IsNull(Status,0) & 64)=0 And (IsNull(Status,0) & 128)=0 And DebitNote.Balance >= 0  '
Set @qry=@qry+N'And  IsNull(DebitNote.CustomerID,0) <> ''0'' '
Set @qry=@qry+N'And DebitNote.DocumentDate Between '''+convert(Nvarchar,@FromDate)+''' And '''+convert(Nvarchar,@ToDate)+''''+ @Criteria3

End


Insert into #tmpInvoiceDebit
Exec sp_executesql @qry


Insert Into #Results
Select InvID, DocID, DocRef, DocType, DocDate, DocValue, DocBalance, Discount, DisVal, CompName, CreditLimit,
PaymentDate, CustomerID, FullDocID, FullDocRef, ChqCollDebitFlag, Flag, ChqCollDocID, ChqCollDocType, 0
From #tmpInvoiceDebit Where Flag <> 2
Union
Select 1, 1, N'', N'', DocDate, 0, Sum(DocBalance), Discount, DisVal, N'', CreditLimit,
PaymentDate, N'', N'', N'', 1, Flag, ChqCollDocID, ChqCollDocType, 0
From #tmpInvoiceDebit Where Flag = 2
Group By DocDate, Discount, DisVal, CreditLimit,
PaymentDate, Flag, ChqCollDocID, ChqCollDocType



-- To update the document balance from bounced cheque debit note balance
Update tmp1 Set tmp1.DocBalance = (tmp1.DocBalance + tmp2.DocBalance), tmp1.ChqCollDebitFlag = tmp2.ChqCollDebitFlag,
tmp1.ChqCollDocID = tmp2.ChqCollDocID, tmp1.ChqCollDocType = tmp2.ChqCollDocType
From #Results tmp1, #Results tmp2 Where tmp2.ChqCollDocID <> 0 And tmp1.InvID = tmp2.ChqCollDocID And
tmp1.DocType = (Case tmp2.ChqCollDocType When 4 Then dbo.LookUpDictionaryItem(N'Invoice', Default) Else dbo.LookUpDictionaryItem(N'Debit Note', Default) End)

-- To update doctype description as 'Inv Chq Bounced' for bounced cheque of cheque invoice only
Update tmp1 Set tmp1.DocType = dbo.LookUpDictionaryItem(N'Inv Chq Bounced', Default) From #Results tmp1, InvoiceAbstract iva
Where iva.InvoiceID = tmp1.ChqCollDocID And tmp1.ChqCollDocType = 4 And Flag <> 2 And IsNull(iva.PaymentMode, 0) = 2

-- To update the unrealised/unbounced cheque amount
Update tmp1 Set tmp1.ChqAmt = tmp2.ChqAmt From #Results tmp1,
(Select InvID, DocID, DocType, (Case When isnull(Max(cl.realised),0) = 3 then dbo.mERP_fn_getCollBalance_ITC(Max(ClD.DocumentID), Max(ClD.DocumentType)) else (IsNull(Sum(cld.AdjustedAmount), 0) - IsNull(Sum(cld.DocAdjustAmount), 0)) End) as ChqAmt From Collections cl, CollectionDetail cld, #Results rs
Where rs.Flag <> 2 And cld.DocumentID = rs.InvID And cld.DocumentType = (Case rs.DocType When dbo.LookUpDictionaryItem(N'Invoice', Default) Then 4 When dbo.LookUpDictionaryItem(N'Inv Chq Bounced', Default) Then 4 Else 5 End)
And cl.DocumentID = cld.CollectionID And IsNull(cl.Status, 0) & 192 = 0 And IsNull(cl.PaymentMode, 0) = 1
And IsNull(cl.Realised, 0) Not In (1, 2)
Group By InvID, DocID, DocType)tmp2
Where tmp1.InvID = tmp2.InvID And tmp1.DocID = tmp2.DocID And tmp1.DocType = tmp2.DocType

Select * From #Results Where Flag <> 2 And DocBalance > 0 Order By DocRef

Drop Table #tmpBt
Drop Table #Results
Drop Table #tmpInvoiceDebit
End
