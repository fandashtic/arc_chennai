CREATE PROCEDURE spr_list_Itemwise_Purchase_Orders(@PRODUCT nvarchar(15),
						   @FROMDATE DATETIME,
						   @TODATE DATETIME)
AS
SELECT PODetail.PONumber, 
"PONumber" = VoucherPrefix.Prefix + CAST(POAbstract.DocumentID AS nVARCHAR), 
POAbstract.PODate, "PO Quantity" = PODetail.Quantity, 
"Pending Quantity" = PODetail.Pending,
PODetail.PurchasePrice, Vendors.Vendor_Name
FROM POAbstract, PODetail, Vendors, VoucherPrefix
WHERE POAbstract.PODate BETWEEN @FROMDATE AND @TODATE
AND POAbstract.PONumber = PODetail.PONumber
AND POAbstract.VendorID = Vendors.VendorID
AND PODetail.Product_Code = @PRODUCT
AND VoucherPrefix.TranID = 'PURCHASE ORDER'
AND isnull(POAbstract.Status,0) & 192 = 0
ORDER BY POAbstract.PODate, POAbstract.PONumber


