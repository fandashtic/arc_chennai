CREATE Procedure sp_Upgrade_Invoice
As
Create Table #temp( InvoiceID int Null,
InvoiceType int Null,
ItemCode nvarchar(20) Null,
GoodsValue Decimal(18, 6) Null,
TaxSuffered Decimal(18, 6) Null,
TaxApplicable Decimal(18, 6) Null,
ProductDiscount Decimal(18, 6) Null,
AddlnDiscount Decimal(18, 6) Null,
PaymentDetails nvarchar(255) Null)

Insert into #temp
Select InvoiceAbstract.InvoiceID, 
InvoiceAbstract.InvoiceType,
InvoiceDetail.Product_Code,
Sum(InvoiceDetail.Quantity * InvoiceDetail.SalePrice),
IsNull(Sum(InvoiceDetail.Quantity * InvoiceDetail.SalePrice) * Max(InvoiceDetail.TaxSuffered)/100, 0),
IsNull(Sum(STPayable + CSTPayable), 0),
IsNull(Sum(InvoiceDetail.Quantity * InvoiceDetail.SalePrice * InvoiceDetail.DiscountPercentage / 100), 0),
IsNull(Sum((InvoiceDetail.Quantity * InvoiceDetail.SalePrice - (InvoiceDetail.Quantity * InvoiceDetail.SalePrice * InvoiceDetail.DiscountPercentage / 100)) * InvoiceAbstract.AdditionalDiscount / 100), 0),
InvoiceAbstract.PaymentDetails
From InvoiceAbstract, InvoiceDetail
Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
InvoiceAbstract.InvoiceType in (1, 2, 3, 4)
Group By InvoiceAbstract.InvoiceID, InvoiceDetail.Product_Code, 
InvoiceDetail.Batch_Number, InvoiceDetail.SalePrice, InvoiceAbstract.PaymentDetails, InvoiceAbstract.InvoiceType

Create Table #temp1 (InvoiceID Int Null,
AdjRef nvarchar(255) Null,
AdjustedAmount Decimal(18, 6) Null,
GoodsValue Decimal(18, 6) Null,
TaxSuffered Decimal(18, 6) Null,
TaxApplicable Decimal(18, 6) Null,
ProductDiscount Decimal(18, 6) Null,
AddlnDiscount Decimal(18, 6) Null)

Insert into #temp1 
Select #temp.InvoiceID,
Case #temp.InvoiceType
When 2 Then
Null
Else
Cast(dbo.GetAdjustments(Cast(Max(#temp.PaymentDetails) As Int), #temp.InvoiceID) as nvarchar)
End,
Case #temp.InvoiceType
When 2 Then
Null
Else
IsNull((Select Sum(AdjustedAmount) From CollectionDetail
Where CollectionID = Cast(Max(#temp.PaymentDetails) As Int) And 
DocumentID <> #temp.InvoiceID),0)
End,
Sum(#temp.GoodsValue),
Sum(#temp.TaxSuffered),
Sum(#temp.TaxApplicable),
Sum(#temp.ProductDiscount),
Sum(#temp.AddlnDiscount)
From #temp
Group By #temp.InvoiceID, #temp.InvoiceType

Drop Table #temp

Update InvoiceAbstract Set
InvoiceAbstract.AdjRef = #temp1.AdjRef,
InvoiceAbstract.AdjustedAmount = #temp1.AdjustedAmount,
InvoiceAbstract.GoodsValue = #temp1.GoodsValue,
InvoiceAbstract.TotalTaxSuffered = #temp1.TaxSuffered,
InvoiceAbstract.TotalTaxApplicable = #temp1.TaxApplicable,
InvoiceAbstract.ProductDiscount = #temp1.ProductDiscount,
InvoiceAbstract.AddlDiscountValue = #temp1.AddlnDiscount
From #temp1
Where InvoiceAbstract.InvoiceID = #temp1.InvoiceID

Drop Table #temp1

