CREATE Procedure spr_ser_list_TaxSummary @FROMDATE datetime,@TODATE datetime 
AS
Create table #Tax_Temp(TaxCode Int,
TaxDesc nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
SalesAmt decimal(18,6),Tax decimal(18,6),ReturnAmt decimal(18,6),Tax1 decimal(18,6),
NetAmt decimal(18,6),NetTax decimal(18,6))

Insert into #Tax_Temp
	
SELECT  T.Tax_code , "Tax Description" = T.Tax_Description ,
"Sales Amt." = sum(case IvA.InvoiceType when  1 then IvD.Amount else 0 end )+
sum(case IvA.InvoiceType when  2 then IvD.Amount else 0 end )+
sum(case IvA.InvoiceType when  3 then IvD.Amount else 0 end ), 
"Tax" = SUM(case IvA.InvoiceType when  1 then IvD.STPayable + IvD.CSTPayable else 0 end)+
SUM(case IvA.InvoiceType when  2 then IvD.STPayable + IvD.CSTPayable else 0 end)+
SUM(case IvA.InvoiceType when  3 then IvD.STPayable + IvD.CSTPayable else 0 end),
"Return Amt." = sum(case IvA.InvoiceType when  4 then IvD.Amount else 0 end ),
"Tax" = SUM(case IvA.InvoiceType when  4 then IvD.STPayable + IvD.CSTPayable else 0 end),

"Net Amt." = sum(case IvA.InvoiceType when  1 then IvD.Amount else 0 end )+
sum(case IvA.InvoiceType when  2 then IvD.Amount else 0 end )+
sum(case IvA.InvoiceType when  3 then IvD.Amount else 0 end ) -
sum(case IvA.InvoiceType when  4 then IvD.Amount else 0 end ),

"Net Tax" = SUM(case IvA.InvoiceType when  1 then IvD.STPayable + IvD.CSTPayable else 0 end)+
SUM(case IvA.InvoiceType when  2 then IvD.STPayable + IvD.CSTPayable else 0 end)+
SUM(case IvA.InvoiceType when  3 then IvD.STPayable + IvD.CSTPayable else 0 end) -
SUM(case IvA.InvoiceType when  4 then IvD.STPayable + IvD.CSTPayable else 0 end)

from Tax T , InvoiceAbstract IvA, InvoiceDetail IvD 
where t.tax_code = IvD.TaxId and IvA.InvoiceID=IvD.InvoiceID   
and invoicedate between @FROMDATE AND @TODATE
And IvA.Status&128=0 
group by t.tax_code, t.tax_description

Insert into #Tax_Temp 

SELECT SerTax.Taxcode ,"Tax Description" = T.Tax_Description ,
"Sales Amt." = Sum(Isnull(SerDet.NetValue,0)),
"Tax" = SUM(Isnull(SerDet.LSTPayable,0) + Isnull(SerDet.CSTPayable,0)),
"Return Amt." = 0,
"Tax" = 0,
"Net Amt." = Sum(Isnull(SerDet.NetValue,0)),
"Net Tax" = SUM(Isnull(SerDet.LSTPayable,0) + Isnull(SerDet.CSTPayable,0))

From ServiceInvoiceDetail SerDet,ServiceInvoiceTaxComponents SerTax,
ServiceInvoiceAbstract SerAbs,Tax T 
Where SerAbs.ServiceInvoiceID=SerDet.ServiceInvoiceID
And SerTax.Serialno = SerDet.Serialno 
And IsNull(SerDet.SpareCode,'') <> ''
And T.tax_code = SerTax.TaxCode 
And ServiceInvoicedate between @FROMDATE AND @TODATE
And SerAbs.Status & 192 =0
group by SerTax.Taxcode ,T.Tax_Description

select TaxCode,TaxDesc as "Tax Description",sum(SalesAmt) as "Sales Amt.",sum(Tax) as "Tax",sum(ReturnAmt) as "Return Amt.",sum(Tax1) as "Tax",sum(NetAmt) as "Net Amt",
sum(NetTax) as "Net Tax" from  #Tax_Temp group by TaxCode,TaxDesc
Drop Table #Tax_Temp    
