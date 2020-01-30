
Create Procedure Sp_Delete_RecPriceMatrix (@ITEM_CODE nVarchar(15), @SERIAL Int)
As
BEGIN
    Update PricingAbstractReceived Set Flag = 32 Where ItemCode=@ITEM_CODE And Serial = @SERIAL  
END

