CREATE procedure [dbo].[spr_list_salesorder_MUOM](@FROMDATE datetime,
				     @TODATE datetime, @UOM nvarchar(50))
AS
Declare @AMENDED As NVarchar(50)
Declare @CANCELLED  As NVarchar(50)
Declare @CLOSED  As NVarchar(50)
Declare @AMENDMENT  As NVarchar(50)
Declare @OPEN  As NVarchar(50)

Set @AMENDED = dbo.LookupDictionaryItem(N'Amended',Default)
Set @CANCELLED = dbo.LookupDictionaryItem(N'Cancelled',Default)
Set @CLOSED = dbo.LookupDictionaryItem(N'Closed',Default)
Set @AMENDMENT = dbo.LookupDictionaryItem(N'Amendment',Default)
Set @OPEN = dbo.LookupDictionaryItem(N'Open',Default)

SELECT SONumber, "SC Number" = VoucherPrefix.Prefix + CAST(DocumentID AS nvarchar), 
	"Customer" = Customer.Company_Name, "SC Date" = SODate,
	"Delivery Date" = DeliveryDate, Value, "Branch" = ClientInformation.Description,
	"PO Reference" = PODocReference,
    " Remarks"     = Remarks, 
	"Status" = (Case When (Status & 320)=320 then @AMENDED
					 When (Status & 192)=192 then @CANCELLED
					 When (Status & 128)=128 then @CLOSED
					 Else (Case When (isnull(SoRef,0) >0) then @AMENDMENT Else @OPEN End)End)					
FROM SOAbstract, Customer, VoucherPrefix, ClientInformation
WHERE SODate BETWEEN @FROMDATE AND @TODATE 
	AND SOAbstract.CustomerID *= Customer.CustomerID
	AND VoucherPrefix.TranID = 'SALE CONFIRMATION' AND
	SOAbstract.ClientID *= ClientInformation.ClientID
