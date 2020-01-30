CREATE procedure [dbo].[sp_ser_rpt_ServiceInvoiceCancelAbstract](@Fromdate datetime,@Todate datetime)                                            
As              
                                            
Declare @Prefix nvarchar(15)                      
Declare @Prefix1 nvarchar(15)                      
Declare @Prefix2 nvarchar(15)                      
Declare @ParamSep nVarchar(10)                              
Set @ParamSep = Char(2)                                
Declare @ItemSpec1  nvarchar(50)                                                 
                
select @Prefix = Prefix from VoucherPrefix where TranID = 'SERVICEINVOICE'                                      
select @Prefix1 = Prefix from VoucherPrefix where TranID = 'JOBCARD'                                      
select @Prefix2 = Prefix from VoucherPrefix where TranID = 'JOBESTIMATION'                                      
              
Select [ID],[ServiceInvoiceID],[ServiceInvoice Date],[Doc Ref],[Payment Mode],[CreditTerm] As [Credit Term],                                         
[CustomerID],[Customer Name],                  
Sum([Tasksum])As [Task Amount],Sum([Sparesum ])As [Spare Amount],                  
[Product Discount],[Trade Discount(%)],[Trade Discount],[Additional Discount],                  
Sum([Tasksumnet])As [Task Net Value],Sum([Sparesumnet])As [Spare Net Value ],                                  
[Freight],[Balance],[Collected Amount],[JobCardID],[JobCard Date],[EstimationID]                
 FROM                                          
(SELECT 'ID' = ServiceInvoiceabstract.ServiceinvoiceID,                  
'ServiceInvoiceID' =  @Prefix + cast(ServiceInvoiceabstract.DocumentID as nvarchar(15)),                                            
'ServiceInvoice Date' = serviceinvoiceDate,                                            
'Doc Ref' = DocReference,                                
(case isnull(Serviceinvoiceabstract.PaymentMode,'') when 0 then 'Credit' 
when 1 then 'Cash' 
when 2 then 'Cheque' 
when 3 then 'DD'  
when 4 then 'Credit Card' 
when 5 then 'Coupon' 
else '' end) as 'Payment Mode',                                          
'CreditTerm' = Creditterm.[description] ,              
'CustomerID' =  ServiceInvoiceabstract.Customerid,                  
'Customer Name' =  company_Name,                                
'Tasksum '=                       
 case when Isnull(Taskid,'')  <> '' and Isnull(sparecode,'') = '' then Cast(sum(ServiceInvoiceDetail.Amount) as Decimal(18,6)) else 0 end,                           
'Sparesum ' = case when Isnull(sparecode,'')  <> ''  then Cast(sum(ServiceInvoiceDetail.Amount) as Decimal(18,6)) else 0 end,                                        
'Product Discount' = Isnull(Itemdiscount,0),          
'Trade Discount(%)' = Tradediscountpercentage,                  
'Trade Discount'  = ISnull(Tradediscountvalue,0),                  
'Additional Discount(%)' = AdditionalDiscountPercentage,                  
'Additional Discount' = Isnull(AdditionalDiscountValue,0),                  
 'TasksumNet'=                       
 case when Isnull(Taskid,'') <> '' and Isnull(sparecode,'') = '' then Cast(sum(ServiceInvoiceDetail.Netvalue) as Decimal(18,6)) else 0 end,                           
'SparesumNet' = case when  Isnull(sparecode,'')  <> ''  then Cast(sum(ServiceInvoiceDetail.Netvalue) as Decimal(18,6)) else 0 end,                                        
'Freight' = ISnull(Freight,0),                  
'Balance' = Isnull(Balance,0),                  
'Collected Amount' = (serviceinvoiceabstract.Netvalue + roundoffamount - balance),                  
'JobCardID' =  @Prefix1 + cast(jobcardabstract.DocumentID as nvarchar(15)),                                            
'JobCard Date' = jobcardabstract.jobcarddate,                  
'EstimationID' =  @Prefix2 + cast(Estimationabstract.DocumentID as nvarchar(15))                                            
from serviceinvoiceabstract,serviceinvoicedetail,jobcardabstract,Estimationabstract,Customer,CreditTerm                
where serviceinvoiceabstract.serviceinvoiceid = serviceinvoicedetail.serviceinvoiceid                  
and serviceinvoiceabstract.customerID = customer.customerID                                            
and (serviceinvoicedate) between @FromDate and @ToDate                                        
--and  serviceinvoiceabstract.serviceinvoiceid = jobcardabstract.serviceinvoiceid                  
and  serviceinvoiceabstract.jobcardid = jobcardabstract.jobcardid                  
and jobcardabstract.Estimationid = Estimationabstract.EstimationID                
and serviceinvoiceabstract.creditterm *= creditterm.creditid                   
and (IsNull(serviceinvoiceabstract.Status,0) & 192) <> 0                                              
group by serviceinvoiceabstract.serviceinvoiceid,                  
serviceinvoiceabstract.documentid,serviceinvoicedetail.Product_Specification1,serviceinvoicedate,ServiceInvoiceDate,                  
serviceinvoiceabstract.DocReference,serviceinvoiceabstract.PaymentMode,                  
CreditTerm.[Description],serviceinvoiceabstract.CustomerID,                  
Customer.Company_Name,serviceinvoiceabstract.itemdiscount,                  
serviceinvoiceabstract.TradeDiscountPercentage,serviceinvoiceabstract.TradeDiscountValue,                  
serviceinvoiceabstract.AdditionalDiscountPercentage,                  
serviceinvoiceabstract.AdditionalDiscountValue,serviceinvoicedetail.SpareCode,                  
serviceinvoicedetail.TaskID,serviceinvoiceabstract.Freight,                  
serviceinvoiceabstract.Balance,serviceinvoiceabstract.NetValue,                  
serviceinvoiceabstract.RoundOffAmount,serviceinvoiceabstract.Balance,                  
jobcardabstract.Documentid,jobcardabstract.jobcarddate,Estimationabstract.Documentid) as grt                  
group by [ID],[ServiceInvoiceID],[ServiceInvoice Date],[doc Ref],[Payment Mode],[CreditTerm],                                         
[CustomerID],[Customer Name],[Product Discount],[Trade Discount(%)],[Trade Discount],[Additional Discount],                  
[Freight],[Balance],[Collected Amount],[JobCardID],[JobCard Date],[EstimationID]
