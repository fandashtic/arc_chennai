CREATE PROCEDURE [dbo].[sp_acc_rpt_stocktransferoutdetail](@DocSerial int)
AS
DECLARE @SPECIALCASE2 INT
SET @SPECIALCASE2=5
Declare @Version Int

Select @Version = dbo.sp_acc_getversion()    
If @Version = 5 or @Version = 8 or @Version= 18 or @Version=19  or @Version=11 
Begin
 	Execute sp_acc_rpt_stocktransferOutdetailUOM @DocSerial
End
Else If @Version = 9 or @Version = 10
Begin
	Exec sp_acc_rpt_stocktransferoutdetailSerial @DocSerial
End
Else
Begin
	SELECT  "Item Code" = stocktransferoutdetail.Product_Code, 
		"Item Name" = Items.ProductName, "Quantity" = stocktransferoutdetail.Quantity, 
		"Rate" = stocktransferoutdetail.Rate, "Gross Amount" = stocktransferoutdetail.Amount,
		"Tax Suffered" = stocktransferoutdetail.TaxSuffered, "Tax Amount" = stocktransferoutdetail.TaxAmount,
		"Total" = stocktransferoutdetail.TotalAmount,@SPECIALCASE2
	FROM stocktransferoutdetail
	Left Outer Join Items on stocktransferoutdetail.Product_Code = Items.Product_Code
	WHERE   stocktransferoutdetail.DocSerial = @DocSerial 
		--AND stocktransferoutdetail.Product_Code *= Items.Product_Code
End
