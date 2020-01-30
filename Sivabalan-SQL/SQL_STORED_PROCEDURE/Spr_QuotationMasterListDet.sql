Create PROCEDURE Spr_QuotationMasterListDet(@QuotationID INT)
AS
DECLARE @QuotationType INT
DECLARE @MfrCatType INT
Declare @YES As NVarchar(50)
Declare @NO As NVarchar(50)
Declare @CATEGORY As NVarchar(50)
Declare @MANUFACTURER As NVarchar(50)
Declare @ECP As NVarchar(50)
Declare @PURCHASE  As NVarchar(50)
Declare @MRP As NVarchar(50)
Declare @SALEPRICE As NVarchar(50)

Set @YES = dbo.LookupDictionaryItem(N'Yes', Default)
Set @NO = dbo.LookupDictionaryItem(N'No', Default)
Set @CATEGORY = dbo.LookupDictionaryItem(N'Category', Default)
Set @MANUFACTURER = dbo.LookupDictionaryItem(N'Manufacturer', Default)
Set @ECP = dbo.LookupDictionaryItem(N'ECP', Default)
Set @PURCHASE = dbo.LookupDictionaryItem(N'Purchase', Default)
Set @MRP = dbo.LookupDictionaryItem(N'MRP', Default)
Set @SALEPRICE = dbo.LookupDictionaryItem(N'SALEPRICE', Default)

SELECT @QuotationType = QuotationLevel FROM QuotationAbstract WHERE QuotationID = @QuotationID

IF @QuotationType = 1
	Select "Quotation ID" = QI.QuotationID, "Item Code" = QI.Product_Code,"Item Name" = Item.ProductName,"UOM" = U.Description ,
	"Purchase Price" = QI.PurchasePrice , "Sale Price" = QI.SalePrice , "ECP" = QI.ECP ,
	"Variance On" = 	CASE QI.MarginOn WHEN 1 THEN @ECP WHEN 2 THEN	@PURCHASE WHEN 3 THEN	@MRP When 4 Then @SALEPRICE END,
	"Variance Percentage" = QI.MarginPercentage, 
	"Rate Quoted" = QI.RateQuoted ,
	"LST_Percentage" =  (Select Top 1 ISNULL(LSTTax.Percentage,0) From Tax LSTTax Where LSTTax.Tax_Code = QI.QuotedTax), 
	"Spl Tax LST" = (Select Top 1 ISNULL(SplTax.Percentage,0) From Tax SplTax Where SplTax.Tax_Code = QI.Quoted_LSTTax)
	From QuotationItems QI
	Join Items Item On Item.Product_Code = QI.Product_Code 
	Join UOM U On U.UOM = Item.UOM 	
	Where QI.QuotationID  = @QuotationID
Else IF @QuotationType = 2
	Select "Quotation ID" = QC.QuotationID , "Item Code" = ItemCat.Category_Name ,"Item Name" = '',"UOM" = '' ,
	"Purchase Price" = '' , "Sale Price" = '' , "ECP" ,
	"Variance On" = 	CASE QC.MarginOn  WHEN 1 THEN @ECP WHEN 2 THEN	@PURCHASE WHEN 3 THEN	@MRP When 4 Then @SALEPRICE END,
	"Variance Percentage" = QC.MarginPercentage , 
	"Rate Quoted" = '' ,
	"LST_Percentage" = '',
	"Spl Tax LST" = ''
	From QuotationMfrCategory QC
	Join ItemCategories ItemCat On ItemCat.CategoryID  = QC.MfrCategoryID  
	Where QC.QuotationID = @QuotationID
Else
	Select "Quotation ID" , "Item Code" ,"Item Name" ,"UOM"  ,
	"Purchase Price" , "Sale Price" , "ECP" ,
	"Variance On" ,
	"Variance Percentage" ,
	"Rate Quoted" ,
	"LST_Percentage",
	"Spl Tax LST" 
