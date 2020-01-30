
Create Procedure spr_Get_InvoiceWiseSales
(
	@InvoiceID nVarchar(255),
	@Flag int
)

As
	If @Flag = 1--Unique UOM
	Begin
		Select Distinct(InvoiceDetail.Product_Code), Items.ProductName, InvoiceDetail.SalePrice as [Sale Price], 
		cast(isnull(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Quantity ELSE InvoiceDetail.Quantity END,0) as varchar) + ' ' + (select ISNULL(Description, '') from UOM WHERE UOM = Items.UOM) as Quantity,
		cast(cast(isnull((case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Quantity ELSE InvoiceDetail.Quantity END) / (case isnull(Items.ReportingUnit,0) when 0 then 1 else isnull(Items.ReportingUnit,0) end),0) as decimal(18,2)) as varchar) + ' ' + (select ISNULL(Description, '') from UOM WHERE UOM = Items.ReportingUOM) as [Quantity RU], 
		case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Amount ELSE InvoiceDetail.Amount END  as [Gross Value] ,
		case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.TaxAmount Else InvoiceDetail.TaxAmount End as Tax,
		case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.DiscountValue Else InvoiceDetail.DiscountValue End as Discount, 
		(case InvoiceAbstract.InvoiceType when 4 then 0- (InvoiceDetail.Amount +  InvoiceDetail.TaxSuffAmount - InvoiceDetail.SplCatDiscAmount - InvoiceDetail.SchemeDiscAmount) Else (InvoiceDetail.Amount +  InvoiceDetail.TaxSuffAmount - InvoiceDetail.SplCatDiscAmount - InvoiceDetail.SchemeDiscAmount) End) as [Net Value]
		From InvoiceAbstract, InvoiceDetail, Items, CustomerSegment, Customer
		Where Items.Product_Code = InvoiceDetail.Product_Code
		And InvoiceAbstract.InvoiceId =InvoiceDetail.InvoiceID 
		And InvoiceAbstract.InvoiceID = @InvoiceID
		And (InvoiceAbstract.Status & 128) = 0 Order By InvoiceDetail.Product_Code
	End
	Else --Else of @Flag = 1
	Begin 
		Select Distinct(InvoiceDetail.Product_Code), Items.ProductName, InvoiceDetail.SalePrice as [Sale Price], 
		cast(isnull(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Quantity ELSE InvoiceDetail.Quantity END,0) as varchar) as Quantity,
		cast(cast(isnull((case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Quantity ELSE InvoiceDetail.Quantity END) / (case isnull(Items.ReportingUnit,0) when 0 then 1 else isnull(Items.ReportingUnit,0) end),0) as decimal(18,2)) as varchar) as [Quantity RU],
		case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Amount ELSE InvoiceDetail.Amount END  as [Gross Value] , 
		case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.TaxAmount Else InvoiceDetail.TaxAmount End as Tax, 
		case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.DiscountValue Else InvoiceDetail.DiscountValue End as Discount, 
		(case InvoiceAbstract.InvoiceType when 4 then 0 - (InvoiceDetail.Amount +  InvoiceDetail.TaxSuffAmount - InvoiceDetail.SplCatDiscAmount - InvoiceDetail.SchemeDiscAmount) Else (InvoiceDetail.Amount +  InvoiceDetail.TaxSuffAmount - InvoiceDetail.SplCatDiscAmount - InvoiceDetail.SchemeDiscAmount) End) as [Net Value]
		From InvoiceAbstract, InvoiceDetail, Items, CustomerSegment, Customer 
		Where Items.Product_Code = InvoiceDetail.Product_Code 
		And InvoiceAbstract.InvoiceId =InvoiceDetail.InvoiceID
		And InvoiceAbstract.InvoiceID = @InvoiceID
		And (InvoiceAbstract.Status & 128) = 0  Order By InvoiceDetail.Product_Code
	End
	


