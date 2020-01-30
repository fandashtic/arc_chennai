CREATE procedure [dbo].[spr_list_cancelled_purchase_orders_pidilite](@FROMDATE datetime,
					  @TODATE datetime)
AS
SELECT  PONumber, "PO Number" = PONumber, "Vendor" = Vendors.Vendor_Name, "Division"=Brand.BrandName, "Date" = PODate,
	"Delivery Date" = RequiredDate, Value,"GRNID" = GRNID,"Remarks" = Remarks
FROM POAbstract, Vendors,Brand
WHERE   PODate BETWEEN @FROMDATE AND @TODATE AND
	POAbstract.VendorID *= Vendors.VendorID AND 
	(Status & 128) <> 0 AND (Status & 64) <> 0 AND
	POAbstract.BrandID*=Brand.BrandID
ORDER BY POAbstract.PODate, POAbstract.VendorID
