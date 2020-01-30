CREATE Procedure sp_ser_rpt_ServiceTaxAbstract(@FromDate datetime,@Todate datetime)    
As    
    
Declare @Prefix nvarchar(15)                        
 
                
select @Prefix = Prefix from VoucherPrefix where TranID = 'SERVICEINVOICE'                                        
    
Select [ID],[ServiceInvoice ID],[ServiceInvoice Date],[Doc Ref],sum([ServiceTaxAmount]) As [ServiceTax Amount]    
From(Select     
'ID' = ServiceInvoiceabstract.ServiceinvoiceID,                    
'ServiceInvoice ID' =  @Prefix + cast(ServiceInvoiceabstract.DocumentID as nvarchar(15)),                                              
'ServiceInvoice Date' = Serviceinvoicedate,
'Doc Ref' = DocReference,                                  
'ServiceTaxAmount'=                         
case when Isnull(Taskid,'')  <> '' and Isnull(sparecode,'') = '' then  
Cast(sum(ServiceInvoiceDetail.ServiceTax) as Decimal(18,6)) else 0 end                             
from Serviceinvoiceabstract,ServiceInvoicedetail    
where serviceinvoiceabstract.serviceinvoiceid = serviceinvoicedetail.serviceinvoiceid                    
and (IsNull(Status, 0) & 192) = 0                          
and(serviceinvoiceabstract.serviceinvoicedate) between @FromDate and @ToDate
and serviceTax <> 0  
Group by Serviceinvoiceabstract.ServiceInvoiceID,    
ServiceInvoiceabstract.DocumentID,    
Serviceinvoicedate,
Serviceinvoiceabstract.DocReference,    
ServiceInvoicedetail.TaskID,ServiceInvoicedetail.SpareCode,    
ServiceInvoiceDetail.ServiceTax     
) as grt    
Group by     
[ID],[ServiceInvoice ID],[Serviceinvoice Date],[doc Ref] 

