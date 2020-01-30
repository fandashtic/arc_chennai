CREATE procedure sp_list_Payments(@VendorID nvarchar(15),    
      @FromDate datetime,    
      @ToDate datetime)    
as    
select Vendors.Vendor_Name, Vendors.VendorID, FullDocID, Payments.DocumentDate, Value,     
DocumentID, Balance, Status,DocRef,
"DocID" = Payments.DocumentReference, "DocType" = Payments.DocSerialtype    
from Payments, Vendors    
where Payments.VendorID = Vendors.VendorID and    
Payments.VendorID like @VendorID and    
Payments.DocumentDate between @FromDate and @ToDate     
order by Vendors.Vendor_Name, Payments.DocumentDate    

