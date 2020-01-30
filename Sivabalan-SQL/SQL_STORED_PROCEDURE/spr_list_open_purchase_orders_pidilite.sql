CREATE procedure [dbo].[spr_list_open_purchase_orders_pidilite]
AS
SELECT  PONumber, "PONumber" = POPrefix.Prefix + CAST(DocumentID AS nvarchar), 
	"Vendor" = Vendors.Vendor_Name, 
	"Division"=Brand.BrandName,
	"Date" = PODate,
	"Delivery Date" = RequiredDate, Value,
	"POReference" = CASE ISNULL(DocRef, 0)
	WHEN 0 THEN NULL
	ELSE DocRef
	END,
	"Branch" = ClientInformation.Description
FROM POAbstract, Vendors, VoucherPrefix POPrefix, ClientInformation,Brand
WHERE (Status &128) = 0 AND 
	POAbstract.VendorID *= Vendors.VendorID AND
	POPrefix.TranID = 'PURCHASE ORDER' AND
	POAbstract.ClientID *= ClientInformation.ClientID AND
	POAbstract.BrandId*=Brand.BrandID
ORDER BY POAbstract.VendorID
