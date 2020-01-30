Create Procedure sp_Check_Stockinhand(@ITEMCODE nVarchar(30))
As
Declare @TOTALQTY Decimal(18,6)
Declare @Qty decimal(18,6)
Declare @VanQty Decimal(18,6)

Set @TOTALQTY = 0 
--Stock in Batch_products
Select @Qty  = IsNull(Sum(Quantity),0) From Batch_products Where Product_Code = @ITEMCODE
--Stock in Van
Select @VanQty  = IsNull(Sum(Pending),0) From VanStatementDetail Where Product_Code = @ITEMCODE
--Total Stock in Hand
Set @TOTALQTY = @Qty + @VanQty

Select IsNull(@TOTALQTY,0)

