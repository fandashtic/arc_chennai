CREATE PROCEDURE sp_Cancel_SR_PendingRevert
	  	(@InvoiceID int)      
AS

DECLARE @ItemCode Nvarchar(15)
DECLARE @Batch_Code Int      
DECLARE @Quantity Decimal(18,6)
Declare @SRInvoiceID int
Declare @SRHH_Reference nvarchar(255)
Declare @Serial int
Declare @ReturnType int

Set @SRHH_Reference = ''

Select @SRInvoiceID = SRInvoiceID, @SRHH_Reference = SRHH_Reference, @ReturnType =  Case When (Status & 32) <> 0 Then 2 Else 1 End 
 From InvoiceAbstract Where InvoiceID = @InvoiceID

IF @SRInvoiceID > 0
Begin
	DECLARE ReturnedInvoice CURSOR STATIC FOR
	Select Product_Code, Serial, Sum(Quantity) Qty From InvoiceDetail Where InvoiceID = @InvoiceID and UOMQty > 0 and FlagWord = 0
	Group By Product_Code, Serial
	OPEN ReturnedInvoice
	FETCH FROM ReturnedInvoice INTO  @ItemCode, @Serial, @Quantity
	WHILE @@FETCH_STATUS = 0
	BEGIN
		Update InvoiceDetail Set PendingQty = PendingQty + @Quantity
		Where InvoiceID = @SRInvoiceID and Product_Code = @ItemCode and Serial = @Serial and UOMQty > 0 --and FlagWord = 0

		IF isnull(@SRHH_Reference,'') <> ''
		Begin
			Update Stock_Return Set PendingQty = PendingQty + @Quantity
			Where ReturnNumber = @SRHH_Reference and Product_Code = @ItemCode
			and ReturnType = @ReturnType
		End	
		FETCH NEXT FROM ReturnedInvoice INTO  @ItemCode, @Serial, @Quantity
	END
	CLOSE ReturnedInvoice
	DEALLOCATE ReturnedInvoice
End

