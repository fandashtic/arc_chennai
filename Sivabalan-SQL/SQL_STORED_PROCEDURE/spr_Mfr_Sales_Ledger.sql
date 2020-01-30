CREATE Procedure spr_Mfr_Sales_Ledger (@FromDate datetime,
					@Todate datetime)
As
Declare @SalesReturnDamages Decimal(18,6)
Declare @SalesReturnOthers Decimal(18,6)
Declare @NetSales Decimal(18,6)

Select @SalesReturnDamages = IsNull(Sum(NetValue - IsNull(Freight, 0)), 0)
From InvoiceAbstract
Where InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And
InvoiceAbstract.Status & 128 = 0 And
((InvoiceAbstract.InvoiceType = 4 And
InvoiceAbstract.Status & 32 <> 0) Or (InvoiceAbstract.InvoiceType = 6))

Select @SalesReturnOthers = IsNull(Sum(NetValue - IsNull(Freight, 0)) , 0)
From InvoiceAbstract
Where InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And
InvoiceAbstract.Status & 128 = 0 And
((InvoiceAbstract.InvoiceType = 4 And
InvoiceAbstract.Status & 32 = 0) or (InvoiceAbstract.InvoiceType=5))

Create Table #temp (InvoiceID int Null,
ItemCode nvarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS null,
GoodsValue Decimal(18,6) Null,
TaxSuffered Decimal(18,6) Null,
TaxApplicable Decimal(18,6) Null,
ProductDiscount Decimal(18,6) Null,
CashDiscount Decimal(18,6) Null)

Insert into #temp
Select InvoiceAbstract.InvoiceID, 
InvoiceDetail.Product_Code,
Sum(InvoiceDetail.Quantity * InvoiceDetail.SalePrice),
IsNull(Sum(Case Isnull(InvoiceAbstract.TaxOnMRP, 0)
When 1 Then
(InvoiceDetail.Quantity * InvoiceDetail.MRP) * dbo.fn_get_TaxOnMRP(InvoiceDetail.TaxSuffered)/100
Else
(InvoiceDetail.Quantity * InvoiceDetail.SalePrice) * InvoiceDetail.TaxSuffered /100
End),0),
IsNull(Sum(STPayable + CSTPayable), 0),
IsNull(Sum(InvoiceDetail.Quantity * InvoiceDetail.SalePrice) * Max(InvoiceDetail.DiscountPercentage) / 100, 0),
IsNull(Sum((InvoiceDetail.Quantity * InvoiceDetail.SalePrice - (InvoiceDetail.Quantity * InvoiceDetail.SalePrice * InvoiceDetail.DiscountPercentage / 100)) * InvoiceAbstract.DiscountPercentage / 100), 0) +
IsNull(Sum((InvoiceDetail.Quantity * InvoiceDetail.SalePrice - (InvoiceDetail.Quantity * InvoiceDetail.SalePrice * InvoiceDetail.DiscountPercentage / 100)) * InvoiceAbstract.AdditionalDiscount / 100), 0)
From InvoiceAbstract, InvoiceDetail
Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And
InvoiceAbstract.Status & 128 = 0 And
InvoiceAbstract.InvoiceType in (1, 2, 3)
Group By InvoiceType, InvoiceAbstract.InvoiceID, InvoiceDetail.Product_Code, Batch_Number, InvoiceAbstract.TaxOnMRP

Select @NetSales = IsNull(Sum(NetValue), 0) - IsNull(Sum(Freight), 0)
From InvoiceAbstract
Where InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And
InvoiceAbstract.Status & 128 = 0 And
InvoiceAbstract.InvoiceType in (1, 2, 3)

Select 1, 
"Total Goods Value" = IsNull(Sum(GoodsValue),0),
"Tax Suffered" = IsNull(Sum(TaxSuffered),0),
"Tax Applicable" = IsNull(Sum(TaxApplicable),0),
"Product Discount" = IsNull(Sum(ProductDiscount),0),
"Cash Discount" = IsNull(Sum(CashDiscount),0),
"Sales Return Damages" = IsNull(@SalesReturnDamages,0),
"Sales Return Saleable" = IsNull(@SalesReturnOthers,0),
"Net Sales" = IsNull(@NetSales, 0) - IsNull(@SalesReturnDamages, 0) - IsNull(@SalesReturnOthers, 0)
From #temp HAVING IsNull(Sum(GoodsValue),0) > 0 
Drop Table #temp





