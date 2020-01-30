CREATE Procedure sp_Get_SchInvItemFreePerc(@InvoiceID as integer)  
as  
Declare @SchVal decimal(18,6)
Declare @SchSalVal decimal(18,6)
select @SchSalVal = Sum(isnull(Quantity,0) * isnull(SalePrice,0)) from Invoicedetail where Invoiceid =@invoiceid
Select @SchVal = sum(Isnull(schemevalue,0)) from tbl_merp_SchemeSale TS,tbl_merp_SchemeAbstract SA where Ts.invoiceid = @Invoiceid
and TS.SchemeID=SA.SchemeID and SA.ApplicableOn = 2
if @SchVal > 0 
	select (@SchVal/@SchSalVal ) * 100 'Percentage'
else
	Select 0 'Percentage'

SET QUOTED_IDENTIFIER OFF 
