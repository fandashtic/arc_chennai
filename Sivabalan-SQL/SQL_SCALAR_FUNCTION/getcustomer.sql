CREATE function getcustomer(@invoiceid integer)
returns nvarchar(255)
as
begin
declare @customer nvarchar(255),@invoicetype integer,@customerid integer,@cusid nvarchar(15) 
select @invoicetype =[InvoiceType],@cusid = [CustomerID] from InvoiceAbstract
where [InvoiceID]= @invoiceid

select @customer = Company_Name from Customer where [CustomerID]=@cusid  	

If ltrim(rtrim(isnull(@Customer,N''))) = N''
Begin
	select @customer = CustomerName from Cash_Customer where [CustomerID]=@cusid  	
End
-- -- if @invoicetype =2
-- -- begin
-- -- 	select @customer = CustomerName from Cash_Customer where [CustomerID]=@cusid  	
-- -- end
-- -- else--if @invoicetype =1 or @invoicetype =4
-- --  begin
-- --  	select @customer = Company_Name from Customer where [CustomerID]=@cusid  	
-- --  end
return @customer
end

