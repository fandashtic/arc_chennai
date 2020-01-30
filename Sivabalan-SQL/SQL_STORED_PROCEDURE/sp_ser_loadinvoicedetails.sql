CREATE procedure sp_ser_loadinvoicedetails(@InvoiceID int)
as
Declare @INVPrefix nvarchar(15)
Declare @JCPrefix nvarchar(15)
Declare @ESTPrefix nvarchar(15)

Select @ESTPrefix = Prefix from VoucherPrefix Where TranID = 'JOBESTIMATION'
Select @JCPrefix = Prefix from VoucherPrefix Where TranID = 'JOBCARD'
Select @INVPrefix = Prefix from VoucherPrefix Where TranID = 'SERVICEINVOICE'

Select serviceinvoiceabstract.ServiceInvoiceID, ServiceInvoiceDate, AdditionalDiscountPercentage,    
ServiceInvoiceabstract.JobCardID, DocReference, PaymentMode, NetValue, Balance, 
PaymentDetails, RoundOffAmount, TradeDiscountPercentage, TradeDiscountValue, 
AdditionalDiscountPercentage, AdditionalDiscountValue, TotalTaxSuffered, 
TotalTaxApplicable, ItemDiscount, TotalServiceTax, 
(NetValue + TradeDiscountValue + AdditionalDiscountValue - IsNull(Freight, 0)) totalvalue,
ServiceInvoiceabstract.DocumentID InvDocumentID, 
'INVPrefixID' = @INVPrefix + cast(ServiceInvoiceabstract.DocumentID as nvarchar(15)), 
'JCPrefixID' = @JCPrefix + cast(JobCardAbstract.DocumentID as nvarchar(15)), 
JobCardDate, JobcardAbstract.DocumentID JCDocumentID, 
Isnull(Company_Name, '') Company, IsNull(Customer.CustomerID, '') CustomerID, 
IsNull(serviceinvoiceabstract.BillingAddress, '') BillingAddress, 
IsNull(serviceinvoiceabstract.ShippingAddress, '') ShippingAddress, 
IsNull(Freight , 0) Freight, IsNull(ServiceInvoiceabstract.CreditTerm, 0) 'CreditTerm', 
Isnull(Serviceinvoiceabstract.DocSerialType,'') 'DocSerialType', Paymentdate, 
isnull(AdjustmentValue, 0) 'AdjustmentValue',
'ESTPrefixID' = @ESTPrefix + cast(EstimationAbstract.DocumentID as nvarchar(15))
from serviceinvoiceabstract 
Inner Join JobCardAbstract On ServiceInvoiceabstract.JobCardID = JobCardAbstract.JobCardID 
Inner Join EstimationAbstract On EstimationAbstract.EstimationID = JobCardAbstract.EstimationID
Left Join Customer On Customer.CustomerID = serviceinvoiceabstract.CustomerID
where serviceinvoiceabstract.ServiceInvoiceID = @InvoiceID 

/* 
Total Value 
(NetValue + TradeDiscountValue + AdditionalDiscountValue - TotalTaxSuffered - 
TotalTaxApplicable + ItemDiscount - TotalServiceTax - IsNull(Freight , 0)) totalvalue,
29.03.05
Total Value will be without ADisc and TradingDiscount 
(NetValue + TradeDiscountValue + AdditionalDiscountValue - IsNull(Freight , 0)) totalvalue,
*/

