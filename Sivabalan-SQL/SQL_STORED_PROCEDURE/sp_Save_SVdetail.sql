CREATE procedure sp_Save_SVdetail          
(          
	@SVNumber Integer,@Product_Code nVarchar(15),@StockCount Decimal(18,6),          
	@OffTake Decimal(18,6),@SuggestedQty Decimal(18,6),@ActualQty Decimal(18,6),          
	@UOMID Integer,@UOMQty Decimal(18,6),@SalePrice Decimal(18,6),
	@UOMPrice Decimal(18,6),@AUOMQty Decimal(18,6),@Serial Integer,
	@StkCntUOMQTY Decimal(18,6),@OffTakeUOMQTY Decimal(18,6)
)          

AS          

Insert Into SVDetail          
(          
	SVNumber,Product_Code,StockCount,OffTake,SuggestedQty,ActualQty,
	UOMID,UOMQty,SalePrice,UOMPrice,AUOMQty,Serial,StockCountUOMID,
	StkCntUOMQTY,OffTakeUOMQTY

)          
Values          
(          
	@SVNumber,@Product_Code,@StockCount,@OffTake,@SuggestedQty,@ActualQty,          
	@UOMID,@UOMQty,@SalePrice,@UOMPrice,@AUOMQty,@Serial,@UOMID,--@SalesUOM
	@StkCntUOMQTY,@OffTakeUOMQTY
)
