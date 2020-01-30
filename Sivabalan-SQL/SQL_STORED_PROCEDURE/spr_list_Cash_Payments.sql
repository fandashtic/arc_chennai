CREATE procedure spr_list_Cash_Payments(     
       @FromDate datetime,      
       @ToDate datetime)      
as      
select Documentid, "Payment ID" = FullDocId, "Date" = DocumentDate,      
"Vendor Name" = Vendors.Vendor_Name,    
"Value" = Payments.Value , "Excess Payment" = Balance   
from Payments, Vendors      
where Payments.VendorID = Vendors.VendorID     
and  Payments.Paymentmode = 0    
and  (isnull(Payments.Status,0)&64)= 0
and Payments.DocumentDate between @FromDate and @ToDate 
