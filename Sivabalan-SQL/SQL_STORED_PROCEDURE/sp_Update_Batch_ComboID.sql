CREATE Procedure sp_Update_Batch_ComboID (@BatchCode Integer, @ComboID Integer, @Free Decimal(18,6))    
As    
If @Free > 0  
update Batch_Products Set ComboID = @ComboID Where Batch_Code in (@BatchCode, @BatchCode+1)  
Else  
update Batch_Products Set ComboID = @ComboID Where Batch_Code = @BatchCode     
  


