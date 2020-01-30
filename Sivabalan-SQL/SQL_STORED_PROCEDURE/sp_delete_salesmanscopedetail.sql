create procedure sp_delete_salesmanscopedetail
(@salesmancode as nvarchar(15))
as
declare @salescode nvarchar(15)
select @salescode =salesmancode from salesman where salesmancode = @salesmancode
if @salescode = @salesmancode
 delete from salesmanscopedetail where Salesmancode = @salesmancode 
else
begin
select @salescode =salesmancode from salesman where salesman_name = @salesmancode
 delete from salesmanscopedetail where Salesmancode = @salescode 
end

