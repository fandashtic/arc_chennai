CREATE Procedure sp_get_docbatchinfo (@Batch_Code Int)      
As      
Select Batch_Products.PKD,   Batch_Products.Expiry,     
Case IsNull(Batch_Products.BatchReference, 0)
When 0 Then
Batch_Products.PTS
Else
(Select PTS From Batch_Products a Where a.Batch_Code = Batch_Products.BatchReference)    
End,
Case IsNull(Batch_Products.BatchReference, 0)
When 0 Then
Batch_Products.PTR
Else
(Select PTR From Batch_Products a Where a.Batch_Code = Batch_Products.BatchReference)      
End,
Case IsNull(Batch_Products.BatchReference, 0)
When 0 Then
Batch_Products.ECP
Else
(Select ECP From Batch_Products a Where a.Batch_Code = Batch_Products.BatchReference)
End,
Case IsNull(Batch_Products.BatchReference, 0)
When 0 Then
Batch_Products.Company_Price
Else
(Select Company_Price From Batch_Products a Where a.Batch_Code = Batch_Products.BatchReference)
End,     
Case IsNull(Batch_Products.BatchReference, 0)
When 0 Then
Batch_Products.GRNApplicableOn
Else
(Select GRNApplicableOn From Batch_Products a Where a.Batch_Code = Batch_Products.BatchReference)
End,     
Case IsNull(Batch_Products.BatchReference, 0)
When 0 Then
Batch_Products.GRNPartOff
Else
(Select GRNPartOff From Batch_Products a Where a.Batch_Code = Batch_Products.BatchReference)          
End     
From Batch_Products      
Where Batch_Products.Batch_Code = @Batch_Code      
  


