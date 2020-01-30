Create PROCEDURE sp_SR_Update_PendingQty(@InvID int, @ItemCode nvarchar(15), @Serial int, @Qty Decimal(18,6) = 0)  
AS
	Declare @Result int
	Declare @PendingQty Decimal(18,6)
	
	Set @Result = 0
	Select @PendingQty = isnull(PendingQty,0) From InvoiceDetail Where InvoiceID = @InvID and Product_Code = @ItemCode and Serial = @Serial and UOMQty > 0

	IF @PendingQty >= @Qty
		Update InvoiceDetail Set PendingQty = isnull(PendingQty,0) - @Qty
		Where InvoiceID = @InvID and Product_Code = @ItemCode and Serial = @Serial and UOMQty > 0 --and FlagWord = 0
	Else
		Set @Result = 1

	Select @Result
