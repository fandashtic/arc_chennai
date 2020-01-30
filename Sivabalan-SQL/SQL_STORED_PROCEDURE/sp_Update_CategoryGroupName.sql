CREATE Procedure sp_Update_CategoryGroupName (@GroupID nVarchar(20),        
         @NewName nVarchar(128))        
As        
Update ProductCategoryGroupAbstract  Set GroupName  = @NewName      
Where GroupID = @GroupID        

