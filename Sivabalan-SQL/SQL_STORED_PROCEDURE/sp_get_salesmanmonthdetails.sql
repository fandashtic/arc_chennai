CREATE procedure sp_get_salesmanmonthdetails  
(@salesmancode nvarchar(255),  
 @objyear int,  
 @objmonth int)  
as  
declare @salescode nvarchar(15)
select @salescode =salesmancode from salesman where salesmancode = @salesmancode
if @salescode = @salesmancode
 select * from salesmanscopedetail where Salesmancode = @salesmancode and objyear = @objyear and objmonth = @objmonth order by serial  
else
begin
select @salescode =salesmancode from salesman where salesman_name = @salesmancode
select * from salesmanscopedetail where Salesmancode = @salescode and objyear = @objyear and objmonth = @objmonth order by serial  
end

