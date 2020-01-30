CREATE Procedure  sp_ser_loadInvoiceSpares   
(@InvoiceID as int, @Product_Code as nvarchar(15), @Product_Specification1 as nvarchar(50))   
as  
Select SerialNo,   
SpareCode, Items.ProductName, Batch_Number, UOM.Description, DateofSale, 
IsNull(Warranty,2) Warranty , WarrantyNo, UOMPrice, IsNUll(EstimatedPrice, 0) EstPrice, 
UOMQty, ServiceInvoiceDetail.Tax_SufferedPercentage, ServiceInvoiceDetail.TaxSuffered, 
ServiceInvoiceDetail.SaleTax,
(Case when LSTPayable = 0 and CSTPayable > 0 then CSTPayable 
when CSTPayable = 0 and  LSTPayable > 0 then LSTPayable else 0 end) SaleTaxAmt,
ItemDiscountPercentage, IsNull(ItemDiscountValue,0) ItemDiscountValue, Flag, Amount, 
NetValue,  ServiceInvoiceDetail.SaleID, IsNull(DocumentID, 0) IssDocumentID, 
IsNull(IssueDate, '') IssueDate, IsNUll(JobFree,0) JobFree, 
IsNull(JobMaster.JobName,'') 'JobName', isNull(Price,0) 'Price' 
from ServiceInvoiceDetail  
Inner Join Items On Items.Product_Code = IsNull(SpareCode,'')  
Inner Join UOM on ServiceInvoiceDetail.UOM = UOM.UOM   
Left Outer Join IssueAbstract On IssueAbstract.IssueID = ServiceInvoiceDetail.IssueID
left Outer Join JobMaster On JobMaster.JobId = IsNull(ServiceInvoiceDetail.JobId,'')
Where  
	ServiceInvoiceID = @InvoiceID and   
	ServiceInvoiceDetail.Product_Code = @Product_Code and   
	Product_Specification1 = @Product_Specification1 and IsNUll(SpareCode,'') <> '' 
Order by SerialNo 


