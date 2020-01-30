
CREATE PROCEDURE spr_list_received_SO ( @FROMDATE datetime,
				  	@TODATE datetime )
AS
DECLARE @PO NVARCHAR(255)

SELECT @PO = VoucherPrefix.Prefix FROM VoucherPrefix WHERE VoucherPrefix.TranID = N'PURCHASE ORDER'
SELECT  SONumber, 
	"SC Number" = DocumentID, 
	"Date" = SODate, "Vendor" = Vendors.Vendor_Name,
	"Delivery Date" = DeliveryDate, "Value" = Value,
	"PO Reference" = case
	WHEN ISNUMERIC(POReference) <> 0 and ISNULL(POReference, 0) = 0 THEN NULL
	WHEN ISNUMERIC(POReference) = 0 THEN ISNULL(POReference, N'')
	ELSE @PO + CAST(POReference AS NVARCHAR)
	END	
FROM 	SOAbstractReceived, vendors
WHERE   SODate BETWEEN @FROMDATE AND @TODATE AND
	SOAbstractReceived.VendorID=Vendors.VendorID


