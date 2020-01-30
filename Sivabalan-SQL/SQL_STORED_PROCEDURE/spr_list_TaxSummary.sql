CREATE Procedure spr_list_TaxSummary @FROMDATE datetime,@TODATE datetime AS
SELECT  T.Tax_code , "Tax Description" = T.Tax_Description ,
"Sales Amt." = sum(case IvA.InvoiceType when  1 then IvD.Amount else 0 end )+
sum(case IvA.InvoiceType when  2 then IvD.Amount else 0 end )+
sum(case IvA.InvoiceType when  3 then IvD.Amount else 0 end ), 
"Tax" = SUM(case IvA.InvoiceType when  1 then IvD.STPayable + IvD.CSTPayable else 0 end)+
SUM(case IvA.InvoiceType when  2 then IvD.STPayable + IvD.CSTPayable else 0 end)+
SUM(case IvA.InvoiceType when  3 then IvD.STPayable + IvD.CSTPayable else 0 end),
"Return Amt." = sum(case when IvA.InvoiceType In (4,5,6) then IvD.Amount else 0 end ),
"Tax" = SUM(case when  IvA.InvoiceType In (4,5,6) then IvD.STPayable + IvD.CSTPayable else 0 end),

"Net Amt." = sum(case IvA.InvoiceType when  1 then IvD.Amount else 0 end )+
sum(case IvA.InvoiceType when  2 then IvD.Amount else 0 end )+
sum(case IvA.InvoiceType when  3 then IvD.Amount else 0 end ) -
sum(case when IvA.InvoiceType In (4,5,6) then IvD.Amount else 0 end ),

"Net Tax" = SUM(case IvA.InvoiceType when  1 then IvD.STPayable + IvD.CSTPayable else 0 end)+
SUM(case IvA.InvoiceType when  2 then IvD.STPayable + IvD.CSTPayable else 0 end)+
SUM(case IvA.InvoiceType when  3 then IvD.STPayable + IvD.CSTPayable else 0 end) -
SUM(case when IvA.InvoiceType In (4,5,6) then IvD.STPayable + IvD.CSTPayable else 0 end)

from Tax T , InvoiceAbstract IvA, InvoiceDetail IvD 
where t.tax_code = IvD.TaxId and IvA.InvoiceID=IvD.InvoiceID   
and invoicedate between @FROMDATE AND @TODATE
And IvA.Status&128=0 
group by t.tax_code, t.tax_description


