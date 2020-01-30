CREATE Procedure sp_update_DivisionName (@BrandID nvarchar(20),    
         @NewName nvarchar(128))    
As    
Update Brand  Set Brandname  = @NewName  
Where BrandID = @BrandID    


