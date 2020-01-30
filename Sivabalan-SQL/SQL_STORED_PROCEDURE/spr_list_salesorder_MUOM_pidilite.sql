CREATE procedure [dbo].[spr_list_salesorder_MUOM_pidilite](@FROMDATE datetime,
				     @TODATE datetime, @UOM nvarchar(50))
AS
SELECT SONumber, "SC Number" = VoucherPrefix.Prefix + CAST(DocumentID AS nvarchar), 
	"Customer" = Customer.Company_Name, 
        "Doc Reference" = DocumentReference,  
        "SC Date" = SODate,
	"Delivery Date" = DeliveryDate, Value, "Branch" = ClientInformation.Description,
	"PO Reference" = PODocReference,
    " Remarks"     = Remarks, 
	"Status" = (Case When (Status & 320)=320 then 'Amended'
					 When (Status & 192)=192 then 'Cancelled'
					 When (Status & 128)=128 then 'Closed'
					 Else (Case When (isnull(SoRef,0) >0) then 'Amendment' Else 'Open' End)End)					
FROM SOAbstract, Customer, VoucherPrefix, ClientInformation
WHERE SODate BETWEEN @FROMDATE AND @TODATE 
	AND SOAbstract.CustomerID *= Customer.CustomerID
	AND VoucherPrefix.TranID = 'SALE CONFIRMATION' AND
	SOAbstract.ClientID *= ClientInformation.ClientID
