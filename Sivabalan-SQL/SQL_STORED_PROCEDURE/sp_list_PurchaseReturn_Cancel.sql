CREATE Procedure sp_list_PurchaseReturn_Cancel( @Vendor nvarchar(15),  
      @FromDate datetime,  
      @ToDate datetime)  
As  
Select AdjustmentID, DocumentID,  
AdjustmentReturnAbstract.VendorID, Vendors.Vendor_Name, AdjustmentDate, Total_Value,  
Balance, Status,isnull(docreference, 0),Reference,DocSerialType  ,GSTFlag, GSTDocID, GSTFullDocID
From AdjustmentReturnAbstract, Vendors  
Where AdjustmentReturnAbstract.VendorID like @Vendor And  
AdjustmentReturnAbstract.VendorID like Vendors.VendorID And  
AdjustmentReturnAbstract.AdjustmentDate Between @FromDate And @ToDate-- And  
--IsNull(AdjustmentReturnAbstract.Status, 0) = 0   
--Cancellation screens to list all documents including cancelled purchase returns  
Order By AdjustmentReturnAbstract.VendorID, AdjustmentReturnAbstract.AdjustmentDate 
