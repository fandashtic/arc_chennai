CREATE Procedure sp_list_PurchaseReturn (@Vendor nvarchar(15),    
     @FromDate datetime,    
     @ToDate datetime)    
As    
Select  AdjustmentID, DocumentID,    
 AdjustmentReturnAbstract.VendorID,     
 Vendors.Vendor_Name,     
 AdjustmentDate,     
 Total_Value,    
 Balance, Status  , isnull(docreference, 0),Reference,DocSerialType  
,GSTFlag, GSTDocID, GSTFullDocID
From  AdjustmentReturnAbstract, Vendors    
Where  AdjustmentReturnAbstract.VendorID like @Vendor And    
 AdjustmentReturnAbstract.VendorID = Vendors.VendorID And    
 AdjustmentReturnAbstract.AdjustmentDate Between @FromDate And @ToDate    
Order By AdjustmentReturnAbstract.VendorID, AdjustmentReturnAbstract.AdjustmentDate
