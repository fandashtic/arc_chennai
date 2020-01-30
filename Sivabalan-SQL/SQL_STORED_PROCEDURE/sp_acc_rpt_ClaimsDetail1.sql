CREATE PROCEDURE sp_acc_rpt_ClaimsDetail1(@CLAIMID INT)

AS
DECLARE @SPECIALCASE2 INT
SET @SPECIALCASE2 = 5

Declare @Version Int  

Set @Version = dbo.sp_acc_getversion()  

If @Version = 9 or @Version = 10
Begin
	Execute sp_acc_rpt_ClaimsDetailSerial1 @CLAIMID
End
Else
Begin
	SELECT "Item Code" = ClaimsDetail.Product_Code, 
	"Item Name" = Items.ProductName, ClaimsDetail.Batch,
	'','','','','','','', ClaimsDetail.Expiry, 
	"Purchase Price" = ClaimsDetail.PurchasePrice, 
	ClaimsDetail.Quantity, ClaimsDetail.Rate, 
	Quantity * Rate AS "Value", Remarks,@SPECIALCASE2 FROM ClaimsDetail, Items
	WHERE ClaimsDetail.ClaimID = @CLAIMID
	AND ClaimsDetail.Product_Code = Items.Product_Code
End	








