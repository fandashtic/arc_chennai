CREATE PROCEDURE sp_Inv_Update_RowNo_fmcg(@RowNo int,@InvID int)  
AS  
-- This is to Identify the Rows of the invoice w.r.t the grid.  
UPDATE Invoicedetail SET Serial = @RowNo WHERE Invoiceid = @InvID and isnull(Serial,0) = 0


