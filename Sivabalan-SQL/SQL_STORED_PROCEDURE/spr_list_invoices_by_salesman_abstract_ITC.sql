
Create  PROCEDURE spr_list_invoices_by_salesman_abstract_ITC
(
	@SALESMAN_NAME nvarchar(2550),
	@BEAT_NAME nvarchar(2550),
	@PAYMENT_MODE nvarchar(50),
	@DSTYPE nvarchar(4000),
	@FROMDATE DATETIME,
	@TODATE DATETIME
)
As

Declare @Delimeter as Char(1), @Pay as nVarchar(50)
Declare @Credit As NVarchar(50), @Cash As NVarchar(50), @Cheque As NVarchar(50)
Declare @DD As NVarchar(50), @OTHERS As NVarchar(50)
Set @Credit = dbo.LookupDictionaryItem(N'Credit', Default)
Set @Cash = dbo.LookupDictionaryItem(N'Cash', Default)
Set @Cheque = dbo.LookupDictionaryItem(N'Cheque', Default)
Set @DD = dbo.LookupDictionaryItem(N'DD', Default)
Set @OTHERS = dbo.LookupDictionaryItem(N'Others', Default)
Set @Delimeter=Char(15)
  
Create Table #tmpSalesMan(SalesmanID int)
Create Table #tmpBeat(BeatID int)
Create Table #tmpPayMode(PayMode NVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)
Create Table #tmpPayMode2(PayMode NVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, pid int)

Insert Into #tmpPayMode2 Values (N'Credit', 0)
Insert Into #tmpPayMode2 Values (N'Cash', 1)  
Insert Into #tmpPayMode2 Values (N'Cheque', 2)
Insert Into #tmpPayMode2 Values (N'DD', 3)

Create Table #tmpSRInvNo (DocID int,PaymentMode int)

Create Table #tmpResult  
(SalesmanID int, Salesman nVarchar(100), GoodsValue Decimal(18,6), Discount Decimal(18,6),
TaxAmount Decimal(18,6), NetValue Decimal(18,6), PendingBills int, CashInvoices Decimal(18,6),
CreditInvoices Decimal(18,6), SalesReturnCash Decimal(18,6), SalesReturnCredit Decimal(18,6)) 

Create table #tmpDSType (SalesmanID Int, Salesman_Name nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
DSTypeValue nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)

if @DSType = N'%' or @DSType = N''
   Insert into #tmpDSType
   select Salesman.SalesmanID,Salesman_Name, DSTypeValue
   from DSType_Master,DSType_Details,Salesman
   Where Salesman.SalesmanID = DSType_Details.SalesmanID
   and DSType_Details.DSTypeID = DSType_Master.DSTypeID   
   and DSType_Master.DSTypeCtlPos = 1
   Union
   Select SalesmanID,Salesman_Name,'' from Salesman
   where SalesmanID not in (select SalesmanID from DSType_Details where DSTypeCtlPos = 1)
Else
   Insert into #tmpDSType
   select Salesman.SalesmanID,Salesman_Name,DSTypeValue from DSType_Master,DSType_Details,Salesman
   Where DSType_Master.DSTypeID = DSType_Details.DSTypeID
   and DSType_Details.SalesmanID = Salesman.SalesmanID  
   and DSType_Master.DSTypeCtlPos = 1   
   and DSType_Master.DSTypeValue in (select * from dbo.sp_SplitIn2Rows(@DSType,@Delimeter)) 

If @SALESMAN_NAME=N'%'      
Begin
	Insert into #tmpSalesMan Select SalesmanID From Salesman
	Insert into #tmpSalesMan Select 0
End
Else
	Insert into #tmpSalesMan Select SalesmanID From Salesman Where Salesman_Name in (select * from dbo.sp_SplitIn2Rows(@SALESMAN_NAME,@Delimeter))

If @BEAT_NAME=N'%'
Begin
	Insert into #tmpBeat Select BeatID From Beat
	Insert into #tmpBeat Select 0
End
Else
	Insert into #tmpBeat Select BeatID From Beat Where Description in (select * from dbo.sp_SplitIn2Rows(@BEAT_NAME,@Delimeter)) 
  
If @Payment_Mode = N'%'
   Insert into #tmpPaymode select [values] from QueryParams where QueryParamID In (11, 26) And [Values] Not In ('Bank Transfer')
else
   Insert into #tmpPaymode select * from dbo.sp_SplitIn2Rows(@Payment_Mode, @Delimeter)

Insert Into #tmpSRInvNo
Select IASR.DocumentID , IA.PaymentMode
From InvoiceAbstract IASR,
(Select DocumentID,PaymentMode From InvoiceAbstract Where Status & 128 = 0
AND InvoiceType in (1, 3) AND InvoiceDate BETWEEN @FROMDATE AND @TODATE
And SalesmanID In (Select SalesmanID From #tmpSalesMan)
And BeatID in (Select BeatID From #tmpBeat)
And PaymentMode in (Select pid From #tmpPayMode2 Where PayMode in (Select PayMode From #tmpPayMode)))  IA
Where
IASR.Status & 128 = 0 And IASR.InvoiceDate BETWEEN @FROMDATE AND @TODATE
And IASR.InvoiceType = 4
And IA.DocumentID = dbo.GetTrueVal(Case When (IsNull(IASR.NewReference,'') = '' or ( IsNumeric( IASR.NewReference) = 1 And CharIndex('.',  IASR.NewReference) = 0 ))   Then IASR.NewReference
Else Reverse(Left(Reverse(IsNull(IASR.NewReference,'')),PATINDEX(N'%[^0-9]%',Reverse(IsNull(IASR.NewReference,'')))-1)) End)
And IASR.SalesmanID In (Select SalesmanID From #tmpSalesMan)
And IASR.BeatID in (Select BeatID From #tmpBeat)

Insert Into #tmpSRInvNo
Select dbo.GetTrueVal(CD.OriginalID),InvA.PaymentMode
From InvoiceAbstract inva, CollectionDetail CD
Where (inva.Status & 128) = 0 And InvoiceType In (1, 3) And
 inva.InvoiceDate BETWEEN @FROMDATE AND @TODATE And
 ISnull(InVa.PaymentDetails,0)=CD.CollectionID And
 CD.DocumentType = 1 And inva.SalesmanID In (Select SalesmanID From #tmpSalesMan) And
 inva.BeatID in (Select BeatID From #tmpBeat) And
 inva.PaymentMode In (Select pid From #tmpPayMode2 Where PayMode In (Select PayMode From #tmpPayMode))

Insert Into #tmpSRInvNo
Select Inva.DocumentID,InvA.PaymentMode
From InvoiceAbstract inva
Where (inva.Status & 128) = 0 And
 InvoiceType in (1, 3) And
 inva.InvoiceDate BETWEEN @FROMDATE AND @TODATE And
 inva.SalesmanID In (Select SalesmanID From #tmpSalesMan) And
 inva.BeatID In (Select BeatID From #tmpBeat) And
 inva.PaymentMode In (Select pid From #tmpPayMode2 Where PayMode In (Select PayMode From #tmpPayMode))

Insert Into #tmpResult
SELECT  Isnull(inva.SalesmanID, 0 ),
(case isnull(inva.SalesmanID, 0 ) when 0 then @OTHERS else Salesman.Salesman_Name end),
Sum(Case InvoiceType When 4 Then 0 Else SalePrice * Quantity End),
Max(Case InvoiceType When 4 Then 0 Else (IsNull(inva.ProductDiscount,0) + IsNull(inva.DiscountValue,0) + IsNull(inva.AddlDiscountValue,0)) End),
Max(Case InvoiceType When 4 Then 0 Else IsNull(inva.TotalTaxApplicable,0) End),
Sum(Case InvoiceType When 4 Then 0 Else Amount End),
Case when inva.Balance > 0 And InvoiceType <> 4 Then 1 Else 0 End,
Sum(Case When IsNull(INVSRInvs.PaymentMode,0) > 0 And IsNull(INVSRInvs.PaymentMode,0) < 4 And InvoiceType <> 4 Then Amount Else 0 End),
Sum(Case When IsNull(INVSRInvs.PaymentMode,0) = 0 and InvoiceType <> 4 Then Amount Else 0 End),
Max(Case When IsNull(INVSRInvs.PaymentMode,0) > 0 And IsNull(INVSRInvs.PaymentMode,0) < 4 And InvoiceType = 4 Then NetValue Else 0 End),
Max(Case When IsNull(INVSRInvs.PaymentMode,0) = 0 and InvoiceType = 4 Then NetValue Else 0 End)
FROM InvoiceAbstract inva, Salesman, InvoiceDetail invd ,#tmpSRInvNo INVSRInvs
WHERE (inva.Status & 128) = 0 AND
(
(InvoiceType in (1,3) And inva.PaymentMode in (Select pid From #tmpPayMode2 Where PayMode in (Select PayMode From #tmpPayMode)))
Or
(InvoiceType =4)
)
 And inva.InvoiceDate BETWEEN @FROMDATE AND @TODATE And
 inva.SalesmanID In (Select SalesmanID From #tmpSalesMan) And
 inva.BeatID in (Select BeatID From #tmpBeat) And
 INVSRInvs.DocID = Inva.DocumentID And
 inva.InvoiceID = invd.InvoiceID And
 inva.SalesmanID = Salesman.SalesmanID
GROUP BY inva.InvoiceID, Inva.InvoiceType, inva.SalesmanID, Salesman.Salesman_Name, inva.Balance, INVSRInvs.PaymentMode

Select tr.SalesmanID, tr.Salesman, "Salesman Type" = DSTypeValue, "Goods Value (%c)" = Sum(GoodsValue), "Discount (%c)" = Sum(Discount),
"Tax Amount (%c)" = Sum(TaxAmount), "Net Value (%c)" = Sum(NetValue), "Pending Bills" = Sum(PendingBills),
"Other than Credit Invoice (%c)" = Sum(CashInvoices), "Credit Invoices (%c)" = Sum(CreditInvoices),
"Sales Return - Other than Credit Invoice (%c)" = Sum(SalesReturnCash), "Sales Return - Credit (%c)" = Sum(SalesReturnCredit)
From #tmpResult tr, #tmpDSType tds
Where tr.SalesmanID = tds.SalesmanID
Group By tr.SalesmanID, tr.Salesman, DSTypeValue Order By tr.Salesman

Drop Table #tmpSalesMan
Drop Table #tmpBeat
Drop Table #tmpPayMode
Drop Table #tmpPayMode2
Drop Table #tmpResult
Drop Table #tmpSRInvNo
Drop Table #tmpDSType
