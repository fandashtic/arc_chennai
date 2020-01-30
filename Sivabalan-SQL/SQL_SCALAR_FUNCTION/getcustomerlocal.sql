CREATE function getcustomerlocal(@invoiceid integer)
returns int
as
begin
declare @customer nvarchar(30),@invoicetype integer,@customerid integer,@cusid nvarchar(15) 
declare @locality int

select @invoicetype =[InvoiceType],@cusid = [CustomerID] from InvoiceAbstract
where [InvoiceID]= @invoiceid

if @invoicetype =2
begin
	set @locality = 1  	
end
else
--if @invoicetype =1 or @invoicetype =4
 begin
 	select @locality = isnull(Locality,0) from Customer 
	where [CustomerID]=@cusid  	
	--if @locality<>1
	--begin
	--	set @locality =0
	--end
 end
return @locality
end
