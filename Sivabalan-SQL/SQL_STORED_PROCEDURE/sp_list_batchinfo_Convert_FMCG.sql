CREATE procedure [dbo].[sp_list_batchinfo_Convert_FMCG] (@ItemCode nvarchar(15), @Free Decimal(18,6))        
as        
       
SELECT a.Batch_Number, a.Expiry, a.Quantity,         
case @Free When 1 then b.PurchasePrice Else a.PurchasePrice End,a.PKD,   
case @Free When 1 then b.SalePrice Else a.SalePrice End,         
GRNAbstract.DocumentID, a.Batch_Code, GRNAbstract.DocumentID        
FROM Batch_Products a, GRNAbstract, Batch_Products b        
WHERE a.Product_Code = @ITEMCODE And a.Quantity > 0 And ISNULL(a.Damage, 0) = 0        
And IsNull(a.Free, 0) = @Free And a.GRN_ID *= GRNAbstract.GRNID         
And a.BatchReference *= b.Batch_Code      
Order By IsNull(a.Expiry,'9999'), a.PKD, a.Batch_Code
