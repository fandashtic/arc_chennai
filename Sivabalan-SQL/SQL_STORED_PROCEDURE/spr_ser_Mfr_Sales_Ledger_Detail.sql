CREATE Procedure spr_ser_Mfr_Sales_Ledger_Detail (@Unused int,
						@FromDate datetime,
						@ToDate datetime)
As


create table #temp (ManufacturerID int, Value Decimal(18,6))

insert into #temp


Select ManufacturerID, 
Case Isnull(InvoiceAbstract.TaxOnMRP, 0)
When 1 Then
IsNull(Sum(InvoiceDetail.MRP * Quantity) * dbo.sp_ser_get_TaxOnMRP(Max(InvoiceDetail.TaxSuffered)) / 100,0)
Else
IsNull(Sum(InvoiceDetail.SalePrice * Quantity) * Max(InvoiceDetail.TaxSuffered) / 100,0)
End
From InvoiceAbstract, InvoiceDetail, Items
Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
InvoiceAbstract.InvoiceDate Between @Fromdate and @Todate And
IsNull(InvoiceAbstract.Status, 0) & 128 = 0 And
InvoiceDetail.Product_Code = Items.Product_Code And
InvoiceAbstract.InvoiceType in (1, 2, 3)
Group By InvoiceAbstract.InvoiceID, Items.Product_Code, Items.ManufacturerID, InvoiceDetail.Batch_Number, InvoiceDetail.SalePrice, InvoiceAbstract.TaxOnMRP

union all

Select ManufacturerID, 
IsNull(Sum(serviceInvoiceDetail.Price * Quantity) * Max(ServiceInvoiceDetail.Tax_SufferedPercentage) / 100,0)
From ServiceInvoiceAbstract, ServiceInvoiceDetail, Items
Where ServiceInvoiceAbstract.ServiceInvoiceID = ServiceInvoiceDetail.serviceInvoiceID And
ServiceInvoiceAbstract.ServiceInvoiceDate Between @Fromdate and @Todate And
IsNull(ServiceInvoiceAbstract.Status, 0) & 192 = 0 And
ServiceInvoiceDetail.SpareCode = Items.Product_Code And
ServiceInvoiceAbstract.ServiceInvoiceType in (1) and
Isnull(serviceinvoicedetail.sparecode, '') <> ''
Group By ServiceInvoiceAbstract.ServiceInvoiceID, Items.Product_Code, Items.ManufacturerID, ServiceInvoiceDetail.Batch_Number, ServiceInvoiceDetail.Price



Select "ManufacturerName" = Manufacturer.Manufacturer_Name,
"Manufacturer" = Manufacturer.Manufacturer_Name,
"Goods Value" = IsNull((Select Sum(SalePrice * Quantity)
	From InvoiceAbstract, InvoiceDetail, Items
	Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
	InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And
	IsNull(InvoiceAbstract.Status, 0) & 128 = 0 And
	InvoiceDetail.Product_Code = Items.Product_Code And
	InvoiceAbstract.InvoiceType in (1, 2, 3) And
	Items.ManufacturerID = Manufacturer.ManufacturerID), 0) 
+
IsNull((Select Sum(Price * Quantity)
	From ServiceInvoiceAbstract, ServiceInvoiceDetail, Items
	Where ServiceInvoiceAbstract.ServiceInvoiceID = ServiceInvoiceDetail.ServiceInvoiceID And
	ServiceInvoiceAbstract.ServiceInvoiceDate Between @Fromdate and @Todate  And
	IsNull(ServiceInvoiceAbstract.Status, 0) & 192 = 0 And
	ServiceInvoiceDetail.SpareCode = Items.Product_Code And
	ServiceInvoiceAbstract.ServiceInvoiceType in (1) And
        Isnull(serviceinvoicedetail.sparecode,'') <> '' and
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
	Items.ManufacturerID = Manufacturer.ManufacturerID), 0)
+ IsNull((Select Sum(LSTPayable + CSTPayable)
	From ServiceInvoiceAbstract, ServiceInvoiceDetail, Items
	Where ServiceInvoiceAbstract.ServiceInvoiceID = ServiceInvoiceDetail.ServiceInvoiceID And
	ServiceInvoiceAbstract.serviceInvoiceDate Between @FromDate And @ToDate And
	IsNull(ServiceInvoiceAbstract.Status, 0) & 128 = 0 And
	ServiceInvoiceDetail.spareCode = Items.Product_Code And
	ServiceInvoiceAbstract.ServiceInvoiceType in (1) And
        Isnull(serviceinvoicedetail.sparecode,'') <> '' and
	Items.ManufacturerID = Manufacturer.ManufacturerID), 0),

"Product Discount" = IsNull((Select Sum(InvoiceDetail.DiscountValue)
	From InvoiceAbstract, InvoiceDetail, Items
	Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
	InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And
	IsNull(InvoiceAbstract.Status, 0) & 128 = 0 And
	InvoiceDetail.Product_Code = Items.Product_Code And
	InvoiceAbstract.InvoiceType in (1, 2, 3) And
	Items.ManufacturerID = Manufacturer.ManufacturerID), 0)

+ IsNull((Select Sum(ServiceInvoicedetail.ItemDiscountValue)
	From ServiceInvoiceAbstract, ServiceInvoiceDetail, Items
	Where ServiceInvoiceAbstract.ServiceInvoiceID = ServiceInvoiceDetail.ServiceInvoiceID And
	ServiceInvoiceAbstract.ServiceInvoiceDate Between @FromDate And @ToDate And
	IsNull(ServiceInvoiceAbstract.Status, 0) & 192 = 0 And
	ServiceInvoiceDetail.spareCode = Items.Product_Code And
	ServiceInvoiceAbstract.ServiceInvoiceType in (1) And
        ISnull(ServiceInvoicedetail.sparecode,'') <> '' And
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
	And Items.ManufacturerID = Manufacturer.ManufacturerID), 0),
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
+
IsNull((Select Sum(Serviceinvoicedetail.NetValue) From serviceInvoiceAbstract, ServiceInvoiceDetail, Items
	Where ServiceInvoiceAbstract.ServiceInvoiceID = ServiceInvoiceDetail.ServiceInvoiceID And
	ServiceInvoiceAbstract.ServiceInvoiceDate Between @Fromdate and @Todate  And
	IsNull(ServiceInvoiceAbstract.Status, 0) & 192 = 0 And
	ServiceInvoiceDetail.SpareCode = Items.Product_Code 
        AND IsNull(ServiceinvoiceDetail.SpareCode, '') <> '' and
	Items.ManufacturerID = Manufacturer.ManufacturerID), 0)
From Manufacturer

drop table #temp









