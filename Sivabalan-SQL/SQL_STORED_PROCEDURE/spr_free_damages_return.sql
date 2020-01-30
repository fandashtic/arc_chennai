CREATE PROCEDURE spr_free_damages_return(@FROMDATE datetime, @TODATE datetime)
AS
Select  Items.Product_Code, "Item Code" = Items.Product_Code, "Item Name" = Items.ProductName, 
	"Free Receipts" = dbo.GetTotalFreeReceived(Items.Product_Code, @FROMDATE, @TODATE),
	"Free Issues" = dbo.GetTotalFreeIssues(Items.Product_Code, @FROMDATE, @TODATE),
	"Expiry Claims" = dbo.GetTotalExpiryClaims(Items.Product_Code, @FROMDATE, @TODATE),
	"Damage Claims" = dbo.GetTotalDamageClaims(Items.Product_Code, @FROMDATE, @TODATE),
	"TM Claims" = dbo.GetTotalTMClaims(Items.Product_Code, @FROMDATE, @TODATE)
From Items
Group By Items.Product_Code, Items.ProductName

