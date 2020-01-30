CREATE procedure sp_View_PurchaseReturn (@DocSerial int)    
As    
Select AdjustmentID, AdjustmentReturnAbstract.VendorID, Vendors.Vendor_Name,    
AdjustmentDate, DocumentID, Total_Value, Balance, Status,DocReference,DocIdRef,
adjustmentIDRef,(select a.adjustmentdate from adjustmentreturnabstract a where adjustmentid=adjustmentreturnabstract.adjustmentidref), 
Reference,DocSerialType ,GSTFlag, GSTDocID, GSTFullDocID
From AdjustmentReturnAbstract, Vendors    
Where AdjustmentID = @DocSerial And    
AdjustmentReturnAbstract.VendorID = Vendors.VendorID    
