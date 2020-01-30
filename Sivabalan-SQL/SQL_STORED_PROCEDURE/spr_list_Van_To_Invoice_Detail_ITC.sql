CREATE Procedure spr_list_Van_To_Invoice_Detail_ITC (
@VanNo nvarchar(100),
@DocPrefix nVarchar(15),
@FromDate datetime,
@ToDate datetime)
As
Begin
Declare @MInvoice NVarchar(50)
Set @MInvoice = dbo.LookupDictionaryItem(N'Invoice', Default)
If @DocPrefix ='%'
Begin
Select
"Invoice No1" = ia.DocumentID,
"Invoice No." = Case Isnull (ia.GSTFlag,0) when 0 then V.prefix + cast(ia.DocumentID as nvarchar) Else ISNULL(ia.GSTFullDocID,'') END,
"Doc. Ref" = IA.DocReference,
"Invoice Date" = ia.InvoiceDate,
"BeatName" = B.Description,
"Customer Name" = company_name,
"Sch Discount" = Max(IA.SchemeDiscountAmount) + Sum(IsNull(idt.schemediscamount,0)+IsNull(idt.splcatdiscamount,0)),
"Discount" = Max(IA.DiscountValue) - Max(IA.schemediscountAmount) + Max(IA.AddlDiscountValue) + Sum( IsNull(idt.DiscountValue,0) - IsNull(idt.schemediscamount,0) - IsNull(idt.splcatdiscamount,0)) ,
"VAT/Tax" = Max(IA.TotalTaxApplicable),
"CASH Sales"   = Sum(Case IsNull(PaymentMode,0) when 1 then idt.amount Else 0 End),
"CHQ/DD Sales" = Sum(Case IsNull(PaymentMode,0) when 2 then idt.amount when 3 then idt.amount Else 0 End),
"Credit Sales" = Sum(Case IsNull(PaymentMode,0) when 0 then idt.amount Else 0 End),
--			"Invoice Amount" = sum(idt.amount),
"Invoice Amount Including Freight" = ia.NetValue,
"Total Weight" = sum(isnull(conversionfactor,0) * isnull(quantity,0))
from Items, InvoiceAbstract ia, InvoiceDetail idt, Customer c, voucherprefix v, Beat B
where
v.tranid = @MInvoice and
ia.vannumber like @VanNo and
ia.invoiceid = idt.invoiceid and
ia.customerid = c.customerid and
Ia.BeatId = B.BeatId And
items.product_code = idt.product_code and
ia.invoicedate between @FromDate and @ToDate and
ia.Status & 192 = 0
Group by ia.documentid, ia.InvoiceDate, company_name, v.prefix,IA.DocReference, ia.NetValue, B.Description   ,ia.GSTFlag,ia.GSTFullDocID
End
Else
Begin
Select
"Invoice No1" = ia.DocumentID,
"Invoice No." = Case ISNULL(ia.GSTFlag,0) when 0 then  V.prefix + cast(ia.DocumentID as nvarchar) Else ISNULL(ia.GSTFullDocID,'')END,
"Doc. Ref" = IA.DocReference,
"Invoice Date" = ia.InvoiceDate,
"BeatName" = B.Description,
"Customer Name" = company_name, "Invoice Amount" = sum(idt.amount),
"Sch Discount" = Max(IA.SchemeDiscountAmount) + Sum(IsNull(idt.schemediscamount,0)+IsNull(idt.splcatdiscamount,0)),
"Discount" = Max(IA.DiscountValue) - Max(IA.schemediscountAmount) + Max(IA.AddlDiscountValue) + Sum( IsNull(idt.DiscountValue,0) - IsNull(idt.schemediscamount,0) - IsNull(idt.splcatdiscamount,0)) ,
"VAT/Tax" = Max(IA.TotalTaxApplicable),
"CASH Sales"   = Sum(Case IsNull(PaymentMode,0) when 1 then idt.amount Else 0 End),
"CHQ/DD Sales" = Sum(Case IsNull(PaymentMode,0) when 2 then idt.amount when 3 then idt.amount Else 0 End),
"Credit Sales" = Sum(Case IsNull(PaymentMode,0) when 0 then idt.amount Else 0 End),
--		 	"Invoice Amount Including Freight" = ia.NetValue,
"Total Weight" = sum(isnull(conversionfactor,0) * isnull(quantity,0))
from Items, InvoiceAbstract ia, InvoiceDetail idt, Customer c, voucherprefix v, Beat B
where
v.tranid = @MInvoice and
ia.vannumber like @VanNo and
ia.invoiceid = idt.invoiceid and
ia.customerid = c.customerid and
Ia.BeatId = B.BeatId And
items.product_code = idt.product_code and
ia.invoicedate between @FromDate and @ToDate and
Ia.DocSerialType = @DocPrefix And
ia.Status & 192 = 0
Group by ia.documentid, ia.InvoiceDate, company_name, v.prefix,IA.DocReference, ia.NetValue, B.Description  ,ia.GSTFlag,ia.GSTFullDocID
End
End
