CREATE procedure sp_update_customerobjective   
@customerid nvarchar(30),    
@Volume decimal(18,6),    
@Serial int    
    
as    
    
Update CustomerObjective 
set volume = @Volume 
where Customerid =@customerid and serial = @Serial
    
  


