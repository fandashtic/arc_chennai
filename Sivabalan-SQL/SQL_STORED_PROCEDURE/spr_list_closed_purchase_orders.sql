CREATE procedure [dbo].[spr_list_closed_purchase_orders](@FROMDATE datetime,
					  @TODATE datetime)
AS
SELECT  PONumber, "PONumber" = POPrefix.Prefix + CAST(DocumentID AS nvarchar), 
	"Vendor" = Vendors.Vendor_Name, "Date" = PODate,
	"Delivery Date" = RequiredDate, Value,
	"GRNID" = CASE ISNULL(NewGRNID, 0)
	WHEN 0 THEN NULL
	ELSE GRNPrefix.Prefix + CAST(NewGRNID AS nvarchar)
	END,
	"POReference" = CASE ISNULL(DocumentReference, 0)
	WHEN 0 THEN NULL
	ELSE DocumentReference
	END,
	"Branch" = ClientInformation.Description
FROM POAbstract, Vendors, VoucherPrefix POPrefix, VoucherPrefix GRNPrefix, ClientInformation
WHERE   PODate BETWEEN @FROMDATE AND @TODATE AND
	POAbstract.VendorID *= Vendors.VendorID AND 
	((Status & 128) <> 0 or (Status & 64) <> 0) AND
	POPrefix.TranID = 'PURCHASE ORDER' AND
	GRNPrefix.TranID = 'GOODS RECEIVED NOTE' AND
	POAbstract.ClientID *= ClientInformation.ClientID
ORDER BY POAbstract.PODate, POAbstract.VendorID
