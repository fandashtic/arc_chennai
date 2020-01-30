CREATE procedure sp_list_batchinfo_Convert (@ItemCode nvarchar(15), @Free Decimal(18,6))      
as      
     
SELECT a.Batch_Number, a.Expiry, a.Quantity,   
case @Free when 1 then b.PurchasePrice else a.PurchasePrice end, a.PKD,       
Case @Free when 1 then b.PTS else a.PTS End,      
Case @Free when 1 then b.PTR else a.PTR End,       
Case @Free when 1 then b.ECP else a.ECP End,       
Case @Free when 1 then b.Company_Price else a.Company_Price End,       
GRNAbstract.DocumentID, a.Batch_Code      
FROM Batch_Products a
Left Outer Join Batch_Products b ON a.BatchReference = b.Batch_Code
Left Outer Join GRNAbstract ON a.GRN_ID = GRNAbstract.GRNID     
WHERE a.Product_Code = @ITEMCODE And a.Quantity > 0 And ISNULL(a.Damage, 0) = 0      
And IsNull(a.Free, 0) = @Free
Order By IsNull(a.Expiry,'9999'), a.PKD, a.Batch_code       

