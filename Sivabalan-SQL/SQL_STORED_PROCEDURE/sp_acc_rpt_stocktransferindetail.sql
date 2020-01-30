CREATE PROCEDURE [dbo].[sp_acc_rpt_stocktransferindetail](@DocSerial int)
AS
DECLARE @SPECIALCASE2 INT
SET @SPECIALCASE2=5
Declare @Version Int    
Select  @Version=dbo.sp_acc_getversion()    
If @Version = 5 or @Version = 8 Or @Version= 18 Or @Version=19 or @Version=11
Begin
 	Execute sp_acc_rpt_stocktransferindetailUOM @DocSerial
End
Else If @Version = 9 or @VErsion = 10
Begin
	Exec sp_acc_rpt_stocktransferindetailSerail @DocSerial
End
Else
Begin
	SELECT  "Item Code" = stocktransferindetail.Product_Code, 
		"Item Name" = Items.ProductName, "Quantity" = stocktransferindetail.Quantity, 
		"Rate" = stocktransferindetail.Rate, "Gross Amount" = stocktransferindetail.Amount,
		"Tax Suffered" = stocktransferindetail.TaxSuffered, "Tax Amount" = stocktransferindetail.TaxAmount,
		"Total" = stocktransferindetail.TotalAmount,@SPECIALCASE2
	FROM stocktransferindetail
	Left Outer Join Items on stocktransferindetail.Product_Code = Items.Product_Code 
	WHERE   stocktransferindetail.DocSerial = @DocSerial 
	--AND stocktransferindetail.Product_Code *= Items.Product_Code
End
