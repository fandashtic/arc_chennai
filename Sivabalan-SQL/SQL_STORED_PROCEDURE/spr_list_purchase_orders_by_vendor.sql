CREATE procedure [dbo].[spr_list_purchase_orders_by_vendor](@VendorID nvarchar (2550),
                                                    @FROMDATE datetime,
	                			  					  @TODATE datetime)
AS

Declare @Delimeter as Char(1)  
Set @Delimeter=Char(15)  

create table #tmpVen(Vendor_Name nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
if @VendorID='%'
   insert into #tmpVen select Vendor_Name from Vendors
else
   insert into #tmpVen select * from dbo.sp_SplitIn2Rows(@VendorID,@Delimeter)

SELECT  PONumber, "Vendor" = Vendors.Vendor_Name, 
	"PONumber" = POPrefix.Prefix + CAST(DocumentID AS nvarchar), 
	"Date" = PODate,
	"Delivery Date" = RequiredDate, Value,
	"GRNID" = CASE ISNULL(NewGRNID, 0)
	WHEN 0 THEN NULL
	ELSE GRNPrefix.Prefix + CAST(NewGRNID AS nvarchar)
	END,
	"POReference" = CASE ISNULL(DocumentReference, 0)
	WHEN 0 THEN NULL
	ELSE DocumentReference
	END,
	"Status" = case Status & 192
	WHEN 0 THEN 'Open'
	WHEN 128 THEN 'Closed'
	ELSE 'Cancelled'
	END,
	"Branch" = ClientInformation.Description
FROM POAbstract, VoucherPrefix POPrefix, VoucherPrefix GRNPrefix, Vendors, ClientInformation
WHERE   PODate BETWEEN @FROMDATE AND @TODATE AND
	POAbstract.VendorID = Vendors.VendorID AND 
	Vendors.Vendor_Name in(select Vendor_Name COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpVen) AND
	POPrefix.TranID = 'PURCHASE ORDER' AND
	GRNPrefix.TranID = 'GOODS RECEIVED NOTE' AND 
	POAbstract.ClientID *= ClientInformation.ClientID
ORDER BY POAbstract.PONumber

drop table #tmpVen
