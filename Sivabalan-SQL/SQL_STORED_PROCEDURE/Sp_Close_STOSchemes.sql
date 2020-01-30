Create Procedure Sp_Close_STOSchemes(@DocSerial Int)
as
--SaleType = 1 is for STO
Update SchemeSale Set Pending = 0 
Where SaleType = 1
And InvoiceID = @DocSerial


