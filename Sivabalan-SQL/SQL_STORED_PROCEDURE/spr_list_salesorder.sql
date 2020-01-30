CREATE PROCEDURE spr_list_salesorder(@FROMDATE datetime,
				     @TODATE datetime)
AS
SET Dateformat dmy
Declare @Expirydate datetime
set @Expirydate= dbo.getSOExpiryDate()

Declare @AMENDED As NVarchar(50)
Declare @CANCELLED  As NVarchar(50)
Declare @CLOSED  As NVarchar(50)
Declare @AMENDMENT  As NVarchar(50)
Declare @OPEN  As NVarchar(50)
Declare @EXPIRED  As NVarchar(50)

Set @AMENDED = dbo.LookupDictionaryItem(N'Amended',Default)
Set @CANCELLED = dbo.LookupDictionaryItem(N'Cancelled',Default)
Set @CLOSED = dbo.LookupDictionaryItem(N'Closed',Default)
Set @AMENDMENT = dbo.LookupDictionaryItem(N'Amendment',Default)
Set @OPEN = dbo.LookupDictionaryItem(N'Open',Default)
Set @EXPIRED = dbo.LookupDictionaryItem(N'Expired',Default)

Create Table #tmpOutput(SONumber int,
[SC Number] nvarchar(200) COLLATE SQL_Latin1_General_CP1_CI_AS,
Customer nvarchar(150)COLLATE SQL_Latin1_General_CP1_CI_AS,
[SC Date] Datetime,
[Delivery Date] DateTime,
[Value] decimal(18,6),
Branch nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
[PO Reference] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
Remarks nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
Status nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)

insert into #tmpOutput(SONumber,[SC Number],Customer,[SC Date],[Delivery Date],[Value],[Branch],[PO Reference],Remarks,Status)
SELECT SONumber, 
	"SC Number" = VoucherPrefix.Prefix + CAST(DocumentID AS nvarchar), 
	"Customer" = Customer.Company_Name, 
	"SC Date" = SODate,
	"Delivery Date" = DeliveryDate, 
	[Value]=Value, 
	"Branch" = ClientInformation.Description,
	"PO Reference" = PODocReference,
    "Remarks"     = Remarks, 
	"Status" = (Case When (Status & 320)=320 then @AMENDED
					 When (Status & 192)=192 then @CANCELLED
					 When (Status & 128)=128 then @CLOSED
					 Else (Case When (isnull(SoRef,0) >0) then @AMENDMENT Else @OPEN End)End)				
FROM SOAbstract
Left Outer Join Customer On SOAbstract.CustomerID = Customer.CustomerID
Inner Join VoucherPrefix On VoucherPrefix.TranID = 'SALE CONFIRMATION' 
Left Outer Join ClientInformation On SOAbstract.ClientID = ClientInformation.ClientID
WHERE SODate BETWEEN @FROMDATE AND @TODATE 
	
update #tmpOutput Set Status =@EXPIRED where status in (@OPEN,@AMENDMENT) And Convert(Nvarchar(10),[SC Date],103) <= @Expirydate 


Select SONumber,[SC Number],Customer,[SC Date],[Delivery Date],[Value],Branch,[PO Reference],Remarks,Status From #tmpOutput

