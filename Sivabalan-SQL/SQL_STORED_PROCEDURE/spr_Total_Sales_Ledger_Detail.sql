CREATE Procedure spr_Total_Sales_Ledger_Detail (@Unused int,
						@FromDate datetime,
						@ToDate datetime)
As
Declare @VoucherPrefix nvarchar(15)
Declare @MLSalesReturnSaleable NVarchar(50)
Declare @MLSalesReturnDamages NVarchar(50)
Declare @MLRetailInvoice NVarchar(50)
Declare @MLInvoice NVarchar(50)
Declare @MLInvoiceAmendment NVarchar(50)
Set @MLSalesReturnSaleable = dbo.LookupDictionaryItem(N'Sales Return Saleable', Default)
Set @MLSalesReturnDamages = dbo.LookupDictionaryItem(N'Sales Return Damages', Default)
Set @MLRetailInvoice = dbo.LookupDictionaryItem(N'Retail Invoice', Default)
Set @MLInvoice = dbo.LookupDictionaryItem(N'Invoice', Default)
Set @MLInvoiceAmendment = dbo.LookupDictionaryItem(N'Invoice Amendment', Default)

Select @VoucherPrefix = Prefix From VoucherPrefix Where TranID = 'INVOICE'
Create Table #temp(InvoiceID int, Value Decimal(18,6))

Insert into #temp
Select InvoiceDetail.InvoiceID, IsNull(Sum(SalePrice * Quantity) * Max(InvoiceDetail.TaxSuffered) / 100,0)
From InvoiceAbstract, InvoiceDetail
Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And
IsNull(InvoiceAbstract.Status, 0) & 128 = 0 And
InvoiceAbstract.InvoiceType in (1, 2, 3, 4)
Group By InvoiceDetail.InvoiceID, InvoiceDetail.Batch_Number, InvoiceDetail.SalePrice

Select InvoiceAbstract.InvoiceID,
"InvoiceID" = @VoucherPrefix + Cast(InvoiceAbstract.DocumentID As nvarchar),
"DocRef" = InvoiceAbstract.DocReference,
"Type" = Case InvoiceType
When 1 Then
@MLInvoice
When 2 Then
@MLRetailInvoice
When 3 Then
@MLInvoiceAmendment
When 4 Then
case (Status & 32)
When 0 then
@MLSalesReturnSaleable
Else
@MLSalesReturnDamages
End
End,
"Goods Value" = 
Case InvoiceType 
When 4 Then
0 - Sum(SalePrice * Quantity)
Else
Sum(SalePrice * Quantity)
End,
"Tax Suffered" = 
Case InvoiceType 
When 4 Then
IsNull((Select 0 - Sum(Value) From #temp 
Where #temp.InvoiceID = InvoiceAbstract.InvoiceID), 0)
Else
IsNull((Select Sum(Value) From #temp 
Where #temp.InvoiceID = InvoiceAbstract.InvoiceID), 0)
End,
"Tax Applicable" = 
Case InvoiceType 
When 4 Then
0 - IsNull(Sum(STPayable + CSTPayable), 0)
Else
IsNull(Sum(STPayable + CSTPayable), 0)
End,
"Discount" = Cast(
Case InvoiceType 
When 4 Then
 0 - (IsNull(Sum(SalePrice * Quantity * InvoiceDetail.DiscountPercentage / 100), 0) +
 IsNull(Sum(((InvoiceDetail.Quantity * InvoiceDetail.SalePrice - (InvoiceDetail.Quantity * InvoiceDetail.SalePrice * InvoiceDetail.DiscountPercentage / 100)) * InvoiceAbstract.DiscountPercentage / 100) + 
 ((InvoiceDetail.Quantity * InvoiceDetail.SalePrice - (InvoiceDetail.Quantity * InvoiceDetail.SalePrice * InvoiceDetail.DiscountPercentage / 100)) * IsNull(InvoiceAbstract.AdditionalDiscount,0) / 100)), 0)) 
Else
 IsNull(Sum(SalePrice * Quantity * InvoiceDetail.DiscountPercentage / 100), 0) +
 IsNull(Sum(((InvoiceDetail.Quantity * InvoiceDetail.SalePrice - (InvoiceDetail.Quantity * InvoiceDetail.SalePrice * InvoiceDetail.DiscountPercentage / 100)) * InvoiceAbstract.DiscountPercentage / 100) + 
 ((InvoiceDetail.Quantity * InvoiceDetail.SalePrice - (InvoiceDetail.Quantity * InvoiceDetail.SalePrice * InvoiceDetail.DiscountPercentage / 100)) * IsNull(InvoiceAbstract.AdditionalDiscount,0) / 100)), 0) 
End
as Decimal(18,6)),

"Net Sales" = Sum(case InvoiceType When 4 Then 0 - Amount Else Amount End)
From InvoiceAbstract, InvoiceDetail
Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And
(IsNull(InvoiceAbstract.Status, 0) & 128) = 0 And
InvoiceAbstract.InvoiceType in (1, 2, 3, 4)
Group By InvoiceAbstract.InvoiceID, InvoiceAbstract.DocumentID, InvoiceAbstract.DocReference,
	 InvoiceType, InvoiceAbstract.Status
Drop table #temp


