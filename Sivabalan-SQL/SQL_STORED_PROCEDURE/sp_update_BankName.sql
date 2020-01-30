create Procedure sp_update_BankName (@BankCode nvarchar(20),      
         @NewName nvarchar(128))      
As      
Update bankmaster  Set bankname  = @NewName    
Where Bankcode = @Bankcode      
  



