Create Procedure mERP_sp_saveGTOverdueInvoice
As
Begin
	Select 0
	/* Below lines are commented as ITC informed that it is not required to track the invoices 
	which are overdue exceeded and shown in Forum login alert */

--		Insert into GT_Invoice(InvoiceID,Documentid,InvoiceType,Alerttype,GroupId,GroupName,DefinedLimit,Value)
--		SELECT InvoiceID,DocumentID,InvoiceType,4,0,'',0,0 FROM InvoiceAbstract  
--		WHERE PaymentDate <= Getdate() and  
--		Balance <> 0 and  
--		InvoiceType in (1, 3) and  
--		Status & 128 = 0  And invoiceid not in (select invoiceid from GT_Invoice where AlertType=4)
END
