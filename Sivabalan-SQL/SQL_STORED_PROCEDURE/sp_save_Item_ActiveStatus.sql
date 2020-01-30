Create Procedure sp_save_Item_ActiveStatus(@ACTVALUE Int, @ITEMCODE nVarchar(30))
As
Declare @TOTALQTY Decimal(18,6)
Declare @Qty decimal(18,6)
Declare @VanQty Decimal(18,6)

Set @TOTALQTY = 0 
If @ACTVALUE = 0  
    Begin 
	Select @Qty  = IsNull(Sum(Quantity),0) From Batch_products 
	Where Product_Code = @ITEMCODE
	Select @VanQty  = IsNull(Sum(Pending),0) From VanStatementDetail
	Where Product_Code = @ITEMCODE
	Set @TOTALQTY = @Qty + @VanQty
	IF @TOTALQTY > 0 
	BEGIN
	SELECT 0
	GOTO ALLSAIDDONE
	END
    End 

Update Items Set Active = @ACTVALUE Where Product_Code = @ITEMCODE
SELECT 1
ALLSAIDDONE:


