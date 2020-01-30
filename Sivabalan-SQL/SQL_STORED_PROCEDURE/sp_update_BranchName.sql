CREATE Procedure sp_update_BranchName (@ID nvarchar(10),@NewName nvarchar(128))    
As    
Update Branchmaster Set BranchName = @NewName  
Where Branchcode = @ID       


