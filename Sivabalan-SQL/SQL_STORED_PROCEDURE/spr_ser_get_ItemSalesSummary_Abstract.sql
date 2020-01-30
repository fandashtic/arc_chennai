
CREATE procedure spr_ser_get_ItemSalesSummary_Abstract(@FromDate DateTime, @ToDate DateTime)
as
Create table #Item_Temp(ProductCode nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
ProductName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,Qty Decimal(18,6),Netvalue decimal(18,6))

insert into #Item_Temp
select 	I.Product_Code, "Item" = I.ProductName,
	"Quantity" = sum(case InvAbs.InvoiceType when 4 then -InvDet.Quantity else InvDet.Quantity end), 
	"Value" = Sum(case InvAbs.InvoiceType when 4 then -InvDet.Amount else InvDet.Amount end)
from InvoiceAbstract InvAbs, InvoiceDetail InvDet, Items I
where 	InvAbs.InvoiceID = InvDet.InvoiceID 
	and InvDet.Product_Code = I.Product_Code 
	and InvAbs.InvoiceDate between @FromDate and @ToDate 
	and IsNull(InvAbs.Status,0)& 192 = 0
group by I.Product_Code, I.ProductName 


Insert into #Item_Temp 
select Isnull(SerDet.Sparecode,''),"Item"= I.productname,
	"Quantity" = sum(SerDet.Quantity),
	"Value" = sum(SerDet.NetValue) 
from ServiceInvoiceAbstract SerAbs ,ServiceInvoiceDetail SerDet,Items I
where 	SerAbs.serviceinvoiceid   = SerDet.serviceinvoiceid 
	and I.product_code = SerDet.sparecode
	and IsNull(SerAbs.serviceInvoiceType,0) = 1
	and IsNull(SerAbs.Status,0) & 192 = 0   
	and IsNull(SerDet.SpareCode, '') <> '' 
	and SerAbs.serviceinvoicedate between @FromDate and @ToDate 
group by SerDet.sparecode,I.productname

select Productcode as Product_Code,Productname as Item,sum(Qty) as Quantity,sum(NetValue) as Value from #Item_Temp group by Productcode,Productname

Drop Table #Item_Temp    
