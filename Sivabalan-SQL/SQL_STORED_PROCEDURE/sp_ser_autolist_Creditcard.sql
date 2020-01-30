CREATE Procedure sp_ser_autolist_Creditcard(@mode integer,    
@KeyField varchar(30)='%',@Direction int = 0, @BookMark varchar(128) = '')    
as    

if @mode = 1     
begin    
   
 IF @Direction = 1    
 Begin     
  select mode,value from paymentmode
  where paymenttype in(3)    
  and value like @keyfield and value > @BookMark  and (Active <> 0)  
  order by value    
 End    
 else
 begin
  select mode,value from paymentmode
  where paymenttype in(3)    
  and value like @keyfield and (Active <> 0)  
  order by value    
 end
End

