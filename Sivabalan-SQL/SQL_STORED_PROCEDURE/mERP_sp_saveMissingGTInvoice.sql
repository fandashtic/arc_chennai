Create Procedure mERP_sp_saveMissingGTInvoice(@InvoiceID int)
As
Begin
	Declare @InvoiceReference int
	Declare @Type int
	Declare @GroupID int
	
	Select @InvoiceReference=isnull(invoicereference,0) from invoiceabstract where invoiceid=@InvoiceID
	/* If there is no alert while amending invoice*/
	if not exists (select 'x'from GT_invoice where invoiceid=@InvoiceID)
	BEGIN
		If(select invoiceType from invoiceAbstract where invoiceid=@InvoiceID)=3
		BEGIN
			if exists (select 'x'from GT_invoice where invoiceid=@InvoiceReference)
			BEGIN
				Insert into GT_Invoice(InvoiceID,Documentid,InvoiceType,Alerttype,GroupId,GroupName,DefinedLimit,Value)
				Select @InvoiceID,Documentid,3,Alerttype,GroupId,GroupName,DefinedLimit,Value from GT_Invoice where invoiceID=@InvoiceReference
			END
		END
	END
	ELSE
	BEGIN
		Declare AllData Cursor For select AlertType,GroupID from GT_invoice where invoiceid=@InvoiceReference
		Open AllData
		Fetch from AllData into @Type,@GroupID
		While @@fetch_status=0
		BEGIN
			if not exists (select 'x'from GT_invoice where invoiceid=@InvoiceID and AlertType=@Type And GroupID=@GroupID)		
			BEGIN
				Insert into GT_Invoice(InvoiceID,Documentid,InvoiceType,Alerttype,GroupId,GroupName,DefinedLimit,Value)
				Select @InvoiceID,Documentid,3,Alerttype,GroupId,GroupName,DefinedLimit,Value from GT_Invoice where 
				invoiceID=@InvoiceReference and AlertType=@Type And GroupID=@GroupID
			END
			Fetch Next from AllData into @Type,@GroupID
		END
		Close AllData
		Deallocate AllData
	END
END
