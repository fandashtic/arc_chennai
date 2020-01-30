CREATE PROCEDURE sp_get_open_documents(@CUSTOMER nvarchar(15),@SalesmanID Int=0)
AS
Declare @InvPreFix nVarchar(10)
Declare @CRPreFix nVarchar(10)
Declare @GVPreFix nVarchar(10)

Select @InvPreFix = Prefix From VoucherPrefix Where TranID = 'INVOICE'
Select @CRPreFix = Prefix From VoucherPrefix Where TranID = 'CREDIT NOTE'
Select @GVPreFix = Prefix From VoucherPrefix Where TranID = 'GIFT VOUCHER'

Declare @DSTypeID Int
Select @DSTypeID = Max(DSTypeId)  From DSType_Details Where DSTypeCtlPos = 1 And SalesManID = @SalesmanID

Create Table #tmpAutoAdjList(
DSTypeID Int,
DocType Int,
DocID nVarchar(50)  COLLATE SQL_Latin1_General_CP1_CI_AS,
DocDate DateTime,
CreditID Int,
Balance Decimal(18,6),
NetValue Decimal(18,6),
RecSchTag Int,
Memo nVarChar(255)  COLLATE SQL_Latin1_General_CP1_CI_AS,
AutoAdjFlag Int Default 0,
SplSKUFlag Int Default 0)

Create Table #tmpDocList(
DocType Int,
DocID nVarchar(50)  COLLATE SQL_Latin1_General_CP1_CI_AS,
DocDate DateTime,
TranID Int,
Balance Decimal(18,6),
NetValue Decimal(18,6),
RecSchTag Int,
Memo nVarChar(255)  COLLATE SQL_Latin1_General_CP1_CI_AS,
AutoAdjFlag Int Default 0,
SplSKUFlag Int Default 0)

Create Table #tmpAutoSplSKuAdjList(
DocType Int,
DocID nVarchar(50)  COLLATE SQL_Latin1_General_CP1_CI_AS,
DocDate DateTime,
TranID Int,
Balance Decimal(18,6),
NetValue Decimal(18,6),
RecSchTag Int,
Memo nVarChar(255)  COLLATE SQL_Latin1_General_CP1_CI_AS,
AutoAdjFlag Int Default 0,
SplSKUFlag Int Default 0)


Insert Into #tmpAutoAdjList(DSTypeID,DocType, DocID, DocDate, CreditID, Balance, NetValue, RecSchTag, Memo,AutoAdjFlag,SplSKUFlag)
Select DST.DSTypeID, 10, @GVPreFix +  CAST(CR.DocumentID AS nvarchar(100)), CR.DocumentDate, CR.CreditID, CR.Balance, CR.NoteValue, 0, CR.Memo , 1,IsNUll(CR.FreeSKUFlag,0)
From CreditNote CR
Join CrNoteDSType DST On DST.CreditID = CR.CreditID  And DST.CreditNoteType in (1)
Where CR.Balance > 0 And CR.CustomerID = @CUSTOMER And IsNull(CR.Flag,0) = 1

Union

Select DST.DSTypeID, 2, @CRPreFix + CAST(CR.DocumentID AS nvarchar), CR.DocumentDate, CR.CreditID, CR.Balance, CR.NoteValue, 0, CR.Memo , 1 ,IsNUll(CR.FreeSKUFlag,0)
From CreditNote CR
Join CrNoteDSType DST On DST.CreditID = CR.CreditID And DST.CreditNoteType in (2,3)
Where CR.Balance > 0 And CR.CustomerID = @CUSTOMER And IsNUll(CR.Flag,0) = 1

--SplFreeSKU
Insert Into #tmpAutoSplSKuAdjList(DocType, DocID, DocDate, TranID, Balance, NetValue, RecSchTag, Memo,AutoAdjFlag,SplSKUFlag)
Select  2, @CRPreFix + CAST(CR.DocumentID AS nvarchar(100)), CR.DocumentDate, CR.CreditID, CR.Balance, CR.NoteValue, 0, CR.Memo , 1 ,IsNUll(CR.FreeSKUFlag,0)
From CreditNote CR
Where CR.Balance > 0 And CR.CustomerID = @CUSTOMER And IsNUll(CR.FreeSKUFlag,0) = 1


Create Table #tmpCLOCrNtLst(CLOCrNtID Int)
--CLO Cr Nt List
Insert Into #tmpCLOCrNtLst (CLOCrNtID)
Select isnull(CreditID,0) From CLOCrnote
where isnull(IsGenerated,0)=1 And CustomerID = @CUSTOMER And isnull(CreditID,0) > 0
And CreditID Not in (Select CreditID From #tmpAutoAdjList)

Insert Into #tmpDocList(DocType, DocID, DocDate, TranID, Balance, NetValue, RecSchTag, Memo,AutoAdjFlag,SplSKUFlag)

Select DocType, DocID, DocDate, CreditID , Balance, NetValue, RecSchTag, Memo,AutoAdjFlag,SplSKUFlag From #tmpAutoAdjList
Where DSTypeID = @DSTypeID
Order By CreditID

Insert Into #tmpDocList(DocType, DocID, DocDate, TranID, Balance, NetValue, RecSchTag, Memo,AutoAdjFlag)

Select 1,
--@InvPreFix + CAST(DocumentID AS nvarchar),
Case IsNULL(GSTFlag ,0)
When 0 then @InvPreFix + CAST(DocumentID AS nvarchar)
Else
IsNULL(GSTFullDocID,'')
End,
InvoiceDate, InvoiceID, Balance, NetValue, 0, ''  , 0
From InvoiceAbstract --, VoucherPrefix
Where InvoiceType =4 And (Status & 128) = 0 And Balance > 0
And CustomerID = @CUSTOMER --And TranID = 'INVOICE'

UNION

Select 7,
--@InvPreFix + CAST(DocumentID AS nvarchar),
Case IsNULL(GSTFlag ,0)
When 0 then @InvPreFix + CAST(DocumentID AS nvarchar)
Else
IsNULL(GSTFullDocID,'')
End,
InvoiceDate, InvoiceID, Balance, NetValue, 0, '' , 0
From InvoiceAbstract--, VoucherPrefix
Where InvoiceType in(5,6) And (Status & 128) = 0 And Balance > 0
And CustomerID = @CUSTOMER --And TranID = 'INVOICE'

UNION

Select 2, @CRPreFix + CAST(CR.DocumentID AS nvarchar), CR.DocumentDate, CR.CreditID, CR.Balance, CR.NoteValue, 0, CR.Memo , 0
From CreditNote CR--, VoucherPrefix
Where CR.Balance > 0 And CR.CustomerID = @CUSTOMER --AND TranID = 'CREDIT NOTE'
/*To Handle CLO */
And IsNUll(CR.FreeSKUFlag,0) = 0
And IsNUll(CR.Flag,0) <> 2 and CR.CreditID Not in (Select CLO.CLOCrNtID From #tmpCLOCrNtLst CLO)
--(Select isnull(creditID,0) from CLOCrnote where isnull(isgenerated,0)=1)
And CR.CreditID Not in (Select AAL.CreditID From #tmpAutoAdjList AAL)

UNION

Select 10, @GVPreFix +  CAST(DocumentID AS nvarchar(100)), DocumentDate, CreditID, Balance, NoteValue, 0, memo , 0
From CreditNote--, VoucherPrefix
Where Balance > 0 And CustomerID = @CUSTOMER --AND TranID = 'GIFT VOUCHER'
and IsNull(Flag,0) = 2

/*To Handle CLO */
UNION

Select 10, @GVPreFix +  CAST(CR.DocumentID AS nvarchar(100)), CR.DocumentDate, CR.CreditID, CR.Balance, CR.NoteValue, 0, CR.Memo  , 0
From CreditNote CR--, VoucherPrefix
Where CR.Balance > 0 And CR.CustomerID = @CUSTOMER --AND TranID = 'GIFT VOUCHER'
and IsNull(CR.Flag,0) <> 2 and CR.CreditID  In (Select CLO.CLOCrNtID From #tmpCLOCrNtLst CLO)
--(Select isnull(creditID,0) from CLOCrnote where isnull(isgenerated,0)=1)

UNION

select 3, FullDocID, DocumentDate, DocumentID, Balance, Value, 0, '' , 0
from Collections
where Balance > 0 and
CustomerID = @CUSTOMER And
IsNull(Status, 0) & 128 = 0

Insert Into #tmpDocList
select * from #tmpAutoSplSKuAdjList

Select * From  #tmpDocList order by SplSKUFlag desc



