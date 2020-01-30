CREATE procedure sp_ser_autolist_institutioncustomer(@mode integer,  
@KeyField varchar(30)='%',@Direction int = 0, @BookMark varchar(128) = '')  
as  
  
if @mode =1   
begin    
 IF @Direction = 1  
 Begin   
  select Company_Name,CustomerID from customer where CustomerCategory in (3, 4)   
  and CustomerID like @KeyField and CustomerID > @BookMark  and Active <> 0
  order by CustomerID

 End  
 Else  
 Begin  
  select Company_Name,CustomerID from customer where CustomerCategory in (3, 4)   
  and CustomerID like @KeyField  and Active <> 0
  order by CustomerID
 End   
end  
else if @mode =2   
begin  
 IF @Direction = 1
 Begin   
  select CustomerID,Company_Name from customer  
  where CustomerID in(select CustomerID from customer where CustomerCategory in (3, 4))  
  and company_Name like @keyfield and company_Name > @BookMark  and  Active <> 0
  order by company_name  
 End  
 Else  
 Begin  
  select CustomerID,Company_Name from customer  
  where CustomerID in(select CustomerID from customer where CustomerCategory in (3, 4))  
  and company_Name like @keyfield  and Active <> 0
  order by company_name  
 End  
End  
  


