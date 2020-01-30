
Create VIEW  [dbo].[V_Invoice_SMS] 
	([InvoiceID],[InvoiceType],[InvoiceDate],[CreationDate],[CustID],[NetValue],
		[SalesmanID],[BeatID],[DocumentID],[NewInvocieReference],[DocReference],
		[Status],[Balance])
As 
	 select * from Fn_InvoiceAlert_ITC ()
