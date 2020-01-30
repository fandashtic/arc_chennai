CREATE function GetMargin(@ItemCode nvarchar(15), @Invoiceid int) 
returns decimal(18,6)
as
begin
Declare @GetMargin decimal(18,6)
Declare @CSPSET int
select @CSPSET = price_option from Itemcategories where Categoryid = 
                 (select Categoryid from items where Product_code = @ItemCode)
if @CSPSET = 1
	begin
		select @GetMargin = sum(InvoiceDetail.PTR) - sum(InvoiceDetail.PTS)  from Invoicedetail
			where InvoiceDetail.Invoiceid = @Invoiceid   
	end
else
	begin
		select @GetMargin = sum(Items.PTR) - sum(Items.PTS) from Items
			where Items.Product_COde = @ItemCode 
	end
return @GetMargin
end


