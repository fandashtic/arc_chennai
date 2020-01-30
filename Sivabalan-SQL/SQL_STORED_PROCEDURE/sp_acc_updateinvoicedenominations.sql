
create procedure sp_acc_updateinvoicedenominations(@invoiceid int,@denominations nvarchar(2000))
as
Update InvoiceAbstract 
Set Denominations = @denominations
where InvoiceID = @invoiceid


