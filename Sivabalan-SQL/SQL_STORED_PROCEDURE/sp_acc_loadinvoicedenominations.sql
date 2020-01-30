
CREATE procedure sp_acc_loadinvoicedenominations(@invoiceid int)	
as
select Denominations from InvoiceAbstract 
where InvoiceID = @invoiceid



