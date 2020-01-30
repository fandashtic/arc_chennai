CREATE PROCEDURE sp_ser_print_ServiceInvoiceTaskAbstract(@InvoiceId INT)      
AS   
Declare @AddDiscount decimal(18, 6)
Declare @TrdDiscount decimal(18, 6)
Select 
	@AddDiscount = IsNull(AdditionalDiscountPercentage, 0),
	@TrdDiscount = IsNull(TradeDiscountPercentage, 0) 
from ServiceInvoiceAbstract Where ServiceInvoiceID = @InvoiceId

Select
"Total Rate" = IsNull(Sum(SDetail.Price), 0),
"Total Amount" = IsNull(Sum(SDetail.Amount), 0),
"Total Tax%" = Isnull(Avg(SDetail.ServiceTax_Percentage), 0),
"Total Tax Value" = Isnull(Sum(SDetail.ServiceTax), 0),
"AdditionalDiscount%" = IsNull(@AddDiscount, 0),
"AdditionalDiscountValue" = (IsNull(Sum(SDetail.Price), 0) * IsNull(@AddDiscount, 0)) / 100,
"TradeDiscount%" = IsNull(@TrdDiscount, 0),
"TradeDiscountValue" = (IsNull(Sum(SDetail.Price), 0) * IsNull(@TrdDiscount, 0)) / 100,
"Total Net" = Isnull(Sum(SDetail.NetValue), 0)
from ServiceInvoiceDetail SDetail 
Where SDetail.ServiceInvoiceID = @InvoiceId
	and SDetail.Type in (1,2) 
	and IsNull(SDetail.SpareCode, '') = ''
	and IsNull(SDetail.TaskID, '') <> ''
Group by SDetail.ServiceInvoiceID




