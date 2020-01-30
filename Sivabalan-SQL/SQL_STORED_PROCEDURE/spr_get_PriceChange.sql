CREATE PROCEDURE spr_get_PriceChange(@COMPANYID NVARCHAR(15))
AS

Declare @NOTPROCESS NVarchar(50)
Declare @PROCESS NVarchar(50)

Set @NOTPROCESS = dbo.LookupDictionaryItem(N'Not Processed', Default)
Set @PROCESS = dbo.LookupDictionaryItem(N'Processed', Default)

select  id, "Company" = CompanyID, 
	"Date" = DocumentDate, 
	"Document Type" = DocumentType, 
	"Item Code" = Product_ID, 
	"Item Name" = ProductName,
	"Description" = Description, 
	"MfrID" = ManufacturerID, 
	"Mfr Name" = ManufacturerName, 
	"CategoryID" = CategoryID, 
	"Category Name" = CategoryName, 
	"Sale Price" = SalePrice, 
	"UOM" = UOM, 
	"Remarks" = Remarks, 
	"MRP" = MRP,
	"Status" = case Status & 128
	WHEN 0 THEN @NOTPROCESS
	ELSE @PROCESS
	END
from downloadeditems where [id] in (
select max([id])
from downloadeditems where CompanyID = @COMPANYID
AND DocumentType = N'PriceChange'
group by product_id )order by companyid
