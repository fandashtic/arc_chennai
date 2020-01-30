Create Procedure mERP_sp_saveGTInvoice(@InvoiceID int,@Type int,@GroupId int,@GroupName nvarchar(255),@LimitValue decimal(18,6),@Value decimal(18,6))
As
Begin
--	Declare @Invoicereference int
		Insert into GT_Invoice(InvoiceID,Documentid,InvoiceType,Alerttype,GroupId,GroupName,DefinedLimit,Value)
		Select @InvoiceID,DocumentID,InvoiceType,@Type,@GroupId,@GroupName,@LimitValue,@Value From invoiceAbstract where Invoiceid= @InvoiceID

--	
--	/* Direct Invoice */
--	If (select InvoiceType from invoiceAbstract where invoiceid=@InvoiceID)=1
--	BEGIN
--		Insert into GT_Invoice(InvoiceID,Documentid,Alerttype,GroupId,GroupName,DefinedLimit,Value)
--		Select @InvoiceID,DocumentID,@Type,@GroupId,@GroupName,@LimitValue,@Value From invoiceAbstract where Invoiceid= @InvoiceID
--	END
--	/* Amendment */
--	ELSE IF (select InvoiceType from invoiceAbstract where invoiceid=@InvoiceID)=3
--	BEGIN
--		Select @Invoicereference=isnull(invoicereference,0) from invoiceabstract where invoiceid=@InvoiceID
--		if exists(Select 'x' from GT_Invoice where invoiceid=@Invoicereference)
--		BEGIN
--			
--				Insert into GT_Invoice(InvoiceID,Documentid,Alerttype,GroupId,GroupName,DefinedLimit,Value)
--				Select @InvoiceID,DocumentID,@Type,@GroupId,@GroupName,@LimitValue,@Value From invoiceAbstract where Invoiceid= @InvoiceID	
--		END
--		ELSE
--		/* For the invoices amended immediately after FSU installation */
--		BEGIN
--			Insert into GT_Invoice(InvoiceID,Documentid,Alerttype,GroupId,GroupName,DefinedLimit,Value)
--			Select @InvoiceID,DocumentID,@Type,@GroupId,@GroupName,@LimitValue,@Value From invoiceAbstract where Invoiceid= @InvoiceID	
--		END
--	END
END
