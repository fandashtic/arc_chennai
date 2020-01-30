CREATE PROCEDURE sp_Bills_Update_RowNo(@RowNo int, @BillID int)  
AS  
  
UPDATE Billdetail SET Serial = @RowNo WHERE Billid = @BillID and isnull(Serial,0) = 0  

