CREATE procedure [dbo].[spr_list_purchase_orders](@FROMDATE datetime,
					  @TODATE datetime)
AS
SELECT  PONumber, 
	"PONumber" = POPrefix.Prefix + CAST(DocumentID AS NVARCHAR), 
	"Vendor" = Vendors.Vendor_Name, "Date" = PODate,
	"Delivery Date" = RequiredDate, Value, 	
	"GRNID" = CASE ISNULL(NewGRNID, 0)
	WHEN 0 THEN NULL
	ELSE GRNPrefix.Prefix + CAST(NewGRNID AS NVARCHAR)
	END,
	"Doc Reference" = DocRef,
	"POReference" = CASE ISNULL(DocumentReference, 0)
	WHEN 0 THEN NULL
	ELSE POPrefix.Prefix + CAST(DocumentReference AS NVARCHAR)
	END,
	"Status" = case Status & 192
	WHEN 0 THEN 'Open'
	WHEN 128 THEN 'Closed'
	ELSE 'Cancelled'
	END,
	"Branch" = ClientInformation.Description
FROM POAbstract, Vendors, VoucherPrefix GRNPrefix, VoucherPrefix POPrefix, ClientInformation
WHERE   PODate BETWEEN @FROMDATE AND @TODATE AND
	POAbstract.VendorID *= Vendors.VendorID	AND
	POPrefix.TranID = 'PURCHASE ORDER' AND
	GRNPrefix.TranID = 'GOODS RECEIVED NOTE' AND
	POAbstract.ClientID *= ClientInformation.ClientID
ORDER BY POAbstract.PONumber
