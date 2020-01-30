CREATE procedure Sp_Display_salesman
(@salesmancode nvarchar(255))
as
declare @salescode nvarchar(255)
select @salescode =salesmancode from salesman where salesmancode = @salesmancode
if @salescode = @salesmancode
select * from salesman where salesmancode = @salesmancode
else
begin
select * from salesman where salesman_Name = @salesmancode
end

