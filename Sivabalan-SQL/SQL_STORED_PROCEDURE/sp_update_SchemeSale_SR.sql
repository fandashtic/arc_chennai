Create Procedure sp_update_SchemeSale_SR @InvoiceID int as
Update SchemeSale Set Cost = Cost * (Case When Cost > 0 then -1 else 1 end)
Where InvoiceID = @InvoiceID

