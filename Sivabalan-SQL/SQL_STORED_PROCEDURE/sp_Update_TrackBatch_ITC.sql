
CREATE procedure sp_Update_TrackBatch_ITC(@ITEM_CODE nvarchar(15))
as

--Backup of tables

If Not Exists(Select * From sysobjects Where name like 'temp1_invoicedetail')
Begin
	select invoiceID,Product_Code,Batch_Number into temp_invoicedetail from invoicedetail where Product_code = @ITEM_CODE
End

If Not Exists(Select * From sysobjects Where name like 'temp1_vanstatementdetail')
Begin
	select [ID],Product_code,Batch_Number into temp_vanstatementdetail from vanstatementdetail where Product_code = @ITEM_CODE
End

If Not Exists(Select * From sysobjects Where name like 'temp1_adjustmentreturndetail')
Begin
	select AdjustmentID,Product_Code,BatchNumber into temp_adjustmentreturndetail from adjustmentreturndetail where Product_code = @ITEM_CODE
End

If Not Exists(Select * From sysobjects Where name like 'temp1_stockadjustment')
Begin
	select SerialNO,Product_Code,Batch_Number into temp_stockadjustment from stockadjustment where Product_code = @ITEM_CODE
End

If Not Exists(Select * From sysobjects Where name like 'temp1_stocktransferindetail')
Begin
	select DocSerial,Product_Code,Batch_Number into temp_stocktransferindetail from stocktransferindetail where Product_code = @ITEM_CODE
End

If Not Exists(Select * From sysobjects Where name like 'temp1_stocktransferoutdetail')
Begin
	select DocSerial,Product_Code,Batch_Number into temp_stocktransferoutdetail from stocktransferoutdetail where Product_code = @ITEM_CODE
End

If Not Exists(Select * From sysobjects Where name like 'temp1_vantransferdetail')
Begin
	select DocSerial,Product_Code,BatchNumber into temp_vantransferdetail from vantransferdetail where Product_code = @ITEM_CODE
End

If Not Exists(Select * From sysobjects Where name like 'temp1_sodetail')
Begin
	select SONumber,Product_Code,Batch_Number into temp_sodetail from sodetail where Product_code = @ITEM_CODE
End

If Not Exists(Select * From sysobjects Where name like 'temp1_batch_products')
Begin
	select batch_code,Product_Code,Batch_Number,pkd into temp_batch_products from batch_products where Product_code = @ITEM_CODE
End

--Backup completed

--Updating tables

update batch_products set batch_Number=''  where Product_code = @ITEM_CODE

update batch_products set pkd=''  where Product_code = @ITEM_CODE

update invoicedetail set batch_Number=''  where Product_code = @ITEM_CODE

update vanstatementdetail set batch_Number=''  where Product_code = @ITEM_CODE

update adjustmentreturndetail set batchNumber=''  where Product_code = @ITEM_CODE

update stockadjustment set batch_Number=''  where Product_code = @ITEM_CODE

update stocktransferindetail set batch_Number=''  where Product_code = @ITEM_CODE

update stocktransferoutdetail set batch_Number=''  where Product_code = @ITEM_CODE

update vantransferdetail set batchNumber=''  where Product_code = @ITEM_CODE

update sodetail set batch_Number=''  where Product_code = @ITEM_CODE

--Updation completed
