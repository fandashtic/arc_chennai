CREATE Procedure sp_ser_updateinvoice (@InvoiceID int) 
as
Declare @retval int
/* Updating VatAmount */
Update a Set a.VatTaxAmount_Spares = 
(case 
	(Select IsNull(c.Locality,1) from Customer c Where c.CustomerID = a.CustomerID) 
When 2 then 0 
Else 	(Select Sum(Isnull(d.LSTPayable, 0) + Isnull(d.CSTPayable, 0)) 
	from ServiceInvoiceDetail d 
	Where d.ServiceInvoiceID = a.ServiceInvoiceId and 
		Isnull(d.Vat_Exists, 0) = 1 and Isnull(d.SpareCode, 0) <> '' group by d.Vat_Exists)
end)
from ServiceInvoiceAbstract a Where a.ServiceInvoiceID = @InvoiceID

set @retval = @@Rowcount
Select @retval 'ReturnValue' 

