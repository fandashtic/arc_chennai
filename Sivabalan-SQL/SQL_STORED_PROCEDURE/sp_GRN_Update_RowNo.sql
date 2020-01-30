CREATE PROCEDURE sp_GRN_Update_RowNo(@RowNo int, @GRNID int)  
AS  
  
UPDATE GRNdetail SET Serial = @RowNo WHERE GRNid = @GRNID and isnull(Serial,0) = 0  
UPDATE batch_products SET Serial = @RowNo WHERE GRN_id = @GRNID and isnull(Serial,0) = 0  

