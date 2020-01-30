CREATE PROCEDURE [dbo].[sp_acc_rpt_billdetail1](@BILLID int)
AS
DECLARE @SPECIALCASE2 INT
Declare @Version Int
SET @SPECIALCASE2=5

Set @Version = dbo.sp_acc_getversion()

If @Version = 5 or @Version = 8 or @Version= 18 or @Version=19 or @Version=11
Begin
	Execute sp_acc_rpt_billdetailuom1 @BILLID
End
Else If @Version = 9 or @Version = 10  
Begin
 	Execute sp_acc_rpt_billdetailserial1 @BILLID  
End
Else
Begin
	SELECT  "Item Code" = BillDetail.Product_Code, 
		"Item Name" = Items.ProductName, "Quantity" = BillDetail.Quantity, 
		'','','','','','','',
		"Rate" = BillDetail.PurchasePrice, "Gross Amount" = BillDetail.Amount,
		"Tax Suffered" = BillDetail.TaxSuffered, "Tax Amount" = BillDetail.TaxAmount,
		"Total" = BillDetail.Amount + BillDetail.TaxAmount,@SPECIALCASE2
	FROM BillDetail
	Left Join Items on BillDetail.Product_Code = Items.Product_Code
	WHERE   BillDetail.BillID = @BILLID 
	--AND BillDetail.Product_Code *= Items.Product_Code
End




