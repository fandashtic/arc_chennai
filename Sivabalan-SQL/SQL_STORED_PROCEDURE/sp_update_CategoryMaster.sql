CREATE Procedure sp_update_CategoryMaster (@CatCode nvarchar(20),  @NewName nvarchar(250))    
As    
Update ItemCategories Set Category_Name = @NewName, ModifiedDate = GetDate()     
Where CategoryID = @CatCode    

  


