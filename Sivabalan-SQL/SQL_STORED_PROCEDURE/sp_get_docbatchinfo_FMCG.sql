CREATE Procedure sp_get_docbatchinfo_FMCG (@Batch_Code Int)  
As  
Select Batch_Products.PKD, Batch_Products.Expiry,    
(Select PurchasePrice From Batch_Products a Where a.Batch_Code = Batch_Products.BatchReference)  
,N'',N'',N'',
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


