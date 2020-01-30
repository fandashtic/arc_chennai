CREATE function [dbo].[fn_GetServiceInvoiceTaxSplit](@invoiceid int,@Servicename nvarchar(250),@serialno int,@gstFlag nvarchar(250),@amtTaxflag nvarchar(250))
returns  decimal(18,6)
As
begin
Declare @result decimal(18,6)

if @amtTaxflag='Per'
BEGIN
select @result=Tax_Percentage from ServiceInvoicesTaxSplitup where Servicename=@Servicename  and  Invoiceid=@Invoiceid and GSTFlag=@GSTFlag  and serialno=@serialno
END
ELSE
BEGIN
select @result=TaxSplitup from ServiceInvoicesTaxSplitup where Invoiceid=@Invoiceid and GSTFlag=@GSTFlag and serialno=@serialno
END

return @result

END
