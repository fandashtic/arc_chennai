CREATE PROCEDURE sp_cancel_grn(@GRNID int, @OpeningDate datetime = Null, @UserName nvarchar(50) = N'', @Remarks nvarchar(100) = N'', @CancelDate datetime = Null)      
AS      
DECLARE @ITEMCODE nvarchar(15)      
DECLARE @QUANTITY Decimal(18,6)      
DECLARE @PRICE Decimal(18,6)      
DECLARE @FREE Int     
DECLARE @DAMAGE Decimal(18,6)      
DECLARE @BATCHCODE Int  
DECLARE @IS_VAT_ITEM Int --Identifies whether the item is a vat item or not  
DECLARE @VAT_LOCALITY Int --Identifies Batch Locality (1=LST, 2=CST)  
      
IF (Select Count(Batch_code) From Batch_Products Where GRN_ID = @GRNID) = 0      
BEGIN      
	SELECT 0      
	GOTO THEEND      
END      
IF (Select Count(Batch_Code) From Batch_Products Where GRN_ID = @GRNID And Quantity <> QuantityReceived) > 0      
	SELECT 0      
ELSE      
BEGIN      
	Update GRNAbstract Set GRNStatus = GRNStatus | 192,CancelUser = @UserName,Remarks = @Remarks,CancelDate = @CancelDate Where GRNID = @GRNID      
  
	DECLARE UndoOpening CURSOR KEYSET FOR      
	Select Batch_Code, Product_Code, IsNull(QuantityReceived, 0), IsNull(Free, 0), PurchasePrice, IsNull(Damage, 0), IsNull(Vat_Locality,0)   
		From Batch_Products Where GRN_ID = @GRNID      
	  
	Open UndoOpening      
	FETCH FROM UndoOpening INTO @BATCHCODE, @ITEMCODE, @QUANTITY, @FREE, @PRICE, @DAMAGE, @VAT_LOCALITY   
	WHILE @@FETCH_STATUS = 0      
	BEGIN      
		--Updating TaxSuff Percentage in OpeningDetails  
		Select @IS_VAT_ITEM = IsNull(Vat,0) from Items Where Product_Code=@ITEMCODE  
		If Exists (Select * From SysColumns Where Name = N'PTS' And ID = (Select ID From Sysobjects Where Name = N'Items'))    
			If @VAT_LOCALITY = 2 AND @IS_VAT_ITEM = 1  
				Exec Sp_Update_Opening_TaxSuffered_Percentage @OpeningDate, @ITEMCODE, @BATCHCODE, 1, 1  
			Else  
				Exec Sp_Update_Opening_TaxSuffered_Percentage @OpeningDate, @ITEMCODE, @BATCHCODE, 1  
		Else --FMCG Version  
			If @VAT_LOCALITY = 2 AND @IS_VAT_ITEM = 1  
				Exec Sp_Update_Opening_TaxSuffered_Percentage_FMCG @OpeningDate, @ITEMCODE, @BATCHCODE, 1, 1  
			Else  
				Exec Sp_Update_Opening_TaxSuffered_Percentage_FMCG @OpeningDate, @ITEMCODE, @BATCHCODE, 1  
	  
		SET @QUANTITY = 0 - @QUANTITY      
		exec sp_update_opening_Stock @ITEMCODE, @OpeningDate, @QUANTITY, @FREE, @PRICE, @DAMAGE, 0, @BATCHCODE
		FETCH NEXT FROM UndoOpening INTO @BATCHCODE, @ITEMCODE, @QUANTITY, @FREE, @PRICE, @DAMAGE, @VAT_LOCALITY  
	END      
	Close UndoOpening      
	DeAllocate UndoOpening      
	  
	Update Batch_Products Set Quantity = Quantity - QuantityReceived Where GRN_ID = @GRNID      
	SELECT 1      
END      
THEEND:      
      
