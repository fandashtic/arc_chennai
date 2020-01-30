CREATE Procedure spr_Mfr_Sales_Ledger_Detail (	@Unused int,
						@FromDate datetime,
						@ToDate datetime)
As
create table #temp (ManufacturerID int, Value Decimal(18,6))
insert into #temp
Select ManufacturerID, 
Case Isnull(InvoiceAbstract.TaxOnMRP, 0)
When 1 Then
IsNull(Sum(InvoiceDetail.MRP * Quantity) * dbo.fn_get_TaxOnMRP(Max(InvoiceDetail.TaxSuffered)) / 100,0)
Else
IsNull(Sum(InvoiceDetail.SalePrice * Quantity) * Max(InvoiceDetail.TaxSuffered) / 100,0)
End
From InvoiceAbstract, InvoiceDetail, Items
Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And
IsNull(InvoiceAbstract.Status, 0) & 128 = 0 And
InvoiceDetail.Product_Code = Items.Product_Code And
InvoiceAbstract.InvoiceType in (1, 2, 3)
Group By InvoiceAbstract.InvoiceID, Items.Product_Code, Items.ManufacturerID, InvoiceDetail.Batch_Number, InvoiceDetail.SalePrice, InvoiceAbstract.TaxOnMRP

Select Manufacturer.Manufacturer_Name,
"Manufacturer" = Manufacturer.Manufacturer_Name,
"Goods Value" = IsNull((Select Sum(SalePrice * Quantity)
	From InvoiceAbstract, InvoiceDetail, Items
	Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
	InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And
	IsNull(InvoiceAbstract.Status, 0) & 128 = 0 And
	InvoiceDetail.Product_Code = Items.Product_Code And
	InvoiceAbstract.InvoiceType in (1, 2, 3) And
	Items.ManufacturerID = Manufacturer.ManufacturerID), 0),
"Tax Suffered" = IsNull((Select Sum(Value)
	From #temp
	Where #temp.ManufacturerID = Manufacturer.ManufacturerID), 0),
"Tax Applicable" = IsNull((Select Sum(STPayable + CSTPayable)
	From InvoiceAbstract, InvoiceDetail, Items
	Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
	InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And
	IsNull(InvoiceAbstract.Status, 0) & 128 = 0 And
	InvoiceDetail.Product_Code = Items.Product_Code And
	InvoiceAbstract.InvoiceType in (1, 2, 3) And
	Items.ManufacturerID = Manufacturer.ManufacturerID), 0),
"Product Discount" = IsNull((Select Sum(InvoiceDetail.DiscountValue)
	From InvoiceAbstract, InvoiceDetail, Items
	Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
	InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And
	IsNull(InvoiceAbstract.Status, 0) & 128 = 0 And
	InvoiceDetail.Product_Code = Items.Product_Code And
	InvoiceAbstract.InvoiceType in (1, 2, 3) And
	Items.ManufacturerID = Manufacturer.ManufacturerID), 0),
"Sales Return Damages" = IsNull((Select Sum(Amount)
	From InvoiceAbstract, InvoiceDetail, Items
	Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
	InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And
	IsNull(InvoiceAbstract.Status, 0) & 128 = 0 And
	InvoiceDetail.Product_Code = Items.Product_Code And
	((InvoiceAbstract.InvoiceType = 4 And
	InvoiceAbstract.Status & 32 <> 0) or(InvoiceAbstract.InvoiceType=6)) And
	Items.ManufacturerID = Manufacturer.ManufacturerID), 0),
"Sales Return Saleable" = IsNull((Select Sum(Amount)
	From InvoiceAbstract, InvoiceDetail, Items
	Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
	InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And
	IsNull(InvoiceAbstract.Status, 0) & 128 = 0 And
	InvoiceDetail.Product_Code = Items.Product_Code And
	((InvoiceAbstract.InvoiceType = 4 And	InvoiceAbstract.Status & 32 = 0) or
	(InvoiceAbstract.InvoiceType = 5))
	And	Items.ManufacturerID = Manufacturer.ManufacturerID), 0),
"Net Sales" = IsNull((Select Sum(Case InvoiceType
	When 4 then
	0 - (Amount)
	When 5 then
	0 - (Amount)
	When 6 then
	0 - (Amount)
	Else
	Amount
	End) From InvoiceAbstract, InvoiceDetail, Items
	Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
	InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And
	IsNull(InvoiceAbstract.Status, 0) & 128 = 0 And
	InvoiceDetail.Product_Code = Items.Product_Code And
	Items.ManufacturerID = Manufacturer.ManufacturerID), 0)
From Manufacturer
drop table #temp


