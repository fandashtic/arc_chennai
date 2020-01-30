Create PROCEDURE sp_Inv_Update_RowNo(@RowNo int,@InvID int,@ECP Decimal(18,6), @UpdateECP int = 1, @InvoiceType int = 1, @Qty Decimal(18,6) = 0)  
AS  
	-- This is to Identify the Rows of the invoice w.r.t the grid.  
	UPDATE Invoicedetail SET Serial = @RowNo WHERE Invoiceid = @InvID and isnull(Serial,0) = 0  
	IF @@ROWCOUNT > 0  and @UpdateECP = 1
	UPDATE Invoicedetail SET MRP = @ECP WHERE Invoiceid = @InvID and Serial = @RowNo and not mrp is null  

	IF @InvoiceType <> 4
		Update InvoiceDetail Set PendingQty = @Qty Where InvoiceID = @InvID and Serial = @RowNo and UOMQty > 0 --and FlagWord = 0

	Exec mERP_sp_Insert_RebateDetails @InvID, @RowNo
