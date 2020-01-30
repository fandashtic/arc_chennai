CREATE Procedure [dbo].[mERP_SP_ListEVATAbstract]
(
@FromDate datetime,
@ToDate datetime,
@OutputType nVarchar(50),
@Format nvarchar(100),
@Tax char(3)
)
As
Begin

Declare @Inv_Pre nvarchar(20)
SELECT @Inv_Pre = Prefix FROM VoucherPrefix WHERE TranID = N'INVOICE' 

If @Tax = N'%' Or Isnull(@Tax,'') = ''
Set @Tax = N'No'

If (@OutputType=N'Purchase' or @OutputType=N'') And @Tax = 'No'
Begin
CREATE Table #Purchasetemp
(
BillID int,
[Invoice No] nvarchar(20),
[Invoice Date] datetime,
[Seller Registration No] nvarchar(100),
[Seller Dealer Name] nvarchar(100),
[Seller Dealer Address] nvarchar(510),
[Value of Goods] decimal(18,6),
[Vat Amount Paid] decimal(18,6),
[Net Amount] decimal(18,6),
[Net Cess] decimal(18,6),
[Net Vat] decimal(18,6),
TaxCode nvarchar(10),
AdjustmentAmount decimal(18,6)
)

INSERT INTO #Purchasetemp
SELECT BA.BillID,
"Invoice No" = case when Invoicereference='' then cast(DocumentID as Nvarchar) else Invoicereference end,
"Invoice Date" = case (Select Max(IsNull(RecdInvoiceID,'')) From GRNAbstract Where BillID in (BA.BillID)) when '' then BillDate else (select Max(InvoiceDate) From InvoiceAbstractReceived Where DocumentID = BA.Invoicereference) end,
"Seller Registration No" = V.Tin_Number,
"Seller Dealer Name" = V.Vendor_name,
"Seller Dealer Address" =IsNull(REPLACE(REPLACE(REPLACE(Replace(Replace(Replace(Replace(Replace(Replace(V.Address,char(44),''),char(34),''),Char(39),''),char(62),''),char(60),''),char(38),''), CHAR(10), ''), CHAR(13), ''), CHAR(9), ''),''),

Sum(BD.Amount) As [Value of Goods],
Sum(BD.TaxAmount) As [Vat Amount Paid],
Sum(BD.Amount) + Sum(BD.TaxAmount) As [Net Amount],

"Net Cess" = CASE When Sum(BD.TaxAmount) <> 0 Then dbo.mERP_fn_Get_CalcPurchaseCess(BA.BillID, BD.TaxCode) Else 0 End,

"Net Vat" = CASE When Sum(BD.TaxAmount) <> 0 Then
Sum(BD.TaxAmount) - CASE When Sum(BD.TaxAmount) <> 0 Then dbo.mERP_fn_Get_CalcPurchaseCess(BA.BillID, BD.TaxCode) Else 0 End ELSE 0 END,
BD.TaxCode, Min(AdjustmentAmount)

from BillAbstract BA,Vendors V, BillDetail BD
where isnull(BA.Status,0) & 192 = 0
and BA.BillDate BETWEEN @FromDate AND @ToDate 
AND BA.BillID = BD.BillID
and V.VendorID=BA.VendorID
Group By BA.BillID, Invoicereference, BillDate, V.Tin_Number, V.Vendor_name, V.Address,
DocumentID, BD.TaxCode Order By 3

Select BillID, [Invoice No], [Invoice Date], [Seller Registration No], [Seller Dealer Name],
[Seller Dealer Address], Sum([Value of Goods]) As [Value of Goods], Sum([Vat Amount Paid]) As [Vat Amount Paid],
Sum([Net Vat]) As [Net Vat],Sum([Net Cess]) As [Net Cess], Sum([Net Amount]) + Min(AdjustmentAmount) As [Net Amount]
From #Purchasetemp Group By BillID, [Invoice No], [Invoice Date], [Seller Registration No],
[Seller Dealer Name], [Seller Dealer Address]

Drop Table #Purchasetemp
End

ELSE if @OutputType=N'Purchase' And @Tax = 'Yes'
BEGIN
CREATE Table #temp
(
BillID int,
[Invoice No] nvarchar(20),
DocumentID int,
[Invoice Date] datetime,
[Seller Registration No] nvarchar(100),
[Seller Dealer Name] nvarchar(100),
[Seller Dealer Address] nvarchar(510),
[Value of Goods] decimal(18,6),
[Vat Amount Paid] decimal(18,6),
[Net Amount] decimal(18,6),
[Net Cess] decimal(18,6),
[Net Vat] decimal(18,6),
TaxCode nvarchar(50),
Tax_Code decimal(18,6),
AdjustmentAmount decimal(18,6)
)

INSERT INTO #temp
Select Distinct BillAbstract.BillID As [Bill ID],
"Invoice No" = case when Invoicereference='' then cast(DocumentID as Nvarchar) else Invoicereference end,
BillAbstract.DocumentID,
"Invoice Date" = case (Select Max(IsNull(RecdInvoiceID,'')) From GRNAbstract Where BillID in (BillAbstract.BillID)) when '' then BillDate else (select Max(InvoiceDate) From InvoiceAbstractReceived Where DocumentID = BillAbstract.Invoicereference) end,
Vendors.TIN_Number As [Seller Registration No],
Vendor_Name As [Seller Dealer Name],
IsNull(REPLACE(REPLACE(REPLACE(Replace(Replace(Replace(Replace(Replace(Replace(Vendors.Address,char(44),''),char(34),''),Char(39),''),char(62),''),char(60),''),char(38),''), CHAR(10), ''), CHAR(13), ''), CHAR(9), ''),'') As [Seller Dealer Address],
Sum(BillDetail.Amount) As [Value of Goods],
Sum(BillDetail.TaxAmount) As [Vat Amount Paid],
Sum(BillDetail.Amount) + Sum(BillDetail.TaxAmount) As [Net Amount],

"Net Cess" = CASE When Sum(BillDetail.TaxAmount) <> 0 Then dbo.mERP_fn_Get_CalcPurchaseCess(BillAbstract.BillID, BillDetail.TaxCode) Else 0 End,

"Net Vat" = CASE When Sum(BillDetail.TaxAmount) <> 0 Then
Sum(BillDetail.TaxAmount) - CASE When Sum(BillDetail.TaxAmount) <> 0 Then dbo.mERP_fn_Get_CalcPurchaseCess(BillAbstract.BillID, BillDetail.TaxCode) Else 0 End ELSE 0 END,

BillDetail.TaxCode,BillDetail.TaxSuffered, Min(AdjustmentAmount)
From BillDetail
INNER JOIN BillAbstract ON BillAbstract.BillID = BillDetail.BillID
INNER JOIN Vendors ON Vendors.VendorID = BillAbstract.VendorID
LEFT JOIN Tax ON Tax.Tax_Code = BillDetail.TaxCode
Where 
BillAbstract.BillDate Between @FromDate AND @ToDate
And isnull(BillAbstract.Status,0) & 192 = 0
Group By BillAbstract.InvoiceReference, BillAbstract.BillID, BillAbstract.DocumentID, BillDate, Vendors.TIN_Number,
Vendor_Name, Address, BillDetail.TaxCode,BillDetail.TaxSuffered

Create Table #TaxComponentDetail
(
[TaxCode] Int,
[TaxDesc] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
[CompCode] Int,
[CompDesc] nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
[CompPercentage] decimal(18,6),
[LSTFlag] Int,
[TaxPerc] nvarchar(100),
[CompTaxPerc] nvarchar(100)
)

Insert Into #TaxComponentDetail
select tx.Tax_Code,Tax_Description,tc.TaxComponent_Code, TaxComponent_desc,SP_Percentage,tc.LST_Flag, Percentage, Tax_Percentage from Tax tx, TaxComponents tc,TaxComponentDetail tcd
Where Tx.Tax_Code = TC.Tax_Code and Tc.TaxComponent_Code = Tcd.TaxComponent_Code
order by tx.Tax_Code,tcd.TaxComponent_Code

Declare @TaxCode Int
Declare @TaxPerc decimal(18,3)
Declare @SQL varchar(8000)
Declare @DynamicQry varchar(8000)
Declare @CompTaxPerc decimal(18,3)
Declare @BillID int
Declare @ValAmount decimal(18,6)
Declare @VatAmount Decimal(18,6)
Declare @CompTaxAmt Decimal(18,6)
Declare @CompPerc Decimal(18,6)
Declare @SPPercentage Decimal(18,6)

Declare TaxFetch Cursor For
Select Distinct TaxCode, Tax_Code From #temp
Order By Tax_Code
SET @DynamicQry = ''
Open TaxFetch
Fetch next from Taxfetch into @TaxCode, @TaxPerc
While(@@FETCH_STATUS =0)
BEGIN
Set @SQL= N'Alter Table #temp Add [VAT_' +Cast(@TaxPerc as nvarchar(510)) + N' Value] decimal(18,6); '
Set @SQL= @SQL + N'Alter Table #temp Add [VAT_' +Cast(@TaxPerc as nvarchar(510)) + N' Tax] decimal(18,6) '

if Not Exists(Select name From tempdb..SysColumns Where Name = 'VAT_'
+ Cast(@TaxPerc as nvarchar) + N' Value' and ID = (OBJECT_ID('tempdb..#temp', 'U')))
BEGIN
SET @DynamicQry = @DynamicQry + '[VAT_' + Cast(@TaxPerc as nvarchar(510)) + N' Value],'
SET @DynamicQry = @DynamicQry + '[VAT_' + Cast(@TaxPerc as nvarchar(510)) + N' Tax],'
Exec(@SQL)
END


If exists(select CompCode from #TaxComponentDetail where TaxCode = @TaxCode) 
BEGIN
Declare ComponentFetch Cursor For
select Taxperc,CompTaxperc from #TaxComponentDetail
where TaxCode = @TaxCode and LSTFlag = 1 order by CompTaxperc desc
Open ComponentFetch
Fetch next from Componentfetch into @TaxPerc,@CompTaxPerc
While(@@FETCH_STATUS = 0)
BEGIN
Set @SQL = N'Alter Table #temp Add [VAT_' +Cast(@TaxPerc as nvarchar (100)) + N'('
+ Cast(@CompTaxPerc as nvarchar(510)) + N') Tax] decimal(18,6) '

if Not Exists(Select name From tempdb..SysColumns Where Name = 'VAT_'
+ Cast(@TaxPerc as nvarchar (100)) + N'('
+ Cast(@CompTaxPerc as nvarchar(510)) + N') Tax' and ID = (OBJECT_ID('tempdb..#temp', 'U')))
BEGIN
Exec(@SQL)
SET @DynamicQry = @DynamicQry + '[VAT_' +Cast(@TaxPerc as nvarchar (100))
+ N'(' + Cast(@CompTaxPerc as nvarchar(510)) + N') Tax],'
END
Fetch next from ComponentFetch into @TaxPerc,@CompTaxPerc
END
Close ComponentFetch
Deallocate ComponentFetch
END

Fetch next from Taxfetch into @TaxCode, @TaxPerc
END
close Taxfetch
deallocate Taxfetch


SET @TaxPerc = '0'
SET @CompTaxPerc = '0'
SET @ValAmount = '0'

Declare TaxUpdate Cursor For
Select Billid, [Value of Goods], [Vat Amount Paid], TaxCode, Tax_Code As Tax_Percentage
From #temp Order By Tax_Code

Open TaxUpdate
Fetch next from TaxUpdate into @BillID, @ValAmount, @VatAmount, @TaxCode, @TaxPerc
While(@@FETCH_STATUS =0)
BEGIN
SET @CompTaxAmt = '0'

SET @SQL=N'Update #temp SET [VAT_'
+ Cast(@TaxPerc as nvarchar) + N' Value]='
+ Cast(Sum(@ValAmount) as nvarchar) + ', [VAT_'
+ Cast(@TaxPerc as nvarchar(510)) + N' Tax]='
+ Cast(Sum(@VatAmount) as nvarchar)
+N' Where BillID='+ Cast(@BillID as varchar)
EXEC(@SQL)

SET @SQL = N'Update #temp Set [VAT_'
+Cast(@TaxPerc as nvarchar) + N' Value] = NULL where [VAT_'
+Cast(@TaxPerc as nvarchar(510)) + N' Value]=0'
EXEC(@SQL)

If exists(select CompCode from #TaxComponentDetail where TaxCode = @TaxCode)
BEGIN
Declare CompFetch Cursor For
select TaxPerc, CompTaxPerc, CompPercentage from #TaxComponentDetail
where TaxCode = @TaxCode and LSTFlag = 1 Order by CompTaxPerc Desc

Open CompFetch
Fetch next from CompFetch into @TaxPerc, @CompTaxPerc, @SPPercentage
While(@@FETCH_STATUS = 0)
BEGIN
Set @CompTaxAmt = Cast((@ValAmount * @SPPercentage/100) as Decimal(18,6))
Set @SQL=N'Update #temp Set [VAT_'
+ Cast(@TaxPerc as nvarchar)
+ N'('+ Cast(@CompTaxPerc as nvarchar) + N') Tax]=isnull([VAT_'
+ Cast(@TaxPerc as nvarchar)
+ N'('+ Cast(@CompTaxPerc as nvarchar) + N') Tax],0) + '
+ Cast(Isnull(@CompTaxAmt,0) as nvarchar)
+ N' Where BillID='+ Cast(@BillID as nvarchar)
EXEC(@SQL)
Fetch next from CompFetch into @TaxPerc, @CompTaxPerc, @SPPercentage
END
Close CompFetch
Deallocate CompFetch
END
Fetch next from TaxUpdate into @BillID, @ValAmount, @VatAmount, @TaxCode, @TaxPerc
END
Close TaxUpdate
Deallocate TaxUpdate
SET @DynamicQry = SubString(@DynamicQry, 0, Len(@DynamicQry))
Declare @SQry Varchar(8000)
Declare @GroupByQry Varchar(8000)

SET @SQry = 'ALTER Table #temp DROP Column TaxCode'
EXEC (@SQry)

SET @SQry = 'Select Distinct BillID, [Invoice No], [Invoice Date], '
SET @SQry = @SQry + '[Seller Registration No], [Seller Dealer Name], [Seller Dealer Address], '
SET @SQry = @SQry + 'Sum(isnull([Value of Goods],0)) As [Value of Goods], '
SET @SQry = @SQry + 'Sum(isnull([Vat Amount Paid],0)) As [Vat Amount Paid], '
SET @SQry = @SQry + 'Sum(isnull([Net Vat],0)) As [Net Vat], '
SET @SQry = @SQry + 'Sum([Net Cess]) As [Net Cess], Sum(isnull([Net Amount],0)) + Min(AdjustmentAmount) As [Net Amount], '

SET @GroupByQry = ' From #temp Group By BillID, [Invoice No], [Invoice Date], [Seller Registration No],[Seller Dealer Name], [Seller Dealer Address], '

IF (@DynamicQry <> '')
BEGIN
EXEC (@SQry + @DynamicQry + @GroupByQry + @DynamicQry + ' Order By 3')
END
ELSE
BEGIN
SET @SQry = 'ALTER Table #temp DROP Column AdjustmentAmount'
EXEC (@SQry)
Select DISTINCT * From #temp
END
DROP Table #temp
DROP Table #TaxComponentDetail
END
Else If @OutputType=N'Sales' And @Tax = 'No'

Begin
CREATE Table #SalesNotemp
(
InvoiceID int,
[Invoice No] nvarchar(70),
DocumentRefNo nvarchar(510),
[Invoice Date] datetime,
[Buyer Registration No] nvarchar(100),
[Buyer Dealer Name] nvarchar(100),
[Buyer Dealer Address] nvarchar(510),
[Value of Goods] decimal(18,6),
[Vat Amount Paid] decimal(18,6),
[Net Amount] decimal(18,6),
[Net Cess] decimal(18,6),
[Net Vat] decimal(18,6),
TaxID nvarchar(50)
)

Insert Into #SalesNotemp
Select InvoiceAbstract.InvoiceID, 
"Invoice No" = @Inv_Pre + CAST(DocumentID as nVarchar(50)),
"Document Reference" = IsNull(DocReference,''),
"Invoice Date" = InvoiceDate,
"Buyer Registration No" = C.Tin_Number,
"Buyer Dealer Name" = C.Company_Name,
"Buyer Dealer Address" = IsNull(REPLACE(REPLACE(REPLACE(Replace(Replace(Replace(Replace(Replace(Replace(C.BillingAddress,char(44),''),char(34),''),Char(39),''),char(62),''),char(60),''),char(38),''), CHAR(10), ''), CHAR(13), ''), CHAR(9), ''),''),

Sum(InvoiceDetail.Quantity * SalePrice) As [Value of Goods],
Sum(InvoiceDetail.STPayable) As [Vat Amount Paid],

Sum(Amount) As [Net Amount],

"Net Cess" = CASE When Sum(InvoiceDetail.STPayable) <> 0 Then dbo.mERP_fn_Get_CalcSalesCess(InvoiceAbstract.InvoiceID, InvoiceDetail.TaxID) Else 0 End,

"Net Vat" = CASE When Sum(InvoiceDetail.STPayable) <> 0 Then
Sum(InvoiceDetail.STPayable) - CASE When Sum(InvoiceDetail.STPayable) <> 0 Then dbo.mERP_fn_Get_CalcSalesCess(InvoiceAbstract.InvoiceID, InvoiceDetail.TaxID) Else 0 End ELSE 0 END,

InvoiceDetail.TaxID
FROM InvoiceAbstract, Customer C, InvoiceDetail
WHERE InvoiceType in (1,3) AND InvoiceDate BETWEEN @FromDate AND @ToDate
and InvoiceAbstract.CustomerID = C.CustomerID And InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID
and isnull(InvoiceAbstract.Status,0) & 192 = 0
Group By InvoiceAbstract.InvoiceID, DocReference, InvoiceDate, C.Tin_Number, C.Company_Name,
C.BillingAddress, DocumentID, InvoiceDetail.TaxID
Order By InvoiceDate

Select Distinct InvoiceID, [Invoice No], DocumentRefNo, [Invoice Date], [Buyer Registration No],
[Buyer Dealer Name], [Buyer Dealer Address], Sum([Value of Goods]) As [Value of Goods],
Sum([Vat Amount Paid]) As [Vat Amount Paid],
Sum([Net Vat]) As [Net Vat],Sum([Net Cess]) As [Net Cess],  Sum([Net Amount]) As [Net Amount]
From #SalesNotemp Group By  InvoiceID, [Invoice No], DocumentRefNo, [Invoice Date], [Buyer Registration No],
[Buyer Dealer Name], [Buyer Dealer Address] Order By 4
End

Else If @OutputType=N'Sales' And @Tax = 'Yes'
BEGIN
CREATE Table #Salestemp1
(
InvoiceID int,
[Invoice No] nvarchar(70),
DocumentRefNo nvarchar(510),
[Invoice Date] datetime,
[Buyer Registration No] nvarchar(100),
[Buyer Dealer Name] nvarchar(100),
[Buyer Dealer Address] nvarchar(510),
[Value of Goods] decimal(18,6),
[Vat Amount Paid] decimal(18,6),
[Net Amount] decimal(18,6),
[Net Cess] decimal(18,6),
[Net Vat] decimal(18,6),
TaxCode nvarchar(10),
DiscountValue decimal(18,6),
Tax_Code decimal(18,6),
Serial int
)
INSERT INTO #Salestemp1
Select Distinct InvoiceAbstract.InvoiceID As [Invoice ID],
"Invoice No" = @Inv_Pre + CAST(DocumentID as nVarchar(50)),
"Document Reference" = IsNull(DocReference,''),
InvoiceDate As [Invoice Date],
Customer.TIN_Number As [Seller Registration No],
Company_Name As [Seller Dealer Name],
IsNull(REPLACE(REPLACE(REPLACE(Replace(Replace(Replace(Replace(Replace(Replace(Customer.BillingAddress,char(44),''),char(34),''),Char(39),''),char(62),''),char(60),''),char(38),''), CHAR(10), ''), CHAR(13), ''), CHAR(9), ''),'') As [Seller Dealer Address],
Sum(InvoiceDetail.Quantity * SalePrice) As [Value of Goods],
Sum(InvoiceDetail.STPayable) As [Vat Amount Paid],
Sum(Amount) As [Net Amount],

"Net Cess" = CASE When Sum(InvoiceDetail.STPayable) <> 0 Then dbo.mERP_fn_Get_CalcSalesCess(InvoiceAbstract.InvoiceID, InvoiceDetail.TaxID) Else 0 End,

"Net Vat" = CASE When Sum(InvoiceDetail.STPayable) <> 0 Then
Sum(InvoiceDetail.STPayable) - CASE When Sum(InvoiceDetail.STPayable) <> 0 Then dbo.mERP_fn_Get_CalcSalesCess(InvoiceAbstract.InvoiceID, InvoiceDetail.TaxID) Else 0 End ELSE 0 END,
InvoiceDetail.TaxID, Sum(InvoiceDetail.DiscountValue), InvoiceDetail.TaxCode, InvoiceDetail.Serial From 
InvoiceDetail
INNER JOIN InvoiceAbstract ON InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
INNER JOIN Customer ON Customer.CustomerID = InvoiceAbstract.CustomerID
Where InvoiceAbstract.InvoiceDate Between @FromDate AND @ToDate
And InvoiceType in (1,3)
And isnull(InvoiceAbstract.Status,0) & 192 = 0
Group By InvoiceAbstract.InvoiceID,
InvoiceAbstract.DocumentID, InvoiceDate, Customer.TIN_Number, Company_Name,
Customer.BillingAddress, InvoiceDetail.TaxID, DocReference, InvoiceDetail.TaxCode
, InvoiceDetail.Serial

Select InvoiceID,
[Invoice No],
DocumentRefNo,
[Invoice Date] ,
[Buyer Registration No],
[Buyer Dealer Name] ,
[Buyer Dealer Address],
Sum([Value of Goods]) as [Value of Goods],
Sum([Vat Amount Paid]) as [Vat Amount Paid] ,
Sum([Net Amount])as [Net Amount] ,
Sum([Net Cess])as [Net Cess] ,
Sum([Net Vat])as [Net Vat] ,
Max(TaxCode) as TaxCode , 
Sum(DiscountValue) as DiscountValue ,
Max(Tax_Code) as Tax_Code,
Serial
into #Salestemp2 From #Salestemp1 Group By InvoiceID, [Invoice No], 
DocumentRefNo, [Invoice Date],[Buyer Registration No],
[Buyer Dealer Name] , [Buyer Dealer Address], Serial

Select InvoiceID,
[Invoice No],
DocumentRefNo,
[Invoice Date] ,
[Buyer Registration No],
[Buyer Dealer Name] ,
[Buyer Dealer Address],
Sum([Value of Goods]) as [Value of Goods],
Sum([Vat Amount Paid]) as [Vat Amount Paid] ,
Sum([Net Amount])as [Net Amount] ,
Max([Net Cess])as [Net Cess] ,
Sum([Net Vat])as [Net Vat] ,
Max(TaxCode) as TaxCode , 
Sum(DiscountValue) as DiscountValue ,
Tax_Code
into #Salestemp From #Salestemp2 Group By InvoiceID, [Invoice No], 
DocumentRefNo, [Invoice Date],[Buyer Registration No],
[Buyer Dealer Name] , [Buyer Dealer Address], Tax_Code

Create Table #SalesTaxComponentDetail
(
[TaxCode] Int,
[TaxDesc] nvarchar(510),
[CompCode] Int,
[SPPercentage] decimal(18,6),
[TaxPerc] decimal(18,6),
[CompTaxPerc] decimal(18,6)
)

Insert Into #SalesTaxComponentDetail
Select Tax.Tax_Code, Tax_Description, TaxComponent_Code, SP_Percentage, Tax.Percentage,
Tax_Percentage From Tax
INNER JOIN TaxComponents ON TaxComponents.Tax_Code = Tax.Tax_Code
Where LST_Flag = 1 Order By Tax.Tax_Code

Declare @sTaxCode Int
Declare @sTaxPerc decimal(18,3)
Declare @sSQL varchar(8000)
Declare @sDynamicQry varchar(8000)
Declare @sCompTaxPerc decimal(18,3)
Declare @sBillID int
Declare @sValAmount decimal(18,6)
Declare @sVatAmount Decimal(18,6)
Declare @sCompTaxAmt Decimal(18,6)
Declare @sCompPerc Decimal(18,6)
Declare @sSPPercentage Decimal(18,6)
Declare @sDiscount Decimal(18,6)

Declare sTaxFetch Cursor For
Select Distinct #Salestemp.TaxCode, Percentage From #Salestemp, Tax
Where Tax.Tax_Code = #Salestemp.TaxCode
And [Invoice Date] Between @FromDate AND @ToDate and #Salestemp.Tax_Code > 0

SET @sDynamicQry = ''
Open sTaxFetch
Fetch next from sTaxFetch into @sTaxCode, @sTaxPerc
While(@@FETCH_STATUS =0)
BEGIN
Set @sSQL= N'Alter Table #Salestemp Add [VAT_' +Cast(@sTaxPerc as nvarchar(510)) + N' Value] decimal(18,6); '
Set @sSQL= @sSQL + N'Alter Table #Salestemp Add [VAT_' +Cast(@sTaxPerc as nvarchar(510)) + N' Tax] decimal(18,6) '

if Not Exists(Select name From tempdb..SysColumns Where Name = 'VAT_'
+ Cast(@sTaxPerc as nvarchar) + N' Value' and ID = (OBJECT_ID('tempdb..#Salestemp', 'U')))
BEGIN
SET @sDynamicQry = @sDynamicQry + '[VAT_' + Cast(@sTaxPerc as nvarchar(510)) + N' Value],'
SET @sDynamicQry = @sDynamicQry + '[VAT_' + Cast(@sTaxPerc as nvarchar(510)) + N' Tax],'
Exec(@sSQL)
END

If exists(select CompCode from #SalesTaxComponentDetail where TaxCode = @sTaxCode)
BEGIN
Declare sComponentFetch Cursor For
select Taxperc, CompTaxperc from #SalesTaxComponentDetail
where TaxCode = @sTaxCode order by CompTaxperc desc
Open sComponentFetch
Fetch next from sComponentFetch into @sTaxPerc, @sCompTaxPerc
While(@@FETCH_STATUS = 0)
BEGIN
Set @sSQL = N'Alter Table #Salestemp Add [VAT_' +Cast(@sTaxPerc as nvarchar (100)) + N'('
+ Cast(@sCompTaxPerc as nvarchar(510)) + N') Tax] decimal(18,6) '

if Not Exists(Select name From tempdb..SysColumns Where Name = 'VAT_'
+ Cast(@sTaxPerc as nvarchar (100)) + N'('
+ Cast(@sCompTaxPerc as nvarchar(510)) + N') Tax'
and ID = (OBJECT_ID('tempdb..#Salestemp', 'U')))
BEGIN
Exec(@sSQL)
SET @sDynamicQry = @sDynamicQry + '[VAT_' +Cast(@sTaxPerc as nvarchar (100))
+ N'(' + Cast(@sCompTaxPerc as nvarchar(510)) + N') Tax],'
END
Fetch next from sComponentFetch into @sTaxPerc,@sCompTaxPerc
END
Close sComponentFetch
Deallocate sComponentFetch
END

Fetch next from sTaxFetch into @sTaxCode, @sTaxPerc
END
close sTaxFetch
deallocate sTaxFetch

SET @sTaxPerc = '0'
SET @sCompTaxPerc = '0'
SET @sValAmount = '0'

Declare sTaxUpdate Cursor For
Select InvoiceID, Sum([Value of Goods]), Sum([Vat Amount Paid]), TaxCode, Tax.Percentage, 
Sum(DiscountValue)
From #Salestemp, Tax Where 
 Tax.Tax_Code = #Salestemp.TaxCode And #Salestemp.Tax_Code > 0
Group By InvoiceID, TaxCode, Tax.Percentage

Open sTaxUpdate
Fetch next from sTaxUpdate into @sBillID, @sValAmount, @sVatAmount, @sTaxCode, @sTaxPerc,
@sDiscount
While(@@FETCH_STATUS =0)
BEGIN
SET @sCompTaxAmt = '0'

SET @sSQL=N'Update #Salestemp SET [VAT_'
+ Cast(@sTaxPerc as nvarchar) + N' Value]='
+ Cast(Sum(@sValAmount)  as nvarchar) + ', [VAT_'
+ Cast(@sTaxPerc as nvarchar) + N' Tax]='
+ Cast(Sum(@sVatAmount) as nvarchar)
+N' Where InvoiceID='+ Cast(@sBillID as varchar)
EXEC(@sSQL)

SET @sSQL = N'Update #Salestemp Set [VAT_'
+Cast(@sTaxPerc as nvarchar) + N' Value] = NULL where [VAT_'
+Cast(@sTaxPerc as nvarchar) + N' Value]=0'
EXEC(@sSQL)

If exists(select CompCode from #SalesTaxComponentDetail where TaxCode = @sTaxCode)
BEGIN
Declare sCompFetch Cursor For
select TaxPerc, CompTaxPerc, SPPercentage from #SalesTaxComponentDetail
where TaxCode = @sTaxCode Order by CompTaxPerc Desc

Open sCompFetch
Fetch next from sCompFetch into @sTaxPerc, @sCompTaxPerc, @sSPPercentage
While(@@FETCH_STATUS = 0)
BEGIN
Set @sCompTaxAmt = Cast((Sum(@sValAmount) * @sSPPercentage/100) as Decimal(18,6))
Set @sSQL=N'Update #Salestemp Set [VAT_'
+ Cast(@sTaxPerc as nvarchar)
+ N'('+ Cast(@sCompTaxPerc as nvarchar) + N') Tax]=isnull([VAT_'
+ Cast(@sTaxPerc as nvarchar)
+ N'('+ Cast(@sCompTaxPerc as nvarchar) + N') Tax],0) + '
+ Cast(Isnull(@sCompTaxAmt,0) as nvarchar)
+ N' Where InvoiceID='+ Cast(@sBillID as nvarchar)
EXEC(@sSQL)
Fetch next from sCompFetch into @sTaxPerc, @sCompTaxPerc, @sSPPercentage
END
Close sCompFetch
Deallocate sCompFetch
END
Fetch next from sTaxUpdate into @sBillID, @sValAmount, @sVatAmount, @sTaxCode, @sTaxPerc,
@sDiscount
END
Close sTaxUpdate
Deallocate sTaxUpdate

SET @sDynamicQry = SubString(@sDynamicQry, 0, Len(@sDynamicQry))

Declare @sSQry Varchar(8000)
Declare @ExemptQry Varchar(8000)
Declare @sGroupByQry Varchar(8000)

if Exists(Select * From #Salestemp Where Tax_Code = '0.000000')
BEGIN
Set @sSQry = N'Alter Table #Salestemp Add [VAT_0.000 Value] decimal(18,6)'
EXEC (@sSQry)
Set @sSQry = N'Alter Table #Salestemp Add [VAT_0.000 Tax] decimal(18,6)'
EXEC (@sSQry)
END

if Exists(Select name From tempdb..SysColumns Where Name = 'VAT_0.000 Tax'
and ID = (OBJECT_ID('tempdb..#Salestemp', 'U')))
BEGIN
Update #Salestemp SET [VAT_0.000 Tax] = 0
Update #Salestemp SET [VAT_0.000 Value] = [Value of Goods] Where Tax_Code = '0.000000'
Update #Salestemp SET [VAT_0.000 Value] = 0 Where [VAT_0.000 Value] is NULL
SET @ExemptQry = 'Sum(isnull([VAT_0.000 Value],0)) As [VAT_0.000 Value], Sum([VAT_0.000 Tax]) As [VAT_0.000 Tax], '
END


SET @sSQry = 'ALTER Table #Salestemp DROP Column TaxCode'
EXEC (@sSQry)
SET @sSQry = 'ALTER Table #Salestemp DROP Column Tax_Code'
EXEC (@sSQry)
SET @sSQry = 'ALTER Table #Salestemp DROP Column DiscountValue'
EXEC (@sSQry)

SET @sSQry = 'Select Distinct InvoiceID, [Invoice No], DocumentRefNo, [Invoice Date], '
SET @sSQry = @sSQry + '[Buyer Registration No],[Buyer Dealer Name],[Buyer Dealer Address], '
SET @sSQry = @sSQry + 'Sum(isnull([Value of Goods],0)) As [Value of Goods], '
SET @sSQry = @sSQry + 'Sum(isnull([Vat Amount Paid],0)) As [Vat Amount Paid], '
SET @sSQry = @sSQry + 'Sum(isnull([Vat Amount Paid],0)) - Sum([Net Cess]) As [Net Vat], '
SET @sSQry = @sSQry + 'Sum([Net Cess]) As [Net Cess], '
SET @sSQry = @sSQry + 'Sum(isnull([Net Amount],0)) As [Net Amount], '
if Exists(Select name From tempdb..SysColumns Where Name = 'VAT_0.000 Tax'
and ID = (OBJECT_ID('tempdb..#Salestemp', 'U')))
BEGIN
SET @sSQry = @sSQry + @ExemptQry
END
SET @sGroupByQry = ' From #Salestemp Group By InvoiceID, [Invoice No], DocumentRefNo, '
SET @sGroupByQry = @sGroupByQry + '[Invoice Date], [Buyer Registration No], '
SET @sGroupByQry = @sGroupByQry + '[Buyer Dealer Name], [Buyer Dealer Address], '

IF (@sDynamicQry <> '')
BEGIN
EXEC (@sSQry + @sDynamicQry + @sGroupByQry + @sDynamicQry + ' Order By 4')
END
ELSE
Select DISTINCT * From #Salestemp

Drop Table #Salestemp
Drop Table #Salestemp1
Drop Table #Salestemp2
Drop Table #SalesTaxComponentDetail
END
End
