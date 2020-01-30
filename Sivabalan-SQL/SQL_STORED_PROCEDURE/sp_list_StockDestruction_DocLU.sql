CREATE PROCEDURE sp_list_StockDestruction_DocLU (@FromDocID int, @ToDocID int)          
AS          
SELECT DocSerial, StockDestructionAbstract.DocumentDate, ClaimsNote.VendorID, Vendors.Vendor_Name, 
StockDestructionAbstract.DocumentID, ClaimsNote.DocumentID, ClaimsNote.ClaimID, ClaimsNote.ClaimDate  
FROM ClaimsNote, Vendors, StockDestructionAbstract          
WHERE ClaimsNote.VendorID = Vendors.VendorID  AND    
 StockDestructionAbstract.ClaimID = ClaimsNote.ClaimID     
AND StockDestructionAbstract.DocumentID BETWEEN @FromDocID AND @ToDocID    
AND ClaimType in (1,2)        
ORDER BY Vendors.Vendor_Name, StockDestructionAbstract.DocumentID    


