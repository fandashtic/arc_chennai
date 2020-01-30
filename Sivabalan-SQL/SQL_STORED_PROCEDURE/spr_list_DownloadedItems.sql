CREATE PROCEDURE spr_list_DownloadedItems(@COMPANYID NVARCHAR(15),
					  @FROMDATE datetime,
					  @TODATE datetime)
AS
Declare @PROCESSED As NVarchar(50)
Declare @NOTPROCESSED As NVarchar(50)
Set @PROCESSED = dbo.LookupDictionaryItem(N'Processed',Default)
Set @NOTPROCESSED = dbo.LookupDictionaryItem(N'Not Processed',Default) 

select DocumentDate, 
"Download Date" = DocumentDate,
"Status" = 
CASE Status & 128
WHEN 128 THEN
@PROCESSED
ELSE
@NOTPROCESSED
END,
"Item Code" = Product_ID, "Item Name" = ProductName, 
"Description" = Description, "Sale Price" = SalePrice, 
"UOM" = UOM, "Remarks" = Remarks, "MRP" = MRP
from downloadeditems where [id] in (
select max([id])
from downloadeditems 
where CompanyID = @COMPANYID
AND DocumentType != 'PriceChange'
AND DocumentDate BETWEEN @FROMDATE AND @TODATE
group by product_id )order by companyid
