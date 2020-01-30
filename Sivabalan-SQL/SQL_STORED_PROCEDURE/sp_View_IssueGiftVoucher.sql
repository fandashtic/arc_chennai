CREATE procedure sp_View_IssueGiftVoucher(@CustomerID nvarchar(15),      
      @FromDate datetime,      
      @ToDate datetime)      
as      
select Customer.Company_Name, Customer.CustomerID, FullDocID, Collections.DocumentDate,       
Value, Collections.DocumentID,Balance,Collections.Status, OriginalRef,      
"DocID" = Collections.DocumentReference,      
"DocType" = Collections.DocSerialType      
from Collections, Customer, GiftVoucherDetail , IssueGiftVoucher      
where Collections.DocumentID = IssueGiftVoucher.CollectionID and      
--Collections.Status IN (1,2) and      
IssueGiftVoucher.SerialNo = GiftVoucherDetail.SerialNo and  
GiftVoucherDetail.CustomerID=Customer.CustomerID and    
GiftVoucherDetail.CustomerID like @CustomerID and    
Collections.DocumentDate between @FromDate and @ToDate    
group by Customer.Company_Name, Customer.CustomerID, FullDocID, Collections.DocumentDate,       
Value, Collections.DocumentID,Balance,Collections.Status, OriginalRef,      
Collections.DocumentReference, Collections.DocSerialType      


