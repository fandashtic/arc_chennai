CREATE procedure [dbo].[spr_list_open_purchase_orders]
AS
SELECT  PONumber, "PONumber" = POPrefix.Prefix + CAST(DocumentID AS nvarchar), 
	"Vendor" = Vendors.Vendor_Name, "Date" = PODate,
	"Delivery Date" = RequiredDate, Value,
	"POReference" = CASE ISNULL(DocumentReference, 0)
	WHEN 0 THEN NULL
	ELSE DocumentReference
	END,
	"Branch" = ClientInformation.Description
FROM POAbstract, Vendors, VoucherPrefix POPrefix, ClientInformation
WHERE (Status &128) = 0 AND 
	POAbstract.VendorID *= Vendors.VendorID AND
	POPrefix.TranID = 'PURCHASE ORDER' AND
	POAbstract.ClientID *= ClientInformation.ClientID
ORDER BY POAbstract.VendorID
