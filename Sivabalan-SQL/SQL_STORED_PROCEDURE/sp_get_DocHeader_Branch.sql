CREATE procedure [dbo].[sp_get_DocHeader_Branch](
 @DocType nvarchar(20),      
 @DocID nvarchar(15))
as
IF @DocType = 'INVOICEBRANCH'      
BEGIN
select ia.*,"CRDESC"= ct.DESCRIPTION,"CRTYPE" = CT.TYPE, "CRVALUE" = CT.VALUE
from invoiceabstract ia
Left Outer Join creditterm ct on ia.creditterm = ct.creditid
where 
--ia.creditterm *= ct.creditid and 
ia.InvoiceID = @DocID
END


