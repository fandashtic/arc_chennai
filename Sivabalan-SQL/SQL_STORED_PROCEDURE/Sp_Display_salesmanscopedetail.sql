CREATE procedure Sp_Display_salesmanscopedetail  
@salesmancode nvarchar(255)  
as  
declare @salescode nvarchar(255)  
select @salescode =salesmancode from salesman where salesmancode =@salesmancode    
if @salescode = @salesmancode  
select * FROM salesmanscopedetail where   salesmancode =@salesmancode  order by serial  
else  
begin  
select @salescode =salesmancode from salesman where salesman_name =@salesmancode  
select * FROM  salesmanscopedetail where salesmancode = @salescode order by serial  
end

