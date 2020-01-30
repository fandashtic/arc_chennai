CREATE function sp_ser_GetMargin(@ItemCode varchar(15), @Invoiceid bigint,@Mode int,@IssueSerial bigint = 0) 
returns decimal(18,6)
as
begin
Declare @GetMargin decimal(18,6)
Declare @CSPSET int
select @CSPSET = price_option from Itemcategories where Categoryid = 
                 (select Categoryid from items where Product_code = @ItemCode)

IF @Mode = 1
Begin

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
--	return @GetMargin
	end

ELSE

Begin

if @CSPSET = 1
		begin

			select @GetMargin = sum(IssueDetail.PTR) - sum(IssueDetail.PTS)  
				from serviceInvoicedetail,IssueDetail
				where serviceInvoiceDetail.serviceInvoiceid = @Invoiceid
                                and issuedetail.SerialNo = @Issueserial
                                and Serviceinvoicedetail.Issue_Serial = issuedetail.SerialNo   


		end
	else
		begin
			select @GetMargin = sum(Items.PTR) - sum(Items.PTS) from Items
				where Items.Product_COde = @ItemCode 
		end

	end
	return @GetMargin
End



