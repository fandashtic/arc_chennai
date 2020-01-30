CREATE procedure [dbo].[spr_list_Van_To_Invoice_detail_udhayam] (  
@VanNo nvarchar(100),   
@FromDate datetime,   
@ToDate datetime)  
as  
(  
 select "Invoice No1" = ia.DocumentID, "Invoice No." = V.prefix + cast(ia.DocumentID as nvarchar), "Invoice Date" = ia.InvoiceDate,   
 "Customer Name" = company_name, "Invoice Amount" = sum(idt.amount),
 "Invoice Amount Including Freight" = ia.NetValue, 
 "Total Weight" = sum(isnull(conversionfactor,0) * isnull(quantity,0)),
 "Beat"=Isnull(Beat.Description,N''),
 "Sequence No"=c.SequenceNo	
 from Items, InvoiceAbstract ia, InvoiceDetail idt, Customer c, voucherprefix v,Beat  
 where  
 v.tranid = N'Invoice' and   
 ia.vannumber like @VanNo and  
 ia.invoiceid = idt.invoiceid and  
 ia.customerid = c.customerid and   
 items.product_code = idt.product_code and  
 ia.invoicedate between @FromDate and @ToDate and
 ia.Status & 192 = 0 and
 ia.BeatId *= Beat.BeatId
 group by ia.documentid, ia.InvoiceDate, company_name, v.prefix, ia.NetValue,Beat.Description,c.SequenceNo
  
)
