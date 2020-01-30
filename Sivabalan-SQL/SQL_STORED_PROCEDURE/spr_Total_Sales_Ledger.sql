CREATE Procedure spr_Total_Sales_Ledger (@FromDate datetime,
					@Todate datetime)
As
Declare @SalesReturnDamages Decimal(18,6)
Declare @SalesReturnOthers Decimal(18,6)

Select @SalesReturnDamages = IsNull(Sum(NetValue - IsNull(Freight, 0)), 0)
From InvoiceAbstract
Where InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And
InvoiceAbstract.Status & 128 = 0 And
InvoiceAbstract.InvoiceType = 4 And
InvoiceAbstract.Status & 32 <> 0

Select @SalesReturnOthers = IsNull(Sum(NetValue - IsNull(Freight, 0)) , 0)
From InvoiceAbstract
Where InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And
InvoiceAbstract.Status & 128 = 0 And
InvoiceAbstract.InvoiceType = 4 And
InvoiceAbstract.Status & 32 = 0

Create Table #temp (InvoiceID int Null,
ItemCode nvarchar(20) null,
GoodsValue Decimal(18,6) Null,
TaxSuffered Decimal(18,6) Null,
TaxApplicable Decimal(18,6) Null,
ProductDiscount Decimal(18,6) Null,
CashDiscount Decimal(18,6) Null)

Insert into #temp
Select InvoiceAbstract.InvoiceID, 
InvoiceDetail.Product_Code,
Sum(InvoiceDetail.Quantity * InvoiceDetail.SalePrice),
IsNull(Sum((InvoiceDetail.Quantity * InvoiceDetail.SalePrice) * IsNull(InvoiceDetail.TaxSuffered,0) /100),0),  
IsNull(Sum(STPayable + CSTPayable), 0),
IsNull(Sum(InvoiceDetail.Quantity * InvoiceDetail.SalePrice * InvoiceDetail.DiscountPercentage / 100), 0),
IsNull(Sum((InvoiceDetail.Quantity * InvoiceDetail.SalePrice - (InvoiceDetail.Quantity * InvoiceDetail.SalePrice * InvoiceDetail.DiscountPercentage / 100)) * InvoiceAbstract.DiscountPercentage / 100), 0) +
IsNull(Sum((InvoiceDetail.Quantity * InvoiceDetail.SalePrice - (InvoiceDetail.Quantity * InvoiceDetail.SalePrice * InvoiceDetail.DiscountPercentage / 100)) * InvoiceAbstract.AdditionalDiscount / 100), 0)
From InvoiceAbstract, InvoiceDetail
Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And
InvoiceAbstract.Status & 128 = 0 And
InvoiceAbstract.InvoiceType in (1, 2, 3)
Group By InvoiceAbstract.InvoiceID, InvoiceDetail.Product_Code, 
InvoiceDetail.Batch_Number, InvoiceDetail.SalePrice

Select 1, 
"Total Goods Value" = IsNull(Sum(GoodsValue), 0),
"Tax Suffered" = IsNull(Sum(TaxSuffered), 0),
"Tax Applicable" = IsNull(Sum(TaxApplicable), 0),
"Sales Return Saleable" = IsNull(@SalesReturnOthers, 0),
"Gross Sales" = IsNull(Sum(GoodsValue), 0) + 
IsNull(Sum(TaxSuffered), 0) + 
IsNull(Sum(TaxApplicable), 0) - 
IsNull(@SalesReturnOthers, 0),
"Product Discount" = IsNull(Sum(ProductDiscount), 0),
"Cash Discount" = IsNull(Sum(CashDiscount), 0),
"Sales Return Damages" = IsNull(@SalesReturnDamages, 0),
"Net Sales" = IsNull(Sum(GoodsValue), 0) + 
IsNull(Sum(TaxSuffered), 0) + 
IsNull(Sum(TaxApplicable), 0) - 
IsNull(@SalesReturnOthers, 0) - 
IsNull(Sum(CashDiscount), 0) - 
IsNull(@SalesReturnDamages, 0)
 - IsNull(Sum(ProductDiscount),0)
From #temp
Drop Table #temp





