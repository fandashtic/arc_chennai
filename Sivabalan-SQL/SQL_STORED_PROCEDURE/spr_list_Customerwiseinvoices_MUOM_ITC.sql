CREATE PROCEDURE spr_list_Customerwiseinvoices_MUOM_ITC
(
@FROMDATE datetime,
@TODATE datetime,
@DocType nvarchar(100), @UOMDesc nVarchar(30),
@Salesman nvarchar(4000),
@TaxCompBrkUp nVARCHAR(10)
)
AS

DECLARE @INV AS NVARCHAR(50)
DECLARE @CASH AS NVARCHAR(50)
DECLARE @CREDIT AS NVARCHAR(50)
DECLARE @CHEQUE AS NVARCHAR(50)
DECLARE @DD AS NVARCHAR(50)
Declare @CS_TaxCode int

SELECT @CASH = DBO.LookUpDictionaryItem(N'Cash',default)
SELECT @CREDIT = DBO.LookUpDictionaryItem(N'Credit',default)
SELECT @CHEQUE = DBO.LookUpDictionaryItem(N'Cheque',default)
SELECT @DD = DBO.LookUpDictionaryItem(N'DD',default)

SELECT @INV = Prefix FROM VoucherPrefix WHERE TranID = N'INVOICE'

DECLARE @Delimiter as Char(1)
SET @Delimiter=Char(15)

Declare @InvoiceID int
Declare @Tax_Code int
Declare @isColExist int
Declare @Tax_Description nvarchar(510)
Declare @Tax_Comp_Desc nvarchar(510)
Declare @Tax_Comp_Code int

Declare @ColName nvarchar(510)
Declare @SQL nvarchar(4000)
Declare @LTPrefix nvarchar(25)
Declare @CTPrefix nvarchar(25)

Declare @IntraPrefix nvarchar(25)
Declare @InterPrefix nvarchar(25)

set @LTPrefix = 'LST'
set @CTPrefix = 'CST'

set @IntraPrefix = 'Intra'
set @InterPrefix = 'Inter'

create table #TaxLog(Tax_Code int, LST_Flag int)

Create Table #tempSalesMan (Salesman_Name NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS)

Declare @Delimeter as Char(1)
Set @Delimeter=Char(15)

Declare @tmpCustId table(CustomerID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
Declare @tmpCustName Table(CustomerName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

--If @CustName='%'
--   Insert into @tmpCustId select CustomerId From Customer where customerid <>'0' and CustomerCategory not in (4,5)
--Else
--Begin
--   Insert into @tmpCustName select * from dbo.sp_SplitIn2Rows(@CustName,@Delimeter)
--   insert into @tmpCustId select CustomerId From Customer where CustomerID
--    In(select * from  @tmpCustName) and CustomerCategory not in (4,5)
--end
If @Salesman = '%'
Insert Into #tempSalesMan
Select Salesman_Name From Salesman
Else
Insert Into #tempSalesMan Select * From DBO.sp_SplitIn2Rows(@Salesman,@Delimiter)

--Customer wise Invoice Report Changes --FRITFITC-1639
--Truncate Table @tmpCustId
Insert into @tmpCustId select CustomerId From InvoiceReportCustomer_Mapping

if @TaxCompBrkUp <> 'Yes'

Begin
SELECT  InvoiceID,
"InvoiceID" = case IsNull(GSTFLAG,0)
when 0 Then @INV + CAST(DocumentID AS nVARCHAR)
Else isnull(InvoiceAbstract.GSTFullDocID,'')
End ,
"Doc Ref" = InvoiceAbstract.DocReference,
"Date" = InvoiceDate,
"Payment Mode" = case IsNull(PaymentMode,0)
When 0 Then @Credit
When 1 Then @Cash
When 2 Then @Cheque
When 3 Then @DD
Else @Credit
End,
"Payment Date" = PaymentDate,
"Credit Term" = CreditTerm.Description,
"CustomerID" = Customer.CustomerID,
"Customer" = Customer.Company_Name,
"AlternateCustomerName" = isnull(InvoiceAbstract.AlternateCGCustomerName,''),
"Billing Address" = ISNULL(InvoiceAbstract.BillingAddress,''),
"Forum Code" = Customer.AlternateCode,
"Goods Value" = GoodsValue,
"Product Discount" = ProductDiscount,
"Trade Discount%" = CAST(Cast(DiscountPercentage as Decimal(18,6)) AS nvarchar) + N'%',
"Trade Discount" = Cast(InvoiceAbstract.GoodsValue * (DiscountPercentage /100) as Decimal(18,6)),
"Addl Discount%" = CAST(AdditionalDiscount AS nvarchar) + N'%',
"Addl Discount" = Isnull(AddlDiscountValue, 0),
Freight, "Net Value" = NetValue,
"Net Volume" = Cast((
Case
When @UOMdesc = N'UOM1' then
(Select Sum(dbo.sp_Get_ReportingQty(Quantity,Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 Else Items.UOM1_Conversion End)) from Items, InvoiceDetail
Where Items.Product_Code = InvoiceDetail.Product_Code and
InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID)
When @UOMdesc = N'UOM2' then
(Select Sum(dbo.sp_Get_ReportingQty(Quantity,Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 Else Items.UOM2_Conversion End)) from Items, InvoiceDetail
Where Items.Product_Code = InvoiceDetail.Product_Code and
InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID)
Else
(Select Sum(Quantity) from Items, InvoiceDetail
Where Items.Product_Code = InvoiceDetail.Product_Code and
InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID)
End) as nVarchar),
"Adj Ref" = IsNull(InvoiceAbstract.AdjRef, N''),
"Adjusted Amount" = IsNull(InvoiceAbstract.AdjustedAmount, 0),
"Balance" = InvoiceAbstract.Balance,
"Collected Amount" = NetValue - IsNull(InvoiceAbstract.AdjustedAmount, 0) - IsNull(InvoiceAbstract.Balance, 0) + IsNull(RoundOffAmount, 0),
"Branch" = ClientInformation.Description,
"Beat" = Beat.Description,
"Salesman" = Salesman.Salesman_Name,
"Reference" =
CASE Status & 15
WHEN 1 THEN
''
WHEN 2 THEN
''
WHEN 4 THEN
''
WHEN 8 THEN
''
END
+ CAST(NewReference AS nVARCHAR),
"Round Off" = RoundOffAmount,
"Document Type" = DocSerialType,
"Total TaxSuffered Value" =  TotalTaxSuffered,
"Total SalesTax Value" = TotalTaxApplicable,
"GSTIN OF Outlet" = InvoiceAbstract.GSTIN,
"OutletStateCode" = ToStateCode
FROM InvoiceAbstract
Inner Join Customer On  InvoiceAbstract.CustomerID = Customer.CustomerID
Left Outer Join CreditTerm On  InvoiceAbstract.CreditTerm = CreditTerm.CreditID
Left Outer Join ClientInformation On InvoiceAbstract.ClientID = ClientInformation.ClientID
Left Outer Join Beat On InvoiceAbstract.BeatID = Beat.BeatID
Inner Join  Salesman  On  InvoiceAbstract.SalesmanID = Salesman.SalesmanID
WHERE  InvoiceType in (1,3) AND InvoiceDate BETWEEN @FROMDATE AND @TODATE AND
(InvoiceAbstract.Status & 128) = 0 And
InvoiceAbstract.DocSerialType like @DocType
and Salesman.Salesman_Name in  (select Salesman_Name from #tempSalesMan)
And InvoiceAbstract.CustomerId in (Select * from @tmpCustId)
Order By  DocumentID
End
Else
Begin

Select * into #tmpMainData from
(
SELECT top 100 percent InvoiceID as InvoiceID1,
"InvoiceID" = case IsNull(GSTFLAG,0)
when 0 Then @INV + CAST(DocumentID AS nVARCHAR)
ELSE isnull(InvoiceAbstract.GSTFullDocID,'')
End ,
"Doc Ref" = InvoiceAbstract.DocReference,
"Date" = InvoiceDate,
"Payment Mode" = case IsNull(PaymentMode,0)
When 0 Then @Credit
When 1 Then @Cash
When 2 Then @Cheque
When 3 Then @DD
Else @Credit
End,
"Payment Date" = PaymentDate,
"Credit Term" = CreditTerm.Description,
"CustomerID" = Customer.CustomerID,
"Customer" = Customer.Company_Name,
"AlternateCustomerName" = isnull(InvoiceAbstract.AlternateCGCustomerName,''),
"Billing Address" = ISNULL(InvoiceAbstract.BillingAddress,''),
"Forum Code" = Customer.AlternateCode,
"Goods Value" = GoodsValue,
"Product Discount" = ProductDiscount,
"Trade Discount%" = CAST(Cast(DiscountPercentage as Decimal(18,6)) AS nvarchar) + N'%',
"Trade Discount" = Cast(InvoiceAbstract.GoodsValue * (DiscountPercentage /100) as Decimal(18,6)),
"Addl Discount%" = CAST(AdditionalDiscount AS nvarchar) + N'%',
"Addl Discount" = Isnull(AddlDiscountValue, 0),
Freight, "Net Value" = NetValue,
"Net Volume" = Cast((
Case
When @UOMdesc = N'UOM1' then
(Select Sum(dbo.sp_Get_ReportingQty(Quantity,Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 Else Items.UOM1_Conversion End)) from Items, InvoiceDetail
Where Items.Product_Code = InvoiceDetail.Product_Code and
InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID)
When @UOMdesc = N'UOM2' then
(Select Sum(dbo.sp_Get_ReportingQty(Quantity,Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 Else Items.UOM2_Conversion End)) from Items, InvoiceDetail
Where Items.Product_Code = InvoiceDetail.Product_Code and
InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID)
Else
(Select Sum(Quantity) from Items, InvoiceDetail
Where Items.Product_Code = InvoiceDetail.Product_Code and
InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID)
End) as nVarchar),
"Adj Ref" = IsNull(InvoiceAbstract.AdjRef, N''),
"Adjusted Amount" = IsNull(InvoiceAbstract.AdjustedAmount, 0),
"Balance" = InvoiceAbstract.Balance,
"Collected Amount" = NetValue - IsNull(InvoiceAbstract.AdjustedAmount, 0) - IsNull(InvoiceAbstract.Balance, 0) + IsNull(RoundOffAmount, 0),
"Branch" = ClientInformation.Description,
"Beat" = Beat.Description,
"Salesman" = Salesman.Salesman_Name,
"Reference" =
CASE Status & 15
WHEN 1 THEN
''
WHEN 2 THEN
''
WHEN 4 THEN
''
WHEN 8 THEN
''
END
+ CAST(NewReference AS nVARCHAR),
"Round Off" = RoundOffAmount,
"Document Type" = DocSerialType,
"Total TaxSuffered Value" =  TotalTaxSuffered,
"Total SalesTax Value" = TotalTaxApplicable ,
"GSTIN OF Outlet" = InvoiceAbstract.GSTIN,
"OutletStateCode" = ToStateCode
FROM InvoiceAbstract
Inner Join  Customer On InvoiceAbstract.CustomerID = Customer.CustomerID
Left Outer Join CreditTerm On InvoiceAbstract.CreditTerm = CreditTerm.CreditID
Left Outer Join  ClientInformation On  InvoiceAbstract.ClientID = ClientInformation.ClientID
Left Outer Join Beat On InvoiceAbstract.BeatID = Beat.BeatID
Inner Join Salesman On InvoiceAbstract.SalesmanID = Salesman.SalesmanID
WHERE  InvoiceType in (1,3) AND InvoiceDate BETWEEN @FROMDATE AND @TODATE AND
(InvoiceAbstract.Status & 128) = 0 And
InvoiceAbstract.DocSerialType like @DocType
and Salesman.Salesman_Name in  (select Salesman_Name from #tempSalesMan)
And InvoiceAbstract.CustomerId in (Select * from @tmpCustId)
Order By  DocumentID
) tmp

--for each invoice get the tax detail
Declare cr_Invoice cursor static  for select InvoiceID1 from #tmpMainData
open cr_Invoice
fetch next from cr_Invoice into @InvoiceID
while @@Fetch_Status = 0
Begin
--Get the Taxes Involved in the invoices
Declare cr_Taxes cursor for
select Distinct Tax.Tax_Code, Tax.Tax_Description,Tax.CS_TaxCode
from InvoiceDetail, Tax
where InvoiceDetail.InvoiceID =  @InvoiceID
and InvoiceDetail.TaxID = Tax.Tax_Code
open cr_Taxes
fetch next from cr_Taxes into @Tax_Code, @Tax_Description,@CS_TaxCode

While @@Fetch_Status = 0
Begin
--Log the Tax into a table to find whether tax column already created
--If not created already add the tax and component columns
set @isColExist = 0
if not exists(Select * from #TaxLog where Tax_code = @Tax_code and LST_Flag = 1)
set @isColExist = 1
--         if exists (
--                    select * from InvoiceTaxComponents, TaxComponents, InvoiceDetail
--                    where InvoiceTaxComponents.InvoiceID = InvoiceDetail.InvoiceID
--                          and InvoiceTaxComponents.Tax_Code = InvoiceDetail.TaxID
--                          and InvoiceTaxComponents.Tax_Code = TaxComponents.Tax_Code
--                          and TaxComponents.Tax_Code = InvoiceDetail.TaxID
--                          and InvoiceTaxComponents.Tax_Component_Code = TaxComponents.TaxComponent_Code
--                          and LST_Flag = 1
--                          and InvoiceDetail.STPAyable > 0
--                          and InvoiceTaxComponents.Tax_Value > 0
--                          and InvoiceDetail.InvoiceID = @InvoiceID
--                          and InvoiceTaxComponents.Tax_Code = @Tax_Code
--                   )
--         Begin
insert into #TaxLog values (@Tax_Code, 1)

--Create or update the LST Column for the tax

if(@CS_TaxCode > 0)
set @ColName = @IntraPrefix + N'_' + @Tax_Description
else
set @ColName = @LTPrefix + N'_' + @Tax_Description

Set @SQL=N'Alter Table #tmpMainData Add [' + @ColName +  N'] decimal(18,6) default 0;'
if @isColExist = 1
Begin
Exec(@SQL)
Set @SQL = N'Update #tmpMainData set [' + @ColName +  N'] = 0;'
Exec(@SQL)
End
--Update LST Column for the tax for the InvoiceID
set @SQL = N'update #tmpMainData '
set @SQL = @SQL + N'set [' + @ColName + N'] ='
set @SQL = @SQL + N'         ('
set @SQL = @SQL + N'             select isnull(sum(InvoiceTaxComponents.Tax_Value),0) as TaxVal'
set @SQL = @SQL + N'             from (select InvoiceID, TaxID, sum(isnull(STPayable,0)) as STPayable from InvoiceDetail where InvoiceDetail.invoiceid = ' + cast(@InvoiceID as nvarchar) + ' group by InvoiceID, TaxID) as InvoiceDetail, InvoiceTaxComponents '
set @SQL = @SQL + N'             where InvoiceDetail.invoiceid = ' + cast(@InvoiceID as nvarchar)
set @SQL = @SQL + N'                   and Tax_Code = ' + cast(@Tax_Code as nvarchar)
set @SQL = @SQL + N'                   and isnull(STPayable,0) > 0'
set @SQL = @SQL + N'                   and InvoiceDetail.InvoiceID = InvoiceTaxComponents.InvoiceID'
set @SQL = @SQL + N'                   and InvoiceDetail.TaxID = InvoiceTaxComponents.Tax_Code'
set @SQL = @SQL + N'         ) where InvoiceID1 = ' + cast(@InvoiceID as nvarchar)
Exec(@SQL)
--Create or update the LST Columns for the tax components
Declare cr_TxComp cursor for
--               select TaxComponentDetail.TaxComponent_Desc, Taxcomponents.TaxComponent_Code
--               from Taxcomponents, TaxComponentDetail
--               where Taxcomponents.Tax_code = @Tax_code
--                     and LST_Flag = 1 --Local Station
--                     and Taxcomponents.Taxcomponent_Code = TaxcomponentDetail.Taxcomponent_Code
--               order by Taxcomponents.TaxComponent_Code
select distinct TaxComponentDetail.TaxComponent_Desc, TaxComponentDetail.TaxComponent_code
from InvoiceTaxComponents, TaxComponentDetail
where invoiceID in (
select invoiceid
from InvoiceDetail
where invoiceid in (Select InvoiceID1 from #TmpMainData)
and isnull(STPayable,0) <> 0
)
and InvoiceTaxComponents.Tax_code = @Tax_code
and InvoiceTaxComponents.Tax_Component_code = TaxComponentDetail.TaxComponent_code
order by TaxComponentDetail.TaxComponent_code
open cr_TxComp
fetch next from cr_TxComp into @Tax_Comp_Desc, @Tax_Comp_Code
While @@Fetch_Status = 0
Begin
--      if exists (select * from InvoiceTaxComponents where InvoiceID = @InvoiceID and Tax_Code = @Tax_Code and Tax_Component_Code = @Tax_Comp_Code)
--               Begin

if(@CS_TaxCode > 0)
set @ColName = @IntraPrefix  + N'_' + @Tax_Comp_Desc + N'_of_' + @Tax_Description
else
set @ColName = @LTPrefix  + N'_' + @Tax_Comp_Desc + N'_of_' + @Tax_Description

Set @SQL=N'Alter Table #tmpMainData Add [' + @ColName +  N'] decimal(18,6) default 0;'
if @isColExist = 1
Begin
Exec(@SQL)
Set @SQL = N'Update #tmpMainData set [' + @ColName +  N'] = 0;'
Exec(@SQL)
End
--Update LST Columns for the tax components  for the Tax
set @SQL = N'update #tmpMainData '
set @SQL = @SQL + N'set [' + @ColName + N'] ='
set @SQL = @SQL + N'         ('
set @SQL = @SQL + N'             select isnull(sum(InvoiceTaxComponents.Tax_Value),0) as TaxVal'
set @SQL = @SQL + N'             from (select InvoiceID, TaxID, sum(isnull(STPayable,0)) as STPayable from InvoiceDetail where InvoiceDetail.invoiceid = ' + cast(@InvoiceID as nvarchar) + ' group by InvoiceID, TaxID) as InvoiceDetail, InvoiceTaxComponents '
set @SQL = @SQL + N'             where InvoiceDetail.invoiceid = ' + cast(@InvoiceID as nvarchar)
set @SQL = @SQL + N'                   and Tax_Code = ' + cast(@Tax_Code as nvarchar)
set @SQL = @SQL + N'                   and Tax_Component_Code = ' + cast(@Tax_Comp_Code as nvarchar)
set @SQL = @SQL + N'                   and isnull(STPayable,0) > 0'
set @SQL = @SQL + N'                   and InvoiceDetail.InvoiceID = InvoiceTaxComponents.InvoiceID'
set @SQL = @SQL + N'                   and InvoiceDetail.TaxID = InvoiceTaxComponents.Tax_Code'
set @SQL = @SQL + N'         ) where InvoiceID1 = ' + cast(@InvoiceID as nvarchar)
Exec(@SQL)
--                End
fetch next from cr_TxComp into @Tax_Comp_Desc, @Tax_Comp_Code
End
close cr_TxComp
Deallocate cr_TxComp
--taxcomponent  End
--Create or update the CST Column for the tax

set @isColExist = 0
if not exists(Select * from #TaxLog where Tax_code = @Tax_code and LST_Flag = 0)
set @isColExist = 1


--         if exists (
--                    select * from InvoiceTaxComponents, TaxComponents, InvoiceDetail
--                    where InvoiceTaxComponents.InvoiceID = InvoiceDetail.InvoiceID
--                          and InvoiceTaxComponents.Tax_Code = InvoiceDetail.TaxID
--                          and InvoiceTaxComponents.Tax_Code = TaxComponents.Tax_Code
--                          and TaxComponents.Tax_Code = InvoiceDetail.TaxID
--                          and InvoiceTaxComponents.Tax_Component_Code = TaxComponents.TaxComponent_Code
--                          and LST_Flag = 0
--                          and InvoiceDetail.CSTPAyable > 0
--                          and InvoiceTaxComponents.Tax_Value > 0
--                          and InvoiceDetail.InvoiceID = @InvoiceID
--                          and InvoiceTaxComponents.Tax_Code = @Tax_Code
--                   ) --If data exist then create col
--         Begin

insert into #TaxLog values (@Tax_Code, 0)
if(@CS_TaxCode > 0)
set @ColName = @InterPrefix  + N'_' + @Tax_Description
else
set @ColName = @CTPrefix  + N'_' + @Tax_Description
Set @SQL=N'Alter Table #tmpMainData Add [' + @ColName +  N'] decimal(18,6) default 0;'
if @isColExist = 1
Begin
Exec(@SQL)
Set @SQL = N'Update #tmpMainData set [' + @ColName +  N'] = 0;'
Exec(@SQL)
End
--Update CST Column for the tax for the InvoiceID
set @SQL = N'update #tmpMainData '
set @SQL = @SQL + N'set [' + @ColName + N'] ='
set @SQL = @SQL + N'         ('
set @SQL = @SQL + N'             select isnull(sum(InvoiceTaxComponents.Tax_Value),0) as TaxVal'
set @SQL = @SQL + N'             from (select InvoiceID, TaxID, sum(isnull(CSTPayable,0)) as CSTPayable from InvoiceDetail where InvoiceDetail.invoiceid = ' + cast(@InvoiceID as nvarchar) + ' group by InvoiceID, TaxID) as InvoiceDetail, InvoiceTaxComponents '
set @SQL = @SQL + N'             where InvoiceDetail.invoiceid = ' + cast(@InvoiceID as nvarchar)
set @SQL = @SQL + N'                   and Tax_Code = ' + cast(@Tax_Code as nvarchar)
set @SQL = @SQL + N'                   and isnull(CSTPayable,0) > 0'
set @SQL = @SQL + N'                   and InvoiceDetail.InvoiceID = InvoiceTaxComponents.InvoiceID'
set @SQL = @SQL + N'                   and InvoiceDetail.TaxID = InvoiceTaxComponents.Tax_Code'
set @SQL = @SQL + N'         ) where InvoiceID1 = ' + cast(@InvoiceID as nvarchar)
Exec(@SQL)

--Create or update the CST Columns for the tax components
Declare cr_TxComp cursor for
--               select TaxComponentDetail.TaxComponent_Desc, Taxcomponents.TaxComponent_Code
--               from Taxcomponents, TaxComponentDetail
--               where Taxcomponents.Tax_code = @Tax_code
--                     and LST_Flag = 0 --Out Station
--                     and Taxcomponents.Taxcomponent_Code = TaxcomponentDetail.Taxcomponent_Code
--               order by Taxcomponents.TaxComponent_Code
select distinct TaxComponentDetail.TaxComponent_Desc, TaxComponentDetail.TaxComponent_code
from InvoiceTaxComponents, TaxComponentDetail
where invoiceID in (
select invoiceid
from InvoiceDetail
where invoiceid in (Select InvoiceID1 from #TmpMainData)
and isnull(CSTPayable,0) <> 0
)
and InvoiceTaxComponents.Tax_code = @Tax_code
and InvoiceTaxComponents.Tax_Component_code = TaxComponentDetail.TaxComponent_code
order by TaxComponentDetail.TaxComponent_code

open cr_TxComp
fetch next from cr_TxComp into @Tax_Comp_Desc, @Tax_Comp_Code
While @@Fetch_Status = 0
Begin
--                    if exists (select * from InvoiceTaxComponents where InvoiceID = @InvoiceID and Tax_Code = @Tax_Code and Tax_Component_Code = @Tax_Comp_Code)
--                    Begin
if(@CS_TaxCode > 0)
set @ColName = @InterPrefix  + N'_' + @Tax_Comp_Desc + N'_of_' + @Tax_Description
else
set @ColName = @CTPrefix  + N'_' + @Tax_Comp_Desc + N'_of_' + @Tax_Description
Set @SQL=N'Alter Table #tmpMainData Add [' + @ColName +  N'] decimal(18,6) default 0;'
if @isColExist = 1
Begin
Exec(@SQL)
Set @SQL = N'Update #tmpMainData set [' + @ColName +  N'] = 0;'
Exec(@SQL)
End

--Update LST Columns for the tax components for the Tax
set @SQL = N'update #tmpMainData '
set @SQL = @SQL + N'set [' + @ColName + N'] ='
set @SQL = @SQL + N'         ('
set @SQL = @SQL + N'             select isnull(sum(InvoiceTaxComponents.Tax_Value),0) as TaxVal'
set @SQL = @SQL + N'             from (select InvoiceID, TaxID, sum(isnull(CSTPayable,0)) as CSTPayable from InvoiceDetail where InvoiceDetail.invoiceid = ' + cast(@InvoiceID as nvarchar) + ' group by InvoiceID, TaxID) as InvoiceDetail, InvoiceTaxComponents '
set @SQL = @SQL + N'             where InvoiceDetail.invoiceid = ' + cast(@InvoiceID as nvarchar)
set @SQL = @SQL + N'                   and Tax_Code = ' + cast(@Tax_Code as nvarchar)
set @SQL = @SQL + N'                   and Tax_Component_Code = ' + cast(@Tax_Comp_Code as nvarchar)
set @SQL = @SQL + N'                   and isnull(CSTPayable,0) > 0'
set @SQL = @SQL + N'                   and InvoiceDetail.InvoiceID = InvoiceTaxComponents.InvoiceID'
set @SQL = @SQL + N'                   and InvoiceDetail.TaxID = InvoiceTaxComponents.Tax_Code'
set @SQL = @SQL + N'         ) where InvoiceID1 = ' + cast(@InvoiceID as nvarchar)
Exec(@SQL)
--                    End
fetch next from cr_TxComp into @Tax_Comp_Desc, @Tax_Comp_Code
End
close cr_TxComp
Deallocate cr_TxComp
-- End
fetch next from cr_Taxes into @Tax_Code, @Tax_Description ,@CS_TaxCode
End
close cr_Taxes
Deallocate cr_Taxes
fetch next from cr_Invoice into @InvoiceID
End
close cr_Invoice
Deallocate cr_Invoice
select * from #tmpMainData
drop table #tempSalesMan
drop table #tmpMainData
drop table #TaxLog
End
