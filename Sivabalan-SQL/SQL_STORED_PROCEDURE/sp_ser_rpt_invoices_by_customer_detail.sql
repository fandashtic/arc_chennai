CREATE procedure [dbo].[sp_ser_rpt_invoices_by_customer_detail](@CUSTOMERID nvarchar(15),            
@FROMDATE datetime, @TODATE datetime)            

AS            
Declare @Prefix nvarchar(15)                          
       
select @Prefix = Prefix from VoucherPrefix where TranID = 'SERVICEINVOICE'                                          
         
Select [ID],[ServiceInvoiceID],[ServiceInvoice Date],[Doc Ref],[CreditTerm] As [Credit Term],          
Sum([TaskAmount])As [Task Amount],Sum([SpareAmount ])As [Spare Amount],                      
[Product Discount],[Trade Discount(%)],[AdditionalDiscount(%)] As [AdditionalDiscount(%)],                      
Sum([TaskNet])As [Task Net],Sum([SpareNet])As [Spare Net],                                      
[Freight],[NetValue] As [Net Value],[Status] from          
(select "ID" =  ServiceInvoiceabstract.serviceinvoiceID,                                                
"ServiceInvoiceID" =  @Prefix + cast(ServiceInvoiceabstract.DocumentID as nvarchar(15)),          
"Doc Ref" = DocReference,                                    
"ServiceInvoice Date" = ServiceInvoiceDate,          
"CreditTerm" = Creditterm.[description] ,              
"TaskAmount" = case when Isnull(Taskid,'') <> '' and Isnull(sparecode,'') = '' then Cast(sum(ServiceInvoiceDetail.Amount) as Decimal(18,6)) else 0 end,                               
"SpareAmount" = case when Isnull(sparecode,'') <> ''  then Cast(sum(ServiceInvoiceDetail.Amount) as Decimal(18,6)) else 0 end,                                            
"Product Discount" = Isnull(Itemdiscount,0),          
"AdditionalDiscount(%)" = AdditionalDiscountPercentage,           
"Trade Discount(%)" = Tradediscountpercentage,             
"TaskNet"=                           
 case when Isnull(Taskid,'') <> '' and Isnull(sparecode,'') = '' then Cast(sum(ServiceInvoiceDetail.Netvalue) as Decimal(18,6)) else 0 end,                               
"SpareNet" = case when  Isnull(sparecode,'') <> ''  then Cast(sum(ServiceInvoiceDetail.Netvalue) as Decimal(18,6)) else 0 end,                                            
"Freight" = Isnull(Freight,0),                      
"NetValue" = Isnull(Serviceinvoiceabstract.NetValue,0),          
"Status" = Case             
      
WHEN Isnull(ServiceInvoiceAbstract.NetValue,0) - Isnull(ServiceInvoiceAbstract.Balance,0)  = 0 THEN 'UnPaid'            
WHEN Isnull(ServiceInvoiceAbstract.NetValue,0) - Isnull(ServiceInvoiceAbstract.Balance,0) = isnull(ServiceInvoiceAbstract.NetValue,0) THEN             
'Paid'            
ELSE 'Partially Paid'            
END            
from serviceinvoiceabstract,serviceinvoicedetail,CreditTerm          
where serviceinvoiceabstract.customerid = @CUSTOMERID          
and serviceinvoiceabstract.serviceinvoiceid = serviceinvoicedetail.serviceinvoiceid          
and serviceinvoiceabstract.creditterm *= creditterm.creditid                   
and serviceInvoiceDate BETWEEN @FROMDATE AND @TODATE             
and (IsNull(Serviceinvoiceabstract.Status, 0) & 192) = 0           
GROUP BY  serviceinvoiceabstract.ServiceInvoiceID,serviceinvoiceabstract.DocumentID,serviceinvoiceabstract.DocReference,serviceinvoiceabstract.ServiceInvoiceDate,          
Creditterm.[description],serviceinvoicedetail.TaskID,serviceinvoicedetail.SpareCode,          
serviceinvoiceabstract.ItemDiscount,serviceinvoiceabstract.AdditionalDiscountPercentage,          
serviceinvoiceabstract.TradeDiscountPercentage,serviceinvoiceabstract.Freight,          
serviceinvoiceabstract.NetValue,serviceinvoiceabstract.Balance,serviceinvoiceabstract.RoundoffAmount,Status) As S          
GROUP BY           
[ID],[ServiceInvoiceID],[ServiceInvoice Date],[Doc Ref],[CreditTerm],                                             
[Product Discount],[Trade Discount(%)],[AdditionalDiscount(%)],                      
[Freight],[NetValue],[Status]
