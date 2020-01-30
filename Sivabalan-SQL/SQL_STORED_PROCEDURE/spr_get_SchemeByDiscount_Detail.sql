CREATE procedure spr_get_SchemeByDiscount_Detail 
(
	@ProdIDSchID char(50), 
	@FromDate DateTime, 
	@ToDate DateTime
)
as
begin
--@ProdIDSchID contains ProductCode and SchemeID seperated by char(15)
declare @ProductCode nvarchar(50)
declare @SchemeID nvarchar(50)
declare @Pos int, @SchIDLen int
declare @Prefix as nvarchar(5)

select @Prefix = Prefix FROM VoucherPrefix WHERE TranID = 'INVOICE'

set @Pos = charindex(char(15), @ProdIDSchID, 1)
set @SchIDLen = len(@ProdIDSchID) - @Pos
set @ProductCode = substring(@ProdIDSchID, 1, @Pos-1)
set @SchemeID = substring(@ProdIDSchID, @Pos+1, @SchIDLen)

select 
	IA.DocumentID, "Invoice ID" = @Prefix + convert(nvarchar,IA.DocumentID), 
	-- Retail Customer Details are moved to Customer master, hence Cash_Customer not required    
	"Customer Name" = (select Company_Name from Customer where CustomerID = IA.CustomerID) ,       
--	 Quantity suffered by scheme only required
	"Quantity" = Sum(SchS.Free),
	"Discount Value" = IDt.DiscountValue,
	"Discount Percentage" = IDt.DiscountPercentage,  
	"Value" = IDt.Amount
from 
	InvoiceAbstract IA, InvoiceDetail IDt, SchemeSale SchS
where
	IA.InvoiceID = IDt.InvoiceID 
	and	IDt.Product_Code = @ProductCode 
	and SchS.Type = @SchemeID 
	and SchS.InvoiceID = IA.InvoiceID 
	and	SchS.Product_Code = IDt.Product_Code 
	and IDt.Amount <> 0
	and	IA.InvoiceDate between @FromDate and @ToDate 
	and (IA.Status & 192) = 0 
	and	IA.InvoiceType not in (4)
	and	(IDt.DiscountValue <> 0 or FlagWord <>0)
group by 
	IA.DocumentID, IA.DocReference, IDt.Amount, IDt.DiscountPercentage, IDt.DiscountValue, 
	IA.CustomerID, IA.InvoiceType, IA.InvoiceId

end


