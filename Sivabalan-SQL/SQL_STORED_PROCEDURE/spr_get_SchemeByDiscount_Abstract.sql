CREATE procedure spr_get_SchemeByDiscount_Abstract 
(
	@FromDate DateTime, 
	@ToDate Datetime
)
as 
begin

select 
	ltrim(rtrim(IDt.Product_Code)) + char(15) + rtrim(ltrim(SchS.Type)) , 
	"Item Code" = IDt.Product_Code, "Item Name" = It.ProductName, "UOM" = UOM.Description,
	"Total Discount Value" = Sum(IDt.DiscountValue), "Total Sale Value" = Sum(IDt.Amount)
from 
	InvoiceDetail IDt, InvoiceAbstract IA, Items It, UOM, SchemeSale SchS, Schemes
where
	IA.InvoiceID = IDt.InvoiceID 
	and IDt.Product_Code = It.Product_Code 
	and	SchS.InvoiceID = IA.InvoiceID 
	and SchS.Product_Code = IDt.Product_Code 
	and IDt.Amount <> 0
	and	It.UOM = UOM.UOM  
	and	IA.InvoiceDate between @FromDate and @ToDate 
	and (IA.Status & 192) = 0 
	and	IA.InvoiceType not in (4)
	and Schemes.SchemeID = SchS.Type
	and Schemes.SchemeType <> 17
group by 
	IDt.Product_Code, SchS.Type, It.ProductName, UOM.Description

end



